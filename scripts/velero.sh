export BACKUP_RESOURCE_GROUP=home
export BACKUP_STORAGE_ACCOUNT_NAME=store811d48e4fca8
velero install --provider azure \
    --plugins velero/velero-plugin-for-microsoft-azure:v1.2.0 \
    --bucket velero \
    --secret-file ./credentials-velero \
    --backup-location-config resourceGroup=$BACKUP_RESOURCE_GROUP,storageAccount=$BACKUP_STORAGE_ACCOUNT_NAME \
    --snapshot-location-config apiTimeout=5m,resourceGroup=$BACKUP_RESOURCE_GROUP,incremental=true \
    --use-restic \
    --wait

velero schedule create unifi-controller --ttl 3600h0m0s --schedule="@every 24h" -l app=unifi-controller
velero schedule create postgres --ttl 3600h0m0s --schedule="@every 24h" -l app=postgres
