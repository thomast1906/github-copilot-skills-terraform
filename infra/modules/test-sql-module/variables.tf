# Variables for Test SQL Module (azurerm v3.x)

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-sqltest-dev-eastus-001"

  validation {
    condition     = can(regex("^rg-", var.resource_group_name))
    error_message = "Resource group name must start with 'rg-' prefix."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"

  validation {
    condition     = contains(["East US", "West US", "Central US", "UK South", "West Europe"], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
  default     = "sql-testserver-dev-eastus-001"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.sql_server_name))
    error_message = "SQL Server name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "sqladmin"

  validation {
    condition     = length(var.sql_admin_username) >= 4
    error_message = "SQL admin username must be at least 4 characters."
  }
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.sql_admin_password) >= 12
    error_message = "SQL admin password must be at least 12 characters."
  }
}

variable "database_name" {
  description = "Name of the SQL database"
  type        = string
  default     = "testdb"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.database_name))
    error_message = "Database name must contain only alphanumeric characters, underscores, or hyphens."
  }
}

variable "office_ip_start" {
  description = "Start IP address for office network firewall rule"
  type        = string
  default     = "203.0.113.0"

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.office_ip_start))
    error_message = "Must be a valid IPv4 address."
  }
}

variable "office_ip_end" {
  description = "End IP address for office network firewall rule"
  type        = string
  default     = "203.0.113.255"

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.office_ip_end))
    error_message = "Must be a valid IPv4 address."
  }
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-sqltest-dev-eastus-001"

  validation {
    condition     = can(regex("^vnet-", var.vnet_name))
    error_message = "VNet name must start with 'vnet-' prefix."
  }
}

variable "elastic_pool_name" {
  description = "Name of the SQL elastic pool"
  type        = string
  default     = "pool-sqltest-dev-eastus-001"

  validation {
    condition     = can(regex("^pool-", var.elastic_pool_name))
    error_message = "Elastic pool name must start with 'pool-' prefix."
  }
}
