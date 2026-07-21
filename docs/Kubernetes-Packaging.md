# 📦 Kubernetes Packaging

You consume Helm charts and Kustomize overlays to feed your ML pipelines, so your day-to-day is rendering and diffing manifests before anything touches a cluster. This note covers the two tools you reach for most, with an inspect-first bias.

## helm — Kubernetes package manager (charts)

Helm packages Kubernetes resources into versioned, parameterized charts, which lets you pull a maintained chart (say a model server or a pipeline component) and render it with your own values instead of hand-writing YAML. Installed by the repo's `setup.sh`.

```sh
# Add a chart repo and refresh your local index
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Find a chart and inspect its configurable values
helm search repo bitnami/redis
helm show values bitnami/redis > values.yaml

# Render the chart to plain manifests WITHOUT touching a cluster (inspect first)
helm template my-redis bitnami/redis -f values.yaml

# Preview an upgrade as a dry run before applying
helm upgrade --install my-redis bitnami/redis -f values.yaml --dry-run
```

> [!tip] `helm template` renders locally and needs no cluster connection, so it is the safe way to review exactly what a chart produces. Pipe it to `kubectl diff -f -` when you do have cluster access to see what would actually change.

Docs: [Helm docs](https://helm.sh/docs/)

## kustomize — template-free manifest customization via overlays

Kustomize layers patches over a base set of manifests, so you can adapt a pipeline's YAML per environment (dev, staging, prod) without templating or forking the originals. Installed by the repo's `setup.sh`.

```sh
# Render an overlay to final manifests so you can read what will be applied
kustomize build overlays/dev

# Inspect a base and a specific overlay side by side
kustomize build base
kustomize build overlays/prod

# Edit a kustomization from the CLI instead of hand-editing YAML
kustomize edit set image myapp=myapp:1.4.2
kustomize edit set namespace ml-pipelines

# Let kubectl render and apply the overlay in one step (-k = kustomize)
kubectl apply -k overlays/dev
```

> [!tip] `kubectl apply -k <dir>` and `kustomize build <dir> | kubectl apply -f -` produce the same result, but running `kustomize build` on its own first lets you eyeball the merged output before you apply it.

Docs: [kustomize docs](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)

See also: [[Terminal-Toolkit]] (index) · [[Inspecting-Kubeflow-Pods]]
