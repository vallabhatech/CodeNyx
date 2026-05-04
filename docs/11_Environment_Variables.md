# Environment Variables

## Overview
CodeNyx uses environment variables to store sensitive configuration and secrets. This document explains all environment variables used in the project.

## Required Environment Variables

### SUPABASE_URL
**Purpose**: Supabase project URL
**Type**: String
**Example**: `https://your-project.supabase.co`
**Usage**: Supabase client initialization

```dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

**How to Get**:
1. Go to Supabase dashboard
2. Select your project
3. Navigate to Settings → API
4. Copy the Project URL

### SUPABASE_ANON_KEY
**Purpose**: Supabase anonymous/public key
**Type**: String
**Example**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
**Usage**: Supabase client initialization

**Security Note**: This key is safe to use in client-side code as it has limited permissions enforced by RLS policies.

**How to Get**:
1. Go to Supabase dashboard
2. Select your project
3. Navigate to Settings → API
4. Copy the anon/public key

## Setting Environment Variables

### Flutter (Development)

#### Method 1: Command Line
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

#### Method 2: VS Code Launch Configuration
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

#### Method 3: Android Studio
1. Run → Edit Configurations
2. Add environment variables:
   - `SUPABASE_URL=https://your-project.supabase.co`
   - `SUPABASE_ANON_KEY=your-anon-key`

### Flutter (Production)

#### Android
Create `android/key.properties` (not in version control):

```properties
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Reference in `android/app/build.gradle`:

```gradle
def supabaseUrl = project.findProperty('SUPABASE_URL') ?: System.getenv('SUPABASE_URL')
def supabaseAnonKey = project.findProperty('SUPABASE_ANON_KEY') ?: System.getenv('SUPABASE_ANON_KEY')

android {
    defaultConfig {
        resValue "string", "supabase_url", supabaseUrl
        resValue "string", "supabase_anon_key", supabaseAnonKey
    }
}
```

#### iOS
Create `ios/Runner.xcconfig` (not in version control):

```xcconfig
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Reference in `ios/Runner/Info.plist`:

```xml
<key>SUPABASE_URL</key>
<string>$(SUPABASE_URL)</string>
<key>SUPABASE_ANON_KEY</key>
<string>$(SUPABASE_ANON_KEY)</string>
```

#### Web
Create `.env` file (not in version control):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Use `flutter_dotenv` package to load.

### CI/CD

#### GitHub Actions
```yaml
env:
  SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

Add secrets in GitHub repository settings.

## Environment Variable Validation

### Validation Function

```dart
void validateEnvironmentVariables() {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Missing environment variables. '
      'Please set SUPABASE_URL and SUPABASE_ANON_KEY.'
    );
  }
}
```

### Usage in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Validate environment variables
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Missing environment variables. '
      'Please set SUPABASE_URL and SUPABASE_ANON_KEY.'
    );
  }
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  runApp(const CodeNyxApp());
}
```

## Security Best Practices

1. **Never commit environment variables**: Add to `.gitignore`
2. **Use different keys for environments**: Dev, staging, production
3. **Rotate keys regularly**: Especially if compromised
4. **Limit key permissions**: Use service role key only server-side
5. **Monitor key usage**: Check Supabase dashboard for unusual activity
6. **Use secrets managers**: For production (AWS Secrets Manager, etc.)

## .gitignore Configuration

Ensure `.gitignore` includes:

```
# Environment variables
.env
.env.local
.env.*.local
android/key.properties
ios/Runner.xcconfig
```

## Troubleshooting

### Environment Variables Not Loading

**Problem**: App crashes with missing environment variables
**Solution**:
- Verify variables are set correctly
- Check for typos in variable names
- Ensure `--dart-define` is used correctly
- Check VS Code launch configuration

### Supabase Connection Fails

**Problem**: Cannot connect to Supabase
**Solution**:
- Verify SUPABASE_URL is correct
- Check SUPABASE_ANON_KEY is valid
- Ensure network connectivity
- Check Supabase project is active

### Build Fails in Production

**Problem**: Production build fails
**Solution**:
- Ensure environment variables are set for target platform
- Check platform-specific configuration files
- Verify CI/CD secrets are set

## Additional Configuration (Optional)

### Feature Flags

You can add feature flags as environment variables:

```dart
const enableDebugMode = bool.fromEnvironment('ENABLE_DEBUG_MODE', defaultValue: false);
const enableAnalytics = bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: false);
```

### API Endpoints

If you need to switch between environments:

```dart
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.codenyx.com',
);
```

### Environment Name

```dart
const environment = String.fromEnvironment(
  'ENVIRONMENT',
  defaultValue: 'development',
);
```

## Testing with Environment Variables

### Unit Tests

```dart
test('with environment variables', () async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://test-project.supabase.co',
    anonKey: 'test-anon-key',
  );
  
  // Test code
});
```

### Mock Environment

```dart
class MockEnvironment {
  static const String supabaseUrl = 'https://test.supabase.co';
  static const String supabaseAnonKey = 'test-key';
}
```

## Summary

| Variable | Required | Type | Description |
|----------|----------|------|-------------|
| SUPABASE_URL | Yes | String | Supabase project URL |
| SUPABASE_ANON_KEY | Yes | String | Supabase anonymous key |

All environment variables must be set before running the application. Use the appropriate method for your development environment and deployment target.
