<#
.SYNOPSIS
    Adds a submodule, checks out a specific tag, and stages the changes.
.PARAMETER $GitUrl
    The URL of the git repository to clone as a submodule.
.PARAMETER $Path
    The destination path for the submodule.
.PARAMETER $Tag
    Optional tag or branch to checkout after adding the submodule.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$GitUrl,
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$Tag = ""
)

Write-Host "Adding submodule $GitUrl as $Path..." -ForegroundColor Cyan
git submodule add --force $GitUrl $Path

if (-not [string]::IsNullOrWhiteSpace($Tag)) {
    Write-Host "Checking out tag $Tag..." -ForegroundColor Cyan
    git -C $Path checkout $Tag
}

Write-Host "Staging submodule at $Path..." -ForegroundColor Cyan
git add $Path

Write-Host "Submodule at $Path has been added." -ForegroundColor Green
