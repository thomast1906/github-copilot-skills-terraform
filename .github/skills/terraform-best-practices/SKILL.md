---
name: terraform-best-practices
description: General Terraform best practices and conventions for writing maintainable, efficient infrastructure code. Use this skill when writing Terraform configurations, organizing code structure, managing state, working with modules, count vs for_each, dynamic blocks, data sources, Terraform functions, or following HashiCorp style guide.
metadata:
  author: github-copilot-skills-terraform
  version: "1.0.0"
  category: terraform-general
---

# Terraform Best Practices Skill

This skill provides general Terraform best practices and conventions that apply to any provider, helping you write maintainable, efficient, and idiomatic infrastructure code.

## When to Use This Skill

- Writing Terraform configurations from scratch
- Refactoring existing Terraform code
- Choosing between `count` vs `for_each`
- Organizing Terraform files and modules
- Working with state management
- Understanding Terraform functions and expressions
- Following HashiCorp coding standards

## Core Best Practices

### 1. Use `for_each` Over `count`

**Prefer `for_each` for collections:**

```hcl
# ✅ GOOD - Stable resource addressing
resource "azurerm_resource_group" "this" {
  for_each = toset(var.resource_groups)
  
  name     = each.value
  location = var.location
}
```

**Avoid `count` for collections:**

```hcl
# ❌ BAD - Fragile, reordering causes destruction
resource "azurerm_resource_group" "this" {
  count = length(var.resource_groups)
  
  name     = var.resource_groups[count.index]
  location = var.location
}
```

**When to use `count`:**
- Binary decisions (create or don't create)
- Creating N identical resources
- Conditional resource creation

```hcl
# ✅ GOOD - Conditional resource
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0
  
  name               = "diagnostics"
  target_resource_id = azurerm_resource.main.id
}
```

### 2. Local Values vs Variables

**Variables** - For user-provided input:
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

**Locals** - For computed/derived values:
```hcl
locals {
  resource_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, {
    ManagedBy   = "Terraform"
    Environment = var.environment
  })
}
```

### 3. Dynamic Blocks

Use dynamic blocks for repeating nested blocks:

```hcl
resource "azurerm_network_security_group" "this" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = var.security_rules
    
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
```

### 4. Data Sources vs Resources

**Data sources** - Read existing infrastructure:
```hcl
data "azurerm_resource_group" "existing" {
  name = "existing-rg"
}

resource "azurerm_storage_account" "this" {
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  # ...
}
```

**Resources** - Create new infrastructure:
```hcl
resource "azurerm_resource_group" "new" {
  name     = "new-rg"
  location = "eastus"
}
```

### 5. File Organization

**Standard module structure:**
```
module/
├── main.tf           # Primary resource definitions
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Provider requirements
├── locals.tf         # Local values (optional)
├── data.tf           # Data sources (optional)
└── README.md         # Documentation
```

**Keep files focused:**
- `main.tf` - Core resources
- `networking.tf` - Network-related resources (if complex)
- `security.tf` - Security resources (if complex)
- `iam.tf` - IAM/RBAC resources (if complex)

### 6. State Management

**Always use remote state:**

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

**Enable state locking and encryption:**
- Azure Blob Storage provides automatic locking
- Enable encryption at rest on storage account
- Use separate state files per environment

### 7. Naming Conventions

**Resource names in code:**
- Use `this` for single resources
- Use `main` when there are supporting resources
- Use descriptive names for multiple similar resources

```hcl
resource "azurerm_storage_account" "this" {
  # Single storage account
}

resource "azurerm_storage_account" "logs" {
  # Specific purpose
}

resource "azurerm_storage_account" "data" {
  # Different specific purpose
}
```

**Resource names in Azure:**
- Follow provider-specific naming conventions
- Use variables for naming to enable reuse
- Apply consistent prefixes/suffixes

### 8. Common Terraform Functions

**String manipulation:**
```hcl
locals {
  uppercase_env = upper(var.environment)
  lowercase_env = lower(var.environment)
  trimmed       = trim(var.input, " ")
  replaced      = replace(var.name, "_", "-")
}
```

**Collection manipulation:**
```hcl
locals {
  # Merge maps
  all_tags = merge(var.default_tags, var.custom_tags)
  
  # Flatten nested lists
  all_subnets = flatten([
    for vnet in var.vnets : vnet.subnets
  ])
  
  # Convert list to set
  unique_regions = toset(var.regions)
}
```

**Type conversions:**
```hcl
locals {
  port_number = tonumber(var.port_string)
  port_string = tostring(var.port_number)
  config_json = jsonencode(var.config_map)
}
```

### 9. Meta-Arguments

**depends_on** - Explicit dependencies:
```hcl
resource "azurerm_role_assignment" "this" {
  depends_on = [azurerm_resource_group.main]
  # ...
}
```

**lifecycle** - Resource behavior:
```hcl
resource "azurerm_storage_account" "this" {
  # ...
  
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}
```

**provisioner** - Last resort only:
```hcl
# ⚠️ Avoid provisioners when possible
# Use cloud-init, user_data, or configuration management instead
```

## Common Anti-Patterns to Avoid

❌ **Hardcoded values:**
```hcl
# BAD
resource "azurerm_resource_group" "this" {
  name     = "my-rg-prod"
  location = "eastus"
}
```

✅ **Use variables:**
```hcl
# GOOD
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}
```

❌ **Mixing resource types in modules:**
```hcl
# BAD - Storage + networking in one module
module "infrastructure" {
  source = "./modules/everything"
}
```

✅ **Single responsibility modules:**
```hcl
# GOOD - Focused modules
module "storage" {
  source = "./modules/storage"
}

module "networking" {
  source = "./modules/networking"
}
```

## Additional Resources

For detailed examples, advanced patterns, and troubleshooting guides, see the [reference guide](references/REFERENCE.md).

For curated links to official HashiCorp documentation, tools, and community resources, see the [links reference](references/LINKS.md).

## HashiCorp Documentation

When you need specific syntax or function details, reference:
- **Terraform Language**: https://developer.hashicorp.com/terraform/language
- **Functions**: https://developer.hashicorp.com/terraform/language/functions
- **Expressions**: https://developer.hashicorp.com/terraform/language/expressions
