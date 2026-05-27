# Terraform Structure

This repository organizes Terraform into three layers:

- **modules/**: shared, reusable Terraform modules that encapsulate a single platform capability such as networking, DNS, policy, or observability.
- **compositions/**: root Terraform modules that compose one or more shared modules into a complete deployment scenario such as a landing zone or AI Foundry workspace.
- **environments/**: environment-specific `*.tfvars` files that provide values for sandbox, proof-of-concept, and production deployments.

## State management

Each composition uses the Azure Storage Account backend (`azurerm`) for remote state. The recommended pattern is:

- one storage account dedicated to Terraform state
- one blob container for state files
- one **state file per composition per environment**

Examples:

- `landing-zone.sandbox.tfstate`
- `landing-zone.prod.tfstate`
- `ai-foundry-workspace.poc.tfstate`

This keeps foundational state isolated from workload state, reduces blast radius, and allows teams to promote environments independently while still consuming outputs through remote state.

## Recommended workflow

1. Select a composition under `terraform/compositions/`.
2. Provide the matching environment variables from `terraform/environments/<environment>/<environment>.tfvars`.
3. Configure the Azure Storage backend for that composition.
4. Run `terraform init`, `terraform plan`, and `terraform apply` from the composition directory.
