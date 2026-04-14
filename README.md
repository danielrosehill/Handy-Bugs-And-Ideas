# Handy — Bugs and Ideas

A personal log of bugs, regressions, UX friction, and feature ideas observed while using [Handy](https://github.com/cjpais/Handy) (the offline speech-to-text app by cjpais) on Ubuntu 25.10 / KDE Plasma / Wayland.

Each entry is a standalone markdown file captured against a specific Handy version. Well-reproduced bugs are intended to be upstreamed as issues on [`cjpais/Handy`](https://github.com/cjpais/Handy/issues); feature ideas may be opened as discussions or kept here as design notes.

## Environment (default)

Unless an entry says otherwise, the environment is:

- **OS**: Ubuntu 25.10
- **Desktop**: KDE Plasma on Wayland (kwin)
- **Handy**: 0.8.1 (installed via `.deb`)
- **Backends available**: `ydotool` (with `ydotoold` running), `wtype`, `xdotool` (under Xwayland)
- **STT model**: Parakeet-TDT 0.6B v2, local GPU inference

## Bugs

| Entry | Status | Upstream |
|---|---|---|
| [Clipboard paste produces garbled output on KDE Wayland — Typing Tool selector unavailable for Clipboard methods](bugs/clipboard-paste-modifier-loss-kde-wayland.md) | Drafted | Not yet filed |

## Ideas

| Entry | Status |
|---|---|
| [KDE Plasma + Wayland friction points — watch-list](ideas/kde-wayland-friction-points-watchlist.md) | AI-generated brainstorm (Claude); items to verify, not confirmed bugs |

## Workarounds

| Script | Addresses |
|---|---|
| [`workarounds/handy-paste.sh`](workarounds/handy-paste.sh) | [Clipboard paste garbled on KDE Wayland](bugs/clipboard-paste-modifier-loss-kde-wayland.md) — one-shot paste via `wl-copy` + `ydotool` raw-keycode Ctrl+V, wired into Handy as an External Script. |

See [`workarounds/README.md`](workarounds/README.md) for installation and rollback.

## Layout

```
bugs/         — one file per reproducible bug, intended for upstream filing
ideas/        — feature requests, UX suggestions, and design notes
workarounds/  — scripts and config snippets that sidestep specific bugs
```

## How I write these

- One file per entry. Filename is a kebab-case slug.
- Bug entries include: summary, environment, steps to reproduce, expected vs actual, diagnosis/hypothesis, workaround, links to related upstream issues.
- Idea entries include: motivation, proposed behaviour, alternatives considered, rough implementation sketch.
- Before upstreaming, verify reproduction on a clean state and re-check against the latest Handy release.
