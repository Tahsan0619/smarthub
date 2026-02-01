import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int _currentStep = 0;
  bool _emailVerified = true;
  bool _phoneVerified = true;
  bool _idVerified = false;
  bool _universityVerified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVerificationProgress(),
            const SizedBox(height: 24),
            _buildSectionTitle('Verification Status'),
            _buildVerificationItem('Email', _emailVerified),
            _buildVerificationItem('Phone', _phoneVerified),
            _buildVerificationItem('Identity (NID/Passport)', _idVerified),
            _buildVerificationItem('University (Student)', _universityVerified),
            const SizedBox(height: 24),
            _buildSectionTitle('Benefits of Full Verification'),
            _buildBenefit('Access all premium features'),
            _buildBenefit('Higher trust score'),
            _buildBenefit('Priority customer support'),
            _buildBenefit('Increased booking limits'),
            const SizedBox(height: 24),
            if (!_idVerified)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showIDVerificationDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Verify Identity'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            if (!_universityVerified)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showUniversityVerificationDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Verify University'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationProgress() {
    final verifiedCount = [_emailVerified, _phoneVerified, _idVerified, _universityVerified]
        .where((v) => v)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verification Progress',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$verifiedCount of 4 completed',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(verifiedCount / 4 * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: verifiedCount / 4,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationItem(String name, bool verified) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: verified
            ? const Icon(Icons.verified, color: AppColors.success)
            : const Icon(Icons.pending, color: AppColors.warning),
        title: Text(name),
        subtitle: Text(verified ? 'Verified' : 'Not verified'),
        trailing: verified
            ? VerificationBadge()
            : Text(
                'Pending',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
      ),
    );
  }

  Widget _buildBenefit(String benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Text(benefit),
        ],
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

  void _showIDVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Identity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please upload a clear photo of your:'),
            const SizedBox(height: 12),
            _buildDocumentOption('National ID (NID)', Icons.credit_card),
            _buildDocumentOption('Passport', Icons.travel_explore),
            _buildDocumentOption('Driving License', Icons.drive_eta),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _idVerified = true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Identity verified successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _showUniversityVerificationDialog(BuildContext context) {
    final universityController = TextEditingController();
    final studentIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify University'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: universityController,
              decoration: const InputDecoration(
                labelText: 'University Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload your student ID card or university certificate',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _universityVerified = true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('University verified successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentOption(String name, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(name),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<_EmergencyContact> contacts = [
    _EmergencyContact(
      id: '1',
      name: 'Mom',
      phone: '+880 1234-567890',
      relation: 'Mother',
    ),
    _EmergencyContact(
      id: '2',
      name: 'Dad',
      phone: '+880 9876-543210',
      relation: 'Father',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddContactDialog(context),
          ),
        ],
      ),
      body: contacts.isEmpty
          ? EmptyState(
              icon: Icons.emergency,
              title: 'No Emergency Contacts',
              subtitle: 'Add contacts who can be reached in case of emergency',
              buttonText: 'Add Contact',
              onButtonPressed: () => _showAddContactDialog(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return _ContactCard(
                  contact: contact,
                  onDelete: () {
                    setState(() => contacts.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact deleted')),
                    );
                  },
                  onEdit: () => _showEditContactDialog(context, index),
                );
              },
            ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRelation = 'Family Member';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRelation,
                decoration: const InputDecoration(
                  labelText: 'Relation',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Mother',
                  'Father',
                  'Sister',
                  'Brother',
                  'Friend',
                  'Family Member',
                  'Other'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => selectedRelation = value ?? selectedRelation,
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
              setState(() {
                contacts.add(
                  _EmergencyContact(
                    id: DateTime.now().toString(),
                    name: nameController.text,
                    phone: phoneController.text,
                    relation: selectedRelation,
                  ),
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact added')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(BuildContext context, int index) {
    final contact = contacts[index];
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phone);
    String selectedRelation = contact.relation;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Emergency Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRelation,
                decoration: const InputDecoration(
                  labelText: 'Relation',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Mother',
                  'Father',
                  'Sister',
                  'Brother',
                  'Friend',
                  'Family Member',
                  'Other'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => selectedRelation = value ?? selectedRelation,
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
              setState(() {
                contacts[index] = _EmergencyContact(
                  id: contact.id,
                  name: nameController.text,
                  phone: phoneController.text,
                  relation: selectedRelation,
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact updated')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final _EmergencyContact contact;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ContactCard({
    required this.contact,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            contact.name[0].toUpperCase(),
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(contact.phone),
            Text(contact.relation, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: onEdit,
            ),
            PopupMenuItem(
              child: const Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relation;

  _EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });
}
