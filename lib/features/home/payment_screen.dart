import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muniafu/providers/payment_provider.dart';
import 'package:muniafu/providers/booking_provider.dart';
import 'package:muniafu/features/home/payment_success_screen.dart';
class PaymentProcessingScreen extends StatefulWidget {
  final String roomId;
  final int amount;
  final String currency;

  const PaymentProcessingScreen({
    super.key, 
    required this.roomId,
    required this.amount,
    this.currency = 'usd',
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _simulatePayment();
    _startRealStripeFlow();
  }

  Future<void> _startRealStripeFlow() async {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    try {
      await paymentProvider.processPayment(
        amount: widget.amount,
        currency: widget.currency,
        context: context,
      );

      final bookingId = await bookingProvider.createMockBooking(widget.roomId);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(bookingId: bookingId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(context, e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _simulatePayment() async {
    await Future.delayed(const Duration(seconds: 2));

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final bookingId = await bookingProvider.createMockBooking(widget.roomId);

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
    final isProcessing = context.watch<PaymentProvider>().isProcessing;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: isProcessing ? const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Transaction in Progress...', style: TextStyle(fontSize: 18)),
          ],
        ): const Text('Preparing Payment....'),
      ),
    );
  }
}