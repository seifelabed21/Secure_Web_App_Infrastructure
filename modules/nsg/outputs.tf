output "nsg_ids" {
	description = "NSG IDs keyed by role"
	value = {
		gateway     = azurerm_network_security_group.gateway_nsg.id
		web         = azurerm_network_security_group.web_nsg.id
		app_gateway = azurerm_network_security_group.app_gateway_nsg.id
		runner      = azurerm_network_security_group.runner_nsg.id
	}
}

output "nsg_names" {
	description = "NSG names keyed by role"
	value = {
		gateway     = azurerm_network_security_group.gateway_nsg.name
		web         = azurerm_network_security_group.web_nsg.name
		app_gateway = azurerm_network_security_group.app_gateway_nsg.name
		runner      = azurerm_network_security_group.runner_nsg.name
	}
}
