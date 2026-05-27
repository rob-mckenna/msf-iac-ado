output "capacity_id" {
  description = "Resource ID of the Microsoft Fabric capacity."
  value       = azapi_resource.capacity.id
}

output "workspace_id" {
  description = "Resource ID of the Microsoft Fabric workspace."
  value       = azapi_resource.workspace.id
}

output "workspace_name" {
  description = "Name of the Microsoft Fabric workspace."
  value       = var.workspace_name
}

output "lakehouse_ids" {
  description = "Resource IDs of the Fabric lakehouses keyed by name."
  value       = { for key, lakehouse in azapi_resource.lakehouse : key => lakehouse.id }
}
