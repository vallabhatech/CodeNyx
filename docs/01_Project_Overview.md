# Project Overview

## Project Name
CodeNyx - Hackathon Companion App

## Purpose
CodeNyx is a comprehensive mobile application designed to enhance the hackathon experience for participants, organizers, and mentors. It provides real-time collaboration tools, social features, and administrative capabilities to streamline hackathon management.

## Project Goals
- Enable seamless team communication during hackathons
- Provide a platform for participants to share progress and updates
- Facilitate mentor-mentee interactions
- Allow organizers to manage announcements and resolve issues
- Track hackathon timelines with integrated timers
- Support cross-platform deployment (iOS, Android, Web)

## Key Features

### User Features
- **Google OAuth Authentication**: Secure login with team-based access control
- **Social Feed**: Create, view, like, comment on, and delete posts with image support
- **Real-time Chat**: Team-based messaging with real-time updates
- **Hackathon Timer**: Countdown timer for hackathon duration
- **Complaint System**: Submit complaints to organizers
- **User Updates**: View announcements from organizers

### Admin Features
- **Announcement Management**: Create and broadcast announcements to all participants
- **Mentor Request Management**: View and manage mentorship requests (pending, accepted, resolved)
- **Complaint Management**: View and resolve user complaints
- **Team Overview**: Monitor team activities and engagement

## Technology Stack

### Frontend
- **Framework**: Flutter 3.27.5
- **Language**: Dart 3.6.1
- **State Management**: Riverpod 2.6.1
- **Navigation**: go_router 14.6.2
- **UI Components**: Material Design 3

### Backend
- **Backend-as-a-Service**: Supabase
  - Authentication (OAuth, Email)
  - PostgreSQL Database
  - Real-time Subscriptions
  - Storage (Image uploads)
  - Edge Functions (if needed)

### Development Tools
- **IDE Support**: VS Code, Android Studio
- **Code Analysis**: flutter_lints
- **Version Control**: Git

## Platform Support
- **iOS**: iOS 12.0+
- **Android**: Android 5.0+ (API 21+)
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)

## Project Structure
The project follows a feature-based architecture with clear separation of concerns:
- `lib/core/`: Core utilities (theme, constants, services)
- `lib/features/`: Feature modules (social_feed, chat, admin, complaints, etc.)
- `lib/main.dart`: Application entry point
- `lib/app.dart`: Root widget with routing configuration

## Database Schema
Key tables in Supabase:
- `profiles`: User profiles and team assignments
- `posts`: Social feed posts
- `comments`: Post comments
- `likes`: Post likes
- `messages`: Chat messages
- `announcements`: Organizer announcements
- `mentor_requests`: Mentorship requests
- `complaints`: User complaints

## Security Features
- OAuth-based authentication
- Team-based access control
- Row-level security (RLS) policies in Supabase
- Secure image upload to Supabase Storage
- Session management

## Performance Optimizations
- Image compression before upload
- Efficient pagination for feeds
- Real-time subscriptions for instant updates
- Cached state management with Riverpod
- Lazy loading for large lists

## Development Status
The application is production-ready with the following features fully implemented:
- ✅ Authentication and team management
- ✅ Social feed with images
- ✅ Real-time team chat
- ✅ Admin panel for announcements
- ✅ Mentor request management
- ✅ Complaint system
- ✅ Hackathon timer
- ⏳ Additional features can be added as needed

## Future Enhancements
Potential areas for expansion:
- Push notifications for real-time alerts
- File sharing in chat
- Video call integration
- Analytics dashboard for organizers
- Multi-language support
- Offline mode support
- Advanced filtering and search
