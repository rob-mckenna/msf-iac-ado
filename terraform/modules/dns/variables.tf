variable "resource_group_name" {
  description = "Resource group that hosts the private DNS zones."
  type        = string
}

variable "hub_vnet_id" {
  description = "Hub virtual network ID linked to each private DNS zone."
  type        = string
}

variable "spoke_vnet_ids" {
  description = "Map of spoke virtual network IDs linked to each private DNS zone."
  type        = map(string)
  default     = {}
}

variable "private_dns_zones" {
  description = "Optional override list of private DNS zones to create."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for zone in var.private_dns_zones : startswith(zone, "privatelink.")])
    error_message = "Each private DNS zone must use the privatelink.* namespace."
  }
}

variable "tags" {
  description = "Tags applied to the private DNS zones and links."
  type        = map(string)
  default     = {}
}
