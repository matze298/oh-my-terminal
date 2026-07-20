# 👻 Ghostty — Starter Config

> [!info] Context
> Companion to [[Ghostty-Hands-On-Intro]]. This is a proposed `~/.config/ghostty/config` you can build up piece by piece. Tuned for your setup: Ghostty `1.3.1`, GTK4, zsh, FiraCode Nerd Font.

> [!warning] Right file, right place
> Ghostty only auto-loads `~/.config/ghostty/config` (no extension). A file named `config.ghostty` is **not** read.
> ```sh
> mkdir -p ~/.config/ghostty
> $EDITOR ~/.config/ghostty/config
> ```
> After saving, press `ctrl+shift+,` in Ghostty to reload live. Confirm what's active with `ghostty +show-config`.

Pick the blocks you want and paste them in. Each has a one-line reason.

---

## Font

```ini
font-family = FiraCode Nerd Font
font-size = 12
# adjust-cell-height = 12%   # a little line spacing helps readability
# font-feature = -calt       # uncomment to kill code ligatures if they annoy you
```

You already have FiraCode Nerd Font installed, so ligatures and icon glyphs work out of the box.

---

## Theme (auto light/dark)

```ini
theme = light:Catppuccin Latte,dark:Catppuccin Mocha
```

Follows your desktop's light/dark toggle. Theme names must match `ghostty +list-themes` exactly, including capitalization and spaces. Browse the 463 built-ins there and swap either side.

---

## Window polish

```ini
background-opacity = 0.95
background-blur = 20
window-padding-x = 10
window-padding-y = 8
window-decoration = auto
```

> [!note] Opacity always works. Blur is best-effort, it depends on your compositor.

---

## Cursor + mouse quality-of-life

```ini
cursor-style = block
cursor-style-blink = false
mouse-hide-while-typing = true
copy-on-select = clipboard
```

> [!tip] `copy-on-select` is the big one. Selecting text goes straight to the clipboard, not just primary selection.

---

## Scrollback + readability guard

```ini
scrollback-limit = 10000000     # ~10MB of history
minimum-contrast = 1.1          # forces legible text even when apps pick bad colors
```

---

## Keybinds worth adding

**Quick/dropdown terminal** has no default bind on your build. Add a Quake-style dropdown:

```ini
keybind = global:ctrl+grave=toggle_quick_terminal
```

> [!warning] `global:` hotkeys need compositor support (solid on GNOME/KDE, may not fire on some minimal Wayland setups). If `ctrl+`` ` does nothing, drop the `global:` prefix and it still works while Ghostty is focused.

**Directional split navigation.** The default `ctrl+alt+arrows` is swallowed by the OS workspace switcher, so remap onto the free `super+ctrl+arrow` combo (matches the built-in `super+ctrl+]`/`[` cycle binds):

```ini
keybind = super+ctrl+arrow_left=goto_split:left
keybind = super+ctrl+arrow_right=goto_split:right
keybind = super+ctrl+arrow_up=goto_split:up
keybind = super+ctrl+arrow_down=goto_split:down
```

> [!note] If your desktop also claims `super+ctrl+arrows`, pick any free combo, or disable the OS shortcut instead. Check with `ghostty +list-keybinds` after reloading.

---

## Custom shader

Copy a `.glsl` (e.g. from [0xhckr/ghostty-shaders](https://github.com/0xhckr/ghostty-shaders)) into `~/.config/ghostty/shaders/`, then:

```ini
custom-shader = ~/.config/ghostty/shaders/shader.glsl
custom-shader-animation = true
```

> [!note] No native keybind toggles a shader in 1.3.1. To turn it off, comment the line (`# custom-shader = ...`) and reload with `ctrl+shift+,`.

---

## Leave for later

- [x] `custom-shader = ...` — the GLSL effects (see above and [[Ghostty-Hands-On-Intro]] §8).
- [x] Per-key rebinds — live with the defaults for a week, then bind only what actually chafes.

---

## Full starter block (copy-paste)

```ini
# ~/.config/ghostty/config

# --- Font ---
font-family = FiraCode Nerd Font
font-size = 12

# --- Theme (auto light/dark) ---
theme = light:Catppuccin Latte,dark:Catppuccin Mocha

# --- Window ---
background-opacity = 0.95
background-blur = 20
window-padding-x = 10
window-padding-y = 8
window-decoration = auto

# --- Cursor + mouse ---
cursor-style = block
cursor-style-blink = false
mouse-hide-while-typing = true
copy-on-select = clipboard

# --- Scrollback + readability ---
scrollback-limit = 10000000
minimum-contrast = 1.1

# --- Keybinds ---
keybind = global:ctrl+grave=toggle_quick_terminal
# ctrl+alt+arrows collides with the OS workspace switcher, so remap split navigation:
keybind = super+ctrl+arrow_left=goto_split:left
keybind = super+ctrl+arrow_right=goto_split:right
keybind = super+ctrl+arrow_up=goto_split:up
keybind = super+ctrl+arrow_down=goto_split:down
```

## 🔗 See also
- [[Ghostty-Hands-On-Intro]] — the full feature tour
- Config reference: https://ghostty.org/docs/config/reference
