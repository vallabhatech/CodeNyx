# Design Patterns

## Overview
This document explains the design patterns used in the CodeNyx application.

## Architectural Patterns

### 1. Layered Architecture

**Description**: The application is organized into distinct layers with clear responsibilities.

**Layers**:
- **Presentation Layer**: UI screens and widgets
- **Business Logic Layer**: Repositories and services
- **Data Layer**: Supabase client and session service
- **Infrastructure Layer**: Supabase backend

**Benefits**:
- Separation of concerns
- Easy to test
- Maintainable
- Scalable

**Example**:
```dart
// Presentation Layer
class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);
    return PostList(posts: posts);
  }
}

// Business Logic Layer
class FeedRepository {
  Future<List<Post>> getPosts() {
    return _client.from('posts').select();
  }
}

// Data Layer
class SupabaseClient {
  // Supabase client implementation
}
```

### 2. Feature-Based Architecture

**Description**: The application is organized by features rather than technical layers.

**Structure**:
```
features/
├── social_feed/
├── chat/
├── admin/
└── complaints/
```

**Benefits**:
- Easy to add new features
- Clear feature boundaries
- Easy to delete features
- Better code organization

**Example**:
```dart
// Each feature is self-contained
features/social_feed/
├── feed_screen.dart
├── feed_repository.dart
└── post_state.dart
```

## Creational Patterns

### 3. Singleton Pattern

**Description**: Ensures a class has only one instance and provides a global point of access.

**Usage**:
- Supabase client
- Session service
- Post state cache

**Example**:
```dart
class SessionService {
  static final SessionService _instance = SessionService._internal();
  
  factory SessionService() {
    return _instance;
  }
  
  SessionService._internal();
  
  static Future<Map<String, dynamic>> getSession() async {
    // Implementation
  }
}
```

### 4. Factory Pattern

**Description**: Creates objects without specifying the exact class of object that will be created.

**Usage**:
- Creating models from JSON
- Creating widgets based on data

**Example**:
```dart
class MessageModel {
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      teamId: json['team_id'],
      message: json['message'],
    );
  }
}
```

## Structural Patterns

### 5. Repository Pattern

**Description**: Mediates between the domain and data mapping layers, acting like an in-memory domain object collection.

**Usage**:
- FeedRepository
- ChatRepository
- ComplaintsRepository

**Benefits**:
- Abstracts data source
- Centralizes data access logic
- Easy to test with mocks
- Can switch data sources

**Example**:
```dart
abstract class FeedRepositoryInterface {
  Future<List<Post>> getPosts();
  Future<void> createPost(String content);
}

class FeedRepository implements FeedRepositoryInterface {
  final SupabaseClient _client;
  
  @override
  Future<List<Post>> getPosts() {
    return _client.from('posts').select();
  }
  
  @override
  Future<void> createPost(String content) {
    return _client.from('posts').insert({'content': content});
  }
}
```

### 6. Provider Pattern (Riverpod)

**Description**: Provides a way to access state and dependencies across the widget tree.

**Usage**:
- State management
- Dependency injection
- Service location

**Benefits**:
- Type-safe
- No BuildContext needed
- Easy to test
- Excellent performance

**Example**:
```dart
// Define provider
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

// Use provider
class FeedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(feedRepositoryProvider);
    return FeedWidget(repository: repository);
  }
}
```

### 7. Observer Pattern

**Description**: Defines a subscription mechanism to notify multiple objects about any events that happen to the object they are observing.

**Usage**:
- StreamProvider for real-time data
- PostState for like updates
- Auth state changes

**Example**:
```dart
// Subject
class PostState {
  final _controller = StreamController<Post>();
  
  Stream<Post> get stream => _controller.stream;
  
  void updatePost(Post post) {
    _controller.add(post);
  }
}

// Observer
class FeedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postStreamProvider);
    return PostList(posts: posts);
  }
}
```

## Behavioral Patterns

### 8. Strategy Pattern

**Description**: Defines a family of algorithms, encapsulates each one, and makes them interchangeable.

**Usage**:
- Image compression strategies
- Error handling strategies

**Example**:
```dart
abstract class CompressionStrategy {
  List<int> compress(List<int> bytes);
}

class JpegCompression implements CompressionStrategy {
  @override
  List<int> compress(List<int> bytes) {
    return img.encodeJpg(img.decodeImage(bytes)!);
  }
}

class PngCompression implements CompressionStrategy {
  @override
  List<int> compress(List<int> bytes) {
    return img.encodePng(img.decodeImage(bytes)!);
  }
}
```

### 9. Command Pattern

**Description**: Encapsulates a request as an object, thereby allowing parameterization of clients with different requests.

**Usage**:
- Undo/redo operations
- Action buttons

**Example**:
```dart
abstract class Command {
  void execute();
  void undo();
}

class LikePostCommand implements Command {
  final FeedRepository _repository;
  final String _postId;
  
  LikePostCommand(this._repository, this._postId);
  
  @override
  void execute() {
    _repository.toggleLike(_postId, false);
  }
  
  @override
  void undo() {
    _repository.toggleLike(_postId, true);
  }
}
```

### 10. Builder Pattern

**Description**: Separates the construction of complex objects from their representation.

**Usage**:
- Building complex widgets
- Building API requests

**Example**:
```dart
class PostBuilder {
  String? _content;
  String? _imageUrl;
  
  PostBuilder setContent(String content) {
    _content = content;
    return this;
  }
  
  PostBuilder setImageUrl(String imageUrl) {
    _imageUrl = imageUrl;
    return this;
  }
  
  Post build() {
    return Post(
      content: _content!,
      imageUrl: _imageUrl,
    );
  }
}

// Usage
final post = PostBuilder()
    .setContent('Hello')
    .setImageUrl('https://...')
    .build();
```

## Flutter-Specific Patterns

### 11. BLoC Pattern (Alternative)

**Description**: Business Logic Component pattern separates presentation from business logic.

**Note**: CodeNyx uses Riverpod instead of BLoC, but the pattern is similar in concept.

### 12. State Pattern

**Description**: Allows an object to alter its behavior when its internal state changes.

**Usage**:
- Loading, success, error states
- Authentication states

**Example**:
```dart
enum PostState {
  initial,
  loading,
  loaded,
  error,
}

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedStateProvider);
    
    switch (state) {
      case PostState.loading:
        return CircularProgressIndicator();
      case PostState.loaded:
        return PostList();
      case PostState.error:
        return ErrorDisplay();
      default:
        return Container();
    }
  }
}
```

## Data Patterns

### 13. Data Mapper Pattern

**Description**: Moves data between objects and a database while keeping them independent.

**Usage**:
- Converting database records to models
- Converting models to JSON

**Example**:
```dart
class PostMapper {
  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
  
  static Map<String, dynamic> toMap(Post post) {
    return {
      'id': post.id,
      'content': post.content,
      'created_at': post.createdAt.toIso8601String(),
    };
  }
}
```

### 14. Cache-Aside Pattern

**Description**: Lazy loads data on demand and caches it for future use.

**Usage**:
- PostState cache for like counts
- Image caching

**Example**:
```dart
class PostState {
  final _cache = <String, PostData>{};
  
  PostData getPost(String postId) {
    if (_cache.containsKey(postId)) {
      return _cache[postId]!;
    }
    // Fetch from database
    final data = _fetchFromDatabase(postId);
    _cache[postId] = data;
    return data;
  }
}
```

## UI Patterns

### 15. Composition Pattern

**Description**: Composes objects into tree structures to represent part-whole hierarchies.

**Usage**:
- Widget tree composition
- Building complex UIs from simple widgets

**Example**:
```dart
class PostCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          PostHeader(),
          PostContent(),
          PostActions(),
        ],
      ),
    );
  }
}
```

### 16. Decorator Pattern

**Description**: Attaches additional responsibilities to an object dynamically.

**Usage**:
- Wrapping widgets with additional functionality
- Adding borders, shadows, etc.

**Example**:
```dart
class DecoratedPostCard extends StatelessWidget {
  final Widget child;
  
  const DecoratedPostCard({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// Usage
DecoratedPostCard(child: PostCard())
```

## Anti-Patterns to Avoid

### 1. God Object
**Avoid**: Having one class that does everything.
**Solution**: Use single responsibility principle and feature-based architecture.

### 2. Spaghetti Code
**Avoid**: Tangled code with no clear structure.
**Solution**: Use layered architecture and clear separation of concerns.

### 3. Magic Numbers
**Avoid**: Hardcoded numbers without explanation.
**Solution**: Use named constants in AppConstants.

### 4. Tight Coupling
**Avoid**: Classes that depend heavily on each other.
**Solution**: Use dependency injection and interfaces.

### 5. Premature Optimization
**Avoid**: Optimizing before measuring.
**Solution**: Profile first, then optimize bottlenecks.

## Summary

CodeNyx uses several design patterns:
- **Layered Architecture**: Clear separation of concerns
- **Feature-Based Architecture**: Organized by functionality
- **Repository Pattern**: Abstracts data access
- **Provider Pattern**: State management with Riverpod
- **Observer Pattern**: Real-time updates
- **Singleton Pattern**: Single instance services
- **Factory Pattern**: Object creation
- **Cache-Aside Pattern**: Performance optimization

These patterns make the codebase maintainable, testable, and scalable.
