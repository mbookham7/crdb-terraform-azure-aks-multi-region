#####################################
# Azure Infrastructure              #
#####################################

### Creation of VNET in three regions with a single subnet.

# Create a Azure Resource Group for all other resources.

resource "azurerm_resource_group" "mb-crdb-multi-region" {
  name     = "${var.prefix}-k8s-resources"
  location = var.location_1
}

# Create VNET in first region

resource "azurerm_virtual_network" "region_1" {
  name                = "${var.prefix}-${var.location_1}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  address_space       = var.location_1_vnet_address_space
}

# Create subnet in first region

resource "azurerm_subnet" "internal-region_1" {
  name                 = "internal-${var.location_1}"
  virtual_network_name = azurerm_virtual_network.region_1.name
  resource_group_name  = azurerm_resource_group.mb-crdb-multi-region.name
  address_prefixes     = var.location_1_aks_subnet
}

# Create VNET in second region

resource "azurerm_virtual_network" "region_2" {
  name                = "${var.prefix}-${var.location_2}"
  location            = var.location_2
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  address_space       = var.location_2_vnet_address_space
}

# Create subnet in second region

resource "azurerm_subnet" "internal-region_2" {
  name                 = "internal-${var.location_2}"
  virtual_network_name = azurerm_virtual_network.region_2.name
  resource_group_name  = azurerm_resource_group.mb-crdb-multi-region.name
  address_prefixes     = var.location_2_aks_subnet
}

# Create VNET in thrid region

resource "azurerm_virtual_network" "region_3" {
  name                = "${var.prefix}-${var.location_3}"
  location            = var.location_3
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  address_space       = var.location_3_vnet_address_space
}

# Create subnet in third region

resource "azurerm_subnet" "internal-region_3" {
  name                 = "internal-${var.location_3}"
  virtual_network_name = azurerm_virtual_network.region_3.name
  resource_group_name  = azurerm_resource_group.mb-crdb-multi-region.name
  address_prefixes     = var.location_3_aks_subnet
}

### Create VNET Peers between each of the three VNETs

# Regions 1 and Region 2 Peer
resource "azurerm_virtual_network_peering" "peer1to2" {
  name                      = "peer${var.location_1}to${var.location_2}"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_1.name
  remote_virtual_network_id = azurerm_virtual_network.region_2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peer2to1" {
  name                      = "peer${var.location_1}to${var.location_2}"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_2.name
  remote_virtual_network_id = azurerm_virtual_network.region_1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

### Region 2 and Region 3 Peer
resource "azurerm_virtual_network_peering" "peer2to3" {
  name                      = "peer${var.location_2}to${var.location_3}"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_2.name
  remote_virtual_network_id = azurerm_virtual_network.region_3.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peer3to2" {
  name                      = "peer${var.location_3}to${var.location_2}"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_3.name
  remote_virtual_network_id = azurerm_virtual_network.region_2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

### Region 1 and Region 3 Peer
resource "azurerm_virtual_network_peering" "peer1to3" {
  name                      = "peer${var.location_1}to${var.location_3}"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_1.name
  remote_virtual_network_id = azurerm_virtual_network.region_3.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peer3to1" {
  name                      = "peer${var.location_3}to${var.location_1}"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_3.name
  remote_virtual_network_id = azurerm_virtual_network.region_1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

### Identity
resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-cac-001"
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  location            = var.location_1
}

resource "azurerm_role_assignment" "network_contributor_region_1" {
  scope                = azurerm_virtual_network.region_1.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "network_contributor_region_2" {
  scope                = azurerm_virtual_network.region_2.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "network_contributor_region_3" {
  scope                = azurerm_virtual_network.region_3.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

### Region 1 AKS Cluster Creation
resource "azurerm_kubernetes_cluster" "aks_region_1" {
  name                = "${var.prefix}-k8s-${var.location_1}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name           = var.aks_pool_name
    node_count     = var.aks_node_count
    vm_size        = var.aks_vm_size
    vnet_subnet_id = azurerm_subnet.internal-region_1.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin = "azure"
  }
}

### Region 2 AKS Cluster Creation
resource "azurerm_kubernetes_cluster" "aks_region_2" {
  name                = "${var.prefix}-k8s-${var.location_2}"
  location            = var.location_2
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name           = var.aks_pool_name
    node_count     = var.aks_node_count
    vm_size        = var.aks_vm_size
    vnet_subnet_id = azurerm_subnet.internal-region_2.id
  }

  network_profile {
    network_plugin = "azure"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }
}

### Region 3 AKS Cluster Creation
resource "azurerm_kubernetes_cluster" "aks_region_3" {
  name                = "${var.prefix}-k8s-${var.location_3}"
  location            = var.location_3
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name           = var.aks_pool_name
    node_count     = var.aks_node_count
    vm_size        = var.aks_vm_size
    vnet_subnet_id = azurerm_subnet.internal-region_3.id
  }

  network_profile {
    network_plugin = "azure"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }
}