import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  int _previousIndex = 0;

  // Getters
  int get currentIndex => _currentIndex;
  int get previousIndex => _previousIndex;

  // Update the current navigation index
  void updateIndex(int newIndex) {
    if (_currentIndex != newIndex) {
      _previousIndex = _currentIndex;
      _currentIndex = newIndex;
      notifyListeners();
    }
  }

  // Reset to initial state
  void reset() {
    _currentIndex = 0;
    _previousIndex = 0;
    notifyListeners();
  }
}