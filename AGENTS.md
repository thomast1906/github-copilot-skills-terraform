# AGENTS.md - GitHub Copilot Skills for Terraform Azure

This file provides context and instructions for AI coding agents working with this repository.

## Repository Overview

This is a **template/reference repository** for GitHub Copilot agents and skills focused on Terraform Azure operations. It provides reusable agent definitions and skills that can be copied into actual infrastructure repositories.

This repository does NOT contain actual Terraform infrastructure code. It contains:
- GitHub Copilot agent definitions (`.github/agents/`)
- Reusable skills for Terraform operations (`.github/skills/`)
- Instructions for configuring Copilot in Terraform projects
- MCP server configuration example (`.vscode/mcp.json`)

## Repository Structure

### Actual Structure
```
.github/
├── agents/                           # GitHub Copilot agent definitions
│   ├── terraform-coordinator.agent.md
│   ├── terraform-module-expert.agent.md
│   └── terraform-security.agent.md
├── skills/                           # Reusable skills
│   ├── azure-verified-modules/
│   ├── github-actions-terraform/
│   └── terraform-security-scan/
└── copilot-instructions.md           # Global Copilot instructions
.vscode/
└── mcp.json                          # MCP server configuration
AGENTS.md                             # This file
README.md                             # Repository documentation
```

### Expected Structure in Target Infrastructure Repositories

When using these agents/skills in an actual Terraform repository, the structure should be:
```
infra/
├── modules/           # Custom reusable modules
├── environments/      # Environment-specific configurations
│   ├── dev/
│   ├── staging/
│   └── prod/
└── shared/            # Shared resources (state, networking)
```

### Naming Conventions

**Resources follow this pattern:**
```
{resource-type}-{workload}-{environment}-{region}-{instance}
```

Examples:
- `rg-webapp-prod-eastus-001` (Resource Group)
- `st-appdata-prod-eastus-001` (Storage Account)
- `kv-secrets-prod-eastus-001` (Key Vault)
- `vm-web-prod-eastus-001` (Virtual Machine)

### Required Tags

All resources MUST include these tags:
```hcl
tags = {
  environment = "dev|staging|prod"
  project     = "project-name"
  owner       = "team-or-individual"
  cost-center = "cost-allocation-code"
  managed-by  = "terraform"
}
```

## Security Requirements

### Authentication
1. **Managed Identity** - Preferred for Azure-hosted workloads
2. **OIDC/Federated Credentials** - Required for CI/CD pipelines
3. **Service Principal** - Only when above options unavailable

### Secrets Management
- NEVER hardcode credentials in Terraform files
- Use Azure Key Vault for all secrets
- Reference secrets via data sources:
```hcl
data "azurerm_key_vault_secret" "example" {
  name         = "secret-name"
  key_vault_id = data.azurerm_key_vault.main.id
}
```

### Encryption
- Enable encryption at rest for all storage
- Require TLS 1.2+ for all connections
- Use private endpoints for PaaS services

## Terraform Best Practices

### State Management
- Remote state stored in Azure Storage Account
- State encryption enabled
- State locking via Azure Blob lease

### Provider Configuration
```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    # Backend config in backend.tfvars
  }
}
```

### Module Usage
- Prefer Azure Verified Modules (AVM) over custom modules
- Always pin module versions
- Document all variable overrides

## Workflow Commands

### Local Development
```bash
# Initialize
terraform init

# Validate
terraform validate

# Format
terraform fmt -recursive

# Plan
terraform plan -out=tfplan

# Apply (with saved plan)
terraform apply tfplan
```

### CI/CD Pipeline
- Push to `main` triggers plan on all environments
- Pull requests show plan output as comments
- Manual approval required for production applies
- Drift detection runs daily on schedule

## Common Tasks

### Adding a New Resource
1. Check for Azure Verified Module first
2. Add resource to appropriate environment folder
3. Include all required tags
4. Run `terraform validate` and `terraform plan`
5. Create pull request for review

### Modifying Existing Resources
1. Review current state: `terraform state show <resource>`
2. Make changes in Terraform files
3. Generate plan: `terraform plan -out=tfplan`
4. Review for unexpected changes
5. Apply after approval

### Destroying Resources
1. Generate destroy plan: `terraform plan -destroy`
2. Review carefully - destruction is permanent
3. Require multi-person approval for production
4. Backup state before applying

## Troubleshooting

### Common Issues

**State Lock Error:**
```bash
terraform force-unlock <lock-id>
```

**Provider Version Mismatch:**
```bash
terraform init -upgrade
```

**Resource Already Exists:**
```bash
terraform import <resource_address> <azure_resource_id>
```

## MCP Server Integration

This repository uses the HashiCorp Terraform MCP server for enhanced tooling:

- **search_modules** - Find Terraform modules
- **get_module_details** - Get module documentation
- **search_providers** - Find provider resources
- **get_provider_details** - Get resource documentation

Configure in `.vscode/mcp.json` for VS Code integration.

## Agent Architecture

This repository includes three specialized agents:

### Terraform Coordinator
**Purpose:** Central routing agent for handoffs between specialist agents.

**Responsibilities:**
- Routes security review requests to `terraform-security`
- Routes implementation requests to `terraform-module-expert`
- Tracks handoff state and maintains a single canonical path for review/implementation cycles
- Avoids performing specialist tasks; delegates to appropriate agents

**When to use:** Use as the central handoff point when one agent needs to invoke another (e.g., module expert requesting security review, security agent requesting implementation).

### Terraform Module Expert
**Purpose:** Discovers, evaluates, and implements Azure Terraform modules.

**Responsibilities:**
- Discover modules from Azure Verified Modules and Terraform Registry
- Evaluate modules for quality, security, and fit
- Implement modules with best practices
- Create custom modules following Azure standards and AVM patterns
- Maintain module versions and handle upgrades

**Handoffs:** Routes security review requests to `terraform-coordinator`.

### Terraform Security
**Purpose:** Analyzes Terraform configurations for security vulnerabilities and compliance.

**Responsibilities:**
- Scan configurations for security vulnerabilities and misconfigurations
- Enforce compliance with security policies and frameworks
- Detect issues that could lead to security incidents
- Provide remediation guidance with secure code examples

**Handoffs:** Routes implementation requests to `terraform-coordinator`.

**Compliance frameworks checked:**
- Azure Security Benchmark
- CIS Azure Foundations Benchmark v2.0
- SOC 2 Type II requirements
- PCI DSS (if applicable)
- HIPAA (if applicable)
