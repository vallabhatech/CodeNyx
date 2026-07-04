# API Documentation

## Overview
CodeNyx uses Supabase as its backend-as-a-service. This document documents all API interactions between the Flutter app and Supabase.

## Supabase Configuration

### Initialization
```dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

### Client Access
```dart
final client = Supabase.instance.client;
```

## Authentication API

### Google OAuth Sign-In

**Endpoint**: Supabase Auth OAuth
**Method**: `signInWithOAuth()`

```dart
await client.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: kIsWeb ? null : 'io.supabase.codenyx://auth/callback',
);
```

**Response**: Auth session with user information

### Sign Out

**Endpoint**: Supabase Auth
**Method**: `signOut()`

```dart
await client.auth.signOut();
```

### Get Current User

**Endpoint**: Supabase Auth
**Method**: `currentUser`

```dart
final user = client.auth.currentUser;
final email = user?.email;
final id = user?.id;
```

## Database API

### Posts Table API

#### Create Post

**Table**: `posts`
**Method**: `insert()`

```dart
await client.from('posts').insert({
  'user_id': userId,
  'team_id': teamId,
  'content': content,
  'image_url': imageUrl, // optional
  'created_at': DateTime.now().toIso8601String(),
});
```

**Fields**:
- `user_id`: UUID (foreign key to profiles)
- `team_id`: String
- `content`: Text
- `image_url`: Text (optional)
- `created_at`: Timestamp

#### Get Posts (Paginated)

**Table**: `posts`
**Method**: `select()` with range

```dart
final response = await client
    .from('posts')
    .select()
    .order('created_at', ascending: false)
    .range(from, to);
```

**Parameters**:
- `from`: Start index (0-based)
- `to`: End index
- `order`: Sort by created_at descending

#### Get Post by ID

**Table**: `posts`
**Method**: `select()` with eq

```dart
final response = await client
    .from('posts')
    .select()
    .eq('id', postId)
    .single();
```

#### Delete Post

**Table**: `posts`
**Method**: `delete()` with eq

```dart
await client.from('posts').delete().eq('id', postId);
```

### Likes Table API

#### Like Post

**Table**: `likes`
**Method**: `insert()`

```dart
await client.from('likes').insert({
  'post_id': postId,
  'user_id': userId,
});
```

#### Unlike Post

**Table**: `likes`
**Method**: `delete()` with eq

```dart
await client
    .from('likes')
    .delete()
    .eq('post_id', postId)
    .eq('user_id', userId);
```

#### Check if User Liked Post

**Table**: `likes`
**Method**: `select()` with eq

```dart
final response = await client
    .from('likes')
    .select()
    .eq('post_id', postId)
    .eq('user_id', userId);
```

#### Get Like Count

**Table**: `likes`
**Method**: `select()` with count

```dart
final response = await client
    .from('likes')
    .select('*', count: CountOption.exact)
    .eq('post_id', postId);
```

#### Increment Like Count (in posts table)

**Table**: `posts`
**Method**: `rpc()` or update

```dart
await client.rpc('increment_like_count', params: {'post_id': postId});
```

### Comments Table API

#### Add Comment

**Table**: `comments`
**Method**: `insert()`

```dart
await client.from('comments').insert({
  'post_id': postId,
  'user_id': userId,
  'content': content,
  'created_at': DateTime.now().toIso8601String(),
});
```

#### Get Post Comments

**Table**: `comments`
**Method**: `select()` with eq

```dart
final response = await client
    .from('comments')
    .select()
    .eq('post_id', postId)
    .order('created_at', ascending: false);
```

#### Delete Comment

**Table**: `comments`
**Method**: `delete()` with eq

```dart
await client.from('comments').delete().eq('id', commentId);
```

### Messages Table API

#### Send Message

**Table**: `messages`
**Method**: `insert()`

```dart
await client.from('messages').insert({
  'team_id': teamId,
  'user_id': userId,
  'message': message,
  'created_at': DateTime.now().toIso8601String(),
});
```

#### Get Team Messages

**Table**: `messages`
**Method**: `select()` with eq

```dart
final response = await client
    .from('messages')
    .select()
    .eq('team_id', teamId)
    .order('created_at', ascending: true);
```

### Announcements Table API

#### Create Announcement

**Table**: `announcements`
**Method**: `insert()`

```dart
await client.from('announcements').insert({
  'title': title,
  'message': message,
  'created_at': DateTime.now().toIso8601String(),
});
```

#### Get All Announcements

**Table**: `announcements`
**Method**: `select()`

```dart
final response = await client
    .from('announcements')
    .select()
    .order('created_at', ascending: false);
```

### Mentor Requests Table API

#### Create Mentor Request

**Table**: `mentor_requests`
**Method**: `insert()`

```dart
await client.from('mentor_requests').insert({
  'user_id': userId,
  'team_id': teamId,
  'request': request,
  'status': 'pending',
  'created_at': DateTime.now().toIso8601String(),
});
```

#### Get All Mentor Requests

**Table**: `mentor_requests`
**Method**: `select()`

```dart
final response = await client
    .from('mentor_requests')
    .select()
    .order('created_at', ascending: false);
```

#### Update Mentor Request Status

**Table**: `mentor_requests`
**Method**: `update()` with eq

```dart
await client
    .from('mentor_requests')
    .update({'status': newStatus})
    .eq('id', requestId);
```

### Complaints Table API

#### Create Complaint

**Table**: `complaints`
**Method**: `insert()`

```dart
await client.from('complaints').insert({
  'user_email': userEmail,
  'team_id': teamId,
  'message': message,
  'status': 'pending',
  'created_at': DateTime.now().toIso8601String(),
});
```

#### Get User Complaints

**Table**: `complaints`
**Method**: `select()` with eq

```dart
final response = await client
    .from('complaints')
    .select()
    .eq('team_id', teamId)
    .order('created_at', ascending: false);
```

#### Get All Complaints (Admin)

**Table**: `complaints`
**Method**: `select()`

```dart
final response = await client
    .from('complaints')
    .select()
    .order('created_at', ascending: false);
```

#### Update Complaint Status

**Table**: `complaints`
**Method**: `update()` with eq

```dart
await client
    .from('complaints')
    .update({'status': 'resolved'})
    .eq('id', complaintId);
```

### Profiles Table API

#### Get User Profile

**Table**: `profiles`
**Method**: `select()` with eq

```dart
final response = await client
    .from('profiles')
    .select()
    .eq('id', userId)
    .single();
```

#### Resolve User Name

**Table**: `profiles`
**Method**: `select()` with eq

```dart
final response = await client
    .from('profiles')
    .select('user_name')
    .eq('id', userId)
    .single();
```

## Storage API

### Upload Image

**Bucket**: `post-images`
**Method**: `upload()`

```dart
final file = File(imagePath);
final bytes = await file.readAsBytes();
final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

await client.storage.from('post-images').upload(
  fileName,
  bytes,
);
```

### Get Public URL

**Bucket**: `post-images`
**Method**: `getPublicUrl()`

```dart
final imageUrl = client.storage
    .from('post-images')
    .getPublicUrl(fileName);
```

### Delete Image

**Bucket**: `post-images`
**Method**: `remove()`

```dart
await client.storage.from('post-images').remove([fileName]);
```

## Realtime API

### Subscribe to Table Changes

**Method**: `on().subscribe()`

```dart
final subscription = client
    .from('messages')
    .on(SupabaseEventTypes.insert, (payload) {
      // Handle new message
    })
    .subscribe();
```

### Unsubscribe

**Method**: `unsubscribe()`

```dart
subscription.unsubscribe();
```

### Subscribe with Filter

**Method**: `on()` with filter

```dart
client
    .from('messages')
    .on(SupabaseEventTypes.insert, (payload) {
      // Handle new message
    })
    .eq('team_id', teamId)
    .subscribe();
```

## Error Handling

### Try-Catch Pattern

```dart
try {
  final response = await client.from('posts').select();
  // Handle success
} on PostgrestException catch (e) {
  // Handle Supabase error
  print('Error: ${e.message}');
} catch (e) {
  // Handle other errors
  print('Unexpected error: $e');
}
```

### Common Error Codes

- **400**: Bad request (invalid data)
- **401**: Unauthorized (not authenticated)
- **403**: Forbidden (RLS policy violation)
- **404**: Not found
- **500**: Server error

## Rate Limiting

Supabase has default rate limits:
- **API requests**: 50 requests/second
- **Realtime connections**: 200 connections/project
- **Storage uploads**: 5 GB/month (free tier)

## Security Headers

All API requests include:
- **Authorization**: Bearer token (from session)
- **apikey**: Anon key
- **Content-Type**: application/json

## API Response Format

### Success Response
```dart
List<Map<String, dynamic>> response = [
  {
    'id': 'uuid',
    'user_id': 'uuid',
    'content': 'Post content',
    'created_at': '2024-01-01T00:00:00.000Z',
  },
];
```

### Error Response
```dart
PostgrestException {
  message: 'Error message',
  code: 'PGRST116',
  details: 'Details',
  hint: 'Hint',
}
```

## API Best Practices

1. **Always handle errors**: Wrap API calls in try-catch
2. **Use pagination**: For large datasets
3. **Select only needed columns**: Reduce payload size
4. **Use indexes**: For frequently queried columns
5. **Cache responses**: When appropriate
6. **Use realtime subscriptions**: For real-time features
7. **Validate input**: Before sending to API
8. **Use transactions**: For multiple related operations
