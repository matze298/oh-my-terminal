# oh-my-terminal docs

A portable, reproducible terminal setup: a zsh foundation plus a curated set of
modern CLI tools, installed by an interactive script. These are the hands-on
how-to notes the toolkit is based on.

> [!note] Who this is for
> Most of the tools are generally useful on any machine. The *selection* and the
> how-to notes, though, are tailored toward a cloud-focused **machine learning
> engineer**: inspecting data on S3/Parquet, debugging training pods on
> Kubernetes, and watching GPUs. Take the generic core, skip the parts that do
> not fit your work.

- **New here?** Start with the [Terminal Toolkit overview](Terminal-Toolkit.md).
- **Rebuilding a machine?** The [Setup Inventory](Setup-Inventory.md) is the full
  annotated parts list.
- **The installer** lives in the
  [oh-my-terminal repository](https://github.com/matze298/oh-my-terminal):
  clone it and run `./setup.sh`.

## The notes

| Note | What it covers |
|---|---|
| [Terminal Toolkit](Terminal-Toolkit.md) | Index and suggested install order |
| [Setup Inventory](Setup-Inventory.md) | Full parts list to reproduce the setup |
| [Zsh Setup Reference](Zsh-Setup-Reference.md) | The active zsh config and PATH |
| [Shell Power Layer](Shell-Power-Layer.md) | fzf, fd, atuin |
| [Git & Dev Flow](Git-and-Dev-Flow.md) | delta, lazygit, just |
| [Data Investigation CLI](Data-Investigation-CLI.md) | duckdb, visidata, s5cmd |
| [Inspecting Kubeflow Pods](Inspecting-Kubeflow-Pods.md) | kubectl, k9s, stern |
| [Switching Contexts](Switching-Contexts-Optional.md) | kubectx, kubens |
| [Ghostty Hands-On](Ghostty-Hands-On-Intro.md) · [Config Starter](Ghostty-Config-Starter.md) | The terminal emulator |
