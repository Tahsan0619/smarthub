import 'package:intl/intl.dart';

/// Utility class for date and time formatting
class DateTimeUtils {
  /// Format relative time (e.g., "5 minutes ago", "Yesterday")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  /// Format date in readable format
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format time in 12-hour format
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Format date and time together
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy HH:mm').format(dateTime);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.day == tomorrow.day && date.month == tomorrow.month && date.year == tomorrow.year;
  }

  /// Get formatted date with smart formatting
  static String formatSmartDate(DateTime date) {
    if (isToday(date)) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (isTomorrow(date)) {
      return 'Tomorrow ${DateFormat('HH:mm').format(date)}';
    } else {
      return formatDateTime(date);
    }
  }
}

/// Utility class for common validators
class ValidationUtils {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate number in range
  static String? validateRange(String? value, double min, double max) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    try {
      final numValue = double.parse(value);
      if (numValue < min || numValue > max) {
        return 'Please enter a value between $min and $max';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validate NID format (Bangladesh National ID)
  static String? validateNID(String? value) {
    if (value == null || value.isEmpty) {
      return 'NID is required';
    }
    if (value.length < 10) {
      return 'NID must be at least 10 digits';
    }
    return null;
  }

  /// Validate pricing
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    try {
      final price = double.parse(value);
      if (price <= 0) {
        return 'Price must be greater than 0';
      }
    } catch (e) {
      return 'Please enter a valid price';
    }
    return null;
  }
}

/// Utility class for string operations
class StringUtils {
  /// Capitalize first letter of string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Format phone number
  static String formatPhone(String phone) {
    if (phone.length == 11) {
      return '+880${phone.substring(1)}';
    }
    return phone;
  }

  /// Truncate string with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Check if string contains only letters
  static bool isAlpha(String text) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(text);
  }

  /// Check if string is numeric
  static bool isNumeric(String text) {
    return RegExp(r'^[0-9]+$').hasMatch(text);
  }

  /// Format currency
  static String formatCurrency(double amount) {
    return 'BDT ${amount.toStringAsFixed(0)}';
  }

  /// Format large numbers with K, M suffix
  static String formatLargeNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}

/// Utility class for distance calculations
class DistanceUtils {
  /// Calculate approximate distance based on coordinates
  /// Using Haversine formula
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in kilometers

    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(_toRad(lat1)) * Math.cos(_toRad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2));
    final c = 2 * Math.asin(Math.sqrt(a));

    return R * c;
  }

  static double _toRad(double deg) {
    return deg * (Math.pi / 180);
  }

  /// Format distance for display
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)}m';
    } else {
      return '${km.toStringAsFixed(1)}km';
    }
  }
}

/// Math operations helper
class Math {
  static const double pi = 3.14159265359;

  static double sin(double radians) {
    return _sin(radians);
  }

  static double cos(double radians) {
    return _cos(radians);
  }

  static double sqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;

    double z = x;
    double result = x;

    for (int i = 0; i < 100; i++) {
      z = 0.5 * (z + x / z);
      if ((z - result).abs() < 1e-10) {
        break;
      }
      result = z;
    }

    return result;
  }

  static double asin(double x) {
    if (x < -1 || x > 1) return double.nan;
    return _asin(x);
  }

  static double _sin(double x) {
    // Normalize angle to [-π, π]
    x = x % (2 * pi);
    if (x > pi) x -= 2 * pi;
    if (x < -pi) x += 2 * pi;

    // Taylor series approximation
    double result = 0;
    double term = x;

    for (int i = 1; i < 20; i++) {
      result += term;
      term *= -x * x / ((2 * i) * (2 * i + 1));
    }

    return result;
  }

  static double _cos(double x) {
    // cos(x) = sin(π/2 - x)
    return sin(pi / 2 - x);
  }

  static double _asin(double x) {
    // Approximation using Newton's method
    if (x == 0) return 0;
    if (x == 1) return pi / 2;
    if (x == -1) return -pi / 2;

    double result = x;
    for (int i = 1; i < 20; i++) {
      result = result - (sin(result) - x) / cos(result);
    }

    return result;
  }
}

/// Utility class for UI helpers
class UIUtils {
  /// Get initials from name
  static String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '';
  }

  /// Get role color
  static String getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return '#26A69A'; // Teal
      case 'owner':
        return '#2196F3'; // Blue
      case 'provider':
        return '#66BB6A'; // Green
      default:
        return '#9C27B0'; // Purple
    }
  }

  /// Get status color
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
      case 'success':
        return '#4CAF50'; // Green
      case 'pending':
      case 'processing':
        return '#FFC107'; // Orange
      case 'rejected':
      case 'cancelled':
      case 'error':
        return '#F44336'; // Red
      case 'in review':
        return '#2196F3'; // Blue
      default:
        return '#9E9E9E'; // Gray
    }
  }
}
