import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LocationSearchBar extends StatefulWidget {
  final Function(String name, double lat, double lng) onLocationPicked;

  const LocationSearchBar({super.key, required this.onLocationPicked});

  @override
  State<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> _suggestions = [];
  Future<List<Map<String, dynamic>>> fetchPlaceSuggestions(String input) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$input&key=$apiKey&components=country:my',
    );

    try {
      final response = await http.get(url);
      final json = jsonDecode(response.body);

      if (json['status'] == 'OK') {
        final predictions = json['predictions'] as List;
        return predictions.map((p) => p as Map<String, dynamic>).toList();
      } else {
        print(
          "⚠ Autocomplete failed: ${json['status']} - ${json['error_message']}",
        );
        return [];
      }
    } catch (e) {
      print("❌ Autocomplete API error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchPlaceDetails(String placeId) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId&key=$apiKey&fields=formatted_address,geometry',
    );

    try {
      final response = await http.get(url);
      final json = jsonDecode(response.body);

      if (json['status'] == 'OK') {
        final result = json['result'];
        return {
          'address': result['formatted_address'],
          'lat': result['geometry']['location']['lat'],
          'lng': result['geometry']['location']['lng'],
        };
      } else {
        print("⚠ Place details failed: ${json['status']}");
        return null;
      }
    } catch (e) {
      print("❌ Place details API error: $e");
      return null;
    }
  }

  void _onSearchChanged(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final results = await fetchPlaceSuggestions(input);
    setState(() => _suggestions = results);
  }

  void _onSuggestionSelected(Map<String, dynamic> suggestion) async {
    final details = await fetchPlaceDetails(suggestion['place_id']);
    if (details != null) {
      widget.onLocationPicked(
        details['address'],
        details['lat'],
        details['lng'],
      );

      setState(() {
        _controller.text = details['address'];
        _suggestions.clear(); // 👈 Clear dropdown list
        FocusScope.of(context).unfocus(); // 👈 Dismiss keyboard
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Search for a location...",
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _onSearchChanged,
        ),
        if (_suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              itemCount: _suggestions.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(suggestion['description']),
                  onTap: () => _onSuggestionSelected(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}
