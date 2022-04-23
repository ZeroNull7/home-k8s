#!/bin/bash
kubectl create namespace flux-system
kubectl create secret generic flux-git-deploy --from-file=identity=/Users/marcelo/.ssh/flux
kubectl apply -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml

kubectl create namespace infra
kubectl create namespace apps
kubectl create namespace istio-system

gpg --export-secret-keys --armor "9DC11809DD7D102342B09932C40921F65EFEF866" | kubectl create secret generic sops-gpg --namespace=flux-system --from-file=sops.asc=/dev/stdin
gpg --export-secret-keys --armor "9DC11809DD7D102342B09932C40921F65EFEF866" | kubectl create secret generic sops-gpg --namespace=istio-system --from-file=sops.asc=/dev/stdin
gpg --export-secret-keys --armor "9DC11809DD7D102342B09932C40921F65EFEF866" | kubectl create secret generic sops-gpg --namespace=infra --from-file=sops.asc=/dev/stdin
gpg --export-secret-keys --armor "9DC11809DD7D102342B09932C40921F65EFEF866" | kubectl create secret generic sops-gpg --namespace=apps --from-file=sops.asc=/dev/stdin

flux create source git home-k8s \
    --url=ssh://git@github.com/ZeroNull7/home-k8s.git \
    --branch=main \
    --interval=1m \
    --private-key-file=/Users/marcelo/.ssh/flux \
    --silent

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
