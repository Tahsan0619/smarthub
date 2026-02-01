import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'pages/provider_home_page.dart';
import 'pages/provider_orders_page.dart';
import 'pages/provider_profile_page.dart';

// Provider to control selected tab
final selectedProviderTabProvider = StateProvider<int>((ref) => 0);

class ProviderDashboard extends ConsumerStatefulWidget {
  const ProviderDashboard({super.key});

  @override
  ConsumerState<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends ConsumerState<ProviderDashboard> {
  final List<Widget> _pages = const [
    ProviderHomePage(),
    ProviderOrdersPage(),
    ProviderProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedProviderTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => ref.read(selectedProviderTabProvider.notifier).state = index,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.providerColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
