# Error Handling

## Overview
CodeNyx implements comprehensive error handling throughout the application to provide a smooth user experience and aid in debugging. This document explains error handling strategies and patterns.

## Error Handling Strategy

### Error Categories

1. **Network Errors**: Connection issues, timeouts
2. **Authentication Errors**: Invalid credentials, expired sessions
3. **Validation Errors**: Invalid user input
4. **Database Errors**: Supabase query failures
5. **Storage Errors**: File upload failures
6. **Unexpected Errors**: Unhandled exceptions

## Error Handling Patterns

### 1. Try-Catch Pattern

**Basic Pattern**:
```dart
try {
  await someOperation();
} on SpecificException catch (e) {
  // Handle specific error
} catch (e) {
  // Handle general error
} finally {
  // Cleanup
}
```

**Example in Repository**:
```dart
Future<void> createPost(String content) async {
  try {
    await _client.from('posts').insert({'content': content});
  } on PostgrestException catch (e) {
    throw Exception('Failed to create post: ${e.message}');
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
```

### 2. Error State Pattern

**UI Error Handling**:
```dart
class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await repository.fetchData();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();
    }

    if (_errorMessage != null) {
      return ErrorDisplay(message: _errorMessage!);
    }

    return Content();
  }
}
```

### 3. SnackBar Error Display

**Pattern**:
```dart
void _showSnackBar(String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.red : AppTheme.surfaceLight,
    ),
  );
}
```

**Usage**:
```dart
try {
  await repository.createPost(content);
  _showSnackBar('Post created successfully');
} catch (e) {
  _showSnackBar('Failed to create post: $e', isError: true);
}
```

## Error Handling by Feature

### Authentication Errors

**Types**:
- OAuth cancellation
- Network timeout
- Invalid credentials
- Session expired

**Handling**:
```dart
Future<void> _signInWithGoogle() async {
  try {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
    );
  } on AuthApiException catch (e) {
    _showError('Authentication failed: ${e.message}');
  } catch (e) {
    _showError('Unexpected error: $e');
  }
}
```

### Social Feed Errors

**Create Post Errors**:
```dart
Future<void> _submitPost() async {
  setState(() => _isSubmitting = true);

  try {
    await _repository.createPost(_contentController.text);
    _showSnackBar('Post created successfully');
    Navigator.pop(context);
  } on PostgrestException catch (e) {
    _showSnackBar('Failed to create post: ${e.message}', isError: true);
  } catch (e) {
    _showSnackBar('Unexpected error: $e', isError: true);
  } finally {
    setState(() => _isSubmitting = false);
  }
}
```

**Load Feed Errors**:
```dart
Future<void> _loadPosts() async {
  try {
    final posts = await _repository.getPosts();
    setState(() => _posts = posts);
  } catch (e) {
    setState(() => _errorMessage = e.toString());
  }
}
```

### Chat Errors

**Send Message Errors**:
```dart
Future<void> _sendMessage() async {
  final message = _controller.text.trim();
  if (message.isEmpty) return;

  try {
    await _repository.sendMessage(message);
    _controller.clear();
  } catch (e) {
    _showSnackBar('Failed to send message: $e', isError: true);
  }
}
```

### Image Upload Errors

**Pick Image Errors**:
```dart
Future<String?> pickAndUploadImage() async {
  try {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return null;
    
    final bytes = await File(image.path).readAsBytes();
    final compressed = compressImage(bytes);
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage.from('post-images').upload(fileName, compressed);
    
    return _client.storage.from('post-images').getPublicUrl(fileName);
  } on PlatformException catch (e) {
    throw Exception('Failed to pick image: ${e.message}');
  } on StorageException catch (e) {
    throw Exception('Failed to upload image: ${e.message}');
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
```

### Admin Errors

**Create Announcement Errors**:
```dart
Future<void> _publishAnnouncement() async {
  try {
    await _repository.createAnnouncement(_title, _message);
    _showSnackBar('Announcement published');
    _loadAnnouncements();
  } catch (e) {
    _showSnackBar('Failed to publish: $e', isError: true);
  }
}
```

### Complaints Errors

**Submit Complaint Errors**:
```dart
Future<void> _submitComplaint() async {
  final message = _messageController.text.trim();
  if (message.isEmpty) {
    _showSnackBar('Please enter your complaint', isError: true);
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    await _repository.createComplaint(message);
    _showSnackBar('Complaint submitted');
    _loadComplaints();
  } catch (e) {
    _showSnackBar('Failed to submit: $e', isError: true);
  } finally {
    setState(() => _isSubmitting = false);
  }
}
```

## Error Display Components

### Error Display Widget

```dart
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Empty State Widget

```dart
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    required this.message,
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
```

## Error Logging

### Console Logging

```dart
void logError(String message, [Object? error, StackTrace?]) {
  debugPrint('ERROR: $message');
  if (error != null) {
    debugPrint('Error details: $error');
  }
  if (stackTrace != null) {
    debugPrint('Stack trace: $stackTrace');
  }
}
```

### Supabase Error Logging

```dart
try {
  await operation();
} on PostgrestException catch (e) {
  logError('Supabase error', e, e.stackTrace);
  // Log error details
  print('Code: ${e.code}');
  print('Message: ${e.message}');
  print('Details: ${e.details}');
  print('Hint: ${e.hint}');
}
```

## Error Recovery Strategies

### Retry Pattern

```dart
Future<T> retry<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      await Future.delayed(delay * attempt);
    }
  }
  throw Exception('Max retry attempts exceeded');
}
```

### Fallback Pattern

```dart
Future<List<Post>> getPosts() async {
  try {
    return await _repository.getPosts();
  } catch (e) {
    // Fallback to cached data
    return _cache.getPosts() ?? [];
  }
}
```

### Graceful Degradation

```dart
Widget buildPostImage(String? imageUrl) {
  if (imageUrl == null) return SizedBox.shrink();
  
  return Image.network(
    imageUrl,
    errorBuilder: (context, error, stackTrace) {
      return Icon(Icons.broken_image);
    },
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return CircularProgressIndicator();
    },
  );
}
```

## Validation Errors

### Input Validation

```dart
String? validatePostContent(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter post content';
  }
  if (value.length > 500) {
    return 'Post too long (max 500 characters)';
  }
  return null;
}
```

### Form Validation

```dart
final _formKey = GlobalKey<FormState>();

ElevatedButton(
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      _submitForm();
    }
  },
  child: Text('Submit'),
)
```

## Network Error Handling

### Connectivity Check

```dart
Future<bool> hasInternetConnection() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}
```

### Timeout Handling

```dart
Future<T> withTimeout<T>(
  Future<T> future,
  Duration timeout,
) async {
  try {
    return await future.timeout(timeout);
  } on TimeoutException {
    throw Exception('Operation timed out');
  }
}
```

## Global Error Handler

### Flutter Error Widget

```dart
void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    logError('Flutter error', details.exception, details.stack);
  };

  runApp(MyApp());
}
```

### Zone Error Handler

```dart
void main() {
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stack) {
    logError('Uncaught error', error, stack);
  });
}
```

## Error Handling Best Practices

1. **Always handle errors**: Never let exceptions propagate to UI
2. **Provide user feedback**: Show error messages to users
3. **Log errors**: Log errors for debugging
4. **Offer recovery**: Provide retry options when possible
5. **Validate input**: Prevent errors before they occur
6. **Use specific exceptions**: Catch specific exception types
7. **Don't swallow errors**: Always handle or rethrow
8. **Test error paths**: Test error handling code

## Error Messages

### User-Friendly Messages

| Error Type | User Message |
|------------|---------------|
| Network error | "No internet connection. Please check your connection." |
| Auth error | "Authentication failed. Please try again." |
| Validation error | "Invalid input. Please check your input." |
| Server error | "Server error. Please try again later." |
| Timeout error | "Request timed out. Please try again." |

### Developer Messages

```dart
// Detailed error for logging
throw Exception(
  'Failed to create post: '
  'PostgrestException(code: ${e.code}, message: ${e.message})'
);
```

## Testing Error Handling

### Unit Tests

```dart
test('handles network error', () async {
  when(repository.getPosts()).thenThrow(NetworkException());
  
  await expectLater(
    screen.loadPosts(),
    throwsA(isA<NetworkException>()),
  );
});
```

### Widget Tests

```dart
testWidgets('shows error on failure', (tester) async {
  when(repository.getPosts()).thenThrow(Exception('Error'));
  
  await tester.pumpWidget(MyScreen());
  await tester.pumpAndSettle();
  
  expect(find.text('Error'), findsOneWidget);
});
```

## Summary

CodeNyx implements comprehensive error handling across all features:
- Try-catch blocks for all async operations
- User-friendly error messages via SnackBars
- Error display components for consistent UI
- Logging for debugging
- Retry and fallback strategies
- Input validation to prevent errors
- Global error handlers for uncaught exceptions

This ensures a robust and user-friendly application experience.
