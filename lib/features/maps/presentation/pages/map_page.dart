import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/services/map_service.dart';
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

  Future<void> _initLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
    if (context.mounted) {
      context.read<MapCubit>().loadTackleShops(userLocation!);
    }
  }

  void _showAddFishingSpotDialog(LatLng latLng) {
    Uint8List? selectedImage;
    String title = '';
    String description = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Fishing Spot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final spot = FishingSpot(
                  id: '',
                  title: title,
                  description: description,
                  lat: latLng.latitude,
                  lng: latLng.longitude,
                );
                context.read<MapCubit>().addFishingSpot(spot);
                setState(() => pinLocation = latLng);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void handleAddPressedFromNavBar() async {
    if (_tabController.index == 0) {
      _tabController.animateTo(1);
      context.read<MapCubit>().loadFishingSpots();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap on the map to add a fishing spot')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap on the map to add a fishing spot')),
      );
    }
  }

  Widget buildMap(bool showTackleShops) {
    return userLocation == null
        ? const Center(child: CircularProgressIndicator())
        : BlocBuilder<MapCubit, MapState>(
          builder: (context, state) {
            final combinedMarkers = {
              ...state.markers,
              if (pinLocation != null)
                Marker(
                  markerId: const MarkerId("pin_marker"),
                  position: pinLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
            };
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userLocation!,
                zoom: 14,
              ),
              onMapCreated: (controller) => mapController = controller,
              myLocationEnabled: true,
              markers: combinedMarkers,
              onTap: (position) {
                if (_tabController.index == 1) {
                  _showAddFishingSpotDialog(position); // no setState here
                }
              },
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Tackle Shops'), Tab(text: 'Fishing Spots')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [buildMap(true), buildMap(false)],
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
