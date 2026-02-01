import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  String _selectedFilter = 'All';

  final List<_Complaint> complaints = [
    _Complaint(
      id: '1',
      title: 'Property Not As Described',
      description: 'The house condition is worse than shown in photos',
      status: 'Open',
      priority: 'High',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _Complaint(
      id: '2',
      title: 'Rude Behavior',
      description: 'Owner was rude during property viewing',
      status: 'In Review',
      priority: 'Medium',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    _Complaint(
      id: '3',
      title: 'Service Not Delivered',
      description: 'Food delivery was not completed',
      status: 'Resolved',
      priority: 'Medium',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<_Complaint> get filteredComplaints {
    if (_selectedFilter == 'All') return complaints;
    return complaints.where((c) => c.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showComplaintDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'All',
                  onTap: () => setState(() => _selectedFilter = 'All'),
                ),
                _FilterChip(
                  label: 'Open',
                  isSelected: _selectedFilter == 'Open',
                  onTap: () => setState(() => _selectedFilter = 'Open'),
                ),
                _FilterChip(
                  label: 'In Review',
                  isSelected: _selectedFilter == 'In Review',
                  onTap: () => setState(() => _selectedFilter = 'In Review'),
                ),
                _FilterChip(
                  label: 'Resolved',
                  isSelected: _selectedFilter == 'Resolved',
                  onTap: () => setState(() => _selectedFilter = 'Resolved'),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredComplaints.isEmpty
                ? EmptyState(
                    icon: Icons.check_circle,
                    title: 'No Complaints',
                    subtitle: 'You have no complaints with this status',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredComplaints.length,
                    itemBuilder: (context, index) {
                      return _ComplaintCard(
                        complaint: filteredComplaints[index],
                        onTap: () => _showComplaintDetails(context, filteredComplaints[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showComplaintDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Property Issue';
    String selectedPriority = 'Medium';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File a Complaint'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Complaint Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ['Property Issue', 'Service Issue', 'Behavior', 'Payment', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => selectedCategory = value ?? selectedCategory,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: ['Low', 'Medium', 'High']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => selectedPriority = value ?? selectedPriority,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Describe the issue in detail',
                ),
                maxLines: 4,
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Complaint filed successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showComplaintDetails(BuildContext context, _Complaint complaint) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      complaint.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatusBadge(
                      status: complaint.status,
                      backgroundColor: _getStatusColor(complaint.status),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(complaint.priority).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Priority: ${complaint.priority}',
                        style: TextStyle(
                          color: _getPriorityColor(complaint.priority),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(complaint.description),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submitted: ${DateFormat('MMM d, yyyy HH:mm').format(complaint.createdAt)}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      Text(
                        'Last Update: ${DateFormat('MMM d, yyyy HH:mm').format(complaint.updatedAt)}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.warning;
      case 'In Review':
        return AppColors.info;
      case 'Resolved':
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final _Complaint complaint;
  final VoidCallback onTap;

  const _ComplaintCard({
    required this.complaint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          complaint.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              complaint.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusBadge(
                  status: complaint.status,
                  backgroundColor: _getStatusColor(complaint.status),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(complaint.priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    complaint.priority,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getPriorityColor(complaint.priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.warning;
      case 'In Review':
        return AppColors.info;
      case 'Resolved':
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _Complaint {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  _Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });
}
