# Azure Verified Modules Reference Guide

This reference contains detailed technical information about Azure Verified Modules (AVM) patterns.

## AVM Module Catalog

Browse implementations: https://azure.github.io/Azure-Verified-Modules/
Terraform Registry: https://registry.terraform.io/namespaces/Azure

## Common AVM Modules to Study

| Module | Learn From It |
|--------|---------------|
| `avm-res-storage-storageaccount` | Storage security defaults, network rules, container management |
| `avm-res-keyvault-vault` | RBAC patterns, purge protection, network ACLs |
| `avm-res-compute-virtualmachine` | Managed identity setup, diagnostic settings |
| `avm-res-network-virtualnetwork` | Subnet delegation, NSG associations |
| `avm-res-web-site` | App Service security, identity configuration |

## Module File Templates

When creating custom modules, use these templates learned from AVM patterns:

### main.tf - Define actual Azure resources

```hcl
resource "azurerm_{resource_type}" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  # Resource-specific configuration
  # Use dynamic blocks for optional nested blocks
  
  tags = merge(var.tags, { managed-by = "terraform" })
}
```

### variables.tf - With validation

```hcl
variable "name" {
  type        = string
  description = "Resource name"
  
  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.name))
    error_message = "Name must be 3-24 characters, lowercase alphanumeric and hyphens"
  }
}

variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
```

### outputs.tf - Essential outputs

```hcl
output "id" {
  description = "The resource ID"
  value       = azurerm_{resource_type}.this.id
}

output "name" {
  description = "The resource name"
  value       = azurerm_{resource_type}.this.name
}
```

### versions.tf - Provider constraints

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}
```

## Security Configuration Patterns

### Storage Account Security Defaults

```hcl
resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # Security defaults learned from AVM
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  public_network_access_enabled   = false
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false
  
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}
```

### Variable Validation Patterns

```hcl
variable "name" {
  type        = string
  description = "Storage account name"
  
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Name must be 3-24 characters, lowercase letters and numbers only."
  }
}
```

### Dynamic Block Patterns

```hcl
resource "azurerm_storage_account" "this" {
  # ... other config ...
  
  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }
}
```

### Child Resource Patterns

```hcl
resource "azurerm_storage_container" "this" {
  for_each = var.containers
  
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value.public_access
}

resource "azurerm_storage_share" "this" {
  for_each = var.shares
  
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name
  quota                = each.value.quota
}
```

## Key Vault Security Patterns

```hcl
resource "azurerm_key_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Security defaults from AVM
  enabled_for_disk_encryption     = true
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true
  enable_rbac_authorization       = true
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}
```

## What NOT to Do

❌ **DON'T copy AVM by calling it as a module:**
```hcl
# This defeats the purpose - just creates a wrapper
module "storage_wrapper" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.2.0"
  name    = var.name
}
```

✅ **DO learn patterns and implement resources directly:**
```hcl
# This is what we want - actual resource using AVM patterns
resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # Using security patterns learned from AVM
  min_tls_version           = "TLS1_2"
  https_traffic_only_enabled = true
}
```
