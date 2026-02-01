import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'pages/owner_home_page.dart';
import 'pages/owner_bookings_page.dart';
import 'pages/owner_profile_page.dart';

// Provider to control selected tab
final selectedOwnerTabProvider = StateProvider<int>((ref) => 0);

class OwnerDashboard extends ConsumerStatefulWidget {
  const OwnerDashboard({super.key});

  @override
  ConsumerState<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends ConsumerState<OwnerDashboard> {
  final List<Widget> _pages = const [
    OwnerHomePage(),
    OwnerBookingsPage(),
    OwnerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedOwnerTabProvider);

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
          onTap: (index) => ref.read(selectedOwnerTabProvider.notifier).state = index,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.ownerColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
              label: 'Bookings',
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
