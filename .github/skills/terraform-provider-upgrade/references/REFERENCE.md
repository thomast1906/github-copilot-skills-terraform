# Terraform Provider Upgrade Reference Guide

Comprehensive reference for safely upgrading Terraform providers with automatic resource migration and state management.

## Table of Contents

1. [Understanding Breaking vs Non-Breaking Changes](#understanding-breaking-vs-non-breaking-changes)
2. [MCP Tools Usage](#mcp-tools-usage)
3. [Common Upgrade Patterns](#common-upgrade-patterns)
4. [Azure Provider Specific Guide](#azure-provider-specific-guide)
5. [Moved Blocks Deep Dive](#moved-blocks-deep-dive)
6. [Argument Mapping Patterns](#argument-mapping-patterns)
7. [Default Value Analysis](#default-value-analysis)
8. [Troubleshooting](#troubleshooting)
9. [Documentation Templates](#documentation-templates)

---

## Understanding Breaking vs Non-Breaking Changes

### Version Semantics

Terraform providers follow [Semantic Versioning](https://semver.org/):
- **Major version** (e.g., 3.x → 4.x): Breaking changes possible
- **Minor version** (e.g., 3.117.x → 3.118.x): New features, backward compatible
- **Patch version** (e.g., 3.117.0 → 3.117.1): Bug fixes, backward compatible

### Non-Breaking Changes

**Characteristics:**
- Minor or patch version bumps
- No removed resources
- No required argument changes
- Backward-compatible deprecations
- New optional arguments only
- Bug fixes

**Examples:**
```
azurerm 3.117.0 → 3.117.1 (patch)
azurerm 3.117.0 → 3.118.0 (minor)
```

**How to Handle:**
1. Update version constraint in `versions.tf`
2. Apply any backward-compatible deprecation replacements
3. Commit without detailed documentation
4. Use simple commit message: `chore: upgrade azurerm to v3.118.0`

**Do NOT create** `TERRAFORM_UPGRADE_BREAKING_CHANGES.md` for non-breaking changes.

### Breaking Changes

**Characteristics:**
- Major version changes (3.x → 4.x)
- Removed or superseded resources
- Required argument renames or type changes
- Default value changes affecting behavior
- Authentication mechanism changes
- Provider configuration changes

**Examples:**
```
azurerm 3.117.0 → 4.51.0 (major)
aws 4.x → 5.x (major)
```

**How to Handle:**
1. Get upgrade guide via MCP tools
2. Identify all breaking changes
3. Apply ALL code changes (migrations, moved blocks, argument updates)
4. Create `TERRAFORM_UPGRADE_BREAKING_CHANGES.md` at **repository root**
5. Document what was done (not manual steps)

### Using MCP Tools to Determine Change Type

```bash
# Step 1: Get latest version
get_latest_provider_version(namespace="hashicorp", name="azurerm")
# Returns: "4.51.0"

# Step 2: Compare with current version
# Current: 3.117.0, Latest: 4.51.0
# Major version difference (3.x → 4.x) = Likely breaking changes

# Step 3: Get upgrade guide to confirm
resolveProviderDocID(
  providerNamespace="hashicorp",
  providerName="azurerm",
  serviceSlug="4.0-upgrade-guide",
  providerDataType="guides",
  providerVersion="latest"
)
getProviderDocs(providerDocID="<id>")

# Step 4: Look for these indicators in upgrade guide:
# - "Removed Resources" section
# - "Breaking Changes" section  
# - Resources marked as "removed", "superseded", or "deprecated"
# - Arguments marked as "renamed", "removed", or "type changed"
# - "Behavior Changes" or "Default Value Changes"
```

### Decision Tree

```
Is this a major version change (X.y.z)?
├─ YES → Likely breaking changes
│   └─ Get upgrade guide via MCP tools
│       ├─ Breaking changes found?
│       │   ├─ YES → Apply migrations + Create documentation
│       │   └─ NO → Update version only (no documentation)
│       └─ Apply changes
└─ NO (minor/patch) → Non-breaking
    └─ Update version + Commit (no documentation)
```

---

## MCP Tools Usage

### Getting Latest Provider Version

```bash
# Get latest AzureRM provider version
get_latest_provider_version(
  namespace="hashicorp",
  name="azurerm"
)

# Response example:
# "4.51.0"
```

### Finding Provider Documentation

**Step 1: Resolve Documentation ID**

```bash
# Find upgrade guide
resolveProviderDocID(
  providerNamespace="hashicorp",
  providerName="azurerm",
  serviceSlug="4.0-upgrade-guide",
  providerDataType="guides",
  providerVersion="latest"
)

# Find resource documentation
resolveProviderDocID(
  providerNamespace="hashicorp",
  providerName="azurerm",
  serviceSlug="mssql_server",
  providerDataType="resources",
  providerVersion="latest"
)

# Find data source documentation
resolveProviderDocID(
  providerNamespace="hashicorp",
  providerName="azurerm",
  serviceSlug="mssql_server",
  providerDataType="data-sources",
  providerVersion="latest"
)
```

**Valid `providerDataType` values:**
- `resources` - Resource documentation (e.g., `azurerm_mssql_server`)
- `data-sources` - Data source documentation (e.g., `data.azurerm_mssql_server`)
- `guides` - Upgrade guides and tutorials
- `overview` - Provider overview and configuration

**Step 2: Fetch Documentation**

```bash
getProviderDocs(providerDocID="<id-from-resolve-call>")

# Returns full documentation in markdown format including:
# - Resource schema (arguments, attributes)
# - Examples
# - Import instructions
# - Upgrade notes
```

### Workflow Example

```bash
# 1. Check current vs latest version
get_latest_provider_version(namespace="hashicorp", name="azurerm")

# 2. Get upgrade guide
resolveProviderDocID(
  providerNamespace="hashicorp",
  providerName="azurerm",
  serviceSlug="4.0-upgrade-guide",
  providerDataType="guides",
  providerVersion="latest"
)
getProviderDocs(providerDocID="<id>")

# 3. Get old resource docs (v3.x)
resolveProviderDocID(
  providerNamespace="hashicorp",
  providerName="azurerm",
  serviceSlug="sql_server",
  providerDataType="resources",
  providerVersion="3.117.1"
)
getProviderDocs(providerDocID="<id>")

# 4. Get new resource docs (v4.x)
resolveProviderDocID(
  providerNamespace="hashicorp",
  providerName="azurerm",
  serviceSlug="mssql_server",
  providerDataType="resources",
  providerVersion="latest"
)
getProviderDocs(providerDocID="<id>")

# 5. Compare schemas and apply migrations
```

---

## Common Upgrade Patterns

### Pattern 1: Simple Resource Rename

**Scenario:** Resource type changed but arguments remain the same.

```hcl
# Before
resource "azurerm_sql_database" "db" {
  name                = "example-db"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql.name
}

# After
resource "azurerm_mssql_database" "db" {
  name      = "example-db"
  server_id = azurerm_mssql_server.sql.id  # Changed from server_name to server_id
}

# Moved block
moved {
  from = azurerm_sql_database.db
  to   = azurerm_mssql_database.db
}
```

**Key Changes:**
- Resource type: `azurerm_sql_database` → `azurerm_mssql_database`
- Removed: `resource_group_name`, `location` (inherited from server)
- Changed: `server_name` → `server_id` (name to ID reference)

### Pattern 2: Argument Type Changes (Name → ID)

**Scenario:** Arguments changed from name-based to ID-based references.

```hcl
# Before (v3.x) - Uses names
resource "azurerm_sql_firewall_rule" "example" {
  name                = "allow-azure"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# After (v4.x) - Uses ID
resource "azurerm_mssql_firewall_rule" "example" {
  name             = "allow-azure"
  server_id        = azurerm_mssql_server.sql.id  # Single ID replaces RG + name
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

moved {
  from = azurerm_sql_firewall_rule.example
  to   = azurerm_mssql_firewall_rule.example
}
```

**Migration Checklist:**
- ✅ Updated resource type
- ✅ Replaced `resource_group_name` + `server_name` with `server_id`
- ✅ Changed reference from `.name` to `.id`
- ✅ Added `moved` block

### Pattern 3: Deprecated Provider Arguments

**Scenario:** Provider block arguments deprecated.

```hcl
# Before
provider "azurerm" {
  features {}
  skip_provider_registration = true  # Deprecated in v4.0
}

# After
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"  # Modern replacement
}
```

**Common deprecated arguments:**
- `skip_provider_registration` → `resource_provider_registrations = "none"`
- Provider block `version` argument → Move to `required_providers` block

### Pattern 4: Multiple Resources in Module

**Scenario:** Module contains multiple related resources that all need migration.

```hcl
# main.tf - Before
resource "azurerm_sql_server" "sql" {
  name                         = "example-sqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_password
}

resource "azurerm_sql_firewall_rule" "allow_azure" {
  name                = "allow-azure"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_virtual_network_rule" "vnet_rule" {
  name                = "vnet-rule"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql.name
  subnet_id           = azurerm_subnet.example.id
}

# main.tf - After
resource "azurerm_mssql_server" "sql" {
  name                         = "example-sqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_password
}

resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "allow-azure"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_virtual_network_rule" "vnet_rule" {
  name      = "vnet-rule"
  server_id = azurerm_mssql_server.sql.id
  subnet_id = azurerm_subnet.example.id
}

# Moved blocks
moved {
  from = azurerm_sql_server.sql
  to   = azurerm_mssql_server.sql
}

moved {
  from = azurerm_sql_firewall_rule.allow_azure
  to   = azurerm_mssql_firewall_rule.allow_azure
}

moved {
  from = azurerm_sql_virtual_network_rule.vnet_rule
  to   = azurerm_mssql_virtual_network_rule.vnet_rule
}
```

---

## Azure Provider Specific Guide

### AzureRM v3.x → v4.x Upgrade

**Breaking Changes Summary:**

#### Removed Resources (Require Migration)

| Old Resource (v3.x) | New Resource (v4.x) | Argument Changes |
|---------------------|---------------------|------------------|
| `azurerm_sql_server` | `azurerm_mssql_server` | None |
| `azurerm_sql_database` | `azurerm_mssql_database` | `server_name` → `server_id` |
| `azurerm_sql_firewall_rule` | `azurerm_mssql_firewall_rule` | `resource_group_name` + `server_name` → `server_id` |
| `azurerm_sql_virtual_network_rule` | `azurerm_mssql_virtual_network_rule` | `resource_group_name` + `server_name` → `server_id` |
| `azurerm_sql_elasticpool` | `azurerm_mssql_elasticpool` | `server_name` → `server_id` |

#### Provider Configuration Changes

```hcl
# v3.x
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# v4.x
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}
```

#### Terraform Version Requirements

- **v3.x**: Terraform >= 1.0
- **v4.x**: Terraform >= 1.3.0

#### Authentication Changes

No breaking changes to authentication mechanisms. All methods remain supported:
- Managed Identity
- Service Principal
- Azure CLI
- OIDC/Federated Credentials

### Common SQL Resource Migrations

#### SQL Server

```hcl
# Arguments remain the same - just resource type changes
moved {
  from = azurerm_sql_server.example
  to   = azurerm_mssql_server.example
}
```

#### SQL Database

```hcl
# Before
resource "azurerm_sql_database" "example" {
  name                = "db"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql.name
  edition             = "Standard"
  requested_service_objective_name = "S1"
}

# After
resource "azurerm_mssql_database" "example" {
  name      = "db"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S1"
}

moved {
  from = azurerm_sql_database.example
  to   = azurerm_mssql_database.example
}
```

**Key Changes:**
- Removed: `resource_group_name`, `location` (inherited from server)
- Changed: `server_name` → `server_id`
- Changed: `edition` + `requested_service_objective_name` → `sku_name`

---

## Moved Blocks Deep Dive

### What Are Moved Blocks?

Moved blocks tell Terraform to update its state file when resource addresses change, enabling safe refactoring without recreation.

**Key Benefits:**
- ✅ Automatic state migration
- ✅ Version controlled and auditable
- ✅ Safer than manual `terraform state mv`
- ✅ Applied automatically on next plan/apply

### Syntax

```hcl
moved {
  from = <old_resource_address>
  to   = <new_resource_address>
}
```

### When to Use Moved Blocks

**Use moved blocks for:**
- Resource type changes (e.g., `azurerm_sql_server` → `azurerm_mssql_server`)
- Resource name changes (e.g., `server` → `sql_server`)
- Module refactoring
- Moving resources between modules

**Do NOT use for:**
- Argument changes within the same resource type
- Changing resource configuration
- Moving resources between state files

### Placement

Place moved blocks in the **same file** as the new resource definition or in a dedicated `moved.tf` file:

```hcl
# Option 1: In main.tf with resources
resource "azurerm_mssql_server" "sql" {
  # ... configuration ...
}

moved {
  from = azurerm_sql_server.sql
  to   = azurerm_mssql_server.sql
}

# Option 2: In dedicated moved.tf
# moved.tf
moved {
  from = azurerm_sql_server.sql
  to   = azurerm_mssql_server.sql
}

moved {
  from = azurerm_sql_firewall_rule.allow_azure
  to   = azurerm_mssql_firewall_rule.allow_azure
}
```

### Lifecycle

**Moved blocks should remain in code until:**
- All environments have been upgraded
- State migration is verified
- No team members are on old provider version

**Then:** Moved blocks can be safely removed (state is already updated).

### Multiple Resources

```hcl
# When migrating multiple related resources
moved {
  from = azurerm_sql_server.sql
  to   = azurerm_mssql_server.sql
}

moved {
  from = azurerm_sql_database.db
  to   = azurerm_mssql_database.db
}

moved {
  from = azurerm_sql_firewall_rule.fw
  to   = azurerm_mssql_firewall_rule.fw
}
```

### Validation

After applying moved blocks, Terraform will show:

```
Terraform will perform the following actions:

  # azurerm_sql_server.sql has moved to azurerm_mssql_server.sql
    resource "azurerm_mssql_server" "sql" {
        # (no changes)
    }

Plan: 0 to add, 0 to change, 0 to destroy.
```

**Expected output:** `0 to add, 0 to change, 0 to destroy` (if only moved blocks changed)

---

## Argument Mapping Patterns

### Name-Based → ID-Based References

**Pattern:** Old resource used `resource_group_name` + `server_name`, new uses `server_id`.

```hcl
# Before
resource "azurerm_sql_firewall_rule" "example" {
  server_name         = azurerm_sql_server.sql.name
  resource_group_name = azurerm_resource_group.rg.name
}

# After
resource "azurerm_mssql_firewall_rule" "example" {
  server_id = azurerm_mssql_server.sql.id
}
```

**Mapping:**
- `resource_group_name` (removed)
- `server_name` → `server_id`
- Reference change: `.name` → `.id`

### Composite Arguments → Single ID

**Pattern:** Multiple arguments combined into single ID reference.

```hcl
# Before - Multiple arguments
resource "azurerm_sql_database" "example" {
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql.name
  location            = azurerm_resource_group.rg.location
}

# After - Single ID
resource "azurerm_mssql_database" "example" {
  server_id = azurerm_mssql_server.sql.id
  # location and resource_group_name inherited from server
}
```

### Renamed Arguments

**Pattern:** Argument renamed for clarity or consistency.

```hcl
# Example: SQL Database SKU
# Before
resource "azurerm_sql_database" "example" {
  edition                          = "Standard"
  requested_service_objective_name = "S1"
}

# After
resource "azurerm_mssql_database" "example" {
  sku_name = "S1"  # Combines edition and tier
}
```

### Validating Argument Changes

**Process:**
1. Get old resource docs with `resolveProviderDocID` + `getProviderDocs`
2. Get new resource docs with `resolveProviderDocID` + `getProviderDocs`
3. Compare argument schemas side-by-side
4. Document mappings in breaking changes file

---

## Default Value Analysis

### Why Check Defaults?

New resources may have different default values than old resources, causing unexpected infrastructure changes.

**Example Scenario:**
```hcl
# Old resource default: public_network_access_enabled = true
# New resource default: public_network_access_enabled = false
```

If your old resource relied on the default `true`, the new resource will unexpectedly restrict access.

### How to Check

**Step 1: Review Old Resource Documentation**
```bash
resolveProviderDocID(
  providerNamespace="hashicorp",
  providerName="azurerm",
  serviceSlug="sql_server",
  providerDataType="resources",
  providerVersion="3.117.1"
)
getProviderDocs(providerDocID="<id>")
```

Look for: "Default: `<value>`" in argument descriptions

**Step 2: Review New Resource Documentation**
```bash
resolveProviderDocID(
  providerNamespace="hashicorp",
  providerName="azurerm",
  serviceSlug="mssql_server",
  providerDataType="resources",
  providerVersion="latest"
)
getProviderDocs(providerDocID="<id>")
```

**Step 3: Compare**

Create a table:

| Argument | Old Default | New Default | Impact |
|----------|-------------|-------------|--------|
| `public_network_access_enabled` | `true` | `false` | ⚠️ May restrict access |
| `min_tls_version` | `TLS1_0` | `TLS1_2` | ✅ Security improvement |

### Documenting Default Changes

**If defaults differ:**
```markdown
## Potential Breaking Changes

### Default Value Changes

**1. public_network_access_enabled**
- **Old Default:** `true` (azurerm_sql_server)
- **New Default:** `false` (azurerm_mssql_server)
- **Impact:** Public access will be restricted by default
- **Action:** Review plan output carefully; explicitly set to `true` if needed

**2. min_tls_version**
- **Old Default:** `TLS1_0`
- **New Default:** `TLS1_2`
- **Impact:** Old clients using TLS 1.0/1.1 will be rejected
- **Action:** Verify all clients support TLS 1.2+
```

**If defaults are identical:**
```markdown
## Default Values

**No new default value changes** detected between `azurerm_sql_server` and `azurerm_mssql_server`.
```

---

## Troubleshooting

### Issue: "Resource not found in state"

**Symptom:**
```
Error: Invalid address

The address "azurerm_sql_server.sql" does not exist in the current state.
```

**Cause:** Moved block references resource that doesn't exist in state.

**Solution:**
1. Verify resource address in current state: `terraform state list`
2. Update moved block `from` address to match state
3. Ensure moved block is in same Terraform files as new resource

### Issue: "Resource already exists in state"

**Symptom:**
```
Error: Duplicate resource address

The resource address "azurerm_mssql_server.sql" is used twice.
```

**Cause:** Both old and new resource definitions exist, or moved block points to existing resource.

**Solution:**
1. Remove old resource definition (keep only new one)
2. Ensure only one resource with target address exists
3. Verify moved block syntax

### Issue: "Plan shows resource recreation"

**Symptom:**
```
  # azurerm_mssql_server.sql must be replaced
-/+ resource "azurerm_mssql_server" "sql" {
```

**Cause:** Argument changes not properly mapped, causing Terraform to see it as new resource.

**Solution:**
1. Verify moved block is present and correct
2. Check argument mappings against provider docs
3. Ensure attribute references use correct property (`.name` vs `.id`)
4. Validate no immutable arguments changed

### Issue: "Moved block not taking effect"

**Symptom:** Terraform still wants to delete old resource and create new one.

**Cause:** Moved block syntax error or state inconsistency.

**Solution:**
1. Verify moved block syntax (no quotes around addresses)
2. Run `terraform init` to refresh state
3. Check moved block is in correct file
4. Validate both addresses exist (old in state, new in code)

### Issue: "Dependent resources failing"

**Symptom:**
```
Error: Invalid reference

The resource "azurerm_sql_server.sql" does not exist.
```

**Cause:** Dependent resources still reference old resource name.

**Solution:**
1. Search codebase for references to old resource
2. Update all references to use new resource type
3. Update attribute references (e.g., `.name` → `.id`)
4. Test each dependent resource

---

## Documentation Templates

### File Location

**Always create documentation at repository root:**

```
your-terraform-repo/
├── TERRAFORM_UPGRADE_BREAKING_CHANGES.md  ← Place here (breaking changes only)
├── infra/
├── .github/
└── README.md
```

**Why root?**
- High visibility for all team members
- Easy to find in repository navigation
- Consistent location across projects
- First seen when browsing files

### When to Create Documentation

| Upgrade Type | Version Change | Create Doc? | Example |
|--------------|----------------|-------------|---------|
| Patch | 3.117.0 → 3.117.1 | ❌ No | Bug fixes only |
| Minor | 3.117.0 → 3.118.0 | ❌ No | New features, backward compatible |
| Major (no breaking) | 3.x → 4.x | ❌ No | Rare, but possible |
| Major (with breaking) | 3.x → 4.x | ✅ Yes | Most common major upgrades |

### Template 0: Non-Breaking Change (No Documentation File)

**For minor/patch versions, use a simple commit message instead:**

```
chore: upgrade azurerm provider to v3.118.0

- Updated provider version from 3.117.0 to 3.118.0
- Reviewed changelog: no breaking changes
- All existing resources remain compatible
```

**Do NOT create** `TERRAFORM_UPGRADE_BREAKING_CHANGES.md` for non-breaking changes.

### Template 1: Minor Version Upgrade (No Breaking Changes)

```markdown
# Terraform Provider Upgrade: {Provider} v{old} → v{new}

**Date:** {date}

## Summary

Upgraded {Provider} provider from v{old} to v{new}. This is a minor version upgrade with no breaking changes.

## What Changed

- Updated `required_providers` version constraint to `{new}`
- No code changes required

## Notes

- All existing resources remain compatible
- No state migration required
- Safe to apply immediately

## Next Steps

1. Commit these changes to a feature branch
2. Run your Terraform workflow via CI/CD pipeline to validate
3. Merge after successful validation

## References

- [{Provider} v{new} Release Notes]({link})
```

### Template 2: Major Version Upgrade (With Breaking Changes)

```markdown
# Terraform Provider Upgrade: {Provider} v{old} → v{new}

**Date:** {date}

## Summary

Upgraded {Provider} provider from v{old} to v{new}. This major version upgrade included automatic migration of removed resources.

## What Changed

- Updated `required_providers` version constraint to `{new}`
- Migrated removed resources
- Updated argument references
- Replaced deprecated provider properties

## Breaking Changes Handled

### ✅ {Old Resource} → {New Resource}

- **Files Modified:** {list files}
- **Changes Applied:**
  - Updated resource type
  - Added `moved` block for automatic state migration
  - Updated arguments: {list changes}
- **Argument Mappings:**
  - {old_arg} → {new_arg}
- **Default Values:** {status}
- **Documentation:** [{new_resource}]({link})

## Potential Breaking Changes

{If defaults changed, list them here}

## Notes

- All changes are backward compatible with existing state
- `moved` blocks enable automatic state migration
- No manual `terraform state mv` commands required

## Next Steps

1. Commit these changes to a feature branch
2. Run your Terraform workflow via CI/CD pipeline to validate
3. Review plan output to confirm state migrations
4. Verify no unexpected changes before merging

## References

- [{Provider} v{new} Upgrade Guide]({link})
- [{Provider} v{new} Release Notes]({link})
- [Terraform Moved Blocks](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)
```

### Template 3: Deprecated Syntax Removal

```markdown
# Terraform Provider Upgrade: {Provider} v{old} → v{new}

**Date:** {date}

## Summary

Upgraded {Provider} provider from v{old} to v{new}. Replaced deprecated provider configuration syntax.

## What Changed

- Updated `required_providers` version constraint to `{new}`
- Replaced deprecated `{old_arg}` with `{new_arg}`

## Deprecation Details

**Deprecated:** `{old_arg}`
- **Reason:** {explanation from docs}
- **Deprecated Since:** {version}
- **Replacement:** `{new_arg}`
- **Documentation:** [{link to docs}]({url})

## Migration

```hcl
# Before
provider "{name}" {
  {old_arg} = {old_value}
}

# After
provider "{name}" {
  {new_arg} = {new_value}
}
```

## Next Steps

1. Commit these changes to a feature branch
2. Run your Terraform workflow via CI/CD pipeline to validate
3. Merge after successful validation

## References

- [{Provider} v{new} Upgrade Guide]({link})
- [{Provider} Configuration Documentation]({link})
```

---

## Quick Reference Checklist

### Pre-Upgrade
- [ ] Inventory all provider version references
- [ ] Document current versions across modules/environments
- [ ] Check latest provider version with `get_latest_provider_version`
- [ ] **Determine upgrade type** (major vs minor/patch)
- [ ] Review upgrade guide with `resolveProviderDocID` + `getProviderDocs`
- [ ] **If major version**: Identify removed resources from upgrade guide
- [ ] **If major version**: Search codebase for removed resources (`grep -r "resource_type"`)
- [ ] **If minor/patch**: Skip to "Update version constraints"

### Upgrade Process (Breaking Changes Only)
- [ ] For each removed resource:
  - [ ] Get old resource docs
  - [ ] Get new resource docs
  - [ ] Compare argument schemas
  - [ ] Check default values
  - [ ] Update resource type
  - [ ] Add moved block
  - [ ] Update argument mappings
  - [ ] Update attribute references (`.name` → `.id`)
  - [ ] Search for dependent resources
  - [ ] Update dependent resources
- [ ] Update version constraints in `versions.tf`
- [ ] Replace deprecated provider properties
- [ ] Ensure consistency across all modules

### Documentation (Breaking Changes Only)
- [ ] **If breaking changes found**: Create `TERRAFORM_UPGRADE_BREAKING_CHANGES.md` at repository root
- [ ] **If non-breaking**: Skip documentation, use simple commit message
- [ ] Document version change
- [ ] List breaking changes handled
- [ ] Show argument mappings
- [ ] Document default value status
- [ ] Include resource documentation links
- [ ] List all modified files
- [ ] Provide pipeline-based next steps
- [ ] Include official documentation links

### Post-Upgrade
- [ ] Commit changes to feature branch
- [ ] Validate via CI/CD pipeline
- [ ] Review plan output for state migrations
- [ ] Verify no unexpected infrastructure changes
- [ ] Confirm no resource recreation
- [ ] Test in non-production environment first
- [ ] Merge after successful validation

---

## Common Provider Upgrade Guides

### HashiCorp Providers

- **AzureRM:** https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **AWS:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Google:** https://registry.terraform.io/providers/hashicorp/google/latest/docs
- **Kubernetes:** https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

### Official Documentation

- **Terraform Moved Blocks:** https://developer.hashicorp.com/terraform/language/modules/develop/refactoring
- **Provider Requirements:** https://developer.hashicorp.com/terraform/language/providers/requirements
- **State Management:** https://developer.hashicorp.com/terraform/language/state
- **Version Constraints:** https://developer.hashicorp.com/terraform/language/expressions/version-constraints

---

## Getting Help

For complex upgrades or issues:

1. **Review official upgrade guides** - Most providers have detailed upgrade documentation
2. **Check GitHub issues** - Search provider repository for known issues
3. **Terraform Registry** - View examples and updated documentation
4. **HashiCorp Forums** - Community support for Terraform questions
5. **Provider-specific channels** - Many providers have dedicated support channels

