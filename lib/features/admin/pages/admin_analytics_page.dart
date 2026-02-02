import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/models/service_model.dart';

class AdminAnalyticsPage extends ConsumerWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all providers for real-time updates
    final users = ref.watch(adminUsersListProvider);
    final houses = ref.watch(housesListProvider);
    final services = ref.watch(servicesListProvider);
    final bookings = ref.watch(bookingsListProvider);
    final orders = ref.watch(ordersListProvider);

    // Calculate stats from watched users for real-time updates
    final stats = {
      'totalUsers': users.where((u) => u.role != 'admin').length,
      'students': users.where((u) => u.role == 'student').length,
      'owners': users.where((u) => u.role == 'owner').length,
      'providers': users.where((u) => u.role == 'provider').length,
      'verifiedUsers': users.where((u) => u.isVerified && u.role != 'admin').length,
      'pendingVerifications': users.where((u) => !u.isVerified && u.role != 'admin').length,
    };

    // Calculate additional metrics
    final availableHouses = houses.where((h) => h.status == 'available').length;
    final occupiedHouses = houses.length - availableHouses;
    final totalRevenue = orders.fold<double>(0, (sum, order) => sum + (order.price * order.quantity));
    final averageOrderValue = orders.isEmpty ? 0.0 : totalRevenue / orders.length;

    // Service category breakdown
    final foodServices = services.where((s) => s.category == ServiceCategory.food).length;
    final medicineServices = services.where((s) => s.category == ServiceCategory.medicine).length;
    final furnitureServices = services.where((s) => s.category == ServiceCategory.furniture).length;
    final tuitionServices = services.where((s) => s.category == ServiceCategory.tuition).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          ref.invalidate(adminUsersProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Analytics Section
            _SectionHeader(
              icon: Icons.people,
              title: 'User Analytics',
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _MetricCard(
                  title: 'Total Users',
                  value: '${stats['totalUsers']}',
                  icon: Icons.group,
                  color: Colors.blue,
                ),
                _MetricCard(
                  title: 'Verified Users',
                  value: '${stats['verifiedUsers']}',
                  icon: Icons.verified_user,
                  color: Colors.green,
                ),
                _MetricCard(
                  title: 'Students',
                  value: '${stats['students']}',
                  icon: Icons.school,
                  color: Colors.teal,
                ),
                _MetricCard(
                  title: 'Owners',
                  value: '${stats['owners']}',
                  icon: Icons.home_work,
                  color: Colors.purple,
                ),
                _MetricCard(
                  title: 'Providers',
                  value: '${stats['providers']}',
                  icon: Icons.handyman,
                  color: Colors.indigo,
                ),
                _MetricCard(
                  title: 'Pending',
                  value: '${stats['pendingVerifications']}',
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Housing Analytics Section
            _SectionHeader(
              icon: Icons.home,
              title: 'Housing Analytics',
              color: Colors.purple.shade700,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _MetricCard(
                  title: 'Total Properties',
                  value: '${houses.length}',
                  icon: Icons.apartment,
                  color: Colors.purple,
                ),
                _MetricCard(
                  title: 'Available',
                  value: '$availableHouses',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _MetricCard(
                  title: 'Occupied',
                  value: '$occupiedHouses',
                  icon: Icons.home,
                  color: Colors.red,
                ),
                _MetricCard(
                  title: 'Bookings',
                  value: '${bookings.length}',
                  icon: Icons.book_online,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Service Analytics Section
            _SectionHeader(
              icon: Icons.shopping_bag,
              title: 'Service Analytics',
              color: Colors.teal.shade700,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _MetricCard(
                  title: 'Total Services',
                  value: '${services.length}',
                  icon: Icons.room_service,
                  color: Colors.teal,
                ),
                _MetricCard(
                  title: 'Food Services',
                  value: '$foodServices',
                  icon: Icons.restaurant,
                  color: Colors.orange,
                ),
                _MetricCard(
                  title: 'Medicine',
                  value: '$medicineServices',
                  icon: Icons.medical_services,
                  color: Colors.red,
                ),
                _MetricCard(
                  title: 'Furniture',
                  value: '$furnitureServices',
                  icon: Icons.chair,
                  color: Colors.brown,
                ),
                _MetricCard(
                  title: 'Tuition',
                  value: '$tuitionServices',
                  icon: Icons.school,
                  color: Colors.teal.shade700,
                ),
                _MetricCard(
                  title: 'Total Orders',
                  value: '${orders.length}',
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Revenue Analytics Section
            _SectionHeader(
              icon: Icons.monetization_on,
              title: 'Revenue Analytics',
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _MetricCard(
                  title: 'Total Revenue',
                  value: '৳${totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
                _MetricCard(
                  title: 'Avg Order Value',
                  value: '৳${averageOrderValue.toStringAsFixed(0)}',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Platform Health
            _SectionHeader(
              icon: Icons.health_and_safety,
              title: 'Platform Health',
              color: Colors.indigo.shade700,
            ),
            const SizedBox(height: 12),
            _HealthCard(
              title: 'User Verification Rate',
              value: (stats['totalUsers'] ?? 0) > 0
                  ? '${(((stats['verifiedUsers'] ?? 0) / (stats['totalUsers'] ?? 1)) * 100).toStringAsFixed(1)}%'
                  : '0%',
              progress: (stats['totalUsers'] ?? 0) > 0
                  ? ((stats['verifiedUsers'] ?? 0) / (stats['totalUsers'] ?? 1))
                  : 0.0,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _HealthCard(
              title: 'Housing Occupancy Rate',
              value: houses.isNotEmpty
                  ? '${((occupiedHouses / houses.length) * 100).toStringAsFixed(1)}%'
                  : '0%',
              progress: houses.isNotEmpty ? (occupiedHouses / houses.length) : 0.0,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _HealthCard(
              title: 'Service Availability',
              value: services.isNotEmpty
                  ? '${((services.where((s) => s.isAvailable).length / services.length) * 100).toStringAsFixed(1)}%'
                  : '0%',
              progress: services.isNotEmpty
                  ? (services.where((s) => s.isAvailable).length / services.length)
                  : 0.0,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final Color color;

  const _HealthCard({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
