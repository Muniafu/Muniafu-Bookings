import 'package:flutter/material.dart';

import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService;
  PaymentModel? _currentPayment;
  bool _isLoading = false;
  String? _error;

  PaymentProvider(this._paymentService);

  PaymentModel? get currentPayment => _currentPayment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initializePayment({
    required BuildContext context,
    required String userId,
    required String bookingId,
    required double amount,
    required String email,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPayment = await _paymentService.initializePayment(
        context: context,
        userId: userId,
        bookingId: bookingId,
        amount: amount,
        email: email,
        phone: phone, checkoutMethod: '',
      );
    } catch (e) {
      _error = 'Payment error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PaymentModel>> getAdminPayments() async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _paymentService.getPaymentsForAdmin();
    } catch (e) {
      _error = 'Failed to load payments: ${e.toString()}';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}