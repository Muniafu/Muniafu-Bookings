import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String bookingId;

  const PaymentScreen({
    super.key,
    required this.amount,
    this.currency = 'USD',
    required this.bookingId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = CardFormEditController();
  bool _isProcessing = false;
  String _cardHolderName= '';
  String _selectedMethod = 'card';
  final Map<String, dynamic> _paymentMethods = {
    'card': {
      'title': 'Credit/Debit Card',
      'icon': Icons.credit_card,
    },
    'mobile_money': {
      'title': 'Mobile Money',
      'icon': Icons.mobile_friendly,
    },
    'paypal': {
      'title': 'PayPal',
      'icon': Icons.paypal,
    },
  };

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      if (_selectedMethod == 'card') {
        await _processCardPayment();
      } else if (_selectedMethod == 'mobile_money') {
        await _processMobileMoneyPayment();
      } else if (_selectedMethod == 'paypal') {
        await _processPayPalPayment();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processCardPayment() async {
    // 1. Create payment intent on your server
    final paymentIntent = await _createPaymentIntent();

    // 2. Confirm payment with Stripe SDK
    await Stripe.instance.confirmPayment(
      paymentIntentClientSecret: paymentIntent['client_secret'],
      data: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(
          billingDetails: BillingDetails(
            name: _cardHolderName,
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _createPaymentIntent() async {
    final url = Uri.parse('https://your-server.com/create-payment-intent');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'amount': (widget.amount * 100).toInt(), // in cents
        'currency': widget.currency,
        'booking_id': widget.bookingId,
      }),
    );

    return json.decode(response.body);
  }

  Future<void> _processMobileMoneyPayment() async {
    // Implement mobile money payment logic
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
  }

  Future<void> _processPayPalPayment() async {
    // Implement PayPal payment logic
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
  }

  Widget _buildCardForm() {
    return CardFormField(
      controller: _cardController,
      style: CardFormStyle(
        textColor: Colors.black,
        placeholderColor: Colors.grey,
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: _paymentMethods.entries.map((method) {
        return RadioListTile<String>(
          title: Row(
            children: [
              Icon(method.value['icon'], color: Colors.blueAccent),
              const SizedBox(width: 10),
              Text(method.value['title']),
            ],
          ),
          value: method.key,
          groupValue: _selectedMethod,
          onChanged: (value) {
            setState(() => _selectedMethod = value!);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSelectedPaymentForm() {
    switch (_selectedMethod) {
      case 'card':
        return Column(
          children: [
            const SizedBox(height: 20),
            _buildCardForm(),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Cardholder Name",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter cardholder name';
                }
                return null;
              },
              onChanged: (value) => _cardHolderName = value,
            ),
          ],
        );
      case 'mobile_money':
        return Column(
          children: [
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          ],
        );
      case 'paypal':
        return const Column(
          children: [
            SizedBox(height: 20),
            Text('You will be redirected to PayPal to complete your payment'),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                'Total Amount: ${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildPaymentMethodSelector(),
              _buildSelectedPaymentForm(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm Payment',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}