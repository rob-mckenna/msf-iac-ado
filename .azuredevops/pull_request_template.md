## Description

Describe the change, impacted environments, and any rollout considerations.

## Type of Change

- [ ] Infrastructure change
- [ ] Pipeline change
- [ ] Policy change
- [ ] Documentation change
- [ ] Script/automation change

## Checklist

- [ ] PR validation pipeline passed (`fmt`, `validate`, security, policy, docs)
- [ ] Terraform plan artifact and PR plan comment reviewed for impacted composition(s)
- [ ] Smoke test and rollback considerations documented for any apply or deploy change
- [ ] Azure DevOps variable groups, environments, and approvals updated if pipeline behavior changed
- [ ] Documentation updated where required
- [ ] ADR updated or created if the change introduces a lasting architectural decision
- [ ] Security, networking, and policy impacts reviewed