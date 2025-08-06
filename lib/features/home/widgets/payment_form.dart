import 'package:flutter/material.dart';
import '../payment_screen.dart';

class PaymentFormWidget extends StatefulWidget {
  final String roomId;
  final int amount;
  final VoidCallback onPaymentSuccess;

  const PaymentFormWidget({
    super.key, 
    required this.roomId,
    required this.amount,
    required this.onPaymentSuccess,
    
  });

  @override
  State<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumber = TextEditingController();
  final TextEditingController _expiry = TextEditingController();
  final TextEditingController _cvv = TextEditingController();

  void _mockSubmitPayment() {
    if (_formKey.currentState!.validate()) {
      widget.onPaymentSuccess();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentProcessingScreen(
            roomId: widget.roomId,
            amount: widget.amount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildField(_cardNumber, 'Card Number', TextInputType.number),
          const SizedBox(height: 12),
          _buildField(_expiry, 'Expiry (MM/YY)', TextInputType.datetime),
          const SizedBox(height: 12),
          _buildField(_cvv, 'CVV', TextInputType.number, obscure: true),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _mockSubmitPayment,
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, TextInputType type, {bool obscure = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }
}
