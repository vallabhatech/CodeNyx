# Dependencies

## Overview
This document lists all dependencies used in the CodeNyx project, their purposes, and versions.

## pubspec.yaml

```yaml
name: codenyx
description: Hackathon companion app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.6.1 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter: ^2.5.0
  
  # State Management
  flutter_riverpod: ^2.6.1
  
  # Navigation
  go_router: ^14.6.2
  
  # Image Handling
  image_picker: ^1.1.2
  image: ^4.2.0
  
  # UI Components
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```

## Production Dependencies

### supabase_flutter ^2.5.0
**Purpose**: Supabase SDK for Flutter
**Features**:
- Authentication (OAuth, Email)
- Database (PostgreSQL)
- Real-time subscriptions
- Storage (file uploads)
- Edge functions

**Usage**:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
);

final client = Supabase.instance.client;
```

**Documentation**: https://supabase.com/docs/reference/dart

### flutter_riverpod ^2.6.1
**Purpose**: State management solution
**Features**:
- Compile-time safety
- Testability
- No need for BuildContext
- Provider composition

**Usage**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myProvider = Provider<int>((ref) => 42);

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(myProvider);
    return Text('$value');
  }
}
```

**Documentation**: https://riverpod.dev

### go_router ^14.6.2
**Purpose**: Declarative routing
**Features**:
- Type-safe navigation
- Deep linking
- Browser URL synchronization
- Route guards

**Usage**:
```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/feed', builder: (context, state) => FeedScreen()),
  ],
);
```

**Documentation**: https://pub.dev/packages/go_router

### image_picker ^1.1.2
**Purpose**: Pick images from gallery/camera
**Features**:
- Gallery picker
- Camera picker
- Multi-image support
- Platform-specific handling

**Usage**:
```dart
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.gallery);
```

**Documentation**: https://pub.dev/packages/image_picker

### image ^4.2.0
**Purpose**: Image manipulation and compression
**Features**:
- Image compression
- Resizing
- Format conversion
- Image processing

**Usage**:
```dart
import 'package/image/image.dart' as img;

final image = img.decodeImage(bytes);
final resized = img.copyResize(image, width: 800, height: 800);
final compressed = img.encodeJpg(resized, quality: 85);
```

**Documentation**: https://pub.dev/packages/image

### cupertino_icons ^1.0.8
**Purpose**: iOS-style icons
**Features**:
- Cupertino icon set
- iOS design language
- Default Flutter dependency

**Usage**:
```dart
import 'package:flutter/cupertino.dart';

Icon(CupertinoIcons.heart);
```

## Development Dependencies

### flutter_test
**Purpose**: Flutter testing framework
**Features**:
- Widget testing
- Unit testing
- Integration testing
- Golden testing

**Usage**:
```dart
testWidgets('my widget test', (tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.text('Hello'), findsOneWidget);
});
```

### flutter_lints ^4.0.0
**Purpose**: Dart linting rules
**Features**:
- Recommended Flutter lints
- Code quality checks
- Best practices enforcement

**Configuration**: `analysis_options.yaml`

## SDK Dependencies

### Flutter SDK
**Version**: 3.27.5
**Purpose**: UI framework
**Features**:
- Cross-platform rendering
- Hot reload
- Rich widget library
- Material Design

### Dart SDK
**Version**: 3.6.1
**Purpose**: Programming language
**Features**:
- Type safety
- Async/await
- Sound null safety
- JIT and AOT compilation

## Platform-Specific Dependencies

### Android
**Gradle**: Build system
**Kotlin**: Native Android code
**Android SDK**: Android APIs

### iOS
**CocoaPods**: Dependency manager
**Swift**: Native iOS code
**iOS SDK**: iOS APIs

### Web
**CanvasKit**: Web rendering engine
**Dart2JS**: JavaScript compiler

## Dependency Tree

```
codenyx
├── flutter (SDK)
├── supabase_flutter
│   ├── supabase (core)
│   └── gotrue (auth)
├── flutter_riverpod
│   └── riverpod (core)
├── go_router
│   └── flutter (SDK)
├── image_picker
│   └── flutter (platform plugins)
├── image
│   └── dart (SDK)
└── cupertino_icons
```

## Version Management

### Semantic Versioning
Dependencies follow semantic versioning:
- **Major**: Breaking changes
- **Minor**: New features (backwards compatible)
- **Patch**: Bug fixes (backwards compatible)

### Version Constraints
```yaml
supabase_flutter: ^2.5.0  # >=2.5.0 <3.0.0
flutter_riverpod: ^2.6.1  # >=2.6.1 <3.0.0
```

### Updating Dependencies

```bash
# Update all dependencies
flutter pub upgrade

# Update specific dependency
flutter pub upgrade supabase_flutter

# Check for outdated dependencies
flutter pub outdated
```

## Dependency Security

### Security Scanning
```bash
# Check for vulnerabilities
flutter pub deps
```

### Best Practices
1. Keep dependencies updated
2. Review changelinks before major updates
3. Use lock files for reproducibility
4. Audit dependencies regularly
5. Remove unused dependencies

## Dependency Alternatives

### State Management Alternatives
- **Provider**: Simpler, less powerful
- **Bloc**: More structured, boilerplate-heavy
- **GetX**: All-in-one, opinionated
- **GetIt**: Service locator pattern

### Navigation Alternatives
- **Navigator 2.0**: Lower-level, more control
- **AutoRoute**: Code generation, type-safe
- **Beamer**: Declarative, powerful

### Image Handling Alternatives
- **flutter_image_compress**: Alternative compression
- **photo_view**: Image viewing with zoom
- **cached_network_image**: Network image caching

## Adding New Dependencies

### Steps
1. Search on pub.dev
2. Check version compatibility
3. Add to pubspec.yaml
4. Run `flutter pub get`
5. Import and use

### Example
```yaml
dependencies:
  http: ^1.2.0
```

```bash
flutter pub get
```

```dart
import 'package:http/http.dart' as http;
```

## Removing Dependencies

### Steps
1. Remove from pubspec.yaml
2. Run `flutter pub get`
3. Remove imports from code
4. Test thoroughly

## Troubleshooting

### Dependency Conflicts
**Problem**: Version conflicts between dependencies
**Solution**:
```bash
flutter pub deps
# Resolve by adjusting versions or using dependency_overrides
```

### Platform Plugin Issues
**Problem**: Plugin not working on specific platform
**Solution**:
- Check platform-specific configuration
- Verify native setup (AndroidManifest.xml, Info.plist)
- Check plugin documentation

### Outdated Lock File
**Problem**: pubspec.lock out of sync
**Solution**:
```bash
flutter pub get
# or delete pubspec.lock and run again
```

## Dependency Optimization

### Tree Shaking
Flutter automatically removes unused code in release builds.

### Code Splitting
Web builds support code splitting for faster loading.

### Lazy Loading
Load dependencies only when needed using deferred imports.

## Summary

| Dependency | Version | Purpose | Category |
|------------|---------|---------|----------|
| flutter | 3.27.5 | UI framework | SDK |
| dart | 3.6.1 | Language | SDK |
| supabase_flutter | ^2.5.0 | Backend integration | Production |
| flutter_riverpod | ^2.6.1 | State management | Production |
| go_router | ^14.6.2 | Navigation | Production |
| image_picker | ^1.1.2 | Image selection | Production |
| image | ^4.2.0 | Image processing | Production |
| cupertino_icons | ^1.0.8 | iOS icons | Production |
| flutter_test | - | Testing | Development |
| flutter_lints | ^4.0.0 | Linting | Development |

All production dependencies are actively maintained and widely used in the Flutter ecosystem.
