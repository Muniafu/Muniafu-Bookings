import 'package:intl/intl.dart';

// Helper function for formatting currency
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(symbol: '₹');
  return formatter.format(amount);
}

// Helper function for email validation
bool validateEmail(String email) {
  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return regex.hasMatch(email);
}

// Helper function for password validation
bool validatePassword(String password) {
  // Minimum 8 characters, at least one letter and one number
  final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
  return regex.hasMatch(password);
}