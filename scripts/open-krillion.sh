#!/usr/bin/env bash
# Opens Krillion's Puffer Party when an AI coding agent starts working.
# With the extension in ./extension loaded in Chrome, it also joins a 3s game automatically.
# Safe to call on every prompt: a cooldown stops it from piling up tabs.
#
# Env vars:
#   KRILLION_URL       URL to open            (default: https://krillion.io/party#autojoin=3s)
#   KRILLION_BROWSER   macOS app to open it in (default: Google Chrome if installed, else default browser)
#   KRILLION_COOLDOWN  seconds between opens  (default: 300, 0 = every time)
#   KRILLION_DISABLED  set to 1 to turn off
#
# Flags:
#   --cursor   print the JSON Cursor's beforeSubmitPrompt hook expects

URL="${KRILLION_URL:-https://krillion.io/party#autojoin=3s}"
COOLDOWN="${KRILLION_COOLDOWN:-300}"
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
  if [ "$(uname)" = "Darwin" ]; then
    BROWSER_APP="${KRILLION_BROWSER:-}"
    if [ -z "$BROWSER_APP" ] && { [ -d "/Applications/Google Chrome.app" ] || [ -d "$HOME/Applications/Google Chrome.app" ]; }; then
      BROWSER_APP="Google Chrome"
    fi
    if [ -n "$BROWSER_APP" ]; then open -a "$BROWSER_APP" "$URL"; else open "$URL"; fi
  elif command -v wslview >/dev/null 2>&1; then
    wslview "$URL"
  elif command -v google-chrome >/dev/null 2>&1; then
    google-chrome "$URL"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$URL"
  elif command -v cmd.exe >/dev/null 2>&1; then
    cmd.exe /c start "" "$URL"
  fi
) >/dev/null 2>&1 &

finish "$1"
