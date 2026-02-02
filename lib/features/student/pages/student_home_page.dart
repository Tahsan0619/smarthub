import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/house_model.dart';
import '../../../core/models/booking_model.dart';
import 'booking_flow_page.dart';
import 'house_detail_page.dart';
import 'all_accommodations_page.dart';
import '../student_dashboard.dart';

class StudentHomePage extends ConsumerStatefulWidget {
  const StudentHomePage({super.key});

  @override
  ConsumerState<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends ConsumerState<StudentHomePage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedFilter;
  
  // Filter state
  RangeValues _rentRange = const RangeValues(20000, 150000);
  double _maxDistance = 10;
  String? _selectedRoomType; // null for all, 'single' or 'shared'
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _bookHouse(HouseModel house) {
    // Navigate to booking flow page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFlowPage(house: house),
      ),
    );
  }

  List<HouseModel> _filterHouses(List<HouseModel> houses) {
    var filtered = houses;
    
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((house) {
        return house.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               house.location.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply rent filter (range)
    filtered = filtered.where((house) {
      return house.rent >= _rentRange.start && house.rent <= _rentRange.end;
    }).toList();
    
    // Apply distance filter
    filtered = filtered.where((house) {
      return house.distance <= _maxDistance;
    }).toList();
    
    // Apply room type filter
    if (_selectedRoomType != null) {
      filtered = filtered.where((house) {
        if (_selectedRoomType == 'single') {
          return house.roomType == 'Single Room';
        } else if (_selectedRoomType == 'shared') {
          return house.roomType == 'Shared Room';
        }
        return true;
      }).toList();
    }
    
    return filtered;
  }

  void _showRentFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Rent Range',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                '৳${_rentRange.start.toInt()} - ৳${_rentRange.end.toInt()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              RangeSlider(
                values: _rentRange,
                min: 10000,
                max: 200000,
                divisions: 38,
                onChanged: (RangeValues newValues) {
                  setModalState(() {
                    _rentRange = newValues;
                  });
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoomTypeFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Room Type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              RadioListTile<String?>(
                title: const Text('All Room Types'),
                value: null,
                groupValue: _selectedRoomType,
                onChanged: (value) {
                  setModalState(() {
                    _selectedRoomType = value;
                  });
                  setState(() {});
                },
              ),
              RadioListTile<String>(
                title: const Text('Single Room'),
                value: 'single',
                groupValue: _selectedRoomType,
                onChanged: (value) {
                  setModalState(() {
                    _selectedRoomType = value;
                  });
                  setState(() {});
                },
              ),
              RadioListTile<String>(
                title: const Text('Shared Room'),
                value: 'shared',
                groupValue: _selectedRoomType,
                onChanged: (value) {
                  setModalState(() {
                    _selectedRoomType = value;
                  });
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDistanceFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Distance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Maximum ${_maxDistance.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Slider(
                value: _maxDistance,
                min: 0.5,
                max: 20,
                divisions: 39,
                label: '${_maxDistance.toStringAsFixed(1)} km',
                onChanged: (double newValue) {
                  setModalState(() {
                    _maxDistance = newValue;
                  });
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allHouses = ref.watch(housesListProvider);
    final houses = _filterHouses(allHouses);
    final savedHousesAsync = ref.watch(savedHousesProvider);
    final savedHouses = savedHousesAsync.value ?? {};
    final allServices = ref.watch(servicesListProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [AppColors.primary, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              '${user?.name.split(' ').first ?? 'Student'}!',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to profile tab (index 3)
                            ref.read(selectedTabProvider.notifier).state = 3;
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            backgroundImage: user?.profileImage != null
                                ? (user!.profileImage!.startsWith('http')
                                    ? NetworkImage(user.profileImage!)
                                    : FileImage(File(user.profileImage!)) as ImageProvider)
                                : null,
                            child: user?.profileImage == null
                                ? const Icon(Icons.person, size: 30)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by area or university',
                          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Featured Accommodations
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Accommodations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllAccommodationsPage(),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              // Featured Houses Horizontal List
              SizedBox(
                height: 220,
                child: allHouses.isEmpty
                    ? Center(
                        child: Text(
                          'No featured properties available',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: allHouses.take(5).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final house = allHouses[index];
                          final isSaved = savedHouses.contains(house.id);
                          return _FeaturedHouseCard(
                            house: house,
                            isSaved: isSaved,
                            onSave: () {
                              ref.read(savedHousesProvider.notifier).toggleSave(house.id);
                            },
                            onBook: () => _bookHouse(house),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        icon: Icons.attach_money,
                        label: 'Rent (৳${_rentRange.start.toInt()}-${_rentRange.end.toInt()})',
                        isSelected: _rentRange.start > 20000 || _rentRange.end < 150000,
                        onTap: () {
                          _showRentFilter();
                        },
                      ),
                      const SizedBox(width: 12),
                      _FilterChip(
                        icon: Icons.bed,
                        label: 'Room: ${_selectedRoomType == null ? 'All' : (_selectedRoomType == 'single' ? 'Single' : 'Shared')}',
                        isSelected: _selectedRoomType != null,
                        onTap: () {
                          _showRoomTypeFilter();
                        },
                      ),
                      const SizedBox(width: 12),
                      _FilterChip(
                        icon: Icons.location_on,
                        label: 'Distance (${_maxDistance.toStringAsFixed(1)} km)',
                        isSelected: _maxDistance < 10,
                        onTap: () {
                          _showDistanceFilter();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Accommodations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${houses.length}/${allHouses.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Houses List - Show filtered results only (no fallback)
              if (houses.isNotEmpty)
                SizedBox(
                  height: 260,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: houses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final house = houses[index];
                      final isSaved = savedHouses.contains(house.id);
                      
                      return SizedBox(
                        width: 240,
                        child: _CompactHouseCard(
                          house: house,
                          isSaved: isSaved,
                          onSave: () {
                            ref.read(savedHousesProvider.notifier).toggleSave(house.id);
                          },
                          onBook: () => _bookHouse(house),
                        ),
                      );
                    },
                  ),
                )
              else
                SizedBox(
                  height: 260,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No accommodations found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HouseCard extends StatelessWidget {
  final HouseModel house;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onBook;

  const _HouseCard({
    required this.house,
    required this.isSaved,
    required this.onSave,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  house.images.first,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.home, size: 80, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: onSave,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '৳${house.rent.toInt()}/mo',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: house.status == 'available'
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        house.status == 'available' ? 'Available Now' : 'Limited Availability',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: house.status == 'available' ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  house.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      house.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.near_me,
                      label: '${house.distanceFromCampus}km from Campus',
                    ),
                    const SizedBox(width: 12),
                    if (house.hasWifi)
                      _InfoChip(
                        icon: Icons.wifi,
                        label: 'WiFi',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FeaturedHouseCard extends StatelessWidget {
  final HouseModel house;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onBook;

  const _FeaturedHouseCard({
    required this.house,
    required this.isSaved,
    required this.onSave,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = house.images.isNotEmpty ? house.images.first : '';
    final isLocalFile = imagePath.isNotEmpty && !imagePath.startsWith('http');
    
    return SizedBox(
      width: 150,
      height: 200,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: isLocalFile
                      ? Image.file(
                          File(imagePath),
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.home, size: 40, color: Colors.grey),
                          ),
                        )
                      : Image.network(
                          imagePath,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.home, size: 40, color: Colors.grey),
                          ),
                        ),
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '৳${house.rent.toInt()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        house.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 10, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '${house.distance.toStringAsFixed(1)} km',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
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
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  iconMap[f] ?? Icons.check,
                                  size: 10,
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                              );
                            }),
                            if (house.facilities.length > 3)
                              Text(
                                '+${house.facilities.length - 3}',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Favorite button
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: onSave,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? Colors.red : Colors.grey,
                    size: 14,
                  ),
                ),
              ),
            ),
            // Book button
            Positioned(
              bottom: 6,
              left: 8,
              right: 8,
              child: SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Book',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _CompactHouseCard extends StatelessWidget {
  final HouseModel house;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onBook;

  const _CompactHouseCard({
    required this.house,
    required this.isSaved,
    required this.onSave,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HouseDetailPage(house: house),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    house.images.first,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.home, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: onSave,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '৳${house.rent.toInt()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          house.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 10, color: AppColors.textSecondary),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${house.distance.toStringAsFixed(1)} km',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton(
                        onPressed: onBook,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Book',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );  // Close InkWell
  }
}

class _ServiceCard extends ConsumerWidget {
  final dynamic service;

  const _ServiceCard({required this.service});

  IconData _getCategoryIcon() {
    final category = service.category.toString().split('.').last.toLowerCase();
    switch (category) {
      case 'food':
        return Icons.fastfood;
      case 'medicine':
        return Icons.medical_services;
      case 'furniture':
        return Icons.chair;
      case 'tuition':
        return Icons.school;
      default:
        return Icons.shopping_bag;
    }
  }

  bool get _isTuition => service.category.toString().split('.').last.toLowerCase() == 'tuition';
  Color get _accentColor => _isTuition ? AppColors.primaryDark : AppColors.primary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewCount = ref.watch(serviceReviewCountProvider(service.id));
    
    return Card(
      elevation: _isTuition ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: _isTuition ? BorderSide(color: AppColors.primaryLight, width: 1) : BorderSide.none,
      ),
      color: _isTuition ? AppColors.primaryLight.withOpacity(0.2) : Colors.white,
      child: InkWell(
        onTap: () {
          // Navigate to service detail page if needed
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: service.images.isNotEmpty
                      ? (service.images.first.startsWith('http')
                          ? Image.network(
                              service.images.first,
                              height: 90,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 90,
                                color: _accentColor.withOpacity(0.1),
                                child: Icon(
                                  _getCategoryIcon(),
                                  size: 30,
                                  color: _accentColor,
                                ),
                              ),
                            )
                          : Image.file(
                              File(service.images.first),
                              height: 90,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 90,
                                color: _accentColor.withOpacity(0.1),
                                child: Icon(
                                  _getCategoryIcon(),
                                  size: 30,
                                  color: _accentColor,
                                ),
                              ),
                            ))
                      : Container(
                          height: 90,
                          color: _accentColor.withOpacity(0.1),
                          child: Icon(
                            _getCategoryIcon(),
                            size: 30,
                            color: _accentColor,
                          ),
                        ),
                ),
                if (_isTuition)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Tuition',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: _isTuition ? AppColors.primaryDark : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              '৳${service.price.toInt()}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.star, size: 10, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${service.rating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '($reviewCount)',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.grey,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        if (service.isAvailable)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 7,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}