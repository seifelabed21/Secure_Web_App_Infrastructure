output "vnet_id" {
	description = "ID of the virtual network"
	value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
	description = "Name of the virtual network"
	value       = azurerm_virtual_network.vnet.name
}

output "gateway_subnet_id" {
	description = "ID of the gateway subnet"
	value       = azurerm_subnet.gateway_snet.id
}

output "gateway_subnet_name" {
	description = "Name of the gateway subnet"
	value       = azurerm_subnet.gateway_snet.name
}

output "web_subnet_id" {
	description = "ID of the web tier subnet"
	value       = azurerm_subnet.web_snet.id
}

output "web_subnet_name" {
	description = "Name of the web tier subnet"
	value       = azurerm_subnet.web_snet.name
}

output "app_gateway_subnet_id" {
	description = "ID of the application gateway subnet"
	value       = azurerm_subnet.app_gateway_snet.id
}

output "app_gateway_subnet_name" {
	description = "Name of the application gateway subnet"
	value       = azurerm_subnet.app_gateway_snet.name
}

output "runner_subnet_id" {
	description = "ID of the GitHub runner subnet"
	value       = azurerm_subnet.runner_snet.id
}

output "runner_subnet_name" {
	description = "Name of the GitHub runner subnet"
	value       = azurerm_subnet.runner_snet.name
}

output "subnet_ids" {
	description = "Subnet IDs keyed by logical role"
	value = {
		gateway     = azurerm_subnet.gateway_snet.id
		web         = azurerm_subnet.web_snet.id
		app_gateway = azurerm_subnet.app_gateway_snet.id
		runner      = azurerm_subnet.runner_snet.id
	}
}
