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

    // Count by species
    final Map<String, int> speciesCount = {};
    for (final entry in entries) {
      speciesCount[entry.species] = (speciesCount[entry.species] ?? 0) + 1;
    }

    final speciesList = speciesCount.entries.toList();
    final total = speciesCount.values.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text("Statistics")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🏆 Highlights
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Highlights",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.height),
                      Text(
                        "  Longest Fish: ${longest.species} ${longest.length} cm",
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.monitor_weight),
                      Text(
                        "  Heaviest Fish: ${heaviest.species} ${heaviest.weight} kg",
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.map),
                      Text("  Best Spot: Coming Soon"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🐠 Donut chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Primary Catches: $total",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 40,
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
                                titleStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children:
                        speciesList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final label = entry.value.key;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 5,
                                backgroundColor: _getColor(index),
                              ),
                              const SizedBox(width: 6),
                              Text(label),
                            ],
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
    ];
    return colors[index % colors.length];
  }
}
