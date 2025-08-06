import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking.dart';
import '../../data/services/booking_service.dart';
//import './widgets/total_bookings_widget.dart';
import './widgets/monthly_trend_chart.dart';
import './widgets/top_categories_chart.dart';
//import './widgets/revenue_summary_card.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  List<Booking> _bookings = [];
  bool _loading = true;
  DateTimeRange? _selectedDateRange;

  // Computed properties
  int get totalBookings => _bookings.length;
  double get totalRevenue => _bookings.fold(0, (sum, b) => sum + b.totalAmount);
  List<Booking> get upcomingCheckIns => _getUpcomingCheckIns();
  Map<String, double> get revenueByCategory => _calculateRevenueByCategory();
  Map<String, int> get bookingsByMonth => _calculateBookingsByMonth();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final bookings = await BookingService().getAllBookings();
      setState(() {
        _bookings = bookings;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e')),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _loadAnalytics();
    }
  }

  List<Booking> _getUpcomingCheckIns() {
    if (_bookings.isEmpty) return [];
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _bookings
        .where((b) => b.checkInDate.isAfter(now) && b.checkInDate.isBefore(nextWeek))
        .toList();
  }

  Map<String, double> _calculateRevenueByCategory() {
    final Map<String, double> result = {};
    for (final booking in _bookings) {
      final category = booking.hotelName; // Assuming hotelName represents category
      result[category] = (result[category] ?? 0) + booking.totalAmount;
    }
    return result;
  }

  Map<String, int> _calculateBookingsByMonth() {
    final Map<String, int> result = {};
    final format = DateFormat('MMM yyyy');
    for (final booking in _bookings) {
      final month = format.format(booking.checkInDate);
      result[month] = (result[month] ?? 0) + 1;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: RevenueSummaryCard(
                          title: 'Total Bookings',
                          value: totalBookings.toString(),
                          icon: Icons.receipt,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RevenueSummaryCard(
                          title: 'Total Revenue',
                          value: '\$${totalRevenue.toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: RevenueSummaryCard(
                          title: 'Upcoming Check-ins',
                          value: upcomingCheckIns.length.toString(),
                          icon: Icons.calendar_today),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RevenueSummaryCard(
                          title: 'Avg. Revenue',
                          value: '\$${(totalRevenue / (totalBookings == 0 ? 1 : totalBookings)).toStringAsFixed(2)}',
                          icon: Icons.trending_up),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Charts Section
                  const Text('Monthly Bookings Trend',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const SizedBox(
                    height: 200,
                    child: MonthlyTrendChart(),
                  ),
                  const SizedBox(height: 24),

                  const Text('Revenue by Category',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const SizedBox(
                    height: 200,
                    child: TopCategoriesChart(),
                  ),
                  const SizedBox(height: 24),

                  // Upcoming Check-ins List
                  const Text('Upcoming Check-ins (Next 7 Days)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (upcomingCheckIns.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No upcoming check-ins'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: upcomingCheckIns.length,
                      itemBuilder: (context, index) {
                        final booking = upcomingCheckIns[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.hotel),
                            title: Text(booking.hotelName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('User: ${booking.userId.substring(0, 8)}...'),
                                Text('Check-in: ${DateFormat.yMMMd().format(booking.checkInDate)}'),
                              ],
                            ),
                            trailing: Text('\$${booking.totalAmount.toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class RevenueSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const RevenueSummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Icon(icon, size: 20, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}