# 🧊 Inspecting Kubeflow Pods — kubectl · k9s · stern

> [!info] Your setup (auto-detected)
> - **kubectl** client `v1.32.13`, kubeconfig present (`~/.kube`)
> - Framing: you *investigate* the Pods that run your Kubeflow pipeline steps — you're not administering the cluster
> - Companion to [[Data-Investigation-CLI]] and [[Terminal-Toolkit]].

A Kubeflow pipeline step runs as a **Pod** (usually an init container to fetch inputs, plus your main training/processing container). When a step is slow, stuck, or failing, you almost always need just five things: find the pod, read its logs, describe it, exec in, and check events.

---

## 1. kubectl — the five moves that matter

Set your namespace once so you can drop `-n` from every command:

```sh
kubectl config set-context --current --namespace=<your-kubeflow-ns>
kubectl config current-context          # confirm which cluster you're on
```

| Goal                                       | Command                                         |
| ------------------------------------------ | ----------------------------------------------- |
| List pods, live-updating                   | `kubectl get pods -w`                           |
| Filter to one run (by label)               | `kubectl get pods -l <pipeline-label>=<run-id>` |
| Stream logs                                | `kubectl logs -f <pod>`                         |
| Logs from a **crashed** previous container | `kubectl logs --previous <pod>`                 |
| Logs from a specific container             | `kubectl logs <pod> -c <container>`             |
| Why is it Pending/CrashLoop?               | `kubectl describe pod <pod>`                    |
| Recent cluster events                      | `kubectl get events --sort-by=.lastTimestamp`   |
| Shell into the running pod                 | `kubectl exec -it <pod> -- bash`                |
| Copy a file out (e.g. a checkpoint)        | `kubectl cp <pod>:/path/model.pt ./model.pt`    |
| Resource usage right now                   | `kubectl top pod <pod>`                         |

- [ ] `kubectl describe pod <pod>` on a pending step and read the **Events** section at the bottom — that's where scheduling/image/quota failures show up

> [!tip] The status tells you where to look
> `Pending` → describe it (scheduling/quota/PVC). `CrashLoopBackOff` → `logs --previous`. `ImagePullBackOff` → describe, check the image name/registry auth.

---

## 2. k9s — a TUI cockpit for the cluster

Navigate namespaces, pods, logs, describe, and exec without memorizing flags. Far faster than repeated `kubectl` for investigation.

**Install** (not in apt — official `.deb`):

```sh
curl -sL https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb -o /tmp/k9s.deb
sudo apt install -y /tmp/k9s.deb
```

Launch:

```sh
k9s
```

| Key | Action |
|---|---|
| `:` then `pods` / `ns` / `deploy` | Jump to any resource type |
| `/` | Filter the current list |
| `l` | Logs for the selected pod |
| `d` | Describe |
| `y` | View YAML |
| `s` | Shell into the pod |
| `esc` | Back out |
| `?` | Help / all keybinds |

- [ ] Open `k9s`, `:pods`, filter to a run with `/`, press `l` to read logs, `d` to describe

---

## 3. stern — tail logs across every pod of a run at once

A Kubeflow step can spread across several pods. `stern` tails them all together, color-coded per pod, with no juggling of names.

**Install** (not in apt — you have Go `1.22`):

```sh
go install github.com/stern/stern@latest      # lands in ~/go/bin (ensure it's on PATH)
```

Prefer no build? Grab a binary from `github.com/stern/stern/releases`.

```sh
stern <run-name-prefix>                 # tail all pods whose name matches
stern -l <pipeline-label>=<run-id>      # tail by label selector
stern <prefix> --since 15m              # only the last 15 minutes
stern <prefix> -c main                  # only the "main" container
stern <prefix> --tail 100               # last 100 lines per pod, then follow
```

- [ ] `stern` a pipeline run prefix and watch interleaved, color-coded logs from all its pods

---

## 4. Is the GPU actually being used?

If a training step looks idle, check the GPU **inside** the pod:

```sh
kubectl exec -it <pod> -- nvidia-smi
```

Zero utilization usually means the job is stuck in data loading or hasn't reached the GPU yet. For local GPU monitoring, see the `nvtop`/`nvitop` section in [[Shell-Power-Layer]].

---

## kubecolor — colorized kubectl output

kubecolor wraps `kubectl` and colorizes its output so pod states, namespaces, and columns are easier to scan while you triage. You use it exactly like `kubectl`, and this repo's `~/.zshrc` already aliases `kubectl=kubecolor` when it is present. Installed by the repo's `setup.sh`.

```sh
# List pods with colorized STATUS and READY columns
kubecolor get pods -n kubeflow

# Watch pods refresh in place, still colorized
kubecolor get pods -n kubeflow -w

# Inspect a single pod, events and conditions stand out
kubecolor describe pod ml-pipeline-0 -n kubeflow

# Wide output with node and IP, colors intact
kubecolor get pods -n kubeflow -o wide

# Force colors when piping into a pager
kubecolor --force-colors get pods -n kubeflow | less -R
```

> [!tip] kubecolor auto-detects pipes and non-TTY output and passes kubectl's text through uncolored, so scripts and `| jq`, `| grep`, `| awk` keep working unchanged. When you do want color through a pipe (for example into `less -R`), add `kubecolor --force-colors`.

Docs: [kubecolor docs](https://kubecolor.github.io/)

---

**Next:** back to index [[Terminal-Toolkit]] · related: [[Data-Investigation-CLI]] · [[Kubernetes-Packaging]] · [[Switching-Contexts-Optional]]
