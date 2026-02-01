import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

class OwnerProfilePage extends ConsumerWidget {
  const OwnerProfilePage({super.key});

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider)!;
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final companyController = TextEditingController(text: user.address ?? '');
    final addressController = TextEditingController(text: user.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
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
            onPressed: () async {
              final updatedUser = user.copyWith(
                name: nameController.text,
                phone: phoneController.text,
                address: addressController.text.isNotEmpty ? addressController.text : null,
              );
              await ref.read(currentUserProvider.notifier).updateProfile(updatedUser);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.ownerColor),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                    ),
                  ),
                  obscureText: _obscureCurrentPassword,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    ),
                  ),
                  obscureText: _obscureNewPassword,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
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
                if (newPasswordController.text == confirmPasswordController.text) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.ownerColor),
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final allHouses = ref.watch(housesProvider);
    final myHouses = allHouses.where((h) => h.ownerId == user?.id).toList();
    final allBookings = ref.watch(bookingsProvider);
    final myBookings = allBookings.where((b) => myHouses.any((h) => h.id == b.houseId)).toList();
    final activeTenants = myBookings.where((b) => b.status == 'approved').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.ownerColor.withOpacity(0.8), AppColors.ownerColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.home, size: 50, color: AppColors.ownerColor),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Property Owner',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Property Owner',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              Expanded(
                child: _StatContainer(
                  label: 'Properties',
                  value: myHouses.length.toString(),
                  icon: Icons.home,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatContainer(
                  label: 'Tenants',
                  value: activeTenants.toString(),
                  icon: Icons.people,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatContainer(
                  label: 'Bookings',
                  value: myBookings.length.toString(),
                  icon: Icons.bookmark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Contact Information
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.phone,
            label: 'Phone',
            value: user?.phone ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _InfoCard(
            icon: Icons.email,
            label: 'Email',
            value: user?.email ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _InfoCard(
            icon: Icons.location_on,
            label: 'Address',
            value: user?.address ?? 'Not specified',
          ),
          const SizedBox(height: 24),

          // Account Actions
          const Text(
            'Account Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showEditProfileDialog(context, ref),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ownerColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showChangePasswordDialog(context),
              icon: const Icon(Icons.lock),
              label: const Text('Change Password'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(currentUserProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/auth/role', (route) => false);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App Info
          Center(
            child: Text(
              'Smart Hub Owner v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatContainer extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatContainer({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.ownerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.ownerColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.ownerColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.ownerColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
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
