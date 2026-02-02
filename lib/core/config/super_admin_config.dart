/// Super Admin configuration - Backend only
/// DO NOT expose these credentials in the frontend
class SuperAdminConfig {
  // Fixed super admin credentials
  static const String superAdminEmail = 'sajibvai.ituapu@gmail.com';
  static const String superAdminPassword = 'smarthub';
  
  /// Initialize super admin in Supabase
  /// Run this ONCE after creating the Supabase project
  /// This should only be executed during backend setup, never in production app
  static Future<void> initializeSuperAdmin() async {
    // This function should be called in a backend script/CLI, not in the app
    // It will create the super admin user with verified status
    print('⚠️ Super admin initialization should be done via backend script only!');
  }
}
