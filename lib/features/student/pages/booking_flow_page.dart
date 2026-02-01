import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/house_model.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../student_dashboard.dart'; // Import to access selectedTabProvider

class BookingFlowPage extends ConsumerStatefulWidget {
  final HouseModel house;

  const BookingFlowPage({super.key, required this.house});

  @override
  ConsumerState<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends ConsumerState<BookingFlowPage> {
  int _currentStep = 0;
  DateTime? _moveInDate;
  DateTime? _moveOutDate;
  String? _specialRequests;
  bool _agreedToTerms = false;

  final _requestsController = TextEditingController();

  @override
  void dispose() {
    _requestsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Review details
      case 1:
        return _moveInDate != null; // Move-in date required
      case 2:
        return _agreedToTerms; // Terms agreement required
      case 3:
        return true; // Final confirmation
      default:
        return false;
    }
  }

  void _submitBooking() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final booking = BookingModel(
      id: 'b${DateTime.now().millisecondsSinceEpoch}',
      houseId: widget.house.id,
      studentId: user.id,
      studentName: user.name,
      studentPhone: user.phone,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    // Add booking to state
    ref.read(bookingsProvider.notifier).addBooking(booking);
    
    // Verify it was added
    print('Booking added: ${booking.id} for ${widget.house.title}');
    print('Total bookings: ${ref.read(bookingsProvider).length}');

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 60),
        title: const Text('Application Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your booking request has been sent for approval.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'You can track the status in your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'Booking ID: ${booking.id}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close booking flow page
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('Back to Home'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close booking flow page
              // Switch to profile tab (index 3)
              ref.read(selectedTabProvider.notifier).state = 3;
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('View My Applications'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Accommodation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (index < 3) const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed()
                          ? (_currentStep == 3 ? _submitBooking : _nextStep)
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text(_currentStep == 3 ? 'Submit Application' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildReviewStep();
      case 1:
        return _buildDateSelectionStep();
      case 2:
        return _buildTermsStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1: Review Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please review the accommodation details',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        // House Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.house.images.first,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey.shade300,
              child: const Icon(Icons.home, size: 60),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // House Details
        Text(
          widget.house.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${widget.house.area}, ${widget.house.location}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildDetailCard(
          icon: Icons.attach_money,
          label: 'Monthly Rent',
          value: '৳${widget.house.rent.toStringAsFixed(0)}',
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.bed,
          label: 'Room Type',
          value: widget.house.roomType,
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.location_on,
          label: 'Distance from Campus',
          value: '${widget.house.distanceFromCampus.toStringAsFixed(1)} km',
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.bed,
          label: 'Bedrooms',
          value: '${widget.house.bedrooms} Bedrooms',
        ),
      ],
    );
  }

  Widget _buildDateSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 2: Select Dates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose your preferred move-in date',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        // Move-in Date
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 7)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _moveInDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Move-in Date *',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _moveInDate != null
                            ? '${_moveInDate!.day}/${_moveInDate!.month}/${_moveInDate!.year}'
                            : 'Select date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _moveInDate != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Move-out Date (optional)
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _moveInDate?.add(const Duration(days: 180)) ??
                  DateTime.now().add(const Duration(days: 180)),
              firstDate: _moveInDate ?? DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (date != null) {
              setState(() => _moveOutDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Move-out Date (Optional)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _moveOutDate != null
                            ? '${_moveOutDate!.day}/${_moveOutDate!.month}/${_moveOutDate!.year}'
                            : 'Select date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _moveOutDate != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Special Requests
        const Text(
          'Special Requests (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _requestsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Any special requirements or questions?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) => _specialRequests = value,
        ),
      ],
    );
  }

  Widget _buildTermsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3: Terms & Conditions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please read and accept the terms',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTermItem('Payment must be made within 48 hours of approval'),
              _buildTermItem('Security deposit of 2 months rent is required'),
              _buildTermItem('Minimum stay duration is 6 months'),
              _buildTermItem('Early termination requires 1 month notice'),
              _buildTermItem('Property inspection will be conducted before move-in'),
              _buildTermItem('Utilities may be charged separately'),
              _buildTermItem('House rules must be followed at all times'),
              _buildTermItem('Subletting is not permitted without owner consent'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () {
            setState(() => _agreedToTerms = !_agreedToTerms);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: (value) {
                  setState(() => _agreedToTerms = value ?? false);
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'I have read and agree to the terms and conditions',
                    style: TextStyle(
                      fontSize: 14,
                      color: _agreedToTerms ? AppColors.primary : Colors.black87,
                      fontWeight: _agreedToTerms ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    final user = ref.read(currentUserProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4: Confirmation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Review your application before submitting',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Application Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow('Property', widget.house.title),
              _buildSummaryRow('Monthly Rent', '৳${widget.house.rent.toStringAsFixed(0)}'),
              _buildSummaryRow('Room Type', widget.house.roomType),
              const Divider(height: 24),
              _buildSummaryRow('Student Name', user?.name ?? 'N/A'),
              _buildSummaryRow('Phone', user?.phone ?? 'N/A'),
              _buildSummaryRow('Email', user?.email ?? 'N/A'),
              const Divider(height: 24),
              _buildSummaryRow(
                'Move-in Date',
                _moveInDate != null
                    ? '${_moveInDate!.day}/${_moveInDate!.month}/${_moveInDate!.year}'
                    : 'Not specified',
              ),
              if (_moveOutDate != null)
                _buildSummaryRow(
                  'Move-out Date',
                  '${_moveOutDate!.day}/${_moveOutDate!.month}/${_moveOutDate!.year}',
                ),
              if (_specialRequests != null && _specialRequests!.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Special Requests:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _specialRequests!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your application will be sent to the property owner for review. You will be notified once it\'s approved.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
