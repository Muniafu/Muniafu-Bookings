import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'package:http/http.dart' as http;

import '../models/payment_model.dart';

class PaymentService {
  final String paystackPublicKeyTest;
  final bool isSandbox;

  PaymentService({
    required this.paystackPublicKeyTest,
    this.isSandbox = true,
  });


  /// Initialize a payment and return final payment status
  Future<PaymentModel> initializePayment({
    required BuildContext context,
    required String userId,
    required String bookingId,
    required double amount,
    required String email,
    String? phone,
    required String checkoutMethod, // "card" or other method for your UI
  }) async {
    final txRef = 'BOOK_${DateTime.now().millisecondsSinceEpoch}';

    // Create initial payment record
    final payment = PaymentModel(
      id: txRef,
      bookingId: bookingId,
      userId: userId,
      amount: amount,
      currency: 'KES', // adjust currency
      paymentMethod: 'card',
      gatewayReference: txRef,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final completer = Completer<PaymentModel>();
    final uniqueTransRef = PayWithPayStack().generateUuidV4();

    try {
      // Start Paystack payment
      await PayWithPayStack().now(
        context: context,
        customerEmail: email,
        reference: uniqueTransRef,
        currency: payment.currency,
        amount: (amount * 100),
        transactionCompleted: (paymentData) async {
          final updatedPayment = payment.copyWith(
            status: 'successful',
            paymentMethod: checkoutMethod,
            completedAt: DateTime.now(),
          );
          await _savePayment(updatedPayment);
          completer.complete(updatedPayment);
        },
        transactionNotCompleted: (reason) async {
          final failedPayment = payment.copyWith(
            status: 'failed',
            completedAt: DateTime.now(),
          );
          await _savePayment(failedPayment);
          debugPrint("==> Transaction failed reason: $reason");
          completer.complete(failedPayment);
        }, callbackUrl: '', secretKey: '',
      );

      return completer.future;
    } catch (e) {
      final failedPayment = payment.copyWith(
        status: 'failed',
        completedAt: DateTime.now(),
      );
      await _savePayment(failedPayment);
      debugPrint('Paystack error: $e');
      return failedPayment;
    }
  }

  /// Save payment to Firestore
  Future<void> _savePayment(PaymentModel payment) async {
    await FirebaseFirestore.instance
        .collection('payments')
        .doc(payment.id)
        .set(payment.toMap());
  }

  /// Verify payment via Paystack API (optional)
  Future<bool> verifyPayment(String reference) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {'Authorization': 'Bearer $paystackPublicKeyTest'},
      );

      final data = jsonDecode(response.body);
      return data['status'] == true && data['data']['status'] == 'success';
    } catch (e) {
      debugPrint('Verification error: $e');
      return false;
    }
  }

  /// Fetch all payments for admin
  Future<List<PaymentModel>> getPaymentsForAdmin() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PaymentModel.fromMap(doc.data()))
        .toList();
  }
}