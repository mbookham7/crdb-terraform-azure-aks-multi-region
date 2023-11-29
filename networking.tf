### Creation of VNET in three regions with a single subnet.

resource "azurerm_resource_group" "mb-crdb-multi-region" {
  name     = "${var.prefix}-k8s-resources"
  location = var.location_1
}

resource "azurerm_virtual_network" "region_1" {
  name                = "${var.prefix}-${var.location_1}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "internal-region_1" {
  name                 = "internal-region_1"
  virtual_network_name = azurerm_virtual_network.region_1.name
  resource_group_name  = azurerm_resource_group.mb-crdb-multi-region.name
  address_prefixes     = ["10.1.0.0/22"]
}

resource "azurerm_virtual_network" "region_2" {
  name                = "${var.prefix}-${var.location_2}"
  location            = var.location_2
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "internal-region_2" {
  name                 = "internal-region_2"
  virtual_network_name = azurerm_virtual_network.region_2.name
  resource_group_name  = azurerm_resource_group.mb-crdb-multi-region.name
  address_prefixes     = ["10.2.0.0/22"]
}

resource "azurerm_virtual_network" "region_3" {
  name                = "${var.prefix}-${var.location_3}"
  location            = var.location_3
  resource_group_name = azurerm_resource_group.mb-crdb-multi-region.name
  address_space       = ["10.3.0.0/16"]
}

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