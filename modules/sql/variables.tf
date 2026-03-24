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
	description = "Project name used for SQL resource naming"
}

variable "database_name" {
	type        = string
	description = "SQL database name"
	default     = "appdb"
}

variable "database_sku_name" {
	type        = string
	description = "Azure SQL database SKU"
	default     = "S0"
}

variable "database_max_size_gb" {
	type        = number
	description = "Azure SQL database max size in GB"
	default     = 5
}

variable "administrator_login" {
	type        = string
	description = "SQL administrator login"
	default     = "sqladminuser"
}

variable "administrator_login_password" {
	type        = string
	description = "SQL administrator password"
	sensitive   = true
	default     = "P@ssw0rd1234!ChangeMe"
}

variable "sql_allowed_subnet_ids" {
	type        = map(string)
	description = "Subnet IDs allowed to access SQL via service endpoints"
	default     = {}
}

variable "tags" {
	type        = map(string)
	description = "Tags for the resources"
	default     = {}
}
