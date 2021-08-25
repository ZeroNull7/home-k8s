    velero install \
    --provider azure \
    --plugins velero/velero-plugin-for-microsoft-azure:v1.2.0 \
    --bucket velero \
    --secret-file ./credentials-velero \
    --backup-location-config resourceGroup=home,storageAccount=store1101d933164a,subscriptionId=4f581ec4-a0a0-4a9b-8e53-f001db85a611 \
    --use-volume-snapshots false
