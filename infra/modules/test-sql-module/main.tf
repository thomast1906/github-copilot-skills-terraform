
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    project     = "terraform-provider-upgrade-test"
    owner       = "devops-team"
    cost-center = "engineering"
    managed-by  = "terraform"
  }
}

resource "azurerm_mssql_server" "sql" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  tags = {
    environment = var.environment
    project     = "terraform-provider-upgrade-test"
    owner       = "devops-team"
    cost-center = "engineering"
    managed-by  = "terraform"
  }
}

moved {
  from = azurerm_sql_server.sql
  to   = azurerm_mssql_server.sql
}

resource "azurerm_mssql_database" "db" {
  name      = var.database_name
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S1"

  tags = {
    environment = var.environment
    project     = "terraform-provider-upgrade-test"
    owner       = "devops-team"
    cost-center = "engineering"
    managed-by  = "terraform"
  }
}

moved {
  from = azurerm_sql_database.db
  to   = azurerm_mssql_database.db
}

resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "allow-azure-services"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

moved {
  from = azurerm_sql_firewall_rule.allow_azure
  to   = azurerm_mssql_firewall_rule.allow_azure
}

resource "azurerm_mssql_firewall_rule" "allow_office" {
  name             = "allow-office-network"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = var.office_ip_start
  end_ip_address   = var.office_ip_end
}

moved {
  from = azurerm_sql_firewall_rule.allow_office
  to   = azurerm_mssql_firewall_rule.allow_office
}

resource "azurerm_mssql_virtual_network_rule" "vnet_rule" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.sql.id
  subnet_id = azurerm_subnet.sql_subnet.id
}

moved {
  from = azurerm_sql_virtual_network_rule.vnet_rule
  to   = azurerm_mssql_virtual_network_rule.vnet_rule
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = var.environment
    project     = "terraform-provider-upgrade-test"
    owner       = "devops-team"
    cost-center = "engineering"
    managed-by  = "terraform"
  }
}

resource "azurerm_subnet" "sql_subnet" {
  name                 = "sql-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_mssql_elasticpool" "pool" {
  name                = var.elastic_pool_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_mssql_server.sql.name
  sku {
    name     = "StandardPool"
    tier     = "Standard"
    capacity = 100
  }
  per_database_settings {
    min_capacity = 0
    max_capacity = 50
  }
  max_size_gb = 50

  tags = {
    environment = var.environment
    project     = "terraform-provider-upgrade-test"
    owner       = "devops-team"
    cost-center = "engineering"
    managed-by  = "terraform"
  }
}

moved {
  from = azurerm_sql_elasticpool.pool
  to   = azurerm_mssql_elasticpool.pool
}
