import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:muniafu/data/services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Future<void> processPayment({
    required int amount,
    required String currency,
    required BuildContext context,
  }) async {
    try {
      _isProcessing = true;
      notifyListeners();

      // 1. Create Payment Intent
      final clientSecret = await PaymentService.createPaymentIntent(
        amount: amount,
        currency: currency,
      );

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Booking App',
        ),
      );

      // 3. Display Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Confirm Payment Success
    } catch (e) {
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}