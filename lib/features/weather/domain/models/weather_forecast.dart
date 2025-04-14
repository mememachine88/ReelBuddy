class WeatherForecast {
  final String date;
  final double temp;
  final String mainCondition;

  WeatherForecast({
    required this.date,
    required this.temp,
    required this.mainCondition,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: json['dt_txt'],
      temp: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
    );
  }
}
