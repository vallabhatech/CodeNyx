# Project Map

## Overview
This document provides a visual map of the CodeNyx project, showing the relationships between files, modules, and dependencies.

## File Dependency Map

```
main.dart
├── app.dart
│   ├── go_router
│   ├── AuthScreen
│   ├── FeedScreen
│   ├── ChatScreen
│   ├── UserUpdatesScreen
│   ├── TimerScreen
│   ├── ManageAnnouncementsScreen
│   ├── ManageMentorRequestsScreen
│   ├── UserComplaintsScreen
│   └── AdminComplaintsScreen
└── Supabase initialization

app.dart
├── go_router package
└── All screen imports

AuthScreen
├── Supabase Auth
├── SessionService
└── Google OAuth

FeedScreen
├── FeedRepository
├── PostState
├── CreatePostScreen
├── PostDetailScreen
└── AppTheme

FeedRepository
├── Supabase Client
├── SessionService
└── PostState

CreatePostScreen
├── FeedRepository
├── ImageUploadService
└── AppTheme

PostDetailScreen
├── FeedRepository
├── PostState
└── AppTheme

ImageUploadService
├── image_picker package
├── image package
└── Supabase Storage

ChatScreen
├── ChatRepository
├── ChatProvider
├── MessageBubble
└── AppTheme

ChatRepository
├── Supabase Client
├── SessionService
└── MessageModel

ChatProvider
├── ChatRepository
└── Riverpod

MessageBubble
├── MessageModel
└── AppTheme

UserUpdatesScreen
├── AnnouncementRepository
└── AppTheme

TimerScreen
└── AppTheme

ManageAnnouncementsScreen
├── AdminProviders
├── AnnouncementRepository
└── AppTheme

ManageMentorRequestsScreen
├── AdminProviders
├── MentorRequestRepository
└── AppTheme

AdminComplaintsScreen
├── ComplaintsRepository
└── AppTheme

UserComplaintsScreen
├── ComplaintsRepository
├── SessionService
└── AppTheme

ComplaintsRepository
├── Supabase Client
└── SessionService

AdminProviders
├── AnnouncementRepository
├── MentorRequestRepository
└── Riverpod

SessionService
├── SharedPreferences
└── Supabase Auth

AppTheme
└── Flutter Material
```

## Module Dependency Map

```
Core Module
├── Theme (app_theme.dart)
└── Constants (app_constants.dart)

Services Module
├── Session Service
└── Supabase Service

Social Feed Module
├── Feed Screen
├── Feed Repository
├── Create Post Screen
├── Post Detail Screen
├── Post State
└── Image Upload Service

Chat Module
├── Chat Screen
├── Chat Repository
├── Chat Provider
├── Message Model
└── Message Bubble

User Module
├── User Updates Screen
└── Timer Screen

Admin Module
├── Manage Announcements Screen
├── Manage Mentor Requests Screen
├── Admin Complaints Screen
└── Admin Providers

Complaints Module
├── User Complaints Screen
├── Admin Complaints Screen
└── Complaints Repository
```

## Package Dependency Map

```
codenyx
├── flutter (SDK)
├── supabase_flutter
│   ├── supabase (core)
│   ├── gotrue (auth)
│   ├── postgrest (database)
│   ├── realtime (subscriptions)
│   └── storage (file storage)
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

## Database Dependency Map

```
Supabase Database
├── profiles table
│   └── Referenced by: posts, comments, likes, messages
├── posts table
│   ├── References: profiles (user_id)
│   └── Referenced by: comments, likes
├── comments table
│   ├── References: posts (post_id), profiles (user_id)
│   └── Referenced by: none
├── likes table
│   ├── References: posts (post_id), profiles (user_id)
│   └── Referenced by: none
├── messages table
│   └── References: profiles (user_id)
├── announcements table
│   └── Referenced by: none
├── mentor_requests table
│   └── References: profiles (user_id)
└── complaints table
    └── References: none (uses user_email)
```

## Data Flow Map

```
User Input
    ↓
Screen (Widget)
    ↓
Provider (Riverpod)
    ↓
Repository (Data Access)
    ↓
Supabase Client
    ↓
Supabase Backend
    ↓
Database/Storage/Realtime
    ↓
Response
    ↓
Repository
    ↓
Provider
    ↓
Screen
    ↓
UI Update
```

## State Management Map

```
Global State (Riverpod Providers)
├── chatRepositoryProvider
├── teamMessagesProvider (Stream)
├── announcementRepositoryProvider
├── mentorRequestRepositoryProvider
└── (future providers can be added)

Local State (StatefulWidget)
├── TextEditingController
├── ScrollController
├── AnimationController
└── bool flags (isLoading, etc.)

Cache State
├── PostState (like counts, user liked status)
└── SessionService (user session data)
```

## Navigation Map

```
GoRouter
├── / (AuthScreen)
│   └── Redirects to /feed if authenticated
├── /feed (FeedScreen)
│   └── Requires authentication
├── /chat (ChatScreen)
│   └── Requires authentication
├── /user-updates (UserUpdatesScreen)
│   └── Requires authentication
├── /timer (TimerScreen)
│   └── Requires authentication
├── /admin (Admin Dashboard)
│   └── Requires admin role
├── /admin/announcements (ManageAnnouncementsScreen)
│   └── Requires admin role
├── /admin/mentor-requests (ManageMentorRequestsScreen)
│   └── Requires admin role
├── /admin/complaints (AdminComplaintsScreen)
│   └── Requires admin role
└── /complaints (UserComplaintsScreen)
    └── Requires authentication
```

## API Call Map

```
FeedRepository
├── createPost() → INSERT posts
├── getPosts() → SELECT posts
├── getPostById() → SELECT posts (single)
├── deletePost() → DELETE posts
├── toggleLike() → INSERT/DELETE likes
├── addComment() → INSERT comments
├── getComments() → SELECT comments
├── deleteComment() → DELETE comments
└── resolveUserName() → SELECT profiles

ChatRepository
├── watchTeamMessages() → Realtime subscription
├── sendMessage() → INSERT messages
└── resolveUserName() → SELECT profiles

ComplaintsRepository
├── createComplaint() → INSERT complaints
├── getUserComplaints() → SELECT complaints
├── getAllComplaints() → SELECT complaints (admin)
└── updateComplaintStatus() → UPDATE complaints

ImageUploadService
├── pickImage() → ImagePicker
├── compressImage() → Image processing
└── uploadImage() → Supabase Storage
```

## Real-time Subscription Map

```
ChatScreen
    ↓
teamMessagesProvider (StreamProvider)
    ↓
ChatRepository.watchTeamMessages()
    ↓
Supabase Realtime
    ↓
messages table (INSERT events)
    ↓
Stream emits new messages
    ↓
UI rebuilds
```

## Authentication Flow Map

```
User
    ↓
AuthScreen
    ↓
Supabase Auth (Google OAuth)
    ↓
Session Created
    ↓
Fetch Profile from Database
    ↓
Save Session (SessionService)
    ↓
Navigate to Feed
```

## Error Handling Map

```
User Action
    ↓
Repository Call
    ↓
Supabase API
    ↓
Exception Thrown
    ↓
UI Catches Exception
    ↓
Show Error Message (SnackBar)
    ↓
User Can Retry
```

## Component Hierarchy Map

```
MaterialApp
└── GoRouter
    └── Screens
        ├── AuthScreen
        │   └── GoogleSignInButton
        ├── FeedScreen
        │   ├── AppBar
        │   ├── RefreshIndicator
        │   ├── ListView
        │   │   └── PostCard
        │   │       ├── PostHeader
        │   │       ├── PostContent
        │   │       ├── PostImage
        │   │       └── PostActions
        │   └── FloatingActionButton
        ├── ChatScreen
        │   ├── AppBar
        │   ├── MessageList
        │   │   └── MessageBubble
        │   └── MessageInput
        └── (other screens)
```

## Configuration Map

```
pubspec.yaml
├── Dependencies
│   ├── flutter (SDK)
│   ├── supabase_flutter
│   ├── flutter_riverpod
│   ├── go_router
│   ├── image_picker
│   ├── image
│   └── cupertino_icons
├── Dev Dependencies
│   ├── flutter_test
│   └── flutter_lints
└── Flutter Configuration
    ├── uses-material-design
    ├── assets (if any)
    └── fonts (if any)

analysis_options.yaml
├── include: flutter_lints
└── custom lint rules

.gitignore
├── Build artifacts
├── IDE files
├── Dart/Flutter files
└── Platform-specific files
```

## Build Output Map

```
Flutter Build
├── Android
│   ├── build/app/outputs/flutter-apk/
│   │   └── app-release.apk
│   └── build/app/outputs/bundle/
│       └── app-release.aab
├── iOS
│   └── build/ios/iphoneos/
│       └── Runner.app
└── Web
    └── build/web/
        ├── index.html
        ├── main.dart.js
        └── assets/
```

## External Service Map

```
CodeNyx App
    ↓
Supabase
    ├── Auth Service (Google OAuth)
    ├── Database Service (PostgreSQL)
    ├── Storage Service (post-images bucket)
    └── Realtime Service (WebSocket)
    ↓
Google OAuth
    ↓
Google Accounts
```

## Summary

The CodeNyx project is organized into:
- **Core modules**: Theme, constants, services
- **Feature modules**: Social feed, chat, user, admin, complaints
- **Data layer**: Repositories, Supabase client
- **State management**: Riverpod providers, local state, cache
- **Navigation**: go_router with route guards
- **External services**: Supabase (auth, database, storage, realtime)

Each module is self-contained with clear dependencies and responsibilities.
