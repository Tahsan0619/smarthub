import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend initialization script for Super Admin
/// Run this ONCE to set up the super admin account
/// This should ONLY be run during backend setup, never exposed in app

class BackendInitializer {
  static const String superAdminEmail = 'sajibvai.ituapu@gmail.com';
  static const String superAdminPassword = 'smarthub';

  /// Initialize super admin in Supabase Auth
  /// Should be called from a backend service or CLI tool
  /// NOT from the Flutter app
  static Future<void> initializeSuperAdmin({
    required String supabaseAnonKey,
    required String supabaseUrl,
  }) async {
    try {
      print('🔧 Starting Super Admin Initialization...');
      
      // Initialize Supabase
      if (!Supabase.instance.isInitialized) {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
      }

      final supabaseClient = Supabase.instance.client;

      // Create super admin user in auth
      try {
        final authResponse = await supabaseClient.auth.signUp(
          email: superAdminEmail,
          password: superAdminPassword,
        );

        if (authResponse.user != null) {
          // Create user profile with admin role and verified status
          await supabaseClient.from('users').insert({
            'auth_id': authResponse.user!.id,
            'email': superAdminEmail,
            'display_name': 'Super Admin',
            'role': 'admin',
            'is_verified': true,
            'verification_date': DateTime.now().toIso8601String(),
          });

          print('✅ Super Admin Created Successfully!');
          print('📧 Email: $superAdminEmail');
          print('🔐 Password: (set in backend only)');
          print('⚠️ NEVER expose these credentials in frontend code!');
        }
      } on AuthException catch (e) {
        if (e.message.contains('already registered')) {
          print('ℹ️ Super Admin already exists, updating profile...');
          
          // Get the super admin user
          final users = await supabaseClient
              .from('users')
              .select()
              .eq('email', superAdminEmail);

          if (users.isNotEmpty) {
            print('✅ Super Admin profile found');
          }
        } else {
          print('❌ Error creating super admin: ${e.message}');
          rethrow;
        }
      }
    } catch (e) {
      print('❌ Initialization failed: $e');
      rethrow;
    }
  }

  /// Verify that super admin exists (call this to check status)
  static Future<bool> superAdminExists() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('email', superAdminEmail)
          .eq('is_verified', true)
          .single();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
