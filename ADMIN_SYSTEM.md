# Super Admin System - SajibMart

## Admin Credentials

**Email:** admin@sajibmart.com  
**Password:** admin  
**NID:** 1234567890123

## Features

### 1. User Management
- View all users (students, owners, providers)
- Filter by role and verification status
- Search users by name, email, phone, or NID
- Verify/Unverify users
- Delete users from the system
- View complete user details including NID

### 2. Content Management
- **Houses:** View and delete all properties
- **Services:** View and delete all services (food, medicine, furniture, tuition)
- **Bookings:** View and delete all house bookings
- **Orders:** View and delete all service orders

### 3. Analytics & Reports
- **User Analytics:** Total users, verified users, role breakdowns, pending verifications
- **Housing Analytics:** Total properties, available/occupied count, bookings
- **Service Analytics:** Service breakdown by category (food, medicine, furniture, tuition)
- **Revenue Analytics:** Total revenue, average order value
- **Platform Health:** Verification rate, occupancy rate, service availability

### 4. Real-Time Features
- All admin actions sync immediately across all user segments
- Pending verification badge updates in real-time
- Dashboard statistics refresh automatically
- When admin deletes content, it disappears from all user views instantly

## How to Access

1. Run the app
2. Login with admin credentials (admin@sajibmart.com / admin)
3. Admin dashboard loads with 4 tabs:
   - **Dashboard:** Overview with statistics and quick actions
   - **Users:** Verify/manage all users
   - **Content:** Delete houses, services, bookings, orders
   - **Analytics:** View detailed platform metrics

## NID (National ID) System

All users must provide a 13-digit NID during signup:
- **Students:** Required for verification before booking houses or ordering services
- **Owners:** Required for verification before posting houses
- **Providers:** Required for verification before offering services
- **Admins:** Can verify/unverify users based on NID validation

## Admin Powers

✅ Verify any user (student, owner, provider)  
✅ Unverify any user  
✅ Delete any user account  
✅ Delete any house posting  
✅ Delete any service offering  
✅ Delete any booking  
✅ Delete any order  
✅ View complete analytics across the platform  
✅ Search and filter all data  
✅ Real-time platform monitoring  

## Technical Implementation

- **Provider:** `admin_provider.dart` with `AdminUsersNotifier`
- **Dashboard:** 4-tab navigation (Dashboard, Users, Content, Analytics)
- **Theme:** Red color scheme (distinguishable from other roles)
- **State Management:** Riverpod with real-time synchronization
- **Data Persistence:** All changes sync to MockDataService

## Architecture

```
lib/features/admin/
├── admin_dashboard.dart          # Main admin interface
└── pages/
    ├── admin_home_page.dart      # Statistics & quick actions
    ├── admin_users_page.dart     # User verification & management
    ├── admin_content_page.dart   # Content deletion & monitoring
    └── admin_analytics_page.dart # Detailed analytics & reports
```

## Notes

- Admin role is separate from other roles (student, owner, provider)
- Admin accounts cannot perform user actions (no booking, no posting)
- Admin focus is purely on platform management and moderation
- All admin actions are immediate and irreversible
- Real-time updates ensure consistency across all user segments
