import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProviderAnalyticsScreen extends StatelessWidget {
  const ProviderAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildSectionTitle('Revenue Trend'),
            _buildRevenueChart(),
            const SizedBox(height: 20),
            _buildSectionTitle('Top Services'),
            _buildTopServicesTable(),
            const SizedBox(height: 20),
            _buildSectionTitle('Customer Distribution'),
            _buildCustomerStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Orders',
            value: '248',
            icon: Icons.shopping_bag,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Total Revenue',
            value: '₹45,320',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Avg Rating',
            value: '4.8',
            icon: Icons.star,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final revenues = [8000, 12000, 9500, 15000, 18000, 16500];
    final maxRevenue = revenues.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('6 Months Revenue', style: TextStyle(fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '+12% from last month',
                    style: TextStyle(color: AppColors.success, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                months.length,
                (index) {
                  final height = (revenues[index] / maxRevenue) * 100;
                  return Column(
                    children: [
                      Container(
                        width: 30,
                        height: height,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(months[index], style: const TextStyle(fontSize: 12)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopServicesTable() {
    final services = [
      {'name': 'Food Delivery', 'orders': 156, 'revenue': '₹28,500'},
      {'name': 'Medicine Delivery', 'orders': 89, 'revenue': '₹12,300'},
      {'name': 'Furniture Service', 'orders': 3, 'revenue': '₹4,500'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: services.map((service) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${service['orders']} orders',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Text(
                    service['revenue'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomerStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Customers', style: TextStyle(color: Colors.grey.shade600)),
                    const Text('145', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Repeat Customers', style: TextStyle(color: Colors.grey.shade600)),
                    const Text('87%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}

class OwnerAnalyticsScreen extends StatelessWidget {
  const OwnerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildSectionTitle('Booking Trend'),
            _buildBookingChart(),
            const SizedBox(height: 20),
            _buildSectionTitle('Top Properties'),
            _buildTopPropertiesTable(),
            const SizedBox(height: 20),
            _buildSectionTitle('Response Time'),
            _buildResponseStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Bookings',
            value: '56',
            icon: Icons.home,
            color: Colors.teal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Occupancy',
            value: '85%',
            icon: Icons.trending_up,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Avg Rating',
            value: '4.9',
            icon: Icons.star,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingChart() {
    final weeks = ['W1', 'W2', 'W3', 'W4'];
    final bookings = [12, 19, 15, 22];
    final maxBooking = bookings.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Bookings', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                weeks.length,
                (index) {
                  final height = (bookings[index] / maxBooking) * 100;
                  return Column(
                    children: [
                      Container(
                        width: 40,
                        height: height,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(weeks[index], style: const TextStyle(fontSize: 12)),
                      Text(bookings[index].toString(), style: const TextStyle(fontSize: 11)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPropertiesTable() {
    final properties = [
      {'name': 'Downtown Apartment', 'views': 2450, 'bookings': 18},
      {'name': 'Campus View House', 'views': 1890, 'bookings': 14},
      {'name': 'Riverside Studio', 'views': 1230, 'bookings': 8},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: properties.map((prop) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prop['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${prop['views']} views',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${prop['bookings']} bookings',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResponseStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Avg Response Time', style: TextStyle(color: Colors.grey.shade600)),
                    const Text('2.5 hrs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timer, color: AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '✓ Excellent response rate',
                style: TextStyle(color: AppColors.success, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
