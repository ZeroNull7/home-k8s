#!/bin/bash
kubectl create namespace infra
gpg --export-secret-keys --armor "9DC11809DD7D102342B09932C40921F65EFEF866" | kubectl create secret generic sops-gpg --namespace=infra --from-file=sops.asc=/dev/stdin
/usr/local/bin/flux bootstrap github \
          --owner=ZeroNull7 \
          --repository=home-k8s \
          --path=cluster \
	  --branch=main \
          --personal
