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
  theme/
    app_theme.dart       # AppColors, AppTheme (purple/coral palette, 7 note colors)
  widgets/
    note_widgets.dart    # Shared: NoteChip, NoteKey, ActionBtn, SysTab
  screens/
    home_screen.dart            # Gradient home with piano logo, note decorations
    mode_selection_screen.dart  # Mode cards (manual / validation)
    manual_mode_screen.dart     # Note keyboard + system selector + animated chips
    validation_mode_screen.dart # Mic simulation + note picker + system selector
    melodies_list_screen.dart   # Card list with color per melody
    melody_detail_screen.dart   # Full detail with note sequence display
web/                     # Web-specific assets
build/web/               # Built web output (served by Node.js)
```

## Design System
- **Primary**: #7C4DFF (purple) / **Secondary**: #FF6B6B (coral)
- **Note colors**: 7 distinct colors mapped to Do/C through Si/B
- **System selector**: Do-Ré-Mi ↔ A-B-C toggle on all note entry screens
- **Animations**: scale press, elastic chip appearance, pulse mic
- **Cards**: white with shadow, gradient headers, rounded 20-24px

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
