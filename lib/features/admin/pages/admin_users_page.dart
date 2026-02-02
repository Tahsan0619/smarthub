import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/models/user_model.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminUser = ref.watch(currentUserProvider);
    final users = ref.watch(adminUsersProvider);
    
    List<UserModel> filteredUsers = _searchQuery.isEmpty
        ? users
        : ref.read(adminUsersProvider.notifier).searchUsers(_searchQuery);
    
    final allUsers = filteredUsers.where((u) => u.role != 'admin').toList();
    final pendingUsers = filteredUsers.where((u) => !u.isVerified && u.role != 'admin').toList();
    final verifiedUsers = filteredUsers.where((u) => u.isVerified && u.role != 'admin').toList();
    final students = filteredUsers.where((u) => u.role == 'student').toList();
    final owners = filteredUsers.where((u) => u.role == 'owner').toList();
    final providers = filteredUsers.where((u) => u.role == 'provider').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'All (${allUsers.length})'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pending '),
                  if (pendingUsers.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${pendingUsers.length}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
            Tab(text: 'Students (${students.length})'),
            Tab(text: 'Owners (${owners.length})'),
            Tab(text: 'Providers (${providers.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, phone, or NID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // User Lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UserList(users: allUsers, adminUser: adminUser),
                _UserList(users: pendingUsers, adminUser: adminUser, isPending: true),
                _UserList(users: students, adminUser: adminUser),
                _UserList(users: owners, adminUser: adminUser),
                _UserList(users: providers, adminUser: adminUser),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserList extends ConsumerWidget {
  final List<UserModel> users;
  final UserModel? adminUser;
  final bool isPending;

  const _UserList({
    required this.users,
    required this.adminUser,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              isPending ? 'No pending verifications' : 'No users found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserCard(user: user, adminUser: adminUser);
      },
    );
  }
}

class _UserCard extends ConsumerWidget {
  final UserModel user;
  final UserModel? adminUser;

  const _UserCard({required this.user, required this.adminUser});

  Color _getRoleColor() {
    switch (user.role) {
      case 'student':
        return AppColors.studentColor;
      case 'owner':
        return AppColors.ownerColor;
      case 'provider':
        return AppColors.providerColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon() {
    switch (user.role) {
      case 'student':
        return Icons.school;
      case 'owner':
        return Icons.home_work;
      case 'provider':
        return Icons.handyman;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleColor = _getRoleColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.1),
          backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
          child: user.profileImage == null ? Icon(_getRoleIcon(), color: roleColor) : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (user.isVerified)
              const Icon(Icons.verified, color: Colors.green, size: 20)
            else
              const Icon(Icons.pending, color: Colors.orange, size: 20),
          ],
        ),
        subtitle: Text(user.email),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.phone, label: 'Phone', value: user.phone),
                if (user.nid != null) _InfoRow(icon: Icons.badge, label: 'NID', value: user.nid!),
                if (user.address != null) _InfoRow(icon: Icons.location_on, label: 'Address', value: user.address!),
                if (user.university != null) _InfoRow(icon: Icons.school, label: 'University', value: user.university!),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Joined',
                  value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                ),
                _InfoRow(
                  icon: Icons.assignment,
                  label: 'Role',
                  value: user.role.toUpperCase(),
                ),
                _InfoRow(
                  icon: Icons.verified_user,
                  label: 'Status',
                  value: user.isVerified ? 'Verified' : 'Pending Verification',
                ),
                if (user.verifiedAt != null)
                  _InfoRow(
                    icon: Icons.check_circle,
                    label: 'Verified On',
                    value: '${user.verifiedAt!.day}/${user.verifiedAt!.month}/${user.verifiedAt!.year}',
                  ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    if (!user.isVerified)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showVerifyDialog(context, ref, user);
                          },
                          icon: const Icon(Icons.verified_user),
                          label: const Text('Verify User'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showUnverifyDialog(context, ref, user);
                          },
                          icon: const Icon(Icons.remove_circle),
                          label: const Text('Unverify'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showDeleteDialog(context, ref, user);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
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
    );
  }

  void _showVerifyDialog(BuildContext context, WidgetRef ref, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify User'),
        content: Text('Are you sure you want to verify ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(adminUsersProvider.notifier).verifyUser(user.id, adminUser?.id ?? 'admin1');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} has been verified'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _showUnverifyDialog(BuildContext context, WidgetRef ref, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unverify User'),
        content: Text('Are you sure you want to remove verification from ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(adminUsersProvider.notifier).unverifyUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} verification removed'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Unverify'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to permanently delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(adminUsersProvider.notifier).deleteUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} has been deleted'),
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
