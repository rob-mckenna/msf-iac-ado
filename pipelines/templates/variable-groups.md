# Azure DevOps variable groups

This repository expects Azure DevOps variable groups to separate shared settings from environment-specific secrets. Keep service connection names and non-secret metadata in standard variables, and store secrets with the lock icon enabled.

## Terraform backend groups

Create one backend group per environment so every stage can target the correct state account.

| Variable group | Required variables |
|---|---|
| `vg-tf-backend-sandbox` | `TF_BACKEND_RESOURCE_GROUP_SANDBOX`, `TF_BACKEND_STORAGE_ACCOUNT_SANDBOX`, `TF_BACKEND_CONTAINER_SANDBOX` |
| `vg-tf-backend-poc` | `TF_BACKEND_RESOURCE_GROUP_POC`, `TF_BACKEND_STORAGE_ACCOUNT_POC`, `TF_BACKEND_CONTAINER_POC` |
| `vg-tf-backend-prod` | `TF_BACKEND_RESOURCE_GROUP_PROD`, `TF_BACKEND_STORAGE_ACCOUNT_PROD`, `TF_BACKEND_CONTAINER_PROD` |

> The composition pipelines pass the backend key explicitly, so only the resource group, storage account, and container need to live in the variable group.

## Infra composition groups

Create one common group and one environment group per composition.

### Landing zone
- Common group: `vg-landing-zone-common`
- Environment groups: `vg-landing-zone-sandbox`, `vg-landing-zone-poc`, `vg-landing-zone-prod`
- Required variables:
  - `LANDING_ZONE_SERVICE_CONNECTION_SANDBOX|POC|PROD`
  - `LANDING_ZONE_APPROVAL_NOTIFY_USERS_POC|PROD`
  - `PROJECT_NAME`, `DEFAULT_LOCATION`, `COMMON_TAGS_JSON`

### AI Foundry infrastructure
- Common group: `vg-ai-foundry-common`
- Environment groups: `vg-ai-foundry-sandbox`, `vg-ai-foundry-poc`, `vg-ai-foundry-prod`
- Required variables:
  - `AI_FOUNDRY_SERVICE_CONNECTION_SANDBOX|POC|PROD`
  - `AI_FOUNDRY_APPROVAL_NOTIFY_USERS_POC|PROD`
  - `PROJECT_NAME`, `DEFAULT_LOCATION`, `COMMON_TAGS_JSON`

### Fabric workspace
- Common group: `vg-fabric-common`
- Environment groups: `vg-fabric-sandbox`, `vg-fabric-poc`, `vg-fabric-prod`
- Required variables:
  - `FABRIC_SERVICE_CONNECTION_SANDBOX|POC|PROD`
  - `FABRIC_APPROVAL_NOTIFY_USERS_POC|PROD`
  - `PROJECT_NAME`, `DEFAULT_LOCATION`, `COMMON_TAGS_JSON`

### APIM gateway
- Common group: `vg-apim-common`
- Environment groups: `vg-apim-sandbox`, `vg-apim-poc`, `vg-apim-prod`
- Required variables:
  - `APIM_SERVICE_CONNECTION_SANDBOX|POC|PROD`
  - `APIM_APPROVAL_NOTIFY_USERS_POC|PROD`
  - `PROJECT_NAME`, `DEFAULT_LOCATION`, `COMMON_TAGS_JSON`

## Deploy pipeline groups

### AI Foundry deploy pipelines
- Common group: `vg-ai-foundry-deploy-common`
- Environment groups: `vg-ai-foundry-deploy-sandbox`, `vg-ai-foundry-deploy-poc`, `vg-ai-foundry-deploy-prod`
- Required variables:
  - `AI_DEPLOY_SERVICE_CONNECTION_SANDBOX|POC|PROD`
  - `AI_FOUNDRY_RESOURCE_GROUP_SANDBOX|POC|PROD`
  - Optional: `INFRACOST_API_KEY`

### Copilot Studio deploy pipeline
- Common group: `vg-copilot-studio-deploy-common`
- Environment groups: `vg-copilot-studio-deploy-sandbox`, `vg-copilot-studio-deploy-poc`, `vg-copilot-studio-deploy-prod`
- Required variables:
  - `COPILOT_STUDIO_CONNECTION_SANDBOX|POC|PROD`

## Service connections

Use one service connection per environment and workload boundary.

- Infrastructure pipelines should use Azure Resource Manager service connections scoped to the target subscription.
- AI Foundry deployment pipelines should use Azure Resource Manager service connections with access to the target workspace resource group.
- Copilot Studio deployment should use a Power Platform service principal connection with solution import rights.

## Common variables

Store shared metadata in each composition's common variable group.

| Variable | Purpose |
|---|---|
| `PROJECT_NAME` | Naming prefix such as `msf` |
| `DEFAULT_LOCATION` | Default Azure region for the workload |
| `COMMON_TAGS_JSON` | Serialized JSON map for common tags like `project`, `owner`, `cost-center`, `managed-by`, `created-date` |

## Secret handling guidance

- Mark connection secrets, API keys, and any service principal credentials as secrets.
- Grant variable group access only to the pipelines that require it.
- Keep approval notification lists non-secret so approver changes do not require secret rotation workflows.