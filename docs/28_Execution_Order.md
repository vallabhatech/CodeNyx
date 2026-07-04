# Execution Order

## Overview
This document explains the order in which different parts of the CodeNyx application execute, from app startup to user interactions.

## App Startup Execution Order

### 1. main.dart Execution
```
1. main() function called
2. WidgetsFlutterBinding.ensureInitialized()
   - Initializes Flutter bindings
   - Sets up platform channels
3. Supabase.initialize()
   - Reads environment variables
   - Creates Supabase client
   - Configures auth, database, storage, realtime
4. runApp(CodeNyxApp())
   - Creates app widget
   - Attaches to Flutter engine
```

### 2. CodeNyxApp Execution
```
1. CodeNyxApp.build() called
2. ProviderScope created
   - Initializes Riverpod
   - Sets up provider container
3. MaterialApp.router created
   - Configures router
   - Sets theme
4. Router initialized
   - Loads route configuration
   - Sets up initial route
```

### 3. Router Execution
```
1. GoRouter initialized
2. Route configuration loaded
3. Initial route determined (/)
4. Auth state checked
5. Route built based on auth state
   - If authenticated: navigate to /feed
   - If not authenticated: show AuthScreen
```

## Screen Lifecycle Execution Order

### StatefulWidget Lifecycle
```
1. Widget constructor called
2. createElement() called
3. createState() called
4. State object created
5. initState() called
   - Initialize variables
   - Set up controllers
   - Start subscriptions
6. didChangeDependencies() called
   - Access inherited widgets
7. build() called
   - Build widget tree
8. Widget mounted to tree
9. didUpdateWidget() called (if parent rebuilds)
10. setState() called (if state changes)
11. build() called again
12. dispose() called (when widget removed)
    - Dispose controllers
    - Cancel subscriptions
    - Clean up resources
```

### Provider Lifecycle
```
1. Provider defined
2. ProviderScope initialized
3. Provider created (when first accessed)
4. State initialized
5. State watched by widget
6. State changes
7. Listeners notified
8. Widgets rebuild
9. Provider disposed (when ProviderScope disposed)
```

## Authentication Execution Order

### Sign In Flow
```
1. User taps "Sign in with Google"
2. _signInWithGoogle() called
3. Supabase.auth.signInWithOAuth() called
4. User redirected to Google OAuth
5. User completes OAuth flow
6. Google redirects back to app
7. Supabase processes OAuth callback
8. Auth session created
9. onAuthStateChange event fired
10. User profile fetched from database
11. Session data extracted (team_id, user_name)
12. SessionService.saveSession() called
13. Session saved to SharedPreferences
14. Router navigates to /feed
15. FeedScreen builds
```

### Session Check Flow
```
1. App starts or route changes
2. Router checks auth state
3. Supabase.auth.currentUser accessed
4. Session validity checked
5. If session valid:
   - SessionService.getSession() called
   - Session data loaded
   - User allowed to access route
6. If session invalid:
   - User redirected to AuthScreen
```

## Data Loading Execution Order

### Feed Loading Flow
```
1. FeedScreen.initState() called
2. _isLoading set to true
3. _loadPosts() called
4. FeedRepository.getPosts() called
5. Supabase client query executed
6. Database query processed
7. Results returned
8. User names resolved (parallel queries)
9. PostState cache updated
10. _isLoading set to false
11. setState() called
12. build() called
13. UI updated with posts
```

### Chat Loading Flow
```
1. ChatScreen builds
2. teamMessagesProvider watched
3. ChatRepository.watchTeamMessages() called
4. Supabase realtime subscription created
5. Initial data fetched
6. Stream emits initial messages
7. StreamProvider updates
8. ChatScreen rebuilds
9. Messages displayed
10. Subscription remains active
```

## User Interaction Execution Order

### Create Post Flow
```
1. User navigates to CreatePostScreen
2. CreatePostScreen builds
3. User enters text
4. TextEditingController updated
5. User selects image (optional)
6. ImagePicker.pickImage() called
7. Image selected
8. Image compressed
9. Image uploaded to Supabase Storage
10. Image URL returned
11. User taps "Post"
12. _submitPost() called
13. FeedRepository.createPost() called
14. Supabase INSERT executed
15. Post created in database
16. Success returned
17. Navigator.pop() called
18. User returned to FeedScreen
19. Feed refreshes
20. New post displayed
```

### Like Post Flow
```
1. User taps like button
2. _toggleLike() called
3. PostState.getPostState() called
4. Current like status retrieved
5. FeedRepository.toggleLike() called
6. Supabase INSERT or DELETE executed
7. Database updated
8. PostState cache updated
9. Listeners notified
10. UI rebuilds
11. Like button updated
```

### Send Message Flow
```
1. User types message
2. TextEditingController updated
3. User taps send
4. _sendMessage() called
5. ChatRepository.sendMessage() called
6. Supabase INSERT executed
7. Message created in database
8. Supabase Realtime detects change
9. Stream emits new message
10. All team members receive update
11. UI rebuilds for all users
12. Auto-scroll to bottom
```

## Real-time Execution Order

### Real-time Subscription Flow
```
1. Screen builds
2. StreamProvider watched
3. Repository method called
4. Supabase realtime subscription created
5. WebSocket connection established
6. Initial data fetched
7. Stream emits initial data
8. UI displays initial data
9. Subscription remains active
10. Database change detected
11. Stream emits new data
12. UI rebuilds with new data
13. Process repeats for each change
```

### Real-time Message Flow
```
1. User A sends message
2. Message inserted into database
3. Supabase detects INSERT event
4. WebSocket broadcast triggered
5. User B's stream receives event
6. Stream emits new message
7. User B's UI rebuilds
8. Message displayed for User B
9. Same for all team members
```

## Error Handling Execution Order

### Error Flow
```
1. User performs action
2. Repository method called
3. Supabase API call made
4. Error occurs
5. Exception thrown
6. Try-catch block catches exception
7. Error type determined
8. Appropriate error message selected
9. SnackBar shown
10. User sees error message
11. User can retry action
```

## Navigation Execution Order

### Route Navigation Flow
```
1. User taps navigation item
2. context.push() or context.go() called
3. GoRouter processes navigation
4. Route validated
5. Auth guard checked (if required)
6. Route parameters extracted
7. Target screen built
8. Navigation performed
9. Old screen disposed
10. New screen mounted
11. New screen builds
12. New screen displayed
```

## State Update Execution Order

### Riverpod State Update Flow
```
1. Provider state changes
2. Provider notifies listeners
3. Widget rebuild scheduled
4. Widget.build() called
5. New state accessed
6. UI updated with new state
7. Frame rendered
8. User sees updated UI
```

## Image Processing Execution Order

### Image Upload Flow
```
1. User selects image
2. ImagePicker.pickImage() called
3. Image file returned
4. File read as bytes
5. Image decoded
6. Image resized to 800x800
7. Image compressed to 85% quality
8. Size calculated
9. Size checked (<500KB)
10. If too large: compress again
11. Filename generated
12. Upload to Supabase Storage
13. Public URL returned
14. URL stored in database
```

## Admin Operation Execution Order

### Create Announcement Flow
```
1. Admin navigates to ManageAnnouncementsScreen
2. Screen builds
3. Admin enters title
4. Admin enters message
5. Admin taps "Publish"
6. _publishAnnouncement() called
7. Validation performed
8. AnnouncementRepository.createAnnouncement() called
9. Supabase INSERT executed
10. Announcement created
11. Success returned
12. Announcements list refreshed
13. Success message shown
14. All users see new announcement
```

## Complaint Execution Order

### Submit Complaint Flow
```
1. User navigates to UserComplaintsScreen
2. Screen builds
3. User enters complaint message
4. User taps "Submit"
5. _submitComplaint() called
6. Validation performed
7. SessionService.getSession() called
8. Team ID and email retrieved
9. ComplaintsRepository.createComplaint() called
10. Supabase INSERT executed
11. Complaint created
12. Success returned
13. Complaints list refreshed
14. Success message shown
```

## Cleanup Execution Order

### Widget Disposal Flow
```
1. Widget removed from tree
2. dispose() called
3. TextEditingController.dispose()
4. ScrollController.dispose()
5. AnimationController.dispose()
6. Stream subscriptions cancelled
7. Timers cancelled
8. Resources released
9. Widget marked as unmounted
10. Memory freed
```

### App Termination Flow
```
1. User closes app
2. Widgets unmounted
3. dispose() called for all widgets
4. Providers disposed
5. Supabase client disconnected
6. WebSocket connections closed
7. Resources released
8. App process terminated
```

## Parallel Execution

### Parallel Queries
```
1. Repository method called
2. Multiple Supabase queries initiated
3. Queries execute in parallel
4. Results awaited
5. Results combined
6. Data returned
```

### Parallel Image Processing
```
1. Multiple images selected
2. Each image processed independently
3. Compression runs in parallel
4. Uploads run in parallel
5. All URLs returned
6. Data saved
```

## Optimization Execution Order

### Lazy Loading Flow
```
1. ListView.builder created
2. Initial items built
3. User scrolls
4. New items come into view
5. Builder called for new items
6. New items built
7. Process repeats
```

### Pagination Flow
```
1. Initial page loaded (page 0)
2. User scrolls near bottom
3. Load more triggered
4. Next page requested (page 1)
5. Data fetched
6. Data appended to list
7. UI updated
8. Process repeats
```

## Summary

The CodeNyx application follows a clear execution order:
1. **Startup**: Initialize → Configure → Load routes → Check auth
2. **Screen Lifecycle**: Constructor → initState → build → dispose
3. **Data Loading**: Request → Query → Process → Cache → Display
4. **User Interaction**: Input → Validate → Process → Update → Refresh
5. **Real-time**: Subscribe → Listen → Emit → Rebuild
6. **Error Handling**: Try → Catch → Show → Retry
7. **Cleanup**: Dispose → Cancel → Release → Free

Understanding this execution order helps with debugging, performance optimization, and adding new features.
