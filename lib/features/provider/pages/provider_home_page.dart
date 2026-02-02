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
    final allServices = ref.watch(servicesListProvider);
    final myServices = allServices.where((s) => s.providerId == user?.id).toList();
    final allOrders = ref.watch(ordersListProvider);
    
    final myOrders = allOrders.isNotEmpty 
      ? allOrders.where((o) => o.providerId == user?.id).toList()
      : <dynamic>[];
    
    final pendingOrders = myOrders.where((o) => o.status == 'pending').length;
    final approvedOrders = myOrders.where((o) => o.status == 'approved').length;
    
    double totalEarnings = 0.0;
    for (final order in myOrders) {
      if (order.status == 'approved') {
        totalEarnings += (order.price * order.quantity);
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
                  onPressed: () => _showAddTuitionDialog(context, ref),
                  icon: const Icon(Icons.school),
                  label: const Text('Add Tuition'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
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
                  items: ServiceCategory.values
                      .where((cat) => cat != ServiceCategory.tuition)
                      .map((cat) {
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
                  ref.read(servicesProvider.notifier).addService(newService, user.id);
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

  void _showAddTuitionDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final subjectController = TextEditingController();
    final qualificationsController = TextEditingController();
    final durationController = TextEditingController(text: '60');
    String selectedExperience = 'intermediate';
    List<String> selectedDays = [];
    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.school, color: Colors.purple.shade600),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Add New Tuition Service',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
                          color: Colors.purple.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.purple.shade50,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            size: 36,
                            color: Colors.purple.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Tuition Cover',
                            style: TextStyle(
                              color: Colors.purple.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Camera or Gallery',
                            style: TextStyle(
                              color: Colors.purple.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Tuition specific fields
                Text(
                  'Course Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: const Icon(Icons.book),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject/Topic',
                    prefixIcon: const Icon(Icons.subject),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price per Session (৳)',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Duration (minutes)',
                          prefixIcon: const Icon(Icons.timer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Course Description',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Tutor Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: qualificationsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Your Qualifications',
                    prefixIcon: const Icon(Icons.school),
                    hintText: 'e.g., B.Sc Mathematics, Teaching Certified',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  value: selectedExperience,
                  decoration: InputDecoration(
                    labelText: 'Experience Level',
                    prefixIcon: const Icon(Icons.trending_up),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedExperience = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Available Days',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                      .map((day) {
                    final isSelected = selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDays.add(day);
                          } else {
                            selectedDays.remove(day);
                          }
                        });
                      },
                      backgroundColor: Colors.purple.shade50,
                      selectedColor: Colors.purple.shade200,
                    );
                  }).toList(),
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
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    subjectController.text.isNotEmpty &&
                    descController.text.isNotEmpty) {
                  final user = ref.read(currentUserProvider);
                  final newService = ServiceModel(
                    id: 't${DateTime.now().millisecondsSinceEpoch}',
                    providerId: user!.id,
                    providerName: user.name,
                    providerPhone: user.phone,
                    name: nameController.text,
                    description: descController.text,
                    price: double.parse(priceController.text),
                    category: ServiceCategory.tuition,
                    createdAt: DateTime.now(),
                    deliveryTime: 'Flexible scheduling',
                    rating: 0.0,
                    reviewCount: 0,
                    isAvailable: true,
                    images: selectedImage != null ? [selectedImage!.path] : [],
                    subject: subjectController.text,
                    qualifications: qualificationsController.text,
                    experienceLevel: selectedExperience,
                    sessionDurationMinutes: int.tryParse(durationController.text) ?? 60,
                    availability: selectedDays,
                  );
                  ref.read(servicesProvider.notifier).addService(newService, user.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Tuition service added successfully!'),
                      backgroundColor: Colors.purple.shade600,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
              ),
              child: const Text('Add Tuition'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalytics(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allServices = ref.watch(servicesListProvider);
    final myServices = allServices.where((s) => s.providerId == user?.id).toList();
    final allOrders = ref.watch(ordersListProvider);
    final myOrders = allOrders.where((o) => o.providerId == user?.id).toList();
    
    // Dynamic calculations
    int totalServices = myServices.length;
    int availableServices = myServices.where((s) => s.isAvailable).length;
    int unavailableServices = myServices.where((s) => !s.isAvailable).length;
    int totalOrders = myOrders.length;
    int pendingOrders = myOrders.where((o) => o.status == 'pending').length;
    int completedOrders = myOrders.where((o) => o.status == 'approved').length;
    int cancelledOrders = myOrders.where((o) => o.status == 'cancelled').length;
    
    double totalRevenue = myOrders.fold(0.0, (sum, order) {
      return sum + (order.price * order.quantity);
    });
    
    double avgRating = myServices.isEmpty ? 0 : myServices.fold(0.0, (sum, s) => sum + s.rating) / myServices.length;
    final allReviews = ref.watch(reviewsListProvider);
    int totalReviews = allReviews.where((r) => myServices.any((s) => s.id == r.serviceId)).length;
    
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
    final isTuition = service.category == ServiceCategory.tuition;
    final cardColor = isTuition ? AppColors.primaryLight.withOpacity(0.2) : Colors.white;
    final borderColor = isTuition ? AppColors.primaryLight : Colors.grey.shade200;
    final iconColor = isTuition ? AppColors.primaryDark : AppColors.providerColor;
    final accentColor = isTuition ? AppColors.primaryDark : AppColors.providerColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isTuition ? 2 : 1,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
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
                                    color: iconColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(service.category),
                                    color: iconColor,
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
                                    color: iconColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(service.category),
                                    color: iconColor,
                                    size: 32,
                                  ),
                                ),
                              ))
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(service.category),
                              color: iconColor,
                              size: 32,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isTuition ? AppColors.primaryDark : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isTuition)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade600,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Tuition',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳${service.price.toInt()}',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isTuition && service.subject != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            service.subject!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (isTuition && service.experienceLevel != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_half, size: 14, color: AppColors.primaryDark),
                      const SizedBox(width: 4),
                      Text(
                        service.experienceLevel!
                            .replaceFirst(
                              service.experienceLevel![0],
                              service.experienceLevel![0].toUpperCase(),
                            ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (service.images.isNotEmpty && service.images.first.startsWith('http'))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      service.images.first,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  service.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '৳${service.price.toInt()}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    if (service.rating > 0)
                      _ServiceRatingRow(service: service),
                  ],
                ),
                const SizedBox(height: 20),
                if (service.category == ServiceCategory.tuition && service.subject != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Subject: ${service.subject}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (service.qualifications != null)
                          Text('Qualifications: ${service.qualifications}', style: const TextStyle(fontSize: 12)),
                        if (service.sessionDurationMinutes != null)
                          Text('Duration: ${service.sessionDurationMinutes} mins', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Edit and Delete buttons
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
      case ServiceCategory.tuition:
        return Icons.school;
    }
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
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
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
                  items: ServiceCategory.values
                      .where((cat) => cat != ServiceCategory.tuition)
                      .map((cat) {
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
class _ServiceRatingRow extends ConsumerWidget {
  final ServiceModel service;

  const _ServiceRatingRow({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewCount = ref.watch(serviceReviewCountProvider(service.id));
    
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: Colors.amber),
        Text(
          '${service.rating.toStringAsFixed(1)} ($reviewCount)',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}