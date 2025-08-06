import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final Map<String, String> _statusCache = {};

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.uid;
    if (userId != null) {
      Provider.of<BookingProvider>(context, listen: false)
        ..fetchBookings(userId: userId)
        ..listenToUserBookings(userId);
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await Provider.of<BookingProvider>(context, listen: false)
          .cancelBooking(bookingId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final userId = authProvider.currentUser?.uid;
              if (userId != null) {
                bookingProvider.fetchBookings(userId: userId);
              }
            },
          ),
        ],
      ),
      body: _buildContent(bookingProvider),
    );
  }

  Widget _buildContent(BookingProvider provider) {
    if (provider.isLoading && provider.bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }

    if (provider.bookings.isEmpty) {
      return const Center(child: Text('No bookings found'));
    }

    return ListView.builder(
      itemCount: provider.bookings.length,
      itemBuilder: (context, index) {
        final booking = provider.bookings[index];
        final currentStatus = booking.status.name;
        final previousStatus = _statusCache[booking.id];

        // Show notification when status changes
        if (previousStatus != null && previousStatus != currentStatus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Booking ${booking.roomId} status changed '
                  'from "$previousStatus" to "$currentStatus"',
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          });
        }

        // Update cache with current status
        _statusCache[booking.id] = currentStatus;

        return BookingCard(
          booking: booking,
          onCancel: () => _cancelBooking(booking.id),
        );
      },
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onCancel;

  const BookingCard({
    Key? key,
    required this.booking,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = booking.status == BookingStatus.confirmed && 
        booking.checkOutDate.isAfter(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room: ${booking.roomId}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Hotel: ${booking.hotelName}'),
            const SizedBox(height: 8),
            Text('Check-in: ${DateFormat.yMMMd().format(booking.checkInDate)}'),
            Text('Check-out: ${DateFormat.yMMMd().format(booking.checkOutDate)}'),
            Text('Guests: ${booking.numberOfGuests}'),
            Text('Total: \$${booking.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    booking.status.name.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(theme, booking.status),
                    ),
                  ),
                  backgroundColor: _getStatusBackgroundColor(theme, booking.status),
                ),
                if (isActive && onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            if (booking.createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Booked on ${DateFormat.yMMMd().add_Hms().format(booking.createdAt!)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return theme.colorScheme.onPrimary;
      case BookingStatus.cancelled:
        return theme.colorScheme.onError;
      case BookingStatus.pending:
        return theme.colorScheme.onSecondary;
      case BookingStatus.completed:
        return theme.colorScheme.onPrimary;
    }
  }

  Color _getStatusBackgroundColor(ThemeData theme, BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return theme.colorScheme.primary;
      case BookingStatus.cancelled:
        return theme.colorScheme.error;
      case BookingStatus.pending:
        return theme.colorScheme.secondary;
      case BookingStatus.completed:
        return theme.colorScheme.primary.withOpacity(0.7);
    }
  }
}