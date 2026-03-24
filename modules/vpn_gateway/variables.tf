variable "resource_group_name" {
  type        = string
  description = "The resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "address_space" {
  type        = list(string)
  description = "Address space passed from root for shared module contract"
  default     = []
}

variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
}

variable "vnet_id" {
  type        = string
  description = "Virtual network ID for VPN gateway"
}

variable "gateway_subnet_id" {
  type        = string
  description = "Gateway subnet ID for VPN gateway"
}

variable "onprem_address_space" {
  type        = list(string)
  description = "On-premises network address space"
  default     = ["192.168.0.0/16"]
}

variable "onprem_gateway_ip" {
  type        = string
  description = "On-premises VPN gateway public IP address"
  default     = "203.0.113.1"
}

variable "vpn_shared_key" {
  type        = string
  description = "Pre-shared key for VPN connection"
  sensitive   = true
  default     = "PresharedKey123!ChangeMe"
}

variable "vpn_gateway_sku" {
  type        = string
  description = "VPN Gateway SKU"
  default     = "VpnGw1"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
  default     = {}
}
