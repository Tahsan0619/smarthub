import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// Loading Shimmer
class ShimmerLoading extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
              stops: [0.0, _controller.value, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// Error Display Card
class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorCard({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom App Bar with search
class SmartHubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final Function(String)? onSearch;
  final Color? backgroundColor;
  final List<Widget>? actions;

  const SmartHubAppBar({
    super.key,
    required this.title,
    this.showSearch = false,
    this.onSearch,
    this.backgroundColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: 0,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

// Rating Bar
class RatingBar extends StatefulWidget {
  final double initialRating;
  final Function(double)? onRatingChanged;
  final int itemCount;
  final double itemSize;
  final bool allowHalfRating;

  const RatingBar({
    super.key,
    this.initialRating = 0,
    this.onRatingChanged,
    this.itemCount = 5,
    this.itemSize = 40,
    this.allowHalfRating = true,
  });

  @override
  State<RatingBar> createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        widget.itemCount,
        (index) {
          return GestureDetector(
            onTap: () {
              setState(() => _rating = (index + 1).toDouble());
              widget.onRatingChanged?.call(_rating);
            },
            child: Icon(
              Icons.star,
              size: widget.itemSize,
              color: index < _rating ? Colors.amber : Colors.grey[300],
            ),
          );
        },
      ),
    );
  }
}

// Status Badge
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
  });

  Color _getBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'available':
        return backgroundColor ?? AppColors.success.withOpacity(0.1);
      case 'pending':
        return backgroundColor ?? AppColors.warning.withOpacity(0.1);
      case 'approved':
        return backgroundColor ?? AppColors.success.withOpacity(0.1);
      case 'rejected':
        return backgroundColor ?? AppColors.error.withOpacity(0.1);
      default:
        return backgroundColor ?? Colors.grey.withOpacity(0.1);
    }
  }

  Color _getTextColor() {
    switch (status.toLowerCase()) {
      case 'available':
        return textColor ?? AppColors.success;
      case 'pending':
        return textColor ?? AppColors.warning;
      case 'approved':
        return textColor ?? AppColors.success;
      case 'rejected':
        return textColor ?? AppColors.error;
      default:
        return textColor ?? Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getTextColor(),
        ),
      ),
    );
  }
}

// Verification Badge
class VerificationBadge extends StatelessWidget {
  final bool isVerified;
  final double size;

  const VerificationBadge({
    super.key,
    this.isVerified = false,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox();

    return Container(
      padding: EdgeInsets.all(size * 0.2),
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

// Confirmation Dialog
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppColors.primary,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

// Empty State
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Success Alert
class SuccessAlert extends StatefulWidget {
  final String message;
  final int durationSeconds;

  const SuccessAlert({
    super.key,
    required this.message,
    this.durationSeconds = 3,
  });

  @override
  State<SuccessAlert> createState() => _SuccessAlertState();
}

class _SuccessAlertState extends State<SuccessAlert> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: widget.durationSeconds), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
