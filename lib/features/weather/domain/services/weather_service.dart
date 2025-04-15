import 'dart:convert';

import 'package:fyp/features/weather/domain/models/weather_forecast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/weather_model.dart'; // Update the path based on your structure

class WeatherService {
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);
  Future<Weather> fetchWeather(String city) async {
    final url = Uri.parse("$_baseUrl?q=$city&appid=$apiKey&units=metric");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception("City not found.");
    } else {
      throw Exception("Failed to load weather data: ${response.reasonPhrase}");
    }
  }

  Future<Weather> fetchWeatherByCoordinates(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to fetch weather data by coordinates');
    }
  }

  Future<String> getCurrentCity() async {
    //get permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception("Location permissions are denied");
    }

    //get current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    //convert location to lat long
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    //convert to city name
    String city = placemarks[0].locality ?? placemarks[0].administrativeArea!;
    return city;
  }

  Future<List<WeatherForecast>> fetch5DayForecast(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawList = data['list'] as List;
      return filterDailyForecast(rawList); // 👈 make sure this exists too
    } else {
      throw Exception('Failed to fetch forecast');
    }
  }

  List<WeatherForecast> filterDailyForecast(List<dynamic> rawList) {
    final List list = rawList;

    Map<String, WeatherForecast> dailyMap = {};

    for (var item in list) {
      final dtTxt = item['dt_txt'];
      final date = DateTime.parse(dtTxt);
      final dateString = DateFormat(
        'yyyy-MM-dd',
      ).format(date); // ✅ this is a string

      if (!dailyMap.containsKey(dateString)) {
        final forecast = WeatherForecast(
          date: DateFormat('yyyy-MM-dd').format(date),
          temp: item['main']['temp'].toDouble(),
          mainCondition: item['weather'][0]['main'],
          minTemp: item['main']['temp_min'].toDouble(), // ✅ new
          humidity: item['main']['humidity'], // ✅ new
          windSpeed: item['wind']['speed'].toDouble(), // ✅ new
        );
        dailyMap[dateString] = forecast;
      }
    }

    return dailyMap.values.take(5).toList();
  }
}
