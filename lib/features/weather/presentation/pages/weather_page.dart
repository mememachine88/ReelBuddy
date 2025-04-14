import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fyp/features/weather/domain/models/weather_forecast.dart';
import 'package:fyp/features/weather/domain/models/weather_model.dart';
import 'package:fyp/features/weather/domain/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import '../../presentation/components/weather_search.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //api key
  final _weatherService = WeatherService(dotenv.env['WEATHER_API_KEY'] ?? '');
  Weather? _weather;
  String? _selectedLocation;
  List<WeatherForecast>? _forecast;
  List<WeatherForecast> _forecastList = [];

  //fetch weather
  _fetchWeather() async {
    String city = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.fetchWeather(city);
      final forecast = await _weatherService.fetch5DayForecast(
        weather.lat,
        weather.lon,
      );
      setState(() {
        _weather = weather;
        _selectedLocation = weather.cityName;
        _forecast = forecast;
      });
    } catch (e) {
      print("❌ Error fetching default weather: $e");
    }
  }

  _fetchWeatherForCoordinates(double lat, double lng, String placeName) async {
    try {
      final weather = await _weatherService.fetchWeatherByCoordinates(lat, lng);
      final forecast = await _weatherService.fetch5DayForecast(
        lat,
        lng,
      ); // ← here

      setState(() {
        _weather = weather;
        _forecastList = forecast.cast<WeatherForecast>();
        _selectedLocation = placeName;
      });
    } catch (e) {
      print("❌ Error fetching weather/forecast: $e");
    }
  }

  //get weather animation
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/weather_icons/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
        return 'assets/weather_icons/overcast.json';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/weather_icons/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/weather_icons/light_rain.json';
      case 'thunderstorm':
        return 'assets/weather_icons/thunderstorm.json';
      case 'clear':
        return 'assets/weather_icons/sunny.json';
      default:
        return 'assets/weather_icons/sunny.json'; // Default animation
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: SafeArea(
    //     child: Column(
    //       children: [
    //         // 🔍 Search Bar
    //         Padding(
    //           padding: const EdgeInsets.all(16.0),
    //           child: LocationSearchBar(
    //             onLocationPicked: (name, lat, lng) {
    //               _fetchWeatherForCoordinates(lat, lng, name);
    //             },
    //           ),
    //         ),

    //         const SizedBox(height: 20),

    //         // 🌦 Weather Info
    //         if (_weather != null)
    //           Expanded(
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Text(
    //                   _selectedLocation ?? 'Unknown',
    //                   style: const TextStyle(
    //                     fontSize: 22,
    //                     fontWeight: FontWeight.w600,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 10),
    //                 Lottie.asset(
    //                   getWeatherAnimation(_weather!.mainCondition),
    //                   height: 100,
    //                   width: 100,
    //                 ),
    //                 Text(
    //                   '${_weather!.temperature.toStringAsFixed(1)} °C',
    //                   style: const TextStyle(
    //                     fontSize: 38,
    //                     fontWeight: FontWeight.bold,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           )
    //         else
    //           const Expanded(child: Center(child: CircularProgressIndicator())),
    //       ],
    //     ),
    //   ),
    // );
    return Scaffold(
      // soft light blue background
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LocationSearchBar(
                onLocationPicked: (name, lat, lng) {
                  _fetchWeatherForCoordinates(lat, lng, name);
                },
              ),
            ),

            // 🌤️ Weather Info Display
            if (_weather != null)
              Expanded(
                child: Column(
                  children: [
                    // 🔵 Top Rounded Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _selectedLocation ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _weather!.mainCondition ?? 'Unknown',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    // 🔄 Lottie Animation
                    Lottie.asset(
                      getWeatherAnimation(_weather!.mainCondition),
                      height: 130,
                      width: 130,
                      fit: BoxFit.contain,
                    ),

                    // 🌡️ Temperature
                    Text(
                      '${_weather!.temperature.toStringAsFixed(1)} °C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔢 Metrics Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetric("Humidity", "${_weather!.humidity}%"),
                          _buildMetric("Wind", "${_weather!.windSpeed} km/h"),
                          _buildMetric(
                            "Feels",
                            "${_weather!.feelsLike.toStringAsFixed(1)} °C",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 📅 Forecast (stub - replace with real forecast data later)
                    if (_forecast != null && _forecast!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "5-Day Forecast",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children:
                                  _forecast!.map((f) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _ForecastTile(
                                        day:
                                            f.date, // should be formatted like "Mon", "Tue"
                                        temp: "${f.temp.toStringAsFixed(0)}°C",
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              )
            else
              const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}

Widget _buildMetric(String label, String value) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}

class _ForecastTile extends StatelessWidget {
  final String day;
  final String temp;

  const _ForecastTile({required this.day, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Icon(Icons.wb_sunny, size: 30), // You can replace with dynamic icons
        const SizedBox(height: 6),
        Text(temp, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
