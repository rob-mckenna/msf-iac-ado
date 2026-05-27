output "capacity_id" {
  description = "Microsoft Fabric capacity ID."
  value       = module.fabric.capacity_id
}

output "workspace_id" {
  description = "Microsoft Fabric workspace ID."
  value       = module.fabric.workspace_id
}

output "workspace_name" {
  description = "Microsoft Fabric workspace name."
  value       = module.fabric.workspace_name
}

output "lakehouse_ids" {
  description = "Fabric lakehouse IDs keyed by lakehouse name."
  value       = module.fabric.lakehouse_ids
}
