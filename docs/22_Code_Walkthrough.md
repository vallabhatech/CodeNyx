# Code Walkthrough

## Overview
This document provides a step-by-step walkthrough of the CodeNyx codebase, explaining how the application works from startup to user interactions.

## Application Startup

### 1. main.dart - Entry Point

```dart
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  
  // Run the app
  runApp(const CodeNyxApp());
}
```

**What happens**:
1. Flutter bindings initialized
2. Supabase client configured with credentials
3. App widget created and run

### 2. CodeNyxApp - Root Widget

```dart
class CodeNyxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData.dark(),
      ),
    );
  }
}
```

**What happens**:
1. ProviderScope wraps the app for Riverpod
2. MaterialApp.router configured with go_router
3. Dark theme applied

### 3. app.dart - Router Configuration

```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => AuthScreen()),
    GoRoute(path: '/feed', builder: (context, state) => FeedScreen()),
    GoRoute(path: '/chat', builder: (context, state) => ChatScreen()),
    // ... more routes
  ],
);
```

**What happens**:
1. All app routes defined
2. Default route is AuthScreen
3. Navigation configured

## Authentication Flow

### User Opens App

1. **App Launch**: `main.dart` executes
2. **Router Initialization**: Routes loaded in `app.dart`
3. **Default Route**: User sees `AuthScreen`

### User Signs In

**AuthScreen.dart**:
```dart
Future<void> _signInWithGoogle() async {
  try {
    // Trigger Google OAuth
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb 
        ? null 
        : 'io.supabase.codenyx://auth/callback',
    );
  } catch (e) {
    _showError('Sign in failed: $e');
  }
}
```

**What happens**:
1. User taps "Sign in with Google"
2. Supabase OAuth flow initiated
3. User redirected to Google
4. User completes OAuth
5. Redirected back to app
6. Session created
7. User profile fetched
8. Session saved
9. Navigated to feed

## Social Feed Flow

### Loading the Feed

**FeedScreen.dart - initState**:
```dart
@override
void initState() {
  super.initState();
  _loadPosts();
}

Future<void> _loadPosts() async {
  setState(() => _isLoading = true);
  try {
    final posts = await _repository.getPosts();
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    _showError(e.toString());
  }
}
```

**FeedRepository.dart - getPosts**:
```dart
Future<List<Map<String, dynamic>>> getPosts({
  int page = 0,
  int limit = 10,
}) async {
  final response = await _client
      .from('posts')
      .select()
      .order('created_at', ascending: false)
      .range(page * limit, (page + 1) * limit - 1);
  
  final posts = List<Map<String, dynamic>>.from(response);
  
  // Resolve user names
  for (var post in posts) {
    final userId = post['user_id'];
    final userName = await resolveUserName(userId);
    post['user_name'] = userName;
  }
  
  return posts;
}
```

**What happens**:
1. FeedScreen initializes
2. _loadPosts() called
3. Repository fetches posts from Supabase
4. Posts ordered by created_at (newest first)
5. Pagination applied (10 posts per page)
6. User names resolved from profiles table
7. Posts returned to screen
8. UI updated with posts

### Creating a Post

**CreatePostScreen.dart**:
```dart
Future<void> _submitPost() async {
  final content = _controller.text.trim();
  String? imageUrl;
  
  // Handle image upload if selected
  if (_selectedImage != null) {
    imageUrl = await _imageService.pickAndUploadImage();
  }
  
  // Create post
  await _repository.createPost(content, imageUrl);
  
  // Navigate back
  Navigator.pop(context);
}
```

**ImageUploadService.dart**:
```dart
Future<String?> pickAndUploadImage() async {
  // Pick image
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);
  if (image == null) return null;
  
  // Read and compress
  final bytes = await File(image.path).readAsBytes();
  final compressed = compressImage(bytes);
  
  // Upload to Supabase Storage
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  await _client.storage.from('post-images').upload(fileName, compressed);
  
  // Return public URL
  return _client.storage.from('post-images').getPublicUrl(fileName);
}
```

**What happens**:
1. User enters text and optionally selects image
2. If image selected:
   - Image picked from gallery
   - Image compressed to 800x800, 85% quality
   - Size checked (<500KB)
   - Uploaded to Supabase Storage
   - Public URL returned
3. Repository.createPost() called
4. Post inserted into database
5. User navigated back to feed
6. Feed refreshes to show new post

### Liking a Post

**FeedScreen.dart**:
```dart
Future<void> _toggleLike(String postId) async {
  final postState = PostState();
  final currentState = postState.getPostState(postId);
  final isLiked = currentState?.userLiked ?? false;
  
  await _repository.toggleLike(postId, isLiked);
  
  // Update cache for instant UI feedback
  postState.updateUserLiked(postId, !isLiked);
  postState.updateLikeCount(postId, 
    (currentState?.likeCount ?? 0) + (isLiked ? -1 : 1)
  );
}
```

**FeedRepository.dart**:
```dart
Future<void> toggleLike(String postId, bool isLiked) async {
  final userId = _client.auth.currentUser?.id;
  
  if (isLiked) {
    // Unlike
    await _client.from('likes').delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
    await _client.rpc('decrement_like_count', 
        params: {'post_id': postId});
  } else {
    // Like
    await _client.from('likes').insert({
      'post_id': postId,
      'user_id': userId,
    });
    await _client.rpc('increment_like_count', 
        params: {'post_id': postId});
  }
}
```

**What happens**:
1. User taps like button
2. PostState checks current like status
3. Repository toggles like in database
4. If liked: delete from likes table, decrement count
5. If not liked: insert to likes table, increment count
6. PostState cache updated instantly
7. UI updates immediately

## Chat Flow

### Sending a Message

**ChatScreen.dart**:
```dart
Future<void> _sendMessage() async {
  final message = _controller.text.trim();
  if (message.isEmpty) return;
  
  await _repository.sendMessage(message);
  _controller.clear();
}
```

**ChatRepository.dart**:
```dart
Future<void> sendMessage(String message) async {
  final session = await SessionService.getSession();
  final teamId = session['teamId'];
  final userId = _client.auth.currentUser?.id;
  
  await _client.from('messages').insert({
    'team_id': teamId,
    'user_id': userId,
    'message': message,
    'created_at': DateTime.now().toIso8601String(),
  });
}
```

**What happens**:
1. User types message
2. User taps send
3. Repository inserts message into database
4. Supabase Realtime broadcasts change
5. All team members receive new message
6. UI auto-updates
7. Chat auto-scrolls to bottom

### Receiving Real-time Messages

**ChatScreen.dart**:
```dart
@override
Widget build(BuildContext context) {
  final messagesAsync = ref.watch(chatMessagesProvider(teamId));
  
  return messagesAsync.when(
    data: (messages) => ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return MessageBubble(message: messages[index]);
      },
    ),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => ErrorDisplay(error: error),
  );
}
```

**ChatProvider.dart**:
```dart
final chatMessagesProvider = StreamProvider.family
    .autoDispose<List<MessageModel>, String>((ref, teamId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchTeamMessages(teamId);
});
```

**ChatRepository.dart**:
```dart
Stream<List<MessageModel>> watchTeamMessages(String teamId) {
  return _client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('team_id', teamId)
      .order('created_at', ascending: true)
      .map((data) => data.map((e) => MessageModel.fromJson(e)).toList());
}
```

**What happens**:
1. ChatScreen subscribes to message stream
2. Repository creates Supabase realtime subscription
3. Supabase listens for INSERT events on messages table
4. When new message inserted:
   - Supabase detects change
   - Stream emits new message
   - StreamProvider updates
   - UI rebuilds with new message
   - Auto-scroll to bottom

## Admin Flow

### Creating an Announcement

**ManageAnnouncementsScreen.dart**:
```dart
Future<void> _publishAnnouncement() async {
  final title = _titleController.text.trim();
  final message = _messageController.text.trim();
  
  if (title.isEmpty || message.isEmpty) {
    _showError('Please fill all fields');
    return;
  }
  
  await _repository.createAnnouncement(title, message);
  
  _titleController.clear();
  _messageController.clear();
  _loadAnnouncements();
}
```

**What happens**:
1. Admin enters title and message
2. Admin taps publish
3. Repository inserts announcement
4. Announcements list refreshed
5. Success message shown

## Complaints Flow

### Submitting a Complaint

**UserComplaintsScreen.dart**:
```dart
Future<void> _submitComplaint() async {
  final message = _messageController.text.trim();
  if (message.isEmpty) {
    _showSnackBar('Please enter your complaint');
    return;
  }
  
  setState(() => _isSubmitting = true);
  
  try {
    await _repository.createComplaint(message);
    _messageController.clear();
    await _loadComplaints();
    _showSnackBar('Complaint submitted successfully');
  } catch (e) {
    _showSnackBar('Failed to submit: $e', isError: true);
  } finally {
    setState(() => _isSubmitting = false);
  }
}
```

**ComplaintsRepository.dart**:
```dart
Future<void> createComplaint(String message) async {
  final userEmail = _client.auth.currentUser?.email;
  final session = await SessionService.getSession();
  final teamId = session['teamId']?.toString();
  
  if (userEmail == null || teamId == null || teamId.isEmpty) {
    throw Exception('Unable to resolve complaint session.');
  }
  
  await _client.from('complaints').insert({
    'user_email': userEmail,
    'team_id': teamId,
    'message': message.trim(),
    'status': 'pending',
  });
}
```

**What happens**:
1. User enters complaint message
2. User taps submit
3. Session service retrieves team ID and email
4. Repository inserts complaint
5. Complaints list refreshed
6. Success message shown

## Navigation Flow

### Using go_router

```dart
// Navigate to feed
context.push('/feed');

// Navigate with parameters
context.push('/post-detail', extra: postId);

// Go back
context.pop();

// Replace route
context.go('/feed');
```

**What happens**:
1. User taps navigation item
2. go_router receives route
3. Route validated
4. Auth checked (if required)
5. Screen built
6. Navigation performed
7. New screen displayed

## State Management Flow

### Using Riverpod

```dart
// Define provider
final myProvider = Provider<int>((ref) => 42);

// Watch provider in widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(myProvider);
    return Text('$value');
  }
}

// Read provider (no rebuild)
final value = ref.read(myProvider);
```

**What happens**:
1. Provider defined
2. Widget watches provider
3. When provider value changes:
   - Provider notifies listeners
   - Widget rebuilds
   - UI updates

## Error Handling Flow

```dart
try {
  await someOperation();
} on PostgrestException catch (e) {
  // Handle Supabase error
  _showError('Database error: ${e.message}');
} on NetworkException catch (e) {
  // Handle network error
  _showError('Network error: ${e.message}');
} catch (e) {
  // Handle unexpected error
  _showError('Unexpected error: $e');
}
```

**What happens**:
1. Operation attempted
2. If error occurs:
   - Specific exception caught
   - Appropriate error message shown
   - User can retry

## Summary

The CodeNyx application follows a clear flow:
1. **Startup**: Initialize → Configure → Load routes
2. **Auth**: OAuth → Session → Navigate
3. **Data**: Repository → Supabase → UI
4. **Real-time**: Subscription → Stream → UI update
5. **State**: Provider → Watch → Rebuild
6. **Error**: Try-catch → Show message → Retry

Each component has a clear responsibility, making the codebase maintainable and understandable.
