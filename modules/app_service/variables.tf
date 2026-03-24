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

variable "web_subnet_id" {
  type        = string
  description = "Subnet ID dedicated to the web VM"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size for hosting the web application"
  default     = "Standard_B2as_v2"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the Linux VM"
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key for VM login (required)."

  validation {
    condition     = length(trimspace(var.admin_ssh_public_key)) > 0
    error_message = "admin_ssh_public_key must be set to a non-empty OpenSSH public key."
  }
}

variable "aspnet_runtime_version" {
  type        = string
  description = "ASP.NET Core runtime major.minor version to install on the VM"
  default     = "8.0"
}

variable "aspnet_app_port" {
  type        = number
  description = "Local port where the ASP.NET Core app listens behind Nginx"
  default     = 5000
}

variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
  default     = {}
}
