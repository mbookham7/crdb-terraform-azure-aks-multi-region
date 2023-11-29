### Region_1 Outputs

output "resource_group_name" {
  value = azurerm_resource_group.mb-crdb-multi-region.name
}

output "kubernetes_cluster_name_region_1" {
  value = azurerm_kubernetes_cluster.aks_region_1.name
}

output "kube_config_region_1" {
  value = azurerm_kubernetes_cluster.aks_region_1.kube_config_raw
  sensitive = true
}

output "client_certificate_region_1" {
  value     = azurerm_kubernetes_cluster.aks_region_1.kube_config[0].client_certificate
  sensitive = true
}

output "client_key_region_1" {
  value     = azurerm_kubernetes_cluster.aks_region_1.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate_region_1" {
  value     = azurerm_kubernetes_cluster.aks_region_1.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password_region_1" {
  value     = azurerm_kubernetes_cluster.aks_region_1.kube_config[0].password
  sensitive = true
}

output "cluster_username_region_1" {
  value     = azurerm_kubernetes_cluster.aks_region_1.kube_config[0].username
  sensitive = true
}

output "host_region_1" {
  value     = azurerm_kubernetes_cluster.aks_region_1.kube_config[0].host
  sensitive = true
}


### Region_2 Outputs

output "kubernetes_cluster_name_region_2" {
  value = azurerm_kubernetes_cluster.aks_region_2.name
}

output "kube_config_region_2" {
  value = azurerm_kubernetes_cluster.aks_region_2.kube_config_raw
  sensitive = true
}

output "client_certificate_region_2" {
  value     = azurerm_kubernetes_cluster.aks_region_2.kube_config[0].client_certificate
  sensitive = true
}

output "client_key_region_2" {
  value     = azurerm_kubernetes_cluster.aks_region_2.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate_region_2" {
  value     = azurerm_kubernetes_cluster.aks_region_2.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password_region_2" {
  value     = azurerm_kubernetes_cluster.aks_region_2.kube_config[0].password
  sensitive = true
}

output "cluster_username_region_2" {
  value     = azurerm_kubernetes_cluster.aks_region_2.kube_config[0].username
  sensitive = true
}

output "host_region_2" {
  value     = azurerm_kubernetes_cluster.aks_region_2.kube_config[0].host
  sensitive = true
}

### Region_3 Outputs

output "kubernetes_cluster_name_region_3" {
  value = azurerm_kubernetes_cluster.aks_region_3.name
}

output "kube_config_region_3" {
  value = azurerm_kubernetes_cluster.aks_region_3.kube_config_raw
  sensitive = true
}

output "client_certificate_region_3" {
  value     = azurerm_kubernetes_cluster.aks_region_3.kube_config[0].client_certificate
  sensitive = true
}

output "client_key_region_3" {
  value     = azurerm_kubernetes_cluster.aks_region_3.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate_region_3" {
  value     = azurerm_kubernetes_cluster.aks_region_3.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password_region_3" {
  value     = azurerm_kubernetes_cluster.aks_region_3.kube_config[0].password
  sensitive = true
}

output "cluster_username_region_3" {
  value     = azurerm_kubernetes_cluster.aks_region_3.kube_config[0].username
  sensitive = true
}

output "host_region_3" {
  value     = azurerm_kubernetes_cluster.aks_region_3.kube_config[0].host
  sensitive = true
}

# Output the External IP for use in the ConfigMap

output "kube-dns-lb_ip_region_1" {
  value     = kubernetes_service_v1.kube-dns-lb-region_1.status.0.load_balancer.0.ingress.0.ip
}

output "kube-dns-lb_ip_region_2" {
  value     = kubernetes_service_v1.kube-dns-lb-region_2.status.0.load_balancer.0.ingress.0.ip
}

output "kube-dns-lb_ip_region_3" {
  value     = kubernetes_service_v1.kube-dns-lb-region_3.status.0.load_balancer.0.ingress.0.ip
}

