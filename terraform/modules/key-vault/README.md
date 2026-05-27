# key-vault module

Deploys a private-by-default Azure Key Vault for platform secrets and certificates.

## What it creates

- Key Vault with soft delete and purge protection enabled
- private endpoint mapped to the vault private DNS zone
- access policies for platform identities
- diagnostic settings to Log Analytics

## Outputs

- `key_vault_id`
- `key_vault_name`
- `vault_uri`
- `private_endpoint_id`
