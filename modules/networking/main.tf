# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# Gateway Subnet
resource "azurerm_subnet" "gateway_snet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.255.224/27"]
}

# Web Tier Subnet
resource "azurerm_subnet" "web_snet" {
  name                 = "web_snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

# Application Gateway Subnet
resource "azurerm_subnet" "app_gateway_snet" {
  name                 = "app_gateway_snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

# GitHub self-hosted runner subnet
resource "azurerm_subnet" "runner_snet" {
  name                 = "runner_snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.runner_subnet_cidr]
}