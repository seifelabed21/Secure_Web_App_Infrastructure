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

variable "app_gateway_subnet_id" {
	type        = string
	description = "Subnet ID dedicated to Application Gateway"
}

variable "backend_fqdns" {
	type        = list(string)
	description = "Backend FQDNs served by Application Gateway"
	default     = []
}

variable "backend_ip_addresses" {
	type        = list(string)
	description = "Backend private IP addresses served by Application Gateway"
	default     = []
}

variable "backend_protocol" {
	type        = string
	description = "Backend protocol used by Application Gateway"
	default     = "Http"
}

variable "backend_port" {
	type        = number
	description = "Backend port used by Application Gateway"
	default     = 80
}

variable "backend_host_name" {
	type        = string
	description = "Host header used by Application Gateway for backend and probe"
	default     = "localhost"
}

variable "ssl_certificate_name" {
	type        = string
	description = "Name of the TLS certificate used by the HTTPS listener"
	default     = "appgw-tls-cert"
}

variable "ssl_certificate_subject" {
	type        = string
	description = "Subject name used to generate a self-signed TLS certificate"
	default     = "CN=app.local"
}

variable "app_gateway_sku_name" {
	type        = string
	description = "Application Gateway SKU with WAF support"
	default     = "WAF_v2"
}

variable "app_gateway_capacity" {
	type        = number
	description = "Application Gateway capacity units"
	default     = 1
}

variable "waf_mode" {
	type        = string
	description = "WAF operating mode: Detection or Prevention"
	default     = "Prevention"
}

variable "tags" {
	type        = map(string)
	description = "Tags for the resources"
	default     = {}
}
