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

## Requirements

**Linux**
- `notify-send` (package `libnotify-bin` on Debian/Ubuntu) for the desktop notification.
- An audio player for the sound. The script tries, in order, `canberra-gtk-play`
  (package `libcanberra-gtk-module` / `libcanberra-gtk3-module`), then `paplay`
  (`pulseaudio-utils`), then `pw-play` (`pipewire`). `canberra-gtk-play` is the most
  portable: it ships on virtually every GTK/GNOME desktop and works on both PulseAudio and
  PipeWire, so the default sound usually works out of the box on Ubuntu, Mint, Debian and
  Fedora desktops.
- The freedesktop sound theme provides the default sounds (`bell` / `complete`). It comes
  installed on GTK/GNOME desktops as a dependency of `libcanberra`.

> Note on Fedora and other PipeWire-based distros: `paplay` is often **not** installed by
> default there, which is why `canberra-gtk-play` is preferred. On a minimal/server/WSL/Docker
> environment with no desktop you may have neither — the plugin will then warn you once (see
> [Troubleshooting](#troubleshooting)).

**macOS**
- Nothing extra — uses the built-in `afplay` and `osascript`.
- The first time it runs, macOS may ask you to allow notifications for your terminal app.

If a required tool is missing the plugin never interrupts your session: it degrades gracefully
and, on Linux, shows a one-time warning explaining what to install.

## Customizing the text

Override the messages with environment variables (e.g. in your shell profile):

```bash
export CLAUDE_NOTIFY_TITLE="Claude Code"
export CLAUDE_NOTIFY_ATTENTION_MSG="Claude needs your attention"
export CLAUDE_NOTIFY_STOP_MSG="Task completed"
```

## Custom sounds

You can replace the default sounds in two ways. They are resolved with this priority:

**1. Environment variable** — point to your own sound file (best if you version your dotfiles):

```bash
export CLAUDE_NOTIFY_ATTENTION_SOUND=~/sounds/ping.oga
export CLAUDE_NOTIFY_STOP_SOUND=~/sounds/done.oga
```

**2. Drop-in file** — just drop a file into the config dir, no config needed. The first
matching extension (`oga`, `ogg`, `wav`, `mp3`, `aiff`) is used:

```
~/.config/claude-notifications/attention.oga
~/.config/claude-notifications/stop.oga
```

(Respects `$XDG_CONFIG_HOME` if set.)

**3. System sound** (default) — if neither of the above is set, the freedesktop theme sound is
used: `bell` for attention, `complete` for stop. You can change which theme sound is used
without providing a file:

```bash
export CLAUDE_NOTIFY_ATTENTION_THEME=message
export CLAUDE_NOTIFY_STOP_THEME=complete
```

## Troubleshooting

**No sound on Linux.** Install an audio player and the sound theme:

```bash
# Debian / Ubuntu / Mint
sudo apt install libcanberra-gtk-module sound-theme-freedesktop libnotify-bin
# Fedora
sudo dnf install libcanberra-gtk3 sound-theme-freedesktop
```

When the plugin can't find any audio player (or `notify-send`), it prints a one-time warning
in the session telling you what's missing. The warning won't repeat unless the situation
changes. It never blocks Claude.

## Note: avoid duplicate notifications

If you previously wired these notifications by hand in `~/.claude/settings.json`
(`Notification` / `Stop` hooks), remove those entries after installing the plugin so you
don't get notified twice.

## License

MIT
