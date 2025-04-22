import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<String>> loadFishSpecies() async {
  final String jsonString = await rootBundle.loadString(
    'assets/fish_data/fish_data.json',
  );
  final Map<String, dynamic> jsonData = json.decode(jsonString);

  final List<dynamic> fishList = jsonData['malaysian_sport_fish'];

  final List<String> speciesNames =
      fishList
          .map((item) => item['common_name'] as String)
          .where((name) => name.isNotEmpty)
          .toList();

  return speciesNames;
}
