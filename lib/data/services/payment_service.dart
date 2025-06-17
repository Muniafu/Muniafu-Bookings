import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:muniafu/app/config/app_constants.dart';

class PaymentService {
  static Future<String> createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer ${AppConstants.stripeSecretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amount.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      },
    );

    return jsonDecode(response.body)['client_secret'];
  }
}