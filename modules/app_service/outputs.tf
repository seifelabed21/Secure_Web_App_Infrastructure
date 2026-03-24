output "vm_id" {
	description = "ID of the web hosting VM"
	value       = azurerm_linux_virtual_machine.webvm.id
}

output "vm_name" {
	description = "Name of the web hosting VM"
	value       = azurerm_linux_virtual_machine.webvm.name
}

output "private_ip_address" {
	description = "Private IP address of the web hosting VM"
	value       = azurerm_network_interface.webvm_nic.private_ip_address
}
