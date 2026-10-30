#!/bin/sh
# Script Studio quiet check (Mac and Linux). Script Studio runs on Creator Studio's own Python
# (it already has the transcription engine and ffmpeg). This finds it, sets it up through the Studio when it is
# missing, then prints the STATUS lines. Never runs a bare python3 (on a Mac that can open an Xcode prompt).
SS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
case "$(uname -s)" in
  Darwin) STUDIO_STATE="$HOME/Library/Application Support/video-studio-codex" ;;
  *) STUDIO_STATE="${XDG_DATA_HOME:-$HOME/.local/share}/video-studio-codex" ;;
esac
case "${VIDEO_STUDIO_STATE:-}" in
  /*/video-studio-codex|/*/video-studio-codex-*) STUDIO_STATE="$VIDEO_STUDIO_STATE" ;;
esac

find_py() {
  PLAT="$STUDIO_STATE/.platform.json"
  [ -f "$PLAT" ] || return 1
  PY="$(sed -n 's/^ *"python": *"\(.*\)",*$/\1/p' "$PLAT" | head -n 1)"
  [ -n "$PY" ] && [ -x "$PY" ]
}

if ! find_py; then
  # Codex can use versioned or "local" caches. Let the agent resolve the registered
  # Creator Studio source instead of guessing a cache directory or choosing a stale version.
  echo 'STATUS studio SETUP_REQUIRED: run the installed Creator Studio for Codex setup check, then retry.'
  exit 0
fi
echo "PY $PY"
exec "$PY" "$SS_DIR/scripts/ss.py" check
