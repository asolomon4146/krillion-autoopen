#!/usr/bin/env bash
# Opens krillion.io in the default browser when an AI coding agent starts working.
# Safe to call on every prompt: a cooldown stops it from piling up tabs.
#
# Env vars:
#   KRILLION_URL       URL to open            (default: https://krillion.io)
#   KRILLION_COOLDOWN  seconds between opens  (default: 600, 0 = every time)
#   KRILLION_DISABLED  set to 1 to turn off
#
# Flags:
#   --cursor   print the JSON Cursor's beforeSubmitPrompt hook expects

URL="${KRILLION_URL:-https://krillion.io}"
COOLDOWN="${KRILLION_COOLDOWN:-600}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/krillion"
STAMP="$STATE_DIR/last-open"

finish() {
  [ "$1" = "--cursor" ] && printf '{"continue":true}\n'
  exit 0
}

# Drain stdin (hooks pass a JSON payload) so the caller never blocks on a full pipe.
[ -t 0 ] || cat >/dev/null 2>&1

[ "${KRILLION_DISABLED:-0}" = "1" ] && finish "$1"

mkdir -p "$STATE_DIR" 2>/dev/null
now=$(date +%s)
last=$(cat "$STAMP" 2>/dev/null || echo 0)
case "$last" in ''|*[!0-9]*) last=0 ;; esac
if [ $((now - last)) -lt "$COOLDOWN" ]; then
  finish "$1"
fi
echo "$now" > "$STAMP" 2>/dev/null

# Open in the background; never print anything (hook stdout can be fed to the model).
(
  if command -v open >/dev/null 2>&1 && [ "$(uname)" = "Darwin" ]; then
    open "$URL"
  elif command -v wslview >/dev/null 2>&1; then
    wslview "$URL"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$URL"
  elif command -v cmd.exe >/dev/null 2>&1; then
    cmd.exe /c start "" "$URL"
  fi
) >/dev/null 2>&1 &

finish "$1"
