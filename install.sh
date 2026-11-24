#!/usr/bin/env bash
# Installs the krillion.io auto-open hook for Cursor and/or Claude Code (without the plugin system).
#   ./install.sh            # install for every tool found
#   ./install.sh cursor     # just Cursor
#   ./install.sh claude     # just Claude Code (settings.json hook)
#   ./install.sh uninstall  # remove from both
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.krillion/open-krillion.sh"
TARGET="${1:-all}"

command -v python3 >/dev/null || { echo "python3 is required to edit JSON config files." >&2; exit 1; }

merge() {  # merge <file> <tool> <add|remove>
  python3 - "$1" "$2" "$3" "$DEST" <<'PY'
import json, os, sys
path, tool, mode, script = sys.argv[1:5]
data = {}
if os.path.exists(path):
    with open(path) as f:
        txt = f.read().strip()
        data = json.loads(txt) if txt else {}
hooks = data.setdefault("hooks", {})
is_ours = lambda s: "open-krillion.sh" in json.dumps(s)
if tool == "cursor":
    data.setdefault("version", 1)
    lst = [h for h in hooks.get("beforeSubmitPrompt", []) if not is_ours(h)]
    if mode == "add":
        lst.append({"command": f'"{script}" --cursor'})
    hooks["beforeSubmitPrompt"] = lst
else:
    lst = [h for h in hooks.get("UserPromptSubmit", []) if not is_ours(h)]
    if mode == "add":
        lst.append({"hooks": [{"type": "command", "command": f'"{script}"', "timeout": 5}]})
    hooks["UserPromptSubmit"] = lst
for k in [k for k, v in hooks.items() if v == []]:
    del hooks[k]
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
}

if [ "$TARGET" = "uninstall" ]; then
  [ -f "$HOME/.cursor/hooks.json" ] && merge "$HOME/.cursor/hooks.json" cursor remove
  [ -f "$HOME/.claude/settings.json" ] && merge "$HOME/.claude/settings.json" claude remove
  rm -f "$DEST"
  echo "Removed krillion.io auto-open."
  exit 0
fi

mkdir -p "$(dirname "$DEST")"
cp "$SRC_DIR/scripts/open-krillion.sh" "$DEST"
chmod +x "$DEST"

if [ "$TARGET" = "all" ] || [ "$TARGET" = "cursor" ]; then
  if [ "$TARGET" = "cursor" ] || [ -d "$HOME/.cursor" ]; then
    merge "$HOME/.cursor/hooks.json" cursor add
    echo "✓ Cursor: hook added to ~/.cursor/hooks.json (restart Cursor)"
  fi
fi
if [ "$TARGET" = "all" ] || [ "$TARGET" = "claude" ]; then
  if [ "$TARGET" = "claude" ] || [ -d "$HOME/.claude" ]; then
    merge "$HOME/.claude/settings.json" claude add
    echo "✓ Claude Code: hook added to ~/.claude/settings.json"
  fi
fi
echo "Puffer Party will open when your agent starts working (at most once every ${KRILLION_COOLDOWN:-300}s)."
echo "For auto-join: open chrome://extensions, enable Developer mode, Load unpacked -> $SRC_DIR/extension"
