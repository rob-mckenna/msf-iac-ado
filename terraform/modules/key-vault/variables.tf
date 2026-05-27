variable "resource_group_name" {
  description = "Resource group that hosts the Key Vault."
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault deployment."
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID used by the Key Vault."
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU name."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], lower(var.sku_name))
    error_message = "Key Vault SKU must be standard or premium."
  }
}

variable "subnet_id" {
  description = "Subnet ID used for the Key Vault private endpoint."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for vault private endpoints."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID used for diagnostics."
  type        = string
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled for the Key Vault."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Soft-delete retention period for the Key Vault."
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90 days."
  }
}

variable "rbac_authorization_enabled" {
  description = "Whether Azure RBAC is used instead of Key Vault access policies."
  type        = bool
  default     = false
}

variable "access_policies" {
  description = "Access policies applied to the Key Vault when RBAC authorization is disabled."
  type = list(object({
    tenant_id               = string
    object_id               = string
    secret_permissions      = list(string)
    key_permissions         = list(string)
    certificate_permissions = list(string)
  }))
  default = []
}

variable "role_assignments" {
  description = "Azure RBAC role assignments applied to the Key Vault when RBAC authorization is enabled."
  type = list(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}
