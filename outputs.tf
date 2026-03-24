output "resource_group_name" {
	description = "Resource group name"
	value       = module.rg.name
}

output "vnet_id" {
	description = "Virtual network ID"
	value       = module.networking.vnet_id
}

output "application_gateway_public_ip" {
	description = "Public IP address of the Application Gateway"
	value       = module.appgateway.public_ip_address
}

output "application_gateway_https_url" {
	description = "HTTPS endpoint exposed by the Application Gateway"
	value       = module.appgateway.https_url
}

output "web_vm_private_ip" {
	description = "Private IP address of the deployed web VM"
	value       = module.appservice.private_ip_address
}

output "runner_vm_name" {
	description = "Name of the GitHub self-hosted runner VM"
	value       = module.github_runner.runner_vm_name
}

output "runner_vm_private_ip" {
	description = "Private IP address of the GitHub self-hosted runner VM"
	value       = module.github_runner.runner_private_ip
}

output "sql_server_fqdn" {
	description = "FQDN of the SQL Server"
	value       = module.sql.sql_server_fqdn
}

output "vpn_gateway_public_ip" {
	description = "Public IP address of the VPN gateway"
	value       = module.vpngateway.vpn_public_ip_address
}
