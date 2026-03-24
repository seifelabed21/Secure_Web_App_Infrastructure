variable "project_name" {
  # Name prefix for all resources
  description = "PFA Infrastructure"
  type        = string
  default     = "pfa_infra"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "francecentral"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "address_space" {
  description = "Address space for the main virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subscription_id" {
  description = "Optional Azure subscription override. Leave null to use az login context."
  type        = string
  default     = null
}

variable "tenant_id" {
  description = "Optional Azure tenant override. Leave null to use az login context."
  type        = string
  default     = null
}

variable "tags" {
  description = "Default tags for governance and cost tracking"
  type        = map(string)
  default = {
    environment = "dev"
    owner       = "student"
    project     = "pfa-network"
  }
}

variable "vm_admin_ssh_public_key" {
  description = "SSH public key for app_service VM (required)."
  type        = string

  validation {
    condition     = length(trimspace(var.vm_admin_ssh_public_key)) > 0
    error_message = "vm_admin_ssh_public_key must be set to a non-empty OpenSSH public key."
  }
}

variable "runner_admin_username" {
  description = "Admin username for the GitHub runner VM"
  type        = string
  default     = "azureuser"
}

variable "runner_vm_size" {
  description = "VM size for the GitHub self-hosted runner"
  type        = string
  default     = "Standard_B2as_v2"
}

variable "github_repo_url" {
  description = "GitHub repository URL used to register the self-hosted runner"
  type        = string
  default     = "https://github.com/seifelabed21/Secure_Web_App_Infrastructure"
}

variable "runner_registration_token" {
  description = "Short-lived GitHub self-hosted runner registration token. Leave empty to register manually later."
  type        = string
  default     = ""
  sensitive   = true
}