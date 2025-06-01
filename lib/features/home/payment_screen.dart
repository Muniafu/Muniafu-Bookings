import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../data/models/booking.dart';
import '../../data/models/room.dart';

class PaymentScreen extends StatefulWidget {
  final bool isMockMode;
  final double amount;
  final String? currency;
  final String? bookingId;
  final Map<String, dynamic>? guestInfo;
  final VoidCallback? onPaymentSuccess;
  final Booking? booking;
  final Room? room;

  const PaymentScreen.mock({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  })  : isMockMode = true,
        currency = null,
        bookingId = null,
        guestInfo = null,
        booking = null,
        room = null;

  const PaymentScreen.real({
    super.key,
    required this.amount,
    required this.currency,
    required this.bookingId,
    this.guestInfo,
    this.booking,
    this.room,
  })  : isMockMode = false,
        onPaymentSuccess = null;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late CardFormEditController _cardController;
  bool _isProcessing = false;
  String _cardHolderName = '';
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
    
    if (!widget.isMockMode) {
      Stripe.publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
      _cardController = CardFormEditController();
    }
  }

  @override
  void dispose() {
    if (!widget.isMockMode) {
      _cardController.dispose();
    }
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (widget.isMockMode) {
      _handleMockPayment();
      return;
    }

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

      if (!mounted) return; // Check if widget is still in tree
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return; // Check if widget is still in tree
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleMockPayment() {
    widget.onPaymentSuccess?.call();
    if (!mounted) return; // Check if widget is still in tree
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock Payment Successful')),
    );
    Navigator.pop(context);
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
        textColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        placeholderColor: Theme.of(context).hintColor,
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: _paymentMethods.entries.map((method) {
        return RadioListTile<String>(
          title: Row(
            children: [
              Icon(method.value['icon'], color: Theme.of(context).primaryColor),
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

  Widget _buildBookingSummary() {
    if (widget.booking == null || widget.room == null) {
      return Container();
    }

    return Card( // Using Material Card widget
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Hotel', widget.booking?.hotelName ?? ''),
            _buildSummaryRow('Room', widget.room?.name ?? ''),
            _buildSummaryRow(
              'Dates',
              '${_formatDate(widget.booking?.checkInDate)} - ${_formatDate(widget.booking?.checkOutDate)}',
            ),
            _buildSummaryRow(
              'Guests',
              '${widget.guestInfo?['adults'] ?? 1} Adults, ${widget.guestInfo?['children'] ?? 0} Children',
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              '\$${widget.amount.toStringAsFixed(2)} ${widget.currency}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
          Text(
            value,
            style: isBold
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? DateFormat('MMM dd, yyyy').format(date) // Using DateFormat
        : 'N/A';
  }

  Widget _buildMockPaymentUI() {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Amount: \$${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('Confirm Mock Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealPaymentUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              if (widget.booking != null && widget.room != null)
                _buildBookingSummary(),
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
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator()
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

  @override
  Widget build(BuildContext context) {
    return widget.isMockMode
        ? _buildMockPaymentUI()
        : _buildRealPaymentUI();
  }
}