locals {
  sql_server_name = substr(lower(replace("${var.project_name}-sql", "_", "-")), 0, 63)
  database_name   = lower(replace(var.database_name, "_", "-"))
}

resource "azurerm_mssql_server" "sql_server" {
  name                          = local.sql_server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.administrator_login
  administrator_login_password  = var.administrator_login_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  tags = var.tags
}

resource "azurerm_mssql_database" "app_db" {
  name         = local.database_name
  server_id    = azurerm_mssql_server.sql_server.id
  sku_name     = var.database_sku_name
  max_size_gb  = var.database_max_size_gb
  zone_redundant = false

  tags = var.tags
}

resource "azurerm_mssql_virtual_network_rule" "allowed_subnets" {
  for_each = var.sql_allowed_subnet_ids

  name      = "${each.key}-sql-vnet-rule"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = each.value
}