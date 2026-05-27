# Terraform Compositions

The `compositions/` directory contains root Terraform modules that assemble shared modules into complete deployment scenarios.

A composition is a **deployable unit** with its own:

- provider configuration
- backend configuration
- variable surface
- module wiring
- outputs consumed by downstream compositions

Examples in this repository include the foundational landing zone, AI Foundry workspace deployment, Microsoft Fabric workspace deployment, API gateway deployment, and standalone observability stack.
