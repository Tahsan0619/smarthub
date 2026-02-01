import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/house_model.dart';

class OwnerHomePage extends ConsumerStatefulWidget {
  const OwnerHomePage({super.key});

  @override
  ConsumerState<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends ConsumerState<OwnerHomePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allHouses = ref.watch(housesProvider);
    final myHouses = allHouses.where((h) => h.ownerId == user?.id).toList();
    final allBookings = ref.watch(bookingsProvider);
    final myBookings = allBookings.where((b) =>
      myHouses.any((h) => h.id == b.houseId)
    ).toList();
    
    final pendingBookings = myBookings.where((b) => b.status == 'pending').length;
    final approvedBookings = myBookings.where((b) => b.status == 'approved').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Text(
            'Welcome, ${user?.name ?? 'Owner'}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your properties and bookings',
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
                  title: 'My Properties',
                  value: myHouses.length.toString(),
                  icon: Icons.home,
                  color: AppColors.ownerColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Pending Bookings',
                  value: pendingBookings.toString(),
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
                  title: 'Approved Bookings',
                  value: approvedBookings.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Total Tenants',
                  value: approvedBookings.toString(),
                  icon: Icons.people,
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
                  onPressed: () => _showAddPropertyDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Property'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ownerColor,
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
          
          // Recent Properties
          const Text(
            'Recent Properties',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (myHouses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No properties yet. Add your first property!',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...myHouses.take(5).map((house) => _PropertyCard(house: house)),
        ],
      ),
    );
  }

  void _showAddPropertyDialog(BuildContext context) {
    final titleController = TextEditingController();
    final rentController = TextEditingController();
    final locationController = TextEditingController();
    final areaController = TextEditingController();
    final bedroomsController = TextEditingController();
    final bathroomsController = TextEditingController();
    final descController = TextEditingController();
    final distanceController = TextEditingController();
    String? selectedImagePath;
    final ImagePicker picker = ImagePicker();
    
    // Available facilities with icons
    final Map<String, IconData> availableFacilities = {
      'WiFi': Icons.wifi,
      'AC': Icons.ac_unit,
      'Water Supply': Icons.water_drop,
      'Parking': Icons.local_parking,
      'Security': Icons.security,
      'Generator': Icons.electric_bolt,
      'Gas': Icons.local_fire_department,
      'Laundry': Icons.local_laundry_service,
      'Kitchen': Icons.kitchen,
      'Balcony': Icons.balcony,
      'Lift': Icons.elevator,
      'CCTV': Icons.videocam,
    };
    Set<String> selectedFacilities = {};
    String selectedRoomType = 'Single Room';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Property'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Upload Section
                GestureDetector(
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_camera),
                              title: const Text('Take Photo'),
                              onTap: () async {
                                Navigator.pop(ctx);
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.camera,
                                  maxWidth: 1024,
                                  maxHeight: 1024,
                                  imageQuality: 85,
                                );
                                if (image != null) {
                                  setState(() {
                                    selectedImagePath = image.path;
                                  });
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from Gallery'),
                              onTap: () async {
                                Navigator.pop(ctx);
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1024,
                                  maxHeight: 1024,
                                  imageQuality: 85,
                                );
                                if (image != null) {
                                  setState(() {
                                    selectedImagePath = image.path;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                      border: Border.all(
                        color: selectedImagePath != null 
                            ? AppColors.ownerColor 
                            : Colors.grey.shade300,
                        width: selectedImagePath != null ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: selectedImagePath != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(selectedImagePath!),
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    color: Colors.black54,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Tap to change photo',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, 
                                    size: 50, color: Colors.grey.shade500),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add property photo',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Property Title',
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Rent (৳)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(
                  labelText: 'Area',
                  prefixIcon: Icon(Icons.map),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: bedroomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bedrooms',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: bathroomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bathrooms',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Room Type Selection
              DropdownButtonFormField<String>(
                value: selectedRoomType,
                decoration: const InputDecoration(
                  labelText: 'Room Type',
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                items: const [
                  DropdownMenuItem(value: 'Single Room', child: Text('Single Room')),
                  DropdownMenuItem(value: 'Shared Room', child: Text('Shared Room')),
                  DropdownMenuItem(value: 'Full Apartment', child: Text('Full Apartment')),
                  DropdownMenuItem(value: 'Studio', child: Text('Studio')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRoomType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              // Distance from Campus
              TextField(
                controller: distanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Distance from Campus (km)',
                  prefixIcon: Icon(Icons.straighten),
                  hintText: 'e.g., 1.5',
                ),
              ),
              const SizedBox(height: 16),
              // Facilities Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Facilities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableFacilities.entries.map((entry) {
                  final isSelected = selectedFacilities.contains(entry.key);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          entry.value,
                          size: 16,
                          color: isSelected ? Colors.white : AppColors.ownerColor,
                        ),
                        const SizedBox(width: 4),
                        Text(entry.key),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedFacilities.add(entry.key);
                        } else {
                          selectedFacilities.remove(entry.key);
                        }
                      });
                    },
                    selectedColor: AppColors.ownerColor,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.ownerColor : Colors.grey.shade300,
                      ),
                    ),
                  );
                }).toList(),
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
                if (titleController.text.isNotEmpty && rentController.text.isNotEmpty) {
                  final user = ref.read(currentUserProvider);
                  final newHouse = HouseModel(
                    id: 'h${DateTime.now().millisecondsSinceEpoch}',
                    ownerId: user!.id,
                    ownerName: user.name,
                    ownerPhone: user.phone,
                    title: titleController.text,
                    description: descController.text.isNotEmpty ? descController.text : 'Comfortable property',
                    rent: double.parse(rentController.text),
                    location: locationController.text,
                    area: areaController.text.isNotEmpty ? areaController.text : locationController.text,
                    latitude: 23.8103,
                    longitude: 90.3563,
                    bedrooms: int.tryParse(bedroomsController.text) ?? 2,
                    bathrooms: int.tryParse(bathroomsController.text) ?? 1,
                    images: selectedImagePath != null 
                        ? [selectedImagePath!] 
                        : ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800'],
                    facilities: selectedFacilities.isNotEmpty 
                        ? selectedFacilities.toList() 
                        : ['WiFi'],
                    createdAt: DateTime.now(),
                    distanceFromCampus: double.tryParse(distanceController.text) ?? 1.0,
                    roomType: selectedRoomType,
                    rating: 0.0,
                    reviewCount: 0,
                  );
                  ref.read(housesProvider.notifier).addHouse(newHouse);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Property added successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.ownerColor),
              child: const Text('Add Property'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalytics(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allHouses = ref.watch(housesProvider);
    final myHouses = allHouses.where((h) => h.ownerId == user?.id).toList();
    final allBookings = ref.watch(bookingsProvider);
    final myBookings = allBookings.where((b) => myHouses.any((h) => h.id == b.houseId)).toList();
    
    // Dynamic calculations
    int totalProperties = myHouses.length;
    int availableProperties = myHouses.where((h) => h.status == 'available').length;
    int bookedProperties = myHouses.where((h) => h.status == 'booked').length;
    int totalBookings = myBookings.length;
    int pendingBookings = myBookings.where((b) => b.status == 'pending').length;
    int approvedBookings = myBookings.where((b) => b.status == 'approved').length;
    int rejectedBookings = myBookings.where((b) => b.status == 'rejected').length;
    
    // Calculate estimated monthly revenue from approved bookings
    double monthlyRevenue = 0;
    for (var booking in myBookings.where((b) => b.status == 'approved')) {
      final house = myHouses.firstWhere(
        (h) => h.id == booking.houseId,
        orElse: () => myHouses.first,
      );
      monthlyRevenue += house.rent;
    }
    
    // Calculate ratings
    double avgRating = myHouses.isEmpty ? 0 : myHouses.fold(0.0, (sum, h) => sum + h.rating) / myHouses.length;
    int totalReviews = myHouses.fold(0, (sum, h) => sum + h.reviewCount);
    
    // Calculate occupancy rate
    double occupancyRate = totalProperties > 0 
        ? (bookedProperties / totalProperties) * 100 
        : 0;
    
    // Total facilities count
    int totalFacilities = myHouses.fold(0, (sum, h) => sum + h.facilities.length);
    
    // Popular facilities
    Map<String, int> facilityCount = {};
    for (var house in myHouses) {
      for (var facility in house.facilities) {
        facilityCount[facility] = (facilityCount[facility] ?? 0) + 1;
      }
    }
    List<MapEntry<String, int>> topFacilities = facilityCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.analytics, color: AppColors.ownerColor),
            const SizedBox(width: 8),
            const Text('Analytics Dashboard'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Properties Section
              const Text(
                'Properties',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _AnalyticsItem('Total Properties', totalProperties.toString(), Icons.home),
              _AnalyticsItem('Available', availableProperties.toString(), Icons.check_circle, color: Colors.green),
              _AnalyticsItem('Booked', bookedProperties.toString(), Icons.event_busy, color: Colors.orange),
              _AnalyticsItem('Occupancy Rate', '${occupancyRate.toStringAsFixed(1)}%', Icons.pie_chart, color: Colors.blue),
              
              const Divider(height: 24),
              
              // Bookings Section
              const Text(
                'Bookings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _AnalyticsItem('Total Bookings', totalBookings.toString(), Icons.bookmark),
              _AnalyticsItem('Pending', pendingBookings.toString(), Icons.pending_actions, color: Colors.orange),
              _AnalyticsItem('Approved', approvedBookings.toString(), Icons.check_circle, color: Colors.green),
              _AnalyticsItem('Rejected', rejectedBookings.toString(), Icons.cancel, color: Colors.red),
              
              const Divider(height: 24),
              
              // Revenue Section
              const Text(
                'Revenue & Ratings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _AnalyticsItem('Est. Monthly Revenue', '৳${monthlyRevenue.toInt()}', Icons.attach_money, color: Colors.green),
              _AnalyticsItem('Active Tenants', approvedBookings.toString(), Icons.people, color: Colors.blue),
              _AnalyticsItem('Average Rating', '${avgRating.toStringAsFixed(1)} ⭐', Icons.star, color: Colors.amber),
              _AnalyticsItem('Total Reviews', totalReviews.toString(), Icons.rate_review),
              
              if (topFacilities.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Top Facilities',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: topFacilities.take(5).map((entry) {
                    final iconMap = {
                      'WiFi': Icons.wifi,
                      'AC': Icons.ac_unit,
                      'Water Supply': Icons.water_drop,
                      'Parking': Icons.local_parking,
                      'Security': Icons.security,
                      'Generator': Icons.electric_bolt,
                      'Gas': Icons.local_fire_department,
                      'Laundry': Icons.local_laundry_service,
                      'Kitchen': Icons.kitchen,
                      'Balcony': Icons.balcony,
                      'Lift': Icons.elevator,
                      'CCTV': Icons.videocam,
                    };
                    return Chip(
                      avatar: Icon(iconMap[entry.key] ?? Icons.check, size: 16),
                      label: Text('${entry.key} (${entry.value})', style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.ownerColor.withOpacity(0.1),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.ownerColor),
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

class _PropertyCard extends ConsumerWidget {
  final HouseModel house;

  const _PropertyCard({required this.house});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsProvider);
    final activeTenants = bookings.where((b) => 
      b.houseId == house.id && b.status == 'approved'
    ).length;
    
    final imagePath = house.images.isNotEmpty ? house.images.first : '';
    final isLocalFile = imagePath.isNotEmpty && !imagePath.startsWith('http');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPropertyDetails(context, ref),
        child: Row(
          children: [
            // Property Image
            SizedBox(
              width: 100,
              height: 100,
              child: isLocalFile
                  ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: Icon(Icons.home, color: Colors.grey.shade600, size: 40),
                      ),
                    )
                  : Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: Icon(Icons.home, color: Colors.grey.shade600, size: 40),
                      ),
                    ),
            ),
            // Property Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      house.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '৳${house.rent.toInt()}/mo • ${house.location}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(house.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            house.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(house.status),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$activeTenants 👥',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Facilities preview
                    if (house.facilities.isNotEmpty)
                      Row(
                        children: [
                          ...house.facilities.take(3).map((f) {
                            final iconMap = {
                              'WiFi': Icons.wifi,
                              'AC': Icons.ac_unit,
                              'Water Supply': Icons.water_drop,
                              'Parking': Icons.local_parking,
                              'Security': Icons.security,
                              'Generator': Icons.electric_bolt,
                              'Gas': Icons.local_fire_department,
                              'Laundry': Icons.local_laundry_service,
                              'Kitchen': Icons.kitchen,
                              'Balcony': Icons.balcony,
                              'Lift': Icons.elevator,
                              'CCTV': Icons.videocam,
                            };
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                iconMap[f] ?? Icons.check,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            );
                          }),
                          if (house.facilities.length > 3)
                            Text(
                              '+${house.facilities.length - 3}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // Edit Button
            IconButton(
              onPressed: () => _showEditPropertyDialog(context, ref),
              icon: const Icon(Icons.edit, color: AppColors.ownerColor),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'booked':
        return Colors.red;
      case 'limited':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showPropertyDetails(BuildContext context, WidgetRef ref) {
    final imagePath = house.images.isNotEmpty ? house.images.first : '';
    final isLocalFile = imagePath.isNotEmpty && !imagePath.startsWith('http');
    
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
              // Property Image
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: isLocalFile
                        ? Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.home, size: 80),
                            ),
                          )
                        : Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.home, size: 80),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () => _showEditPropertyDialog(context, ref),
                        icon: const Icon(Icons.edit, color: AppColors.ownerColor),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      house.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(house.location, style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DetailItem('Price', '৳${house.rent.toInt()}/mo'),
                        _DetailItem('Bedrooms', '${house.bedrooms}'),
                        _DetailItem('Bathrooms', '${house.bathrooms}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DetailItem('Room Type', house.roomType),
                        _DetailItem('Distance', '${house.distanceFromCampus} km'),
                        _DetailItem('Status', house.status.toUpperCase()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(house.description),
                    const SizedBox(height: 16),
                    const Text(
                      'Facilities',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: house.facilities.map((f) {
                        final iconMap = {
                          'WiFi': Icons.wifi,
                          'AC': Icons.ac_unit,
                          'Water Supply': Icons.water_drop,
                          'Parking': Icons.local_parking,
                          'Security': Icons.security,
                          'Generator': Icons.electric_bolt,
                          'Gas': Icons.local_fire_department,
                          'Laundry': Icons.local_laundry_service,
                          'Kitchen': Icons.kitchen,
                          'Balcony': Icons.balcony,
                          'Lift': Icons.elevator,
                          'CCTV': Icons.videocam,
                        };
                        return Chip(
                          avatar: Icon(iconMap[f] ?? Icons.check_circle, size: 18, color: AppColors.ownerColor),
                          label: Text(f),
                          backgroundColor: AppColors.ownerColor.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditPropertyDialog(context, ref);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Property'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.ownerColor,
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

  void _showEditPropertyDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: house.title);
    final rentController = TextEditingController(text: house.rent.toInt().toString());
    final locationController = TextEditingController(text: house.location);
    final areaController = TextEditingController(text: house.area);
    final bedroomsController = TextEditingController(text: house.bedrooms.toString());
    final bathroomsController = TextEditingController(text: house.bathrooms.toString());
    final descController = TextEditingController(text: house.description);
    final distanceController = TextEditingController(text: house.distanceFromCampus.toString());
    String? selectedImagePath;
    String currentImageUrl = house.images.isNotEmpty ? house.images.first : '';
    String selectedStatus = house.status;
    String selectedRoomType = house.roomType;
    final ImagePicker picker = ImagePicker();
    
    // Available facilities with icons
    final Map<String, IconData> availableFacilities = {
      'WiFi': Icons.wifi,
      'AC': Icons.ac_unit,
      'Water Supply': Icons.water_drop,
      'Parking': Icons.local_parking,
      'Security': Icons.security,
      'Generator': Icons.electric_bolt,
      'Gas': Icons.local_fire_department,
      'Laundry': Icons.local_laundry_service,
      'Kitchen': Icons.kitchen,
      'Balcony': Icons.balcony,
      'Lift': Icons.elevator,
      'CCTV': Icons.videocam,
    };
    Set<String> selectedFacilities = Set<String>.from(house.facilities);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Property'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Preview with Upload Option
                GestureDetector(
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_camera),
                              title: const Text('Take Photo'),
                              onTap: () async {
                                Navigator.pop(ctx);
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.camera,
                                  maxWidth: 1024,
                                  maxHeight: 1024,
                                  imageQuality: 85,
                                );
                                if (image != null) {
                                  setState(() {
                                    selectedImagePath = image.path;
                                  });
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from Gallery'),
                              onTap: () async {
                                Navigator.pop(ctx);
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1024,
                                  maxHeight: 1024,
                                  imageQuality: 85,
                                );
                                if (image != null) {
                                  setState(() {
                                    selectedImagePath = image.path;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (selectedImagePath != null)
                            Image.file(
                              File(selectedImagePath!),
                              fit: BoxFit.cover,
                            )
                          else if (currentImageUrl.isNotEmpty)
                            Image.network(
                              currentImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.image, size: 50, color: Colors.grey),
                              ),
                            )
                          else
                            const Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.black54,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tap to change photo',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Property Title',
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Rent (৳)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: areaController,
                  decoration: const InputDecoration(
                    labelText: 'Area',
                    prefixIcon: Icon(Icons.map),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bedroomsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bedrooms',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: bathroomsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bathrooms',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'available', child: Text('Available')),
                    DropdownMenuItem(value: 'booked', child: Text('Booked')),
                    DropdownMenuItem(value: 'limited', child: Text('Limited')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Room Type Selection
                DropdownButtonFormField<String>(
                  value: selectedRoomType,
                  decoration: const InputDecoration(
                    labelText: 'Room Type',
                    prefixIcon: Icon(Icons.meeting_room),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Single Room', child: Text('Single Room')),
                    DropdownMenuItem(value: 'Shared Room', child: Text('Shared Room')),
                    DropdownMenuItem(value: 'Full Apartment', child: Text('Full Apartment')),
                    DropdownMenuItem(value: 'Studio', child: Text('Studio')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRoomType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Distance from Campus
                TextField(
                  controller: distanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Distance from Campus (km)',
                    prefixIcon: Icon(Icons.straighten),
                    hintText: 'e.g., 1.5',
                  ),
                ),
                const SizedBox(height: 16),
                // Facilities Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Facilities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableFacilities.entries.map((entry) {
                    final isSelected = selectedFacilities.contains(entry.key);
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            entry.value,
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.ownerColor,
                          ),
                          const SizedBox(width: 4),
                          Text(entry.key),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedFacilities.add(entry.key);
                          } else {
                            selectedFacilities.remove(entry.key);
                          }
                        });
                      },
                      selectedColor: AppColors.ownerColor,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.ownerColor : Colors.grey.shade300,
                        ),
                      ),
                    );
                  }).toList(),
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
                if (titleController.text.isNotEmpty && rentController.text.isNotEmpty) {
                  // For now, store local path. When backend is added, upload to server first
                  List<String> newImages = house.images;
                  if (selectedImagePath != null) {
                    // Store local file path - replace with upload URL when backend is ready
                    newImages = [selectedImagePath!];
                  }
                  
                  final updatedHouse = house.copyWith(
                    title: titleController.text,
                    rent: double.parse(rentController.text),
                    location: locationController.text,
                    area: areaController.text,
                    bedrooms: int.tryParse(bedroomsController.text) ?? house.bedrooms,
                    bathrooms: int.tryParse(bathroomsController.text) ?? house.bathrooms,
                    description: descController.text,
                    status: selectedStatus,
                    images: newImages,
                    facilities: selectedFacilities.toList(),
                    roomType: selectedRoomType,
                    distanceFromCampus: double.tryParse(distanceController.text) ?? house.distanceFromCampus,
                  );
                  ref.read(housesProvider.notifier).updateHouse(updatedHouse);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Property updated successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.ownerColor),
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
        title: const Text('Delete Property'),
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
                  content: Text('Property deleted'),
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

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
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
    final itemColor = color ?? AppColors.ownerColor;
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