import 'package:flutter/material.dart';

// Managing admin-related state and actions

class AdminProvider with ChangeNotifier{
  List<String> _payments = []; // stores a list of payments made by users;

  List<String> get payments => _payments;

  // Add a payment to the admin's payment list
  void addPayment(String payment) {
    _payments.add(payment);
    notifyListeners(); // Notify listeners to update the UI
  }

  // Fetch payments (simulate API call)
  Future<void> fetchPayment() async {

    // Simulate a delay to mimic an API call
    await Future.delayed(const Duration(seconds: 5));
    _payments = ['Payment 1', 'Payment 2', 'Payment 3'];
    notifyListeners();
  }
}