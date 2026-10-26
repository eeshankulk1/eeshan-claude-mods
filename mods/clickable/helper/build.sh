#!/bin/sh
# Builds "Clickable Copy.app", the macOS helper behind the clickable mod's copy
# links, and registers its clickable-copy:// scheme. In Claude Code's classic
# view a click reaches the terminal, never Claude Code, and a terminal can only
# open a link; so the mod links each code block as clickable-copy://<id>, and
# macOS opens this app for that scheme, which copies the text the mod saved
# under the id (copy.sh does the work).
#
# The mod runs this at session start when the app is missing or older than the
# mod. Prints "built" when it built the app; nothing when another session's
# build is under way.
#   sh build.sh <app path> <stamp>
set -eu

app=$1
stamp=$2
src=$(cd "$(dirname "$0")" && pwd)
parent=$(dirname "$app")
mkdir -p "$parent"

# One build at a time: a session starting meanwhile leaves it to the first.
# A lock older than five minutes is a build that died.
lock=$parent/.build-lock
if ! mkdir "$lock" 2>/dev/null; then
  [ -n "$(find "$lock" -maxdepth 0 -mmin +5)" ] || exit 0
  rm -rf "$lock"
  mkdir "$lock"
fi
staging=$(mktemp -d "$parent/.build-XXXXXX")
trap 'rm -rf "$staging" "$lock"' EXIT

fresh=$staging/Clickable\ Copy.app
osacompile -o "$fresh" "$src/handler.applescript"
cp "$src/copy.sh" "$fresh/Contents/Resources/copy.sh"
chmod 755 "$fresh/Contents/Resources/copy.sh"
printf '%s\n' "$stamp" > "$fresh/Contents/Resources/stamp"
plist=$fresh/Contents/Info.plist
plutil -replace CFBundleIdentifier -string com.github.eeshankulk1.clickable-copy "$plist"
plutil -replace CFBundleName -string "Clickable Copy" "$plist"
plutil -replace LSUIElement -bool YES "$plist"
plutil -replace CFBundleURLTypes -json '[{"CFBundleURLName":"clickable copy link","CFBundleURLSchemes":["clickable-copy"]}]' "$plist"
# Editing Info.plist voids osacompile's signature; Apple silicon will not launch an app without one.
codesign --force --deep --sign - "$fresh"

# Keep the old app until the new one is in place: a failed move puts it back.
if [ -e "$app" ]; then mv "$app" "$staging/previous.app"; fi
if ! mv "$fresh" "$app"; then
  [ -e "$staging/previous.app" ] && mv "$staging/previous.app" "$app"
  exit 1
fi
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app"
echo built
