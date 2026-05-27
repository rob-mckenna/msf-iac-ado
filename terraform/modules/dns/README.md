# dns module

Creates the private DNS zones required for a private-by-default Azure AI platform.

## Covered services

The default zone set includes private link zones for:

- Storage
- Key Vault
- Azure Container Registry
- Azure Machine Learning / AI Foundry
- Cognitive Services and Azure OpenAI
- Azure Monitor

## Outputs

- `private_dns_zone_ids`
- `private_dns_zone_names`
- `virtual_network_link_ids`
