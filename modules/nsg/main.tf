locals {
  nsg_ids_by_role = {
    web         = azurerm_network_security_group.web_nsg.id
    app_gateway = azurerm_network_security_group.app_gateway_nsg.id
    runner      = azurerm_network_security_group.runner_nsg.id
  }
}

# Gateway subnet NSG (VPN gateway ingress from on-prem)
resource "azurerm_network_security_group" "gateway_nsg" {
  name                = "gateway_nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-ike-from-onprem"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500"
    source_address_prefix      = var.onprem_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-nat-t-from-onprem"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4500"
    source_address_prefix      = var.onprem_cidr
    destination_address_prefix = "*"
  }
}

# Application Gateway subnet NSG (public web ingress)
resource "azurerm_network_security_group" "app_gateway_nsg" {
  name                = "app_gateway_nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-http-from-internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https-from-internet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-gateway-manager"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-azure-load-balancer"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

# Web tier NSG (traffic from App Gateway subnet)
resource "azurerm_network_security_group" "web_nsg" {
  name                = "web_nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-http-from-appgw"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.app_gateway_subnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https-from-appgw"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.app_gateway_subnet_cidr
    destination_address_prefix = "*"
  }

}

# Runner subnet NSG (SSH only from on-prem over VPN)
resource "azurerm_network_security_group" "runner_nsg" {
  name                = "runner_nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-ssh-from-onprem"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.onprem_cidr
    destination_address_prefix = "*"
  }
}

# Associate NSGs with subnets when subnet IDs are passed from networking module.
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = {
    for role, subnet_id in var.subnet_ids : role => subnet_id
    if contains(keys(local.nsg_ids_by_role), role)
  }

  subnet_id                 = each.value
  network_security_group_id = local.nsg_ids_by_role[each.key]
}