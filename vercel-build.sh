#!/bin/bash
set -e

echo "=== 1. Checking Flutter SDK ==="
if [ ! -d "$HOME/flutter" ]; then
  echo "Flutter not found. Cloning Flutter SDK (channel stable)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
else
  echo "Flutter found in cache."
fi

# Add flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

echo "=== 2. Flutter Environment ==="
flutter --version
flutter config --no-analytics

echo "=== 3. Pre-caching Web Artifacts ==="
flutter precache --web

echo "=== 4. Fetching Dependencies ==="
flutter pub get

echo "=== 5. Building Flutter Web (Release) ==="
flutter build web --release

echo "=== Build Complete! Output is in build/web ==="
