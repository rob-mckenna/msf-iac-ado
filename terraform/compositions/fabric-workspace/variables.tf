variable "fabric_resource_group_name" {
  description = "Resource group used by the Fabric composition."
  type        = string
}

variable "location" {
  description = "Azure region for the Fabric composition."
  type        = string
}

variable "capacity_name" {
  description = "Name of the Microsoft Fabric capacity."
  type        = string
}

variable "fabric_workspace_name" {
  description = "Name of the Microsoft Fabric workspace."
  type        = string
}

variable "fabric_workspace_display_name" {
  description = "Optional display name for the Microsoft Fabric workspace."
  type        = string
  default     = ""
}

variable "fabric_workspace_description" {
  description = "Description applied to the Microsoft Fabric workspace."
  type        = string
  default     = "Platform-managed Fabric workspace."
}

variable "sku" {
  description = "Fabric capacity SKU."
  type        = string
}

variable "admin_members" {
  description = "User principal names that administer the Fabric capacity."
  type        = list(string)
}

variable "lakehouses" {
  description = "Lakehouses created in the Fabric workspace."
  type = list(object({
    name         = string
    display_name = optional(string, "")
    description  = optional(string, "")
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}
