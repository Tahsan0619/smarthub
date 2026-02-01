import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  RangeValues _priceRange = const RangeValues(5000, 50000);
  double _distance = 5;
  String _sortBy = 'Newest';
  List<String> _selectedAmenities = [];
  String _roomType = 'Any';

  final List<String> amenities = [
    'WiFi',
    'Air Conditioning',
    'Parking',
    'Laundry',
    'Furnished',
    'Kitchen',
    'Gym',
    'Security',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Search')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Price Range'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BDT ${_priceRange.start.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'BDT ${_priceRange.end.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 100000,
                      onChanged: (values) => setState(() => _priceRange = values),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Room Type'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  children: ['Any', '1 Bed', '2 Bed', '3+ Bed'].map((type) {
                    final isSelected = _roomType == type;
                    return FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _roomType = type),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Amenities'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  children: amenities.map((amenity) {
                    final isSelected = _selectedAmenities.contains(amenity);
                    return FilterChip(
                      label: Text(amenity),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAmenities.add(amenity);
                          } else {
                            _selectedAmenities.remove(amenity);
                          }
                        });
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Distance from Campus'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Up to'),
                        Text(
                          '${_distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _distance,
                      min: 0,
                      max: 20,
                      onChanged: (value) => setState(() => _distance = value),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Sort By'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  items: ['Newest', 'Price: Low to High', 'Price: High to Low', 'Rating', 'Distance']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => _sortBy = value ?? _sortBy),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _priceRange = const RangeValues(5000, 50000);
                        _distance = 5;
                        _sortBy = 'Newest';
                        _selectedAmenities.clear();
                        _roomType = 'Any';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text('Reset', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Search applied successfully'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
