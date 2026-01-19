---
name: terraform-security-scan
description: Perform security scanning and compliance checking of Terraform configurations for Azure. Use this skill when scanning for security issues, checking CIS/Azure Security Benchmark compliance, auditing Terraform code for vulnerabilities, implementing security gates in CI/CD pipelines, vulnerability scan, security audit, compliance check, CIS benchmark, tfsec, or checkov.
metadata:
  author: github-copilot-skills-terraform
  version: "1.0.0"
  category: terraform-security
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

### Authentication and Secrets

#### Check: No Hardcoded Credentials

**Bad:**
```hcl
output "storage_key" {
  value = azurerm_storage_account.example.primary_access_key
}
```

**Good:**
```hcl
data "azurerm_key_vault_secret" "storage_connection" {
  name         = "storage-connection-string"
  key_vault_id = data.azurerm_key_vault.main.id
}
```

### Encryption

#### Check: Storage Encryption

```hcl
resource "azurerm_storage_account" "secure" {
  name                     = "stsecuredata"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false
}
```

### Network Security

#### Check: NSG Rules

```hcl
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web-tier"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

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
}
```

### RBAC and Access Control

#### Check: Least Privilege

```hcl
resource "azurerm_role_assignment" "storage_reader" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
```

## Security Scanning Commands

### Static Analysis with tfsec

```bash
brew install tfsec
tfsec .
tfsec . --format json > security-report.json
```

### Checkov Scanning

```bash
pip install checkov
checkov -d .
checkov -d . --framework terraform --check CKV_AZURE
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
- 3.x - Storage Accounts
- 4.x - Database Services
- 5.x - Logging and Monitoring
- 6.x - Networking

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

## Additional Resources

For detailed compliance checklists, security patterns, and scanning tool configurations, see the [reference guide](references/REFERENCE.md).
