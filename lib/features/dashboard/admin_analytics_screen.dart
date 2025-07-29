import 'package:flutter/material.dart';
import './widgets/total_bookings_widget.dart';
import 'widgets/monthly_trend_chart.dart';
import 'widgets/top_categories_chart.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Analytics")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: const [
              TotalBookingsWidget(),
              SizedBox(height: 20),
              MonthlyTrendChart(),
              SizedBox(height: 20),
              TopCategoriesChart(),
            ],
          ),
        ),
      ),
    );
  }
}
