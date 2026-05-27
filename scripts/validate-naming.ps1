[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]]$Name,

    [ValidateSet('generic', 'resourceGroup', 'storageAccount', 'keyVault', 'cognitiveAccount', 'apim', 'workspace')]
    [string]$ResourceType = 'generic'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rules = @{
    generic = @{ Pattern = '^[a-z0-9]+(-[a-z0-9]+){2,5}$'; Example = 'rg-aiplatform-sandbox-eus-001' }
    resourceGroup = @{ Pattern = '^rg-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+(-[a-z0-9]+)?$'; Example = 'rg-aiplatform-sandbox-eus' }
    storageAccount = @{ Pattern = '^st[a-z0-9]{8,22}$'; Example = 'staiplatsbxeus01' }
    keyVault = @{ Pattern = '^kv-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+$'; Example = 'kv-aiplatform-sandbox-eus' }
    cognitiveAccount = @{ Pattern = '^ai-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+$'; Example = 'ai-aiplatform-sandbox-eus' }
    apim = @{ Pattern = '^apim-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+$'; Example = 'apim-aiplatform-prod-eus' }
    workspace = @{ Pattern = '^mlw-[a-z0-9]+-[a-z0-9]+-[a-z0-9]+$'; Example = 'mlw-aiplatform-poc-eus' }
}

$selectedRule = $rules[$ResourceType]
$invalidNames = New-Object System.Collections.Generic.List[string]

foreach ($candidate in $Name) {
    if ($candidate -cnotmatch $selectedRule.Pattern) {
        $invalidNames.Add($candidate)
        Write-Error "Name '$candidate' does not match ADR-0004 rule '$ResourceType'. Expected pattern '$($selectedRule.Pattern)' (example: $($selectedRule.Example))."
    }
    else {
        Write-Host "PASS: $candidate"
    }
}

if ($invalidNames.Count -gt 0) {
    throw "Naming validation failed for $($invalidNames.Count) resource name(s)."
}

Write-Host "All resource names comply with ADR-0004 validation rules for '$ResourceType'."
