import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

// Signup result enum
enum SignupResult { success, emailExists, error }

// Login result enum
enum LoginResult { success, invalidCredentials, pendingApproval, error }

// Current user state
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  CurrentUserNotifier() : super(null) {
    _loadUserFromStorage();
    _listenAuthChanges();
  }

  StreamSubscription<AuthState>? _authSub;

  void _log(String message) {
    // ignore: avoid_print
    print('[CurrentUser] $message');
  }

  void _loadUserFromStorage() {
    final userJson = StorageService.getUser();
    if (userJson != null) {
      try {
        state = UserModel.fromJson(json.decode(userJson));
      } catch (e) {
        state = null;
      }
    }
  }

  void _listenAuthChanges() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (event) async {
        _log('authState -> ${event.event.name}');
        if (event.event == AuthChangeEvent.signedIn ||
            event.event == AuthChangeEvent.tokenRefreshed ||
            event.event == AuthChangeEvent.userUpdated) {
          final user = event.session?.user;
          if (user != null) {
            await _loadUserProfile(user.id);
          }
        }

        if (event.event == AuthChangeEvent.signedOut) {
          state = null;
          await StorageService.clearUser();
        }
      },
    );
  }

  Future<void> _loadUserProfile(String authId) async {
    _log('loadProfile -> start (auth_id: $authId)');
    final profile = await SupabaseService.getUserProfile(authId);
    if (profile == null) return;

    final userModel = _mapProfileToUser(profile);
    state = userModel;
    await StorageService.saveUser(json.encode(userModel.toJson()));
    _log('loadProfile -> success');
  }

  UserModel _mapProfileToUser(Map<String, dynamic> profile) {
    final createdAtRaw = profile['created_at'];
    final createdAt = createdAtRaw is String
        ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
        : createdAtRaw is DateTime
            ? createdAtRaw
            : DateTime.now();

    final ratingRaw = profile['rating'];
    final reviewRaw = profile['review_count'];

    return UserModel(
      id: (profile['id'] ?? '').toString(),
      name: (profile['display_name'] ?? '').toString(),
      email: (profile['email'] ?? '').toString(),
      phone: (profile['phone_number'] ?? '').toString(),
      role: (profile['role'] ?? '').toString(),
      profileImage: profile['profile_image_url'] as String?,
      address: profile['location'] as String?,
      university: profile['university'] as String?,
      nid: profile['nid_number'] as String?,
      isVerified: profile['is_verified'] == true,
      verifiedAt: profile['verification_date'] != null
          ? DateTime.tryParse(profile['verification_date'].toString())
          : null,
      verifiedBy: profile['verified_by'] as String?,
      rating: ratingRaw is num ? ratingRaw.toDouble() : 0.0,
      reviewCount: reviewRaw is int ? reviewRaw : 0,
      createdAt: createdAt,
    );
  }

  Future<LoginResult> login(String email, String password) async {
    try {
      _log('login -> start (email: $email)');
      final authResponse = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = authResponse.user;
      if (authUser == null) return LoginResult.invalidCredentials;

      final profile = await SupabaseService.getUserProfile(authUser.id);
      if (profile == null) {
        await Supabase.instance.client.auth.signOut();
        _log('login -> no profile found');
        return LoginResult.error;
      }

      final isVerified = profile['is_verified'] == true;
      if (!isVerified) {
        await Supabase.instance.client.auth.signOut();
        _log('login -> blocked (pending approval)');
        return LoginResult.pendingApproval;
      }

      final userModel = _mapProfileToUser(profile);
      state = userModel;
      await StorageService.saveUser(json.encode(userModel.toJson()));
      _log('login -> success');
      return LoginResult.success;
    } on AuthException catch (e) {
      _log('login -> auth error: ${e.message}');
      return LoginResult.invalidCredentials;
    } catch (e) {
      _log('login -> error: $e');
      return LoginResult.error;
    }
  }

  Future<void> logout() async {
    state = null;
    _log('logout -> start');
    await Supabase.instance.client.auth.signOut();
    await StorageService.clearUser();
    _log('logout -> success');
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    state = updatedUser;
    _log('updateProfile -> start');
    await SupabaseService.updateUserProfile(updatedUser.id, {
      'display_name': updatedUser.name,
      'phone_number': updatedUser.phone,
      'profile_image_url': updatedUser.profileImage,
      'location': updatedUser.address,
      'nid_number': updatedUser.nid,
      'is_verified': updatedUser.isVerified,
      'verification_date': updatedUser.verifiedAt?.toIso8601String(),
    });
    await StorageService.saveUser(json.encode(updatedUser.toJson()));
    _log('updateProfile -> success');
  }

  Future<SignupResult> signup({
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
      _log('signup -> start (email: $email, role: $role)');
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final authUser = authResponse.user;
      if (authUser == null) return SignupResult.error;

      // Check if user already exists (email was already registered)
      if (authResponse.user?.identities?.isEmpty ?? false) {
        _log('signup -> email already exists');
        return SignupResult.emailExists;
      }

      await SupabaseService.createUserProfile(
        authId: authUser.id,
        email: email,
        displayName: name,
        role: role,
        phoneNumber: phone,
        address: address,
        nidNumber: nid,
        university: university,
      );

      // Ensure user must wait for admin approval
      await Supabase.instance.client.auth.signOut();
      _log('signup -> success (pending approval)');
      return SignupResult.success;
    } on AuthException catch (e) {
      _log('signup -> auth error: ${e.message}');
      if (e.message.contains('already registered') || e.message.contains('already exists')) {
        return SignupResult.emailExists;
      }
      return SignupResult.error;
    } catch (e) {
      _log('signup -> error: $e');
      return SignupResult.error;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
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
