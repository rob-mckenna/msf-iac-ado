# Environment Promotion Model

The `environments/` directory contains Terraform variable files for progressive environment promotion.

## Promotion path

1. **sandbox** — low-cost developer integration environment used for module validation and early experimentation.
2. **poc** — proof-of-concept environment with medium SKUs used for capability demonstrations and stakeholder validation.
3. **prod** — production environment with resilient SKUs, tighter governance, and operational settings intended for live workloads.

## Promotion guidance

- deploy the same composition across environments
- keep module code identical across environments
- promote by changing only `*.tfvars` values and backend state keys
- isolate state per composition and per environment
- consume lower-layer outputs through remote state rather than copy-pasting values
