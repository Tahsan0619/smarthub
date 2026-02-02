import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/mock_data_service.dart';

// Current user state
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  CurrentUserNotifier() : super(null) {
    _loadUser();
  }

  void _loadUser() {
    final userJson = StorageService.getUser();
    if (userJson != null) {
      try {
        state = UserModel.fromJson(json.decode(userJson));
      } catch (e) {
        state = null;
      }
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      // Mock login - find user by email
      final user = MockDataService.demoUsers.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('User not found'),
      );

      // In production, verify password here
      state = user;
      await StorageService.saveUser(json.encode(user.toJson()));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    state = null;
    await StorageService.clearUser();
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    state = updatedUser;
    await StorageService.saveUser(json.encode(updatedUser.toJson()));
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? university,
    String? address,
    String? nid,
  }) async {
    try {
      // Check if email already exists
      final existingUser = MockDataService.demoUsers.where(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
      if (existingUser.isNotEmpty) {
        return false; // Email already exists
      }

      // Create new user
      final newUser = UserModel(
        id: 'u${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        role: role,
        university: university,
        address: address,
        nid: nid,
        isVerified: false, // New users need admin verification
        rating: 0.0,
        reviewCount: 0,
        createdAt: DateTime.now(),
      );

      // Add to demo users list (in production, save to backend)
      MockDataService.demoUsers.add(newUser);

      // Auto-login after signup
      state = newUser;
      await StorageService.saveUser(json.encode(newUser.toJson()));
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// User role
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});
