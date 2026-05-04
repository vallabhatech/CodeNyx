# Architecture Diagrams

## Overview
This document contains Mermaid architecture diagrams illustrating the overall system architecture of the CodeNyx application.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        A[Flutter App]
        B[iOS]
        C[Android]
        D[Web]
    end
    
    subgraph "Presentation Layer"
        E[Screens]
        F[Widgets]
        G[Navigation]
    end
    
    subgraph "Business Logic Layer"
        H[Repositories]
        I[Services]
        J[Providers]
    end
    
    subgraph "Data Layer"
        K[Session Service]
        L[State Cache]
    end
    
    subgraph "Infrastructure Layer"
        M[Supabase Client]
    end
    
    subgraph "Backend Layer"
        N[Supabase Auth]
        O[PostgreSQL DB]
        P[Supabase Storage]
        Q[Supabase Realtime]
    end
    
    A --> E
    B --> E
    C --> E
    D --> E
    E --> F
    E --> G
    F --> H
    G --> H
    H --> I
    H --> J
    I --> K
    I --> L
    H --> M
    K --> M
    M --> N
    M --> O
    M --> P
    M --> Q
```

## Layered Architecture

```mermaid
graph LR
    subgraph "Presentation Layer"
        A[UI Screens]
        B[Widgets]
        C[Navigation]
    end
    
    subgraph "Business Logic Layer"
        D[Repositories]
        E[Services]
        F[State Management]
    end
    
    subgraph "Data Access Layer"
        G[Supabase Client]
        H[Session Service]
    end
    
    subgraph "External Services"
        I[Supabase Auth]
        J[Supabase DB]
        K[Supabase Storage]
        L[Supabase Realtime]
    end
    
    A --> D
    B --> D
    C --> D
    D --> E
    D --> F
    E --> G
    F --> H
    G --> I
    G --> J
    G --> K
    G --> L
    H --> I
```

## Feature Architecture

```mermaid
graph TB
    subgraph "Social Feed Feature"
        A1[FeedScreen]
        A2[FeedRepository]
        A3[PostState]
        A4[ImageUploadService]
    end
    
    subgraph "Chat Feature"
        B1[ChatScreen]
        B2[ChatRepository]
        B3[MessageModel]
    end
    
    subgraph "Admin Feature"
        C1[ManageAnnouncementsScreen]
        C2[ManageMentorRequestsScreen]
        C3[AdminComplaintsScreen]
        C4[AdminProviders]
    end
    
    subgraph "Complaints Feature"
        D1[UserComplaintsScreen]
        D2[AdminComplaintsScreen]
        D3[ComplaintsRepository]
    end
    
    subgraph "Shared Services"
        E1[SessionService]
        E2[SupabaseClient]
    end
    
    A1 --> A2
    A1 --> A3
    A1 --> A4
    B1 --> B2
    B1 --> B3
    C1 --> C4
    C2 --> C4
    C3 --> D3
    D1 --> D3
    A2 --> E2
    B2 --> E2
    D3 --> E2
    A4 --> E2
    A1 --> E1
    B1 --> E1
    D1 --> E1
```

## Data Architecture

```mermaid
graph TB
    subgraph "Client Data"
        A[UI State]
        B[Local Cache]
        C[Session Data]
    end
    
    subgraph "API Layer"
        D[Supabase Client]
        E[REST API]
        F[Realtime API]
    end
    
    subgraph "Database"
        G[PostgreSQL]
    end
    
    subgraph "Storage"
        H[Supabase Storage]
    end
    
    subgraph "Auth"
        I[Supabase Auth]
    end
    
    A --> D
    B --> D
    C --> D
    D --> E
    D --> F
    E --> G
    F --> G
    D --> H
    D --> I
```

## Component Architecture

```mermaid
graph TB
    subgraph "App Root"
        A[CodeNyxApp]
        B[MyApp]
        C[GoRouter]
    end
    
    subgraph "Auth Module"
        D[AuthScreen]
    end
    
    subgraph "Feed Module"
        E[FeedScreen]
        F[CreatePostScreen]
        G[PostDetailScreen]
    end
    
    subgraph "Chat Module"
        H[ChatScreen]
    end
    
    subgraph "User Module"
        I[UserUpdatesScreen]
        J[TimerScreen]
    end
    
    subgraph "Admin Module"
        K[ManageAnnouncementsScreen]
        L[ManageMentorRequestsScreen]
    end
    
    subgraph "Complaints Module"
        M[UserComplaintsScreen]
        N[AdminComplaintsScreen]
    end
    
    A --> B
    B --> C
    C --> D
    C --> E
    C --> F
    C --> G
    C --> H
    C --> I
    C --> J
    C --> K
    C --> L
    C --> M
    C --> N
```

## State Management Architecture

```mermaid
graph TB
    subgraph "UI Layer"
        A[Widgets]
    end
    
    subgraph "State Layer"
        B[Riverpod Providers]
        C[Local State]
    end
    
    subgraph "Data Layer"
        D[Repositories]
        E[Services]
    end
    
    subgraph "Cache Layer"
        F[PostState]
        G[SessionService]
    end
    
    subgraph "External Layer"
        H[Supabase]
    end
    
    A --> B
    A --> C
    B --> D
    B --> E
    D --> F
    D --> G
    E --> H
    F --> H
    G --> H
```

## Network Architecture

```mermaid
graph TB
    subgraph "Client"
        A[Flutter App]
    end
    
    subgraph "Network"
        B[HTTPS]
        C[WebSocket]
    end
    
    subgraph "Supabase"
        D[Auth Service]
        E[Database Service]
        F[Storage Service]
        G[Realtime Service]
    end
    
    A --> B
    A --> C
    B --> D
    B --> E
    B --> F
    C --> G
```

## Security Architecture

```mermaid
graph TB
    subgraph "Client"
        A[Flutter App]
        B[Environment Variables]
    end
    
    subgraph "Auth"
        C[Google OAuth]
        D[Supabase Auth]
    end
    
    subgraph "Session"
        E[Access Token]
        F[Refresh Token]
        G[Session Storage]
    end
    
    subgraph "API Security"
        H[Anon Key]
        I[Auth Token]
        J[RLS Policies]
    end
    
    subgraph "Database"
        K[PostgreSQL]
    end
    
    A --> B
    A --> C
    C --> D
    D --> E
    D --> F
    E --> G
    A --> H
    A --> I
    I --> J
    J --> K
```

## Deployment Architecture

```mermaid
graph TB
    subgraph "Development"
        A[Local Machine]
        B[Flutter Dev Server]
    end
    
    subgraph "Build"
        C[Android APK]
        D[iOS IPA]
        E[Web Build]
    end
    
    subgraph "Distribution"
        F[Google Play Store]
        G[Apple App Store]
        H[Web Hosting]
    end
    
    subgraph "Backend"
        I[Supabase Cloud]
    end
    
    A --> B
    B --> C
    B --> D
    B --> E
    C --> F
    D --> G
    E --> H
    F --> I
    G --> I
    H --> I
```

## Real-time Architecture

```mermaid
graph TB
    subgraph "Client A"
        A1[ChatScreen]
        A2[StreamProvider]
    end
    
    subgraph "Client B"
        B1[ChatScreen]
        B2[StreamProvider]
    end
    
    subgraph "Supabase Realtime"
        C[WebSocket Server]
        D[Change Detection]
    end
    
    subgraph "Database"
        E[Messages Table]
    end
    
    A1 --> A2
    A2 --> C
    B1 --> B2
    B2 --> C
    C --> D
    D --> E
    E --> D
    D --> C
    C --> A2
    C --> B2
```

## File Upload Architecture

```mermaid
graph TB
    subgraph "Client"
        A[ImagePicker]
        B[Image Compressor]
    end
    
    subgraph "Processing"
        C[Resize]
        D[Compress]
        E[Size Check]
    end
    
    subgraph "Upload"
        F[Supabase Storage]
        G[Bucket: post-images]
    end
    
    subgraph "Database"
        H[Posts Table]
        I[image_url field]
    end
    
    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
    H --> I
```

## Navigation Architecture

```mermaid
graph TB
    subgraph "GoRouter"
        A[Router]
        B[Route Configuration]
        C[Route Guards]
    end
    
    subgraph "Routes"
        D[/ - Auth]
        E[/feed - Feed]
        F[/chat - Chat]
        G[/admin - Admin]
        H[/complaints - Complaints]
    end
    
    subgraph "Screens"
        I[AuthScreen]
        J[FeedScreen]
        K[ChatScreen]
        L[AdminScreens]
        M[ComplaintsScreens]
    end
    
    A --> B
    A --> C
    B --> D
    B --> E
    B --> F
    B --> G
    B --> H
    D --> I
    E --> J
    F --> K
    G --> L
    H --> M
```

## Microservices-like Architecture (Supabase)

```mermaid
graph TB
    subgraph "Supabase Services"
        A[Auth Service]
        B[Database Service]
        C[Storage Service]
        D[Realtime Service]
        E[Edge Functions]
    end
    
    subgraph "Data Stores"
        F[PostgreSQL]
        G[Object Storage]
    end
    
    subgraph "Client"
        H[Flutter App]
    end
    
    H --> A
    H --> B
    H --> C
    H --> D
    H --> E
    A --> F
    B --> F
    C --> G
    D --> F
    E --> F
```

## Caching Architecture

```mermaid
graph TB
    subgraph "UI"
        A[PostCard]
    end
    
    subgraph "Memory Cache"
        B[PostState]
        C[Like Counts]
        D[User Like Status]
    end
    
    subgraph "Database"
        E[Posts Table]
        F[Likes Table]
    end
    
    A --> B
    B --> C
    B --> D
    C --> E
    D --> F
    E --> B
    F --> B
```

## Error Handling Architecture

```mermaid
graph TB
    subgraph "UI Layer"
        A[Error Display]
        B[SnackBar]
        C[Error Screen]
    end
    
    subgraph "Logic Layer"
        D[Try-Catch Blocks]
        E[Error Handlers]
    end
    
    subgraph "Exception Types"
        F[NetworkException]
        G[AuthException]
        H[ValidationException]
        I[StorageException]
    end
    
    subgraph "Logging"
        J[Console Logs]
        K[Error Tracking]
    end
    
    A --> D
    B --> D
    C --> D
    D --> E
    E --> F
    E --> G
    E --> H
    E --> I
    E --> J
    E --> K
```
