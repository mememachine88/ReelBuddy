import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/fishing_spots.dart';
import '../../presentation/cubit/map_cubit.dart';

class MapState {
  final MapMode mode;
  final Set<Marker> markers;
  final List<FishingSpot> fishingSpots;

  MapState({
    required this.mode,
    required this.markers,
    required this.fishingSpots,
  });

  MapState copyWith({
    MapMode? mode,
    Set<Marker>? markers,
    List<FishingSpot>? fishingSpots,
  }) {
    return MapState(
      mode: mode ?? this.mode,
      markers: markers ?? this.markers,
      fishingSpots: fishingSpots ?? this.fishingSpots,
    );
  }
}
