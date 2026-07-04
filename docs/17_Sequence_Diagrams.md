# Sequence Diagrams

## Overview
This document contains Mermaid sequence diagrams illustrating key interactions within the CodeNyx application.

## Authentication Flow

```mermaid
sequenceDiagram
    participant User
    participant AuthScreen as Auth Screen
    participant SupabaseAuth as Supabase Auth
    participant Google as Google OAuth
    participant Session as Session Service
    participant DB as Database
    
    User->>AuthScreen: Tap "Sign in with Google"
    AuthScreen->>SupabaseAuth: signInWithOAuth(Google)
    SupabaseAuth->>Google: Redirect to OAuth
    User->>Google: Complete OAuth flow
    Google->>SupabaseAuth: Authorization code
    SupabaseAuth->>SupabaseAuth: Create session
    SupabaseAuth-->>AuthScreen: Session data
    AuthScreen->>DB: Fetch user profile
    DB-->>AuthScreen: Profile + team_id
    AuthScreen->>Session: saveSession(teamId, userData)
    Session-->>AuthScreen: Saved
    AuthScreen->>User: Navigate to feed
```

## Create Post Flow

```mermaid
sequenceDiagram
    participant User
    participant CreatePost as CreatePostScreen
    participant ImageService as ImageUploadService
    participant Storage as Supabase Storage
    participant Repo as FeedRepository
    participant DB as Database
    
    User->>CreatePost: Enter text
    User->>CreatePost: Select image
    CreatePost->>ImageService: pickImage()
    ImageService-->>CreatePost: Image file
    CreatePost->>ImageService: compressImage()
    ImageService->>ImageService: Resize & compress
    ImageService-->>CreatePost: Compressed bytes
    CreatePost->>Storage: uploadImage()
    Storage-->>CreatePost: Public URL
    User->>CreatePost: Tap "Post"
    CreatePost->>Repo: createPost(text, imageUrl)
    Repo->>DB: INSERT into posts
    DB-->>Repo: Success
    Repo-->>CreatePost: Post created
    CreatePost->>User: Navigate to feed
```

## Load Feed Flow

```mermaid
sequenceDiagram
    participant FeedScreen as FeedScreen
    participant Repo as FeedRepository
    participant DB as Database
    participant PostState as PostState
    participant UI as UI
    
    FeedScreen->>FeedScreen: initState()
    FeedScreen->>Repo: getPosts(page, limit)
    Repo->>DB: SELECT posts with pagination
    DB-->>Repo: Post records
    Repo->>DB: SELECT user names
    DB-->>Repo: User names
    Repo->>Repo: Resolve names
    Repo->>PostState: Update cache
    PostState-->>Repo: Updated
    Repo-->>FeedScreen: Posts list
    FeedScreen->>UI: Render post cards
    UI-->>User: Display feed
```

## Like Post Flow

```mermaid
sequenceDiagram
    participant User
    participant FeedScreen as FeedScreen
    participant PostState as PostState
    participant Repo as FeedRepository
    participant DB as Database
    
    User->>FeedScreen: Tap like button
    FeedScreen->>PostState: Check like status
    PostState-->>FeedScreen: Current status
    alt Not liked
        FeedScreen->>Repo: toggleLike(postId, false)
        Repo->>DB: INSERT into likes
        Repo->>DB: UPDATE posts like_count +1
        DB-->>Repo: Success
        Repo->>PostState: Update cache (liked=true, count+1)
    else Already liked
        FeedScreen->>Repo: toggleLike(postId, true)
        Repo->>DB: DELETE from likes
        Repo->>DB: UPDATE posts like_count -1
        DB-->>Repo: Success
        Repo->>PostState: Update cache (liked=false, count-1)
    end
    PostState->>FeedScreen: Notify listeners
    FeedScreen->>User: Update UI
```

## Send Chat Message Flow

```mermaid
sequenceDiagram
    participant User
    participant ChatScreen as ChatScreen
    participant Repo as ChatRepository
    participant DB as Database
    participant Realtime as Supabase Realtime
    participant OtherUser as Other User
    
    User->>ChatScreen: Type message
    User->>ChatScreen: Tap send
    ChatScreen->>Repo: sendMessage(teamId, message)
    Repo->>DB: INSERT into messages
    DB-->>Repo: Success
    Repo-->>ChatScreen: Sent
    DB->>Realtime: Broadcast change
    Realtime->>OtherUser: Push new message
    OtherUser->>OtherUser: Update UI
    ChatScreen->>ChatScreen: Auto-scroll
```

## Receive Real-time Message Flow

```mermaid
sequenceDiagram
    participant OtherUser as Other User
    participant DB as Database
    participant Realtime as Supabase Realtime
    participant Stream as StreamProvider
    participant ChatScreen as ChatScreen
    participant User as Current User
    
    OtherUser->>DB: INSERT message
    DB->>Realtime: Notify of INSERT
    Realtime->>Stream: Emit new message
    Stream->>ChatScreen: Rebuild with new data
    ChatScreen->>User: Display message
    ChatScreen->>ChatScreen: Auto-scroll to bottom
```

## Create Announcement Flow (Admin)

```mermaid
sequenceDiagram
    participant Admin
    participant AdminScreen as AdminScreen
    participant Repo as AnnouncementRepository
    participant DB as Database
    participant User as Regular User
    
    Admin->>AdminScreen: Enter title & message
    Admin->>AdminScreen: Tap "Publish"
    AdminScreen->>Repo: createAnnouncement(title, message)
    Repo->>DB: INSERT into announcements
    DB-->>Repo: Success
    Repo-->>AdminScreen: Created
    AdminScreen->>AdminScreen: Refresh list
    AdminScreen->>Admin: Show success
    User->>User: See new announcement
```

## Submit Complaint Flow

```mermaid
sequenceDiagram
    participant User
    participant ComplaintScreen as ComplaintScreen
    participant Session as SessionService
    participant Repo as ComplaintsRepository
    participant DB as Database
    
    User->>ComplaintScreen: Enter complaint
    User->>ComplaintScreen: Tap "Submit"
    ComplaintScreen->>Session: getSession()
    Session-->>ComplaintScreen: teamId, userEmail
    ComplaintScreen->>Repo: createComplaint(message)
    Repo->>DB: INSERT into complaints
    DB-->>Repo: Success
    Repo-->>ComplaintScreen: Created
    ComplaintScreen->>ComplaintScreen: Refresh list
    ComplaintScreen->>User: Show success
```

## Resolve Complaint Flow (Admin)

```mermaid
sequenceDiagram
    participant Admin
    participant AdminScreen as AdminComplaintsScreen
    participant Repo as ComplaintsRepository
    participant DB as Database
    participant User as Complainant
    
    Admin->>AdminScreen: View complaint
    Admin->>AdminScreen: Tap "Resolve"
    AdminScreen->>Repo: updateComplaintStatus(complaintId)
    Repo->>DB: UPDATE status='resolved'
    DB-->>Repo: Success
    Repo-->>AdminScreen: Updated
    AdminScreen->>AdminScreen: Refresh list
    AdminScreen->>Admin: Show resolved
    User->>User: See resolved status
```

## Navigation Flow

```mermaid
sequenceDiagram
    participant User
    participant UI as Current Screen
    participant Router as GoRouter
    participant NewScreen as New Screen
    
    User->>UI: Tap navigation item
    UI->>Router: router.push('/new-route')
    Router->>Router: Validate route
    Router->>Router: Check auth state
    alt Authenticated
        Router->>NewScreen: Build screen
        NewScreen-->>Router: Widget
        Router-->>UI: Navigate
        UI->>User: Display new screen
    else Not authenticated
        Router->>Router: Redirect to auth
        Router-->>UI: Navigate to auth
        UI->>User: Display auth screen
    end
```

## Error Handling Flow

```mermaid
sequenceDiagram
    participant User
    participant UI as UI Screen
    participant Repo as Repository
    participant Supabase as Supabase
    participant Error as Error Handler
    
    User->>UI: Perform action
    UI->>Repo: Call repository method
    Repo->>Supabase: API call
    Supabase-->>Repo: Error exception
    Repo->>Error: Throw exception
    Error->>UI: Catch exception
    UI->>UI: Show error message
    UI->>User: Display SnackBar
    User->>UI: Option to retry
    alt Retry
        UI->>Repo: Retry call
        Repo->>Supabase: API call
        Supabase-->>Repo: Success
        Repo-->>UI: Success
        UI->>User: Show success
    end
```

## Session Refresh Flow

```mermaid
sequenceDiagram
    participant App as App
    participant SupabaseAuth as Supabase Auth
    participant Session as Session Service
    participant UI as UI
    
    App->>SupabaseAuth: Check session
    alt Session valid
        SupabaseAuth-->>App: Session OK
        App->>Session: Load session
        Session-->>App: Session data
        App->>UI: Navigate to feed
    else Session expired
        SupabaseAuth->>SupabaseAuth: Refresh token
        alt Refresh successful
            SupabaseAuth-->>App: New session
            App->>Session: Update session
            Session-->>App: Updated
            App->>UI: Continue
        else Refresh failed
            SupabaseAuth-->>App: Refresh failed
            App->>Session: Clear session
            Session-->>App: Cleared
            App->>UI: Navigate to auth
        end
    end
```

## Image Upload Flow

```mermaid
sequenceDiagram
    participant User
    participant Screen as CreatePostScreen
    participant Picker as ImagePicker
    participant Compressor as Image Compressor
    participant Storage as Supabase Storage
    participant DB as Database
    
    User->>Screen: Tap image picker
    Screen->>Picker: pickImage()
    Picker-->>Screen: Image file
    Screen->>Compressor: compressImage()
    Compressor->>Compressor: Decode image
    Compressor->>Compressor: Resize to 800x800
    Compressor->>Compressor: Compress to 85% quality
    Compressor->>Compressor: Check size <500KB
    Compressor-->>Screen: Compressed bytes
    Screen->>Storage: upload(fileName, bytes)
    Storage->>Storage: Upload to bucket
    Storage-->>Screen: Public URL
    Screen->>Screen: Display preview
    User->>Screen: Submit post
    Screen->>DB: Insert post with URL
```

## Pull-to-Refresh Flow

```mermaid
sequenceDiagram
    participant User
    participant FeedScreen as FeedScreen
    participant RefreshIndicator as RefreshIndicator
    participant Repo as FeedRepository
    participant DB as Database
    
    User->>FeedScreen: Pull down
    FeedScreen->>RefreshIndicator: onRefresh
    RefreshIndicator->>Repo: getPosts(refresh=true)
    Repo->>DB: SELECT posts (fresh)
    DB-->>Repo: Latest posts
    Repo-->>RefreshIndicator: New data
    RefreshIndicator->>FeedScreen: Update list
    FeedScreen->>User: Show refreshed feed
```

## Pagination Flow

```mermaid
sequenceDiagram
    participant User
    participant FeedScreen as FeedScreen
    participant ScrollController as ScrollController
    participant Repo as FeedRepository
    participant DB as Database
    
    User->>FeedScreen: Scroll down
    FeedScreen->>ScrollController: Check position
    ScrollController->>ScrollController: Near bottom?
    alt Near bottom
        ScrollController->>FeedScreen: Load more
        FeedScreen->>Repo: getPosts(nextPage, limit)
        Repo->>DB: SELECT posts with offset
        DB-->>Repo: Next batch
        Repo-->>FeedScreen: New posts
        FeedScreen->>FeedScreen: Append to list
        FeedScreen->>User: Show more posts
    end
```

## Sign Out Flow

```mermaid
sequenceDiagram
    participant User
    participant UI as UI
    participant Auth as Supabase Auth
    participant Session as SessionService
    participant Router as GoRouter
    
    User->>UI: Tap sign out
    UI->>Auth: signOut()
    Auth->>Auth: Clear session
    Auth-->>UI: Signed out
    UI->>Session: clearSession()
    Session->>Session: Remove from storage
    Session-->>UI: Cleared
    UI->>Router: Navigate to auth
    Router-->>UI: Auth screen
    UI->>User: Display auth screen
```
