# FAQ

## General Questions

### What is CodeNyx?
CodeNyx is a hackathon companion app built with Flutter and Supabase. It provides features like social feed, team chat, admin panel, and complaints management for hackathon participants and organizers.

### What technologies are used?
- **Frontend**: Flutter 3.27.5, Dart 3.6.1
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Realtime)
- **State Management**: Riverpod 2.6.1
- **Navigation**: go_router 14.6.2

### Is CodeNyx open source?
Yes, CodeNyx is open source. Check the repository for license information.

### How can I contribute?
See the Developer Onboarding guide (`docs/25_Developer_Onboarding.md`) for detailed contribution guidelines.

## Setup and Installation

### How do I install Flutter?
Download Flutter from https://flutter.dev/docs/get-started/install and follow the platform-specific instructions.

### How do I set up Supabase?
1. Create a free account at https://supabase.com
2. Create a new project
3. Get your Project URL and anon key from Settings → API
4. Set them as environment variables

### What are the environment variables?
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key

### How do I set environment variables?
For development, use:
```bash
flutter run --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-key
```

Or configure in `.vscode/launch.json`.

### How do I run the app?
```bash
flutter run
```

### How do I build for release?
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Development

### How do I add a new feature?
1. Create a feature branch
2. Add your code
3. Test thoroughly
4. Submit a pull request

### How do I add a new screen?
1. Create screen file in appropriate feature folder
2. Add route in `app.dart`
3. Navigate to screen using go_router

### How do I add a new dependency?
Add to `pubspec.yaml` and run `flutter pub get`.

### How do I debug?
Use VS Code debugger or Flutter DevTools. Set breakpoints and step through code.

### How do I format code?
Run `dart format .` to format all Dart files.

### How do I check for issues?
Run `flutter analyze` to check for code issues.

## Features

### How does authentication work?
CodeNyx uses Google OAuth via Supabase Auth. Users sign in with their Google account, and their profile is created/updated in the database.

### How does the social feed work?
Users can create posts with text and optional images. Posts are displayed in a feed, and users can like and comment on posts.

### How does real-time chat work?
Chat uses Supabase Realtime subscriptions. When a user sends a message, it's inserted into the database, and all team members receive the message instantly via WebSocket.

### How do image uploads work?
Images are picked from the gallery, compressed to 800x800 pixels and 85% quality (max 500KB), uploaded to Supabase Storage, and the public URL is stored in the database.

### How does the admin panel work?
Admin screens allow administrators to create announcements, manage mentor requests, and resolve complaints. These features are protected by admin role checks.

### How do complaints work?
Users can submit complaints about issues affecting their team. Admins can view all complaints and mark them as resolved.

## Troubleshooting

### Flutter command not found
Add Flutter to your PATH and restart your terminal.

### Dependencies not resolving
Run `flutter clean` then `flutter pub get`.

### Build fails
1. Check Flutter version: `flutter --version`
2. Clean build: `flutter clean`
3. Update dependencies: `flutter pub upgrade`

### Supabase connection fails
1. Check environment variables are set
2. Verify Supabase credentials
3. Check network connection
4. Ensure Supabase project is active

### App crashes on launch
1. Check environment variables
2. Verify Supabase configuration
3. Check console logs for errors

### Hot reload not working
1. Try hot restart instead
2. Check for syntax errors
3. Restart the app

### Images not uploading
1. Check Supabase Storage bucket exists
2. Verify storage permissions
3. Check image size (<500KB)

### Real-time not working
1. Check Supabase Realtime is enabled
2. Verify subscription is active
3. Check network connection

## Architecture

### Why Supabase?
Supabase provides an all-in-one backend solution with auth, database, storage, and realtime. It's open-source, has a generous free tier, and is easy to set up.

### Why Riverpod?
Riverpod provides type-safe state management, doesn't require BuildContext, has excellent performance, and is easy to test.

### Why go_router?
go_router provides declarative routing, deep linking support, type-safe navigation, and better API than Navigator 2.0.

### Why feature-based structure?
Feature-based structure makes it easy to add, remove, and maintain features. Each feature is self-contained with its own screens, repositories, and providers.

## Database

### What database does CodeNyx use?
CodeNyx uses PostgreSQL via Supabase.

### How do I set up the database?
Run the SQL scripts provided in the Database Documentation (`docs/09_Database_Documentation.md`) in the Supabase SQL editor.

### What are the main tables?
- `profiles`: User profiles and team assignments
- `posts`: Social feed posts
- `comments`: Post comments
- `likes`: Post likes
- `messages`: Chat messages
- `announcements`: Organizer announcements
- `mentor_requests`: Mentorship requests
- `complaints`: User complaints

### How does Row Level Security work?
RLS policies restrict database access based on user identity. Users can only access their team's data.

### How do I add a new table?
Create the table in Supabase SQL editor and add RLS policies.

## Testing

### Does CodeNyx have tests?
Currently, CodeNyx doesn't have comprehensive test coverage. This is an area for improvement.

### How do I run tests?
```bash
flutter test
```

### How do I add tests?
See the Testing documentation (`docs/15_Testing.md`) for guidelines on writing tests.

## Deployment

### How do I deploy to Google Play Store?
1. Build signed APK or App Bundle
2. Upload to Google Play Console
3. Complete store listing
4. Submit for review

### How do I deploy to Apple App Store?
1. Build release version
2. Archive in Xcode
3. Upload to App Store Connect
4. Complete store listing
5. Submit for review

### How do I deploy to web?
Build with `flutter build web --release` and deploy to any web hosting service (Vercel, Netlify, Firebase Hosting).

### How do I set up CI/CD?
See the Build and Deployment documentation (`docs/16_Build_And_Deployment.md`) for CI/CD examples.

## Security

### Is my data secure?
Yes, CodeNyx uses:
- Row Level Security (RLS) on all tables
- Team-based access control
- Secure OAuth authentication
- HTTPS for all API calls
- Environment variables for sensitive data

### How are passwords handled?
CodeNyx uses Google OAuth, so passwords are handled by Google. No passwords are stored in the CodeNyx database.

### How do I secure my API keys?
Never commit API keys to version control. Use environment variables or secure storage.

## Performance

### How can I improve performance?
- Implement pagination for large lists
- Add image caching
- Use lazy loading
- Optimize database queries
- Use code splitting for web

### Why is the app slow?
Possible reasons:
- Large images not compressed
- No pagination for long lists
- Slow network connection
- Database queries not optimized

### How do I profile performance?
Use Flutter DevTools to profile CPU, memory, and performance.

## Customization

### How do I change the app name?
Update the `name` field in `pubspec.yaml` and platform-specific configuration files.

### How do I change the theme?
Modify colors and styles in `lib/core/theme/app_theme.dart`.

### How do I add a new language?
Implement internationalization using `flutter_localizations` and `intl` packages.

### How do I change the logo?
Replace the app icon in platform-specific folders (android/app/src/main/res/, ios/Runner/Assets.xcassets/).

## Support

### Where can I get help?
- Check the documentation in the `docs/` folder
- Search Stack Overflow
- Ask in the Flutter community
- Create an issue on GitHub

### How do I report a bug?
Create an issue on GitHub with:
- Description of the bug
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details

### How do I request a feature?
Create an issue on GitHub with the "enhancement" label and describe the feature you'd like.

## Miscellaneous

### What is the license?
Check the LICENSE file in the repository.

### Can I use CodeNyx for my own project?
Yes, CodeNyx is open source. Check the license for specific terms.

### How do I cite CodeNyx?
If you use CodeNyx in your project, please cite it appropriately.

### Is there a demo available?
Check the repository for demo links or build the app yourself.

### Can I contribute to CodeNyx?
Yes! Contributions are welcome. See the Developer Onboarding guide.

### How often is CodeNyx updated?
Check the repository for the latest commits and releases.

### What's the roadmap?
Future improvements include:
- Comprehensive test coverage
- Push notifications
- Search functionality
- Internationalization
- Offline support
- Performance optimizations

## Still Have Questions?

If your question isn't answered here:
1. Check the documentation in the `docs/` folder
2. Search existing GitHub issues
3. Create a new issue on GitHub
4. Contact the maintainers
