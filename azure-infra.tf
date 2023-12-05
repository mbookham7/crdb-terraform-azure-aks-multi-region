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
  address_space       = ["10.1.0.0/16"]
}

# Create subnet in first region

resource "azurerm_subnet" "internal-region_1" {
  name                 = "internal-region_1"
  virtual_network_name = azurerm_virtual_network.region_1.name
  resource_group_name  = azurerm_resource_group.mb-crdb-multi-region.name
  address_prefixes     = ["10.1.0.0/22"]
}

# Create VNET in second region

resource "azurerm_virtual_network" "region_2" {
  name                = "${var.prefix}-${var.location_2}"
  location            = var.location_2
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  address_space       = ["10.2.0.0/16"]
}

# Create subnet in first region

resource "azurerm_subnet" "internal-region_2" {
  name                 = "internal-region_2"
  virtual_network_name = azurerm_virtual_network.region_2.name
  resource_group_name  = azurerm_resource_group.mb-crdb-multi-region.name
  address_prefixes     = ["10.2.0.0/22"]
}

# Create VNET in thrid region

resource "azurerm_virtual_network" "region_3" {
  name                = "${var.prefix}-${var.location_3}"
  location            = var.location_3
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  address_space       = ["10.3.0.0/16"]
}

# Create subnet in third region

resource "azurerm_subnet" "internal-region_3" {
  name                 = "internal-region_3"
  virtual_network_name = azurerm_virtual_network.region_3.name
  resource_group_name  = azurerm_resource_group.mb-crdb-multi-region.name
  address_prefixes     = ["10.3.0.0/22"]
}

### Create VNET Peers between each of the three VNETs

# Regions 1 and Region 2 Peer
resource "azurerm_virtual_network_peering" "peer1to2" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_1.name
  remote_virtual_network_id = azurerm_virtual_network.region_2.id
}

resource "azurerm_virtual_network_peering" "peer2to1" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_2.name
  remote_virtual_network_id = azurerm_virtual_network.region_1.id
}

### Region 2 and Region 3 Peer
resource "azurerm_virtual_network_peering" "peer2to3" {
  name                      = "peer2to3"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_2.name
  remote_virtual_network_id = azurerm_virtual_network.region_3.id
}

resource "azurerm_virtual_network_peering" "peer3to2" {
  name                      = "peer3to2"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_3.name
  remote_virtual_network_id = azurerm_virtual_network.region_2.id
}

### Region 1 and Region 3 Peer
resource "azurerm_virtual_network_peering" "peer1to3" {
  name                      = "peer1to3"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_1.name
  remote_virtual_network_id = azurerm_virtual_network.region_3.id
}

resource "azurerm_virtual_network_peering" "peer3to1" {
  name                      = "peer3to1"
  resource_group_name       = azurerm_resource_group.mb-crdb-multi-region.name
  virtual_network_name      = azurerm_virtual_network.region_3.name
  remote_virtual_network_id = azurerm_virtual_network.region_1.id
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
    name           = "system"
    node_count     = 3
    vm_size        = "Standard_D8s_v3"
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
    name           = "system"
    node_count     = 3
    vm_size        = "Standard_D8s_v3"
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
    name           = "system"
    node_count     = 3
    vm_size        = "Standard_D8s_v3"
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