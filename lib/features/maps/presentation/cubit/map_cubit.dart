import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/maps/data/models/fishing_spots.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/tackle_shop.dart';
import '../../domain/services/map_service.dart';

enum MapMode { tackle, fishing }

class MapState {
  final MapMode mode;
  final Set<Marker> markers;

  MapState({required this.mode, required this.markers});

  MapState copyWith({MapMode? mode, Set<Marker>? markers}) {
    return MapState(mode: mode ?? this.mode, markers: markers ?? this.markers);
  }
}

class MapCubit extends Cubit<MapState> {
  final MapService _mapService;

  MapCubit(this._mapService)
    : super(MapState(mode: MapMode.tackle, markers: {}));

  Future<void> loadTackleShops(LatLng userLocation) async {
    final shops = await _mapService.fetchNearbyTackleShops(
      userLocation.latitude,
      userLocation.longitude,
    );
    final markers =
        shops
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
                infoWindow: InfoWindow(title: s.title, snippet: s.description),
              ),
            )
            .toSet();
    emit(state.copyWith(mode: MapMode.fishing, markers: markers));
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
