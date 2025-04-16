import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/app.dart';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';
import 'package:fyp/features/maps/presentation/components/fishing_spot_popup.dart';
import 'package:fyp/features/maps/presentation/cubit/map_states.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/tackle_shop.dart';
import '../../domain/services/map_service.dart';

enum MapMode { tackle, fishing }

class MapCubit extends Cubit<MapState> {
  final MapService _mapService;

  MapCubit(this._mapService)
    : super(MapState(mode: MapMode.tackle, markers: {}));

  Future<void> loadTackleShops(LatLng userLocation) async {
    final allShops = await _mapService.fetchNearbyTackleShops(
      userLocation.latitude,
      userLocation.longitude,
    );

    const maxDistanceInMeters = 5000; // e.g., 5km

    final nearbyShops =
        allShops.where((shop) {
          final distance = Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            shop.lat,
            shop.lng,
          );
          return distance <= maxDistanceInMeters;
        }).toList();

    final markers =
        nearbyShops
            .map(
              (s) => Marker(
                markerId: MarkerId(s.id),
                position: LatLng(s.lat, s.lng),
                infoWindow: InfoWindow(title: s.name),
              ),
            )
            .toSet();

    emit(state.copyWith(mode: MapMode.tackle, markers: markers));
  }

  Future<void> loadFishingSpots() async {
    final spots = await _mapService.fetchFishingSpots();
    final markers =
        spots
            .map(
              (s) => Marker(
                markerId: MarkerId(s.id),
                position: LatLng(s.lat, s.lng),
                onTap: () {
                  showDialog(
                    context:
                        navigatorKey
                            .currentContext!, // 👈 Make sure you define this
                    builder: (_) => FishingSpotPopup(spot: s),
                  );
                },
              ),
            )
            .toSet();
    emit(
      state.copyWith(
        mode: MapMode.fishing,
        markers:
            markers
                as Set<
                  Marker
                >?, // ✅ This should already work IF `markers` is Set<Marker>
      ),
    );
  }

  Future<void> addFishingSpot(FishingSpot spot) async {
    await _mapService.addFishingSpot(spot);
    await loadFishingSpots(); // refresh
  }

  void enableAddFishingSpotMode() {
    emit(
      state.copyWith(mode: MapMode.fishing),
    ); // or however you're managing modes
  }
}
