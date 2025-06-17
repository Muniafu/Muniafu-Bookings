import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muniafu/providers/payment_provider.dart';
import 'package:muniafu/providers/booking_provider.dart';
import 'package:muniafu/data/models/booking.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/features/home/payment_success_screen.dart';

class PaymentScreen extends StatelessWidget {
  final double amount;
  final String currency;
  final Booking booking;

  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.currency,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total: \$${amount.toStringAsFixed(2)}'),
            const SizedBox(height: 30),
            if (paymentProvider.isProcessing)
              const CircularProgressIndicator()
            else
              ButtonWidget(
                text: 'Pay with Card',
                onPressed: () async {
                  try {
                    // Process payment first
                    await paymentProvider.processPayment(
                      amount: (amount * 100).toInt(), // Convert to cents
                      currency: currency.toLowerCase(),
                      context: context,
                    );
                    
                    // Create booking in backend (with pending status)
                    final bookingId = await bookingProvider.createBooking(
                      booking.copyWith(
                        createdAt: DateTime.now(), // Ensure timestamp is set
                      )
                    );
                    
                    // Confirm booking after successful payment
                    await bookingProvider.confirmBooking(bookingId);
                    
                    // Navigate to success screen with updated booking
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentSuccessScreen(
                          booking: booking.copyWith(
                            id: bookingId,
                            status: BookingStatus.confirmed,
                          ),
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}