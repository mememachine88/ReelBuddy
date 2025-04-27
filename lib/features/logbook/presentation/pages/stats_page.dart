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
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Catch Statistics',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          automaticallyImplyLeading: true,
        ),
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
        centerTitle: true,
        title: Text(
          'Fishing Stats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 Highlights
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
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
                  _buildHighlightRow(
                    Icons.height,
                    "Longest",
                    "${longest.species} — ${longest.length.toStringAsFixed(1)} cm",
                  ),
                  const SizedBox(height: 8),
                  _buildHighlightRow(
                    Icons.monitor_weight,
                    "Heaviest",
                    "${heaviest.species} — ${heaviest.weight.toStringAsFixed(1)} kg",
                  ),
                  const SizedBox(height: 8),
                  _buildHighlightRow(
                    Icons.star,
                    "Most Caught",
                    "${mostCaught.key} (${mostCaught.value}x)",
                    iconColor: Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🎯 Pie Chart Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
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
                                    style: const TextStyle(fontSize: 14),
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

  Widget _buildHighlightRow(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 26, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text("$label: $value", style: const TextStyle(fontSize: 15)),
        ),
      ],
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
