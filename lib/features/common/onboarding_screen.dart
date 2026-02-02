import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onSkip;

  const OnboardingScreen({super.key, required this.onSkip});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingData> onboardingData = [
    OnboardingData(
      icon: Icons.home,
      title: 'Find Houses',
      subtitle: 'Browse and book houses easily',
      color: Colors.blue.shade400,
    ),
    OnboardingData(
      icon: Icons.build,
      title: 'Service Providers',
      subtitle: 'Connect with trusted service providers',
      color: Colors.purple.shade400,
    ),
    OnboardingData(
      icon: Icons.school,
      title: 'Tuition Services',
      subtitle: 'Find qualified tutors for any subject',
      color: Colors.indigo.shade400,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Got It!'),
        content: const Text('You won\'t see this onboarding again for 30 days.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Save the current date to SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              final now = DateTime.now();
              await prefs.setString('onboarding_last_shown', now.toIso8601String());
              
              widget.onSkip();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return _OnboardingPage(data: onboardingData[index]);
              },
            ),
          ),
          // Dots indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentPage == onboardingData.length - 1
                    ? _showConfirmDialog
                    : () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _currentPage == onboardingData.length - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.color,
            data.color.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large icon
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 120,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              data.subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
