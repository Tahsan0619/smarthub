import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);
});

final authServiceProvider = Provider((ref) {
  return AuthService();
});

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  
  return await SupabaseService.getUserProfile(user.id);
});

/// Check if user is verified/approved by admin
final userApprovalStatusProvider = FutureProvider<bool>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;
  
  final profile = await SupabaseService.getUserProfile(user.id);
  return profile?['is_verified'] == true;
});

void _authLog(String message) {
  // ignore: avoid_print
  print('[AuthService] $message');
}

class AuthService {
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      _authLog('signUp -> start (email: $email, role: $role)');
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final authUser = authResponse.user;
      if (authUser == null) {
        _authLog('signUp -> error: null auth user');
        throw Exception('Unable to create user. Please try again.');
      }

      // Create user profile with is_verified = false by default
      // User cannot sign in until admin approves (sets is_verified = true)
      await SupabaseService.createUserProfile(
        authId: authUser.id,
        email: email,
        displayName: displayName,
        role: role,
      );
      
      _authLog('signUp -> success (pending approval)');
    } catch (e) {
      _authLog('signUp -> error: $e');
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _authLog('signIn -> start (email: $email)');
      // First authenticate with Supabase
      final authResponse = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = authResponse.user;
      if (authUser == null) {
        _authLog('signIn -> error: invalid credentials');
        throw Exception('Invalid credentials');
      }

      // Then check if user is approved by admin
      final profile = await SupabaseService.getUserProfile(authUser.id);

      if (profile == null) {
        _authLog('signIn -> error: profile not found');
        throw Exception('User profile not found');
      }

      // Check if user is verified (approved by admin)
      final isVerified = profile['is_verified'] == true;
      
      if (!isVerified) {
        // Sign out the user if not approved
        await Supabase.instance.client.auth.signOut();
        _authLog('signIn -> blocked (pending approval)');
        throw Exception('Account pending admin approval. Please contact support.');
      }

      _authLog('signIn -> success');
    } catch (e) {
      _authLog('signIn -> error: $e');
      // Make sure user is signed out if there's an error
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _authLog('signOut -> start');
      await Supabase.instance.client.auth.signOut();
      _authLog('signOut -> success');
    } catch (e) {
      _authLog('signOut -> error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _authLog('resetPassword -> start (email: $email)');
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      _authLog('resetPassword -> success');
    } catch (e) {
      _authLog('resetPassword -> error: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    return Supabase.instance.client.auth.currentUser;
  }
}
