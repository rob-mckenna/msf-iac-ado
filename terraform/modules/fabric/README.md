# fabric module

Deploys Microsoft Fabric capacity and an attached Fabric workspace.

## What it creates

- `azurerm_fabric_capacity` for dedicated Fabric capacity
- `azapi_resource` workspace bound to that capacity
- Azure RBAC assignments that grant contributor access to the listed administrators

## Inputs

- `resource_group_name`
- `location`
- `capacity_name`
- `sku`
- `admin_members`
- `workspace_name`
- `tags`

## Outputs

- `capacity_id`
- `workspace_id`
- `workspace_name`
