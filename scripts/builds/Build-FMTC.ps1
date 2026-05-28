<#
.SYNOPSIS
    Builds the vapoursynth-fmtconv package wheel.
#>

$RepoRoot = Resolve-Path "$PSScriptRoot/../.."
Push-Location $RepoRoot

try {
    Write-Host "=== Building vapoursynth-fmtconv ===" -ForegroundColor Cyan

    if ($IsWindows) {
        . "$RepoRoot/scripts/Enter-DevShell.ps1" 
    }

    Write-Host "Running uv build..." -ForegroundColor Cyan
    uv build --package vapoursynth-fmtconv

    Write-Host "Build completed successfully." -ForegroundColor Green
}
finally {
    Pop-Location
}
