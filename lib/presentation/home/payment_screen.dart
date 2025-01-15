import 'package:flutter/material.dart';

class PaymentScreen  extends StatelessWidget{
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MakePayment'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Payment option 1
            _paymentOption(
              title: 'Credit/Debit Card',
              icon: Icons.credit_card,
              onTap: () {
                _processCardPayment(context);
              },
            ),
            const SizedBox(height: 10),

            // Payment option 2
            _paymentOption(
              title: 'Mobile Money',
              icon: Icons.mobile_friendly,
              onTap: () {
                _processMobileMoneyPayment(context);
              },
            ),
            const SizedBox(height: 10),

            // Payment Option 3
            _paymentOption(
              title: 'Paypal',
              icon: Icons.paypal,
              onTap: () {
                _processPayPalPayment(context);
              },
            ),

            const Spacer(),

            // Cancel payment button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('Cancel Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

 // Reusable widget for each payment option
  Widget _paymentOption({
    required String title,
    required IconData icon, // Changed type from String to IconData
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent, size: 30), // No need to cast icon
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }


  // Simulates processing a card payment
  void _processCardPayment(BuildContext context) {
    _showPaymentDialog(context, 'processing Credit/Debit Card Payment...');
  }

  // Simulates processing a mobile money payment
  void _processMobileMoneyPayment(BuildContext context) {
    _showPaymentDialog(context, 'processing Mobile Money payment...');
  }
  
  // Simulates processing a paypal payment
  void _processPayPalPayment(BuildContext context) {
    _showPaymentDialog(context, 'processing PayPal Payment...');
  }
  
  // Display a dialog to show payment processing status
  void _showPaymentDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment In Progress'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }  
}