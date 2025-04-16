import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

import 'package:fyp/features/maps/presentation/cubit/map_cubit.dart';
import 'package:lottie/lottie.dart';

class MapState {
  final MapMode mode;
  final Set<gmap.Marker> markers; // 👈 add prefix

  MapState({required this.mode, required this.markers});

  MapState copyWith({MapMode? mode, Set<gmap.Marker>? markers}) {
    return MapState(mode: mode ?? this.mode, markers: markers ?? this.markers);
  }
}
