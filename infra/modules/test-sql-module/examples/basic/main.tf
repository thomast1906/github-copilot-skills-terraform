# Example Usage of Test SQL Module (v3.x)

# Use the test-sql-module
module "test_sql" {
  source = "../../"

  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment

  sql_server_name    = var.sql_server_name
  sql_admin_username = var.sql_admin_username
  sql_admin_password = var.sql_admin_password

  database_name     = var.database_name
  elastic_pool_name = var.elastic_pool_name

  vnet_name = var.vnet_name

  office_ip_start = var.office_ip_start
  office_ip_end   = var.office_ip_end
}
