# krillion-autoopen

Opens **[Krillion Puffer Party](https://krillion.io/party)** the moment your vibe coding tool starts working on a prompt, and (with the bundled Chrome extension) drops you straight into a **3s** game.

Works with **Claude Code** and **Cursor**. macOS, Linux and WSL.

## Install

### Claude Code (plugin)

Inside Claude Code:

```
/plugin marketplace add asolomon4146/krillion-autoopen
/plugin install krillion-autoopen@krillion
```

### Cursor (or Claude Code without plugins)

```bash
git clone https://github.com/asolomon4146/krillion-autoopen.git
cd krillion-autoopen
./install.sh          # installs for every tool it finds
```

`./install.sh cursor` or `./install.sh claude` installs for just one. Restart Cursor afterwards.

### Auto-join a 3s game (Chrome)

The hook opens `https://krillion.io/party#autojoin=3s`. To have it pick **3s** and press **Quick Play** for you:

1. Open `chrome://extensions` and turn on **Developer mode** (top right).
2. Click **Load unpacked** and choose the [`extension`](extension) folder from this repo.
3. Play one Puffer Party game by hand so the site remembers your name.

On macOS the page opens in Google Chrome when it's installed, even if Chrome isn't your default browser. If a Puffer Party tab is already open, the extension switches to it instead of joining a second game.

Want a different mode? Set `KRILLION_URL`, e.g. `https://krillion.io/party#autojoin=1v1`, `#autojoin=4-6`, `#autojoin=8-10`, or add `-rated` (`#autojoin=3s-rated`) for rated play.

## How it works

| Tool        | Hook                 | Fires when                      |
|-------------|----------------------|---------------------------------|
| Claude Code | `UserPromptSubmit`   | you send Claude a prompt        |
| Cursor      | `beforeSubmitPrompt` | you send the agent a prompt     |

The hook runs [`scripts/open-krillion.sh`](scripts/open-krillion.sh), which opens the URL in the background and returns immediately, so it never slows the agent down or adds anything to its context.

To avoid a tab per prompt, it opens at most **once every 5 minutes**.

## Settings

Set these in your shell profile:

| Variable            | Default               | Meaning                                  |
|---------------------|-----------------------|------------------------------------------|
| `KRILLION_COOLDOWN` | `300`                 | Seconds between opens (`0` = every prompt) |
| `KRILLION_URL`      | `https://krillion.io/party#autojoin=3s` | Page to open           |
| `KRILLION_BROWSER`  | Google Chrome (macOS) | App to open it in                        |
| `KRILLION_DISABLED` | unset                 | `1` turns it off                         |

## Uninstall

- Claude Code plugin: `/plugin uninstall krillion-autoopen@krillion`
- Script install: `./install.sh uninstall`

## License

MIT
