resource "azurerm_resource_group" "this" {
  name     = var.fabric_resource_group_name
  location = var.location
  tags     = var.tags
}

module "fabric" {
  source = "../../modules/fabric"

  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  capacity_name          = var.capacity_name
  sku                    = var.sku
  admin_members          = var.admin_members
  workspace_name         = var.fabric_workspace_name
  workspace_display_name = var.fabric_workspace_display_name
  workspace_description  = var.fabric_workspace_description
  lakehouses             = var.lakehouses
  tags                   = merge(var.tags, { workload = "fabric" })
}
