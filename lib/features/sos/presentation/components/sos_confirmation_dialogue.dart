import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SOSConfirmationDialog extends StatelessWidget {
  final LatLng location;
  final VoidCallback onConfirm;

  const SOSConfirmationDialog({
    super.key,
    required this.location,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Send SOS Alert"),
      content: SizedBox(
        height: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to send an SOS?"),
            const SizedBox(height: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: location,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("sos_marker"),
                      position: location,
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true); // ✅ this must return `true`
          },
          child: const Text("Send SOS"),
        ),
      ],
    );
  }
}
