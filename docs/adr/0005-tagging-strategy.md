# ADR 0005: Tagging Strategy

## Status
Accepted

## Date
2026-05-27

## Context
The platform needs consistent metadata on every resource to support governance, cost allocation, ownership tracking, lifecycle review, and policy enforcement. Manual tagging alone is not reliable enough for an enterprise platform footprint.

## Decision
Require the following tags on all resources: `environment` (`sandbox`, `poc`, or `prod`), `project` (`msf`), `owner` (team email), `cost-center` (finance code), `managed-by` (`terraform`), and `created-date` (ISO 8601). Optional tags include `workload` and `data-classification`. Enforce required tags with Azure Policy. Pass tags through Terraform variable maps so modules and compositions can apply them consistently.

## Consequences
Governance and cost reporting improve because metadata is standardized across deployments. Platform teams must maintain tag values in tfvars and composition inputs. Azure Policy provides enforcement, but deployments can fail if required tags are missing or malformed.
