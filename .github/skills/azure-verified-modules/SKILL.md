---
name: azure-verified-modules
description: Research and learn from Azure Verified Modules (AVM) patterns to build better custom Terraform modules. Use this skill when creating Terraform modules, researching Azure security defaults, understanding proper resource configuration patterns, looking for Microsoft patterns, reference implementation examples, security defaults, or AVM examples. NOT for consuming AVM modules directly.
metadata:
  author: github-copilot-skills-terraform
  version: "1.0.0"
  category: terraform-azure
---

# Azure Verified Modules (Reference) Skill

This skill helps you learn from Azure Verified Modules (AVM) - Microsoft's official Terraform modules - to understand best practices, security patterns, and proper resource configuration when building your own custom modules.

## When to Use This Skill

- **Learning best practices** for Azure resource configuration
- **Researching security defaults** that Microsoft recommends
- **Understanding module structure** and organization patterns
- **Finding proper resource attributes** and configurations
- **Reference architecture** for custom module development

## How to Use AVM as Reference

**AVM provides examples of:**
- Security-first configurations (TLS versions, encryption, network rules)
- Proper variable validation patterns
- Output structure and naming conventions
- Dynamic blocks for optional resources
- Module organization and file structure

## What are Azure Verified Modules?

Azure Verified Modules (AVM) are Microsoft's official Terraform modules that serve as **reference implementations** showing:

- **Security best practices** - Microsoft-recommended security configurations
- **Proper resource patterns** - How to structure and organize resources
- **Validation rules** - Input validation for Azure resource constraints
- **Output conventions** - Standard output naming and structure
- **Testing patterns** - How Microsoft tests infrastructure code

## Finding AVM for Reference

### Official AVM Catalog

Browse implementations: https://azure.github.io/Azure-Verified-Modules/

### Terraform Registry

View source code: https://registry.terraform.io/namespaces/Azure
AVM modules are prefixed with `avm-`, e.g., `avm-res-storage-storageaccount`. (https://registry.terraform.io/search/modules?q=avm)

### Using Terraform MCP Tools

\`\`\`bash
# Use terraform MCP to find relevant AVM modules
search_modules("azure storage account verified")

# View AVM implementation details
get_module_details("Azure/avm-res-storage-storageaccount/azurerm")
\`\`\`

## Key Learnings from AVM

### 1. Security Defaults
- Always enforce TLS 1.2 minimum
- Disable public access by default
- Use private endpoints for PaaS services
- Enable encryption at rest and in transit

### 2. Variable Design
- Add validation for Azure resource constraints
- Provide sensible defaults for optional values
- Use object types for complex configurations
- Document all variables with descriptions

### 3. Resource Organization
- Use \`for_each\` for child resources
- Implement dynamic blocks for optional configs
- Tag all resources consistently
- Name resources predictably

### 4. Output Structure
- Expose resource IDs
- Provide connection endpoints
- Mark sensitive values appropriately
- Use descriptive output names

## What NOT to Do

❌ **DON'T copy AVM by calling it as a module:**
\`\`\`hcl
# This defeats the purpose - just creates a wrapper
module "storage_wrapper" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.2.0"
  name    = var.name
}
\`\`\`

✅ **DO learn patterns and implement resources directly:**
\`\`\`hcl
# This is what we want - actual resource using AVM patterns
resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # Using security patterns learned from AVM
  min_tls_version           = "TLS1_2"
  https_traffic_only_enabled = true
}
\`\`\`

## Additional Resources

For detailed code examples, security patterns, and module templates, see the [reference guide](references/REFERENCE.md).
