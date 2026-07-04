# Configuration

## Overview
This document explains all configuration files in the CodeNyx project and their purposes.

## Configuration Files

### pubspec.yaml
**Location**: Root directory
**Purpose**: Project metadata and dependencies

**Key Sections**:
```yaml
name: codenyx                    # Project name
description: Hackathon companion app
version: 1.0.0+1                # Version + build number
publish_to: 'none'               # Don't publish to pub.dev

environment:
  sdk: '>=3.6.1 <4.0.0'         # Dart SDK constraint

dependencies:
  # Production dependencies

dev_dependencies:
  # Development dependencies

flutter:
  uses-material-design: true    # Use Material Design
  # assets:
  #   - assets/images/
  # fonts:
  #   - family: CustomFont
```

**Important Notes**:
- Version format: `major.minor.patch+build`
- SDK constraint ensures compatibility
- Assets and fonts can be added here

### analysis_options.yaml
**Location**: Root directory
**Purpose**: Dart analyzer configuration

**Content**:
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Custom lint rules
    # avoid_print: false
    # prefer_single_quotes: true
```

**Available Lint Rules**:
- `avoid_print`: Discourage print statements
- `prefer_single_quotes`: Use single quotes
- `prefer_const_constructors`: Use const where possible
- `avoid_unnecessary_containers`: Remove unnecessary containers

**Running Analysis**:
```bash
flutter analyze
```

### .gitignore
**Location**: Root directory
**Purpose**: Files to exclude from Git

**Content**:
```
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store

# IntelliJ
*.iml
.idea/

# VS Code
.vscode/

# Flutter/Dart
.dart_tool/
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/
/coverage/

# Symbolication
app.*.symbols

# Obfuscation
app.*.map.json

# Android
/android/app/debug
/android/app/profile
/android/app/release

# iOS
/ios/.symlinks/
/ios/Pods/
```

**Purpose**:
- Exclude build artifacts
- Exclude IDE files
- Exclude sensitive data
- Keep repository clean

### android/app/build.gradle
**Location**: `android/app/`
**Purpose**: Android build configuration

**Key Sections**:
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.example.codenyx"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt')
        }
    }
}
```

**Important Settings**:
- `minSdkVersion`: Minimum Android version (5.0+)
- `targetSdkVersion`: Target Android version
- `applicationId`: Unique app identifier

### android/app/src/main/AndroidManifest.xml
**Location**: `android/app/src/main/`
**Purpose**: Android app manifest

**Key Permissions**:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**Deep Link Configuration**:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="io.supabase.codenyx"
    android:host="auth/callback" />
</intent-filter>
```

### ios/Runner/Info.plist
**Location**: `ios/Runner/`
**Purpose**: iOS app configuration

**Key Settings**:
```xml
<key>CFBundleIdentifier</key>
<string>com.example.codenyx</string>

<key>CFBundleVersion</key>
<string>1</string>

<key>NSCameraUsageDescription</key>
<string>Need camera access to take photos</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Need photo library access to select photos</string>
```

**Deep Link Configuration**:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>io.supabase.codenyx</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.codenyx</string>
    </array>
  </dict>
</array>
```

### ios/Podfile
**Location**: `ios/`
**Purpose**: iOS dependency management

**Content**:
```ruby
platform :ios, '12.0'

use_frameworks!
inhibit_all_warnings!

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Pods', 'Target Support Files', 'Pods-Runner', 'generated.xcodebuild_settings'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist"
  end
  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found"
end

target 'Runner' do
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

**Installing Pods**:
```bash
cd ios
pod install
```

### web/index.html
**Location**: `web/`
**Purpose**: Web entry point

**Content**:
```html
<!DOCTYPE html>
<html>
<head>
  <base href="/">
  <title>CodeNyx</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

### web/manifest.json
**Location**: `web/`
**Purpose**: Web app manifest

**Content**:
```json
{
  "name": "CodeNyx",
  "short_name": "CodeNyx",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#6C63FF",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    }
  ]
}
```

## App Configuration

### Theme Configuration
**Location**: `lib/core/theme/app_theme.dart`

**Key Settings**:
```dart
class AppTheme {
  // Colors
  static const Color primaryBackground = Color(0xFF0F0F1A);
  static const Color accentPrimary = Color(0xFF6C63FF);
  
  // Spacing
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
}
```

### Constants Configuration
**Location**: `lib/core/constants/app_constants.dart`

**Example**:
```dart
class AppConstants {
  static const String appName = 'CodeNyx';
  static const int maxImageSizeKB = 500;
  static const int maxImageWidth = 800;
  static const int maxImageHeight = 800;
}
```

## Environment Configuration

### Development
```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

### Production
Set environment variables in platform-specific files (see Environment Variables documentation).

## Build Configuration

### Debug Build
```bash
flutter run
```

**Characteristics**:
- Fast compilation
- Debug symbols included
- Hot reload enabled
- Not optimized

### Release Build

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

**Characteristics**:
- Optimized code
- Smaller size
- Faster performance
- No debug symbols

## Router Configuration
**Location**: `lib/app.dart`

**GoRouter Configuration**:
```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => AuthScreen()),
    GoRoute(path: '/feed', builder: (context, state) => FeedScreen()),
    // ... more routes
  ],
  errorBuilder: (context, state) => ErrorScreen(),
);
```

## Supabase Configuration
**Location**: `lib/main.dart`

**Initialization**:
```dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

## Platform-Specific Configuration

### Android
- **Keystore**: For signing release builds
- **ProGuard**: Code obfuscation
- **Gradle**: Build optimization

### iOS
- **Signing**: Apple Developer account
- **Provisioning Profiles**: App distribution
- **Info.plist**: App permissions

### Web
- **Firebase Hosting**: Web deployment
- **Service Workers**: Offline support
- **PWA**: Progressive web app features

## Configuration Best Practices

1. **Version Control**: Commit configuration files (except secrets)
2. **Environment Separation**: Use different configs for dev/staging/prod
3. **Documentation**: Document all configuration changes
4. **Validation**: Validate configuration on app start
5. **Security**: Never commit secrets or keys
6. **Consistency**: Keep configuration consistent across platforms

## Configuration Validation

### Startup Validation
```dart
void validateConfiguration() {
  // Validate environment variables
  // Validate theme constants
  // Validate router configuration
  // Validate Supabase configuration
}
```

### Build Validation
```bash
flutter analyze
flutter test
flutter build apk --release
```

## Troubleshooting

### Configuration Not Applied
**Problem**: Changes not reflected
**Solution**:
- Run `flutter clean`
- Run `flutter pub get`
- Restart the app

### Platform-Specific Issues
**Problem**: Config works on one platform but not another
**Solution**:
- Check platform-specific config files
- Verify platform permissions
- Check platform SDK versions

### Build Failures
**Problem**: Build fails after config change
**Solution**:
- Check for syntax errors
- Verify dependency versions
- Check platform-specific requirements

## Summary

| File | Purpose | Platform |
|------|---------|----------|
| pubspec.yaml | Dependencies & metadata | All |
| analysis_options.yaml | Linting rules | All |
| .gitignore | Git exclusions | All |
| build.gradle | Android build config | Android |
| AndroidManifest.xml | Android manifest | Android |
| Info.plist | iOS configuration | iOS |
| Podfile | iOS dependencies | iOS |
| index.html | Web entry point | Web |
| manifest.json | Web app manifest | Web |
| app_theme.dart | Theme configuration | All |
| app_constants.dart | App constants | All |
| app.dart | Router configuration | All |
| main.dart | App initialization | All |

All configuration files should be properly maintained and documented to ensure smooth development and deployment.
