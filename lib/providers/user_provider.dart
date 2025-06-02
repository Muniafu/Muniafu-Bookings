import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../data/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _service;
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isDarkMode => _user?.darkMode ?? false;

  UserProvider(this._service);

  // Fetch user profile
  Future<void> fetchProfile(String userId) async {
    try {
      _setLoading(true);
      _clearMessages();
      
      _user = await _service.getUserProfile(userId);
    } catch (e) {
      _error = 'Failed to load profile: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Create new user
  Future<void> createUser(User newUser) async {
    try {
      _setLoading(true);
      _clearMessages();
      
      if (_service.isFirestoreMode) {
        await _service.createUser(newUser);
      } else {
        // For HTTP mode, we need to implement creation logic
        throw UnsupportedError('User creation not supported in HTTP mode');
      }
      
      _user = newUser;
      _successMessage = 'Account created successfully';
    } catch (e) {
      _error = 'Failed to create user: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile with specific fields
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    bool? darkMode,
    String? location,
    String? phone,
    String? bio,
    String? birthDate,
  }) async {
    if (_user == null) return;
    
    try {
      _setLoading(true);
      _clearMessages();
      
      // Create update map
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (darkMode != null) updates['darkMode'] = darkMode;
      if (location != null) updates['location'] = location;
      if (phone != null) updates['phone'] = phone;
      if (bio != null) updates['bio'] = bio;
      if (birthDate != null) updates['birthDate'] = birthDate;
      
      // Apply updates
      await _service.updateProfile(_user!.id, updates);
      
      // Update local user
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        photoUrl: photoUrl ?? _user!.photoUrl,
        darkMode: darkMode ?? _user!.darkMode,
        location: location ?? _user!.location,
        phone: phone ?? _user!.phone,
        bio: bio ?? _user!.bio,
        birthDate: birthDate ?? _user!.birthDate,
      );
      
      _successMessage = 'Profile updated successfully';
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update entire user model
  Future<void> updateUserModel(User updatedUser) async {
    try {
      _setLoading(true);
      _clearMessages();
      
      if (_service.isFirestoreMode) {
        await _service.updateUserModel(updatedUser);
      } else {
        throw UnsupportedError('Full user updates not supported in HTTP mode');
      }
      
      _user = updatedUser;
      _successMessage = 'Profile updated successfully';
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    if (_user == null) return;
    
    try {
      _setLoading(true);
      _clearMessages();
      
      await _service.changePassword(_user!.id, newPassword);
      _successMessage = 'Password changed successfully';
    } catch (e) {
      _error = 'Failed to change password: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Verify email
  Future<void> verifyEmail() async {
    if (_user == null) return;
    
    try {
      _setLoading(true);
      _clearMessages();
      
      await _service.verifyEmail(_user!.id);
      _user = _user!.copyWith(emailVerified: true);
      _successMessage = 'Verification email sent';
    } catch (e) {
      _error = 'Failed to verify email: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle dark mode preference
  Future<void> toggleDarkMode() async {
    if (_user == null) return;
    
    final newMode = !_user!.darkMode;
    await updateProfile(darkMode: newMode);
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_user != null) {
      await fetchProfile(_user!.id);
    }
  }

  // Logout/Clear user data
  void logout() {
    _user = null;
    _clearMessages();
    notifyListeners();
  }

  // Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearMessages() {
    _error = null;
    _successMessage = null;
  }
}