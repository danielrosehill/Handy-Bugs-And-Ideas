# Clipboard paste produces garbled output on KDE Wayland; Typing Tool selector unavailable for Clipboard methods

**Filed locally:** 14/04/26
**Handy version:** 0.8.1 (deb)
**Status:** Drafted, not yet upstreamed
**Upstream issue:** _not yet filed — candidate for [cjpais/Handy](https://github.com/cjpais/Handy/issues)_

## Summary

On Ubuntu 25.10 / KDE Plasma / Wayland, switching *Paste Method* from `Direct` to any Clipboard variant (`Ctrl+V`, `Ctrl+Shift+V`, `Shift+Insert`) produces garbled output at the cursor — characters like `2424` appear instead of the transcript. Simultaneously, the *Typing Tool* selector (which exposes `ydotool` / `wtype` / `kwtype` / `dotool` / `xdotool` / `Auto`) disappears from the settings UI when a Clipboard method is selected, so there is no way to force a specific backend for the synthesised paste keystroke.

Direct mode works (slow paced typing, but correct characters); clipboard-variant modes do not.

## Environment

- **OS:** Ubuntu 25.10
- **Desktop:** KDE Plasma 6 on Wayland (kwin_wayland)
- **Handy:** 0.8.1 (installed via `.deb`)
- **Audio capture:** working (Direct mode proves pipeline end-to-end)
- **ydotool:** installed, `ydotoold` running as user service, user in `input` group
- **wtype:** installed
- **xdotool:** installed (usable under Xwayland only)
- **Keyboard layout:** US QWERTY (so layout-mismatch is not the cause)

## Steps to reproduce

1. Open Handy settings.
2. Set *Paste Method* → `Clipboard (Ctrl+V)`.
3. Focus any text field (tested: Kate, Firefox URL bar, Konsole).
4. Push-to-talk, dictate a short sentence, release.
5. Observe the output at the cursor.

## Expected

The clipboard is populated with the transcript, a synthetic Ctrl+V fires, and the full transcript appears instantly at the cursor.

## Actual

Garbled/nonsensical characters appear (e.g. `2424`). The transcript itself does land on the clipboard correctly — confirmed by manually hitting Ctrl+V afterwards, which pastes the intended text. So the bug is in the **keystroke-synthesis half** of the clipboard paste, not the clipboard half.

Switching between the three Clipboard variants (`Ctrl+V` / `Ctrl+Shift+V` / `Shift+Insert`) does not help; all three produce garbled output.

## Diagnosis / hypothesis

Two related issues stacked on top of each other:

### 1. Modifier key not held when synthesising the paste shortcut

On KDE Plasma/Wayland (kwin_wayland), the virtual-keyboard protocol implementations used by cross-platform keystroke-synthesis libraries (notably the Rust `enigo` crate, which Handy appears to use internally) have known limitations around holding modifier keys. The observed symptom — a sequence of plain digits/letters instead of the expected paste action — is consistent with Ctrl being released (or never registered) before V is pressed, so the target app sees a bare `v` (or a fallback keycode sequence) rather than `Ctrl+V`.

Related ecosystem context: `wtype` historically has trouble with KDE kwin because kwin's `zwp_virtual_keyboard_v1` support doesn't always honour modifier state for non-IME clients. `ydotool` bypasses Wayland entirely via `uinput`, which usually works, but requires the daemon and correct permissions.

### 2. *Typing Tool* selector is hidden when a Clipboard method is selected

In Handy 0.8.1, the *Typing Tool* dropdown — which lists `wtype`, `kwtype`, `dotool`, `ydotool`, `xdotool`, `Auto` — only appears in the UI when *Paste Method* is `Direct`. Switching to any Clipboard variant removes the selector.

This means the user cannot force `ydotool` (the one backend most likely to work on KDE Wayland) for the Ctrl+V synthesis. Presumably Handy uses `enigo` directly for the modifier+key synthesis in Clipboard mode, rather than dispatching to the user-selected typing tool. If that's the case, the fix is to apply the same Typing Tool selection to both paths — or at minimum, expose the selector.

## Workaround

### Option A — External Script paste method

Set *Paste Method* → `External Script` and point it at a script that uses `wl-copy` + `ydotool` with raw keycodes (avoids any layout translation):

```bash
#!/usr/bin/env bash
# ~/bin/handy-paste.sh
set -euo pipefail
TEXT="$(cat)"                  # Handy passes transcript on stdin
OLD="$(wl-paste 2>/dev/null || true)"
printf '%s' "$TEXT" | wl-copy
ydotool key 29:1 47:1 47:0 29:0   # LCTRL down, V down, V up, LCTRL up
sleep 0.3
printf '%s' "$OLD" | wl-copy
```

Make executable: `chmod +x ~/bin/handy-paste.sh`. Ensure `wl-clipboard` installed: `sudo apt install wl-clipboard`. Ensure `ydotoold` running: `systemctl --user status ydotoold`.

### Option B — Stay on Direct, live with the pacing

`Direct` mode works correctly on US QWERTY — it just paces keystrokes at ~5–30 ms/char, so a few paragraphs can take 10–20 s to finish typing. Acceptable for short dictation, painful for long.

## Questions for upstream

1. What synthesises the Ctrl+V keystroke in Clipboard mode — is it `enigo` directly, or does it dispatch to the user-selected Typing Tool? If the former, consider routing through Typing Tool instead.
2. Why is *Typing Tool* hidden for Clipboard methods? Even if the paste-keystroke path is different, the user should be able to pick a backend.
3. Has the `enigo` modifier-handling issue on KDE Wayland been raised / tested? (enigo-rs issue tracker references may already exist.)

## Related upstream issues

- [cjpais/Handy#692](https://github.com/cjpais/Handy/issues/692) — `Direct` mode repeats/breaks text in terminals (different symptom, same general "injection layer is fragile" theme).
- [cjpais/Handy#439](https://github.com/cjpais/Handy/issues/439) — `Direct` doesn't respect non-US keyboard layouts.
- [cjpais/Handy#742 (discussion)](https://github.com/cjpais/Handy/discussions/742) — "Enable the ability to detect the current available typing methods and let the user choose" — directly relevant; argues for exposing and honouring the Typing Tool choice across all paste methods.

## Verification before filing

- [ ] Re-test on a clean Handy 0.8.1 install.
- [ ] Confirm `ydotoold` is active and user is in `input` group (`groups $USER | grep input`).
- [ ] Confirm the External Script workaround resolves the issue (positive control — proves the clipboard content is fine and the bug is strictly in Handy's keystroke synthesis).
- [ ] Capture a screen recording showing the garbled output for the upstream issue.
- [ ] Re-check against the latest Handy release (may be >0.8.1 by filing time).
