import 'package:flutter/material.dart';
import '../../../data/models/booking.dart';

class BookingDetailsBottomSheet extends StatelessWidget {
  final Booking booking;

  const BookingDetailsBottomSheet({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Booking for ${booking.hotelName}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text('Status: ${booking.status.name}'),
          Text('Check-in: ${booking.checkInDate}'),
          Text('Check-out: ${booking.checkOutDate}'),
        ],
      ),
    );
  }
}