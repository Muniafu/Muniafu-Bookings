import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  int _previousIndex = 0;
  bool _isTransitioning = false;

  // Getters
  int get currentIndex => _currentIndex;
  int get previousIndex => _previousIndex;
  bool get isTransitioning => _isTransitioning;

  // Update the current navigation index
  void updateIndex(int newIndex, {bool notify = true}) {
    if (_currentIndex != newIndex && !_isTransitioning) {
      _isTransitioning = true;
      _previousIndex = _currentIndex;
      _currentIndex = newIndex;
      
      if (notify) {
        notifyListeners();
      }
      _isTransitioning = false;
    }
  }

  // For backward compatibility
  void setIndex(int index) {
    updateIndex(index);
  }

  // Reset to initial state
  void reset() {
    _currentIndex = 0;
    _previousIndex = 0;
    _isTransitioning = false;
    notifyListeners();
  }

  // Check if a specific tab is active
  bool isTabActive(int index) {
    return _currentIndex == index;
  }

  // Get the navigation history
  List<int> get navigationHistory {
    return [_previousIndex, _currentIndex];
  }

  // Handle back navigation
  void navigateBack() {
    if (_previousIndex != _currentIndex) {
      updateIndex(_previousIndex);
    }
  }
}