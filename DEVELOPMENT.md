# Development Guide

## Quick Start

### Option 1: Test in Web Browser (Easiest)

1. **Install Flutter** (if not already):
   - Download: https://docs.flutter.dev/get-started/install/windows
   - Extract and add to PATH
   - Run `flutter doctor` to verify

2. **Run in browser**:
   ```bash
   flutter run -d chrome
   ```
   
   Or for hot reload in web:
   ```bash
   flutter run -d web-server --web-port=8080
   ```
   Then open: http://localhost:8080

3. **Make changes**:
   - Edit any `.dart` file in `lib/`
   - Press `r` in terminal for hot reload
   - Press `R` for hot restart
   - Press `q` to quit

### Option 2: Test on Android Emulator

1. **Install Android Studio**
2. **Create emulator**: Tools → Device Manager → Create Device
3. **Start emulator**
4. **Run**:
   ```bash
   flutter run
   ```

### Option 3: Test on Physical Device

**Android:**
1. Enable Developer Options on phone
2. Enable USB Debugging
3. Connect via USB
4. Run: `flutter run`

**iOS (Mac only):**
1. Connect iPhone
2. Trust computer
3. Run: `flutter run`

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── screens/
│   └── home_screen.dart         # Start screen (tap to begin)
├── widgets/
│   └── hold_session.dart        # 60-second session widget
└── core/
    └── tension_detector.dart    # Jitter & velocity detection
```

## Key Files to Edit

- **Visual style**: `lib/widgets/hold_session.dart` (colors, animations)
- **Tension algorithm**: `lib/core/tension_detector.dart`
- **Session duration**: `lib/widgets/hold_session.dart` (line 18: `_remainingSeconds = 60`)
- **App name**: `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`

## Useful Commands

```bash
flutter doctor              # Check setup
flutter devices             # List available devices
flutter run                 # Run on default device
flutter run -d chrome       # Run in Chrome
flutter run -d edge         # Run in Edge
flutter pub get             # Install dependencies
flutter clean               # Clean build cache
flutter build apk           # Build Android APK
flutter build web           # Build for web
```

## Hot Reload Tips

- **Hot Reload (r)**: Updates UI instantly, keeps app state
- **Hot Restart (R)**: Restarts app, loses state
- **Full Restart**: Stop and run again

## Web vs Mobile Differences

- Haptics only work on mobile (automatically disabled on web)
- Web uses mouse/trackpad instead of touch
- Mobile has better performance for animations

## Debugging

- Add `print('debug message')` anywhere
- Check terminal for output
- Use Flutter DevTools: `flutter pub global activate devtools` then `flutter pub global run devtools`

## Next Steps

1. Run `flutter run -d chrome` to test immediately
2. Edit `lib/widgets/hold_session.dart` to change colors/animations
3. Press `r` to see changes instantly
4. Keep coding with Kiro while testing in browser!
