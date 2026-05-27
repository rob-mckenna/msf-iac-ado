[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9-]+$')]
    [string]$WorkloadName,

    [Parameter(Mandatory = $true)]
    [ValidateSet('ai-foundry-project', 'apim-product')]
    [string]$WorkloadType,

    [string[]]$Environments = @('sandbox', 'poc', 'prod'),
    [string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-FileIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    if (Test-Path $Path) {
        throw "File '$Path' already exists. Refusing to overwrite scaffolded content."
    }

    $directory = Split-Path -Path $Path -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    Set-Content -Path $Path -Value $Content -Encoding utf8
}

$pipelineDirectory = Join-Path $RepositoryRoot 'pipelines\deploy'
$environmentDirectory = Join-Path $RepositoryRoot 'terraform\environments'

switch ($WorkloadType) {
    'ai-foundry-project' {
        $moduleRoot = Join-Path $RepositoryRoot 'terraform\compositions\ai-foundry-workspace\workloads'
        $pipelinePath = Join-Path $pipelineDirectory ("{0}-agent-deploy.yml" -f $WorkloadName)
        $pipelineContent = @"
trigger: none
pr: none

extends:
  template: agent-deploy.yml
  parameters:
    project: mlw-$WorkloadName-sandbox
    environment: sandbox
    agent_config_path: agents\$WorkloadName\deployment.yml
"@
        $modulePath = Join-Path $moduleRoot ("{0}.tf" -f $WorkloadName)
        $moduleContent = @"
module \"$($WorkloadName -replace '-', '_')\" {
  source              = "../../modules/ai-foundry"
  project_name        = "$WorkloadName"
  deployment_env_map  = var.project_environment_map["$WorkloadName"]
}
"@
    }
    'apim-product' {
        $moduleRoot = Join-Path $RepositoryRoot 'terraform\compositions\apim-gateway\products'
        $pipelinePath = Join-Path $pipelineDirectory ("{0}-flow-deploy.yml" -f $WorkloadName)
        $pipelineContent = @"
trigger: none
pr: none

extends:
  template: flow-deploy.yml
  parameters:
    project: mlw-$WorkloadName-sandbox
    environment: sandbox
    flow_config_path: flows\$WorkloadName\deployment.yml
    endpoint_name: ep-$WorkloadName
    deployment_name: blue
"@
        $modulePath = Join-Path $moduleRoot ("{0}.tf" -f $WorkloadName)
        $moduleContent = @"
module \"$($WorkloadName -replace '-', '_')\" {
  source        = "../../modules/apim"
  product_name  = "$WorkloadName"
  display_name  = "$WorkloadName"
}
"@
    }
}

foreach ($environment in $Environments) {
    $tfvarsPath = Join-Path $environmentDirectory ("{0}\{1}.auto.tfvars.json" -f $environment, $WorkloadName)
    $tfvarsObject = [ordered]@{
        workload_name = $WorkloadName
        workload_type = $WorkloadType
        environment   = $environment
        project_environment_map = @{
            $WorkloadName = @{
                environment = $environment
                enabled     = $true
            }
        }
    }
    New-FileIfMissing -Path $tfvarsPath -Content ($tfvarsObject | ConvertTo-Json -Depth 6)
}

New-FileIfMissing -Path $pipelinePath -Content $pipelineContent
New-FileIfMissing -Path $modulePath -Content $moduleContent

Write-Host "Scaffolded workload '$WorkloadName' for type '$WorkloadType'."
Write-Host "Pipeline : $pipelinePath"
Write-Host "Module   : $modulePath"
Write-Host "tfvars   : $($Environments -join ', ')"
