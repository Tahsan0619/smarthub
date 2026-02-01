# Smart Hub - Complete Feature Map

## Quick Reference Guide

### 📱 All Available Screens

#### User Account & Settings
```
Settings Screen
├── Account Management
│   ├── Edit Profile
│   ├── Change Password
│   └── Verification
├── Notifications
│   ├── Push Notifications (Toggle)
│   ├── Email Alerts (Toggle)
│   └── SMS Alerts (Toggle)
├── Preferences
│   ├── Language
│   └── Location
├── Help & Support
│   ├── Help Center
│   ├── Report Issue
│   └── Privacy Policy
└── Danger Zone
    └── Delete Account
```

#### Help & FAQs
```
Help Center Screen
├── Booking FAQs
├── Cancellation FAQs
├── Property Report FAQs
├── Payment FAQs
├── Dispute Resolution FAQs
├── Property Listing FAQs
└── Contact Support
    ├── Email: support@smarthub.com
    ├── Phone: +880 1234-567890
    └── Send Message Button
```

#### Communication
```
Messaging Screen
├── Conversation List
│   ├── Search Conversations
│   ├── Conversation Items
│   │   ├── User Avatar
│   │   ├── Last Message Preview
│   │   ├── Unread Badge
│   │   └── Timestamp
│   └── Online Status Indicator
└── Chat Detail Screen
    ├── Header
    │   ├── User Name
    │   ├── Online Status
    │   ├── Call Button
    │   └── Info Button
    ├── Message List
    │   ├── User Messages (Right)
    │   ├── Other Messages (Left)
    │   ├── Timestamps
    │   └── Read Status
    ├── Message Input
    │   ├── Add Button
    │   ├── Text Field
    │   └── Send Button
    └── Auto-scroll to Latest
```

#### Search & Discovery
```
Advanced Search Screen
├── Price Range
│   └── RangeSlider (0-100,000 BDT)
├── Room Type
│   ├── Any
│   ├── 1 Bed
│   ├── 2 Bed
│   └── 3+ Bed
├── Amenities
│   ├── WiFi
│   ├── Air Conditioning
│   ├── Parking
│   ├── Laundry
│   ├── Furnished
│   ├── Kitchen
│   ├── Gym
│   └── Security
├── Distance
│   └── Slider (0-20 km)
├── Sort By
│   ├── Newest
│   ├── Price: Low to High
│   ├── Price: High to Low
│   ├── Rating
│   └── Distance
├── Reset Button
└── Apply Button
```

#### Support & Complaints
```
Complaint Screen
├── Filter Tabs
│   ├── All
│   ├── Open
│   ├── In Review
│   └── Resolved
├── Complaint List
│   ├── Complaint Cards
│   │   ├── Title
│   │   ├── Description Preview
│   │   ├── Status Badge
│   │   ├── Priority
│   │   └── Created Date
│   └── Tap to View Details
├── Details Dialog
│   ├── Full Title
│   ├── Status & Priority
│   ├── Full Description
│   ├── Submission Date
│   └── Last Update Date
└── Add Button (+)
    └── File Complaint Dialog
        ├── Title Input
        ├── Category Dropdown
        ├── Priority Dropdown
        └── Description Text Field
```

#### Service Ordering
```
Service Detail Screen
├── Header Section
│   ├── Service Icon
│   └── Gradient Background
├── Service Info
│   ├── Name
│   ├── Category Badge
│   └── Star Rating
├── Description
├── Quantity Selector
│   ├── Decrease Button
│   ├── Quantity Display
│   └── Increase Button
├── Delivery Date
│   └── DatePicker
├── Time Slot Selection
│   ├── 08:00 AM
│   ├── 09:00 AM
│   ├── 10:00 AM
│   ├── 02:00 PM
│   ├── 03:00 PM
│   └── 04:00 PM
├── Order Summary
│   ├── Subtotal
│   ├── Delivery Fee (50 BDT)
│   └── Total
└── Proceed to Checkout Button
```

#### Checkout & Payment
```
Checkout Dialog
├── Order Item Summary
├── Order Summary
│   ├── Items
│   ├── Subtotal
│   ├── Delivery
│   └── Total
├── Payment Methods
│   ├── Credit Card (Radio)
│   ├── Mobile Banking (Radio)
│   └── Cash on Delivery (Radio)
├── Delivery Address
│   ├── Address Display
│   └── Estimated Delivery Time
└── Place Order Button
    └── Processing State (Spinner)
```

#### Analytics Dashboards

**For Service Providers**
```
Provider Analytics Screen
├── Stats Cards
│   ├── Total Orders
│   ├── Total Revenue
│   └── Average Rating
├── Revenue Chart
│   ├── 6-Month Trend
│   ├── Bar Chart
│   └── Growth Indicator
├── Top Services
│   ├── Service Name
│   ├── Order Count
│   └── Revenue
└── Customer Distribution
    ├── New Customers
    └── Repeat Customer Rate
```

**For House Owners**
```
Owner Analytics Screen
├── Stats Cards
│   ├── Total Bookings
│   ├── Occupancy Rate
│   └── Average Rating
├── Booking Trend
│   ├── 4-Week Chart
│   └── Weekly Booking Count
├── Top Properties
│   ├── Property Name
│   ├── View Count
│   └── Booking Count
└── Response Time
    ├── Average Response Time
    └── Quality Indicator
```

#### User Verification
```
Verification Screen
├── Progress Bar
│   ├── Percentage Display
│   └── Status Counter
├── Verification Items
│   ├── Email (✓ Verified)
│   ├── Phone (✓ Verified)
│   ├── Identity Document (Pending)
│   └── University (Pending)
├── Benefits List
│   ├── Access Premium Features
│   ├── Higher Trust Score
│   ├── Priority Support
│   └── Increased Booking Limits
├── Verify Identity Button
│   └── Dialog
│       ├── National ID (NID)
│       ├── Passport
│       └── Driving License
└── Verify University Button
    └── Dialog
        ├── University Name
        ├── Student ID
        └── Document Upload
```

#### Emergency Contacts
```
Emergency Contacts Screen
├── Floating Action Button (+)
│   └── Add Contact Dialog
│       ├── Name Input
│       ├── Phone Input
│       ├── Relation Dropdown
│       │   ├── Mother
│       │   ├── Father
│       │   ├── Sister
│       │   ├── Brother
│       │   ├── Friend
│       │   ├── Family Member
│       │   └── Other
│       └── Add Button
├── Contact Cards
│   ├── Avatar with Initial
│   ├── Contact Name
│   ├── Phone Number
│   ├── Relation
│   └── Menu (Edit/Delete)
└── Empty State (if no contacts)
```

---

## 🔗 Navigation Flow

### From Student Dashboard
```
Dashboard
├── Home Tab
│   ├── Search Bar → Advanced Search
│   └── House Card → House Details → Reviews → Book
├── Search Tab
│   ├── Search Bar → Advanced Search
│   └── Service Cards → Service Details → Checkout
├── Saved Tab
│   └── Saved Houses
├── Profile Tab
    ├── Edit Profile → Settings
    ├── Help → Help Center
    ├── Logout
    ├── Verification
    └── Emergency Contacts
```

### From Owner Dashboard
```
Dashboard
├── Add Property
├── My Properties
├── Recent Booking Requests
└── Settings
    ├── Account Management
    └── Analytics
```

### From Provider Dashboard
```
Dashboard
├── Add Service
├── My Services
├── Recent Orders
└── Settings
    ├── Account Management
    └── Analytics
```

---

## 🎨 Color Guide

### Status Colors
```
✅ Verified/Complete    → Green #4CAF50
⏳ Pending/In Review     → Orange #FFC107 or Blue #2196F3
❌ Rejected/Error        → Red #F44336
ℹ️  Information           → Blue #2196F3
```

### Role Colors
```
Student                 → Teal #26A69A
Owner                   → Blue #2196F3
Provider                → Green #66BB6A
```

---

## 🎯 Feature Access Quick Links

| Feature | File | How to Access |
|---------|------|---------------|
| Settings | settings_screen.dart | Profile → Settings |
| Help | help_center_screen.dart | Profile → Help or Settings → Help Center |
| Messages | messaging_screen.dart | Dashboard → Messages tab |
| Search | advanced_search_screen.dart | Dashboard → Search filter button |
| Complaints | complaint_screen.dart | Profile → Support → Complaints |
| Analytics | analytics_screen.dart | Dashboard → Analytics (for Owner/Provider) |
| Service Details | service_detail_screen.dart | Search results → Tap service card |
| Checkout | service_detail_screen.dart | Service Details → Proceed to Checkout |
| Verification | verification_screen.dart | Profile → Verification |
| Emergency | verification_screen.dart | Profile → Emergency Contacts |

---

## 📊 Data Models Used

```dart
// Existing Models
- UserModel              (id, name, email, role, rating)
- HouseModel            (id, title, rent, images, amenities)
- ServiceModel          (id, name, price, category)
- BookingModel          (id, houseId, status)
- OrderModel            (id, serviceId, status)

// Extended Models
- ReviewModel           (id, rating, comment, images)
- ComplaintModel        (id, title, status, priority)
- MessageModel          (id, text, isRead)
- ConversationModel     (id, lastMessage, unreadCount)
- PaymentModel          (id, amount, method)
- AnalyticsModel        (id, views, bookings, revenue)
```

---

## 💾 Persistence

```
SharedPreferences Keys:
- user_id               (Current user ID)
- user_role             (student/owner/provider)
- auth_token            (Bearer token)
- app_theme             (light/dark)
- notification_prefs    (JSON)
- language              (en/bn)
```

---

## 🔐 Verification Statuses

```
Email       → Auto-verified on signup
Phone       → Requires phone verification
Identity    → Requires document upload
University  → Requires student ID upload
```

---

## 📈 Analytics Metrics

**For Providers:**
- Total orders placed
- Total revenue earned
- Average customer rating
- Monthly revenue trend
- Top performing services
- New vs repeat customers

**For Owners:**
- Total bookings received
- Occupancy rate
- Average property rating
- Weekly booking trend
- Top performing properties
- Average response time

---

## 🧪 Testing Scenarios

### Student User Flow
1. Login as student
2. Search for services (Advanced Search)
3. Select service and quantity
4. Choose delivery date/time
5. Proceed to checkout
6. Select payment method
7. Place order
8. File complaint if needed
9. Message provider

### Owner User Flow
1. Login as owner
2. Add property
3. View bookings
4. Check analytics
5. Review verification status
6. Update settings

### Provider User Flow
1. Login as provider
2. Add service
3. Manage orders
4. View analytics
5. Message customers
6. Handle complaints

---

**Last Updated**: 2024
**Version**: 1.0.0
**Status**: Complete & Production Ready ✅
