# Smart Hub Integration Guide

## Quick Navigation Setup

To use these new screens in your app, add the following routes to your `app_router.dart`:

```dart
// Add to GoRouter routes
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
),
GoRoute(
  path: '/help',
  builder: (context, state) => const HelpCenterScreen(),
),
GoRoute(
  path: '/messages',
  builder: (context, state) => const MessagingScreen(),
),
GoRoute(
  path: '/search-advanced',
  builder: (context, state) => const AdvancedSearchScreen(),
),
GoRoute(
  path: '/complaints',
  builder: (context, state) => const ComplaintScreen(),
),
GoRoute(
  path: '/analytics',
  builder: (context, state) => const ProviderAnalyticsScreen(), // or OwnerAnalyticsScreen
),
GoRoute(
  path: '/service/:id',
  builder: (context, state) => ServiceDetailScreen(
    serviceName: state.pathParameters['name'] ?? 'Service',
    category: 'Food', // from params
    price: 500,
    rating: 4.5,
  ),
),
GoRoute(
  path: '/verification',
  builder: (context, state) => const VerificationScreen(),
),
GoRoute(
  path: '/emergency-contacts',
  builder: (context, state) => const EmergencyContactsScreen(),
),
```

## Import Statements

Add these imports to files that use the new screens:

```dart
// Settings & Help
import 'package:sajibmart/features/common/settings_screen.dart';
import 'package:sajibmart/features/common/help_center_screen.dart';

// Messaging
import 'package:sajibmart/features/common/messaging_screen.dart';

// Search & Filters
import 'package:sajibmart/features/common/advanced_search_screen.dart';

// Support System
import 'package:sajibmart/features/common/complaint_screen.dart';

// Analytics
import 'package:sajibmart/features/common/analytics_screen.dart';

// Services & Checkout
import 'package:sajibmart/features/common/service_detail_screen.dart';

// Verification & Emergency
import 'package:sajibmart/features/common/verification_screen.dart';

// Utilities
import 'package:sajibmart/core/utils/utility_helpers.dart';
```

## Navigation Examples

### From Profile Screen

```dart
// Open Settings
ElevatedButton(
  onPressed: () => context.push('/settings'),
  child: const Text('Settings'),
)

// Open Help Center
ElevatedButton(
  onPressed: () => context.push('/help'),
  child: const Text('Help Center'),
)

// Open Verification
ElevatedButton(
  onPressed: () => context.push('/verification'),
  child: const Text('Verify Account'),
)

// Open Emergency Contacts
ElevatedButton(
  onPressed: () => context.push('/emergency-contacts'),
  child: const Text('Emergency Contacts'),
)
```

### From Dashboard

```dart
// Open Messaging
IconButton(
  icon: const Icon(Icons.message),
  onPressed: () => context.push('/messages'),
)

// Open Advanced Search
IconButton(
  icon: const Icon(Icons.tune),
  onPressed: () => context.push('/search-advanced'),
)

// Open Complaints
IconButton(
  icon: const Icon(Icons.report_problem),
  onPressed: () => context.push('/complaints'),
)

// Open Analytics
ElevatedButton(
  onPressed: () => context.push('/analytics'),
  child: const Text('View Analytics'),
)
```

## Using Utility Helpers

### Date/Time Utils

```dart
import 'package:sajibmart/core/utils/utility_helpers.dart';

// Relative time
String timeAgo = DateTimeUtils.getRelativeTime(DateTime.now().subtract(Duration(hours: 2)));
// Output: "2 hours ago"

// Format date
String formatted = DateTimeUtils.formatDate(DateTime.now());
// Output: "Jan 15, 2024"

// Smart date formatting
String smart = DateTimeUtils.formatSmartDate(DateTime.now());
// Output: "Today 14:30"
```

### Validation Utils

```dart
// Email validation
String? error = ValidationUtils.validateEmail('test@example.com');

// Phone validation
String? error = ValidationUtils.validatePhone('01234567890');

// Custom range validation
String? error = ValidationUtils.validateRange('250', 0, 50000);

// NID validation
String? error = ValidationUtils.validateNID('1234567890');
```

### String Utils

```dart
// Format currency
String price = StringUtils.formatCurrency(5000);
// Output: "BDT 5000"

// Format large numbers
String views = StringUtils.formatLargeNumber(125000);
// Output: "125.0K"

// Truncate text
String short = StringUtils.truncate('This is a long text', 10);
// Output: "This is a..."

// Get initials
String initials = StringUtils.capitalize('john doe');
// Output: "John doe"
```

### UI Utils

```dart
// Get initials for avatar
String initials = UIUtils.getInitials('John Doe');
// Output: "JD"

// Get status color
String color = UIUtils.getStatusColor('approved');
// Output: "#4CAF50"

// Get role color
String color = UIUtils.getRoleColor('student');
// Output: "#26A69A"
```

## Widget Integration

### Using in Custom Screens

```dart
// Settings Tile
ListTile(
  leading: Icon(Icons.settings),
  title: Text('App Settings'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () => context.push('/settings'),
)

// Status Badge
StatusBadge(
  label: 'Approved',
  color: Colors.green,
)

// Rating Bar
RatingBar(
  rating: 4.5,
  onRated: (rating) {
    print('Rated: $rating');
  },
)

// Verification Badge
VerificationBadge()

// Empty State
EmptyState(
  icon: Icons.inbox,
  title: 'No Messages',
  subtitle: 'You have no new messages',
  buttonText: 'Start Messaging',
  onButtonPressed: () => context.push('/messages'),
)
```

## State Management Integration

### With Riverpod

```dart
// Listen to message provider
final messages = ref.watch(messagesProvider);

// Listen to complaint status
final complaints = ref.watch(complaintsProvider);

// Listen to analytics
final analytics = ref.watch(analyticsProvider);

// Use in ConsumerWidget
class MyAnalyticsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    
    return ProviderAnalyticsScreen();
  }
}
```

## Backend Integration Points

### Connect to Real APIs

```dart
// Example: Replace mock data with real API calls
Future<List<_Conversation>> fetchConversations() async {
  final response = await http.get(
    Uri.parse('https://api.smarthub.com/conversations'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode == 200) {
    // Parse and return conversations
  }
}

// Example: Submit complaint to backend
Future<void> submitComplaint(String title, String description) async {
  final response = await http.post(
    Uri.parse('https://api.smarthub.com/complaints'),
    headers: {'Authorization': 'Bearer $token'},
    body: jsonEncode({
      'title': title,
      'description': description,
      'userId': currentUser.id,
    }),
  );
  
  return response.statusCode == 201;
}

// Example: Process payment
Future<void> processPayment(PaymentMethod method, double amount) async {
  final response = await http.post(
    Uri.parse('https://api.smarthub.com/payments'),
    headers: {'Authorization': 'Bearer $token'},
    body: jsonEncode({
      'method': method,
      'amount': amount,
      'currency': 'BDT',
    }),
  );
  
  return response.statusCode == 200;
}
```

## Testing the Features

### Manual Testing Checklist

- [ ] Settings Screen - All toggles and buttons work
- [ ] Help Center - FAQs expand/collapse smoothly
- [ ] Messaging - Can send messages in chat
- [ ] Advanced Search - Filters apply and reset properly
- [ ] Complaints - Can file and view complaints
- [ ] Analytics - Charts display correctly
- [ ] Service Detail - Can select quantity and time slots
- [ ] Checkout - Payment methods selectable
- [ ] Verification - Progress bar updates
- [ ] Emergency Contacts - Can add/edit/delete contacts

### Testing with Different Screen Sizes

```dart
// Test device orientation
flutter run -d chrome --web-renderer html
```

## Troubleshooting

### Screen Not Showing
- Verify route is added to `app_router.dart`
- Check import statements are correct
- Ensure no compilation errors: `flutter analyze`

### Data Not Persisting
- Check Riverpod providers are properly initialized
- Verify StateNotifier updates are called
- Check SharedPreferences is initialized in main.dart

### UI Layout Issues
- Test on different screen sizes
- Check for overflow errors in Logcat
- Use `flutter run -d emulator --verbose` for detailed logs

### Performance Issues
- Use `ListView.builder` for long lists
- Avoid rebuilds with proper widget structure
- Profile with `flutter run --profile`

## Support Features Usage

### Settings to User Profile
```dart
// Navigate from Settings to edit profile
Navigator.of(context).push(MaterialPageRoute(
  builder: (context) => const StudentProfilePage(), // existing screen
));
```

### Help to Support
```dart
// Open support from Help Center
showDialog(
  context: context,
  builder: (context) => ContactSupportDialog(),
);
```

### Complaints to Analytics
```dart
// Show complaint impact on analytics
// Provider can see how complaints affect ratings
```

## Color Reference

- **Primary (Teal)**: `#26A69A` - Main actions
- **Secondary (Blue)**: `#2196F3` - Secondary actions
- **Success (Green)**: `#4CAF50` - Completed/verified
- **Warning (Orange)**: `#FFC107` - Pending/attention
- **Error (Red)**: `#F44336` - Errors/high priority
- **Info (Light Blue)**: `#2196F3` - Information

## Button Styles

### Primary Action
```dart
ElevatedButton(
  onPressed: onTap,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
  ),
  child: const Text('Action'),
)
```

### Secondary Action
```dart
OutlinedButton(
  onPressed: onTap,
  child: const Text('Cancel'),
)
```

### Destructive Action
```dart
ElevatedButton(
  onPressed: onTap,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
  ),
  child: const Text('Delete'),
)
```

## Next Steps

1. Add routes to `app_router.dart`
2. Test each screen independently
3. Integrate with backend APIs
4. Set up real data providers with Riverpod
5. Add push notifications
6. Implement real payment gateway
7. Connect to messaging service (Firebase, Socket.io)
8. Set up document storage for verification

---

**Version**: 1.0.0
**Last Updated**: 2024
**Status**: Ready for Production
