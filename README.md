# claude-notifications

A small [Claude Code](https://docs.claude.com/en/docs/claude-code) plugin marketplace that
distributes one plugin: **`notifications`**.

It plays a sound and shows a desktop notification when Claude Code:

- **needs your attention** (the `Notification` hook — e.g. waiting for input or a permission), and
- **finishes a task** (the `Stop` hook).

Works on **Linux** and **macOS**.

## Install

In any Claude Code session:

```
/plugin marketplace add AlexTheMagnus/claude-notifications
/plugin install notifications@claude-notifications
```

Restart the session (or run `/plugin`) and you're done.

> Replace `AlexTheMagnus/claude-notifications` with the actual GitHub `owner/repo` once published.

## Requirements

**Linux**
- `notify-send` (package `libnotify-bin` on Debian/Ubuntu) for the desktop notification.
- A PulseAudio/PipeWire setup with `paplay` for the sound (falls back to `canberra-gtk-play`,
  or no sound if neither is available).
- The freedesktop sound theme (`/usr/share/sounds/freedesktop/...`), present on most desktops.

**macOS**
- Nothing extra — uses the built-in `afplay` and `osascript`.
- The first time it runs, macOS may ask you to allow notifications for your terminal app.

If a required tool is missing the plugin degrades silently and never interrupts your session.

## Customizing the text

Override the messages with environment variables (e.g. in your shell profile):

```bash
export CLAUDE_NOTIFY_TITLE="Claude Code"
export CLAUDE_NOTIFY_ATTENTION_MSG="Claude needs your attention"
export CLAUDE_NOTIFY_STOP_MSG="Task completed"
```

## Note: avoid duplicate notifications

If you previously wired these notifications by hand in `~/.claude/settings.json`
(`Notification` / `Stop` hooks), remove those entries after installing the plugin so you
don't get notified twice.

## License

MIT
