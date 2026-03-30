output "application_gateway_id" {
	description = "ID of the Application Gateway"
	value       = azurerm_application_gateway.appgw.id
}

output "application_gateway_name" {
	description = "Name of the Application Gateway"
	value       = azurerm_application_gateway.appgw.name
}

output "public_ip_id" {
	description = "ID of the Application Gateway public IP"
	value       = azurerm_public_ip.appgw_pip.id
}

output "public_ip_address" {
	description = "Public IP address of the Application Gateway"
	value       = azurerm_public_ip.appgw_pip.ip_address
}

output "frontend_fqdn" {
	description = "FQDN of the Application Gateway public endpoint"
	value       = azurerm_public_ip.appgw_pip.fqdn
}

output "https_url" {
	description = "HTTPS URL exposed by Application Gateway"
	value       = "https://${azurerm_public_ip.appgw_pip.ip_address}"
}

output "certificate_secret_id" {
	description = "Key Vault secret ID used by the HTTPS listener certificate"
	value       = local.use_custom_certificate ? azurerm_key_vault_certificate.appgw_custom_cert[0].secret_id : azurerm_key_vault_certificate.appgw_self_signed_cert[0].secret_id
}
