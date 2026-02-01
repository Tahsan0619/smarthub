import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/service_model.dart';

class ProviderHomePage extends ConsumerStatefulWidget {
  const ProviderHomePage({super.key});

  @override
  ConsumerState<ProviderHomePage> createState() => _ProviderHomePageState();
}

class _ProviderHomePageState extends ConsumerState<ProviderHomePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allServices = ref.watch(servicesProvider);
    final myServices = allServices.where((s) => s.providerId == user?.id).toList();
    final allOrders = ref.watch(serviceOrdersProvider);
    
    final myOrders = allOrders.isNotEmpty 
      ? allOrders.where((o) {
        return o.items.any((item) => item.service.providerId == user?.id);
      }).toList()
      : <ServiceOrder>[];
    
    final pendingOrders = myOrders.where((o) => o.status == 'pending').length;
    final approvedOrders = myOrders.where((o) => o.status == 'approved').length;
    
    double totalEarnings = 0.0;
    for (final order in myOrders) {
      if (order.status == 'approved') {
        for (final item in order.items ?? []) {
          if (item?.service?.providerId == user?.id) {
            totalEarnings += item?.subtotal ?? 0.0;
          }
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Text(
            'Welcome, ${user?.name ?? 'Provider'}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your services and orders',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Cards - Dynamic
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'My Services',
                  value: myServices.length.toString(),
                  icon: Icons.store,
                  color: AppColors.providerColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Pending Orders',
                  value: pendingOrders.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Approved Orders',
                  value: approvedOrders.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Total Earnings',
                  value: '৳${totalEarnings.toInt()}',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddServiceDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Service'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.providerColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAnalytics(context),
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analytics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Services
          const Text(
            'Recent Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (myServices.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No services yet. Add your first service!',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...myServices.map((service) => _ServiceCard(service: service)),
        ],
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final deliveryController = TextEditingController();
    ServiceCategory selectedCategory = ServiceCategory.food;
    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                if (selectedImage != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(selectedImage!.path),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => setState(() => selectedImage = null),
                          icon: const Icon(Icons.close, color: Colors.white),
                          iconSize: 20,
                        ),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () => _showImageOptions(context, setState, picker, (img) {
                      selectedImage = img;
                    }),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 36,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Service Image',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Camera or Gallery',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (৳)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deliveryController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Time (e.g., 30-45 mins)',
                    prefixIcon: Icon(Icons.schedule),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ServiceCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ServiceCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty && descController.text.isNotEmpty) {
                  final user = ref.read(currentUserProvider);
                  final newService = ServiceModel(
                    id: 's${DateTime.now().millisecondsSinceEpoch}',
                    providerId: user!.id,
                    providerName: user.name,
                    providerPhone: user.phone,
                    name: nameController.text,
                    description: descController.text,
                    price: double.parse(priceController.text),
                    category: selectedCategory,
                    createdAt: DateTime.now(),
                    deliveryTime: deliveryController.text.isNotEmpty ? deliveryController.text : '30-45 mins',
                    rating: 0.0,
                    reviewCount: 0,
                    isAvailable: true,
                    images: selectedImage != null ? [selectedImage!.path] : [],
                  );
                  ref.read(servicesProvider.notifier).addService(newService);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Service added successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.providerColor),
              child: const Text('Add Service'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions(
    BuildContext context,
    StateSetter setState,
    ImagePicker picker,
    Function(XFile) onImageSelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.providerColor),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => onImageSelected(image));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: AppColors.providerColor),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => onImageSelected(image));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalytics(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allServices = ref.watch(servicesProvider);
    final myServices = allServices.where((s) => s.providerId == user?.id).toList();
    final allOrders = ref.watch(serviceOrdersProvider);
    final myOrders = allOrders.where((o) => o.items.any((item) => item.service.providerId == user?.id)).toList();
    
    // Dynamic calculations
    int totalServices = myServices.length;
    int availableServices = myServices.where((s) => s.isAvailable).length;
    int unavailableServices = myServices.where((s) => !s.isAvailable).length;
    int totalOrders = myOrders.length;
    int pendingOrders = myOrders.where((o) => o.status == 'pending').length;
    int completedOrders = myOrders.where((o) => o.status == 'approved').length;
    int cancelledOrders = myOrders.where((o) => o.status == 'cancelled').length;
    
    double totalRevenue = myOrders.fold(0.0, (sum, order) {
      return sum + order.items.where((item) => item.service.providerId == user?.id).fold(0.0, (itemSum, item) => itemSum + item.subtotal);
    });
    
    double avgRating = myServices.isEmpty ? 0 : myServices.fold(0.0, (sum, s) => sum + s.rating) / myServices.length;
    int totalReviews = myServices.fold(0, (sum, s) => sum + s.reviewCount);
    
    // Category breakdown
    Map<String, int> categoryCount = {};
    for (var service in myServices) {
      String catName = service.category.toString().split('.').last;
      categoryCount[catName] = (categoryCount[catName] ?? 0) + 1;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.analytics, color: AppColors.providerColor),
            const SizedBox(width: 8),
            const Text('Analytics Dashboard'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Services Section
              const Text(
                'Services',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _AnalyticsItem('Total Services', totalServices.toString(), Icons.store),
              _AnalyticsItem('Available', availableServices.toString(), Icons.check_circle, color: Colors.green),
              _AnalyticsItem('Unavailable', unavailableServices.toString(), Icons.cancel, color: Colors.red),
              
              const Divider(height: 24),
              
              // Orders Section
              const Text(
                'Orders',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _AnalyticsItem('Total Orders', totalOrders.toString(), Icons.shopping_cart),
              _AnalyticsItem('Pending', pendingOrders.toString(), Icons.pending_actions, color: Colors.orange),
              _AnalyticsItem('Completed', completedOrders.toString(), Icons.check_circle, color: Colors.green),
              _AnalyticsItem('Cancelled', cancelledOrders.toString(), Icons.cancel, color: Colors.red),
              
              const Divider(height: 24),
              
              // Revenue & Ratings
              const Text(
                'Revenue & Ratings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _AnalyticsItem('Total Revenue', '৳${totalRevenue.toInt()}', Icons.trending_up, color: Colors.green),
              _AnalyticsItem('Average Rating', '${avgRating.toStringAsFixed(1)} ⭐', Icons.star, color: Colors.amber),
              _AnalyticsItem('Total Reviews', totalReviews.toString(), Icons.rate_review),
              
              if (categoryCount.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Categories',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categoryCount.entries.map((entry) {
                    return Chip(
                      label: Text('${entry.key} (${entry.value})', style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.providerColor.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.providerColor),
            child: const Text('Close'),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends ConsumerWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () => _showServiceDetails(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: service.images.isNotEmpty
                        ? (service.images.first.startsWith('http')
                            ? Image.network(
                                service.images.first,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.providerColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(service.category),
                                    color: AppColors.providerColor,
                                    size: 32,
                                  ),
                                ),
                              )
                            : Image.file(
                                File(service.images.first),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.providerColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(service.category),
                                    color: AppColors.providerColor,
                                    size: 32,
                                  ),
                                ),
                              ))
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.providerColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(service.category),
                              color: AppColors.providerColor,
                              size: 32,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳${service.price.toInt()} • ${service.category.toString().split('.').last}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (service.deliveryTime != null)
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                service.deliveryTime!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(
                          service.isAvailable ? 'Available' : 'Unavailable',
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: service.isAvailable 
                            ? Colors.green.withOpacity(0.1) 
                            : Colors.red.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: service.isAvailable ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (service.rating > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                '${service.rating.toStringAsFixed(1)} (${service.reviewCount})',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (service.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  service.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.food:
        return Icons.fastfood;
      case ServiceCategory.medicine:
        return Icons.medical_services;
      case ServiceCategory.furniture:
        return Icons.chair;
    }
  }

  void _showServiceDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.providerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(service.category),
                            size: 24,
                            color: AppColors.providerColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '৳${service.price.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.providerColor,
                                  ),
                                ),
                                Text(
                                  service.category.toString().split('.').last,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Chip(
                                label: Text(service.isAvailable ? 'Available' : 'Unavailable'),
                                backgroundColor: service.isAvailable
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: service.isAvailable ? Colors.green : Colors.red,
                                ),
                              ),
                              if (service.rating > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${service.rating.toStringAsFixed(1)} (${service.reviewCount})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(service.description),
                    if (service.deliveryTime != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Delivery Time',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 20, color: AppColors.providerColor),
                          const SizedBox(width: 8),
                          Text(service.deliveryTime!),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditServiceDialog(context, ref);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Service'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.providerColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showDeleteConfirmation(context, ref);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Delete', style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: service.name);
    final priceController = TextEditingController(text: service.price.toInt().toString());
    final descController = TextEditingController(text: service.description);
    final deliveryController = TextEditingController(text: service.deliveryTime ?? '30-45 mins');
    ServiceCategory selectedCategory = service.category;
    String? selectedImagePath;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                if (selectedImagePath != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(selectedImagePath!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 16,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 16),
                            onPressed: () => setState(() => selectedImagePath = null),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (service.images.isNotEmpty)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          service.images.first,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 16,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 16),
                            onPressed: () => setState(() => selectedImagePath = ''),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Change Image'),
                    onPressed: () async {
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() => selectedImagePath = image.path);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (৳)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deliveryController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Time',
                    prefixIcon: Icon(Icons.schedule),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ServiceCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ServiceCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  List<String> updatedImages = service.images;
                  
                  if (selectedImagePath != null && selectedImagePath!.isNotEmpty) {
                    if (!selectedImagePath!.startsWith('http')) {
                      updatedImages = [selectedImagePath!];
                    }
                  } else if (selectedImagePath == '') {
                    updatedImages = [];
                  }
                  
                  final updatedService = service.copyWith(
                    name: nameController.text,
                    price: double.parse(priceController.text),
                    description: descController.text,
                    deliveryTime: deliveryController.text,
                    category: selectedCategory,
                    images: updatedImages,
                  ) ?? service;
                  
                  ref.read(servicesProvider.notifier).updateService(updatedService);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Service updated successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.providerColor),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
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
                  content: Text('Service deleted'),
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

class _AnalyticsItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _AnalyticsItem(this.label, this.value, this.icon, {this.color});

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.providerColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: itemColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: itemColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: itemColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
