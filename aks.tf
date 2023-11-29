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