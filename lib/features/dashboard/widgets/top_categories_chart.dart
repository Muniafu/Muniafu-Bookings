import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class TopCategoriesChart extends StatefulWidget {
  const TopCategoriesChart({super.key});

  @override
  State<TopCategoriesChart> createState() => _TopCategoriesChartState();
}

class _TopCategoriesChartState extends State<TopCategoriesChart> {
  final Map<String, int> _categoryCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTopCategories();
  }

  Future<void> _fetchTopCategories() async {
    final bookingsSnapshot = await FirebaseFirestore.instance.collection('bookings').get();
    final roomIds = bookingsSnapshot.docs.map((doc) => doc['roomId'] as String).toList();

    // Room ID → Category mapping
    final roomCategoryMap = <String, String>{};

    final roomSnapshot = await FirebaseFirestore.instance.collection('rooms').get();
    for (final doc in roomSnapshot.docs) {
      roomCategoryMap[doc.id] = doc['category'] ?? 'Unknown';
    }

    for (final roomId in roomIds) {
      final category = roomCategoryMap[roomId] ?? 'Unknown';
      _categoryCounts[category] = (_categoryCounts[category] ?? 0) + 1;
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final keys = _categoryCounts.keys.toList();
    final values = _categoryCounts.values.toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Top Booked Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(keys.length, (i) {
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: values[i].toDouble(), color: Colors.deepPurpleAccent)
                    ]);
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return Text(keys[index], style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
