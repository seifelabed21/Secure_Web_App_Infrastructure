locals {
  labels_csv = join(",", var.runner_labels)
}

resource "azurerm_network_interface" "runner_nic" {
  name                = "${var.project_name}-runner-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.runner_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "runner_vm" {
  name                = "${var.project_name}-gh-runner"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.runner_vm_size
  admin_username      = var.admin_username
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.runner_nic.id,
  ]
  tags = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOT
    #!/bin/bash
    set -eux

    apt-get update
    apt-get install -y curl jq tar unzip ca-certificates

    useradd -m -s /bin/bash runner || true
    mkdir -p /opt/actions-runner
    cd /opt/actions-runner

    curl -L -o actions-runner.tar.gz "https://github.com/actions/runner/releases/download/v${var.runner_version}/actions-runner-linux-x64-${var.runner_version}.tar.gz"
    tar xzf actions-runner.tar.gz
    ./bin/installdependencies.sh
    chown -R runner:runner /opt/actions-runner

    cat > /usr/local/bin/configure-github-runner.sh <<'SCRIPT'
    #!/bin/bash
    set -eux
    REPO_URL="${var.github_repo_url}"
    REG_TOKEN="${var.runner_registration_token}"

    if [ -z "$REG_TOKEN" ]; then
      echo "runner_registration_token is empty. Generate one in GitHub and re-run this script."
      echo "Example: sudo runner_registration_token=<token> /usr/local/bin/configure-github-runner.sh"
      exit 1
    fi

    cd /opt/actions-runner
    ./config.sh --unattended --replace --url "$REPO_URL" --token "$REG_TOKEN" --labels "${local.labels_csv}" --name "$(hostname)"
    ./svc.sh install runner
    ./svc.sh start
    SCRIPT

    chmod +x /usr/local/bin/configure-github-runner.sh

    if [ -n "${var.runner_registration_token}" ]; then
      /usr/local/bin/configure-github-runner.sh
    fi
  EOT
  )
}
