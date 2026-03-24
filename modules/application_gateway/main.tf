data "azurerm_client_config" "current" {}

locals {
	key_vault_name = substr(lower("kv${replace(replace(var.project_name, "-", ""), "_", "")}${substr(md5(var.resource_group_name), 0, 6)}"), 0, 24)
}

resource "azurerm_user_assigned_identity" "appgw_identity" {
	name                = "${var.project_name}-appgw-id"
	resource_group_name = var.resource_group_name
	location            = var.location
	tags                = var.tags
}

resource "azurerm_key_vault" "appgw_kv" {
	name                       = local.key_vault_name
	location                   = var.location
	resource_group_name        = var.resource_group_name
	tenant_id                  = data.azurerm_client_config.current.tenant_id
	sku_name                   = "standard"
	soft_delete_retention_days = 7
	purge_protection_enabled   = false
	tags                       = var.tags
}

resource "azurerm_key_vault_access_policy" "current" {
	key_vault_id = azurerm_key_vault.appgw_kv.id
	tenant_id    = data.azurerm_client_config.current.tenant_id
	object_id    = data.azurerm_client_config.current.object_id

	certificate_permissions = ["Create", "Delete", "Get", "Import", "List", "Update"]
	secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
	key_permissions         = ["Create", "Delete", "Get", "Import", "List", "Update", "Recover", "Purge"]
}

resource "azurerm_key_vault_access_policy" "appgw" {
	key_vault_id = azurerm_key_vault.appgw_kv.id
	tenant_id    = data.azurerm_client_config.current.tenant_id
	object_id    = azurerm_user_assigned_identity.appgw_identity.principal_id

	secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_certificate" "appgw_cert" {
	name         = var.ssl_certificate_name
	key_vault_id = azurerm_key_vault.appgw_kv.id

	certificate_policy {
		issuer_parameters {
			name = "Self"
		}

		key_properties {
			exportable = true
			key_size   = 2048
			key_type   = "RSA"
			reuse_key  = true
		}

		secret_properties {
			content_type = "application/x-pkcs12"
		}

		x509_certificate_properties {
			subject            = var.ssl_certificate_subject
			validity_in_months = 12
			key_usage = [
				"digitalSignature",
				"keyEncipherment"
			]
			extended_key_usage = ["1.3.6.1.5.5.7.3.1"]
		}
	}

	depends_on = [azurerm_key_vault_access_policy.current]
}

resource "azurerm_public_ip" "appgw_pip" {
	name                = "${var.project_name}-appgw-pip"
	resource_group_name = var.resource_group_name
	location            = var.location
	allocation_method   = "Static"
	sku                 = "Standard"
	tags                = var.tags
}

resource "azurerm_application_gateway" "appgw" {
	name                = "${var.project_name}-appgw"
	resource_group_name = var.resource_group_name
	location            = var.location
	tags                = var.tags

	identity {
		type         = "UserAssigned"
		identity_ids = [azurerm_user_assigned_identity.appgw_identity.id]
	}

	sku {
		name     = var.app_gateway_sku_name
		tier     = var.app_gateway_sku_name
		capacity = var.app_gateway_capacity
	}

	waf_configuration {
		enabled          = true
		firewall_mode    = var.waf_mode
		rule_set_type    = "OWASP"
		rule_set_version = "3.2"
	}

	ssl_policy {
		policy_type = "Predefined"
		policy_name = "AppGwSslPolicy20220101S"
	}

	gateway_ip_configuration {
		name      = "appgw-ip-config"
		subnet_id = var.app_gateway_subnet_id
	}

	frontend_port {
		name = "http-port"
		port = 80
	}

	frontend_port {
		name = "https-port"
		port = 443
	}

	frontend_ip_configuration {
		name                 = "public-frontend"
		public_ip_address_id = azurerm_public_ip.appgw_pip.id
	}

	ssl_certificate {
		name                = var.ssl_certificate_name
		key_vault_secret_id = azurerm_key_vault_certificate.appgw_cert.secret_id
	}

	backend_address_pool {
		name         = "app-backend-pool"
		fqdns        = var.backend_fqdns
		ip_addresses = var.backend_ip_addresses
	}

	backend_http_settings {
		name                  = "http-backend-settings"
		cookie_based_affinity = "Disabled"
		port                  = var.backend_port
		protocol              = var.backend_protocol
		host_name             = var.backend_host_name
		request_timeout       = 30
		probe_name            = "app-health-probe"
	}

	probe {
		name                = "app-health-probe"
		host                = var.backend_host_name
		protocol            = var.backend_protocol
		path                = "/"
		interval            = 30
		timeout             = 30
		unhealthy_threshold = 3
		minimum_servers     = 0
	}

	url_path_map {
		name                               = "app-path-map"
		default_backend_address_pool_name  = "app-backend-pool"
		default_backend_http_settings_name = "http-backend-settings"

		path_rule {
			name                       = "api-path-rule"
			paths                      = ["/api/*"]
			backend_address_pool_name  = "app-backend-pool"
			backend_http_settings_name = "http-backend-settings"
		}
	}

	http_listener {
		name                           = "http-listener"
		frontend_ip_configuration_name = "public-frontend"
		frontend_port_name             = "http-port"
		protocol                       = "Http"
	}

	http_listener {
		name                           = "https-listener"
		frontend_ip_configuration_name = "public-frontend"
		frontend_port_name             = "https-port"
		protocol                       = "Https"
		ssl_certificate_name           = var.ssl_certificate_name
	}

	redirect_configuration {
		name                 = "http-to-https-redirect"
		redirect_type        = "Permanent"
		target_listener_name = "https-listener"
		include_path         = true
		include_query_string = true
	}

	request_routing_rule {
		name                        = "http-redirect-rule"
		rule_type                   = "Basic"
		http_listener_name          = "http-listener"
		redirect_configuration_name = "http-to-https-redirect"
		priority                    = 90
	}

	request_routing_rule {
		name               = "https-app-routing-rule"
		rule_type          = "PathBasedRouting"
		http_listener_name = "https-listener"
		url_path_map_name  = "app-path-map"
		priority           = 100
	}

	depends_on = [azurerm_key_vault_access_policy.appgw]
}
