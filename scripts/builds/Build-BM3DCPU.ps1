<#
.SYNOPSIS
    Builds the vapoursynth-bm3dcpu package wheel.
#>

$RepoRoot = Resolve-Path "$PSScriptRoot/../.."
Push-Location $RepoRoot

try {
    Write-Host "=== Building vapoursynth-bm3dcpu ===" -ForegroundColor Cyan

    if ($IsWindows) {
        . "$RepoRoot/scripts/Enter-DevShell.ps1" 
    }

    Write-Host "Running uv build..." -ForegroundColor Cyan
    uv build --package vapoursynth-bm3dcpu

    Write-Host "Build completed successfully." -ForegroundColor Green
}
finally {
    Pop-Location
}
