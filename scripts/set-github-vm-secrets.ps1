param(
  [Parameter(Mandatory = $true)]
  [string]$Repo,

  [Parameter(Mandatory = $true)]
  [string]$SshPrivateKeyPath,

  [Parameter(Mandatory = $false)]
  [string]$VmUsername = "azureuser"
)

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI (gh) is required. Install it from https://cli.github.com/"
}

if (-not (Test-Path -Path $SshPrivateKeyPath)) {
  throw "SSH private key file not found: $SshPrivateKeyPath"
}

Write-Host "Setting VM_USERNAME secret..."
gh secret set VM_USERNAME --repo $Repo --body $VmUsername

Write-Host "Setting VM_SSH_PRIVATE_KEY secret..."
$privateKey = Get-Content -Raw -Path $SshPrivateKeyPath
gh secret set VM_SSH_PRIVATE_KEY --repo $Repo --body $privateKey

Write-Host "Done. Secrets configured for repository $Repo"
Write-Host "Next: create repository variable VM_HOST with your VM reachable IP or DNS."