import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/theme/app_colors.dart';

class ProviderOrdersPage extends ConsumerStatefulWidget {
  const ProviderOrdersPage({super.key});

  @override
  ConsumerState<ProviderOrdersPage> createState() => _ProviderOrdersPageState();
}

class _ProviderOrdersPageState extends ConsumerState<ProviderOrdersPage> {
  String _selectedStatus = 'all'; // all, pending, approved, rejected

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allOrders = ref.watch(serviceOrdersProvider);
    
    final myOrders = allOrders.isNotEmpty
      ? allOrders.where((o) {
        return o.items.any((item) => item.service.providerId == user?.id);
      }).toList()
      : <ServiceOrder>[];

    // Filter based on selected status
    final filteredOrders = _selectedStatus == 'all'
        ? myOrders
        : myOrders.where((o) => o.status == _selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: AppColors.providerColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedStatus == 'all',
                  onTap: () => setState(() => _selectedStatus = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  isSelected: _selectedStatus == 'pending',
                  onTap: () => setState(() => _selectedStatus = 'pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Approved',
                  isSelected: _selectedStatus == 'approved',
                  onTap: () => setState(() => _selectedStatus = 'approved'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Rejected',
                  isSelected: _selectedStatus == 'rejected',
                  onTap: () => setState(() => _selectedStatus = 'rejected'),
                ),
              ],
            ),
          ),
          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No $_selectedStatus orders',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _OrderCard(
                        order: order,
                        onApprove: () => _approveOrder(order),
                        onReject: () => _rejectOrder(order),
                        providerId: user!.id,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _approveOrder(dynamic order) {
    ref.read(serviceOrdersProvider.notifier).updateOrder(
      order.copyWith(status: 'approved'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order approved!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _rejectOrder(dynamic order) {
    ref.read(serviceOrdersProvider.notifier).updateOrder(
      order.copyWith(status: 'rejected'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order rejected'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String providerId;

  const _OrderCard({
    required this.order,
    required this.onApprove,
    required this.onReject,
    required this.providerId,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final relevantItems = order.items
        .where((item) => item.service.providerId == providerId)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student: ${order.studentName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order Date
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Items
            const Text(
              'Items:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...relevantItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.service.name,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'x${item.quantity}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '৳${item.subtotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '৳${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.providerColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Contact Info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    order.studentPhone,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            if (order.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.providerColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.providerColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
