# Testing

## Overview
This document explains the testing approach for the CodeNyx project. While the project currently doesn't have extensive test coverage, this guide provides recommendations for implementing a comprehensive testing strategy.

## Testing Strategy

### Test Pyramid

```
        /\
       /E2E\      (End-to-End Tests)
      /------\
     /Integration\ (Integration Tests)
    /------------\
   /  Unit Tests  \ (Unit Tests)
  /----------------\
```

**Recommendations**:
- **70% Unit Tests**: Test individual functions and classes
- **20% Integration Tests**: Test feature integration
- **10% E2E Tests**: Test complete user flows

## Unit Testing

### Purpose
Test individual functions, classes, and methods in isolation.

### Setup

**Dependencies** (add to pubspec.yaml):
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

### Example: Repository Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([SupabaseClient])
import 'feed_repository_test.mocks.dart';

void main() {
  late FeedRepository repository;
  late MockSupabaseClient mockClient;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = FeedRepository();
  });

  group('FeedRepository', () {
    test('createPost should insert post', () async {
      // Arrange
      const content = 'Test post';
      
      // Act
      await repository.createPost(content);
      
      // Assert
      verify(mockClient.from('posts').insert(any));
    });

    test('getPosts should return list of posts', () async {
      // Arrange
      final expectedPosts = [
        {'id': '1', 'content': 'Post 1'},
        {'id': '2', 'content': 'Post 2'},
      ];
      
      when(mockClient.from('posts').select())
          .thenAnswer((_) async => expectedPosts);
      
      // Act
      final posts = await repository.getPosts();
      
      // Assert
      expect(posts.length, 2);
      expect(posts[0]['content'], 'Post 1');
    });

    test('toggleLike should handle like', () async {
      // Arrange
      const postId = 'post-123';
      
      // Act
      await repository.toggleLike(postId, false);
      
      // Assert
      verify(mockClient.from('likes').insert(any));
    });
  });
}
```

### Example: Service Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('ImageUploadService', () {
    test('compressImage should reduce size', () {
      // Arrange
      final originalBytes = List.filled(1000000, 0); // 1MB
      
      // Act
      final compressed = ImageUploadService.compressImage(originalBytes);
      
      // Assert
      expect(compressed.length, lessThan(originalBytes.length));
    });

    test('compressImage should maintain quality', () {
      // Arrange
      final testImage = img.Image(width: 1000, height: 1000);
      
      // Act
      final compressed = ImageUploadService.compressImage(testImage);
      
      // Assert
      expect(compressed, isNotNull);
    });
  });
}
```

### Example: Provider Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('chatRepositoryProvider returns ChatRepository', () {
    // Arrange
    final container = ProviderContainer();
    
    // Act
    final repository = container.read(chatRepositoryProvider);
    
    // Assert
    expect(repository, isA<ChatRepository>());
    
    container.dispose();
  });
});
```

## Widget Testing

### Purpose
Test individual widgets and their interactions.

### Example: Screen Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codenyx/features/social_feed/feed_screen.dart';

void main() {
  testWidgets('FeedScreen displays loading indicator', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: FeedScreen(),
      ),
    );
    
    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('FeedScreen displays post cards', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: FeedScreen(),
      ),
    );
    
    // Wait for data to load
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.byType(PostCard), findsWidgets);
  });

  testWidgets('tapping like button toggles like', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: FeedScreen(),
      ),
    );
    await tester.pumpAndSettle();
    
    // Act
    final likeButton = find.byIcon(Icons.favorite_border);
    await tester.tap(likeButton);
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
});
```

### Example: Widget Test with Mocks

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('CreatePostScreen submits post', (tester) async {
    // Arrange
    final mockRepository = MockFeedRepository();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp(
          home: CreatePostScreen(),
        ),
      ),
    );
    
    // Act
    await tester.enterText(find.byType(TextField), 'Test post');
    await tester.tap(find.text('Post'));
    await tester.pumpAndSettle();
    
    // Assert
    verify(mockRepository.createPost('Test post'));
  });
}
```

## Integration Testing

### Purpose
Test complete features and user flows.

### Setup

**Dependencies**:
```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
```

### Example: Authentication Flow

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:codenyx/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('authentication flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Tap sign in button
    await tester.tap(find.text('Sign in with Google'));
    await tester.pumpAndSettle();
    
    // Verify navigation to feed
    expect(find.text('Social Feed'), findsOneWidget);
  });
}
```

### Example: Create Post Flow

```dart
testWidgets('create post flow', (tester) async {
  app.main();
  await tester.pumpAndSettle();
  
  // Navigate to create post
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  
  // Enter post content
  await tester.enterText(find.byType(TextField), 'Test post');
  
  // Submit post
  await tester.tap(find.text('Post'));
  await tester.pumpAndSettle();
  
  // Verify post created
  expect(find.text('Test post'), findsOneWidget);
});
```

## End-to-End Testing

### Purpose
Test complete user journeys across the app.

### Tools
- **Appium**: Cross-platform E2E testing
- **Detox**: iOS E2E testing
- **Espresso**: Android E2E testing

### Example: Complete User Journey

```dart
// Using Appium
describe('Complete user journey', () => {
  it('should allow user to sign in and create post', async () => {
    // Sign in
    await driver.elementByAccessibilityId('sign_in_button').click();
    await driver.sleep(5000); // Wait for OAuth
    
    // Navigate to feed
    expect(await driver.elementByAccessibilityId('feed_title').text())
      .toBe('Social Feed');
    
    // Create post
    await driver.elementByAccessibilityId('fab_button').click();
    await driver.elementByAccessibilityId('post_input').sendKeys('Test post');
    await driver.elementByAccessibilityId('submit_button').click();
    
    // Verify post created
    expect(await driver.elementByAccessibilityId('post_content').text())
      .toBe('Test post');
  });
});
```

## Testing Best Practices

### 1. Arrange-Act-Assert Pattern

```dart
test('example', () {
  // Arrange
  final input = 'test';
  
  // Act
  final result = function(input);
  
  // Assert
  expect(result, equals('expected'));
});
```

### 2. Test Descriptions

```dart
test('should return empty list when no posts exist', () {
  // Clear and descriptive
});

test('getPosts returns empty list', () {
  // Less descriptive
});
```

### 3. Test Isolation

```dart
setUp(() {
  // Reset state before each test
});

tearDown(() {
  // Cleanup after each test
});
```

### 4. Mock External Dependencies

```dart
// Mock Supabase client
final mockClient = MockSupabaseClient();

// Mock repositories
final mockRepository = MockFeedRepository();
```

### 5. Test Edge Cases

```dart
test('handles empty input', () {});
test('handles null values', () {});
test('handles network errors', () {});
test('handles timeout', () {});
```

## Test Coverage

### Measuring Coverage

```bash
# Install coverage tool
flutter pub global activate coverage

# Run tests with coverage
flutter test --coverage

# Generate report
genhtml coverage/lcov.info -o coverage/html
```

### Coverage Goals

| Component | Target Coverage |
|-----------|-----------------|
| Repositories | 90%+ |
| Services | 90%+ |
| Providers | 80%+ |
| Screens | 70%+ |
| Models | 95%+ |

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```

## Current Test Status

### Existing Tests
- None currently implemented

### Recommended Tests to Add

1. **Repository Tests**
   - FeedRepository tests
   - ChatRepository tests
   - ComplaintsRepository tests
   - Admin repository tests

2. **Service Tests**
   - ImageUploadService tests
   - SessionService tests

3. **Widget Tests**
   - FeedScreen tests
   - ChatScreen tests
   - CreatePostScreen tests
   - Admin screens tests

4. **Integration Tests**
   - Authentication flow
   - Create post flow
   - Send message flow
   - Admin operations

## Testing Checklist

- [ ] Add unit tests for all repositories
- [ ] Add unit tests for all services
- [ ] Add widget tests for all screens
- [ ] Add integration tests for key flows
- [ ] Set up test coverage reporting
- [ ] Configure CI/CD test runs
- [ ] Add E2E tests for critical paths
- [ ] Document test execution

## Running Tests

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Specific Test File
```bash
flutter test test/feed_repository_test.dart
```

### With Coverage
```bash
flutter test --coverage
```

## Summary

While CodeNyx currently lacks comprehensive test coverage, implementing the testing strategy outlined above will ensure:
- Code reliability
- Easier refactoring
- Fewer bugs in production
- Better documentation
- Confidence in deployments

Start with unit tests for repositories and services, then add widget tests for screens, and finally integration tests for complete flows.
