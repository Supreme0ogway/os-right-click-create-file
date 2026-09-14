#!/usr/bin/env zsh
# Draws the app icon and builds the icon file the app carries.
# Run again after changing scripts/make-icon.swift.

cd "$(dirname "$0")/.."

ICONSET=".dist/AppIcon.iconset"
DESTINATION="bundles/app/Resources/AppIcon.icns"

rm -rf "$ICONSET"
mkdir -p "$(dirname "$DESTINATION")"

swift scripts/make-icon.swift "$ICONSET"
iconutil --convert icns --output "$DESTINATION" "$ICONSET"

echo "wrote $DESTINATION"
