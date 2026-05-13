<#
.SYNOPSIS
    Removes a submodule and cleans up its internal metadata.
.PARAMETER $Path
    The path to the submodule to remove.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Path
)

Write-Host "Removing submodule entry for $Path..." -ForegroundColor Cyan
git rm $Path

$gitModulePath = Join-Path ".git" "modules" $Path
if (Test-Path $gitModulePath) {
    Write-Host "Cleaning up internal Git metadata at $gitModulePath..." -ForegroundColor Cyan
    Remove-Item -Recurse -Force $gitModulePath
}

Write-Host "Submodule at $Path has been removed and metadata cleaned up." -ForegroundColor Green
