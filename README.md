# CodeNyx

A comprehensive hackathon companion app built with Flutter and Supabase.

---

## Overview

CodeNyx is a feature-rich mobile application designed to enhance the hackathon experience for participants, organizers, and mentors. It provides real-time collaboration tools, social features, and administrative capabilities to streamline hackathon management.

---

## What it does

CodeNyx helps participants:

- **Team-based authentication** with Google OAuth
- **Social feed** with posts, images, likes, and comments
- **Real-time team chat** for instant communication
- **Live announcements** from organizers
- **Hackathon timer** to track event duration
- **Mentor requests** for getting help
- **Complaint system** to report issues
- **Admin panel** for organizers to manage events

No confusion. No chaos. Just everything in one app.

---

## Why it exists

Hackathons usually feel messy — too many groups, missed updates, no coordination.

CodeNyx fixes that by becoming the **single source of truth** for the entire event.

---

## 📱 Key Features

### User Features
- 👥 **Team-based login** with Google OAuth
- 📢 **Live announcements** from organizers
- 🌍 **Social feed** (posts + images + likes + comments)
- � **Real-time team chat** with instant messaging
- ⏱️ **Hackathon timer** for event countdown
- 🧑‍🏫 **Mentor requests** for getting help
- 📝 **Complaint system** to report issues

### Admin Features
- 📢 **Create and manage announcements**
- 🧑‍🏫 **Manage mentor requests** (pending, accepted, resolved)
- 📝 **View and resolve user complaints**
- 📊 **Team overview and monitoring**

---

## Tech Stack

- **Frontend**: Flutter 3.27.5, Dart 3.6.1
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Realtime)
- **State Management**: Riverpod 2.6.1
- **Navigation**: go_router 14.6.2
- **Image Handling**: image_picker, image packages

---

## Platforms

- 📱 **iOS** (12.0+)
- 🤖 **Android** (5.0+)
- 🌐 **Web** (modern browsers)

---

## Documentation

Comprehensive documentation is available in the `docs/` folder:

### Getting Started
- [01_Project_Overview](docs/01_Project_Overview.md) - Project purpose, goals, features, tech stack
- [02_Folder_Structure](docs/02_Folder_Structure.md) - Complete folder structure explanation
- [21_Beginner_Guide](docs/21_Beginner_Guide.md) - Step-by-step beginner guide
- [25_Developer_Onboarding](docs/25_Developer_Onboarding.md) - Setup and contribution guide
- [26_FAQ](docs/26_FAQ.md) - Frequently asked questions

### Architecture & Design
- [04_System_Architecture](docs/04_System_Architecture.md) - Complete architecture explanation
- [05_Request_Flow](docs/05_Request_Flow.md) - User request flows through the system
- [06_Data_Flow](docs/06_Data_Flow.md) - Data movement through the project
- [07_Component_Flow](docs/07_Component_Flow.md) - Component hierarchy and relationships
- [29_Design_Patterns](docs/29_Design_Patterns.md) - Design patterns used

### Code & Files
- [03_File_By_File_Explanation](docs/03_File_By_File_Explanation.md) - Every important file documented
- [22_Code_Walkthrough](docs/22_Code_Walkthrough.md) - Code execution walkthrough
- [27_Project_Map](docs/27_Project_Map.md) - Dependency mapping
- [28_Execution_Order](docs/28_Execution_Order.md) - Startup and initialization order

### API & Database
- [08_API_Documentation](docs/08_API_Documentation.md) - All Supabase API interactions
- [09_Database_Documentation](docs/09_Database_Documentation.md) - Database schema and relationships
- [10_Authentication](docs/10_Authentication.md) - Auth flow and security

### Configuration
- [11_Environment_Variables](docs/11_Environment_Variables.md) - Configuration and secrets
- [12_Dependencies](docs/12_Dependencies.md) - All dependencies explained
- [13_Configuration](docs/13_Configuration.md) - All config files documented

### Development
- [14_Error_Handling](docs/14_Error_Handling.md) - Error handling strategies
- [15_Testing](docs/15_Testing.md) - Testing approach and guidelines
- [16_Build_And_Deployment](docs/16_Build_And_Deployment.md) - Build and deployment process

### Diagrams
- [17_Sequence_Diagrams](docs/17_Sequence_Diagrams.md) - Mermaid sequence diagrams
- [18_Flowcharts](docs/18_Flowcharts.md) - Mermaid flowcharts for processes
- [19_Class_Diagrams](docs/19_Class_Diagrams.md) - Mermaid class diagrams
- [20_Architecture_Diagrams](docs/20_Architecture_Diagrams.md) - Mermaid architecture diagrams

### Reference
- [23_Glossary](docs/23_Glossary.md) - Technical terms glossary
- [24_Project_Insights](docs/24_Project_Insights.md) - Strengths, weaknesses, improvements
- [30_Summary](docs/30_Summary.md) - Complete project summary

---

## Getting Started

### Prerequisites
- Flutter SDK 3.27.5+
- Dart SDK 3.6.1+
- A Supabase account (free tier works)
- VS Code or Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/vallabhatech/CodeNyx.git
   cd CodeNyx
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase**
   - Create a free account at https://supabase.com
   - Create a new project
   - Get your Project URL and anon key from Settings → API
   - Set environment variables:
   ```bash
   flutter run --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-key
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

For detailed setup instructions, see [Beginner Guide](docs/21_Beginner_Guide.md).

---

## Database Setup

Create the following tables in Supabase SQL Editor:

- `profiles` - User profiles and team assignments
- `posts` - Social feed posts
- `comments` - Post comments
- `likes` - Post likes
- `messages` - Chat messages
- `announcements` - Organizer announcements
- `mentor_requests` - Mentorship requests
- `complaints` - User complaints

For complete database schema and SQL scripts, see [Database Documentation](docs/09_Database_Documentation.md).

---

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # Router configuration
├── core/                  # Core utilities
│   ├── theme/            # App theme
│   └── constants/        # Constants
├── features/             # Feature modules
│   ├── social_feed/      # Social feed
│   ├── chat/             # Chat
│   ├── user/             # User features
│   ├── admin/            # Admin features
│   └── complaints/       # Complaints
└── services/             # Shared services
    ├── session_service.dart
    └── supabase_service.dart
```

For detailed structure explanation, see [Folder Structure](docs/02_Folder_Structure.md).

---

## Development

### Running Tests
```bash
flutter test
```

### Building for Release

**Android**:
```bash
flutter build apk --release
```

**iOS**:
```bash
flutter build ios --release
```

**Web**:
```bash
flutter build web --release
```

For detailed build and deployment instructions, see [Build and Deployment](docs/16_Build_And_Deployment.md).

---

## Contributing

Contributions are welcome! Please see [Developer Onboarding](docs/25_Developer_Onboarding.md) for guidelines.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## License

This project is open source. See the LICENSE file for details.

---

## Goal

Make hackathons feel smooth, organized, and actually enjoyable.

---

## Built for

- **Speed** - Fast performance with Flutter
- **Simplicity** - Clean, intuitive interface
- **Real-time interaction** - Instant updates with Supabase Realtime

---

## Support

For questions or issues:
- Check the [FAQ](docs/26_FAQ.md)
- Review the [documentation](docs/)
- Create an issue on GitHub

---

## Acknowledgments

- Flutter team for the amazing framework
- Supabase team for the excellent backend solution
- Riverpod community for the state management solution
- All contributors to the CodeNyx project  