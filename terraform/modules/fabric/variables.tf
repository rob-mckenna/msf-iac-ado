variable "resource_group_name" {
  description = "Resource group that hosts the Fabric capacity."
  type        = string
}

variable "location" {
  description = "Azure region for the Fabric capacity."
  type        = string
}

variable "capacity_name" {
  description = "Name of the Microsoft Fabric capacity."
  type        = string
}

variable "sku" {
  description = "Fabric capacity SKU, for example F2, F8, or F64."
  type        = string

  validation {
    condition     = can(regex("^F[0-9]+$", var.sku))
    error_message = "Fabric SKU must follow the F<number> pattern, such as F2 or F64."
  }
}

variable "admin_members" {
  description = "User principal names for Fabric capacity administrators."
  type        = list(string)

  validation {
    condition     = length(var.admin_members) > 0
    error_message = "Provide at least one Fabric capacity administrator."
  }
}

variable "workspace_name" {
  description = "Name of the Fabric workspace created on the capacity."
  type        = string
}

variable "workspace_display_name" {
  description = "Optional display name used for the Fabric workspace."
  type        = string
  default     = ""
}

variable "workspace_description" {
  description = "Description applied to the Fabric workspace."
  type        = string
  default     = "Platform-managed Fabric workspace."
}

variable "lakehouses" {
  description = "Lakehouses provisioned inside the Fabric workspace."
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
