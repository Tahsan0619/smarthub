import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/models/house_model.dart';
import 'house_detail_page.dart';

class AllAccommodationsPage extends ConsumerStatefulWidget {
  const AllAccommodationsPage({super.key});

  @override
  ConsumerState<AllAccommodationsPage> createState() => _AllAccommodationsPageState();
}

class _AllAccommodationsPageState extends ConsumerState<AllAccommodationsPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'default';
  RangeValues? _priceRange;
  
  final List<String> _filters = ['All', 'Available', 'Single Room', 'Shared Room'];
  final List<String> _sortOptions = ['default', 'price_low', 'price_high', 'rating', 'newest'];

  @override
  Widget build(BuildContext context) {
    final allHouses = ref.watch(housesListProvider);
    final savedHousesAsync = ref.watch(savedHousesProvider);
    final savedHouses = savedHousesAsync.value ?? {};
    
    // Calculate dynamic price range from actual house data
    final maxRent = allHouses.isEmpty 
        ? 100000.0 
        : allHouses.map((h) => h.rent).reduce((a, b) => a > b ? a : b);
    final minRent = allHouses.isEmpty 
        ? 0.0 
        : allHouses.map((h) => h.rent).reduce((a, b) => a < b ? a : b);
    
    // Initialize price range if not set
    _priceRange ??= RangeValues(minRent, maxRent);
    
    // Apply filters
    List<HouseModel> filteredHouses = allHouses.where((house) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!house.title.toLowerCase().contains(query) &&
            !house.location.toLowerCase().contains(query) &&
            !house.area.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Status/Type filter
      if (_selectedFilter == 'Available' && house.status != 'available') {
        return false;
      }
      if (_selectedFilter == 'Single Room' && house.roomType != 'Single Room') {
        return false;
      }
      if (_selectedFilter == 'Shared Room' && house.roomType != 'Shared Room') {
        return false;
      }
      
      // Price filter (only apply if user has adjusted it)
      if (_priceRange != null && 
          (house.rent < _priceRange!.start || house.rent > _priceRange!.end)) {
        return false;
      }
      
      return true;
    }).toList();
    
    // Apply sorting
    switch (_sortBy) {
      case 'price_low':
        filteredHouses.sort((a, b) => a.rent.compareTo(b.rent));
        break;
      case 'price_high':
        filteredHouses.sort((a, b) => b.rent.compareTo(a.rent));
        break;
      case 'rating':
        filteredHouses.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
        filteredHouses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Accommodations'),
        backgroundColor: AppColors.studentColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.studentColor.withOpacity(0.1),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by location, area, or title...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = filter);
                  },
                  selectedColor: AppColors.studentColor.withOpacity(0.2),
                  checkmarkColor: AppColors.studentColor,
                );
              },
            ),
          ),
          
          // Results count and sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredHouses.length} properties found',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.sort, size: 20),
                  items: const [
                    DropdownMenuItem(value: 'default', child: Text('Default')),
                    DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                    DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                    DropdownMenuItem(value: 'newest', child: Text('Newest')),
                  ],
                  onChanged: (value) {
                    setState(() => _sortBy = value!);
                  },
                ),
              ],
            ),
          ),
          
          // Houses List
          Expanded(
            child: filteredHouses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_work_outlined, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No properties found',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredHouses.length,
                    itemBuilder: (context, index) {
                      final house = filteredHouses[index];
                      final isSaved = savedHouses.contains(house.id);
                      return _HouseCard(
                        house: house,
                        isSaved: isSaved,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HouseDetailPage(house: house),
                            ),
                          );
                        },
                        onSave: () {
                          ref.read(savedHousesProvider.notifier).toggleSave(house.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final allHouses = ref.read(housesListProvider);
    final maxRent = allHouses.isEmpty 
        ? 100000.0 
        : allHouses.map((h) => h.rent).reduce((a, b) => a > b ? a : b);
    final minRent = allHouses.isEmpty 
        ? 0.0 
        : allHouses.map((h) => h.rent).reduce((a, b) => a < b ? a : b);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                'Filter & Sort',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Price Range (৳)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              RangeSlider(
                values: _priceRange ?? RangeValues(minRent, maxRent),
                min: minRent,
                max: maxRent,
                divisions: 50,
                labels: RangeLabels(
                  '৳${(_priceRange?.start ?? minRent).round()}',
                  '৳${(_priceRange?.end ?? maxRent).round()}',
                ),
                activeColor: AppColors.studentColor,
                onChanged: (values) {
                  setModalState(() => _priceRange = values);
                },
              ),
              Text(
                '৳${(_priceRange?.start ?? minRent).round()} - ৳${(_priceRange?.end ?? maxRent).round()}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _priceRange = RangeValues(minRent, maxRent);
                        });
                        setState(() {
                          _priceRange = const RangeValues(0, 50000);
                          _selectedFilter = 'All';
                          _sortBy = 'default';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.studentColor,
                      ),
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
}

class _HouseCard extends ConsumerWidget {
  final HouseModel house;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const _HouseCard({
    required this.house,
    required this.isSaved,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewCount = ref.watch(houseReviewCountProvider(house.id));
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    image: house.images.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(house.images.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: house.images.isEmpty
                      ? const Center(child: Icon(Icons.home, size: 50, color: Colors.grey))
                      : null,
                ),
                // Status Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: house.status == 'available' ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      house.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Save Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : Colors.grey,
                        size: 20,
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
                    children: [
                      Expanded(
                        child: Text(
                          house.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            house.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviewCount)',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${house.area}, ${house.location}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoChip(icon: Icons.bed, text: '${house.bedrooms} Bed'),
                      const SizedBox(width: 8),
                      _InfoChip(icon: Icons.bathtub, text: '${house.bathrooms} Bath'),
                      const SizedBox(width: 8),
                      _InfoChip(icon: Icons.meeting_room, text: house.roomType),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '৳${house.rent.toStringAsFixed(0)}/month',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.studentColor,
                        ),
                      ),
                      if (house.hasWifi)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.wifi, size: 14, color: Colors.blue.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'WiFi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
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
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
