output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.vpn_gw.id
}

output "vpn_gateway_name" {
  description = "Name of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.vpn_gw.name
}

output "vpn_public_ip_id" {
  description = "ID of the VPN Gateway public IP"
  value       = azurerm_public_ip.vpn_pip.id
}

output "vpn_public_ip_address" {
  description = "Public IP address of the VPN Gateway"
  value       = azurerm_public_ip.vpn_pip.ip_address
}

output "vpn_connection_id" {
  description = "ID of the Site-to-Site VPN connection"
  value       = azurerm_virtual_network_gateway_connection.s2s.id
}

output "vpn_connection_name" {
  description = "Name of the Site-to-Site VPN connection"
  value       = azurerm_virtual_network_gateway_connection.s2s.name
}