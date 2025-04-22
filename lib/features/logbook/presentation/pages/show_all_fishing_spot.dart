import 'package:flutter/material.dart';
import 'package:fyp/features/maps/presentation/components/fishing_spot_popup.dart';
import 'package:fyp/features/weather/presentation/components/weather_search.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';
import 'package:fyp/features/logbook/data/firebase_logbook_repo.dart';
import 'package:fyp/features/auth/presentation/cubits/auth_cubit.dart';

class ShowAllFishingSpot extends StatefulWidget {
  const ShowAllFishingSpot({super.key});

  @override
  State<ShowAllFishingSpot> createState() => _ShowAllFishingSpotState();
}

class _ShowAllFishingSpotState extends State<ShowAllFishingSpot> {
  final _repo = FirebaseLogbookRepo();
  List<FishingSpot> userSpots = [];
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    final username = context.read<AuthCubit>().currentUser?.username;
    if (username != null) {
      _repo.fetchUserSpots(username).then((spots) {
        setState(() {
          userSpots = spots;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Fishing Spots")),
      body: Stack(
        children: [
          userSpots.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                onMapCreated: (controller) => mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: LatLng(userSpots[0].lat, userSpots[0].lng),
                  zoom: 10,
                ),
                markers:
                    userSpots.map((spot) {
                      return Marker(
                        markerId: MarkerId(spot.id),
                        position: LatLng(spot.lat, spot.lng),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) => FishingSpotPopup(spot: spot),
                          );
                        },
                      );
                    }).toSet(),
              ),

          //Add the search bar overlay
          Positioned(
            top: MediaQuery.of(context).padding.top,
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
        ],
      ),
    );
  }
}
