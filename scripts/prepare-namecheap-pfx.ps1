param(
  [Parameter(Mandatory = $true)]
  [string]$DomainName,

  [Parameter(Mandatory = $true)]
  [string]$IssuedCertificatePath,

  [Parameter(Mandatory = $true)]
  [string]$PfxPassword,

  [string]$OutputPfxPath = "keys/$($DomainName).pfx"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $IssuedCertificatePath)) {
  throw "Issued certificate file not found: $IssuedCertificatePath"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

try {
  Write-Host "Linking issued certificate to the existing private key via certreq..." -ForegroundColor Cyan
  certreq -accept $IssuedCertificatePath | Out-Null

  $cert = Get-ChildItem Cert:\CurrentUser\My |
    Where-Object { $_.Subject -match "CN=$([regex]::Escape($DomainName))(,|$)" -and $_.HasPrivateKey } |
    Sort-Object NotAfter -Descending |
    Select-Object -First 1

  if (-not $cert) {
    throw "No certificate with private key found in CurrentUser\\My for CN=$DomainName. Ensure CSR was generated on this machine/user and certificate was accepted successfully."
  }

  $securePassword = ConvertTo-SecureString -String $PfxPassword -AsPlainText -Force
  $outputDir = Split-Path -Parent $OutputPfxPath
  if ($outputDir -and -not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
  }

  Write-Host "Exporting PFX to $OutputPfxPath ..." -ForegroundColor Cyan
  Export-PfxCertificate -Cert $cert.PSPath -FilePath $OutputPfxPath -Password $securePassword -ChainOption BuildChain | Out-Null

  Write-Host "PFX generated successfully: $OutputPfxPath" -ForegroundColor Green
  Write-Host "Next: set ssl_certificate_pfx_path and ssl_certificate_pfx_password in terraform.tfvars, then run apply." -ForegroundColor Yellow
}
finally {
  Pop-Location
}
