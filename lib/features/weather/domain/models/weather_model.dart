class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String mainCondition;
  final double lat;
  final double lon;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.mainCondition,
    required this.lat,
    required this.lon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      lat: json['coord']['lat'].toDouble(),
      lon: json['coord']['lon'].toDouble(),
    );
  }
}
