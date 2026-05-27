# Getting Started

This guide walks through the initial setup and first deployment path for the Azure AI Platform reference architecture.

## 1. Prerequisites

Ensure you have the following before starting:

- Azure CLI installed and authenticated
- Terraform `>= 1.5`
- An Azure DevOps organization for pipeline setup
- Required Azure subscriptions for `sandbox`, `poc`, and `prod`
- Permissions to create resource groups, service principals, and role assignments

## 2. Clone the Repo

```powershell
git clone <repository-url>
cd msf-iac-ado
```

## 3. Initialize Terraform Backend

Run the backend initialization script to create or configure the remote Terraform state backend.

```powershell
.\scripts\init-backend.ps1
```

## 4. Configure Azure DevOps Service Connections

Create service connections for each deployment environment and scope them to the appropriate Azure subscription or resource group. Confirm the pipelines can authenticate with least-privilege access.

## 5. Deploy the Landing Zone

Start with the `sandbox` environment. Deploy the landing zone composition first so the shared networking, policy, and foundational services are available for downstream workloads.

## 6. Deploy the AI Foundry Workspace

Deploy the AI Foundry composition or workload definition into `sandbox`. Confirm the workspace, private endpoints, and any dependent services are provisioned successfully.

## 7. Deploy the APIM Gateway

Deploy Azure API Management into the APIM spoke and configure the gateway policies, products, and backend routing for the AI endpoints.

## 8. Verify Deployment

Validate the initial deployment by checking:

- Terraform apply completed successfully
- Private endpoints and DNS resolution are healthy
- APIM is reachable through the intended network path
- Entra authentication works for the configured test client
- A sample AI API call succeeds end-to-end

## 9. Next Steps

- Review the ADRs in `..\adr\`
- Read `..\architecture\overview.md`
- Use `onboarding-new-workload.md` to add another AI workload
- Promote changes from `sandbox` to `poc` after plan review
