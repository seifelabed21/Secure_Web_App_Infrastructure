resource "azurerm_public_ip" "vpn_pip" {
  name                = "${var.project_name}-vpn-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vpn_gw" {
  name                = "${var.project_name}-vpn-gw"
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = var.vpn_gateway_sku
  tags                = var.tags

  ip_configuration {
    name                          = "vnet-gateway-config"
    public_ip_address_id          = azurerm_public_ip.vpn_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
}

resource "azurerm_virtual_network_gateway_connection" "s2s" {
  name                = "${var.project_name}-s2s-connection"
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = "IPsec"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vpn_gw.id
  local_network_gateway_id        = azurerm_local_network_gateway.onprem.id
  shared_key                      = var.vpn_shared_key
  tags                            = var.tags

  ipsec_policy {
    dh_group         = "DHGroup14"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "PFS2048"
  }
}

resource "azurerm_local_network_gateway" "onprem" {
  name                = "${var.project_name}-onprem-gw"
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.onprem_gateway_ip
  address_space       = var.onprem_address_space
  tags                = var.tags
}

