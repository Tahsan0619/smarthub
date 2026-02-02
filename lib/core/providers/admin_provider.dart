import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

void _log(String message) {
  // ignore: avoid_print
  print('[AdminProvider] $message');
}

// Admin provider for user management
final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AsyncValue<List<UserModel>>>((ref) {
  return AdminUsersNotifier();
});

class AdminUsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  RealtimeChannel? _subscription;

  AdminUsersNotifier() : super(const AsyncValue.loading()) {
    loadUsers();
    _subscribeToChanges();
  }

  Future<void> loadUsers() async {
    try {
      _log('loadUsers -> start');
      state = const AsyncValue.loading();
      final data = await SupabaseService.getAllUsers();
      final users = data.map((e) => _mapToUserModel(e)).toList();
      state = AsyncValue.data(users);
      _log('loadUsers -> loaded ${users.length} users');
    } catch (e, st) {
      _log('loadUsers -> error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  void _subscribeToChanges() {
    _subscription = SupabaseService.subscribeToUsers((payload) {
      _log('users realtime update received');
      loadUsers();
    });
  }

  UserModel _mapToUserModel(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['display_name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone_number'] ?? '',
      role: data['role'] ?? '',
      profileImage: data['profile_image_url'],
      address: data['location'],
      university: data['university'],
      nid: data['nid_number'],
      isVerified: data['is_verified'] ?? false,
      verifiedAt: data['verification_date'] != null
          ? DateTime.tryParse(data['verification_date'].toString())
          : null,
      verifiedBy: data['verified_by'],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['review_count'] ?? 0,
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Verify a user
  Future<void> verifyUser(String userId, String adminId) async {
    try {
      _log('verifyUser -> start (userId: $userId)');
      await SupabaseService.verifyUser(userId, adminId);
      _log('verifyUser -> success');
      await loadUsers();
    } catch (e) {
      _log('verifyUser -> error: $e');
      rethrow;
    }
  }

  // Unverify a user
  Future<void> unverifyUser(String userId) async {
    try {
      _log('unverifyUser -> start (userId: $userId)');
      await SupabaseService.unverifyUser(userId);
      _log('unverifyUser -> success');
      await loadUsers();
    } catch (e) {
      _log('unverifyUser -> error: $e');
      rethrow;
    }
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      _log('deleteUser -> start (userId: $userId)');
      await SupabaseService.deleteUser(userId);
      _log('deleteUser -> success');
      await loadUsers();
    } catch (e) {
      _log('deleteUser -> error: $e');
      rethrow;
    }
  }

  // Update user details
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      _log('updateUser -> start (userId: ${updatedUser.id})');
      await SupabaseService.updateUserProfile(updatedUser.id, {
        'display_name': updatedUser.name,
        'phone_number': updatedUser.phone,
        'profile_image_url': updatedUser.profileImage,
        'location': updatedUser.address,
        'nid_number': updatedUser.nid,
        'role': updatedUser.role,
      });
      _log('updateUser -> success');
      await loadUsers();
    } catch (e) {
      _log('updateUser -> error: $e');
      rethrow;
    }
  }

  // Get users by role
  List<UserModel> getUsersByRole(String role) {
    return state.value?.where((u) => u.role == role).toList() ?? [];
  }

  // Get unverified users
  List<UserModel> getUnverifiedUsers() {
    return state.value?.where((u) => !u.isVerified && u.role != 'admin').toList() ?? [];
  }

  // Get verified users
  List<UserModel> getVerifiedUsers() {
    return state.value?.where((u) => u.isVerified && u.role != 'admin').toList() ?? [];
  }

  // Search users
  List<UserModel> searchUsers(String query) {
    final lowerQuery = query.toLowerCase();
    return state.value?.where((u) =>
      u.name.toLowerCase().contains(lowerQuery) ||
      u.email.toLowerCase().contains(lowerQuery) ||
      u.phone.contains(query) ||
      (u.nid?.contains(query) ?? false)
    ).toList() ?? [];
  }

  // Get admin statistics
  Map<String, int> getStatistics() {
    final users = state.value ?? [];
    final students = users.where((u) => u.role == 'student').length;
    final owners = users.where((u) => u.role == 'owner').length;
    final providers = users.where((u) => u.role == 'provider').length;
    final verified = users.where((u) => u.isVerified && u.role != 'admin').length;
    final unverified = users.where((u) => !u.isVerified && u.role != 'admin').length;
    final total = users.where((u) => u.role != 'admin').length;

    return {
      'totalUsers': total,
      'students': students,
      'owners': owners,
      'providers': providers,
      'verifiedUsers': verified,
      'pendingVerifications': unverified,
    };
  }

  @override
  void dispose() {
    if (_subscription != null) {
      SupabaseService.unsubscribe(_subscription!);
    }
    super.dispose();
  }
}

// Provider for pending verifications count
final pendingVerificationsProvider = Provider<int>((ref) {
  final usersAsync = ref.watch(adminUsersProvider);
  return usersAsync.value?.where((u) => !u.isVerified && u.role != 'admin').length ?? 0;
});

// Helper provider to get all users list
final adminUsersListProvider = Provider<List<UserModel>>((ref) {
  return ref.watch(adminUsersProvider).value ?? [];
});
