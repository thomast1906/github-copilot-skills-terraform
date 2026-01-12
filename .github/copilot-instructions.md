# GitHub Copilot Instructions for Terraform Azure

This repository contains Terraform configurations for deploying Azure infrastructure. Follow these instructions when assisting with this codebase.

## General Guidelines

### Terraform Best Practices

1. **Always validate before planning**: Run `terraform validate` before `terraform plan`
2. **Use Azure Verified Modules**: Prefer modules from the Azure Verified Modules registry
3. **Follow HashiCorp style guide**: https://developer.hashicorp.com/terraform/language/style
4. **State Management**: Always use remote state with encryption enabled

### Security Requirements

- **Never hardcode credentials** - Use Azure Key Vault or environment variables
- **Prefer Managed Identity** - Use managed identity for Azure-hosted workloads
- **Use OIDC for GitHub Actions** - Federated credentials over client secrets
- **Enable encryption** - All storage and state files must be encrypted
- **Least privilege RBAC** - Scope roles appropriately

### Code Quality

- Use meaningful resource names with consistent naming conventions
- Add descriptions to all variables and outputs
- Include tags on all resources for cost tracking and governance
- Document complex logic with comments

## Azure-Specific Guidelines

### Authentication Priority

1. Managed Identity (for Azure-hosted workloads)
2. OIDC/Federated Credentials (for CI/CD)
3. Service Principal with certificate
4. Service Principal with secret (last resort)

### Resource Naming Convention

```
{resource-type}-{workload}-{environment}-{region}-{instance}
```

Examples:
- `rg-webapp-prod-eastus-001`
- `st-tfstate-prod-eastus-001`
- `kv-secrets-prod-eastus-001`

### Required Tags

All resources must include:
- `environment` - dev/staging/prod
- `project` - Project or workload name
- `owner` - Team or individual owner
- `cost-center` - For billing allocation
- `managed-by` - terraform

## MCP Tools Available

When working with this repository, you have access to the following MCP servers:

### HashiCorp Terraform MCP Server

The primary MCP server for Terraform operations. Use these tools:

- `search_modules` - Search Terraform Registry for modules by name/keyword
- `get_module_details` - Get detailed documentation for a specific module
- `search_providers` - Search for provider resources and data sources
- `get_provider_details` - Get resource/data source documentation

Example queries:
```
Use terraform MCP: search_modules for "azure storage account"
Use terraform MCP: get_provider_details for azurerm_storage_account
```

### Azure MCP Tools

- `azureterraformbestpractices` - **MUST call before generating any Azure Terraform code** - Returns current Azure Terraform best practices, security recommendations, and provider-specific guidance
- `azure_resources` - Query Azure Resource Graph for existing resources

### When to Use MCP Tools

1. **Before writing Terraform code** - **MUST call** `azureterraformbestpractices` to get current recommendations
2. **When searching for modules** - Use `search_modules` to find AVM or community modules
3. **When adding new resources** - Use `get_provider_details` for correct syntax
4. **When reviewing infrastructure** - Use `azure_resources` to query existing state

## Workflow Commands

### Local Development

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Generate plan
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan
```

### GitHub Actions

- Push to `main` triggers plan on all environments
- Pull requests show plan output as comments
- Manual approval required for production applies
- Drift detection runs on schedule

## File Organization

```
infra/
├── modules/           # Custom reusable modules
├── environments/      # Environment-specific configurations
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── prod/
└── shared/            # Shared resources (state, networking)
```

## Error Handling

When encountering Terraform errors:

1. Check Azure resource quotas and limits
2. Verify RBAC permissions
3. Check for naming conflicts
4. Review provider version compatibility
5. Validate state file consistency
