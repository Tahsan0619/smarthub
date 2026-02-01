import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

class StudentSavedPage extends ConsumerWidget {
  const StudentSavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedHousesProvider);
    final allHouses = ref.watch(housesProvider);
    final savedHouses = allHouses.where((h) => savedIds.contains(h.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Accommodations'),
      ),
      body: savedHouses.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No saved accommodations',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedHouses.length,
              itemBuilder: (context, index) {
                final house = savedHouses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        house.images.first,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(house.title),
                    subtitle: Text('৳${house.rent.toInt()}/mo'),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        ref.read(savedHousesProvider.notifier).toggleSave(house.id);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
