variable "prefix" {
  description = "A prefix used for all resources in this example"
}

variable "location_1" {
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "location_2" {
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "location_3" {
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "location_1_vnet_address_space" {
  description = "The Azure VNET address space for first location"
  default = ["10.1.0.0/16"]
}

variable "location_2_vnet_address_space" {
  description = "The Azure VNET address space for second location"
  default = ["10.2.0.0/16"]
}

variable "location_3_vnet_address_space" {
  description = "The Azure VNET address space for third location"
  default = ["10.3.0.0/16"]
}

variable "location_1_aks_subnet" {
  description = "The Azure VNET address space for first location"
  default = ["10.1.0.0/22"]
}

variable "location_2_aks_subnet" {
  description = "The Azure VNET address space for second location"
  default = ["10.2.0.0/22"]
}

variable "location_3_aks_subnet" {
  description = "The Azure VNET address space for third location"
  default = ["10.3.0.0/22"]
}

variable "aks_pool_name" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = "nodepool"
}

variable "aks_vm_size" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = "Standard_D8s_v3"
}

variable "aks_node_count" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = 3
}

variable "cockroachdb_version" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = "v23.2.3"
}

variable "cockroachdb_pod_cpu" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = "4"
}

variable "cockroachdb_pod_memory" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = "8Gi"
}

variable "cockroachdb_storage" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = "50Gi"
}

variable "statfulset_replicas" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = 3
}