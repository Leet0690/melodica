#!/bin/bash
set -e

export PATH="$HOME/flutter-sdk/bin:$PATH"
export FLUTTER_ROOT="$HOME/flutter-sdk"

echo "Building Flutter web app..."
flutter build web --release

echo "Starting web server on port 5000..."
node serve.js
