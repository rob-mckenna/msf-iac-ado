# Onboarding a New AI Workload

Use this guide when adding a new AI workload to the platform.

## 1. Create tfvars for the New Workload

Add environment-specific tfvars for the workload and define values for naming, tags, networking, identity, and any backend model configuration.

## 2. Add Pipeline Definition

Create or update the Azure DevOps pipeline definition so the workload can run `plan` and `apply` stages across the required environments. Include manual review gates aligned with the promotion model.

## 3. Run the Landing Zone if New Networking Is Needed

If the workload needs a new spoke, private DNS linkage, or additional shared services, update and deploy the landing zone or network composition before deploying the workload itself.

## 4. Deploy the AI Foundry Project

Deploy the AI Foundry workspace project, model configuration, and supporting resources using the appropriate Terraform composition for the workload.

## 5. Register the API in APIM

Add the workload API or model endpoint to APIM, apply the required policies, and assign it to the correct product for governed access.

## 6. Configure the Entra App Registration

Create or update the Entra app registration, define scopes if needed, and assign the correct groups or service principals for runtime and operational access.

## 7. Validate End-to-End

Confirm the workload is reachable through APIM, private connectivity works, authentication succeeds, telemetry is emitted, and the workload behaves as expected in the target environment.
