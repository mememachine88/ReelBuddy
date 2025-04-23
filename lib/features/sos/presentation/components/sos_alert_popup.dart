// lib/features/sos/presentation/components/sos_alert_popup.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:fyp/features/sos/domain/entities/sos.dart';

class SOSAlertPopup extends StatelessWidget {
  final SOSAlert alert;

  const SOSAlertPopup({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("🚨 SOS Alert Received"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    alert.senderProfileImageUrl.isNotEmpty
                        ? NetworkImage(alert.senderProfileImageUrl)
                        : null,
                child:
                    alert.senderProfileImageUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.senderName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('@${alert.senderUsername}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Location of alert:"),
          const SizedBox(height: 10),
          Text("Coordinates: ${alert.latitude} , ${alert.longitude}"),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(alert.latitude, alert.longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("sos_pin"),
                    position: LatLng(alert.latitude, alert.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Dismiss",
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
      ],
    );
  }
}
