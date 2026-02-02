import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/providers/data_providers.dart';

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final users = ref.watch(adminUsersProvider);
    final pendingVerifications = ref.watch(pendingVerificationsProvider);
    final houses = ref.watch(housesProvider);
    final services = ref.watch(servicesProvider);
    final bookings = ref.watch(bookingsProvider);
    
    // Calculate stats from watched users for real-time updates
    final stats = {
      'total': users.where((u) => u.role != 'admin').length,
      'students': users.where((u) => u.role == 'student').length,
      'owners': users.where((u) => u.role == 'owner').length,
      'providers': users.where((u) => u.role == 'provider').length,
      'verified': users.where((u) => u.isVerified && u.role != 'admin').length,
      'unverified': users.where((u) => !u.isVerified && u.role != 'admin').length,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(currentUserProvider.notifier).logout();
              if (context.mounted) {
                context.go('/auth/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                color: Colors.red.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: user?.profileImage != null
                            ? NetworkImage(user!.profileImage!)
                            : null,
                        child: user?.profileImage == null
                            ? const Icon(Icons.admin_panel_settings, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              user?.name ?? 'Super Admin',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (pendingVerifications > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$pendingVerifications pending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Statistics Overview
              const Text(
                'Platform Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _StatCard(
                    title: 'Total Users',
                    value: stats['total'].toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'Pending',
                    value: stats['unverified'].toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: 'Properties',
                    value: houses.length.toString(),
                    icon: Icons.home_work,
                    color: AppColors.ownerColor,
                  ),
                  _StatCard(
                    title: 'Services',
                    value: services.length.toString(),
                    icon: Icons.room_service,
                    color: AppColors.providerColor,
                  ),
                  _StatCard(
                    title: 'Students',
                    value: stats['students'].toString(),
                    icon: Icons.school,
                    color: AppColors.studentColor,
                  ),
                  _StatCard(
                    title: 'Bookings',
                    value: bookings.length.toString(),
                    icon: Icons.book_online,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickActionChip(
                    label: 'Verify Users',
                    icon: Icons.verified_user,
                    color: Colors.green,
                    count: pendingVerifications,
                    onTap: () {
                      // Navigate to users page with filter
                    },
                  ),
                  _QuickActionChip(
                    label: 'Manage Content',
                    icon: Icons.content_copy,
                    color: Colors.blue,
                    onTap: () {
                      // Navigate to content page
                    },
                  ),
                  _QuickActionChip(
                    label: 'View Reports',
                    icon: Icons.report,
                    color: Colors.red,
                    onTap: () {
                      // Navigate to reports
                    },
                  ),
                  _QuickActionChip(
                    label: 'Analytics',
                    icon: Icons.analytics,
                    color: Colors.purple,
                    onTap: () {
                      // Navigate to analytics
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Activity
              const Text(
                'Recent Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.take(5).length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final recentUser = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: recentUser.profileImage != null
                            ? NetworkImage(recentUser.profileImage!)
                            : null,
                        child: recentUser.profileImage == null
                            ? Text(recentUser.name[0])
                            : null,
                      ),
                      title: Text(recentUser.name),
                      subtitle: Text(
                        '${recentUser.role.toUpperCase()} • ${recentUser.isVerified ? "Verified" : "Pending"}',
                      ),
                      trailing: Icon(
                        recentUser.isVerified ? Icons.verified : Icons.pending,
                        color: recentUser.isVerified ? Colors.green : Colors.orange,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int? count;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.color,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, color: color, size: 20),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onPressed: onTap,
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}
