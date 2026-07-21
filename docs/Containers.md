# 🐳 Containers

Your go-to terminal tools for inspecting, debugging, and slimming Docker images when you build training and serving containers. Both run entirely in the terminal, so they work the same on your laptop and over SSH on a GPU box.

## lazydocker — full-screen Docker & compose TUI

A terminal UI for Docker and docker-compose that puts containers, logs, images, and volumes on one screen, from the same author as lazygit. It saves you from memorizing long `docker ps`, `docker logs`, and `docker inspect` incantations while you debug a training or serving container. Installed by the repo's `setup.sh`.

```sh
# Launch the dashboard in the current directory (auto-detects docker-compose)
lazydocker
```

Common key bindings inside the TUI:

| Key | Action |
| --- | --- |
| `[` / `]` | Previous / next tab in the focused panel |
| `1`–`5` | Jump to a panel (project, containers, images, volumes) |
| `x` | Open the context menu of actions for the selected item |
| `s` | Stop the selected container |
| `r` | Restart the selected container |
| `a` | Attach to the selected container |
| `E` | Exec a shell into the selected container |
| `d` | Remove the selected container or image |
| `b` | View and run bulk (custom) commands |
| `+` / `-` | Zoom the log/main panel in and out |
| `q` | Quit |

> [!tip] Press `x` on any item to see the full, context-aware menu of actions with their exact key bindings, so you never have to guess what a given panel supports.

Docs: [lazydocker docs](https://github.com/jesseduffield/lazydocker#readme)

## dive — explore an image layer by layer

A tool for inspecting a Docker image one layer at a time, showing exactly which files each layer adds, changes, or deletes and how much space is wasted. It is the fastest way to spot a bloated `pip install` cache or leftover apt lists inflating your training image. Installed by the repo's `setup.sh`.

```sh
# Analyze a local or pulled image interactively
dive my-training-image:latest

# Analyze by image ID
dive 6f2d3c8a1b9e

# Build and immediately analyze in one step (proxies to docker build)
dive build -t my-serving-image:latest .

# Analyze an image saved as a tarball, no daemon needed
dive --source docker-archive image.tar

# Non-interactive CI mode: exits non-zero if efficiency rules fail
CI=true dive my-training-image:latest

# CI mode with custom thresholds (e.g. lowestEfficiency, highestWastedBytes)
CI=true dive my-training-image:latest --ci-config .dive-ci
```

> [!tip] In CI, set `CI=true` and a `.dive-ci` file with a `lowestEfficiency` and `highestWastedBytes` threshold, then run `dive` as a build gate. It fails the pipeline when a change balloons your image, catching regressions before they ship.

Docs: [dive docs](https://github.com/wagoodman/dive#readme)

See also: [[Terminal-Toolkit]] (index) · [[Inspecting-Kubeflow-Pods]]
