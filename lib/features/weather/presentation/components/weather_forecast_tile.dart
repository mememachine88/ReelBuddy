import 'package:flutter/material.dart';
import 'package:fyp/features/weather/presentation/pages/weather_page.dart';
import 'package:lottie/lottie.dart';

class ForecastTile extends StatelessWidget {
  final String day;
  final String temp;
  final String? mainCondition;
  final VoidCallback onTap;

  const ForecastTile({
    super.key,
    required this.day,
    required this.temp,
    this.mainCondition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Lottie.asset(
            getWeatherAnimation(mainCondition),
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 6),
          Text(temp, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
