import 'package:flutter/material.dart';
import 'package:fyp/features/weather/presentation/components/weather_search.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerModal {
  static Future<Map<String, dynamic>?> show(BuildContext context) async {
    LatLng selectedLatLng = const LatLng(3.075114, 101.68336);
    String selectedName = "Selected Location";
    GoogleMapController? mapController;

    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,

      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool useSearchName = false;

            Future<String> getLocationNameFromCoords(LatLng latLng) async {
              try {
                final placemarks = await placemarkFromCoordinates(
                  latLng.latitude,
                  latLng.longitude,
                );

                if (placemarks.isNotEmpty) {
                  final p = placemarks.first;
                  final nameParts = [
                    if (p.locality != null && p.locality!.isNotEmpty)
                      p.locality,
                    if (p.administrativeArea != null &&
                        p.administrativeArea!.isNotEmpty)
                      p.administrativeArea,
                    if (p.country != null && p.country!.isNotEmpty) p.country,
                  ];

                  return nameParts.join(', ');
                }
              } catch (e) {
                print("Reverse geocoding failed: $e");
              }

              return 'Unknown Location';
            }

            // Location helper
            Future<void> getCurrentLocation() async {
              final permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                await Geolocator.requestPermission();
              }

              final position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );

              final currentLatLng = LatLng(
                position.latitude,
                position.longitude,
              );

              final name = await getLocationNameFromCoords(currentLatLng);

              setState(() {
                selectedLatLng = currentLatLng;
                selectedName = name;
              });

              mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: currentLatLng, zoom: 16),
                ),
              );
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Post Position",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final name = await getLocationNameFromCoords(
                              selectedLatLng,
                            );
                            Navigator.pop(context, {
                              "name": selectedName,
                              "lat": selectedLatLng.latitude,
                              "lng": selectedLatLng.longitude,
                              "useSearchName": useSearchName,
                            });
                          },
                          child: Text(
                            "Done",
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar (uses your component)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: LocationSearchBar(
                        onLocationPicked: (name, lat, lng) {
                          final newLatLng = LatLng(lat, lng);
                          setState(() {
                            selectedLatLng = newLatLng;
                            selectedName = name;
                            useSearchName = true;
                          });

                          mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(target: newLatLng, zoom: 16),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Use My Location Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: SizedBox(
                      width: 140,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // 👈 rounder corners
                          ),
                          textStyle: const TextStyle(fontSize: 13),
                          tapTargetSize:
                              MaterialTapTargetSize
                                  .shrinkWrap, // 👈 no extra vertical padding
                          minimumSize: Size.zero, // 👈 removes default min size
                        ),
                        onPressed: getCurrentLocation,
                        icon: const Icon(Icons.my_location, size: 18),
                        label: const Text("My Location"),
                      ),
                    ),
                  ),

                  // Map view
                  Expanded(
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: selectedLatLng,
                            zoom: 16,
                          ),
                          onMapCreated: (controller) {
                            mapController = controller;
                          },
                          onCameraMove: (position) {
                            selectedLatLng = position.target;
                          },

                          onCameraIdle: () async {
                            if (useSearchName) {
                              useSearchName = false;
                              return;
                            }

                            final name = await getLocationNameFromCoords(
                              selectedLatLng,
                            );
                            setState(() {
                              selectedName = name;
                            });
                          },

                          myLocationEnabled: true,
                          zoomControlsEnabled: false,
                        ),
                        Center(
                          child: Icon(
                            Icons.location_on,
                            size: 40,
                            color: Color(0xFF00FFFF),
                          ),
                        ),
                        // Coordinates + name overlay
                        Positioned(
                          top: 10,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${selectedLatLng.latitude.toStringAsFixed(5)}, ${selectedLatLng.longitude.toStringAsFixed(5)}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  selectedName,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
