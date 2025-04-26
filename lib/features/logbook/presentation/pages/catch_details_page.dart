import 'package:flutter/material.dart';
import 'package:fyp/features/logbook/domain/entities/logbook_entry.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CatchDetailsPage extends StatelessWidget {
  final LogbookEntry entry;

  const CatchDetailsPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd().format(entry.catchDate);
    final formattedTime = entry.catchTime.format(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Catch Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🐟 Image
            if (entry.imageUrl != null)
              Image.network(
                entry.imageUrl!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 60)),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🐠 Species
                  Text(
                    entry.species,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 12),

                  // 📊 Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoTile(Icons.straighten, '${entry.length} cm'),
                      _buildInfoTile(
                        Icons.monitor_weight,
                        '${entry.weight} kg',
                      ),
                      _buildInfoTile(Icons.access_time, formattedTime),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 📅 Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(formattedDate),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 📍 Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.location),
                            if (entry.latitude != null &&
                                entry.longitude != null)
                              Text(
                                '(${entry.latitude!.toStringAsFixed(5)}, ${entry.longitude!.toStringAsFixed(5)})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🔁 Released
                  if (entry.isReleased)
                    Row(
                      children: const [
                        Icon(Icons.loop, color: Colors.orange),
                        SizedBox(width: 8),
                        Text("Caught & Released"),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // 🗺️ Mini Map
                  if (entry.latitude != null && entry.longitude != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(entry.latitude!, entry.longitude!),
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('catch_location'),
                              position: LatLng(
                                entry.latitude!,
                                entry.longitude!,
                              ),
                            ),
                          },
                          myLocationEnabled: false,
                          zoomControlsEnabled: false,
                          liteModeEnabled: true, // ✅ Enable lightweight map
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Column(
      children: [Icon(icon, size: 28), const SizedBox(height: 4), Text(text)],
    );
  }
}
