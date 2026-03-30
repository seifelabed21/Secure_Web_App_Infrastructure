# SecureCloud Terraform Infrastructure

This folder is prepared for repeatable lifecycle operations:

- deploy the full stack
- inspect outputs
- destroy all managed resources

## Prerequisites

- Terraform CLI >= 1.5
- Azure CLI
- Authenticated Azure session: `az login`
- Valid values in `terraform.tfvars`

## First-Time Setup

1. Authenticate:
   - `az login`
2. Optional: confirm the active subscription:
   - `az account show --output table`
3. Run validation:
   - PowerShell: `./scripts/terraform-lifecycle.ps1 -Action validate`
   - Bash: `./scripts/terraform-lifecycle.sh validate`

## Deploy Anytime

PowerShell:

- Plan: `./scripts/terraform-lifecycle.ps1 -Action plan`
- Apply: `./scripts/terraform-lifecycle.ps1 -Action apply`
- Apply non-interactive: `./scripts/terraform-lifecycle.ps1 -Action apply -AutoApprove`

Bash:

- Plan: `./scripts/terraform-lifecycle.sh plan`
- Apply: `./scripts/terraform-lifecycle.sh apply`
- Apply non-interactive: `AUTO_APPROVE=true ./scripts/terraform-lifecycle.sh apply`

## Destroy Everything

PowerShell:

- Interactive safe destroy: `./scripts/terraform-lifecycle.ps1 -Action destroy`
- Non-interactive destroy: `./scripts/terraform-lifecycle.ps1 -Action destroy -AutoApprove`

Bash:

- Interactive safe destroy: `./scripts/terraform-lifecycle.sh destroy`
- Non-interactive destroy: `AUTO_APPROVE=true ./scripts/terraform-lifecycle.sh destroy`

## Useful Operations

- Show outputs:
  - PowerShell: `./scripts/terraform-lifecycle.ps1 -Action output`
  - Bash: `./scripts/terraform-lifecycle.sh output`
- Use a different tfvars file:
  - PowerShell: `./scripts/terraform-lifecycle.ps1 -Action apply -TfVarsFile custom.tfvars`
  - Bash: `TFVARS_FILE=custom.tfvars ./scripts/terraform-lifecycle.sh apply`

## Trusted TLS (Namecheap) Auto-Bind

If you have an issued certificate from Namecheap, you can make App Gateway bind it automatically during `terraform apply`.

1. Generate PFX from your issued cert on the same Windows user/machine that created the CSR:
   - `./scripts/prepare-namecheap-pfx.ps1 -DomainName pfaseifaymen.me -IssuedCertificatePath C:\path\pfaseifaymen.me.crt -PfxPassword "YourStrongPfxPassword" -OutputPfxPath "keys/pfaseifaymen.me.pfx"`
2. Set these values in `terraform.tfvars`:
   - `app_public_domain = "pfaseifaymen.me"`
   - `ssl_certificate_pfx_path = "keys/pfaseifaymen.me.pfx"`
   - `ssl_certificate_pfx_password = "YourStrongPfxPassword"`
3. Deploy:
   - PowerShell: `./scripts/terraform-lifecycle.ps1 -Action apply`
   - Bash: `./scripts/terraform-lifecycle.sh apply`

Behavior:

- If `ssl_certificate_pfx_path` is set, Terraform imports that trusted PFX into Key Vault and App Gateway uses it.
- If `ssl_certificate_pfx_path` is empty, Terraform falls back to a generated self-signed certificate.

DNS reminder:

- Point your domain A record to the Application Gateway public IP, not the backend VM.

### DNS Checklist (after deploy)

1. Get App Gateway public IP:
   - `terraform output application_gateway_public_ip`
2. At your DNS provider (Namecheap), create records:
   - `A` record: `@` -> `<application_gateway_public_ip>`
   - Optional `CNAME`: `www` -> `pfaseifaymen.me`
3. Wait for propagation, then verify:
   - `nslookup pfaseifaymen.me`
4. Browse only using the domain:
   - `https://pfaseifaymen.me`

## Notes

- `keys/`, `.terraform/`, and `*.tfstate*` are ignored in Git to avoid leaking sensitive local artifacts.
- The scripts always run `terraform init -upgrade -reconfigure` unless explicitly skipped:
  - PowerShell: `-SkipInit`
  - Bash: `SKIP_INIT=true`
