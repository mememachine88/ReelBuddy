import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fyp/features/logbook/domain/entities/logbook_entry.dart';

class StatsPage extends StatelessWidget {
  final List<LogbookEntry> entries;

  const StatsPage({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Statistics")),
        body: const Center(child: Text("No data to show")),
      );
    }

    final longest = entries.reduce((a, b) => a.length > b.length ? a : b);
    final heaviest = entries.reduce((a, b) => a.weight > b.weight ? a : b);

    final Map<String, int> speciesCount = {};
    for (final entry in entries) {
      speciesCount[entry.species] = (speciesCount[entry.species] ?? 0) + 1;
    }

    final speciesList = speciesCount.entries.toList();
    final total = speciesCount.values.reduce((a, b) => a + b);
    final mostCaught = speciesList.reduce((a, b) => a.value > b.value ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fishing Statistics", style: TextStyle(fontSize: 22)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🏆 Highlights Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Highlights",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.height, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        "Longest: ${longest.species} — ${longest.length.toStringAsFixed(1)} cm",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.monitor_weight, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        "Heaviest: ${heaviest.species} — ${heaviest.weight.toStringAsFixed(1)} kg",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 26, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        "Most Caught: ${mostCaught.key} (${mostCaught.value}x)",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🐠 Donut Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    "Total Catches: $total",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 50,
                        sections:
                            speciesList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final label = entry.value.key;
                              final count = entry.value.value;
                              final color = _getColor(index);

                              return PieChartSectionData(
                                value: count.toDouble(),
                                title: count.toString(),
                                color: color,
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children:
                        speciesList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final label = entry.value.key;
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: _getColor(index),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    label,
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(int index) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.brown,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}
