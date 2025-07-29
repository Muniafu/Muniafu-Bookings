import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muniafu/providers/payment_provider.dart';
import 'package:muniafu/providers/booking_provider.dart';
import 'package:muniafu/data/models/booking.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/features/home/payment_success_screen.dart';
class PaymentProcessingScreen extends StatefulWidget {
  final String roomId;
  const PaymentProcessingScreen({super.key, required this.roomId});

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _simulatePayment();
  }

  Future<void> _simulatePayment() async {
    await Future.delayed(const Duration(seconds: 2));

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final bookingId = await bookingProvider.mockCreateBooking(widget.roomId);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(bookingId: bookingId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Transaction in Progress...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
