output "runner_vm_id" {
  description = "ID of the GitHub runner VM"
  value       = azurerm_linux_virtual_machine.runner_vm.id
}

output "runner_vm_name" {
  description = "Name of the GitHub runner VM"
  value       = azurerm_linux_virtual_machine.runner_vm.name
}

output "runner_private_ip" {
  description = "Private IP address of the runner VM"
  value       = azurerm_network_interface.runner_nic.private_ip_address
}
