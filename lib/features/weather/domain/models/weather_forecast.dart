class WeatherForecast {
  final String date;
  final double temp;
  final double minTemp;
  final int humidity;
  final double windSpeed;
  final String mainCondition;

  WeatherForecast({
    required this.date,
    required this.temp,
    required this.minTemp,
    required this.humidity,
    required this.windSpeed,
    required this.mainCondition,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: json['dt_txt'],
      temp: json['main']['temp'].toDouble(),
      minTemp: json['main']['temp_min'].toDouble(), // ✅ new
      humidity: json['main']['humidity'], // ✅ new
      windSpeed: json['wind']['speed'].toDouble(), // ✅ new
      mainCondition: json['weather'][0]['main'],
    );
  }
}
