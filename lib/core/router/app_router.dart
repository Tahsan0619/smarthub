import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/role_select_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/student/student_dashboard.dart';
import '../../features/owner/owner_dashboard.dart';
import '../../features/provider/provider_dashboard.dart';
import '../../features/admin/admin_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final userRole = ref.watch(userRoleProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.matchedLocation;
      
      // If on splash, let it handle navigation
      if (path == '/splash') return null;
      
      // If not authenticated and not on auth screens, go to login
      if (!isAuthenticated && !path.startsWith('/auth')) {
        return '/auth/login';
      }
      
      // If authenticated and on auth screens, redirect to dashboard
      if (isAuthenticated && path.startsWith('/auth')) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          if (userRole == 'student') {
            return const StudentDashboard();
          } else if (userRole == 'owner') {
            return const OwnerDashboard();
          } else if (userRole == 'provider') {
            return const ProviderDashboard();
          } else if (userRole == 'admin') {
            return const AdminDashboard();
          }
          return const SplashScreen();
        },
      ),
    ],
  );
});
