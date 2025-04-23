import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fyp/features/weather/domain/models/weather_forecast.dart';
import 'package:fyp/features/weather/domain/models/weather_model.dart';
import 'package:fyp/features/weather/domain/services/weather_service.dart';
import 'package:fyp/features/weather/presentation/components/metric_tile.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import '../../presentation/components/weather_search.dart';
import '../../presentation/components/weather_forecast_tile.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

// Weather animation selector
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
      return 'assets/weather_icons/sunny.json';
  }
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService(dotenv.env['WEATHER_API_KEY'] ?? '');
  Weather? _weather;
  String? _selectedLocation;
  List<WeatherForecast>? _forecast;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
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
      print(" Error fetching weather: $e");
    }
  }

  Future<void> _fetchWeatherForCoordinates(
    double lat,
    double lng,
    String placeName,
  ) async {
    try {
      final weather = await _weatherService.fetchWeatherByCoordinates(lat, lng);
      final forecast = await _weatherService.fetch5DayForecast(lat, lng);
      setState(() {
        _weather = weather;
        _forecast = forecast;
        _selectedLocation = placeName;
      });
    } catch (e) {
      print(" Error fetching weather/forecast: $e");
    }
  }

  void _showForecastDetails(BuildContext context, WeatherForecast forecast) {
    // Dismiss keyboard before opening modal
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEEE, MMM d').format(DateTime.parse(forecast.date)),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Lottie.asset(
                getWeatherAnimation(forecast.mainCondition),
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              Text(
                "${forecast.temp.toStringAsFixed(1)} °C",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MetricTile(label: "Humidity", value: "${forecast.humidity}%"),
                  MetricTile(
                    label: "Wind",
                    value: "${forecast.windSpeed} km/h",
                  ),
                  MetricTile(
                    label: "Min Temp",
                    value: "${forecast.minTemp.toStringAsFixed(1)}°C",
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                LocationSearchBar(
                  onLocationPicked: (name, lat, lng) {
                    _fetchWeatherForCoordinates(lat, lng, name);
                  },
                ),

                const SizedBox(height: 20),

                if (_weather != null) ...[
                  Center(
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
                          DateFormat('EEEE, MMM d').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_weather!.mainCondition ?? 'Unknown'),
                        const SizedBox(height: 20),
                        Lottie.asset(
                          getWeatherAnimation(_weather!.mainCondition),
                          height: 130,
                          width: 130,
                        ),
                        Text(
                          '${_weather!.temperature.toStringAsFixed(1)} °C',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MetricTile(
                              label: "Humidity",
                              value: "${_weather!.humidity}%",
                            ),
                            MetricTile(
                              label: "Wind",
                              value: "${_weather!.windSpeed} m/s",
                            ),
                            MetricTile(
                              label: "Feels Like",
                              value:
                                  "${_weather!.feelsLike.toStringAsFixed(1)} °C",
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_forecast != null && _forecast!.isNotEmpty) ...[
                    const Text(
                      "5-Day Forecast",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            _forecast!
                                .map(
                                  (f) => Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: ForecastTile(
                                      day: f.date,
                                      temp: "${f.temp.toStringAsFixed(0)}°C",
                                      mainCondition: f.mainCondition,
                                      onTap:
                                          () =>
                                              _showForecastDetails(context, f),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ] else
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        190, // approximate full height minus top padding
                    child: Center(
                      child: LoadingAnimationWidget.dotsTriangle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        size: 70,
                      ),
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
