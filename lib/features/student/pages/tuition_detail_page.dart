import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/service_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/data_providers.dart';

class TuitionDetailPage extends ConsumerWidget {
  final ServiceModel service;

  const TuitionDetailPage({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceReviewCount = ref.watch(serviceReviewCountProvider(service.id));
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom Tuition App Bar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      service.images.isNotEmpty ? service.images.first : '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primaryLight,
                        child: const Icon(
                          Icons.school,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.primaryDark.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                service.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price per Session',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳${service.price.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${service.rating}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _TuitionReviewCount(service: service),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tutor Info Section
                      Text(
                        'About Your Tutor',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _TutorInfoTile(
                        icon: Icons.person,
                        title: 'Tutor Name',
                        value: service.providerName,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      _TutorInfoTile(
                        icon: Icons.school,
                        title: 'Qualifications',
                        value: service.qualifications ?? 'Not specified',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      _TutorInfoTile(
                        icon: Icons.trending_up,
                        title: 'Experience Level',
                        value: (service.experienceLevel ?? 'intermediate')
                            .replaceFirst(
                              (service.experienceLevel ?? 'intermediate')[0],
                              (service.experienceLevel ?? 'intermediate')[0].toUpperCase(),
                            ),
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),

                      // Course Details
                      Text(
                        'Course Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _TutorInfoTile(
                        icon: Icons.subject,
                        title: 'Subject',
                        value: service.subject ?? 'Not specified',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      _TutorInfoTile(
                        icon: Icons.timer,
                        title: 'Session Duration',
                        value: '${service.sessionDurationMinutes ?? 60} minutes',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),

                      // Availability
                      if (service.availability != null && service.availability!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Days',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: service.availability!.map((day) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.primary),
                                  ),
                                  child: Text(
                                    day,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // Description
                      Text(
                        'About This Course',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          service.description,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.6,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Contact Info
                      Text(
                        'Contact Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _TutorInfoTile(
                        icon: Icons.phone,
                        title: 'Phone',
                        value: service.providerPhone,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(cartProvider.notifier).addToCart(service);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added to cart!'),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Book Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _TutorInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _TuitionReviewCount extends ConsumerWidget {
  final ServiceModel service;

  const _TuitionReviewCount({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewCount = ref.watch(serviceReviewCountProvider(service.id));
    
    return Text(
      '($reviewCount reviews)',
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.green,
      ),
    );
  }
}