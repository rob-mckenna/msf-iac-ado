[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('sandbox', 'poc', 'prod')]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [string]$ResourceGroupName,
    [string]$StorageAccountName,

    [string[]]$Containers = @(
        'landing-zone',
        'ai-foundry-workspace',
        'fabric-workspace',
        'apim-gateway',
        'observability'
    )
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-StorageAccountName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentName
    )

    $cleanEnvironment = ($EnvironmentName -replace '[^a-z0-9]', '').ToLowerInvariant()
    $suffix = -join ((48..57) + (97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })
    return ("sttf{0}{1}" -f $cleanEnvironment, $suffix).Substring(0, [Math]::Min(24, ("sttf{0}{1}" -f $cleanEnvironment, $suffix).Length))
}

if (-not $ResourceGroupName) {
    $ResourceGroupName = "rg-tfstate-$Environment"
}

if (-not $StorageAccountName) {
    $StorageAccountName = New-StorageAccountName -EnvironmentName $Environment
}

Write-Host "Ensuring Terraform backend resource group '$ResourceGroupName' in '$Location'."
az group create --name $ResourceGroupName --location $Location --tags environment=$Environment workload=terraform-backend | Out-Null

Write-Host "Ensuring Terraform backend storage account '$StorageAccountName'."
az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --allow-blob-public-access false `
    --min-tls-version TLS1_2 `
    --public-network-access Disabled `
    --tags environment=$Environment workload=terraform-backend | Out-Null

$accountKey = az storage account keys list --resource-group $ResourceGroupName --account-name $StorageAccountName --query "[0].value" --output tsv
if (-not $accountKey) {
    throw "Unable to retrieve a storage account key for '$StorageAccountName'."
}

foreach ($container in $Containers) {
    Write-Host "Ensuring backend container '$container'."
    az storage container create `
        --name $container `
        --account-name $StorageAccountName `
        --account-key $accountKey `
        --public-access off | Out-Null
}

Write-Host "Terraform backend initialization complete."
Write-Host "Resource Group : $ResourceGroupName"
Write-Host "Storage Account: $StorageAccountName"
Write-Host "Containers     : $($Containers -join ', ')"
