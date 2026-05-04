# Class Diagrams

## Overview
This document contains Mermaid class diagrams illustrating the structure and relationships of classes in the CodeNyx application.

## Core Classes

```mermaid
classDiagram
    class CodeNyxApp {
        +main()
        +run()
    }
    
    class MyApp {
        +build()
        +router
    }
    
    CodeNyxApp --> MyApp : creates
```

## Theme Classes

```mermaid
classDiagram
    class AppTheme {
        +Color primaryBackground
        +Color accentPrimary
        +Color surfaceLight
        +Color textPrimary
        +Color textSecondary
        +Color textTertiary
        +Color borderColor
        +double spacingS
        +double spacingM
        +double spacingL
        +double spacingXL
        +double radiusSmall
        +double radiusMedium
        +double radiusLarge
        +cardDecoration()
        +backgroundGradient
        +cardTitle
        +cardBody
        +sectionHeader
        +metaText
    }
    
    class AppConstants {
        +String appName
        +int maxImageSizeKB
        +int maxImageWidth
        +int maxImageHeight
    }
```

## Service Classes

```mermaid
classDiagram
    class SessionService {
        -String _sessionKey
        +saveSession(Map data)
        +getSession() Map
        +clearSession()
    }
    
    class SupabaseService {
        +initialize()
        +getClient() SupabaseClient
    }
```

## Social Feed Classes

```mermaid
classDiagram
    class FeedScreen {
        -FeedRepository _repository
        -List _posts
        -bool _isLoading
        -ScrollController _scrollController
        +initState()
        +build()
        +_loadPosts()
        +_loadMorePosts()
        +_onRefresh()
        +_toggleLike()
        +_deletePost()
        +_navigateToDetail()
    }
    
    class FeedRepository {
        -SupabaseClient _client
        +createPost(content, imageUrl)
        +getPosts(page, limit)
        +getPostById(id)
        +deletePost(id)
        +toggleLike(postId, isLiked)
        +addComment(postId, content)
        +getComments(postId)
        +deleteComment(id)
        +resolveUserName(userId)
    }
    
    class CreatePostScreen {
        -FeedRepository _repository
        -ImageUploadService _imageService
        -TextEditingController _controller
        -String? _imageUrl
        +build()
        +_pickImage()
        +_removeImage()
        +_submitPost()
    }
    
    class PostDetailScreen {
        -FeedRepository _repository
        -Map _post
        -List _comments
        +build()
        +_loadPost()
        +_loadComments()
        +_toggleLike()
        +_addComment()
        +_deletePost()
    }
    
    class PostState {
        -Map _cache
        -ValueNotifier _notifier
        +updateLikeCount(postId, count)
        +updateUserLiked(postId, isLiked)
        +getPostState(postId)
        +clearCache()
    }
    
    class ImageUploadService {
        +pickAndUploadImage()
        +compressImage(bytes)
        +_compressToSize(bytes, maxSizeKB)
        +getFileSizeKB(bytes)
    }
    
    FeedScreen --> FeedRepository : uses
    FeedScreen --> PostState : uses
    CreatePostScreen --> FeedRepository : uses
    CreatePostScreen --> ImageUploadService : uses
    PostDetailScreen --> FeedRepository : uses
    PostDetailScreen --> PostState : uses
```

## Chat Classes

```mermaid
classDiagram
    class ChatScreen {
        -ChatRepository _repository
        -ScrollController _scrollController
        -TextEditingController _controller
        +build()
        +_sendMessage()
        +_scrollToBottom()
    }
    
    class ChatRepository {
        -SupabaseClient _client
        +watchTeamMessages(teamId) Stream
        +sendMessage(teamId, message)
        +resolveUserName(userId)
    }
    
    class MessageModel {
        +String id
        +String teamId
        +String userId
        +String userName
        +String message
        +DateTime createdAt
        +fromJson(Map) MessageModel
    }
    
    class MessageBubble {
        -MessageModel _message
        -bool _isCurrentUser
        +build()
    }
    
    class ChatProvider {
        +chatRepositoryProvider
        +teamMessagesProvider
    }
    
    ChatScreen --> ChatRepository : uses
    ChatScreen --> MessageBubble : creates
    ChatScreen --> ChatProvider : uses
    ChatRepository --> MessageModel : creates
    MessageBubble --> MessageModel : uses
```

## User Classes

```mermaid
classDiagram
    class UserUpdatesScreen {
        -AnnouncementRepository _repository
        -List _announcements
        +build()
        +_loadAnnouncements()
        +_onRefresh()
    }
    
    class TimerScreen {
        -DateTime _endTime
        -Timer _timer
        +build()
        +_startTimer()
        +_updateTimer()
    }
    
    UserUpdatesScreen --> AnnouncementRepository : uses
```

## Admin Classes

```mermaid
classDiagram
    class ManageAnnouncementsScreen {
        -AnnouncementRepository _repository
        -TextEditingController _titleController
        -TextEditingController _messageController
        +build()
        +_publishAnnouncement()
        +_loadAnnouncements()
    }
    
    class ManageMentorRequestsScreen {
        -MentorRequestRepository _repository
        -String _selectedFilter
        -List _requests
        +build()
        +_loadRequests()
        +_updateRequestStatus()
        +_filterRequests()
    }
    
    class AdminComplaintsScreen {
        -ComplaintsRepository _repository
        -List _complaints
        +build()
        +_loadComplaints()
        +_resolveComplaint()
    }
    
    class AdminProviders {
        +announcementRepositoryProvider
        +mentorRequestRepositoryProvider
    }
    
    ManageAnnouncementsScreen --> AnnouncementRepository : uses
    ManageMentorRequestsScreen --> MentorRequestRepository : uses
    AdminComplaintsScreen --> ComplaintsRepository : uses
    ManageAnnouncementsScreen --> AdminProviders : uses
    ManageMentorRequestsScreen --> AdminProviders : uses
```

## Complaints Classes

```mermaid
classDiagram
    class UserComplaintsScreen {
        -ComplaintsRepository _repository
        -TextEditingController _controller
        -List _complaints
        +build()
        +_submitComplaint()
        +_loadComplaints()
    }
    
    class AdminComplaintsScreen {
        -ComplaintsRepository _repository
        -List _complaints
        +build()
        +_loadComplaints()
        +_resolveComplaint()
    }
    
    class ComplaintsRepository {
        -SupabaseClient _client
        +createComplaint(message)
        +getUserComplaints(teamId)
        +getAllComplaints()
        +updateComplaintStatus(id)
    }
    
    UserComplaintsScreen --> ComplaintsRepository : uses
    AdminComplaintsScreen --> ComplaintsRepository : uses
```

## Repository Pattern

```mermaid
classDiagram
    class Repository {
        <<abstract>>
        +getAll()
        +getById(id)
        +create(data)
        +update(id, data)
        +delete(id)
    }
    
    class FeedRepository {
        +getPosts(page, limit)
        +createPost(content, imageUrl)
        +deletePost(id)
        +toggleLike(postId, isLiked)
    }
    
    class ChatRepository {
        +watchTeamMessages(teamId)
        +sendMessage(teamId, message)
    }
    
    class ComplaintsRepository {
        +createComplaint(message)
        +getUserComplaints(teamId)
        +updateComplaintStatus(id)
    }
    
    Repository <|-- FeedRepository
    Repository <|-- ChatRepository
    Repository <|-- ComplaintsRepository
```

## Provider Pattern

```mermaid
classDiagram
    class Provider {
        <<abstract>>
        +ref
        +read()
        +watch()
    }
    
    class StateNotifierProvider {
        +notifier
        +state
    }
    
    class StreamProvider {
        +stream
        +keepAlive()
    }
    
    class FutureProvider {
        +future
    }
    
    class chatRepositoryProvider {
        +FeedRepository
    }
    
    class teamMessagesProvider {
        +Stream~List~MessageModel~~
    }
    
    Provider <|-- StateNotifierProvider
    Provider <|-- StreamProvider
    Provider <|-- FutureProvider
    chatRepositoryProvider ..> Provider : implements
    teamMessagesProvider ..> StreamProvider : extends
```

## Model Classes

```mermaid
classDiagram
    class Post {
        +String id
        +String userId
        +String teamId
        +String content
        +String? imageUrl
        +int likeCount
        +DateTime createdAt
        +String userName
        +bool userLiked
        +fromJson(Map) Post
    }
    
    class Comment {
        +String id
        +String postId
        +String userId
        +String content
        +DateTime createdAt
        +String userName
        +fromJson(Map) Comment
    }
    
    class Like {
        +String id
        +String postId
        +String userId
        +DateTime createdAt
        +fromJson(Map) Like
    }
    
    class Message {
        +String id
        +String teamId
        +String userId
        +String userName
        +String message
        +DateTime createdAt
        +fromJson(Map) Message
    }
    
    class Announcement {
        +String id
        +String title
        +String message
        +DateTime createdAt
        +fromJson(Map) Announcement
    }
    
    class Complaint {
        +String id
        +String userEmail
        +String teamId
        +String message
        +String status
        +DateTime createdAt
        +fromJson(Map) Complaint
    }
```

## Widget Hierarchy

```mermaid
classDiagram
    class StatelessWidget {
        <<abstract>>
        +build(BuildContext)
    }
    
    class StatefulWidget {
        <<abstract>>
        +createState()
    }
    
    class State {
        <<abstract>>
        +initState()
        +build(BuildContext)
        +dispose()
    }
    
    class FeedScreen {
        +createState()
    }
    
    class _FeedScreenState {
        +initState()
        +build()
        +dispose()
    }
    
    class PostCard {
        +build()
    }
    
    StatelessWidget <|-- PostCard
    StatefulWidget <|-- FeedScreen
    State <|-- _FeedScreenState
    FeedScreen --> _FeedScreenState : creates
    _FeedScreenState --> PostCard : creates
```

## Data Flow Classes

```mermaid
classDiagram
    class DataSource {
        <<interface>>
        +fetch()
        +save()
    }
    
    class SupabaseDataSource {
        +client
        +fetch(table)
        +save(table, data)
    }
    
    class Cache {
        <<interface>>
        +get(key)
        +set(key, value)
        +remove(key)
    }
    
    class MemoryCache {
        -Map _cache
        +get(key)
        +set(key, value)
        +clear()
    }
    
    class PostState {
        -MemoryCache _cache
        +updateLikeCount()
        +getUserLiked()
    }
    
    DataSource <|-- SupabaseDataSource
    Cache <|-- MemoryCache
    PostState --> MemoryCache : uses
```

## Authentication Classes

```mermaid
classDiagram
    class AuthScreen {
        +build()
        +_signInWithGoogle()
        +_signOut()
    }
    
    class AuthRepository {
        +signInWithOAuth()
        +signOut()
        +getCurrentUser()
        +onAuthStateChange()
    }
    
    class Session {
        +String userId
        +String userEmail
        +String userName
        +String teamId
        +bool isAdmin
        +fromJson(Map) Session
        +toJson() Map
    }
    
    AuthScreen --> AuthRepository : uses
    AuthRepository --> Session : creates
```

## Error Handling Classes

```mermaid
classDiagram
    class AppException {
        +String message
        +int? code
        +StackTrace? stackTrace
    }
    
    class NetworkException {
        +String message
        +int statusCode
    }
    
    class AuthException {
        +String message
        +String? code
    }
    
    class ValidationException {
        +String message
        +String field
    }
    
    class StorageException {
        +String message
        +String? bucket
    }
    
    AppException <|-- NetworkException
    AppException <|-- AuthException
    AppException <|-- ValidationException
    AppException <|-- StorageException
```
