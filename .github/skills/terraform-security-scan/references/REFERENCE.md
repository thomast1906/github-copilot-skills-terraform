# Terraform Security Scan Reference Guide

This reference contains detailed security patterns and compliance framework information for Terraform Azure configurations.

## Security Scanning Tools

### tfsec

```bash
# Install tfsec
brew install tfsec

# Run scan
tfsec .

# Output as JSON
tfsec . --format json > security-report.json

# Exclude specific checks
tfsec . --exclude-downloaded-modules --exclude azure-storage-queue-services-logging-enabled
```

### Checkov

```bash
# Install checkov
pip install checkov

# Run scan
checkov -d .

# Run with specific framework
checkov -d . --framework terraform --check CKV_AZURE

# Output as SARIF for GitHub
checkov -d . -o sarif > results.sarif
```

### Terrascan

```bash
# Install terrascan
brew install terrascan

# Run scan
terrascan scan -t azure

# With policy as code
terrascan scan -t azure -p /path/to/policies
```

## CI/CD Security Gate

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
          
      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: results.sarif
```

## CIS Azure Foundations Benchmark

### Section 1.x - Identity and Access Management

- [ ] 1.1 - Ensure Security Defaults is enabled
- [ ] 1.2 - Ensure MFA is enabled for all privileged users
- [ ] 1.3 - Ensure guest users are reviewed monthly
- [ ] 1.4 - Ensure custom subscription owner roles are not created

### Section 3.x - Storage Accounts

- [ ] 3.1 - Ensure 'Secure transfer required' is set to 'Enabled'
- [ ] 3.2 - Ensure storage account access keys are periodically regenerated
- [ ] 3.3 - Ensure Storage logging is enabled for Queue service
- [ ] 3.4 - Ensure shared access signature tokens expire within an hour
- [ ] 3.5 - Ensure 'public access level' is set to Private for blob containers
- [ ] 3.6 - Ensure default network access rule for Storage Accounts is set to deny
- [ ] 3.7 - Ensure 'Trusted Microsoft Services' is enabled
- [ ] 3.8 - Ensure soft delete is enabled for Azure Storage

### Section 4.x - Database Services

- [ ] 4.1.1 - Ensure 'Auditing' is set to 'On'
- [ ] 4.1.2 - Ensure SQL server's TDE protector is encrypted with CMK
- [ ] 4.2.1 - Ensure server parameter 'log_checkpoints' is set to 'ON'
- [ ] 4.2.2 - Ensure server parameter 'log_connections' is set to 'ON'

### Section 5.x - Logging and Monitoring

- [ ] 5.1.1 - Ensure that a 'Diagnostic Setting' exists
- [ ] 5.1.2 - Ensure Diagnostic Setting captures appropriate categories
- [ ] 5.1.3 - Ensure the storage container storing Activity Logs is not publicly accessible
- [ ] 5.2.1 - Ensure that Activity Log Alert exists for Create Policy Assignment
- [ ] 5.2.2 - Ensure that Activity Log Alert exists for Delete Policy Assignment

### Section 6.x - Networking

- [ ] 6.1 - Ensure that RDP access is restricted from the internet
- [ ] 6.2 - Ensure that SSH access is restricted from the internet
- [ ] 6.3 - Ensure no SQL Databases allow ingress 0.0.0.0/0
- [ ] 6.4 - Ensure that Network Security Group Flow Log retention period is 'greater than 90 days'
- [ ] 6.5 - Ensure that Network Watcher is 'Enabled'

## Security Report Template

```markdown
## Security Scan Report

**Scan Date:** YYYY-MM-DD
**Directory:** ./infra/environments/prod
**Scanner:** tfsec + checkov + manual review

### Summary
| Severity | Count |
|----------|-------|
| 🔴 Critical | X |
| 🟠 High | X |
| 🟡 Medium | X |
| 🟢 Low | X |

### Critical Findings

#### SEC-001: [Finding Title]
**Resource:** `resource_type.resource_name`
**File:** `filename.tf:XX`
**Issue:** Description of the security issue

**Remediation:**
\`\`\`hcl
# Corrected configuration
\`\`\`

### Compliance Status
| Framework | Status | Coverage |
|-----------|--------|----------|
| Azure Security Benchmark | ⚠️ Partial | XX% |
| CIS Azure 1.4 | ⚠️ Partial | XX% |

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]
```

## Secure Configuration Patterns

### Storage Account

```hcl
resource "azurerm_storage_account" "secure" {
  name                     = "stsecuredata"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  # Required security settings
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  shared_access_key_enabled       = false
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 30
    }
  }
}
```

### Key Vault

```hcl
resource "azurerm_key_vault" "secure" {
  name                = "kv-secure-001"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Required security settings
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

### Network Security Group

```hcl
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web-tier"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Specific rules, not wide open
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  
  # Deny all other inbound
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
```

### Private Endpoint

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
  
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}
```
