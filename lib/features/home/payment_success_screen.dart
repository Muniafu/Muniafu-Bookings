import 'package:flutter/material.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/data/models/booking.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Booking booking;

  const PaymentSuccessScreen({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '\$${booking.totalPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            ButtonWidget(
              text: 'Back to Home',
              onPressed: () => Navigator.popUntil(
                context, 
                (route) => route.isFirst
              ),
            ),
          ],
        ),
      ),
    );
  }
}