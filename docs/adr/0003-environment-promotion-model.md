# ADR 0003: Environment Promotion Model

## Status
Accepted

## Date
2026-05-27

## Context
The platform must support rapid experimentation while protecting production workloads from unreviewed or unvalidated changes. Environment boundaries need to reflect different risk levels, data sensitivity, and operational expectations.

## Decision
Use three environments: `sandbox` for experimentation and short-lived workloads, `poc` for validation and stakeholder demos, and `prod` for production workloads. Each environment has its own tfvars, state file, and Azure subscription or resource group boundary. Promotion is manual. Changes must pass plan review in each environment before apply. There is no automatic promotion from `sandbox` to `prod`.

## Consequences
Pipeline stages model this progression explicitly. Teams gain stronger production safety and clearer review gates, but promotion requires deliberate operator action and repeated validation in each environment. Environment-specific configuration must be maintained consistently across tfvars and pipeline stages.
