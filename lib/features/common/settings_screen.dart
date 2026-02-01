import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionTitle('Account'),
          _SettingsTile(
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.verified_user,
            title: 'Verification',
            subtitle: 'Verify your identity',
            onTap: () {},
          ),
          const Divider(),
          const _SectionTitle('Notifications'),
          _NotificationTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive booking and order updates',
          ),
          _NotificationTile(
            icon: Icons.mail,
            title: 'Email Notifications',
            subtitle: 'Receive emails for important updates',
          ),
          _NotificationTile(
            icon: Icons.sms,
            title: 'SMS Alerts',
            subtitle: 'Receive SMS for urgent matters',
          ),
          const Divider(),
          const _SectionTitle('Preferences'),
          _SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Currently: English',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.location_on,
            title: 'Location',
            subtitle: 'Dhaka',
            onTap: () {},
          ),
          const Divider(),
          const _SectionTitle('Help & Support'),
          _SettingsTile(
            icon: Icons.help,
            title: 'Help Center',
            subtitle: 'FAQs and guides',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.bug_report,
            title: 'Report Issue',
            subtitle: 'Tell us what went wrong',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.policy,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ConfirmationDialog(
                    title: 'Delete Account',
                    message: 'Are you sure you want to delete your account? This action cannot be undone.',
                    confirmText: 'Delete',
                    confirmColor: AppColors.error,
                    onConfirm: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account deleted')),
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Delete Account'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _NotificationTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon, color: AppColors.primary),
      title: Text(widget.title),
      subtitle: Text(widget.subtitle),
      trailing: Switch(
        value: _enabled,
        onChanged: (value) => setState(() => _enabled = value),
        activeColor: AppColors.primary,
      ),
    );
  }
}
