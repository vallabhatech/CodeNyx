# Beginner Guide

## Overview
This guide is designed for beginners who want to understand and work with the CodeNyx project. It covers the basics of Flutter, the project structure, and how to get started.

## Prerequisites

### Required Knowledge
- Basic programming knowledge
- Understanding of object-oriented programming
- Familiarity with JSON and APIs

### Required Tools
- Flutter SDK (3.27.5+)
- Dart SDK (3.6.1+)
- VS Code or Android Studio
- Git
- A Supabase account (free tier works)

## Step 1: Install Flutter

### Download Flutter
1. Visit https://flutter.dev/docs/get-started/install
2. Download Flutter SDK for your operating system
3. Extract the zip file to a location

### Set Up Environment Variables
**Windows**:
```powershell
# Add Flutter to PATH
$env:Path += ";C:\path\to\flutter\bin"
```

**macOS/Linux**:
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Verify Installation
```bash
flutter doctor
```

Fix any issues reported by `flutter doctor`.

## Step 2: Set Up Development Environment

### Install VS Code
1. Download VS Code from https://code.visualstudio.com/
2. Install Flutter extension
3. Install Dart extension

### Install Android Studio (for Android development)
1. Download Android Studio from https://developer.android.com/studio
2. Install Android SDK
3. Set up an Android emulator or connect a physical device

### Install Xcode (for iOS development, macOS only)
1. Install Xcode from Mac App Store
2. Install Xcode command-line tools
```bash
xcode-select --install
```

## Step 3: Clone the Repository

```bash
git clone <repository-url>
cd CodeNyx
```

## Step 4: Install Dependencies

```bash
flutter pub get
```

This downloads all the packages listed in `pubspec.yaml`.

## Step 5: Set Up Supabase

### Create a Supabase Project
1. Go to https://supabase.com
2. Sign up for a free account
3. Create a new project
4. Wait for the project to be ready (2-3 minutes)

### Get Supabase Credentials
1. Go to your project dashboard
2. Navigate to Settings → API
3. Copy the Project URL
4. Copy the anon/public key

### Set Environment Variables
**For development**:
```bash
flutter run --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-key
```

**For VS Code**:
Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "CodeNyx",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://your-project.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your-anon-key"
      ]
    }
  ]
}
```

## Step 6: Set Up Database Tables

### Create Tables in Supabase SQL Editor

```sql
-- Profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  user_name TEXT NOT NULL,
  team_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Posts table
CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  team_id TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  like_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Comments table
CREATE TABLE comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID NOT NULL REFERENCES posts(id),
  user_id TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Likes table
CREATE TABLE likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID NOT NULL REFERENCES posts(id),
  user_id TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Messages table
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  team_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Announcements table
CREATE TABLE announcements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mentor requests table
CREATE TABLE mentor_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  team_id TEXT NOT NULL,
  request TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Complaints table
CREATE TABLE complaints (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_email TEXT NOT NULL,
  team_id TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Enable Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE mentor_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies (customize as needed)
CREATE POLICY "Public read for announcements"
ON announcements FOR SELECT
USING (true);

CREATE POLICY "Public read for profiles"
ON profiles FOR SELECT
USING (true);
```

## Step 7: Run the App

### Run on Emulator/Device
```bash
flutter run
```

### Run on Web
```bash
flutter run -d chrome
```

### Run on Specific Device
```bash
flutter devices
flutter run -d <device-id>
```

## Step 8: Understanding the Project Structure

### Folder Structure
```
lib/
├── main.dart              # App entry point
├── app.dart               # Router configuration
├── core/                  # Core utilities
│   ├── theme/            # App theme
│   └── constants/        # Constants
├── features/             # Features
│   ├── social_feed/      # Social feed
│   ├── chat/             # Chat
│   ├── user/             # User features
│   ├── admin/            # Admin features
│   └── complaints/       # Complaints
└── services/             # Shared services
```

### Key Files to Know
- `main.dart`: Where the app starts
- `app.dart`: Navigation routes
- `pubspec.yaml`: Dependencies
- `analysis_options.yaml`: Linting rules

## Step 9: Making Your First Change

### Change the App Name
1. Open `pubspec.yaml`
2. Change the `name` field
3. Run `flutter pub get`

### Change the Theme Color
1. Open `lib/core/theme/app_theme.dart`
2. Find `accentPrimary` color
3. Change the color value
4. Hot reload the app (press `r` in terminal)

### Add a New Screen
1. Create a new file in `lib/features/`
2. Create a StatefulWidget
3. Add route in `app.dart`
4. Navigate to the new screen

## Step 10: Common Tasks

### Add a New Dependency
1. Find the package on pub.dev
2. Add to `pubspec.yaml`
3. Run `flutter pub get`
4. Import and use

### Debug an Issue
1. Use `print()` statements
2. Use Flutter DevTools
3. Check console logs
4. Use breakpoints in VS Code

### Build for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Learning Resources

### Flutter Documentation
- https://flutter.dev/docs
- https://api.flutter.dev

### Dart Documentation
- https://dart.dev/guides
- https://api.dart.dev

### Supabase Documentation
- https://supabase.com/docs
- https://supabase.com/docs/reference/dart

### Riverpod Documentation
- https://riverpod.dev
- https://pub.dev/packages/flutter_riverpod

## Common Issues and Solutions

### "Flutter command not found"
**Solution**: Add Flutter to your PATH

### "No devices found"
**Solution**: Start an emulator or connect a physical device

### "Supabase connection failed"
**Solution**: Check your environment variables and Supabase credentials

### "Build failed"
**Solution**: Run `flutter clean` then `flutter pub get`

## Next Steps

1. Read the project documentation in the `docs/` folder
2. Explore the codebase
3. Try making small changes
4. Read about Flutter widgets
5. Learn about state management with Riverpod
6. Understand Supabase integration

## Getting Help

- Check the documentation in `docs/`
- Search Flutter documentation
- Ask questions in Flutter communities
- Review Supabase documentation

## Tips for Beginners

1. **Start Small**: Make small changes first
2. **Read Code**: Read existing code to understand patterns
3. **Use Hot Reload**: Use hot reload for faster development
4. **Test Often**: Test your changes frequently
5. **Ask Questions**: Don't hesitate to ask for help
6. **Learn by Doing**: The best way to learn is by doing

## Glossary

- **Widget**: UI building block in Flutter
- **State**: Data that can change over time
- **Provider**: Riverpod state management
- **Repository**: Data access layer
- **Supabase**: Backend-as-a-service
- **Hot Reload**: Update code without restarting app
- **Pubspec.yaml**: Flutter project configuration file
- **Dart**: Programming language used by Flutter

Congratulations! You've set up the CodeNyx project and are ready to start developing.
