variable "resource_group_name" {
  description = "Resource group that hosts the AI Foundry workspace and private endpoints."
  type        = string
}

variable "location" {
  description = "Azure region for the deployment."
  type        = string
}

variable "workspace_name" {
  description = "Name of the Azure AI Foundry hub workspace."
  type        = string
}

variable "workspace_display_name" {
  description = "Optional display name used for the Azure AI Foundry workspace."
  type        = string
  default     = ""
}

variable "workspace_description" {
  description = "Optional description applied to the Azure AI Foundry workspace."
  type        = string
  default     = ""
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

variable "subnet_id" {
  description = "Subnet ID used for private endpoints."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Map of service keys to private DNS zone IDs used by private endpoints."
  type        = map(list(string))
  default     = {}
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "key_vault_id" {
  description = "Existing Key Vault resource ID associated with the workspace."
  type        = string
}

variable "storage_account_id" {
  description = "Existing Storage Account resource ID associated with the workspace."
  type        = string
}

variable "container_registry_id" {
  description = "Existing Container Registry resource ID associated with the workspace."
  type        = string
}

variable "application_insights_id" {
  description = "Existing Application Insights resource ID associated with the workspace."
  type        = string
}

variable "cognitive_account_id" {
  description = "Existing Cognitive Services account resource ID used for model deployments."
  type        = string
}
