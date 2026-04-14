# Workarounds

Drop-in scripts and config snippets that work around specific Handy bugs without waiting on an upstream fix.

Each workaround is cross-referenced with the bug entry it addresses.

## Scripts

| Script | Addresses | Purpose |
|---|---|---|
| [`handy-paste.sh`](handy-paste.sh) | [`bugs/clipboard-paste-modifier-loss-kde-wayland.md`](../bugs/clipboard-paste-modifier-loss-kde-wayland.md) | One-shot instant paste on KDE Wayland via `wl-copy` + `ydotool` raw-keycode Ctrl+V. Replaces Handy's broken built-in Clipboard paste method. |

## Installation — `handy-paste.sh`

```bash
# Dependencies
sudo apt install -y wl-clipboard ydotool

# Confirm ydotoold is running and you're in the input group
systemctl is-active ydotoold || sudo systemctl enable --now ydotoold
groups | grep -q input || sudo usermod -aG input "$USER"   # requires re-login

# Install the script
install -m 755 handy-paste.sh ~/bin/handy-paste.sh
```

In Handy settings:

1. **Paste Method** → `External Script`
2. **Script path** → `/home/$USER/bin/handy-paste.sh` (absolute path)

Test with a short dictation. The transcript should appear in one shot with no visible per-character typing.

## Rollback

Switch **Paste Method** back to `Direct` (or `Clipboard (Ctrl+V)` if/when the upstream bug is fixed). The script makes no persistent changes to the system — removing it is `rm ~/bin/handy-paste.sh`.

## Notes

- The script uses raw evdev keycodes (`29:1 47:1 47:0 29:0` = LCtrl down, V down, V up, LCtrl up) rather than the symbolic `ctrl+v` form, because symbolic form requires layout translation and can fail on non-US layouts.
- The 300 ms sleep before clipboard restore gives the target app time to consume the paste. If you see the restore landing before the paste, raise it; if clipboard-manager integrations complain, you can remove the restore block and set `Clipboard Handling` → `Copy to Clipboard` in Handy instead.
- This workaround is *not* a substitute for upstream fixing the Clipboard paste method — it bypasses Handy's injection path entirely, which means things like `Clipboard Handling` settings and the `Typing Tool` selector are inert while External Script is active.
