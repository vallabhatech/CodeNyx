# Component Flow

## Overview
This document explains the component hierarchy and relationships in the CodeNyx Flutter application.

## Component Hierarchy

```mermaid
graph TB
    A[CodeNyxApp] --> B[MaterialApp]
    B --> C[GoRouter]
    C --> D[AuthScreen]
    C --> E[FeedScreen]
    C --> F[ChatScreen]
    C --> G[UserUpdatesScreen]
    C --> H[TimerScreen]
    C --> I[AdminDashboard]
    C --> J[UserComplaintsScreen]
    
    E --> K[PostCard]
    E --> L[FloatingActionButton]
    
    K --> M[PostContent]
    K --> N[LikeButton]
    K --> O[CommentPreview]
    K --> P[DeleteButton]
    
    F --> Q[MessageList]
    F --> R[MessageInput]
    
    Q --> S[MessageBubble]
    
    I --> T[ManageAnnouncementsScreen]
    I --> U[ManageMentorRequestsScreen]
    I --> V[AdminComplaintsScreen]
    
    T --> W[AnnouncementForm]
    T --> X[AnnouncementList]
    
    U --> Y[MentorRequestCard]
    
    V --> Z[ComplaintCard]
```

## Screen Component Flow

### 1. App Initialization Flow

```mermaid
sequenceDiagram
    participant Main as main()
    participant App as CodeNyxApp
    participant Router as GoRouter
    participant Auth as AuthScreen
    
    Main->>App: runApp()
    App->>Router: Initialize router
    Router->>Auth: Check auth state
    alt Not authenticated
        Router-->>Auth: Navigate to / (AuthScreen)
    else Authenticated
        Router-->>Router: Navigate to /feed
    end
```

### 2. AuthScreen Component Flow

```mermaid
graph LR
    A[AuthScreen] --> B[GoogleSignInButton]
    A --> C[LoadingIndicator]
    A --> D[ErrorMessage]
    
    B --> E[onTap]
    E --> F[Supabase Auth]
    F --> G[Session Service]
    G --> H[Navigation]
```

**Component Breakdown**:
- **AuthScreen**: Main authentication container
- **GoogleSignInButton**: Triggers OAuth flow
- **LoadingIndicator**: Shows during auth process
- **ErrorMessage**: Displays auth errors

### 3. FeedScreen Component Flow

```mermaid
graph TB
    A[FeedScreen] --> B[AppBar]
    A --> C[RefreshIndicator]
    A --> D[ListView.builder]
    A --> E[FloatingActionButton]
    
    C --> F[onRefresh]
    F --> G[FeedRepository]
    G --> H[Reload Posts]
    
    D --> I[PostCard]
    I --> J[PostHeader]
    I --> K[PostContent]
    I --> L[PostImage]
    I --> M[PostActions]
    
    M --> N[LikeButton]
    M --> O[CommentButton]
    M --> P[DeleteButton]
    
    E --> Q[onTap]
    Q --> R[Navigate to CreatePostScreen]
```

**Component Breakdown**:
- **FeedScreen**: Main feed container with scrollable list
- **AppBar**: Screen title and actions
- **RefreshIndicator**: Pull-to-refresh functionality
- **ListView.builder**: Efficient list rendering
- **PostCard**: Individual post display
- **FloatingActionButton**: Navigate to create post

**PostCard Sub-components**:
- **PostHeader**: User name and timestamp
- **PostContent**: Post text content
- **PostImage**: Post image (if any)
- **PostActions**: Like, comment, delete buttons

### 4. CreatePostScreen Component Flow

```mermaid
graph TB
    A[CreatePostScreen] --> B[AppBar]
    A --> C[TextField]
    A --> D[ImagePickerButton]
    A --> E[ImagePreview]
    A --> F[SubmitButton]
    
    D --> G[onTap]
    G --> H[ImageUploadService]
    H --> I[pickImage]
    I --> J[compressImage]
    J --> K[uploadImage]
    K --> L[Return URL]
    
    F --> M[onTap]
    M --> N[FeedRepository]
    N --> O[createPost]
    O --> P[Navigate back]
```

**Component Breakdown**:
- **CreatePostScreen**: Post creation form
- **TextField**: Multi-line text input
- **ImagePickerButton**: Trigger image selection
- **ImagePreview**: Show selected image
- **SubmitButton**: Submit post

### 5. PostDetailScreen Component Flow

```mermaid
graph TB
    A[PostDetailScreen] --> B[AppBar]
    A --> C[PostContent]
    A --> D[CommentsList]
    A --> E[CommentInput]
    
    C --> F[PostHeader]
    C --> G[PostText]
    C --> H[PostImage]
    C --> I[LikeButton]
    
    D --> J[CommentCard]
    J --> K[CommentHeader]
    J --> L[CommentText]
    J --> M[DeleteCommentButton]
    
    E --> N[TextField]
    E --> O[SendButton]
```

**Component Breakdown**:
- **PostDetailScreen**: Full post view
- **PostContent**: Post details
- **CommentsList**: Scrollable comments
- **CommentInput**: Add new comment

### 6. ChatScreen Component Flow

```mermaid
graph TB
    A[ChatScreen] --> B[AppBar]
    A --> C[MessageList]
    A --> D[MessageInput]
    
    C --> E[ListView.builder]
    E --> F[MessageBubble]
    
    F --> G[SentBubble]
    F --> H[ReceivedBubble]
    
    D --> I[TextField]
    D --> J[SendButton]
    
    C --> K[ScrollController]
    K --> L[Auto-scroll to bottom]
```

**Component Breakdown**:
- **ChatScreen**: Chat container
- **MessageList**: Scrollable message list
- **MessageBubble**: Individual message display
- **MessageInput**: Send new messages

**MessageBubble Variants**:
- **SentBubble**: User's own messages (right-aligned)
- **ReceivedBubble**: Others' messages (left-aligned)

### 7. UserUpdatesScreen Component Flow

```mermaid
graph TB
    A[UserUpdatesScreen] --> B[AppBar]
    A --> C[RefreshIndicator]
    A --> D[AnnouncementsList]
    
    D --> E[AnnouncementCard]
    E --> F[AnnouncementTitle]
    E --> G[AnnouncementMessage]
    E --> H[AnnouncementDate]
```

**Component Breakdown**:
- **UserUpdatesScreen**: Announcements view
- **AnnouncementsList**: Scrollable list
- **AnnouncementCard**: Individual announcement

### 8. Admin Screens Component Flow

#### ManageAnnouncementsScreen

```mermaid
graph TB
    A[ManageAnnouncementsScreen] --> B[AppBar]
    A --> C[AnnouncementForm]
    A --> D[AnnouncementsList]
    
    C --> E[TitleInput]
    C --> F[MessageInput]
    C --> G[PublishButton]
    
    D --> H[AnnouncementCard]
```

#### ManageMentorRequestsScreen

```mermaid
graph TB
    A[ManageMentorRequestsScreen] --> B[AppBar]
    A --> C[FilterChips]
    A --> D[RequestsList]
    
    C --> E[AllFilter]
    C --> F[PendingFilter]
    C --> G[AcceptedFilter]
    C --> H[ResolvedFilter]
    
    D --> I[MentorRequestCard]
    I --> J[RequestDetails]
    I --> K[StatusButtons]
```

#### AdminComplaintsScreen

```mermaid
graph TB
    A[AdminComplaintsScreen] --> B[AppBar]
    A --> C[ComplaintsList]
    
    C --> D[ComplaintCard]
    D --> E[UserEmail]
    D --> F[TeamId]
    D --> G[Message]
    D --> H[Status]
    D --> I[ResolveButton]
```

### 9. UserComplaintsScreen Component Flow

```mermaid
graph TB
    A[UserComplaintsScreen] --> B[ComplaintForm]
    A --> C[ComplaintsList]
    
    B --> D[MessageInput]
    B --> E[SubmitButton]
    
    C --> F[ComplaintCard]
    F --> G[Message]
    F --> H[Status]
    F --> I[CreatedAt]
```

## Component Communication Patterns

### 1. Parent to Child Communication
**Pattern**: Pass data through constructor parameters

```dart
// Parent
PostCard(post: post, onLike: () => toggleLike(post.id))

// Child
class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;
}
```

### 2. Child to Parent Communication
**Pattern**: Callback functions

```dart
// Child
ElevatedButton(
  onPressed: widget.onLike,
  child: Text('Like'),
)

// Parent
PostCard(
  post: post,
  onLike: () => toggleLike(post.id),
)
```

### 3. Sibling Communication
**Pattern**: State lifted to parent or shared via Riverpod

```dart
// Via Riverpod
final postStateProvider = Provider<PostState>((ref) => PostState());

// Both siblings access same provider
final postState = ref.watch(postStateProvider);
```

### 4. Cross-Screen Communication
**Pattern**: Riverpod providers or navigation parameters

```dart
// Via Provider
final feedRepositoryProvider = Provider<FeedRepository>((ref) => FeedRepository());

// Via Navigation
context.push('/post-detail', extra: postId);
```

## Component Lifecycle Flow

### StatefulWidget Lifecycle

```mermaid
sequenceDiagram
    participant Widget as StatefulWidget
    participant State as State
    participant Build as Build
    
    Widget->>State: createState()
    State->>State: initState()
    State->>State: didChangeDependencies()
    State->>Build: build()
    Build-->>Widget: Widget tree
    State->>State: didUpdateWidget()
    State->>Build: build()
    Build-->>Widget: Updated widget
    State->>State: dispose()
```

### Provider Lifecycle

```mermaid
sequenceDiagram
    participant Widget as Widget
    participant Provider as Riverpod Provider
    participant State as Provider State
    
    Widget->>Provider: ref.watch()
    Provider->>State: Initialize state
    State-->>Provider: Initial value
    Provider-->>Widget: Current value
    State->>State: State changes
    State-->>Provider: Notify listeners
    Provider-->>Widget: New value
    Widget->>Widget: Rebuild
```

## Component Reusability

### Reusable Components

1. **PostCard**: Used in FeedScreen and PostDetailScreen
2. **MessageBubble**: Used for all chat messages
3. **AnnouncementCard**: Used in admin and user screens
4. **LoadingIndicator**: Reused across all screens
5. **ErrorDisplay**: Reused error handling component

### Component Composition

```dart
// Composing smaller components
PostCard(
  post: post,
  child: Column(
    children: [
      PostHeader(user: user),
      PostContent(text: text),
      PostImage(url: imageUrl),
      PostActions(
        onLike: onLike,
        onComment: onComment,
      ),
    ],
  ),
)
```

## Component State Management

### Local State
- **TextEditingController**: Form inputs
- **ScrollController**: Scroll position
- **AnimationController**: Animations
- **bool flags**: Loading states

### Global State
- **Riverpod Providers**: Shared state across screens
- **PostState**: Post like cache
- **SessionService**: User session data

## Component Performance Optimization

### 1. Const Constructors
```dart
const PostCard({required this.post}); // Compile-time constant
```

### 2. ListView.builder
```dart
ListView.builder(
  itemCount: posts.length,
  itemBuilder: (context, index) => PostCard(post: posts[index]),
)
```

### 3. RepaintBoundary
```dart
RepaintBoundary(
  child: PostCard(post: post),
)
```

## Component Testing Strategy

### Unit Tests
- Test individual widgets in isolation
- Mock providers and repositories
- Verify widget output

### Widget Tests
- Test widget interactions
- Test callback execution
- Verify state changes

### Integration Tests
- Test complete user flows
- Test navigation
- Test data persistence
