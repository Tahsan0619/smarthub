import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';

// Admin provider for user management
final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, List<UserModel>>((ref) {
  return AdminUsersNotifier();
});

class AdminUsersNotifier extends StateNotifier<List<UserModel>> {
  AdminUsersNotifier() : super(MockDataService.demoUsers);

  // Verify a user
  void verifyUser(String userId, String adminId) {
    state = [
      for (final user in state)
        if (user.id == userId)
          user.copyWith(
            isVerified: true,
            verifiedAt: DateTime.now(),
            verifiedBy: adminId,
          )
        else
          user,
    ];
    
    // Update MockDataService
    final index = MockDataService.demoUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      MockDataService.demoUsers[index] = state.firstWhere((u) => u.id == userId);
    }
  }

  // Unverify a user
  void unverifyUser(String userId) {
    state = [
      for (final user in state)
        if (user.id == userId)
          user.copyWith(
            isVerified: false,
            verifiedAt: null,
            verifiedBy: null,
          )
        else
          user,
    ];
    
    // Update MockDataService
    final index = MockDataService.demoUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      MockDataService.demoUsers[index] = state.firstWhere((u) => u.id == userId);
    }
  }

  // Delete a user
  void deleteUser(String userId) {
    state = state.where((u) => u.id != userId).toList();
    MockDataService.demoUsers.removeWhere((u) => u.id == userId);
  }

  // Update user details
  void updateUser(UserModel updatedUser) {
    state = [
      for (final user in state)
        if (user.id == updatedUser.id) updatedUser else user,
    ];
    
    // Update MockDataService
    final index = MockDataService.demoUsers.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      MockDataService.demoUsers[index] = updatedUser;
    }
  }

  // Get users by role
  List<UserModel> getUsersByRole(String role) {
    return state.where((u) => u.role == role).toList();
  }

  // Get unverified users
  List<UserModel> getUnverifiedUsers() {
    return state.where((u) => !u.isVerified && u.role != 'admin').toList();
  }

  // Get verified users
  List<UserModel> getVerifiedUsers() {
    return state.where((u) => u.isVerified && u.role != 'admin').toList();
  }

  // Search users
  List<UserModel> searchUsers(String query) {
    final lowerQuery = query.toLowerCase();
    return state.where((u) =>
      u.name.toLowerCase().contains(lowerQuery) ||
      u.email.toLowerCase().contains(lowerQuery) ||
      u.phone.contains(query) ||
      (u.nid?.contains(query) ?? false)
    ).toList();
  }

  // Get admin statistics
  Map<String, int> getStatistics() {
    final students = state.where((u) => u.role == 'student').length;
    final owners = state.where((u) => u.role == 'owner').length;
    final providers = state.where((u) => u.role == 'provider').length;
    final verified = state.where((u) => u.isVerified && u.role != 'admin').length;
    final unverified = state.where((u) => !u.isVerified && u.role != 'admin').length;
    final total = state.where((u) => u.role != 'admin').length;

    return {
      'totalUsers': total,
      'students': students,
      'owners': owners,
      'providers': providers,
      'verifiedUsers': verified,
      'pendingVerifications': unverified,
    };
  }
}

// Provider for pending verifications count
final pendingVerificationsProvider = Provider<int>((ref) {
  final users = ref.watch(adminUsersProvider);
  return users.where((u) => !u.isVerified && u.role != 'admin').length;
});
