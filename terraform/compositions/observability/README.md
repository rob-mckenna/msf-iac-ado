# observability composition

Deploys the monitoring stack as a standalone composition.

## Included resources

- workload resource group
- Log Analytics workspaces for primary telemetry and content safety
- Application Insights
- Azure Monitor action group with email and webhook receivers
- saved KQL searches and AI Gateway alert rules
- reusable diagnostic settings for external resource IDs
- optional resource-group budget alerting
