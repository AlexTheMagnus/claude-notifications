# notifications

Sound + desktop notifications for Claude Code, on **Linux** and **macOS**.

| Hook event     | When it fires                          | Sound (Linux / macOS)        |
| -------------- | -------------------------------------- | ---------------------------- |
| `Notification` | Claude needs your input/attention      | `bell.oga` / `Submarine.aiff` |
| `Stop`         | Claude finished responding to the task | `complete.oga` / `Glass.aiff` |

Both events also show a desktop notification (`notify-send` on Linux, `osascript` on macOS).

## What's inside

```
notifications/
├── .claude-plugin/plugin.json   # plugin manifest
├── hooks/hooks.json             # wires Notification + Stop to the script
└── scripts/notify.sh            # cross-platform sound + notification
```

`hooks.json` invokes `scripts/notify.sh` via `${CLAUDE_PLUGIN_ROOT}`, so it works
regardless of where the plugin is installed.

## Custom sounds

Sounds are resolved as **environment variable → drop-in file → system sound**, e.g.
`export CLAUDE_NOTIFY_STOP_SOUND=~/sounds/done.oga` or dropping
`~/.config/claude-notifications/stop.oga`. See the
[marketplace README](../../README.md#custom-sounds) for the full list of options,
requirements per distro, and troubleshooting.
