
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

resource "azurerm_sql_server" "sql" {
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

resource "azurerm_sql_database" "db" {
  name                             = var.database_name
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  server_name                      = azurerm_sql_server.sql.name
  edition                          = "Standard"
  requested_service_objective_name = "S1"

  tags = {
    environment = var.environment
    project     = "terraform-provider-upgrade-test"
    owner       = "devops-team"
    cost-center = "engineering"
    managed-by  = "terraform"
  }
}

resource "azurerm_sql_firewall_rule" "allow_azure" {
  name                = "allow-azure-services"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_firewall_rule" "allow_office" {
  name                = "allow-office-network"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql.name
  start_ip_address    = var.office_ip_start
  end_ip_address      = var.office_ip_end
}

resource "azurerm_sql_virtual_network_rule" "vnet_rule" {
  name                = "sql-vnet-rule"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql.name
  subnet_id           = azurerm_subnet.sql_subnet.id
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

resource "azurerm_sql_elasticpool" "pool" {
  name                = var.elastic_pool_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql.name
  edition             = "Standard"
  dtu                 = 100
  db_dtu_min          = 0
  db_dtu_max          = 50
  pool_size           = 50000

  tags = {
    environment = var.environment
    project     = "terraform-provider-upgrade-test"
    owner       = "devops-team"
    cost-center = "engineering"
    managed-by  = "terraform"
  }
}
