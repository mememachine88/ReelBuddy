import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/fishing_spots.dart';
import '../../data/models/tackle_shop.dart';
import '../../domain/services/map_service.dart';
import 'map_states.dart';

enum MapMode { tackle, fishing }

class MapCubit extends Cubit<MapState> {
  final MapService _mapService;

  MapCubit(this._mapService)
    : super(MapState(mode: MapMode.tackle, markers: {}, fishingSpots: []));

  //loads tackle shop in 5 km radius
  Future<void> loadTackleShops(LatLng userLocation) async {
    final allShops = await _mapService.fetchNearbyTackleShops(
      userLocation.latitude,
      userLocation.longitude,
    );

    const maxDistanceInMeters = 5000;

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
                markerId: MarkerId('tackle_${s.id}'),
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
                markerId: MarkerId('spot_${s.id}'),
                position: LatLng(s.lat, s.lng),
              ),
            )
            .toSet();

    emit(
      state.copyWith(
        mode: MapMode.fishing,
        markers: markers,
        fishingSpots: spots,
      ),
    );
  }

  Future<void> addFishingSpot(FishingSpot spot) async {
    await _mapService.addFishingSpot(spot);
    await loadFishingSpots();
  }

  void enableAddFishingSpotMode() {
    emit(state.copyWith(mode: MapMode.fishing));
  }
}
