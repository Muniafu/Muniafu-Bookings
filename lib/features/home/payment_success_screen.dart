import 'package:flutter/material.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/data/models/booking.dart';
class PaymentSuccessScreen extends StatelessWidget {
  final String bookingId;
  const PaymentSuccessScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Success")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Booking Confirmed!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("Your booking ID is:\n$bookingId",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("Go to Home"),
            )
          ],
        ),
      ),
    );
  }
}
