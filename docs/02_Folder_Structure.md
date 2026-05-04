# Folder Structure

## Root Directory Structure
```
CodeNyx/
├── android/                 # Android-specific configuration and code
├── ios/                     # iOS-specific configuration and code
├── web/                     # Web-specific configuration and code
├── lib/                     # Main Dart source code
├── docs/                    # Project documentation
├── test/                    # Test files
├── .gitignore               # Git ignore rules
├── analysis_options.yaml    # Dart analyzer configuration
├── pubspec.yaml             # Dependencies and project metadata
└── README.md                # Project readme
```

## lib/ Directory Structure
```
lib/
├── main.dart               # Application entry point
├── app.dart                # Root widget with routing
├── core/                   # Core utilities and services
│   ├── theme/
│   │   └── app_theme.dart  # App theme configuration
│   └── constants/
│       └── app_constants.dart # App-wide constants
├── features/               # Feature modules
│   ├── auth/               # Authentication feature
│   │   ├── auth_screen.dart
│   │   └── auth_provider.dart
│   ├── social_feed/        # Social feed feature
│   │   ├── feed_screen.dart
│   │   ├── feed_repository.dart
│   │   ├── create_post_screen.dart
│   │   ├── post_detail_screen.dart
│   │   ├── post_state.dart
│   │   └── image_upload_service.dart
│   ├── chat/               # Chat feature
│   │   ├── chat_screen.dart
│   │   ├── chat_repository.dart
│   │   ├── chat_provider.dart
│   │   ├── message_model.dart
│   │   └── message_bubble.dart
│   ├── user/               # User features
│   │   ├── user_updates_screen.dart
│   │   └── timer_screen.dart
│   ├── admin/              # Admin features
│   │   ├── admin_providers.dart
│   │   ├── manage_announcements_screen.dart
│   │   └── manage_mentor_requests_screen.dart
│   └── complaints/         # Complaints feature
│       ├── user_complaints_screen.dart
│       ├── admin_complaints_screen.dart
│       └── complaints_repository.dart
└── services/               # Shared services
    ├── session_service.dart # Session management
    └── supabase_service.dart # Supabase initialization
```

## Directory Explanations

### android/
Contains Android-specific configuration files:
- `app/`: Main Android application code
- `gradle/`: Gradle build configuration
- `AndroidManifest.xml`: Android app manifest
- Build scripts and resource files

### ios/
Contains iOS-specific configuration files:
- `Runner/`: Main iOS application code
- `Runner.xcworkspace/`: Xcode workspace
- `Info.plist`: iOS app configuration
- Podfile: CocoaPods dependencies

### web/
Contains web-specific configuration:
- `index.html`: Web entry point
- `manifest.json`: Web app manifest
- Icons and favicon

### lib/
Main application source code directory:
- **main.dart**: Entry point, initializes Supabase and runs the app
- **app.dart**: Root widget with go_router configuration
- **core/**: Shared utilities (theme, constants)
- **features/**: Feature-based modules
- **services/**: Shared services (session, Supabase)

### docs/
Project documentation files (this directory)

### test/
Unit and widget test files

### Configuration Files
- **pubspec.yaml**: Dependencies, version, and metadata
- **analysis_options.yaml**: Dart analyzer rules
- **.gitignore**: Files to exclude from version control

## Feature Module Structure
Each feature follows a consistent pattern:
```
feature_name/
├── feature_screen.dart      # Main UI screen
├── feature_repository.dart  # Data layer (Supabase interactions)
├── feature_provider.dart    # Riverpod state management
├── feature_model.dart       # Data models
└── feature_service.dart     # Business logic services
```

## Naming Conventions
- **Files**: snake_case (e.g., `feed_screen.dart`)
- **Classes**: PascalCase (e.g., `FeedScreen`)
- **Variables**: camelCase (e.g., `feedRepository`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_IMAGE_SIZE`)
- **Private members**: underscore prefix (e.g., `_isLoading`)

## Import Organization
Imports are organized in this order:
1. Dart SDK imports
2. Flutter imports
3. Package imports (external dependencies)
4. Internal imports (relative paths)

## Asset Structure
Assets (images, fonts) are typically placed in:
- `assets/images/`: Image files
- `assets/fonts/`: Custom fonts
- Referenced in `pubspec.yaml` under `flutter: assets:`
