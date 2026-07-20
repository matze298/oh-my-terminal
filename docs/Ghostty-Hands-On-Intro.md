# 👻 Ghostty — Hands-On Intro

> [!info] Your setup (auto-detected)
> - **Ghostty** `1.3.1` (stable), GTK4 + libadwaita, OpenGL renderer
> - **Shell**: zsh (shell integration is automatic — several features below depend on it)
> - **Config file**: `~/.config/ghostty/config`
> - Every keybind below is a **verified default for your build**. See them all with `ghostty +list-keybinds --default`.

This is a do-it-as-you-read tour. Keep Ghostty open next to Obsidian and work through the checkboxes.

---

## 0. First, the config file (2 min)

Ghostty is configured with a plain text file. It only auto-loads from **one** path:

```
~/.config/ghostty/config
```

> [!warning] You currently have `~/.config/ghostty/config.ghostty` — that filename is **not** loaded automatically. Create the real one:
> ```sh
> mkdir -p ~/.config/ghostty
> $EDITOR ~/.config/ghostty/config
> ```
> Keep it minimal: only put in the settings you actually want to change. Everything you leave out already uses Ghostty's built-in default.

The killer feature: **live reload**. Edit the file, save, then press `ctrl+shift+,` in any window and changes apply instantly. No restart.

- [x] Create `~/.config/ghostty/config`
- [x] Add a line, save, press `ctrl+shift+,`, watch it apply

Inspect config without opening the file at all:

```sh
ghostty +show-config            # what's active right now
ghostty +list-actions           # every action you can bind
ghostty +list-keybinds          # your current keybinds
```

---

## 1. Splits & tabs — a full workspace in one window

Ghostty has native splits and tabs, no tmux required.

| Do this | Key |
|---|---|
| Split **right** | `ctrl+shift+o` |
| Split **down** | `ctrl+shift+e` |
| Move between splits | `ctrl+alt+↑ ↓ ← →` (see warning below) |
| Cycle splits | `super+ctrl+]` / `super+ctrl+[` |
| Resize focused split | `super+ctrl+shift+↑ ↓ ← →` |
| **Zoom** a split fullscreen (toggle) | `ctrl+shift+enter` |
| New tab | `ctrl+shift+t` |
| Next / prev tab | `ctrl+tab` / `ctrl+shift+tab` |
| Jump to tab N | `alt+1` … `alt+9` |
| Close split/tab | `ctrl+shift+w` |

- [x] Split right, then down, so you have 3 panes
- [x] Jump around with `super+ctrl+arrows` (after the rebind below)
- [x] Zoom one pane with `ctrl+shift+enter`, then again to restore

> [!warning] `ctrl+alt+arrows` is grabbed by the Linux desktop for **workspace switching**, so Ghostty never sees it. Remap split navigation onto the free `super+ctrl+arrow` combo (matches the built-in `super+ctrl+]`/`[` cycle binds):
> ```ini
> keybind = super+ctrl+arrow_left=goto_split:left
> keybind = super+ctrl+arrow_right=goto_split:right
> keybind = super+ctrl+arrow_up=goto_split:up
> keybind = super+ctrl+arrow_down=goto_split:down
> ```
> If your desktop also claims that combo, pick any free one, or disable the OS shortcut. See [[Ghostty-Config-Starter]].

> [!tip] New splits and tabs **inherit the working directory** of the current pane (thanks to zsh shell integration). `cd` into a project, split, and the new pane is already there.

---

## 2. The command palette

> [!example] Press `ctrl+shift+p`
> A searchable list of **every action** pops up. Type "split", "theme", "font", "fullscreen"… This is the fastest way to discover features and run something you haven't bound to a key yet.

- [x] Open it and search for `split`
- [x] Search for `config` and reload from there

---

## 3. Themes — 463 of them, built in

No downloading color schemes. Ghostty ships **463 themes**.

```sh
ghostty +list-themes        # browse (interactive preview in a terminal)
```

Set one in your config:

```ini
theme = Catppuccin Mocha
```

> [!warning] Theme names must match `ghostty +list-themes` **exactly**, including capitalization and spaces (e.g. `Catppuccin Mocha`, not `catppuccin-mocha`).

The slick part — **automatic light/dark switching** that follows your desktop:

```ini
theme = light:Catppuccin Latte,dark:Catppuccin Mocha
```

- [x] Run `ghostty +list-themes` and pick one you like
- [x] Set `theme = ...`, save, `ctrl+shift+,` to apply live
- [x] Bonus: try the `light:…,dark:…` form and toggle your OS theme

---

## 4. Fonts, ligatures & Nerd Font icons

You already have **FiraCode Nerd Font** installed — a programming font with ligatures *and* thousands of icon glyphs.

```ini
font-family = FiraCode Nerd Font
font-size = 13
# Turn specific ligatures on/off with font features:
# font-feature = -calt   # disable code ligatures if you dislike them
```

Test ligatures — these should render as combined glyphs, not separate characters:

```
==   ->   =>   !=   >=   <=   ===   |>   ::
```

Test Nerd Font icons (if you see boxes, the font-family isn't set):

```
      
```

Live font sizing: `ctrl+=` bigger, `ctrl+-` smaller, `ctrl+0` reset.

- [x] Set `font-family = FiraCode Nerd Font` and reload
- [x] Confirm `->` and `=>` render as arrows
- [x] List everything available: `ghostty +list-fonts`

---

## 5. Shell integration superpowers (zsh)

Because Ghostty knows where each prompt begins, you get things a dumb terminal can't do:

| Feature | How |
|---|---|
| **Jump between previous commands** | `ctrl+shift+page_up` / `ctrl+shift+page_down` |
| Working directory inheritance | automatic on new tab/split (see §1) |
| Cursor-at-prompt awareness, safe resize/reflow | automatic |
| Select whole scrollback | `ctrl+shift+a` |
| Scroll to top / bottom | `shift+home` / `shift+end` |

- [x] Run a few commands, then hammer `ctrl+shift+page_up` — the viewport snaps to each prior prompt

> [!note] This is on automatically for zsh. Nothing to configure.

---

## 6. Clicky links & the mouse

- **Hover** a URL and it underlines. Click (or `ctrl+click`) to open it in your browser.
- Selecting text auto-copies to the primary selection. Paste it with `shift+insert`.
- Copy: `ctrl+shift+c` · Paste: `ctrl+shift+v`.

- [x] `echo "https://ghostty.org"`, then click the link

---

## 7. Appearance polish — opacity, blur, padding

Drop these into your config and reload:

```ini
background-opacity = 0.92
background-blur = 20
window-padding-x = 10
window-padding-y = 8
cursor-style = block
mouse-hide-while-typing = true
```

- [x] Add opacity + blur, reload with `ctrl+shift+,`

> [!tip] `background-blur` depends on your compositor. If nothing happens, your desktop may not support it — opacity still will.

---

## 8. Custom GLSL shaders (the party trick 🎆)

Ghostty can run **custom fragment shaders** over the whole terminal — animated cursors, CRT scanlines, glow, bloom. This is genuinely unique.

Grab a collection like [0xhckr/ghostty-shaders](https://github.com/0xhckr/ghostty-shaders), copy the one you want into `~/.config/ghostty/shaders/`, and point the config at it:

```ini
custom-shader = ~/.config/ghostty/shaders/shader.glsl
custom-shader-animation = true
```

- [x] (Optional) Create `~/.config/ghostty/shaders/`, drop a `.glsl` in, and wire it up

> [!note] There's no native keybind to toggle a shader in 1.3.1. To switch it off, comment the `custom-shader` line and reload with `ctrl+shift+,`.

---

## 9. Inline images (Kitty graphics protocol)

Ghostty implements the Kitty graphics protocol, so image-capable CLI tools can render **actual pictures** in the terminal. Try `chafa` or `timg`:

```sh
sudo apt install chafa      # if not present
chafa some-image.png
```

- [x] Render an image inline

---

## 10. The terminal inspector (for the curious)

Press `ctrl+shift+i` to open a live inspector — surface state, keyboard events, frame timing. Great for debugging a misbehaving TUI or seeing exactly what escape sequences a keypress sends.

- [x] Open it, press some keys, watch the event stream

---

## 📎 Cheat sheet

```
ctrl+shift+p        command palette (start here)
ctrl+shift+,        reload config live
ctrl+shift+o / e    split right / down
super+ctrl+arrows   move between splits (rebind; ctrl+alt is the OS workspace switcher)
ctrl+shift+enter    zoom split
ctrl+shift+t        new tab      ctrl+tab / ctrl+shift+tab  cycle tabs
alt+1..9            jump to tab
ctrl+= / - / 0      font bigger / smaller / reset
ctrl+shift+pgup/pgdn  jump between prompts
ctrl+shift+c / v    copy / paste
ctrl+enter          fullscreen
ctrl+shift+i        inspector
```

CLI helpers: `ghostty +show-config` · `+list-themes` · `+list-fonts` · `+list-keybinds` · `+list-actions`

## 🔗 Go deeper
- Config reference: https://ghostty.org/docs/config/reference
- All keybind actions: https://ghostty.org/docs/config/keybind/reference
- Official docs: https://ghostty.org/docs
