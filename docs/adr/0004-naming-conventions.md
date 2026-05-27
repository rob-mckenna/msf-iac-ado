# ADR 0004: Naming Conventions

## Status
Accepted

## Date
2026-05-27

## Context
The platform needs a consistent naming approach for Azure resources, Terraform assets, and operational documentation so components are easy to identify across environments and regions. Naming must be predictable enough for automation while remaining readable to operators.

## Decision
Use the Azure resource naming pattern `{project}-{component}-{environment}-{region}-{instance}`. The project prefix is `msf`. Region codes use short forms such as `eus` for East US and `wus` for West US. Environment codes are `sbx`, `poc`, and `prd`. The instance value is a three-digit zero-padded number. Examples include `msf-hub-vnet-sbx-eus-001`, `msf-aifoundry-sbx-eus-001`, and `msf-apim-prd-eus-001`. Resource groups use the pattern `msf-rg-{component}-{environment}-{region}`. Terraform resource names use underscores internally.

## Consequences
Names become easy to parse in automation, dashboards, and operational runbooks. The convention requires discipline when introducing new components and regions, but it reduces ambiguity across the platform. Terraform code and Azure resource names intentionally differ in delimiter style to align with each tool's conventions.
