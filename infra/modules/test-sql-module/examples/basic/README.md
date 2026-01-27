# Basic Example - Test SQL Module (v3.x)

This example demonstrates using the test SQL module with azurerm provider v3.x.

## Purpose

Test automated provider upgrades from azurerm v3.x to v4.x using resources with known breaking changes.

## Prerequisites

- Terraform >= 1.3.0
- Azure CLI installed and authenticated (`az login`)
- Azure subscription with appropriate permissions

## Resources Deployed

- 1x Resource Group
- 1x SQL Server (v3.x deprecated resource)
- 1x SQL Database (v3.x deprecated resource)
- 1x SQL Elastic Pool (v3.x deprecated resource)
- 2x SQL Firewall Rules (v3.x deprecated resource)
- 1x SQL VNet Rule (v3.x deprecated resource)
- 1x Virtual Network
- 1x Subnet with SQL service endpoint

## Usage

### Step 1: Copy Configuration File

```bash
cp terraform.tfvars.example terraform.tfvars
```

### Step 2: Edit Configuration

Edit `terraform.tfvars` and customize:
- Resource names (must be globally unique for SQL server)
- Office IP range for firewall access
- SQL admin password (or use environment variable)

**Security Best Practice:**
```bash
# Don't store password in terraform.tfvars - use environment variable
export TF_VAR_sql_admin_password="YourSecurePassword123!"
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Plan Deployment

```bash
terraform plan
```

### Step 5: Apply Configuration

```bash
terraform apply
```

## Testing Provider Upgrade

### Current State (v3.x)

This example uses azurerm provider v3.x with deprecated SQL resources.

### Upgrade to v4.x

After deploying with v3.x, you can test the automated upgrade:

1. **Update provider version** in module's `versions.tf`:
   ```hcl
   required_providers {
     azurerm = {
       source  = "hashicorp/azurerm"
       version = "~> 4.0"
     }
   }
   ```

2. **Run upgrade automation:**
   - Automated tool detects removed resources
   - Adds `moved` blocks for state migration
   - Updates resource types (sql → mssql)
   - Updates argument references
   - Replaces deprecated provider config

3. **Validate migration:**
   ```bash
   terraform init -upgrade
   terraform plan  # Should show moves, no recreation
   terraform apply
   ```

## Expected Breaking Changes

| Old Resource | New Resource | Argument Changes |
|--------------|--------------|------------------|
| `azurerm_sql_server` | `azurerm_mssql_server` | None |
| `azurerm_sql_database` | `azurerm_mssql_database` | `server_name` → `server_id` |
| `azurerm_sql_firewall_rule` | `azurerm_mssql_firewall_rule` | `resource_group_name` + `server_name` → `server_id` |
| `azurerm_sql_virtual_network_rule` | `azurerm_mssql_virtual_network_rule` | `resource_group_name` + `server_name` → `server_id` |
| `azurerm_sql_elasticpool` | `azurerm_mssql_elasticpool` | `server_name` → `server_id` |

## Cost Estimate

**Approximate monthly cost (East US):**
- SQL Database (Standard S1): ~$30/month
- SQL Elastic Pool (100 DTU): ~$200/month
- Virtual Network: Free
- Negligible data transfer costs

**Total: ~$230/month**

⚠️ **Remember to destroy resources after testing!**

## Cleanup

```bash
terraform destroy
```

## Outputs

After successful deployment, you'll see:

- `resource_group_name` - Resource group name
- `sql_server_fqdn` - SQL server FQDN for connections
- `sql_server_id` - SQL server resource ID
- `database_name` - Database name
- `firewall_rules` - List of configured firewall rules
- And more...

## Troubleshooting

### SQL Server name already exists
SQL server names must be globally unique. Change `sql_server_name` in terraform.tfvars.

### Authentication failed
Run `az login` and ensure you have appropriate permissions.

### Provider version mismatch
Run `terraform init -upgrade` to download the correct provider version.

## Security Notes

🔒 This is a **TEST configuration** with simplified security:
- Public network access enabled
- Basic firewall rules
- Test password in example file

**For production:**
- Use Azure Key Vault for credentials
- Enable Microsoft Entra ID authentication
- Configure private endpoints
- Disable public network access
- Enable Advanced Threat Protection
- Configure audit logging
- Use TLS 1.2+

## References

- [Module README](../../README.md)
- [AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure SQL Best Practices](https://learn.microsoft.com/en-us/azure/azure-sql/database/security-best-practice)
