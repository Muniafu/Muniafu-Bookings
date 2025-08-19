import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key, required bookingId, required String paymentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Confirmed")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Your booking is confirmed!", style: TextStyle(fontSize: 20)),
            TextButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false), child: const Text("Back to Home"))
          ],
        ),
      ),
    );
  }
}