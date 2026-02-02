# Smart Hub

A comprehensive multi-role marketplace Flutter application designed for student living solutions. Smart Hub connects students with property owners and service providers, offering seamless accommodation bookings and essential services.

## 🎯 Features

### Three User Roles

#### 👨‍🎓 Student
- Browse and search for accommodations near campus
- View detailed property information with images and amenities
- Book accommodations with real-time approval system
- Discover and order services (food, medicine, furniture)
- Shopping cart functionality with order management
- Save favorite properties and services
- View booking history and order tracking
- Profile management

#### 🏠 Owner (Property Owner)
- Manage property listings with images and details
- Real-time booking request management
- Approve or reject booking requests
- View analytics and performance metrics
- Track revenue and occupancy rates
- Profile and property management
- Dynamic dashboard with stats

#### 🛍️ Provider (Service Provider)
- Manage service catalog (food, medicine, furniture)
- Add/edit/delete services with image uploads
- Real-time order management
- View customer orders and order history
- Track earnings and performance analytics
- Dynamic dashboard with service stats
- Image picker integration for service photos

#### 🛡️ Admin (Super Admin)
- Full platform oversight (users, listings, services, bookings, orders)
- Verify users with 13-digit NID and track verification history
- Approve/unapprove accounts and remove abusive content
- Real-time analytics dashboard with system health metrics
- Live updates across all role dashboards

## 🚀 Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: SharedPreferences
- **Image Handling**: image_picker
- **UI Components**: Material Design 3

## 📦 Key Packages

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  go_router: ^14.6.2
  shared_preferences: ^2.3.3
  image_picker: ^1.1.2
```

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── models/          # Data models (User, House, Service, Booking, Order)
│   ├── providers/       # Riverpod state providers
│   ├── router/          # GoRouter configuration
│   ├── services/        # Mock data and storage services
│   ├── theme/           # App theme and colors
│   ├── utils/           # Utility functions
│   └── widgets/         # Reusable widgets
├── features/
│   ├── auth/           # Login, Signup, Splash screens
│   ├── common/         # Shared screens (Onboarding, Settings, Help, etc.)
│   ├── student/        # Student-specific features
│   ├── owner/          # Owner-specific features
│   ├── provider/       # Provider-specific features
│   └── admin/          # Admin dashboard and management
└── main.dart           # App entry point
```

## 🎨 Features Highlights

### Real-time Updates
- Dynamic data synchronization across all user roles
- Instant updates when bookings are approved/rejected
- Live order status tracking
- Real-time service catalog updates
- Real-time rating and review counts

### Image Management
- Upload images for properties and services
- Support for both camera and gallery selection
- Network and local image display with error handling
- Edit and update images for existing listings

### Analytics Dashboard
- Dynamic statistics for each user role
- Revenue tracking for owners and providers
- Order and booking metrics
- Performance indicators with visual cards

### User Experience
- Clean, intuitive Material Design interface
- Role-specific color schemes (Student: Teal, Owner: Orange, Provider: Purple)
- Smooth animations and transitions
- Responsive layouts for various screen sizes
- 3-step onboarding shown once every 30 days

## 🔧 Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/Tahsan0619/smarthub.git
   cd smarthub
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🧪 Demo Credentials

### Student Account
- Email: student@test.com
- Password: 123456

### Owner Account
- Email: owner@test.com
- Password: 123456

### Provider Account
- Email: provider@test.com
- Password: 123456

### Admin Account
- Email: admin@sajibmart.com
- Password: admin

## 📱 Screenshots

- Splash Screen with Smart Hub branding
- Role-based dashboards with dynamic statistics
- Property and service listings with images
- Booking and order management interfaces
- Profile management screens

## 🛠️ Development

### Adding New Features
The app uses a modular architecture with clear separation between user roles. Each role has its own feature folder with pages, widgets, and business logic.

### State Management
Riverpod providers are used throughout the app for:
- Authentication state
- Data management (houses, services, bookings, orders)
- Shopping cart functionality
- User profile management

### Navigation
GoRouter handles all navigation with role-based routing:
- `/auth/*` - Authentication flows
- `/student/*` - Student features
- `/owner/*` - Owner features  
- `/provider/*` - Provider features

## 🔐 Permissions

### Android
- `INTERNET` - Network requests and image loading
- `ACCESS_NETWORK_STATE` - Check connectivity status

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Developer

Developed by Tahsan
- GitHub: [@Tahsan0619](https://github.com/Tahsan0619)

## 🔮 Future Enhancements

- Firebase integration for real backend
- Push notifications for bookings and orders
- Payment gateway integration
- Chat system between users
- Map integration for property locations
- Advanced search filters
- Rating and review system
- Multi-language support

---

**Note**: Currently using mock data for demonstration. Backend integration coming soon!
