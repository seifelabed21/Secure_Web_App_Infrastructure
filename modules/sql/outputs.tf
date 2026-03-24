output "sql_server_id" {
	description = "ID of the SQL server"
	value       = azurerm_mssql_server.sql_server.id
}

output "sql_server_name" {
	description = "Name of the SQL server"
	value       = azurerm_mssql_server.sql_server.name
}

output "sql_server_fqdn" {
	description = "FQDN of the SQL server"
	value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "database_id" {
	description = "ID of the SQL database"
	value       = azurerm_mssql_database.app_db.id
}

output "database_name" {
	description = "Name of the SQL database"
	value       = azurerm_mssql_database.app_db.name
}
