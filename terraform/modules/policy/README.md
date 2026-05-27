# policy module

Defines and assigns a production-ready Azure Policy initiative that hardens the AI platform landing zone.

## Initiative contents

- enforce required platform tags
- allow only approved Azure regions
- require encryption at rest on platform storage
- deny public access on core platform services
- deny public ingress on AI services
- require private endpoints for AI platform services
- enforce deny-by-default network isolation

## Environment-aware effects

The module resolves effects by environment:

- `sandbox` and `poc` default to `Audit`
- `prod` defaults to `Deny`
- use `default_policy_effect` to override globally
- use `policy_effect_overrides` for per-policy exceptions

This supports audit-first rollout in lower environments and hard enforcement in production.

## Key inputs

- `environment_tier`
- `allowed_locations`
- `required_tags`
- `default_policy_effect`
- `policy_effect_overrides`
- `assignment_enforcement_enabled`

## Outputs

- `policy_definition_ids`
- `policy_assignment_ids`
- `initiative_definition_id`
- `initiative_assignment_id`
- `policy_effects`
