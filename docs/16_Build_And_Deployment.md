# Build and Deployment

## Overview
This document explains how to build and deploy the CodeNyx application for different platforms (iOS, Android, Web).

## Prerequisites

### Development Environment
- Flutter SDK 3.27.5+
- Dart SDK 3.6.1+
- Android Studio (for Android)
- Xcode (for iOS, macOS only)
- Git

### Platform-Specific Requirements

#### Android
- Android SDK
- Java JDK 8 or higher
- Android Studio with Android SDK

#### iOS
- macOS
- Xcode 14+
- CocoaPods
- Apple Developer Account (for App Store)

#### Web
- Chrome or Firefox browser
- No additional requirements

## Environment Setup

### 1. Clone Repository
```bash
git clone <repository-url>
cd CodeNyx
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Set Environment Variables
```bash
flutter run --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-key
```

## Building for Android

### Debug Build
```bash
flutter run
```

### Release Build (APK)
```bash
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

### Release Build (App Bundle)
```bash
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

### Android Signing

#### Create Keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### Configure Signing in build.gradle
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### Create key.properties
```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=your-key-alias
storeFile=/path/to/your/upload-keystore.jks
```

**Important**: Add `key.properties` to `.gitignore`

### Android Deployment

#### Google Play Store
1. Create app in Google Play Console
2. Generate signed APK or App Bundle
3. Upload to Play Console
4. Complete store listing
5. Submit for review

#### Internal Testing
```bash
flutter build apk --release
# Upload APK to Play Console internal testing
```

## Building for iOS

### Debug Build
```bash
flutter run
```

### Release Build
```bash
flutter build ios --release
```

### iOS Configuration

#### Bundle Identifier
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Set Bundle Identifier in General tab

#### Code Signing
1. Select your team in Xcode
2. Enable automatic signing
3. Or manually configure provisioning profiles

#### Info.plist Permissions
Add required permissions in `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Need camera access to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Need photo library access to select photos</string>
```

### iOS Deployment

#### TestFlight
1. Build release version
```bash
flutter build ios --release
```
2. Open in Xcode
3. Archive (Product → Archive)
4. Distribute to TestFlight
5. Invite testers

#### App Store
1. Follow TestFlight steps
2. Submit for App Store review
3. Complete store listing

## Building for Web

### Debug Build
```bash
flutter run -d chrome
```

### Release Build
```bash
flutter build web --release
```

**Output**: `build/web/`

### Web Deployment

#### Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize
firebase init

# Deploy
firebase deploy
```

#### Vercel
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

#### GitHub Pages
```bash
# Build
flutter build web --release

# Deploy to gh-pages branch
git subtree push --prefix build/web origin gh-pages
```

#### Netlify
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod --dir=build/web
```

## Build Optimization

### Android Optimization

#### ProGuard
Enabled by default in release builds:
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android.txt')
    }
}
```

#### Split APKs
```bash
flutter build apk --split-per-abi
```

### iOS Optimization

#### App Thinning
Xcode automatically handles app thinning for iOS.

#### Bitcode
Disabled by default in Flutter.

### Web Optimization

#### Web Compiler
```bash
flutter build web --release --web-renderer canvaskit
```

#### Tree Shaking
Automatically enabled in release builds.

## Continuous Integration/Deployment

### GitHub Actions

#### Android Build
```yaml
name: Build Android

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.5'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

#### iOS Build
```yaml
name: Build iOS

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.5'
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
```

#### Web Build
```yaml
name: Build Web

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.5'
      - run: flutter pub get
      - run: flutter build web --release
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

## Version Management

### Version Numbering
Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # major.minor.patch+build
```

### Increment Version
```bash
# Patch version (bug fixes)
# 1.0.0 → 1.0.1

# Minor version (new features)
# 1.0.0 → 1.1.0

# Major version (breaking changes)
# 1.0.0 → 2.0.0
```

## Build Verification

### Pre-Build Checklist
- [ ] All tests pass
- [ ] Code reviewed
- [ ] Dependencies updated
- [ ] Environment variables set
- [ ] Changelog updated
- [ ] Version incremented

### Post-Build Verification
- [ ] Build completes without errors
- [ ] App launches successfully
- [ ] Key features work
- [ ] No crashes
- [ ] Performance acceptable

## Deployment Checklist

### Android
- [ ] APK/App Bundle built
- [ ] Signed correctly
- [ ] Tested on device
- [ ] Play Console configured
- [ ] Store listing complete
- [ ] Screenshots uploaded
- [ ] Privacy policy added

### iOS
- [ ] Archive created
- [ ] Code signing valid
- [ ] Tested on device
- [ ] TestFlight configured
- [ ] App Store Connect configured
- [ ] Store listing complete
- [ ] Screenshots uploaded

### Web
- [ ] Web build successful
- [ ] Deployed to hosting
- [ ] HTTPS configured
- [ ] Custom domain (optional)
- [ ] Performance optimized

## Troubleshooting

### Build Failures

#### Android Build Fails
```bash
# Clean build
flutter clean
flutter pub get
flutter build apk --release
```

#### iOS Build Fails
```bash
# Clean build
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release
```

#### Web Build Fails
```bash
# Clean build
flutter clean
flutter pub get
flutter build web --release
```

### Signing Issues

#### Android Signing Error
- Verify keystore path
- Check keystore passwords
- Ensure key.properties exists

#### iOS Signing Error
- Verify team selection
- Check provisioning profiles
- Ensure bundle identifier is unique

### Runtime Issues

#### App Crashes on Launch
- Check environment variables
- Verify Supabase configuration
- Check for missing assets

#### Features Not Working
- Verify API keys
- Check network permissions
- Review console logs

## Performance Monitoring

### Firebase Performance Monitoring
```yaml
dependencies:
  firebase_performance: ^0.9.0
```

### Sentry Error Tracking
```yaml
dependencies:
  sentry_flutter: ^7.0.0
```

## Rollback Strategy

### Android Rollback
1. Upload previous APK to Play Console
2. Publish as new release
3. Or unpublish current version

### iOS Rollback
1. Upload previous build to TestFlight
2. Submit for expedited review
3. Or remove from App Store

### Web Rollback
1. Revert git commit
2. Redeploy
3. Or use hosting rollback feature

## Summary

| Platform | Build Command | Output | Deployment |
|----------|---------------|--------|------------|
| Android | `flutter build apk --release` | APK | Play Store |
| Android | `flutter build appbundle --release` | AAB | Play Store |
| iOS | `flutter build ios --release` | .app | App Store |
| Web | `flutter build web --release` | HTML/JS | Web hosting |

Follow platform-specific guidelines for successful deployment.
