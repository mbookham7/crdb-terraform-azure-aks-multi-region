az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name_region_1)

az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name_region_2)

az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name_region_3)


```
kubectl config use-context mb-crdb-mr-k8s-uksouth
kubectl create -f https://raw.githubusercontent.com/cockroachdb/cockroach/master/cloud/kubernetes/multiregion/client-secure.yaml --namespace uksouth
```

```
kubectl exec -it cockroachdb-client-secure -n uksouth --context mb-crdb-mr-k8s-uksouth -- ./cockroach sql --certs-dir=/cockroach-certs --host=cockroachdb-public
```

```
CREATE USER craig WITH PASSWORD 'cockroach';
GRANT admin TO craig;
```