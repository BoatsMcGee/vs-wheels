<#
.SYNOPSIS
    Builds the vapoursynth-dfttest2_gcc package wheel.
#>

$RepoRoot = Resolve-Path "$PSScriptRoot/../.."
Push-Location $RepoRoot

try {
    Write-Host "=== Building vapoursynth-dfttest2_gcc ===" -ForegroundColor Cyan

    if ($IsWindows) {
        . "$RepoRoot/scripts/Enter-DevShell.ps1"
    }

    Write-Host "Running uv build..." -ForegroundColor Cyan
    uv build --package vapoursynth-dfttest2_gcc

    Write-Host "Build completed successfully." -ForegroundColor Green
}
finally {
    Pop-Location
}
