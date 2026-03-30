param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("validate", "plan", "apply", "destroy", "output")]
  [string]$Action,

  [string]$TfVarsFile = "terraform.tfvars",
  [string]$PlanFile = "terraform.tfplan",
  [switch]$AutoApprove,
  [switch]$SkipInit
)

$ErrorActionPreference = "Stop"

function Invoke-Terraform {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  Write-Host ("terraform " + ($Arguments -join " ")) -ForegroundColor Cyan
  & terraform @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Terraform command failed with exit code $LASTEXITCODE"
  }
}

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
  throw "Terraform CLI not found. Install Terraform and retry."
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
  throw "Azure CLI not found. Install Azure CLI and retry."
}

az account show --output none | Out-Null

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

try {
  if (-not $SkipInit) {
    Invoke-Terraform -Arguments @("init", "-upgrade", "-reconfigure")
  }

  switch ($Action) {
    "validate" {
      Invoke-Terraform -Arguments @("validate")
    }

    "plan" {
      Invoke-Terraform -Arguments @("plan", "-var-file=$TfVarsFile", "-out=$PlanFile")
      Write-Host "Plan written to $PlanFile" -ForegroundColor Green
    }

    "apply" {
      if ($AutoApprove) {
        Invoke-Terraform -Arguments @("apply", "-var-file=$TfVarsFile", "-auto-approve")
      }
      else {
        Invoke-Terraform -Arguments @("apply", "-var-file=$TfVarsFile")
      }
    }

    "destroy" {
      if (-not $AutoApprove) {
        Write-Host "Destroy will remove ALL managed resources for this state." -ForegroundColor Yellow
        $confirmation = Read-Host "Type 'destroy' to continue"
        if ($confirmation -ne "destroy") {
          throw "Destroy cancelled by user."
        }
      }

      if ($AutoApprove) {
        Invoke-Terraform -Arguments @("destroy", "-var-file=$TfVarsFile", "-auto-approve")
      }
      else {
        Invoke-Terraform -Arguments @("destroy", "-var-file=$TfVarsFile")
      }
    }

    "output" {
      Invoke-Terraform -Arguments @("output")
    }
  }
}
finally {
  Pop-Location
}
