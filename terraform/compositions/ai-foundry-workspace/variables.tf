variable "ai_foundry_resource_group_name" {
  description = "Resource group for the AI Foundry workload deployment."
  type        = string
}

variable "location" {
  description = "Azure region for the AI Foundry workload."
  type        = string
}

variable "project_name" {
  description = "Project prefix used in naming dependent resources."
  type        = string
}

variable "environment" {
  description = "Environment token such as sandbox, poc, or prod."
  type        = string
}

variable "ai_foundry_workspace_name" {
  description = "Name of the Azure AI Foundry workspace."
  type        = string
}

variable "ai_foundry_workspace_display_name" {
  description = "Optional display name for the Azure AI Foundry workspace."
  type        = string
  default     = ""
}

variable "ai_foundry_workspace_description" {
  description = "Description for the Azure AI Foundry workspace."
  type        = string
  default     = "Platform-managed Azure AI Foundry workspace."
}

variable "landing_zone_state_resource_group_name" {
  description = "Resource group name that holds the landing zone Terraform state storage account."
  type        = string
}

variable "landing_zone_state_storage_account_name" {
  description = "Storage account name that holds the landing zone Terraform state."
  type        = string
}

variable "landing_zone_state_container_name" {
  description = "Blob container name that holds the landing zone Terraform state."
  type        = string
}

variable "landing_zone_state_key" {
  description = "State file key for the landing zone composition."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Optional override subnet ID used for private endpoints. When empty, the landing zone output is used."
  type        = string
  default     = ""
}

variable "storage_replication_type" {
  description = "Replication type for the AI Foundry storage account."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RAGRS", "RAGZRS"], var.storage_replication_type)
    error_message = "storage_replication_type must be a valid Azure Storage replication SKU."
  }
}

variable "acr_sku" {
  description = "SKU for the Container Registry used by AI Foundry."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

variable "workspace_sku_name" {
  description = "SKU name for the Azure AI Foundry workspace."
  type        = string
  default     = "Basic"
}

variable "workspace_sku_tier" {
  description = "SKU tier for the Azure AI Foundry workspace."
  type        = string
  default     = "Basic"
}

variable "workspace_key_vault_name" {
  description = "Optional override for the AI Foundry workspace Key Vault name."
  type        = string
  default     = ""
}

variable "workspace_key_vault_sku_name" {
  description = "SKU used by the AI Foundry workspace Key Vault."
  type        = string
  default     = "standard"
}

variable "workspace_key_vault_soft_delete_retention_days" {
  description = "Soft-delete retention period for the AI Foundry workspace Key Vault."
  type        = number
  default     = 30
}

variable "log_analytics_sku" {
  description = "SKU for the AI Foundry Log Analytics workspace."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Retention period for the AI Foundry Log Analytics workspace."
  type        = number
  default     = 30
}

variable "tenant_id" {
  description = "Tenant ID used by the AI Foundry workspace Key Vault."
  type        = string
}

variable "cognitive_account_kind" {
  description = "Cognitive Services kind used for model deployment endpoints."
  type        = string
  default     = "OpenAI"
}

variable "cognitive_account_sku_name" {
  description = "SKU used for the Cognitive Services account."
  type        = string
  default     = "S0"
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}
