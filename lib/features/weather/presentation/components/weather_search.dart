import 'dart:async';
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
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _overlayEntry?.remove();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (input.isEmpty) {
        _removeOverlay();
        return;
      }

      final results = await fetchPlaceSuggestions(input);
      _suggestions = results;
      _showOverlay();
    });
  }

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
        return [];
      }
    } catch (e) {
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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _onSuggestionSelected(Map<String, dynamic> suggestion) async {
    final details = await fetchPlaceDetails(suggestion['place_id']);
    if (details != null) {
      widget.onLocationPicked(
        details['address'],
        details['lat'],
        details['lng'],
      );

      _controller.text = details['address'];
      _removeOverlay();
      FocusScope.of(context).unfocus();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              // Transparent layer to detect taps outside
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeOverlay();
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),

              // Positioned suggestion list
              Positioned(
                width: size.width - 32,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(16, 55),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
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
                  ),
                ),
              ),
            ],
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Search for a location...",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
