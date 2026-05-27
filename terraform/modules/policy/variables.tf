variable "subscription_id" {
  description = "Subscription ID that receives the policy assignments."
  type        = string
}

variable "location" {
  description = "Azure region used for policy assignment identities."
  type        = string
}

variable "policy_prefix" {
  description = "Prefix used for naming policy definitions and assignments."
  type        = string
}

variable "environment_tier" {
  description = "Environment classification used to resolve default policy effect. Use sandbox or poc for audit-first, prod for deny-first."
  type        = string
  default     = "sandbox"

  validation {
    condition     = contains(["sandbox", "poc", "prod"], lower(var.environment_tier))
    error_message = "environment_tier must be sandbox, poc, or prod."
  }
}

variable "default_policy_effect" {
  description = "Optional global override for the default effect applied to policy references. Valid values: Audit, Deny, Disabled."
  type        = string
  default     = null

  validation {
    condition     = var.default_policy_effect == null || contains(["audit", "deny", "disabled"], lower(var.default_policy_effect))
    error_message = "default_policy_effect must be null, Audit, Deny, or Disabled."
  }
}

variable "policy_effect_overrides" {
  description = "Per-policy effect overrides keyed by policy name. Valid values: Audit, Deny, Disabled."
  type        = map(string)
  default     = {}
}

variable "assignment_enforcement_enabled" {
  description = "Whether the subscription assignment enforces the initiative. Set false for staged rollout or break-glass validation."
  type        = bool
  default     = true
}

variable "allowed_locations" {
  description = "Azure regions allowed for platform resources. Defaults to the assignment location when empty."
  type        = list(string)
  default     = []
}

variable "required_tags" {
  description = "Tags enforced by the tag governance policy."
  type        = list(string)
  default     = ["environment", "project", "owner", "cost-center", "managed-by", "created-date"]
}
