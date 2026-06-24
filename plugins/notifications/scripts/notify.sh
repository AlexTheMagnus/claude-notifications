#!/usr/bin/env bash
#
# Claude Code notification hook.
# Usage: notify.sh <attention|stop>
#
#   attention  -> fired on the "Notification" hook (Claude needs your input)
#   stop       -> fired on the "Stop" hook (Claude finished the task)
#
# Plays a sound and shows a desktop notification. Supports Linux and macOS,
# and degrades gracefully (never fails the Claude session) when the required
# tools or sound files are missing. If nothing can be played on Linux it warns
# the user once via a hook `systemMessage`.
#
# Customization (priority: env var > drop-in file > system sound):
#   CLAUDE_NOTIFY_ATTENTION_SOUND / CLAUDE_NOTIFY_STOP_SOUND
#       Absolute path to a custom sound file.
#   ~/.config/claude-notifications/{attention,stop}.{oga,ogg,wav,mp3,aiff}
#       Drop-in file picked up automatically (respects $XDG_CONFIG_HOME).
#   CLAUDE_NOTIFY_ATTENTION_THEME / CLAUDE_NOTIFY_STOP_THEME
#       Freedesktop theme sound name to use instead of the default
#       (attention -> "bell", stop -> "complete").
#
# Text overrides:
#   CLAUDE_NOTIFY_TITLE          (default: "Claude Code")
#   CLAUDE_NOTIFY_ATTENTION_MSG  (default: "Claude necesita tu atención")
#   CLAUDE_NOTIFY_STOP_MSG       (default: "Tarea completada")

set -u

kind="${1:-stop}"
[ "$kind" != "attention" ] && kind="stop"

has() { command -v "$1" >/dev/null 2>&1; }

# --- text ---------------------------------------------------------------------
title="${CLAUDE_NOTIFY_TITLE:-Claude Code}"
if [ "$kind" = "attention" ]; then
  message="${CLAUDE_NOTIFY_ATTENTION_MSG:-Claude necesita tu atención}"
else
  message="${CLAUDE_NOTIFY_STOP_MSG:-Tarea completada}"
fi

# --- config / cache locations -------------------------------------------------
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/claude-notifications"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude-notifications"

# --- resolve the custom sound (env var, then drop-in file) --------------------
if [ "$kind" = "attention" ]; then
  custom_sound="${CLAUDE_NOTIFY_ATTENTION_SOUND:-}"
  theme_name="${CLAUDE_NOTIFY_ATTENTION_THEME:-bell}"
else
  custom_sound="${CLAUDE_NOTIFY_STOP_SOUND:-}"
  theme_name="${CLAUDE_NOTIFY_STOP_THEME:-complete}"
fi

if [ -z "$custom_sound" ]; then
  for ext in oga ogg wav mp3 aiff; do
    candidate="$config_dir/$kind.$ext"
    if [ -f "$candidate" ]; then
      custom_sound="$candidate"
      break
    fi
  done
fi

# --- sound playback -----------------------------------------------------------
# Returns 0 if a usable player was found and launched, 1 otherwise.
play_sound() {
  local os="$1"

  if [ "$os" = "Darwin" ]; then
    local file="$custom_sound"
    [ -z "$file" ] && file="$macos_default"
    if has afplay && [ -f "$file" ]; then
      afplay "$file" >/dev/null 2>&1 &
      return 0
    fi
    return 1
  fi

  # Linux: a custom file uses file players...
  if [ -n "$custom_sound" ] && [ -f "$custom_sound" ]; then
    if has paplay; then paplay "$custom_sound" >/dev/null 2>&1 & return 0; fi
    if has pw-play; then pw-play "$custom_sound" >/dev/null 2>&1 & return 0; fi
    if has canberra-gtk-play; then canberra-gtk-play -f "$custom_sound" >/dev/null 2>&1 & return 0; fi
  fi

  # ...otherwise the system sound. Prefer the theme name (no hardcoded path,
  # works on both PulseAudio and PipeWire desktops), then fall back to paths.
  if has canberra-gtk-play; then canberra-gtk-play -i "$theme_name" >/dev/null 2>&1 & return 0; fi
  if [ -f "$linux_default" ]; then
    if has paplay; then paplay "$linux_default" >/dev/null 2>&1 & return 0; fi
    if has pw-play; then pw-play "$linux_default" >/dev/null 2>&1 & return 0; fi
  fi
  return 1
}

# --- desktop notification -----------------------------------------------------
# Returns 0 if a notifier was found, 1 otherwise.
notify_user() {
  local os="$1"
  if [ "$os" = "Darwin" ]; then
    if has osascript; then
      local safe_title="${title//\"/\\\"}"
      local safe_message="${message//\"/\\\"}"
      osascript -e "display notification \"${safe_message}\" with title \"${safe_title}\"" >/dev/null 2>&1
      return 0
    fi
    return 1
  fi
  if has notify-send; then
    notify-send "$title" "$message" >/dev/null 2>&1
    return 0
  fi
  return 1
}

os="$(uname -s)"
case "$os" in
  Linux|Darwin) ;;
  *) exit 0 ;; # unsupported OS: do nothing, never fail the session
esac

linux_default="/usr/share/sounds/freedesktop/stereo/${theme_name}.oga"
if [ "$kind" = "attention" ]; then
  macos_default="/System/Library/Sounds/Submarine.aiff"
else
  macos_default="/System/Library/Sounds/Glass.aiff"
fi

sound_ok=0
notify_ok=0
play_sound "$os" && sound_ok=1
notify_user "$os" && notify_ok=1

# --- warn the user once if Linux can't play sound or show a notification ------
if [ "$os" = "Linux" ] && { [ "$sound_ok" -eq 0 ] || [ "$notify_ok" -eq 0 ]; }; then
  marker="$cache_dir/warned-s${sound_ok}-n${notify_ok}"
  if [ ! -f "$marker" ]; then
    mkdir -p "$cache_dir" >/dev/null 2>&1
    : > "$marker" 2>/dev/null
    parts=""
    if [ "$sound_ok" -eq 0 ]; then
      parts="no audio player found (install libcanberra-gtk-module, pulseaudio-utils or pipewire)"
    fi
    if [ "$notify_ok" -eq 0 ]; then
      [ -n "$parts" ] && parts="${parts}; "
      parts="${parts}notify-send missing (install libnotify-bin)"
    fi
    printf '{"systemMessage": "claude-notifications: %s. Notifications will be degraded."}\n' "$parts"
  fi
fi

exit 0
