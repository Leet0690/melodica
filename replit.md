# Melodica - Flutter Web App

## Overview
Melodica is a Flutter web application for creating and managing melodies. It uses Hive for local storage and Provider for state management.

## Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Storage**: Hive / Hive Flutter
- **Target Platform**: Web (served via Node.js static file server)

## Project Structure
```
lib/
  main.dart              # App entry point, Hive init, Provider setup
  models/
    melody.dart          # Melody domain model
    melody.g.dart        # Hive adapter (generated)
  services/
    hive_service.dart    # Hive persistence service
    melody_provider.dart # ChangeNotifier state management
  screens/
    home_screen.dart
    mode_selection_screen.dart
    manual_mode_screen.dart
    validation_mode_screen.dart
    melodies_list_screen.dart
    melody_detail_screen.dart
web/                     # Web-specific assets
build/web/               # Built web output (served by Node.js)
```

## Flutter SDK Setup
The Flutter SDK is not a module in Replit's environment. It is set up manually:
- Flutter 3.32.0 is copied to `~/flutter-sdk/` from the nix store
- The `bin/cache/pkg/sky_engine` directory is added from the nix store
- The `bin/cache/flutter_web_sdk/` is copied from matching web artifacts
- The `bin/cache/artifacts/material_fonts/` is copied from universal artifacts

The SDK version was adjusted: `pubspec.yaml` SDK constraint changed from `^3.11.4` to `>=3.5.0 <4.0.0` to be compatible with Dart 3.8.0.

## Running Locally
The workflow runs `bash start.sh` which:
1. Builds the Flutter web app: `flutter build web --release`
2. Serves it via Node.js on port 5000 (`node serve.js`)

## Deployment
- **Target**: Autoscale
- **Build**: `bash start.sh` (builds Flutter web app)
- **Run**: `node serve.js` (serves static files on port 5000)

## Key Files
- `start.sh` - Build and serve script
- `serve.js` - Node.js static file server (port 5000, host 0.0.0.0)
- `pubspec.yaml` - Flutter dependencies
- `build/web/` - Built web output directory
