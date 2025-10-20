# GearMate Client

Flutter frontend for GearMate application.

## Setup

1. Make sure you have Flutter installed:
```bash
flutter --version
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Development

### Running on specific platforms:
- **Web**: `flutter run -d chrome`
- **iOS**: `flutter run -d ios`
- **Android**: `flutter run -d android`
- **macOS**: `flutter run -d macos`

### Build for production:
```bash
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
flutter build macos      # macOS
```

## Connecting to API

Update the API endpoint URL in your configuration to point to the FastAPI backend:
- Development: `http://localhost:8000`
- Production: Update with your deployed API URL

## Project Structure

```
client/
├── lib/                # Dart source files
├── android/            # Android-specific files
├── ios/                # iOS-specific files
├── web/                # Web-specific files
├── macos/              # macOS-specific files
├── linux/              # Linux-specific files
├── windows/            # Windows-specific files
├── test/               # Test files
└── pubspec.yaml        # Dependencies and configuration
```
