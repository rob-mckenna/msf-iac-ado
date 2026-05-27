# Shared Terraform Modules

The `modules/` directory contains shared, reusable Terraform modules for the Azure AI Platform reference architecture.

Each module is designed to be:

- independently consumable by multiple root modules
- versioned independently through Git tags or a module registry
- tested independently with module-level validation and example deployments
- focused on a single capability boundary

Compositions under `terraform/compositions/` assemble these modules into complete deployment units.
