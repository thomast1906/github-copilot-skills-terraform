# Variables for Basic Example

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-sqltest-dev-eastus-001"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
  default     = "sql-testserver-dev-eastus-001"
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the SQL database"
  type        = string
  default     = "testdb"
}

variable "office_ip_start" {
  description = "Start IP address for office network firewall rule"
  type        = string
  default     = "203.0.113.0"
}

variable "office_ip_end" {
  description = "End IP address for office network firewall rule"
  type        = string
  default     = "203.0.113.255"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-sqltest-dev-eastus-001"
}

variable "elastic_pool_name" {
  description = "Name of the SQL elastic pool"
  type        = string
  default     = "pool-sqltest-dev-eastus-001"
}
