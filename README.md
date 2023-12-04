# CockroachDB  - Terraform Managed Azure AKS Multi-region Database

This repo is the Terraform code to deploy a single CockroachDB Cluster into three AKS clusters into three separate regions.

1. Update the `tfvars` file with you required settings prior to deploying your infrastructure.

```
location_1 = "uksouth"
location_2 = "ukwest"
location_3 = "northeurope"
prefix = "mb-crdb-mr"
```

2. To initialize the code you need to run the `terraform init` command. The `terraform init` command initializes a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times.

```
terraform init
```

3. The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. By default, when Terraform creates a plan it:

- Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
- Compares the current configuration to the prior state and noting any differences.
- Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

```
terraform plan
```

4. The `terraform apply`` command executes the actions proposed in a Terraform plan.

```
terraform apply --auto-approve
```

5. When you have deployed your infrastructure you can add the three AKS clusters to your local `KUBECONFIG` file. Once you have done this you will be able to communicate with your clusters via `kubectl`

```
az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name_region_1)

az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name_region_2)

az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name_region_3)
```

6. To be able to log on to the UI we need to create a user. To do this we need to deploy a pod with the cockroach binary and connect to our Cockroach cluster and add a user. First we deploy a pod into the correct namespace.

```
kubectl config use-context $(terraform output -raw kubernetes_cluster_name_region_1)
kubectl create -f https://raw.githubusercontent.com/cockroachdb/cockroach/master/cloud/kubernetes/multiregion/client-secure.yaml --namespace $(terraform output -raw crdb_namespace_region_1)
```

7. Now we connect to the pod.

```
kubectl exec -it cockroachdb-client-secure -n $(terraform output -raw crdb_namespace_region_1) --context $(terraform output -raw kubernetes_cluster_name_region_1) -- ./cockroach sql --certs-dir=/cockroach-certs --host=cockroachdb-public
```

8. Create a user and grand admin to that user.

```
CREATE USER craig WITH PASSWORD 'cockroach';
GRANT admin TO craig;
```


9. The terraform destroy command is a convenient way to destroy all remote objects managed by a particular Terraform configuration.

While you will typically not want to destroy long-lived objects in a production environment, Terraform is sometimes used to manage ephemeral infrastructure for development purposes, in which case you can use terraform destroy to conveniently clean up all of those temporary objects once you are finished with your work.

```
terraform destroy
```