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

See the [marketplace README](../../README.md) for install instructions, requirements, and
how to customize the notification text.
