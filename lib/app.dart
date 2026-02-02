import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/data_providers.dart';
import 'features/common/onboarding_screen.dart';

class SmartHubApp extends ConsumerWidget {
  const SmartHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final shouldShowOnboarding = ref.watch(shouldShowOnboardingProvider);
    
    return MaterialApp.router(
      title: 'Smart Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        return shouldShowOnboarding.when(
          data: (showOnboarding) {
            if (!showOnboarding) {
              return content;
            }
            return Stack(
              children: [
                content,
                Positioned.fill(
                  child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute(
                      builder: (_) => OnboardingScreen(
                        onSkip: () {
                          ref.invalidate(shouldShowOnboardingProvider);
                          ref.read(routerProvider).go('/auth/login');
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, __) => content,
        );
      },
    );
  }
}
