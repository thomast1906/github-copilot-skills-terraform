---
name: terraform-security-scan
description: Perform security scanning and compliance checking of Terraform configurations for Azure. Use this skill when asked to scan for security issues, check compliance, or audit Terraform code for vulnerabilities.
---

# Terraform Security Scan Skill

This skill helps you perform comprehensive security scanning and compliance checking of Terraform configurations for Azure infrastructure.

## When to Use This Skill

- Reviewing Terraform code for security vulnerabilities
- Checking compliance with security frameworks
- Pre-deployment security gates
- Security audits and assessments
- Pull request security reviews

## Security Check Categories

### 🔐 Authentication & Secrets

#### Check: No Hardcoded Credentials

**Bad:**
```hcl
# ❌ Never do this
resource "azurerm_storage_account" "example" {
  # ...
}

output "storage_key" {
  value = azurerm_storage_account.example.primary_access_key
}
```

**Good:**
```hcl
# ✅ Use Key Vault references
data "azurerm_key_vault_secret" "storage_connection" {
  name         = "storage-connection-string"
  key_vault_id = data.azurerm_key_vault.main.id
}
```

#### Check: Managed Identity Preferred

```hcl
# ✅ Use system-assigned managed identity
resource "azurerm_linux_virtual_machine" "example" {
  # ...
  
  identity {
    type = "SystemAssigned"
  }
}
```

### 🔒 Encryption

#### Check: Storage Encryption

```hcl
resource "azurerm_storage_account" "secure" {
  name                     = "stsecuredata"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  # ✅ Required security settings
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 30
    }
  }
  
  # ✅ Customer-managed keys (for sensitive data)
  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.storage.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }
}
```

#### Check: Key Vault Configuration

```hcl
resource "azurerm_key_vault" "secure" {
  name                = "kv-secure-001"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # ✅ Required security settings
  enabled_for_disk_encryption     = true
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true
  enable_rbac_authorization       = true
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
  }
}
```

### 🌐 Network Security

#### Check: NSG Rules

```hcl
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web-tier"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # ✅ Specific rules, not wide open
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"  # Consider restricting further
    destination_address_prefix = "*"
  }

  # ❌ Avoid rules like this
  # security_rule {
  #   name                       = "AllowAll"
  #   source_address_prefix      = "*"
  #   destination_port_range     = "*"
  # }
}
```

#### Check: Private Endpoints for PaaS

```hcl
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-storage"
    private_connection_resource_id = azurerm_storage_account.main.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}
```

### 🛡️ RBAC & Access Control

#### Check: Least Privilege

```hcl
# ✅ Specific role at resource scope
resource "azurerm_role_assignment" "storage_reader" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# ❌ Avoid broad roles at subscription scope
# resource "azurerm_role_assignment" "contributor" {
#   scope                = data.azurerm_subscription.current.id
#   role_definition_name = "Contributor"
#   principal_id         = var.service_principal_id
# }
```

### 📊 Logging & Monitoring

#### Check: Diagnostic Settings

```hcl
resource "azurerm_monitor_diagnostic_setting" "storage" {
  name                       = "diag-storage"
  target_resource_id         = azurerm_storage_account.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "AllMetrics"
  }
}
```

## Security Scanning Commands

### Static Analysis with tfsec

```bash
# Install tfsec
brew install tfsec

# Run scan
tfsec .

# Output as JSON
tfsec . --format json > security-report.json
```

### Checkov Scanning

```bash
# Install checkov
pip install checkov

# Run scan
checkov -d .

# Run with specific framework
checkov -d . --framework terraform --check CKV_AZURE
```

### Terrascan

```bash
# Install terrascan
brew install terrascan

# Run scan
terrascan scan -t azure
```

## Compliance Frameworks

### Azure Security Benchmark

Key controls to verify:
- Network security controls
- Identity management
- Data protection
- Asset management
- Logging and threat detection

### CIS Azure Foundations

Check these sections:
- 1.x - Identity and Access Management
- 2.x - Security Center
- 3.x - Storage Accounts
- 4.x - Database Services
- 5.x - Logging and Monitoring
- 6.x - Networking
- 7.x - Virtual Machines
- 8.x - Other Security Considerations

## Security Report Format

```markdown
## Security Scan Report

**Scan Date:** 2024-01-15
**Directory:** ./infra/environments/prod
**Scanner:** tfsec + manual review

### Summary
| Severity | Count |
|----------|-------|
| 🔴 Critical | 1 |
| 🟠 High | 3 |
| 🟡 Medium | 7 |
| 🟢 Low | 12 |

### Critical Findings

#### SEC-001: Storage Account Allows Public Access
**Resource:** `azurerm_storage_account.uploads`
**File:** `storage.tf:15`
**Issue:** `allow_nested_items_to_be_public = true`

**Remediation:**
```hcl
allow_nested_items_to_be_public = false
```

### High Findings

#### SEC-002: Key Vault Missing Network ACLs
**Resource:** `azurerm_key_vault.secrets`
**File:** `keyvault.tf:8`
**Issue:** No network restrictions configured

**Remediation:**
```hcl
network_acls {
  default_action = "Deny"
  bypass         = "AzureServices"
}
```

### Compliance Status
| Framework | Status | Coverage |
|-----------|--------|----------|
| Azure Security Benchmark | ⚠️ Partial | 85% |
| CIS Azure 1.4 | ⚠️ Partial | 78% |

### Recommendations
1. Enable private endpoints for all PaaS services
2. Implement customer-managed keys for sensitive storage
3. Review and tighten NSG rules
```

## Integration with CI/CD

### GitHub Actions Security Gate

```yaml
name: Security Scan

on: [pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run tfsec
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          soft_fail: false
      
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          soft_fail: false
```
