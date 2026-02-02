import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/models/house_model.dart';
import '../../../core/models/service_model.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/models/order_model.dart';

class AdminContentPage extends ConsumerStatefulWidget {
  const AdminContentPage({super.key});

  @override
  ConsumerState<AdminContentPage> createState() => _AdminContentPageState();
}

class _AdminContentPageState extends ConsumerState<AdminContentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final houses = ref.watch(housesListProvider);
    final services = ref.watch(servicesListProvider);
    final bookings = ref.watch(bookingsListProvider);
    final orders = ref.watch(ordersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Houses (${houses.length})'),
            Tab(text: 'Services (${services.length})'),
            Tab(text: 'Bookings (${bookings.length})'),
            Tab(text: 'Orders (${orders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HousesList(houses: houses),
          _ServicesList(services: services),
          _BookingsList(bookings: bookings),
          _OrdersList(orders: orders),
        ],
      ),
    );
  }
}

class _HousesList extends ConsumerWidget {
  final List<HouseModel> houses;

  const _HousesList({required this.houses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (houses.isEmpty) {
      return const Center(child: Text('No houses available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: houses.length,
      itemBuilder: (context, index) {
        final house = houses[index];
        return _HouseCard(house: house);
      },
    );
  }
}

class _HouseCard extends ConsumerWidget {
  final HouseModel house;

  const _HouseCard({required this.house});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: house.images.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(house.images.first),
                    fit: BoxFit.cover,
                  )
                : null,
            color: Colors.grey.shade300,
          ),
          child: house.images.isEmpty ? const Icon(Icons.home) : null,
        ),
        title: Text(house.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('৳${house.rent}/month • ${house.location}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.category, label: 'Room Type', value: house.roomType),
                _InfoRow(icon: Icons.bed, label: 'Bedrooms', value: '${house.bedrooms}'),
                _InfoRow(icon: Icons.bathtub, label: 'Bathrooms', value: '${house.bathrooms}'),
                _InfoRow(icon: Icons.location_on, label: 'Area', value: house.area),
                _InfoRow(icon: Icons.check_circle, label: 'Status', value: house.status.toUpperCase()),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteDialog(context, ref, house),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete House'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, HouseModel house) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete House'),
        content: Text('Are you sure you want to delete "${house.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(housesProvider.notifier).deleteHouse(house.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('House deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ServicesList extends ConsumerWidget {
  final List<ServiceModel> services;

  const _ServicesList({required this.services});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (services.isEmpty) {
      return const Center(child: Text('No services available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _ServiceCard(service: service);
      },
    );
  }
}

class _ServiceCard extends ConsumerWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  Color _getCategoryColor() {
    switch (service.category) {
      case ServiceCategory.food:
        return Colors.orange;
      case ServiceCategory.medicine:
        return Colors.red;
      case ServiceCategory.furniture:
        return Colors.brown;
      case ServiceCategory.tuition:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryColor = _getCategoryColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: service.images.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(service.images.first),
                    fit: BoxFit.cover,
                  )
                : null,
            color: categoryColor.withOpacity(0.1),
          ),
          child: service.images.isEmpty
              ? Icon(Icons.room_service, color: categoryColor)
              : null,
        ),
        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('৳${service.price} • ${service.category.name.toUpperCase()}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.category, label: 'Category', value: service.category.name.toUpperCase()),
                _ServiceRatingInfoRow(service: service),
                _InfoRow(icon: Icons.check_circle, label: 'Status', value: service.isAvailable ? 'Available' : 'Unavailable'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteDialog(context, ref, service),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(servicesProvider.notifier).deleteService(service.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Service deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BookingsList extends ConsumerWidget {
  final List<BookingModel> bookings;

  const _BookingsList({required this.bookings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(booking: booking);
      },
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  Color _getStatusColor() {
    switch (booking.status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final houses = ref.watch(housesListProvider);
    final house = houses.firstWhere((h) => h.id == booking.houseId, orElse: () => houses.first);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(),
          child: const Icon(Icons.book, color: Colors.white),
        ),
        title: Text(house.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Status: ${booking.status.toUpperCase()}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Booked On',
                  value: '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}',
                ),
                _InfoRow(icon: Icons.info, label: 'Status', value: booking.status.toUpperCase()),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteDialog(context, ref, booking),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(bookingsProvider.notifier).deleteBooking(booking.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final List<OrderModel> orders;

  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order);
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  Color _getStatusColor() {
    switch (order.status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(),
          child: const Icon(Icons.shopping_cart, color: Colors.white),
        ),
        title: Text('Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Total: ৳${order.totalPrice} • ${order.status.toUpperCase()}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.shopping_bag, label: 'Quantity', value: '${order.quantity}'),
                _InfoRow(icon: Icons.money, label: 'Total', value: '৳${order.totalPrice}'),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Ordered On',
                  value: '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                ),
                _InfoRow(icon: Icons.info, label: 'Status', value: order.status.toUpperCase()),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteDialog(context, ref, order),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(ordersProvider.notifier).deleteOrder(order.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ServiceRatingInfoRow extends ConsumerWidget {
  final ServiceModel service;

  const _ServiceRatingInfoRow({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewCount = ref.watch(serviceReviewCountProvider(service.id));
    
    return _InfoRow(
      icon: Icons.star,
      label: 'Rating',
      value: '${service.rating} ⭐ ($reviewCount reviews)',
    );
  }
}