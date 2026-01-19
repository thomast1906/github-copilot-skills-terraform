# Terraform Best Practices - Detailed Reference

This reference provides detailed patterns, examples, and advanced guidance for Terraform best practices.

## Advanced for_each Patterns

### Creating Multiple Resources with Complex Keys

```hcl
variable "storage_accounts" {
  type = map(object({
    location                 = string
    account_tier            = string
    account_replication_type = string
  }))
}

resource "azurerm_storage_account" "this" {
  for_each = var.storage_accounts
  
  name                     = each.key
  location                 = each.value.location
  resource_group_name      = var.resource_group_name
  account_tier            = each.value.account_tier
  account_replication_type = each.value.account_replication_type
}
```

### Nested for_each

```hcl
locals {
  # Flatten nested structure
  subnets = flatten([
    for vnet_key, vnet in var.vnets : [
      for subnet_key, subnet in vnet.subnets : {
        vnet_key   = vnet_key
        subnet_key = subnet_key
        vnet_name  = vnet.name
        subnet     = subnet
      }
    ]
  ])
  
  # Create map with compound key
  subnets_map = {
    for subnet in local.subnets :
    "${subnet.vnet_key}-${subnet.subnet_key}" => subnet
  }
}

resource "azurerm_subnet" "this" {
  for_each = local.subnets_map
  
  name                 = each.value.subnet.name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = var.resource_group_name
  address_prefixes     = each.value.subnet.address_prefixes
}
```

## Complex Variable Validation

### Multiple Validation Rules

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
  
  validation {
    condition     = length(var.environment) <= 10
    error_message = "Environment name must be 10 characters or less."
  }
}
```

### Cross-Variable Validation with Locals

```hcl
variable "min_capacity" {
  type = number
}

variable "max_capacity" {
  type = number
}

locals {
  capacity_valid = var.min_capacity <= var.max_capacity
  
  # Force error if validation fails
  capacity_check = local.capacity_valid ? "valid" : file("ERROR: min_capacity must be <= max_capacity")
}
```

## State Management Deep Dive

### State File Organization

**Option 1: Environment-based separation**
```
terraform/
├── dev/
│   ├── main.tf
│   └── backend.tf  # key = "dev.tfstate"
├── staging/
│   ├── main.tf
│   └── backend.tf  # key = "staging.tfstate"
└── prod/
    ├── main.tf
    └── backend.tf  # key = "prod.tfstate"
```

**Option 2: Workspace-based separation**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    # Different workspaces store in different blob versions
  }
}
```

### State Import

```bash
# Import existing resource
terraform import azurerm_resource_group.main /subscriptions/{sub-id}/resourceGroups/{rg-name}

# Import with for_each
terraform import 'azurerm_storage_account.this["primary"]' /subscriptions/{sub-id}/...

# Import multiple resources
for rg in $(az group list --query "[].name" -o tsv); do
  terraform import "azurerm_resource_group.imported[\"$rg\"]" "/subscriptions/{sub-id}/resourceGroups/$rg"
done
```

### State Operations

```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show azurerm_resource_group.main

# Move resource in state
terraform state mv azurerm_storage_account.old azurerm_storage_account.new

# Remove resource from state (keeps in Azure)
terraform state rm azurerm_storage_account.removed

# Pull state for inspection
terraform state pull > state.json
```

## Module Composition Patterns

### Wrapper Modules

Sometimes wrapper modules are appropriate for standardization:

```hcl
# modules/standard-storage-account/main.tf
module "storage" {
  source = "../../base-modules/storage-account"
  
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  # Apply organization standards
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true
  
  tags = merge(var.tags, {
    ManagedBy   = "Terraform"
    Compliance  = "Standard"
  })
}
```

### Child Modules

```hcl
# Root module calls child modules
module "networking" {
  source = "./modules/networking"
  
  vnet_name           = "main-vnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

module "security" {
  source = "./modules/security"
  
  subnet_ids = module.networking.subnet_ids
  location   = azurerm_resource_group.main.location
}
```

## Advanced Dynamic Blocks

### Conditional Dynamic Blocks

```hcl
resource "azurerm_linux_virtual_machine" "this" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  
  # Only create identity block if enabled
  dynamic "identity" {
    for_each = var.enable_managed_identity ? [1] : []
    
    content {
      type = "SystemAssigned"
    }
  }
  
  # Multiple data disks
  dynamic "data_disk" {
    for_each = var.data_disks
    
    content {
      lun                  = data_disk.key
      disk_size_gb         = data_disk.value.size
      caching              = data_disk.value.caching
      storage_account_type = data_disk.value.storage_type
    }
  }
}
```

## Terraform Functions Reference

### String Functions

```hcl
locals {
  # Format strings
  formatted = format("rg-%s-%s-%03d", var.project, var.env, var.instance)
  
  # Join/Split
  joined = join("-", ["rg", var.project, var.env])
  parts  = split("-", "rg-project-prod")
  
  # Substring operations
  prefix    = substr(var.long_string, 0, 10)
  trimmed   = trimspace("  text  ")
  lowercase = lower("TEXT")
  uppercase = upper("text")
}
```

### Collection Functions

```hcl
locals {
  # Length
  count = length(var.items)
  
  # Lookup with default
  value = lookup(var.map, "key", "default")
  
  # Merge maps
  combined = merge(var.map1, var.map2)
  
  # Filter collections
  prod_only = {
    for k, v in var.resources : k => v
    if v.environment == "prod"
  }
  
  # Transform collections
  names = [for item in var.items : item.name]
  
  # Flatten nested structures
  all_ips = flatten([for vm in var.vms : vm.ip_addresses])
  
  # Distinct values
  unique = distinct(var.list_with_duplicates)
  
  # Set operations
  union_set = setunion(var.set1, var.set2)
  intersection = setintersection(var.set1, var.set2)
}
```

### Encoding Functions

```hcl
locals {
  # JSON encoding/decoding
  json_string = jsonencode(var.config)
  config_map  = jsondecode(file("config.json"))
  
  # YAML decoding
  yaml_config = yamldecode(file("config.yaml"))
  
  # Base64 encoding
  encoded = base64encode("plain text")
  decoded = base64decode(var.encoded_value)
}
```

### Filesystem Functions

```hcl
locals {
  # Read files
  script_content = file("${path.module}/scripts/init.sh")
  
  # Template rendering
  user_data = templatefile("${path.module}/templates/user-data.tpl", {
    hostname = var.hostname
    env      = var.environment
  })
  
  # Directory contents
  config_files = fileset(path.module, "configs/*.yaml")
}
```

### Type Conversion Functions

```hcl
locals {
  # Type conversions
  as_number = tonumber("42")
  as_string = tostring(42)
  as_bool   = tobool("true")
  
  # Collection conversions
  as_list = tolist(["a", "b", "c"])
  as_set  = toset(["a", "b", "c"])
  as_map  = tomap({key = "value"})
}
```

## Troubleshooting Common Issues

### Cycle Errors

```hcl
# ❌ BAD - Circular dependency
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  resource_group_name = azurerm_subnet.subnet.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ✅ GOOD - Break the cycle
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name = "subnet"
  # Associate NSG separately
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
```

### Provider Version Conflicts

```hcl
# ✅ Lock provider versions
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"  # Allows 4.x, but not 5.0
    }
  }
}
```

### Resource Address Changes

```bash
# Handle resource renames without recreation
terraform state mv \
  'azurerm_storage_account.old_name' \
  'azurerm_storage_account.new_name'

# Handle for_each conversion
terraform state mv \
  'azurerm_resource_group.rg[0]' \
  'azurerm_resource_group.rg["first"]'
```

## Performance Optimization

### Parallelism

```bash
# Increase parallelism (default is 10)
terraform apply -parallelism=20

# Reduce for rate-limited APIs
terraform apply -parallelism=5
```

### Targeted Operations

```bash
# Apply changes to specific resource
terraform apply -target=azurerm_resource_group.main

# Plan specific module
terraform plan -target=module.networking
```

### Refresh Optimization

```bash
# Skip refresh for faster plan
terraform plan -refresh=false

# Manual refresh
terraform refresh
```

## Testing Terraform Code

### Static Analysis

```bash
# Validate syntax
terraform validate

# Format code
terraform fmt -recursive

# Check formatting
terraform fmt -check

# Linting with tflint
tflint --init
tflint
```

### Plan Testing

```bash
# Generate plan for review
terraform plan -out=tfplan

# Show plan in JSON for parsing
terraform show -json tfplan > plan.json

# Analyze plan with tools
jq '.resource_changes[] | select(.change.actions[] | contains("delete"))' plan.json
```
