# Outputs for Test SQL Module (azurerm v3.x)

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_sql_server.sql.id
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_sql_server.sql.fully_qualified_domain_name
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_sql_server.sql.name
}

output "database_id" {
  description = "ID of the SQL Database"
  value       = azurerm_sql_database.db.id
}

output "database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_sql_database.db.name
}

output "elastic_pool_id" {
  description = "ID of the SQL Elastic Pool"
  value       = azurerm_sql_elasticpool.pool.id
}

output "elastic_pool_name" {
  description = "Name of the SQL Elastic Pool"
  value       = azurerm_sql_elasticpool.pool.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "sql_subnet_id" {
  description = "ID of the SQL subnet"
  value       = azurerm_subnet.sql_subnet.id
}

output "firewall_rules" {
  description = "List of firewall rule names configured"
  value = [
    azurerm_sql_firewall_rule.allow_azure.name,
    azurerm_sql_firewall_rule.allow_office.name
  ]
}
