# Private Endpoint Reference

This reference lists the private endpoint subresource types used by the platform modules and the DNS zones they require. Use it when wiring new workloads, validating DNS, or reviewing policy exceptions.

## Active private endpoint patterns in current Terraform

| Resource | Subresource name | Private DNS zone | Where used | Notes |
|---|---|---|---|---|
| Azure AI Foundry workspace | `amlworkspace` | `privatelink.api.azureml.ms` | `terraform/modules/ai-foundry` | Required for hub workspace control plane access |
| Storage account | `blob` | `privatelink.blob.core.windows.net` | `terraform/modules/ai-foundry` | Used for workspace artifact and data storage |
| Key Vault | `vault` | `privatelink.vaultcore.azure.net` | `terraform/modules/key-vault`, `terraform/modules/ai-foundry` | Used for shared secrets and workspace-backed keys |
| Azure Container Registry | `registry` | `privatelink.azurecr.io` | `terraform/modules/ai-foundry` | Required for private image pulls |
| Application Insights / Azure Monitor | `azuremonitor` | `privatelink.monitor.azure.com` | `terraform/modules/ai-foundry` | Keeps telemetry egress on private name resolution |

## Platform DNS zones pre-provisioned for workload expansion

The landing zone also pre-creates additional private DNS zones so new workloads can stay inside the same pattern without redesigning shared networking.

| DNS zone | Typical Azure service or subresource | Why it exists in the landing zone |
|---|---|---|
| `privatelink.file.core.windows.net` | Storage `file` | Future file shares or package caches |
| `privatelink.queue.core.windows.net` | Storage `queue` | Future async workload or orchestration queues |
| `privatelink.table.core.windows.net` | Storage `table` | Future metadata tables or compatibility workloads |
| `privatelink.notebooks.azure.net` | Azure ML notebooks | Reserved for notebook-enabled workspace patterns |
| `privatelink.cognitiveservices.azure.com` | Cognitive Services account endpoint | Required when Azure AI services are brought in behind private endpoints |
| `privatelink.openai.azure.com` | Azure OpenAI endpoint | Required for private Azure OpenAI deployments |

## Validation checklist

- confirm the correct `subresource_names` value is used in Terraform
- attach the private endpoint to the matching private DNS zone group
- link the zone to both hub and workload VNets that need resolution
- verify public network access is disabled on the target service
- confirm name resolution from APIM and workload subnets before promotion

## Policy alignment

These endpoint patterns line up with the policy baseline:

- private endpoints are required for Storage, Key Vault, ACR, Azure AI, and AI Foundry workspaces
- public ingress stays disabled even after a private endpoint is created
- network ACLs remain deny-by-default so private endpoints do not become a partial control only
