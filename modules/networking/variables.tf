variable "project_name" {
  type        = string
  description = "The project name used as naming prefix"
}

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
  description = "Address space for the virtual network"
}

variable "runner_subnet_cidr" {
  type        = string
  description = "CIDR for the GitHub self-hosted runner subnet"
  default     = "10.0.4.0/24"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
  default     = {}
}