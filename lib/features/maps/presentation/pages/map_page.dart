import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';
import 'package:fyp/features/maps/presentation/components/fishing_spot_popup.dart';
import 'package:fyp/features/maps/presentation/cubit/map_states.dart';
import 'package:fyp/features/weather/presentation/components/weather_search.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/map_cubit.dart';

class MapPage extends StatefulWidget {
  final TabController? externalTabController;
  const MapPage({super.key, this.externalTabController});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with TickerProviderStateMixin {
  GoogleMapController? mapController;
  LatLng? userLocation;
  late TabController _tabController;
  LatLng? pinLocation;
  bool _isMapLoading = true;
  String? selectedTackleShopName;
  LatLng? selectedTackleShopLatLng;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController =
        widget.externalTabController ?? TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initLocation();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && userLocation != null) {
      if (_tabController.index == 0) {
        context.read<MapCubit>().loadTackleShops(userLocation!);
      } else {
        context.read<MapCubit>().loadFishingSpots();
      }
    }
  }

  Future<void> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationDeniedPopup(); // 👈 show custom popup
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationDeniedPopup(permanentlyDenied: true);
      return;
    }
  }

  void _showLocationDeniedPopup({bool permanentlyDenied = false}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: Text(
              permanentlyDenied
                  ? 'Location permission is permanently denied. Please enable it in settings.'
                  : 'This app needs location access to find your position.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (permanentlyDenied) {
                    Geolocator.openAppSettings(); // Open device settings
                  }
                },
                child: Text(permanentlyDenied ? 'Open Settings' : 'OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _initLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
      if (context.mounted) {
        context.read<MapCubit>().loadTackleShops(userLocation!);
      }
    }
  }

  void showFishingSpotPopup(BuildContext context, FishingSpot spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FishingSpotPopup(spot: spot),
    );
  }

  Widget buildMap(bool showTackleShops) {
    return userLocation == null
        ? const Center(child: CircularProgressIndicator())
        : BlocBuilder<MapCubit, MapState>(
          builder: (context, state) {
            final contextState = context.read<MapCubit>().state;

            final filteredMarkers = contextState.markers.where((marker) {
              final id = marker.markerId.value;
              return showTackleShops
                  ? id.startsWith('tackle_')
                  : id.startsWith('spot_');
            });

            final markersWithTap =
                filteredMarkers.map((marker) {
                  final markerId = marker.markerId.value;

                  // Fishing spot
                  if (markerId.startsWith('spot_')) {
                    final spot = contextState.fishingSpots.firstWhere(
                      (s) => 'spot_${s.id}' == markerId,
                      orElse:
                          () => FishingSpot(
                            id: '',
                            description: '',
                            lat: 0,
                            lng: 0,
                          ),
                    );

                    return marker.copyWith(
                      onTapParam: () => showFishingSpotPopup(context, spot),
                    );
                  }

                  // Tackle shop
                  if (markerId.startsWith('tackle_')) {
                    return marker.copyWith(
                      onTapParam: () {
                        setState(() {
                          selectedTackleShopName = marker.infoWindow.title;
                          selectedTackleShopLatLng = marker.position;
                        });
                      },
                    );
                  }

                  return marker;
                }).toSet();

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userLocation!,
                zoom: 14,
              ),
              onMapCreated: (controller) => mapController = controller,
              myLocationEnabled: true,
              markers: markersWithTap,
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //Tab-based maps (Tackle Shops / Fishing Spots)
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [buildMap(true), buildMap(false)],
          ),

          // 🔍 Location Search Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: LocationSearchBar(
                onLocationPicked: (name, lat, lng) {
                  mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
                  );
                },
              ),
            ),
          ),

          // if (selectedTackleShopName != null &&
          //     selectedTackleShopLatLng != null)
          //   Positioned(
          //     bottom: 100,
          //     left: MediaQuery.of(context).size.width / 2 - 100,
          //     child: Material(
          //       elevation: 4,
          //       color: Colors.transparent,
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 16,
          //           vertical: 8,
          //         ),
          //         decoration: BoxDecoration(
          //           color: Colors.black.withOpacity(0.8),
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         child: Text(
          //           selectedTackleShopName!,
          //           style: const TextStyle(color: Colors.white, fontSize: 14),
          //         ),
          //       ),
          //     ),
          //   ),

          //Floating buttons
          //Floating buttons with center location
          Positioned(
            top: 100,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'tackle',
                  mini: true,
                  backgroundColor:
                      _tabController.index == 0 ? Colors.blue : Colors.grey,
                  onPressed: () {
                    setState(() => _tabController.index = 0);
                  },
                  child: const Icon(Icons.shopping_bag),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'fish',
                  mini: true,
                  backgroundColor:
                      _tabController.index == 1 ? Colors.blue : Colors.grey,
                  onPressed: () {
                    setState(() => _tabController.index = 1);
                  },
                  child: const Icon(Icons.location_pin),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'center',
                  mini: true,
                  backgroundColor: Colors.teal,
                  onPressed: () {
                    if (userLocation != null && mapController != null) {
                      mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(userLocation!, 14),
                      );
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
}
