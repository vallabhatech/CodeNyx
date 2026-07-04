# File by File Explanation

## Core Files

### main.dart
**Purpose**: Application entry point
**Key Responsibilities**:
- Initialize Supabase client with environment variables
- Run the Flutter app
- Configure app-wide settings

**Important Code**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  runApp(const CodeNyxApp());
}
```

### app.dart
**Purpose**: Root widget with routing configuration
**Key Responsibilities**:
- Define navigation routes using go_router
- Configure authentication guards
- Set up route handlers for all screens

**Routes Defined**:
- `/`: Auth screen (default)
- `/feed`: Social feed
- `/chat`: Team chat
- `/admin`: Admin panel
- `/complaints`: User complaints
- `/admin/complaints`: Admin complaints

## Core Theme Files

### lib/core/theme/app_theme.dart
**Purpose**: Centralized theme configuration
**Key Responsibilities**:
- Define color palette (primary, secondary, accent)
- Set up text styles (titles, body, meta)
- Configure spacing constants
- Define card decorations and gradients

**Key Constants**:
- `primaryBackground`: Main background color
- `accentPrimary`: Primary accent color (#6C63FF)
- `spacingS/M/L/XL`: Spacing scale
- `radiusSmall/Medium/Large`: Border radius values

### lib/core/constants/app_constants.dart
**Purpose**: Application-wide constants
**Key Responsibilities**:
- Define feature flags
- Set configuration values
- Store magic numbers

## Service Files

### lib/services/session_service.dart
**Purpose**: Manage user session data
**Key Responsibilities**:
- Store and retrieve session data (team ID, user info)
- Provide session validation
- Handle session persistence

**Key Methods**:
- `getSession()`: Retrieve current session
- `saveSession()`: Save session data
- `clearSession()`: Clear session data

### lib/services/supabase_service.dart
**Purpose**: Supabase client initialization
**Key Responsibilities**:
- Configure Supabase client
- Provide global Supabase instance access

## Feature: Social Feed

### lib/features/social_feed/feed_screen.dart
**Purpose**: Main social feed UI
**Key Responsibilities**:
- Display list of posts with pagination
- Handle post interactions (like, comment, delete)
- Navigate to post detail and create post screens
- Implement pull-to-refresh
- Show loading states

**Key Widgets**:
- `_PostCard`: Individual post display
- Like button with animation
- Comment preview

### lib/features/social_feed/feed_repository.dart
**Purpose**: Data layer for social feed
**Key Responsibilities**:
- Fetch posts with pagination
- Create new posts
- Handle likes/unlikes
- Manage comments (add, get, delete)
- Delete posts
- Resolve user names for posts

**Key Methods**:
- `getPosts()`: Fetch paginated posts
- `createPost()`: Create new post
- `toggleLike()`: Like/unlike post
- `addComment()`: Add comment to post
- `deletePost()`: Delete post

### lib/features/social_feed/create_post_screen.dart
**Purpose**: Create new post UI
**Key Responsibilities**:
- Text input for post content
- Image selection and preview
- Image compression before upload
- Submit post to repository

**Key Features**:
- Multi-line text input
- Image picker integration
- Image preview with delete option
- Loading state during upload

### lib/features/social_feed/post_detail_screen.dart
**Purpose**: View single post details
**Key Responsibilities**:
- Display full post content
- Show all comments
- Add new comments
- Toggle likes
- Delete post (if author)

**Key Widgets**:
- `_CommentCard`: Individual comment display
- Comment input field
- Like button with count

### lib/features/social_feed/post_state.dart
**Purpose**: In-memory cache for post data
**Key Responsibilities**:
- Cache post like counts
- Cache user like status
- Provide instant UI updates
- Notify listeners of changes

**Key Methods**:
- `updateLikeCount()`: Update cached like count
- `updateUserLiked()`: Update user like status
- `getPostState()`: Get cached post data

### lib/features/social_feed/image_upload_service.dart
**Purpose**: Handle image operations
**Key Responsibilities**:
- Pick image from gallery
- Compress image to reduce size
- Upload to Supabase Storage
- Return public URL

**Key Constants**:
- `MAX_WIDTH`: 800px
- `MAX_HEIGHT`: 800px
- `QUALITY`: 85
- `MAX_SIZE_KB`: 500KB

## Feature: Chat

### lib/features/chat/chat_screen.dart
**Purpose**: Team chat UI
**Key Responsibilities**:
- Display real-time messages
- Send new messages
- Auto-scroll to new messages
- Differentiate sent/received messages

**Key Features**:
- Real-time message updates via StreamProvider
- Message bubbles with different styles
- Auto-scroll on new messages
- Input field with send button

### lib/features/chat/chat_repository.dart
**Purpose**: Data layer for chat
**Key Responsibilities**:
- Watch for real-time message updates
- Send new messages
- Fetch message history
- Resolve user names

**Key Methods**:
- `watchTeamMessages()`: Stream of team messages
- `sendMessage()`: Send new message
- `resolveUserName()`: Get user display name

### lib/features/chat/chat_provider.dart
**Purpose**: Riverpod providers for chat
**Key Responsibilities**:
- Provide ChatRepository instance
- Provide message stream for specific team

**Providers**:
- `chatRepositoryProvider`: Repository instance
- `chatMessagesProvider`: Stream of messages (keepAlive)

### lib/features/chat/message_model.dart
**Purpose**: Data model for chat messages
**Key Responsibilities**:
- Define message structure
- Provide factory constructor from map

**Fields**:
- `id`: Unique message ID
- `teamId`: Team identifier
- `userId`: User who sent message
- `userName`: Display name of sender
- `message`: Message content
- `createdAt`: Timestamp

### lib/features/chat/message_bubble.dart
**Purpose**: Display individual message
**Key Responsibilities**:
- Style message based on sender
- Display message content
- Show timestamp

**Key Features**:
- Different alignment for sent/received
- Different colors for sent/received
- Rounded corners based on position

## Feature: User

### lib/features/user/user_updates_screen.dart
**Purpose**: Display announcements to users
**Key Responsibilities**:
- Fetch announcements from Supabase
- Display in scrollable list
- Handle loading/error states
- Pull-to-refresh

**Key Widgets**:
- `_AnnouncementCard`: Individual announcement display

### lib/features/user/timer_screen.dart
**Purpose**: Hackathon countdown timer
**Key Responsibilities**:
- Display countdown to hackathon end
- Update every second
- Handle timer expiration

## Feature: Admin

### lib/features/admin/admin_providers.dart
**Purpose**: Riverpod providers for admin features
**Key Responsibilities**:
- Provide announcement repository
- Provide mentor request repository

**Providers**:
- `announcementRepositoryProvider`: Announcements data
- `mentorRequestRepositoryProvider`: Mentor requests data

### lib/features/admin/manage_announcements_screen.dart
**Purpose**: Admin UI for announcements
**Key Responsibilities**:
- Create new announcements
- View existing announcements
- Handle form submission
- Show loading states

**Key Features**:
- Title and message input
- Submit button
- List of recent announcements

### lib/features/admin/manage_mentor_requests_screen.dart
**Purpose**: Admin UI for mentor requests
**Key Responsibilities**:
- View all mentor requests
- Filter by status (all, pending, accepted, resolved)
- Update request status
- Display request details

**Key Features**:
- Status filter chips
- Request cards with details
- Status update buttons

## Feature: Complaints

### lib/features/complaints/user_complaints_screen.dart
**Purpose**: User UI for complaints
**Key Responsibilities**:
- Submit new complaints
- View user's complaints
- Display complaint status
- Handle submission states

**Key Features**:
- Complaint message input
- Submit button
- List of user's complaints with status

### lib/features/complaints/admin_complaints_screen.dart
**Purpose**: Admin UI for complaints
**Key Responsibilities**:
- View all complaints
- Resolve complaints
- Display complaint details
- Filter by status

**Key Features**:
- Complaint cards with user info
- Resolve button
- Status indicators

### lib/features/complaints/complaints_repository.dart
**Purpose**: Data layer for complaints
**Key Responsibilities**:
- Create new complaint
- Fetch user complaints
- Fetch all complaints (admin)
- Update complaint status

**Key Methods**:
- `createComplaint()`: Submit new complaint
- `getUserComplaints()`: Get user's complaints
- `getAllComplaints()`: Get all complaints
- `updateComplaintStatus()`: Mark as resolved

## Configuration Files

### pubspec.yaml
**Purpose**: Project dependencies and metadata
**Key Dependencies**:
- `flutter`: SDK
- `supabase_flutter`: Supabase integration
- `go_router`: Navigation
- `flutter_riverpod`: State management
- `image_picker`: Image selection
- `image`: Image compression

### analysis_options.yaml
**Purpose**: Dart analyzer configuration
**Key Settings**:
- Uses `flutter_lints` for recommended rules
- Can customize lint rules
- Enables static analysis

### .gitignore
**Purpose**: Git ignore rules
**Ignored Items**:
- Build artifacts
- IDE files (.idea/, .vscode/)
- Dart tools (.dart_tool/)
- Flutter plugins
- iOS/Android build files
