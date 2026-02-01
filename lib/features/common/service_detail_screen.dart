import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceName;
  final String category;
  final double price;
  final double rating;

  const ServiceDetailScreen({
    required this.serviceName,
    required this.category,
    required this.price,
    required this.rating,
    super.key,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  int _quantity = 1;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  final List<String> timeSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceInfo(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quantity'),
                  _buildQuantitySelector(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Delivery Date'),
                  _buildDatePicker(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Time Slot'),
                  _buildTimeSlotSelector(),
                  const SizedBox(height: 24),
                  _buildOrderSummary(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showCheckout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
      ),
      child: Center(
        child: Text(
          '🍕',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.serviceName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.category,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.warning, size: 18),
                const SizedBox(width: 4),
                Text(widget.rating.toString()),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Fresh and delicious meals delivered to your doorstep. We ensure quality and timely delivery.',
          style: TextStyle(color: Colors.grey.shade700, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              icon: const Icon(Icons.remove),
            ),
            Text(
              '$_quantity',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => setState(() => _quantity++),
              icon: const Icon(Icons.add),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
        title: Text(
          _selectedDate != null ? DateFormat('MMM d, yyyy').format(_selectedDate!) : 'Select Date',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (date != null) setState(() => _selectedDate = date);
        },
      ),
    );
  }

  Widget _buildTimeSlotSelector() {
    return Wrap(
      spacing: 8,
      children: timeSlots.map((slot) {
        final isSelected = _selectedTimeSlot == slot;
        return FilterChip(
          label: Text(slot),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedTimeSlot = slot),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = widget.price * _quantity;
    const deliveryFee = 50.0;
    final total = subtotal + deliveryFee;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', 'BDT ${subtotal.toStringAsFixed(0)}'),
            const Divider(height: 16),
            _buildSummaryRow('Delivery Fee', 'BDT ${deliveryFee.toStringAsFixed(0)}'),
            const Divider(height: 16),
            _buildSummaryRow(
              'Total',
              'BDT ${total.toStringAsFixed(0)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.primary : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCheckout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CheckoutScreen(
        serviceName: widget.serviceName,
        quantity: _quantity,
        price: widget.price,
      ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  final String serviceName;
  final int quantity;
  final double price;

  const CheckoutScreen({
    required this.serviceName,
    required this.quantity,
    required this.price,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Card';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final total = (widget.price * widget.quantity) + 50;

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOrderItem(),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Items', '${widget.quantity}x ${widget.serviceName}'),
            _buildSummaryRow('Subtotal', 'BDT ${(widget.price * widget.quantity).toStringAsFixed(0)}'),
            _buildSummaryRow('Delivery', 'BDT 50'),
            const Divider(height: 16),
            _buildSummaryRow(
              'Total',
              'BDT ${total.toStringAsFixed(0)}',
              isTotal: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile('Card', Icons.credit_card),
            _buildPaymentMethodTile('Mobile Banking', Icons.phone_android),
            _buildPaymentMethodTile('Cash on Delivery', Icons.payments),
            const SizedBox(height: 20),
            _buildAddressInfo(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _processPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('🍕', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Qty: ${widget.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            'BDT ${(widget.price * widget.quantity).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.primary : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(String method, IconData icon) {
    return RadioListTile<String>(
      value: method,
      groupValue: _selectedPaymentMethod,
      onChanged: (value) => setState(() => _selectedPaymentMethod = value ?? method),
      title: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(method),
        ],
      ),
    );
  }

  Widget _buildAddressInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '123 University Street, Dhaka 1205',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated Delivery: 30-40 mins',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) {
    setState(() => _isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Order placed successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }
}
