# Test SQL Module for Provider Upgrade Testing

## Purpose

This module **intentionally uses deprecated Azure SQL resources** from azurerm provider v3.x to test automated provider upgrades to v4.x.

## Breaking Changes in v4.0

This module contains the following resources that were **REMOVED** in azurerm v4.0:

| v3.x Resource (Used Here) | v4.x Replacement | Breaking Changes |
|---------------------------|------------------|------------------|
| `azurerm_sql_server` | `azurerm_mssql_server` | None - direct rename |
| `azurerm_sql_database` | `azurerm_mssql_database` | `server_name` → `server_id`<br/>`edition` + `requested_service_objective_name` → `sku_name` |
| `azurerm_sql_firewall_rule` | `azurerm_mssql_firewall_rule` | `resource_group_name` + `server_name` → `server_id` |
| `azurerm_sql_virtual_network_rule` | `azurerm_mssql_virtual_network_rule` | `resource_group_name` + `server_name` → `server_id` |
| `azurerm_sql_elasticpool` | `azurerm_mssql_elasticpool` | `server_name` → `server_id` |

### Provider Configuration Changes

```hcl
# v3.x (Current - DEPRECATED)
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# v4.x (Target)
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}
```

## Module Structure

```
test-sql-module/
├── main.tf               # Resource definitions (v3.x deprecated resources)
├── variables.tf          # Input variables with validation
├── outputs.tf            # Module outputs
├── versions.tf           # Provider version constraints (v3.x)
├── README.md             # This file
└── examples/
    └── basic/
        ├── main.tf                  # Working example
        ├── variables.tf             # Example variables
        ├── outputs.tf               # Example outputs
        ├── terraform.tfvars.example # Sample configuration
        ├── example.auto.tfvars      # Auto-loaded test values
        └── README.md                # Example usage guide
```

## Resources Created

- **Resource Group** - Container for all resources
- **SQL Server** (v3.x) - Azure SQL logical server
- **SQL Database** (v3.x) - Single database in Standard tier (S1)
- **SQL Elastic Pool** (v3.x) - Elastic pool for shared resources
- **Firewall Rules** (v3.x):
  - Allow Azure Services (0.0.0.0)
  - Allow Office Network (configurable IP range)
- **Virtual Network** - For VNet service endpoints
- **Subnet** - With SQL service endpoint
- **VNet Rule** (v3.x) - Allow SQL access from subnet

## Usage

See the [examples/basic](./examples/basic/) directory for a complete working example.

```hcl
module "test_sql" {
  source = "../../modules/test-sql-module"

  resource_group_name = "rg-sqltest-dev-eastus-001"
  location            = "East US"
  environment         = "dev"
  
  sql_server_name     = "sql-testserver-dev-eastus-001"
  sql_admin_username  = "sqladmin"
  sql_admin_password  = var.sql_password  # Sensitive - use Key Vault
  
  database_name       = "testdb"
  elastic_pool_name   = "pool-sqltest-dev-eastus-001"
  
  vnet_name           = "vnet-sqltest-dev-eastus-001"
  
  office_ip_start     = "203.0.113.0"
  office_ip_end       = "203.0.113.255"
}
```

## Testing Upgrade Path

### Step 1: Deploy with v3.x (Current)

```bash
cd examples/basic
terraform init
terraform plan
terraform apply
```

### Step 2: Upgrade to v4.x

Update `versions.tf`:
```hcl
required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = "~> 4.0"
  }
}
```

### Step 3: Run Automated Migration

The upgrade should:
1. Detect removed resources
2. Add `moved` blocks for state migration
3. Update resource types
4. Update argument references (names → IDs)
5. Replace deprecated provider arguments
6. Update output references

### Step 4: Validate Migration

```bash
terraform init -upgrade
terraform plan  # Should show state moves, no resource recreation
terraform apply
```

## Expected Moved Blocks

After upgrade, these `moved` blocks should be added:

```hcl
moved {
  from = azurerm_sql_server.sql
  to   = azurerm_mssql_server.sql
}

moved {
  from = azurerm_sql_database.db
  to   = azurerm_mssql_database.db
}

moved {
  from = azurerm_sql_firewall_rule.allow_azure
  to   = azurerm_mssql_firewall_rule.allow_azure
}

moved {
  from = azurerm_sql_firewall_rule.allow_office
  to   = azurerm_mssql_firewall_rule.allow_office
}

moved {
  from = azurerm_sql_virtual_network_rule.vnet_rule
  to   = azurerm_mssql_virtual_network_rule.vnet_rule
}

moved {
  from = azurerm_sql_elasticpool.pool
  to   = azurerm_mssql_elasticpool.pool
}
```

## Security Notes

🔒 **DO NOT use this module in production!**

This is a **test module** for demonstrating provider upgrades. It contains:
- Hardcoded IP addresses for testing
- Simplified security configurations
- Public network access enabled (v3.x default)

For production SQL deployments:
- Use Azure Key Vault for credentials
- Configure private endpoints
- Enable Microsoft Entra ID authentication
- Follow Azure SQL security best practices

## Tags

All resources include standard tags:
- `environment` - dev/staging/prod
- `project` - terraform-provider-upgrade-test
- `owner` - devops-team
- `cost-center` - engineering
- `managed-by` - terraform

## References

- [AzureRM v4.0 Upgrade Guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide)
- [azurerm_mssql_server Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server)
- [Terraform Moved Blocks](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)
