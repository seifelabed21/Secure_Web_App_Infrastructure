# core/variables.tf

variable "resource_group_name" {
  type        = string
  description = "The resource group name"
}

variable "resource_group_id" {
  type        = string
  description = "The resource group id"
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

variable "onprem_cidr" {
  type        = string
  description = "On-premises network CIDR"
  default     = "192.168.0.0/16"
}

variable "gateway_subnet_cidr" {
  type        = string
  description = "Gateway subnet CIDR"
  default     = "10.0.255.224/27"
}

variable "web_subnet_cidr" {
  type        = string
  description = "Web tier subnet CIDR"
  default     = "10.0.1.0/24"
}

variable "app_gateway_subnet_cidr" {
  type        = string
  description = "Application Gateway subnet CIDR"
  default     = "10.0.3.0/24"
}

variable "subnet_ids" {
  type        = map(string)
  description = "Subnet IDs keyed by role (gateway, web, app_gateway)"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
  default     = {}
}
