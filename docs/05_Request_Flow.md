# Request Flow

## Overview
This document explains how user requests flow through the CodeNyx application from UI interaction to data persistence and back.

## General Request Flow Pattern

```mermaid
sequenceDiagram
    participant User
    participant UI as Flutter UI
    participant Provider as Riverpod Provider
    participant Repo as Repository
    participant Service as Service
    participant Supabase as Supabase
    
    User->>UI: User Action (tap, input)
    UI->>Provider: Call provider method
    Provider->>Repo: Call repository method
    Repo->>Service: Call service (if needed)
    Service->>Supabase: API call
    Supabase-->>Service: Response
    Service-->>Repo: Processed data
    Repo-->>Provider: Updated state
    Provider-->>UI: State change
    UI-->>User: UI update
```

## Authentication Request Flow

### Google OAuth Sign-In

```mermaid
sequenceDiagram
    participant User
    participant AuthScreen as Auth Screen
    participant SupabaseAuth as Supabase Auth
    participant Profiles as Profiles Table
    participant Session as Session Service
    
    User->>AuthScreen: Click "Sign in with Google"
    AuthScreen->>SupabaseAuth: signInWithOAuth()
    SupabaseAuth-->>AuthScreen: Redirect to Google
    User->>SupabaseAuth: Complete OAuth flow
    SupabaseAuth-->>AuthScreen: Auth session
    AuthScreen->>Profiles: Fetch user profile
    Profiles-->>AuthScreen: User data + teamId
    AuthScreen->>Session: saveSession(teamId, userData)
    Session-->>AuthScreen: Session saved
    AuthScreen->>User: Navigate to feed
```

**Steps**:
1. User taps "Sign in with Google" button
2. AuthScreen calls Supabase `signInWithOAuth()`
3. User completes OAuth flow in browser
4. Supabase returns auth session
5. App fetches user profile from `profiles` table
6. Team ID extracted from profile
7. Session saved using SessionService
8. User navigated to feed screen

## Social Feed Request Flows

### Create Post Request

```mermaid
sequenceDiagram
    participant User
    participant CreatePost as CreatePostScreen
    participant ImageService as ImageUploadService
    participant FeedRepo as FeedRepository
    participant Supabase as Supabase
    participant PostState as PostState
    
    User->>CreatePost: Enter text & select image
    CreatePost->>ImageService: pickAndUploadImage()
    ImageService->>ImageService: Pick from gallery
    ImageService->>ImageService: Compress image
    ImageService->>Supabase: Upload to storage
    Supabase-->>ImageService: Public URL
    ImageService-->>CreatePost: Image URL
    User->>CreatePost: Click "Post"
    CreatePost->>FeedRepo: createPost(text, imageUrl)
    FeedRepo->>Supabase: Insert into posts table
    Supabase-->>FeedRepo: Success
    FeedRepo-->>CreatePost: Post created
    CreatePost->>PostState: Update cache (if needed)
    CreatePost->>User: Navigate back to feed
```

**Steps**:
1. User enters text and optionally selects image
2. ImageService picks image from gallery
3. Image compressed to reduce size
4. Image uploaded to Supabase Storage
5. Public URL returned
6. User clicks "Post" button
7. FeedRepository inserts post into `posts` table
8. PostState cache updated (if needed)
9. User navigated back to feed

### Like Post Request

```mermaid
sequenceDiagram
    participant User
    participant FeedScreen as FeedScreen
    participant FeedRepo as FeedRepository
    participant PostState as PostState
    participant Supabase as Supabase
    
    User->>FeedScreen: Tap like button
    FeedScreen->>PostState: Check current like status
    PostState-->>FeedScreen: Current status
    FeedScreen->>FeedRepo: toggleLike(postId, currentStatus)
    FeedRepo->>Supabase: Check if liked
    alt Already liked
        FeedRepo->>Supabase: Delete from likes table
        FeedRepo->>Supabase: Decrement like count
    else Not liked
        FeedRepo->>Supabase: Insert into likes table
        FeedRepo->>Supabase: Increment like count
    end
    Supabase-->>FeedRepo: Success
    FeedRepo-->>PostState: Update cache
    PostState-->>FeedScreen: Notify listeners
    FeedScreen->>User: Update like button UI
```

**Steps**:
1. User taps like button
2. PostState checks current like status
3. FeedRepository toggles like in Supabase
4. If liked: delete from `likes` table, decrement count
5. If not liked: insert to `likes` table, increment count
6. PostState cache updated for instant UI feedback
7. UI updated with new like status

### Add Comment Request

```mermaid
sequenceDiagram
    participant User
    participant PostDetail as PostDetailScreen
    participant FeedRepo as FeedRepository
    participant Supabase as Supabase
    
    User->>PostDetail: Enter comment text
    User->>PostDetail: Click "Send"
    PostDetail->>FeedRepo: addComment(postId, commentText)
    FeedRepo->>Supabase: Insert into comments table
    Supabase-->>FeedRepo: Success
    FeedRepo->>Supabase: Fetch updated comments
    Supabase-->>FeedRepo: Comments list
    FeedRepo-->>PostDetail: Updated comments
    PostDetail->>User: Display new comment
```

**Steps**:
1. User enters comment text
2. User clicks "Send" button
3. FeedRepository inserts comment into `comments` table
4. FeedRepository fetches updated comments
5. UI updated with new comment

## Chat Request Flows

### Send Message Request

```mermaid
sequenceDiagram
    participant User
    participant ChatScreen as ChatScreen
    participant ChatRepo as ChatRepository
    participant Supabase as Supabase
    participant Stream as Message Stream
    
    User->>ChatScreen: Enter message
    User->>ChatScreen: Click send
    ChatScreen->>ChatRepo: sendMessage(teamId, message)
    ChatRepo->>Supabase: Insert into messages table
    Supabase-->>ChatRepo: Success
    Supabase->>Stream: Push new message
    Stream-->>ChatScreen: New message received
    ChatScreen->>User: Display message
```

**Steps**:
1. User enters message text
2. User clicks send button
3. ChatRepository inserts message into `messages` table
4. Supabase realtime pushes new message
5. StreamProvider receives new message
6. UI updated with new message

### Receive Real-time Message

```mermaid
sequenceDiagram
    participant OtherUser as Other User
    participant Supabase as Supabase
    participant Stream as Realtime Stream
    participant ChatScreen as ChatScreen
    participant User as Current User
    
    OtherUser->>Supabase: Send message
    Supabase->>Stream: Broadcast change
    Stream-->>ChatScreen: Stream emits new message
    ChatScreen->>User: Display new message
    ChatScreen->>ChatScreen: Auto-scroll to bottom
```

**Steps**:
1. Other user sends message via their app
2. Supabase broadcasts change via realtime
3. StreamProvider emits new message
4. Current user's UI updates automatically
5. Chat auto-scrolls to show new message

## Admin Request Flows

### Create Announcement Request

```mermaid
sequenceDiagram
    participant Admin
    participant AdminScreen as ManageAnnouncementsScreen
    participant AdminRepo as Announcement Repository
    participant Supabase as Supabase
    
    Admin->>AdminScreen: Enter title & message
    Admin->>AdminScreen: Click "Publish"
    AdminScreen->>AdminRepo: createAnnouncement(title, message)
    AdminRepo->>Supabase: Insert into announcements table
    Supabase-->>AdminRepo: Success
    AdminRepo-->>AdminScreen: Announcement created
    AdminScreen->>AdminScreen: Refresh announcements list
    AdminScreen->>Admin: Show success message
```

**Steps**:
1. Admin enters title and message
2. Admin clicks "Publish" button
3. Repository inserts announcement into `announcements` table
4. Announcements list refreshed
5. Success message displayed

### Update Mentor Request Status

```mermaid
sequenceDiagram
    participant Admin
    participant MentorScreen as ManageMentorRequestsScreen
    participant MentorRepo as Mentor Request Repository
    participant Supabase as Supabase
    
    Admin->>MentorScreen: Select request
    Admin->>MentorScreen: Click "Accept" or "Resolve"
    MentorScreen->>MentorRepo: updateRequestStatus(requestId, newStatus)
    MentorRepo->>Supabase: Update mentor_requests table
    Supabase-->>MentorRepo: Success
    MentorRepo-->>MentorScreen: Status updated
    MentorScreen->>MentorScreen: Refresh requests list
    MentorScreen->>Admin: Show updated status
```

**Steps**:
1. Admin selects a mentor request
2. Admin clicks status update button
3. Repository updates status in `mentor_requests` table
4. Requests list refreshed
5. Updated status displayed

## Complaint Request Flows

### Submit Complaint Request

```mermaid
sequenceDiagram
    participant User
    participant ComplaintScreen as UserComplaintsScreen
    participant ComplaintRepo as ComplaintsRepository
    participant Session as SessionService
    participant Supabase as Supabase
    
    User->>ComplaintScreen: Enter complaint message
    User->>ComplaintScreen: Click "Submit"
    ComplaintScreen->>Session: getSession()
    Session-->>ComplaintScreen: teamId, userEmail
    ComplaintScreen->>ComplaintRepo: createComplaint(message)
    ComplaintRepo->>Supabase: Insert into complaints table
    Supabase-->>ComplaintRepo: Success
    ComplaintRepo-->>ComplaintScreen: Complaint created
    ComplaintScreen->>ComplaintScreen: Refresh complaints list
    ComplaintScreen->>User: Show success message
```

**Steps**:
1. User enters complaint message
2. User clicks "Submit" button
3. SessionService retrieves team ID and user email
4. Repository inserts complaint into `complaints` table
5. Complaints list refreshed
6. Success message displayed

### Resolve Complaint Request (Admin)

```mermaid
sequenceDiagram
    participant Admin
    participant AdminComplaint as AdminComplaintsScreen
    participant ComplaintRepo as ComplaintsRepository
    participant Supabase as Supabase
    
    Admin->>AdminComplaint: View complaint
    Admin->>AdminComplaint: Click "Resolve"
    AdminComplaint->>ComplaintRepo: updateComplaintStatus(complaintId)
    ComplaintRepo->>Supabase: Update complaints table (status='resolved')
    Supabase-->>ComplaintRepo: Success
    ComplaintRepo-->>AdminComplaint: Status updated
    AdminComplaint->>AdminComplaint: Refresh complaints list
    AdminComplaint->>Admin: Show resolved status
```

**Steps**:
1. Admin views complaint details
2. Admin clicks "Resolve" button
3. Repository updates status to 'resolved' in `complaints` table
4. Complaints list refreshed
5. Resolved status displayed

## Error Handling Flow

```mermaid
sequenceDiagram
    participant User
    participant UI as UI Screen
    participant Repo as Repository
    participant Supabase as Supabase
    
    User->>UI: User action
    UI->>Repo: Repository call
    Repo->>Supabase: API call
    Supabase-->>Repo: Error exception
    Repo-->>UI: Throw exception
    UI->>UI: Catch exception
    UI->>User: Show error SnackBar
    UI->>User: Option to retry
```

**Error Handling Steps**:
1. User performs action
2. Repository calls Supabase
3. Supabase returns error
4. Repository throws exception
5. UI catches exception
6. Error message displayed to user
7. User can retry the action

## Navigation Flow

```mermaid
sequenceDiagram
    participant User
    participant UI as Current Screen
    participant Router as go_router
    participant NewScreen as New Screen
    
    User->>UI: Tap navigation item
    UI->>Router: router.push('/new-route')
    Router->>Router: Check route
    Router->>NewScreen: Build new screen
    NewScreen-->>Router: Screen widget
    Router-->>UI: Navigate
    UI->>User: Display new screen
```

**Navigation Steps**:
1. User taps navigation item
2. UI calls go_router with route path
3. Router validates route
4. New screen built
5. Navigation performed
6. New screen displayed
