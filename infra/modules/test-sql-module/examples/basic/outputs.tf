# Outputs for Basic Example

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.test_sql.resource_group_id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.test_sql.resource_group_name
}

output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = module.test_sql.sql_server_id
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = module.test_sql.sql_server_fqdn
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = module.test_sql.sql_server_name
}

output "database_id" {
  description = "ID of the SQL Database"
  value       = module.test_sql.database_id
}

output "database_name" {
  description = "Name of the SQL Database"
  value       = module.test_sql.database_name
}

output "elastic_pool_id" {
  description = "ID of the SQL Elastic Pool"
  value       = module.test_sql.elastic_pool_id
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.test_sql.vnet_id
}

output "sql_subnet_id" {
  description = "ID of the SQL subnet"
  value       = module.test_sql.sql_subnet_id
}

output "firewall_rules" {
  description = "List of firewall rule names configured"
  value       = module.test_sql.firewall_rules
}
