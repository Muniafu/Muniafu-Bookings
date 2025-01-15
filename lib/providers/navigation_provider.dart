import 'package:flutter/material.dart';

// Managing navigation state
class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  // Update current index and notifier
  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}