resource "azurerm_network_interface" "webvm_nic" {
	name                = "${var.project_name}-webvm-nic"
	location            = var.location
	resource_group_name = var.resource_group_name
	tags                = var.tags

	ip_configuration {
		name                          = "internal"
		subnet_id                     = var.web_subnet_id
		private_ip_address_allocation = "Dynamic"
	}
}

resource "azurerm_linux_virtual_machine" "webvm" {
	name                = "${var.project_name}-webvm"
	resource_group_name = var.resource_group_name
	location            = var.location
	size                = var.vm_size
	admin_username      = var.admin_username
	network_interface_ids = [
		azurerm_network_interface.webvm_nic.id,
	]
	disable_password_authentication = true
	tags                           = var.tags

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
		apt-get install -y nginx wget gnupg ca-certificates
		wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
		dpkg -i /tmp/packages-microsoft-prod.deb
		rm -f /tmp/packages-microsoft-prod.deb
		apt-get update
		apt-get install -y aspnetcore-runtime-${var.aspnet_runtime_version}

		cat > /etc/nginx/sites-available/default <<'NGINXCONF'
		server {
			listen 80 default_server;
			listen [::]:80 default_server;

			location / {
				proxy_pass http://127.0.0.1:${var.aspnet_app_port};
				proxy_http_version 1.1;
				proxy_set_header Upgrade $http_upgrade;
				proxy_set_header Connection keep-alive;
				proxy_set_header Host $host;
				proxy_cache_bypass $http_upgrade;
				proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
				proxy_set_header X-Forwarded-Proto $scheme;
			}
		}
		NGINXCONF

		cat > /var/www/html/index.html <<'HTML'
		<h1>SecureCloud ASP.NET Core VM</h1>
		<p>Nginx is configured to reverse proxy to 127.0.0.1:${var.aspnet_app_port}.</p>
		<p>Deploy your ASP.NET Core app as a systemd service listening on that port.</p>
		HTML

		nginx -t
		systemctl enable nginx
		systemctl restart nginx
	EOT
	)
}
