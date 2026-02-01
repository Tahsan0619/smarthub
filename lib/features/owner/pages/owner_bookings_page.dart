import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

class OwnerBookingsPage extends ConsumerStatefulWidget {
  const OwnerBookingsPage({super.key});

  @override
  ConsumerState<OwnerBookingsPage> createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends ConsumerState<OwnerBookingsPage> {
  String _selectedStatus = 'all'; // all, pending, approved, rejected

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allHouses = ref.watch(housesProvider);
    final myHouses = allHouses.where((h) => h.ownerId == user?.id).toList();
    final allBookings = ref.watch(bookingsProvider);
    final myBookings = allBookings.where((b) =>
      myHouses.any((h) => h.id == b.houseId)
    ).toList();

    // Filter based on selected status
    final filteredBookings = _selectedStatus == 'all'
        ? myBookings
        : myBookings.where((b) => b.status == _selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
        backgroundColor: AppColors.ownerColor,
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
          // Bookings List
          Expanded(
            child: filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No $_selectedStatus bookings',
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
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      final house = myHouses.firstWhere((h) => h.id == booking.houseId);
                      return _BookingCard(
                        booking: booking,
                        house: house,
                        onApprove: () => _approveBooking(booking),
                        onReject: () => _rejectBooking(booking),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _approveBooking(dynamic booking) {
    ref.read(bookingsProvider.notifier).updateBooking(
      booking.copyWith(status: 'approved'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking approved!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _rejectBooking(dynamic booking) {
    ref.read(bookingsProvider.notifier).updateBooking(
      booking.copyWith(status: 'rejected'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking rejected'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic booking;
  final dynamic house;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _BookingCard({
    required this.booking,
    required this.house,
    required this.onApprove,
    required this.onReject,
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
                        booking.studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booking #${booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id.toUpperCase()}',
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
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Property Info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Property:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    house.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '৳${house.rent.toInt()}/month • ${house.location}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Student Info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Information:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(booking.studentName, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(booking.studentPhone, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Booking Date
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Applied: ${DateFormat('MMM dd, yyyy - hh:mm a').format(booking.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),

            if (booking.status == 'pending') ...[
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
                        backgroundColor: AppColors.ownerColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ] else if (booking.status == 'approved') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This booking has been approved. The student is your tenant.',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                  ],
                ),
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
          color: isSelected ? AppColors.ownerColor : Colors.grey.shade200,
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
