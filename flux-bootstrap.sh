#!/bin/bash
kubectl create namespace flux-system
gpg --export-secret-keys --armor "9DC11809DD7D102342B09932C40921F65EFEF866" | kubectl create secret generic sops-gpg --namespace=flux-system --from-file=sops.asc=/dev/stdin

flux create source git home-k8s \
    --url=ssh://git@github.com/ZeroNull7/home-k8s.git \
    --branch=main \
    --interval=1m

flux create kustomization base \
        --source=GitRepository/home-k8s \
        --path="./overlays/prod/base/sources" \
        --prune=true \
        --interval=5m


flux create kustomization infra \
      --source=GitRepository/home-k8s \
      --path="./overlays/prod/infra/sources" \
      --prune=true \
      --interval=5m