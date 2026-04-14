#!/usr/bin/env bash
# handy-paste.sh — one-shot instant paste for Handy on KDE Wayland.
#
# Context:
#   Handy's built-in "Paste Method: Clipboard (*)" options produce garbled
#   output on KDE Plasma / Wayland (see bugs/clipboard-paste-modifier-loss-kde-wayland.md).
#   Direct mode works but paces keystrokes, so a few paragraphs can take
#   10–20 seconds to finish typing.
#
# This script is a drop-in workaround. Set Handy's Paste Method to
# "External Script" and point it at this file. Handy passes the transcript
# on stdin; we stage it on the Wayland clipboard and synthesise a single
# Ctrl+V via ydotool raw keycodes. Total latency ~20–50 ms regardless of
# transcript length.
#
# Requirements:
#   - wl-clipboard  (`sudo apt install wl-clipboard`)
#   - ydotool + ydotoold running  (user in `input` group)
#   - The target window must accept Ctrl+V as paste.
#
# Keycodes used:
#   29 = LEFTCTRL, 47 = V  (standard Linux evdev codes; unaffected by keyboard layout).

set -euo pipefail

TEXT="$(cat)"

# Save previous clipboard so we can restore after paste.
OLD="$(wl-paste 2>/dev/null || true)"

# Stage transcript on the clipboard.
printf '%s' "$TEXT" | wl-copy

# Fire Ctrl+V as raw keycode sequence.
ydotool key 29:1 47:1 47:0 29:0

# Let the target app consume the paste before we overwrite the clipboard.
sleep 0.3

# Restore the previous clipboard contents.
printf '%s' "$OLD" | wl-copy
