import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp/features/auth/presentation/components/my_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationSelector extends StatefulWidget {
  final Function(String name, double lat, double lng) onLocationPicked;

  const LocationSelector({super.key, required this.onLocationPicked});

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> suggestions = [];
  String? selectedLocation;
  bool isLoading = false;

  String get apiKey => dotenv.env['GOOGLE_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    print("🔍 User input: $input");

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$input&key=$apiKey&components=country:my', // Change country as needed
    );

    try {
      final response = await http.get(url);
      final json = jsonDecode(response.body);

      print("📡 Autocomplete API response: ${jsonEncode(json)}");

      if (json['status'] == 'OK') {
        final preds = json['predictions'] as List;
        setState(() {
          suggestions = preds.map((p) => p as Map<String, dynamic>).toList();
        });
      } else {
        print(
          "⚠ Autocomplete error: ${json['status']} - ${json['error_message']}",
        );
        setState(() => suggestions = []);
      }
    } catch (e) {
      print("❌ Autocomplete API call failed: $e");
      setState(() => suggestions = []);
    }
  }

  void _onSuggestionTap(Map<String, dynamic> place) async {
    final placeId = place['place_id'];
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey',
    );

    print("📍 Fetching details for place ID: $placeId");

    try {
      final response = await http.get(url);
      final json = jsonDecode(response.body);
      final result = json['result'];

      print("✅ Place Details response: ${jsonEncode(result)}");

      final lat = result['geometry']['location']['lat'];
      final lng = result['geometry']['location']['lng'];
      final address = result['formatted_address'];

      setState(() {
        selectedLocation = address;
        suggestions.clear();
        _controller.text = address;
      });

      widget.onLocationPicked(address, lat, lng);
    } catch (e) {
      print("❌ Error getting place details: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => isLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied");
        }
      }

      final pos = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      final place = placemarks.first;
      final name = '${place.locality}, ${place.country}';

      setState(() {
        selectedLocation = name;
        _controller.text = name;
      });

      widget.onLocationPicked(name, pos.latitude, pos.longitude);
    } catch (e) {
      print("❌ Location error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Search Input
            MyTextField(
              controller: _controller,
              hintText: 'Search for a location...',
              obscureText: false,
            ),

            const SizedBox(height: 10),

            // 📍 Use Current Location
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text("Use current location"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(fontSize: 14),
                ),
                onPressed: isLoading ? null : _useCurrentLocation,
              ),
            ),

            const SizedBox(height: 10),

            // 🧭 Suggestions List
            if (suggestions.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return ListTile(
                      title: Text(suggestion['description']),
                      onTap: () => _onSuggestionTap(suggestion),
                      leading: const Icon(Icons.location_on_outlined),
                      dense: true,
                    );
                  },
                ),
              ),

            const SizedBox(height: 10),

            // ✅ Selected Location Display
            if (selectedLocation != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Selected: $selectedLocation",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
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
}
