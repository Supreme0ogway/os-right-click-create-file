#!/usr/bin/env zsh
# Installs the two tools the build needs. Safe to run again.

command -v brew >/dev/null || { echo "Homebrew is required: https://brew.sh"; exit 1; }

for tool in xcodegen swiftlint; do
  if command -v "$tool" >/dev/null; then
    echo "ok    $tool $("$tool" --version 2>&1 | head -1)"
  else
    echo "install $tool"
    brew install "$tool"
  fi
done

echo
echo "Signing identity:"
security find-identity -v -p codesigning | grep "Apple Development" || {
  echo "  none found. Open Xcode > Settings > Accounts and add your Apple ID."
  exit 1
}
