# krillion-autoopen

Opens **[krillion.io](https://krillion.io)** in your browser the moment your vibe coding tool starts working on a prompt.

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
| `KRILLION_URL`      | `https://krillion.io` | Page to open                             |
| `KRILLION_DISABLED` | unset                 | `1` turns it off                         |

## Uninstall

- Claude Code plugin: `/plugin uninstall krillion-autoopen@krillion`
- Script install: `./install.sh uninstall`

## License

MIT
