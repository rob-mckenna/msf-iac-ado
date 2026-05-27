# landing-zone composition

The landing zone composition provisions the shared platform foundation.

## Included modules

- `networking`
- `dns`
- `observability`
- `key-vault`
- `policy`

## Responsibilities

- establish hub-spoke networking
- publish platform private DNS zones
- create shared observability services
- deploy a private Key Vault for shared secrets
- assign the AI Platform baseline policy initiative

## Policy rollout

The landing zone passes environment-aware policy settings into the policy module:

- `sandbox` and `poc` default to audit-first behavior
- `prod` defaults to deny-first behavior
- `allowed_locations` constrains regional placement
- `policy_effect_overrides` supports exceptions during staged rollout

This composition should be deployed before workload compositions so downstream deployments can consume its outputs through remote state.
