#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPLICATIONS_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$APPLICATIONS_DIR/voice-to-jetbrains.desktop"
DESKTOP_ID="voice-to-jetbrains.desktop"

mkdir -p "$APPLICATIONS_DIR"

sed "s|{{PROJECT_DIR}}|$PROJECT_DIR|g" \
  "$PROJECT_DIR/voice-to-jetbrains.desktop.template" \
  > "$DESKTOP_FILE"

chmod +x "$DESKTOP_FILE"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APPLICATIONS_DIR" >/dev/null 2>&1 || true
fi

if command -v gsettings >/dev/null 2>&1; then
  DESKTOP_ID="$DESKTOP_ID" python3 - <<'PY' || true
import ast
import os
import subprocess

desktop_id = os.environ["DESKTOP_ID"]
current = subprocess.check_output(
    ["gsettings", "get", "org.gnome.shell", "favorite-apps"],
    text=True,
).strip()
favorites = ast.literal_eval(current)

if desktop_id not in favorites:
    favorites.append(desktop_id)
    subprocess.run(
        ["gsettings", "set", "org.gnome.shell", "favorite-apps", repr(favorites)],
        check=True,
    )
PY
fi

echo "Installed: $DESKTOP_FILE"
echo "Added to Ubuntu Favorites: $DESKTOP_ID"
echo "Open the app launcher, search for 'VoiceJet', then pin it to the dock."
