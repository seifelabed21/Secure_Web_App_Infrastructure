# modules/resource_group/variables.tf

variable "project_name" {
    type        = string
    description = "The Project Name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
  default     = {}
}
