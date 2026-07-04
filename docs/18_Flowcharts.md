# Flowcharts

## Overview
This document contains Mermaid flowcharts illustrating key processes and decision flows in the CodeNyx application.

## App Startup Flow

```mermaid
flowchart TD
    A[App Launch] --> B{Environment Variables Set?}
    B -->|No| C[Show Error & Exit]
    B -->|Yes| D[Initialize Supabase]
    D --> E{Supabase Initialized?}
    E -->|No| F[Show Error & Exit]
    E -->|Yes| G[Check Auth State]
    G --> H{User Authenticated?}
    H -->|Yes| I[Load Session]
    H -->|No| J[Show Auth Screen]
    I --> K{Session Valid?}
    K -->|Yes| L[Navigate to Feed]
    K -->|No| J
    L --> M[App Ready]
    J --> N[User Signs In]
    N --> I
```

## Authentication Flow

```mermaid
flowchart TD
    A[User Opens App] --> B{Has Valid Session?}
    B -->|Yes| C[Navigate to Feed]
    B -->|No| D[Show Auth Screen]
    D --> E[User Taps Sign In with Google]
    E --> F[Redirect to Google OAuth]
    F --> G{User Completes OAuth?}
    G -->|Yes| H[Receive Auth Session]
    G -->|No| D
    H --> I[Fetch User Profile]
    I --> J{Profile Exists?}
    J -->|Yes| K[Extract Team ID]
    J -->|No| L[Create Profile]
    L --> K
    K --> M[Save Session]
    M --> C
```

## Create Post Flow

```mermaid
flowchart TD
    A[User Opens Create Post] --> B[Enter Text Content]
    B --> C{Add Image?}
    C -->|Yes| D[Open Image Picker]
    C -->|No| F[Tap Post Button]
    D --> E[Select Image]
    E --> G[Compress Image]
    G --> H{Size < 500KB?}
    H -->|No| I[Show Error]
    H -->|Yes| J[Upload to Supabase Storage]
    J --> K{Upload Success?}
    K -->|No| I
    K -->|Yes| L[Get Public URL]
    L --> F
    F --> M{Text Not Empty?}
    M -->|No| N[Show Validation Error]
    M -->|Yes| O[Call createPost API]
    O --> P{API Success?}
    P -->|No| Q[Show Error]
    P -->|Yes| R[Navigate to Feed]
    R --> S[Feed Refreshed]
```

## Like Post Flow

```mermaid
flowchart TD
    A[User Taps Like Button] --> B[Check Current Like Status]
    B --> C{Already Liked?}
    C -->|Yes| D[Call Unlike API]
    C -->|No| E[Call Like API]
    D --> F{API Success?}
    E --> G{API Success?}
    F -->|No| H[Show Error]
    F -->|Yes| I[Decrement Like Count]
    G -->|No| H
    G -->|Yes| J[Increment Like Count]
    I --> K[Update PostState Cache]
    J --> K
    K --> L[Update UI]
    L --> M[Show Unlike Button]
    M --> N[Show Like Button]
```

## Send Chat Message Flow

```mermaid
flowchart TD
    A[User Types Message] --> B[Tap Send Button]
    B --> C{Message Not Empty?}
    C -->|No| D[Show Validation Error]
    C -->|Yes| E[Call sendMessage API]
    E --> F{API Success?}
    F -->|No| G[Show Error]
    F -->|Yes| H[Clear Input Field]
    H --> I[Message Added to Database]
    I --> J[Real-time Broadcast]
    J --> K[All Team Members Receive]
    K --> L[UI Auto-scrolls]
    L --> M[Message Displayed]
```

## Admin Create Announcement Flow

```mermaid
flowchart TD
    A[Admin Opens Manage Announcements] --> B[Enter Title]
    B --> C[Enter Message]
    C --> D[Tap Publish Button]
    D --> E{Title & Message Not Empty?}
    E -->|No| F[Show Validation Error]
    E -->|Yes| G[Call createAnnouncement API]
    G --> H{API Success?}
    H -->|No| I[Show Error]
    H -->|Yes| J[Refresh Announcements List]
    J --> K[Show Success Message]
    K --> L[New Announcement Visible]
```

## Submit Complaint Flow

```mermaid
flowchart TD
    A[User Opens Complaints] --> B[Enter Complaint Message]
    B --> C[Tap Submit Button]
    C --> D{Message Not Empty?}
    D -->|No| E[Show Validation Error]
    D -->|Yes| F[Get Session Data]
    F --> G{Session Valid?}
    G -->|No| H[Show Session Error]
    G -->|Yes| I[Call createComplaint API]
    I --> J{API Success?}
    J -->|No| K[Show Error]
    J -->|Yes| L[Refresh Complaints List]
    L --> M[Show Success Message]
    M --> N[Complaint Listed]
```

## Admin Resolve Complaint Flow

```mermaid
flowchart TD
    A[Admin Opens Complaints] --> B[View Complaint Details]
    B --> C{Status Pending?}
    C -->|No| D[Disable Resolve Button]
    C -->|Yes| E[Enable Resolve Button]
    E --> F[Admin Taps Resolve]
    F --> G[Call updateComplaintStatus API]
    G --> H{API Success?}
    H -->|No| I[Show Error]
    H -->|Yes| J[Refresh Complaints List]
    J --> K[Show Success Message]
    K --> L[Status Changed to Resolved]
```

## Image Upload Flow

```mermaid
flowchart TD
    A[User Selects Image] --> B[ImagePicker Returns File]
    B --> C[Read File Bytes]
    C --> D[Decode Image]
    D --> E[Resize to 800x800]
    E --> F[Compress to 85% Quality]
    F --> G[Calculate Size]
    G --> H{Size < 500KB?}
    H -->|No| I[Show Size Error]
    H -->|Yes| J[Generate Filename]
    J --> K[Upload to Supabase Storage]
    K --> L{Upload Success?}
    L -->|No| M[Show Upload Error]
    L -->|Yes| N[Get Public URL]
    N --> O[Return URL to Caller]
```

## Error Handling Flow

```mermaid
flowchart TD
    A[User Action] --> B[Call Repository Method]
    B --> C[Repository Calls Supabase]
    C --> D{Success?}
    D -->|Yes| E[Return Data]
    D -->|No| F[Throw Exception]
    F --> G[UI Catches Exception]
    G --> H{Exception Type?}
    H -->|Network Error| I[Show Network Error Message]
    H -->|Auth Error| J[Show Auth Error Message]
    H -->|Validation Error| K[Show Validation Error]
    H -->|Server Error| L[Show Server Error Message]
    H -->|Unknown Error| M[Show Generic Error]
    I --> N[Offer Retry Option]
    J --> N
    K --> O[Show Input Error]
    L --> N
    M --> N
    N --> P{User Retries?}
    P -->|Yes| B
    P -->|No| Q[Stay on Screen]
```

## Navigation Flow

```mermaid
flowchart TD
    A[User Taps Navigation Item] --> B[GoRouter Receives Route]
    B --> C{Route Exists?}
    C -->|No| D[Show 404 Error]
    C -->|Yes| E{Auth Required?}
    E -->|No| F[Navigate to Route]
    E -->|Yes| G{User Authenticated?}
    G -->|No| H[Redirect to Auth]
    G -->|Yes| F
    F --> I[Build Screen]
    I --> J[Display Screen]
```

## Session Management Flow

```mermaid
flowchart TD
    A[App Checks Session] --> B{Session Exists?}
    B -->|No| C[Show Auth Screen]
    B -->|Yes| D{Session Valid?}
    D -->|No| E[Clear Session]
    E --> C
    D -->|Yes| F{Token Expired?}
    F -->|Yes| G[Attempt Refresh]
    G --> H{Refresh Success?}
    H -->|Yes| I[Update Session]
    H -->|No| E
    F -->|No| J[Load Session Data]
    I --> J
    J --> K[Navigate to Feed]
```

## Pull-to-Refresh Flow

```mermaid
flowchart TD
    A[User Pulls Down] --> B[RefreshIndicator Activates]
    B --> C[Call Repository Refresh]
    C --> D[Fetch Fresh Data]
    D --> E{Fetch Success?}
    E -->|No| F[Show Error]
    E -->|Yes| G[Update State]
    G --> H[UI Rebuilds]
    H --> I[RefreshIndicator Completes]
    I --> J[Show Updated Data]
```

## Pagination Flow

```mermaid
flowchart TD
    A[User Scrolls] --> B[ScrollController Checks Position]
    B --> C{Near Bottom?}
    C -->|No| D[Continue Scrolling]
    C -->|Yes| E{Loading More?}
    E -->|Yes| D
    E -->|No| F[Set Loading Flag]
    F --> G[Fetch Next Page]
    G --> H{Fetch Success?}
    H -->|No| I[Show Error]
    H -->|Yes| J[Append to List]
    J --> K[Clear Loading Flag]
    K --> L[UI Updates]
```

## Sign Out Flow

```mermaid
flowchart TD
    A[User Taps Sign Out] --> B[Confirm Sign Out]
    B --> C{User Confirms?}
    C -->|No| D[Cancel]
    C -->|Yes| E[Call Supabase signOut]
    E --> F{Sign Out Success?}
    F -->|No| G[Show Error]
    F -->|Yes| H[Clear Session Service]
    H --> I[Navigate to Auth Screen]
    I --> J[Show Auth Screen]
```

## Data Validation Flow

```mermaid
flowchart TD
    A[User Submits Form] --> B[Validate Required Fields]
    B --> C{All Fields Present?}
    C -->|No| D[Show Missing Field Error]
    C -->|Yes| E[Validate Field Formats]
    E --> F{Formats Valid?}
    F -->|No| G[Show Format Error]
    F -->|Yes| H[Validate Field Lengths]
    H --> I{Lengths Valid?}
    I -->|No| J[Show Length Error]
    I -->|Yes| K[Validate Business Rules]
    K --> L{Rules Valid?}
    L -->|No| M[Show Business Rule Error]
    L -->|Yes| N[Submit Data]
```

## Real-time Subscription Flow

```mermaid
flowchart TD
    A[Screen Initializes] --> B[Subscribe to Real-time]
    B --> C[StreamProvider Created]
    C --> D[Listen to Stream]
    D --> E{Data Change?}
    E -->|No| F[Continue Listening]
    E -->|Yes| G[Stream Emits New Data]
    G --> H[UI Rebuilds]
    H --> I{Screen Disposed?}
    I -->|No| F
    I -->|Yes| J[Cancel Subscription]
    J --> K[Cleanup Resources]
```
