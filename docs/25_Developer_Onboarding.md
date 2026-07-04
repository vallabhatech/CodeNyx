# Developer Onboarding

## Overview
This guide helps new developers get started with contributing to the CodeNyx project.

## Prerequisites

### Required Skills
- **Flutter**: Basic understanding of Flutter widgets and state management
- **Dart**: Familiarity with Dart language features
- **Git**: Basic Git operations (clone, commit, push, pull)
- **REST APIs**: Understanding of HTTP requests and JSON
- **SQL**: Basic SQL knowledge for database operations

### Required Tools
- Flutter SDK 3.27.5+
- Dart SDK 3.6.1+
- VS Code or Android Studio
- Git
- A Supabase account (for local development)

## Step 1: Set Up Development Environment

### Install Flutter
```bash
# Download Flutter from https://flutter.dev/docs/get-started/install
# Extract and add to PATH

# Verify installation
flutter doctor
```

### Install VS Code Extensions
- Flutter
- Dart
- GitLens (optional but recommended)

### Install Android Studio (for Android development)
- Download from https://developer.android.com/studio
- Install Android SDK
- Set up emulator or connect physical device

## Step 2: Clone the Repository

```bash
git clone <repository-url>
cd CodeNyx
```

## Step 3: Install Dependencies

```bash
flutter pub get
```

## Step 4: Set Up Supabase

### Create a Local Supabase Project (Optional)
For local development, you can use the shared Supabase project or create your own.

### Get Credentials
1. Go to Supabase dashboard
2. Navigate to Settings → API
3. Copy Project URL and anon key

### Set Environment Variables
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
        "--dart-define=SUPABASE_URL=your-url",
        "--dart-define=SUPABASE_ANON_KEY=your-key"
      ]
    }
  ]
}
```

## Step 5: Run the App

```bash
flutter run
```

## Step 6: Understand the Project Structure

### Directory Overview
```
lib/
├── main.dart              # Entry point
├── app.dart               # Router configuration
├── core/                  # Core utilities
│   ├── theme/            # App theme
│   └── constants/        # Constants
├── features/             # Feature modules
│   ├── social_feed/      # Social feed feature
│   ├── chat/             # Chat feature
│   ├── user/             # User features
│   ├── admin/            # Admin features
│   └── complaints/       # Complaints feature
└── services/             # Shared services
    ├── session_service.dart
    └── supabase_service.dart
```

### Key Files to Read First
1. `main.dart` - How the app starts
2. `app.dart` - Navigation setup
3. `pubspec.yaml` - Dependencies
4. `lib/core/theme/app_theme.dart` - Theme configuration

## Step 7: Development Workflow

### Branch Strategy
- `main` - Production code
- `develop` - Integration branch
- `feature/*` - Feature branches
- `bugfix/*` - Bug fix branches

### Creating a Feature Branch
```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### Making Changes
1. Make your changes
2. Test thoroughly
3. Run `flutter analyze` to check for issues
4. Format code with `dart format .`

### Committing Changes
```bash
git add .
git commit -m "feat: add your feature description"
```

### Commit Message Convention
```
feat: add new feature
fix: fix bug
docs: update documentation
style: code style changes
refactor: code refactoring
test: add tests
chore: maintenance tasks
```

### Pushing Changes
```bash
git push origin feature/your-feature-name
```

### Creating a Pull Request
1. Go to GitHub/GitLab
2. Create pull request from your branch to `develop`
3. Describe your changes
4. Request review from team members

## Step 8: Coding Standards

### Dart Style
- Follow `dart format` style
- Use `camelCase` for variables and functions
- Use `PascalCase` for classes
- Use `snake_case` for files
- Use `UPPER_SNAKE_CASE` for constants

### Flutter Best Practices
- Use `const` constructors where possible
- Prefer `StatelessWidget` over `StatefulWidget` when possible
- Use `Builder` to get `BuildContext` in callbacks
- Dispose controllers and streams in `dispose()`

### Riverpod Best Practices
- Use `Provider` for immutable values
- Use `StateNotifierProvider` for mutable state
- Use `StreamProvider` for streams
- Use `ref.read` for one-time reads
- Use `ref.watch` for reactive reads

### Documentation
- Add doc comments for public APIs
- Comment complex logic
- Update README for user-facing changes

## Step 9: Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/feed_repository_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests
```dart
test('should return posts', () async {
  // Arrange
  final repository = FeedRepository();
  
  // Act
  final posts = await repository.getPosts();
  
  // Assert
  expect(posts, isNotEmpty);
});
```

## Step 10: Debugging

### Using VS Code Debugger
1. Set breakpoints by clicking on line numbers
2. Press F5 to start debugging
3. Use debug controls to step through code
4. View variables in debug panel

### Using Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Console Logging
```dart
debugPrint('Debug message');
print('Console message');
```

## Step 11: Common Tasks

### Adding a New Screen
1. Create screen file in appropriate feature folder
2. Create StatefulWidget or StatelessWidget
3. Add route in `app.dart`
4. Navigate to screen

### Adding a New Repository
1. Create repository file in feature folder
2. Implement data access methods
3. Create provider for repository
4. Use provider in screen

### Adding a New Provider
```dart
final myProvider = Provider<MyType>((ref) {
  return MyType();
});
```

### Adding a New Dependency
1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. Import and use

## Step 12: Code Review Process

### Before Submitting PR
- [ ] Code follows style guidelines
- [ ] Code is formatted (`dart format`)
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Tests pass (`flutter test`)
- [ ] Documentation updated
- [ ] Commit messages follow convention

### During Review
- Address reviewer comments
- Make requested changes
- Update PR with changes
- Respond to comments

### After Approval
- Squash your commits if needed
- Merge to `develop`
- Delete feature branch

## Step 13: Deployment

### Building for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Deploying to Stores
- Follow platform-specific deployment guides
- See `docs/16_Build_And_Deployment.md`

## Step 14: Resources

### Documentation
- Project docs: `docs/` folder
- Flutter docs: https://flutter.dev/docs
- Dart docs: https://dart.dev/guides
- Supabase docs: https://supabase.com/docs
- Riverpod docs: https://riverpod.dev

### Community
- Flutter community: https://flutter.dev/community
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- Discord: Flutter Discord server

## Step 15: Getting Help

### Internal Resources
- Ask in team chat
- Create issue on GitHub
- Check existing documentation

### External Resources
- Search Stack Overflow
- Ask in Flutter communities
- Read package documentation

## Troubleshooting

### Common Issues

**Flutter command not found**
- Add Flutter to PATH
- Restart terminal

**Dependencies not resolving**
- Run `flutter clean`
- Run `flutter pub get`

**Build fails**
- Check Flutter version
- Clean build: `flutter clean`
- Update dependencies: `flutter pub upgrade`

**Supabase connection fails**
- Check environment variables
- Verify Supabase credentials
- Check network connection

## Checklist for New Contributors

- [ ] Development environment set up
- [ ] Repository cloned
- [ ] Dependencies installed
- [ ] App runs locally
- [ ] Project structure understood
- [ ] Coding standards reviewed
- [ ] Git workflow understood
- [ ] First contribution made
- [ ] Code review process understood

## Next Steps

1. Start with a small bug fix
2. Read existing code to understand patterns
3. Ask questions in team chat
4. Contribute to documentation
5. Work on a feature

## Contact

For questions or support:
- Team chat: [team-chat-link]
- GitHub issues: [repository-url]/issues
- Email: [maintainer-email]

Welcome to the CodeNyx team! We're excited to have you contribute.
