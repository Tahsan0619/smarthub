import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FAQItem(
              question: 'How do I book a house?',
              answer: 'Browse available houses, click "Book Now", fill in your details, and submit your request. The owner will review and approve or decline your booking.',
            ),
            _FAQItem(
              question: 'Can I cancel my booking?',
              answer: 'Yes, you can cancel your booking anytime. However, cancellation fees may apply based on the cancellation policy.',
            ),
            _FAQItem(
              question: 'How do I report a property?',
              answer: 'If you find inappropriate content, click the report button on the property page and describe the issue.',
            ),
            _FAQItem(
              question: 'How do payments work?',
              answer: 'We support cash on delivery, card payments, and mobile banking. Choose your preferred method during checkout.',
            ),
            _FAQItem(
              question: 'What if I have a dispute?',
              answer: 'Contact our support team immediately with details. We will review and help resolve the issue.',
            ),
            _FAQItem(
              question: 'How do I list my property?',
              answer: 'For owners: Go to your dashboard, click "Add Property", fill in details, upload photos, and publish.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Still need help?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Support',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text('Email: support@smarthub.com'),
                    const Text('Phone: +880 1234-567890'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Send Message'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.answer,
              style: TextStyle(color: Colors.grey.shade700, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
