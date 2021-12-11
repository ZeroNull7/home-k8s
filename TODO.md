self-link
vi /etc/kubernetes/manifests/kube-apiserver.yaml
spec:
  containers:
  - command:
    - kube-apiserver
    - --feature-gates=RemoveSelfLink=false

---
Metallb

# see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system


-----
https://stackoverflow.com/questions/65901186/kube-prometheus-stack-issue-scraping-metrics/66276144#66276144

prometheus needs etc secrets
kubectl --kubeconfig /etc/kubernetes/admin.conf -n monitoring create secret generic etcd-client-cert --from-file=/etc/kubernetes/pki/etcd/ca.crt --from-file=/etc/kubernetes/pki/etcd/healthcheck-client.crt --from-file=/etc/kubernetes/pki/etcd/healthcheck-client.key

controller manager 
$ sudo vi /etc/kubernetes/manifests/kube-controller-manager.yaml
apiVersion: v1
kind: Pod
metadata:
  ...
spec:
  containers:
  - command:
    - kube-controller-manager
    ...
    - --bind-address=<your control-plane IP or 0.0.0.0>

----x
restore from velero

To close this out, the following should work for backing-up and restoring a specific workload using velero in a gitops (flux) environment:

Create a backup using a label selector (that's present on the deployment, pv, & pvc) for the application, e.g. velero backup create test-minecraft --selector "app=mc-test-minecraft" --wait
<Do whatever action results in the active data getting lost (e.g. kubectl delete hr mc-test)>
Delete the unwanted new data & associate Deployment/StatefulSet/Daemonset, e.g. kubectl delete deployment mc-test-minecraft && kubectl delete pvc mc-test-minecraft-datadir
Restore from restic the backup with only the label selector, e.g. velero restore create --from-backup test-minecraft --selector "app=mc-test-minecraft" --wait
Profit!
This should not interfere with the HelmRelease or require scaling helm-operator
You don't need to worry about adding labels to the HelmRelease or backing-up the helm secret object

----

kubectl edit cm/kube-proxy -n kube-system

...
kind: KubeProxyConfiguration
metricsBindAddress: 0.0.0.0:10249
...

$ kubectl delete pod -l k8s-app=kube-proxy -n kube-system

----
sudo vi /etc/kubernetes/manifests/kube-scheduler.yaml
    - --bind-address=0.0.0.0

-- SOPS SECRETS ---
gpg --export-secret-keys --armor "9DC11809DD7D102342B09932C40921F65EFEF866" | kubectl create secret generic sops-gpg --namespace=istio-operator --from-file=sops.asc=/dev/stdin
gpg --export-secret-keys --armor "9DC11809DD7D102342B09932C40921F65EFEF866" | kubectl create secret generic sops-gpg --namespace=istio-system --from-file=sops.asc=/dev/stdin
gpg --export-secret-keys --armor "9DC11809DD7D102342B09932C40921F65EFEF866" | kubectl create secret generic sops-gpg --namespace=infra --from-file=sops.asc=/dev/stdin
gpg --export-secret-keys --armor "9DC11809DD7D102342B09932C40921F65EFEF866" | kubectl create secret generic sops-gpg --namespace=apps --from-file=sops.asc=/dev/stdin

-- VELERO INSTALL 
export BACKUP_RESOURCE_GROUP=home
export BACKUP_STORAGE_ACCOUNT_NAME=store811d48e4fca8
velero install --provider azure --plugins velero/velero-plugin-for-microsoft-azure:v1.2.0 --bucket velero --secret-file ./credentials-velero --backup-location-config resourceGroup=$BACKUP_RESOURCE_GROUP,storageAccount=$BACKUP_STORAGE_ACCOUNT_NAME --snapshot-location-config apiTimeout=5m,resourceGroup=$BACKUP_RESOURCE_GROUP,incremental=true --wait


----
List all resources 
    kubectl api-resources --verbs=list --namespaced -o name   | xargs -n 1 kubectl get --show-kind --ignore-not-found -n istio-system
