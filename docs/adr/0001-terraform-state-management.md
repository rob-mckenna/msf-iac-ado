# ADR 0001: Terraform State Management

## Status
Accepted

## Date
2026-05-27

## Context
The platform needs isolated Terraform state per composition so teams can deploy and evolve compositions independently without coupling release timing across the entire reference architecture. The state approach must also support recovery from accidental changes and safe concurrent operations.

## Decision
Use an Azure Storage Account as the Terraform backend, with one blob container per composition and one state file per environment. Each composition gets its own state file keyed as `{composition}-{environment}.tfstate`. Enable soft-delete and blob versioning for state recovery. Use Azure blob lease locking for Terraform state locking.

## Consequences
State access requires Azure Storage Account RBAC for operators, pipelines, and automation identities. Cross-composition references use `terraform_remote_state` data sources. This model supports independent deployment cycles, but it adds backend configuration and access management overhead for each composition.
