# Track Vision - Flutter App Structure

## 📁 Folder Structure

This Flutter application follows a feature-based architecture pattern with clear separation of concerns. The structure is inspired by modern frontend frameworks and follows Flutter best practices.

```
lib/
├── core/                    # Core functionality and configuration
│   ├── config/             # App configuration and constants
│   │   ├── constants.dart  # Color constants, API config, app settings
│   │   └── config.dart     # Barrel export
│   ├── services/           # Core services (API, storage, etc.)
│   │   ├── api_service.dart # HTTP client and API endpoints
│   │   └── services.dart   # Barrel export
│   └── utils/              # Utility functions and helpers
│       ├── helpers.dart    # Common helper functions
│       └── utils.dart      # Barrel export
│
├── shared/                  # Shared resources across features
│   ├── models/             # Data models used across features
│   │   ├── complaint_model.dart
│   │   ├── detection_model.dart
│   │   ├── alert_model.dart
│   │   ├── route_model.dart
│   │   └── models.dart     # Barrel export
│   ├── providers/          # Global state providers (Riverpod)
│   │   ├── auth_notifier.dart
│   │   ├── auth_state.dart
│   │   ├── data_providers.dart
│   │   └── providers.dart  # Barrel export
│   └── widgets/            # Reusable widgets
│       ├── admin_appbar.dart
│       ├── user_appbar.dart
│       ├── admin_bottom_navbar.dart
│       ├── user_bottom_navbar.dart
│       └── widgets.dart    # Barrel export
│
├── features/                # Feature modules
│   ├── auth/               # Authentication feature
│   │   ├── models/         # Auth-specific models
│   │   │   ├── user_model.dart
│   │   │   └── admin_model.dart
│   │   ├── providers/      # Auth-specific providers
│   │   │   ├── user_provider.dart
│   │   │   └── admin_provider.dart
│   │   └── screens/        # Auth screens
│   │       ├── splash_screen.dart
│   │       ├── login_screen.dart
│   │       ├── signup_screen.dart
│   │       ├── forgot_password_screen.dart
│   │       ├── verify_code_screen.dart
│   │       └── reset_password_screen.dart
│   │
│   ├── admin/              # Admin feature module
│   │   ├── dashboard/      # Admin dashboard sub-feature
│   │   │   ├── screens/
│   │   │   │   └── admin_dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── overview_cards.dart
│   │   │       ├── detection_section.dart
│   │   │       ├── google_map_widget.dart
│   │   │       └── recent_detection_widget.dart
│   │   ├── vehicles/       # Vehicle tracking sub-feature
│   │   │   ├── screens/
│   │   │   │   └── admin_vehicles_screen.dart
│   │   │   └── widgets/
│   │   │       └── detection_details_widget.dart
│   │   ├── alerts/         # Alerts management sub-feature
│   │   │   └── screens/
│   │   │       └── admin_alerts_screen.dart
│   │   ├── camera/         # Camera management sub-feature
│   │   │   ├── screens/
│   │   │   │   └── admin_camera_screen.dart
│   │   │   └── widgets/
│   │   │       ├── ipcamera_widget.dart
│   │   │       ├── upload_detection_widget.dart
│   │   │       └── camera_settings_widget.dart
│   │   └── complaints/     # Complaints management sub-feature
│   │       └── screens/
│   │           └── admin_complaints_screen.dart
│   │
│   └── user/               # User feature module
│       ├── dashboard/      # User dashboard sub-feature
│       │   └── screens/
│       │       └── user_dashboard_screen.dart
│       ├── complaints/     # User complaints sub-feature
│       │   ├── screens/
│       │   │   └── user_complaints_screen.dart
│       │   └── widgets/
│       │       ├── search_complaints_widget.dart
│       │       └── submit_complaint_widget.dart
│       ├── alerts/         # User alerts sub-feature
│       │   └── widgets/
│       │       ├── alerts_popup_widget.dart
│       │       ├── show_alerts_widget.dart
│       │       └── viewall_alerts_widget.dart
│       ├── camera/         # User camera sub-feature
│       │   ├── screens/
│       │   │   └── user_camera_screen.dart
│       │   └── widgets/
│       │       └── camera_scan_page_widget.dart
│       └── profile/        # User profile sub-feature
│           └── widgets/
│               ├── profile_edit_widget.dart
│               └── profile_dropdown_widget.dart
│
├── routes/                  # Navigation and routing
│   └── app_routes.dart     # Centralized route definitions
│
└── main.dart               # App entry point

```

## 🏗️ Architecture Principles

### 1. Feature-Based Organization
- Each feature is self-contained with its own screens, widgets, and business logic
- Easy to locate and modify feature-specific code
- Promotes modularity and scalability

### 2. Separation of Concerns
- **Core**: Foundation code used everywhere (config, services, utils)
- **Shared**: Resources shared across multiple features (models, providers, common widgets)
- **Features**: Business logic and UI for specific features

### 3. Naming Conventions
- **Screens**: `*_screen.dart` (e.g., `login_screen.dart`)
- **Widgets**: `*_widget.dart` (e.g., `overview_cards_widget.dart`)
- **Models**: `*_model.dart` (e.g., `user_model.dart`)
- **Providers**: `*_provider.dart` or `*_notifier.dart`

### 4. Barrel Exports
Each major directory has a barrel export file (e.g., `models.dart`, `widgets.dart`) to simplify imports:
```dart
// Instead of:
import 'package:track_vision/shared/models/complaint_model.dart';
import 'package:track_vision/shared/models/detection_model.dart';

// Use:
import 'package:track_vision/shared/models/models.dart';
```

## 📦 Key Modules

### Core Module
- **config**: Application-wide configuration and constants
- **services**: API service, authentication service, storage service
- **utils**: Helper functions, validators, formatters

### Shared Module
- **models**: Data models used across multiple features
- **providers**: Global state management (Riverpod)
- **widgets**: Reusable UI components (app bars, navigation bars, etc.)

### Features Module
#### Auth Feature
- User authentication flow (login, signup, password recovery)
- JWT token management
- User and admin models

#### Admin Feature
- **Dashboard**: Overview statistics, recent detections, map view
- **Vehicles**: Vehicle tracking and detection history
- **Alerts**: Alert management and notifications
- **Camera**: IP camera configuration and upload detection
- **Complaints**: View and manage user complaints

#### User Feature
- **Dashboard**: User overview and quick actions
- **Complaints**: Submit and track complaints
- **Alerts**: View notifications and alerts
- **Camera**: Scan vehicle plates
- **Profile**: Edit profile and settings

## 🚀 Getting Started

### Import Best Practices

```dart
// ✅ Good: Use barrel exports
import 'package:track_vision/core/config/config.dart';
import 'package:track_vision/shared/models/models.dart';
import 'package:track_vision/shared/widgets/widgets.dart';

// ❌ Bad: Direct file imports for shared resources
import 'package:track_vision/shared/models/complaint_model.dart';
import 'package:track_vision/shared/models/detection_model.dart';
```

### Adding New Features

1. Create feature folder in `lib/features/`
2. Add subdirectories: `screens/`, `widgets/`, `models/`, `providers/`
3. Implement feature-specific code
4. Create barrel exports for easy importing
5. Update routes in `lib/routes/app_routes.dart`

### Code Organization Tips

1. **Keep screens lean**: Move complex logic to providers
2. **Reuse widgets**: Place reusable widgets in `shared/widgets/`
3. **Model everything**: Use data models for API responses
4. **Centralize navigation**: All routes defined in `app_routes.dart`
5. **Use providers**: State management with Riverpod

## 🔧 Configuration

Update `lib/core/config/constants.dart` for:
- API base URL
- Color theme
- App-wide settings
- Environment-specific configuration

## 📚 Related Documentation

- [Flutter Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Riverpod Documentation](https://riverpod.dev/)
- [Feature-First Architecture](https://codewithandrea.com/articles/flutter-project-structure/)

## 🤝 Contributing

When adding new features:
1. Follow the established folder structure
2. Use consistent naming conventions
3. Create barrel exports for public APIs
4. Update this README if adding major features
5. Keep features independent and loosely coupled
