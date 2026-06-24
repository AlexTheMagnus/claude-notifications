#!/usr/bin/env bash
#
# Claude Code notification hook.
# Usage: notify.sh <attention|stop>
#
#   attention  -> fired on the "Notification" hook (Claude needs your input)
#   stop       -> fired on the "Stop" hook (Claude finished the task)
#
# Plays a sound and shows a desktop notification. Supports Linux and macOS,
# and degrades silently (never fails the Claude session) when the required
# tools or sound files are missing.
#
# Text can be overridden with environment variables:
#   CLAUDE_NOTIFY_TITLE            (default: "Claude Code")
#   CLAUDE_NOTIFY_ATTENTION_MSG    (default: "Claude necesita tu atención")
#   CLAUDE_NOTIFY_STOP_MSG         (default: "Tarea completada")

set -u

kind="${1:-stop}"

title="${CLAUDE_NOTIFY_TITLE:-Claude Code}"
case "$kind" in
  attention) message="${CLAUDE_NOTIFY_ATTENTION_MSG:-Claude necesita tu atención}" ;;
  stop)      message="${CLAUDE_NOTIFY_STOP_MSG:-Tarea completada}" ;;
  *)         message="${CLAUDE_NOTIFY_STOP_MSG:-Tarea completada}" ;;
esac

has() { command -v "$1" >/dev/null 2>&1; }

play_sound_linux() {
  local sound
  if [ "$kind" = "attention" ]; then
    sound="/usr/share/sounds/freedesktop/stereo/bell.oga"
  else
    sound="/usr/share/sounds/freedesktop/stereo/complete.oga"
  fi
  if has paplay && [ -f "$sound" ]; then
    paplay "$sound" >/dev/null 2>&1 &
  elif has canberra-gtk-play; then
    canberra-gtk-play -i "bell" >/dev/null 2>&1 &
  fi
}

notify_linux() {
  if has notify-send; then
    notify-send "$title" "$message" >/dev/null 2>&1
  fi
}

play_sound_macos() {
  local sound
  if [ "$kind" = "attention" ]; then
    sound="/System/Library/Sounds/Submarine.aiff"
  else
    sound="/System/Library/Sounds/Glass.aiff"
  fi
  if has afplay && [ -f "$sound" ]; then
    afplay "$sound" >/dev/null 2>&1 &
  fi
}

notify_macos() {
  if has osascript; then
    # Escape double quotes in the strings to keep the AppleScript valid.
    local safe_title="${title//\"/\\\"}"
    local safe_message="${message//\"/\\\"}"
    osascript -e "display notification \"${safe_message}\" with title \"${safe_title}\"" >/dev/null 2>&1
  fi
}

case "$(uname -s)" in
  Linux)  play_sound_linux; notify_linux ;;
  Darwin) play_sound_macos; notify_macos ;;
  *)      : ;; # unsupported OS: do nothing, never fail the session
esac

exit 0
