# 🔁 Switching Clusters & Namespaces (optional) — kubectx · kubens

> [!info] Auto-detected
> - **kubectl** client `v1.32.13`, kubeconfig present (`~/.kube`)
> - Optional add-on to [[Inspecting-Kubeflow-Pods]] — only worth it if you regularly hop between **multiple clusters or namespaces**
> - Best paired with `fzf` from [[Shell-Power-Layer]] (adds interactive pickers)

If you only ever touch one cluster and one namespace, skip this — `kubectl config set-context --current --namespace=...` (in [[Inspecting-Kubeflow-Pods]]) is enough. If you juggle several, `kubectx`/`kubens` make switching a one-word command.

**Install:**

```sh
sudo apt install kubectx
```

This gives you two commands: `kubectx` (switch **cluster/context**) and `kubens` (switch **namespace**).

| Command | What it does |
|---|---|
| `kubectx` | List contexts (fuzzy picker if `fzf` is installed) |
| `kubectx <name>` | Switch to that context |
| `kubectx -` | Toggle back to the previous context |
| `kubectx short=very-long-arn-name` | Give an unwieldy context a short alias |
| `kubens` | List namespaces (fuzzy picker with `fzf`) |
| `kubens <ns>` | Switch default namespace |
| `kubens -` | Toggle back to the previous namespace |

> [!tip] With fzf, just run them bare
> Once `fzf` is in place ([[Shell-Power-Layer]]), a bare `kubectx` or `kubens` opens an interactive fuzzy list — type a fragment, `enter`, done. No need to remember exact names.

- [ ] `kubectx` to see your clusters, switch to one, then `kubectx -` to jump back
- [ ] `kubens <your-kubeflow-ns>` so subsequent `kubectl`/`k9s`/`stern` commands default to it

After switching, everything in [[Inspecting-Kubeflow-Pods]] (`kubectl`, `k9s`, `stern`) targets the new context/namespace automatically.

---

Back to [[Inspecting-Kubeflow-Pods]] · index [[Terminal-Toolkit]]
