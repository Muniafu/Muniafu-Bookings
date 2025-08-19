import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<void> _loadBookingsFuture;
  late String _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userId = Provider.of<AuthProvider>(context, listen: false).user!.uid;
      _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    setState(() {
      _loadBookingsFuture =
          Provider.of<BookingProvider>(context, listen: false).loadBookings(_userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: bookingProvider.isLoading && bookingProvider.bookings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: FutureBuilder(
                future: _loadBookingsFuture,
                builder: (context, snapshot) {
                  if (bookingProvider.isLoading &&
                      bookingProvider.bookings.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final bookings = bookingProvider.bookings;

                  if (bookings.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("No bookings found.")),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingDetailsScreen(booking: b),
                              ),
                            );
                          },
                          title: Text("Booking ${b.id.substring(0, 6)}"),
                          subtitle: Text(
                            "Check-in: ${b.checkIn.toString().split(" ").first} • Check-out: ${b.checkOut.toString().split(" ").first}",
                          ),
                          trailing: Chip(
                            label: Text(b.status),
                            backgroundColor: _statusColor(b.status),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      case 'checked-in':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade300;
    }
  }
}