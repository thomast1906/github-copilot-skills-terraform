# Terraform Provider Upgrade: AzureRM v3.x → v4.58.0

**Date:** 2026-01-27

## Summary

Upgraded HashiCorp AzureRM provider from `~> 3.0` to `4.58.0` in the `test-sql-module`. This major version upgrade included automatic migration of all removed SQL resources to their modern MSSQL equivalents using `moved` blocks.

## What Changed

- Updated `required_providers` version constraint to `4.58.0`
- Migrated all `azurerm_sql_*` resources → `azurerm_mssql_*` equivalents
- Replaced deprecated `skip_provider_registration` with `resource_provider_registrations`
- Updated argument references from name-based to ID-based where required
- Added `moved` blocks for automatic state migration

## Breaking Changes Handled

### ✅ 1. azurerm_sql_server → azurerm_mssql_server

- **Files Modified:** `infra/modules/test-sql-module/main.tf`
- **Changes Applied:**
  - Updated resource type
  - Added `moved` block for automatic state migration
  - All arguments remain compatible
- **Argument Mappings:** No changes required (schema compatible)
- **Default Values:** No new default value changes
- **Documentation:** [azurerm_mssql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server)

### ✅ 2. azurerm_sql_database → azurerm_mssql_database

- **Files Modified:** `infra/modules/test-sql-module/main.tf`
- **Changes Applied:**
  - Updated resource type
  - Changed arguments to use server ID reference
  - Combined edition and service objective into sku_name
  - Added `moved` block for automatic state migration
- **Argument Mappings:**
  - `resource_group_name` (removed - inherited from server)
  - `location` (removed - inherited from server)
  - `server_name` → `server_id` (now uses `azurerm_mssql_server.sql.id`)
  - `edition` + `requested_service_objective_name` → `sku_name = "S1"`
- **Default Values:** No new default value changes
- **Documentation:** [azurerm_mssql_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database)

### ✅ 3. azurerm_sql_firewall_rule → azurerm_mssql_firewall_rule (2 instances)

- **Files Modified:** `infra/modules/test-sql-module/main.tf`
- **Resources Migrated:**
  - `azurerm_sql_firewall_rule.allow_azure`
  - `azurerm_sql_firewall_rule.allow_office`
- **Changes Applied:**
  - Updated resource types
  - Changed from name-based to ID-based server reference
  - Added `moved` blocks for both instances
- **Argument Mappings:**
  - `resource_group_name` (removed)
  - `server_name` → `server_id` (now uses `azurerm_mssql_server.sql.id`)
- **Default Values:** No new default value changes
- **Documentation:** [azurerm_mssql_firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule)

### ✅ 4. azurerm_sql_virtual_network_rule → azurerm_mssql_virtual_network_rule

- **Files Modified:** `infra/modules/test-sql-module/main.tf`
- **Changes Applied:**
  - Updated resource type
  - Changed to ID-based server reference
  - Added `moved` block for automatic state migration
- **Argument Mappings:**
  - `resource_group_name` (removed)
  - `server_name` → `server_id` (now uses `azurerm_mssql_server.sql.id`)
- **Default Values:** No new default value changes
- **Documentation:** [azurerm_mssql_virtual_network_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_network_rule)

### ✅ 5. azurerm_sql_elasticpool → azurerm_mssql_elasticpool

- **Files Modified:** `infra/modules/test-sql-module/main.tf`
- **Changes Applied:**
  - Updated resource type
  - Restructured SKU and capacity configuration
  - Added `moved` block for automatic state migration
- **Argument Mappings:**
  - `edition` + `dtu` → `sku { name, tier, capacity }`
  - `db_dtu_min` + `db_dtu_max` → `per_database_settings { min_capacity, max_capacity }`
  - `pool_size` → `max_size_gb` (converted from bytes to GB: 50000 bytes → 50 GB)
- **Default Values:** No new default value changes
- **Documentation:** [azurerm_mssql_elasticpool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_elasticpool)

### ✅ 6. Deprecated Provider Property Replaced

- **Files Modified:** `infra/modules/test-sql-module/versions.tf`
- **Changes Applied:**
  - Replaced `skip_provider_registration = true`
  - With `resource_provider_registrations = "none"`
- **Reason:** `skip_provider_registration` deprecated in AzureRM v4.0
- **Documentation:** [AzureRM 4.0 Upgrade Guide - Resource Provider Registrations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide#resource-provider-registrations)

## State Migration

Terraform will automatically migrate state using the `moved` blocks on the next plan/apply. The moved blocks instruct Terraform to update resource addresses in the state file without recreating infrastructure.

**Total moved blocks added:** 6

## Files Modified

- `infra/modules/test-sql-module/versions.tf` - Updated provider version and configuration
- `infra/modules/test-sql-module/main.tf` - Migrated all SQL resources with moved blocks

## Notes

- All changes are backward compatible with existing Azure infrastructure
- No resources will be destroyed and recreated
- `moved` blocks enable automatic state migration during next terraform plan/apply
- No manual `terraform state mv` commands required

## Next Steps

1. **Commit these changes** to a feature branch
2. **Run your Terraform workflow** via CI/CD pipeline to validate
3. **Review plan output** to confirm state migrations:
   - Look for messages like: `# azurerm_sql_server.sql has moved to azurerm_mssql_server.sql`
   - Plan should show `0 to add, 0 to change, 0 to destroy` if only moved blocks changed
4. **Verify no unexpected changes** before merging
5. After successful apply, moved blocks can remain in code or be removed once all environments are upgraded

## References

- [AzureRM Provider 4.0 Upgrade Guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide)
- [AzureRM Provider v4.58.0 Release Notes](https://github.com/hashicorp/terraform-provider-azurerm/releases/tag/v4.58.0)
- [Terraform Moved Blocks Documentation](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)
- [Removed Resources Guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide#removed-resources)
