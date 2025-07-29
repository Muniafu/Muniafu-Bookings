import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MonthlyTrendChart extends StatefulWidget {
  const MonthlyTrendChart({super.key});

  @override
  State<MonthlyTrendChart> createState() => _MonthlyTrendChartState();
}

class _MonthlyTrendChartState extends State<MonthlyTrendChart> {
  final Map<String, int> _monthlyCounts = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookingTrends();
  }

  Future<void> _loadBookingTrends() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 5);

    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    final formatter = DateFormat('MMM');

    for (var i = 5; i >= 0; i--) {
      final month = formatter.format(DateTime(now.year, now.month - i));
      _monthlyCounts[month] = 0;
    }

    for (final doc in snapshot.docs) {
      final ts = doc['createdAt'] as Timestamp?;
      if (ts != null) {
        final date = ts.toDate();
        final label = formatter.format(date);
        if (_monthlyCounts.containsKey(label)) {
          _monthlyCounts[label] = _monthlyCounts[label]! + 1;
        }
      }
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

    final keys = _monthlyCounts.keys.toList();
    final values = _monthlyCounts.values.toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Monthly Booking Trend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(keys.length, (i) {
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: values[i].toDouble(), color: Colors.blue)
                    ]);
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return Text(keys[index], style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
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