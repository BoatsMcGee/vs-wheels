<#
.SYNOPSIS
    Downloads the .json metadata files from the successful runs
#>

$repoRoot = Resolve-Path "$PSScriptRoot/.."
$metadataDir = Join-Path $repoRoot "metadata_files"
$workflowsPath = Join-Path $repoRoot ".github/workflows/pkg-*.yml"

New-Item -ItemType Directory -Force -Path $metadataDir

# Dynamically get all plugin workflows
$workflows = Get-ChildItem -Path $workflowsPath | Select-Object -ExpandProperty Name

foreach ($wf in $workflows) {
    # Get up to 10 successful runs to find the latest one that has metadata
    $runIds = @(((gh run list --workflow $wf --status success --limit 10 --json databaseId | Out-String) | ConvertFrom-Json).databaseId)

    $downloaded = $false
    foreach ($runId in $runIds) {
        gh run download $runId --pattern "*-metadata" -D $metadataDir 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully downloaded metadata from run $runId for $wf"
            $downloaded = $true
            break
        }
    }
    if (-not $downloaded) {
        Write-Host "No metadata found in the last 10 successful runs for $wf"
    }
}
