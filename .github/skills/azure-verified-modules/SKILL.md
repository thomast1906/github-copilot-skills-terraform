---
name: azure-verified-modules
description: Research and learn from Azure Verified Modules (AVM) patterns to build better custom Terraform modules. Use this skill to reference AVM structure, security defaults, and best practices - NOT to consume AVM modules directly.
---

# Azure Verified Modules (Reference) Skill

This skill helps you learn from Azure Verified Modules (AVM) - Microsoft's official Terraform modules - to understand best practices, security patterns, and proper resource configuration when building your own custom modules.

## When to Use This Skill

- **Learning best practices** for Azure resource configuration
- **Researching security defaults** that Microsoft recommends
- **Understanding module structure** and organization patterns
- **Finding proper resource attributes** and configurations
- **Reference architecture** for custom module development

## How to Use AVM as Reference

**AVM provides examples of:**
- Security-first configurations (TLS versions, encryption, network rules)
- Proper variable validation patterns
- Output structure and naming conventions
- Dynamic blocks for optional resources
- Module organization and file structure

## Learning from AVM Structure

### 1. Security Defaults

Review AVM to understand Microsoft's recommended security settings:

```hcl
# Example: What we learn from AVM storage account patterns
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

### 2. Variable Validation Patterns

Learn validation rules from AVM:

```hcl
variable "name" {
  type        = string
  description = "Storage account name"
  
  # Validation pattern learned from AVM
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Name must be 3-24 characters, lowercase letters and numbers only."
  }
}
```

### 3. Dynamic Block Patterns

Understand how to handle optional nested configurations:

```hcl
# Pattern learned from AVM for optional network rules
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

## What are Azure Verified Modules?

Azure Verified Modules (AVM) are:

- **Microsoft-maintained** - Official support and regular updates
- **Security-reviewed** - Follows Azure security best practices
- **Well-documented** - Comprehensive examples and documentation
- **Tested** - Automated testing for reliability
- **Standardized** - Consistent interface across modules

## What are Azure Verified Modules?

Azure Verified Modules (AVM) are Microsoft's official Terraform modules that serve as **reference implementations** showing:

- **Security best practices** - Microsoft-recommended security configurations
- **Proper resource patterns** - How to structure and organize resources
- **Validation rules** - Input validation for Azure resource constraints
- **Output conventions** - Standard output naming and structure
- **Testing patterns** - How Microsoft tests infrastructure code

## Finding AVM for Reference

### Official AVM Catalog

Browse implementations: https://azure.github.io/Azure-Verified-Modules/

### Terraform Registry

View source code: https://registry.terraform.io/namespaces/Azure

### Common AVM Modules to Study

| Module | Learn From It |
|--------|---------------|
| `avm-res-storage-storageaccount` | Storage security defaults, network rules, container management |
| `avm-res-keyvault-vault` | RBAC patterns, purge protection, network ACLs |
| `avm-res-compute-virtualmachine` | Managed identity setup, diagnostic settings |
| `avm-res-network-virtualnetwork` | Subnet delegation, NSG associations |
| `avm-res-web-site` | App Service security, identity configuration |

## Using Terraform MCP Tools

### Search AVM for Patterns

```bash
# Use terraform MCP to find relevant AVM modules
search_modules("azure storage account verified")
```

### Get Module Details for Learning

```bash
# View AVM implementation details
get_module_details("Azure/avm-res-storage-storageaccount/azurerm")
```

This shows you:
- Input variables and their validation
- Security defaults used
- Output structure
- Resource relationships

## Example: Learning from AVM Storage Account

When creating a custom storage account module, reference AVM to learn:

### Security Configuration
```hcl
resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # Learned from AVM: Security-first defaults
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  min_tls_version          = "TLS1_2"
  https_traffic_only_enabled = true
  public_network_access_enabled = false
  shared_access_key_enabled = false
  allow_nested_items_to_be_public = false
  
  tags = merge(var.tags, { managed-by = "terraform" })
}
```

### Child Resource Patterns
```hcl
# Learned from AVM: How to handle optional child resources
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

### Network Rules Pattern
```hcl
# Learned from AVM: Dynamic blocks for optional configurations
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

## Key Learnings from AVM

### 1. Security Defaults
- Always enforce TLS 1.2 minimum
- Disable public access by default
- Use private endpoints for PaaS services
- Enable encryption at rest and in transit

### 2. Variable Design
- Add validation for Azure resource constraints
- Provide sensible defaults for optional values
- Use object types for complex configurations
- Document all variables with descriptions

### 3. Resource Organization
- Use `for_each` for child resources
- Implement dynamic blocks for optional configs
- Tag all resources consistently
- Name resources predictably

### 4. Output Structure
- Expose resource IDs
- Provide connection endpoints
- Mark sensitive values appropriately
- Use descriptive output names

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
  
  # ... rest of configuration
}
```
