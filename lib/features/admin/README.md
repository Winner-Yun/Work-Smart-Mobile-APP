# Admin Homepage Setup Guide

## Overview

This package contains admin dashboard screens for your WorkSmart application. Two versions are provided:

1. **AdminHomepage** - Optimized for mobile and smaller screens
2. **AdminHomepageWeb** - Optimized for web and larger screens

## Files Created

```
lib/features/home/admin/
├── presentation/
│   ├── admin_homepage.dart          # Mobile-optimized admin dashboard
│   ├── admin_homepage_web.dart      # Web-optimized admin dashboard
│   └── index.dart                   # Barrel export file
└── README.md                         # This file
```

## How to Use

### 1. Import the screens

#### Mobile Version:

```dart
import 'package:flutter_worksmart_mobile_app/features/home/admin/presentation/admin_homepage.dart';

// Use in navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AdminHomepage(
      loginData: loginData,
    ),
  ),
);
```

#### Web Version:

```dart
import 'package:flutter_worksmart_mobile_app/features/home/admin/presentation/admin_homepage_web.dart';

// Use in navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AdminHomepageWeb(
      loginData: loginData,
    ),
  ),
);
```

#### Using Barrel Export:

```dart
import 'package:flutter_worksmart_mobile_app/features/home/admin/presentation/index.dart';

// Now you can use both AdminHomepage and AdminHomepageWeb
```

### 2. Add Routes (Optional)

Add to `lib/app/routes/app_route.dart`:

```dart
import 'package:flutter_worksmart_mobile_app/features/home/admin/presentation/admin_homepage.dart';
import 'package:flutter_worksmart_mobile_app/features/home/admin/presentation/admin_homepage_web.dart';

class AppRoute {
  static const String adminDashboard = '/admin-dashboard';
  static const String adminDashboardWeb = '/admin-dashboard-web';

  static Map<String, WidgetBuilder> routes = {
    // ... existing routes
    adminDashboard: _buildRoute(
      (args) => AdminHomepage(loginData: args),
    ),
    adminDashboardWeb: _buildRoute(
      (args) => AdminHomepageWeb(loginData: args),
    ),
  };
}
```

### 3. Responsive Implementation

For a responsive approach that automatically selects the right version:

```dart
Widget _buildAdminScreen(Map<String, dynamic> loginData) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return AdminHomepageWeb(loginData: loginData);
      } else {
        return AdminHomepage(loginData: loginData);
      }
    },
  );
}
```

## Features

### Mobile Version (AdminHomepage)

- Dashboard summary card
- 4-column stats grid (2x2 on mobile)
- 3-column quick actions grid
- Recent activities list
- Bottom navigation bar
- Responsive design

### Web Version (AdminHomepageWeb)

- Sidebar navigation rail
- 4-column stats grid (card-based design)
- Quick actions section with grid layout
- Employee statistics with progress bars
- Recent activities sidebar panel
- Upcoming events panel
- Optimized spacing and typography for web

## Components

Both versions include:

- **StatCard**: Displays key metrics with icons
- **QuickActionCard**: Action buttons for common tasks
- **ActivityListTile**: Shows user activities
- Custom layouts for each screen

## Data Structure

The `loginData` parameter expects:

```dart
Map<String, dynamic> loginData = {
  'userId': '123',
  'userName': 'Admin Name',
  'email': 'admin@worksmart.com',
  // ... other data
};
```

## Customization

### Modify Stats

Edit the `stats` list in `_buildStatsGrid()` or `_buildStatsOverview()` to show your actual data.

### Add More Quick Actions

Add new items to the `actions` or `stat` lists in the respective methods.

### Connect to Real Data

Replace hardcoded values with:

```dart
// Example: Get real data from your provider/controller
final userCount = Provider.of<UserProvider>(context).allUsers.length;
final activeUsers = Provider.of<UserProvider>(context).activeUsers.length;
```

### Styling

Both screens use the app's theme. Customize through:

- `Theme.of(context).textTheme`
- `Theme.of(context).primaryColor`
- `AppThemes.lightTheme` / `AppThemes.darkTheme`

## Next Steps

1. **Add routing**: Update `app_route.dart` to include admin routes
2. **Connect data**: Replace mock data with real API calls
3. **Add sub-pages**: Create dedicated screens for:
   - User Management
   - Leave Requests
   - Reports
   - Settings
4. **Implement navigation**: Link quick action buttons to respective screens
5. **Add animations**: Consider adding AnimatedBuilder for smooth transitions

## Notes

- Both screens are stateful to handle navigation state
- The web version includes a responsive NavigationRail for desktop
- Data is currently mocked; replace with actual data sources
- All colors and icons use Material Design conventions
