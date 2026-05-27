# ADR 0002: Module Composition Pattern

## Status
Accepted

## Date
2026-05-27

## Context
The platform needs a Terraform structure that supports reuse while preserving clear deployment boundaries. Shared capabilities such as networking, identity integration, and platform services should be reusable, but deployment units must remain independently operable.

## Decision
Adopt a two-tier module hierarchy. Shared modules in `terraform\modules\` contain single-concern reusable components. Compositions in `terraform\compositions\` are root modules that wire shared modules together for a specific deployment scenario. Compositions are the unit of deployment. Shared modules never call other shared modules, keeping the shared layer flat.

## Consequences
This pattern improves module clarity and keeps deployment boundaries explicit. Some configuration duplication across compositions is acceptable because deployment isolation is prioritized over deep abstraction. Composition authors take responsibility for orchestration logic that is not embedded inside shared modules.
