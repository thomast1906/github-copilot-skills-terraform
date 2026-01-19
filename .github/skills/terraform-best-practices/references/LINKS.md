# Terraform Best Practices - Recommended Resources

This reference provides curated links to official documentation, guides, and resources for Terraform best practices.

## Official HashiCorp Documentation

### Core Terraform Documentation

**Language Documentation**
- [Terraform Language](https://developer.hashicorp.com/terraform/language) - Complete language reference
- [Configuration Syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration) - HCL syntax guide
- [Style Conventions](https://developer.hashicorp.com/terraform/language/style) - Official style guide
- [Expressions](https://developer.hashicorp.com/terraform/language/expressions) - Expression syntax and operators
- [Functions](https://developer.hashicorp.com/terraform/language/functions) - Built-in function reference

**Resource Behavior**
- [Resources](https://developer.hashicorp.com/terraform/language/resources) - Resource blocks and behavior
- [Data Sources](https://developer.hashicorp.com/terraform/language/data-sources) - Reading existing infrastructure
- [Resource Addressing](https://developer.hashicorp.com/terraform/cli/state/resource-addressing) - How to reference resources
- [Meta-Arguments](https://developer.hashicorp.com/terraform/language/meta-arguments/count) - count, for_each, depends_on, etc.
- [Provisioners](https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax) - Last resort patterns

**Variables and Outputs**
- [Input Variables](https://developer.hashicorp.com/terraform/language/values/variables) - Defining and using variables
- [Output Values](https://developer.hashicorp.com/terraform/language/values/outputs) - Exposing module outputs
- [Local Values](https://developer.hashicorp.com/terraform/language/values/locals) - Internal computed values
- [Variable Validation](https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules) - Input validation rules
- [Type Constraints](https://developer.hashicorp.com/terraform/language/expressions/type-constraints) - Variable type system

**Modules**
- [Modules Overview](https://developer.hashicorp.com/terraform/language/modules) - Module basics
- [Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure) - Standard module structure
- [Module Sources](https://developer.hashicorp.com/terraform/language/modules/sources) - Where modules can come from
- [Module Composition](https://developer.hashicorp.com/terraform/language/modules/develop/composition) - Building with modules
- [Module Best Practices](https://developer.hashicorp.com/terraform/language/modules/develop) - Module development guide

**State Management**
- [State](https://developer.hashicorp.com/terraform/language/state) - Understanding state
- [Remote State](https://developer.hashicorp.com/terraform/language/state/remote) - Remote backend configuration
- [State Locking](https://developer.hashicorp.com/terraform/language/state/locking) - Preventing concurrent modifications
- [Sensitive Data in State](https://developer.hashicorp.com/terraform/language/state/sensitive-data) - Handling secrets
- [Import](https://developer.hashicorp.com/terraform/cli/import) - Importing existing resources

### Best Practices Guides

**Official Best Practices**
- [Plugin Development Best Practices](https://developer.hashicorp.com/terraform/plugin/best-practices) - Provider development patterns
- [Module Best Practices](https://developer.hashicorp.com/terraform/language/modules/develop) - Writing good modules
- [Testing Terraform](https://developer.hashicorp.com/terraform/language/modules/testing-experiment) - Experimental testing features
- [Version Constraints](https://developer.hashicorp.com/terraform/language/expressions/version-constraints) - Pinning versions correctly


**Performance and Scale**
- [Performance](https://developer.hashicorp.com/terraform/internals/graph) - Understanding the dependency graph
- [Large Repositories](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices/large-repositories) - Managing large configurations
- [Parallelism](https://developer.hashicorp.com/terraform/cli/commands/apply#parallelism-n) - Concurrent operations


## Azure-Specific Resources

### Azure Provider Documentation
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) - Official azurerm provider docs
- [Azure Provider Guides](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides) - Authentication, feature flags, etc.
- [Azure Resource Types](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/) - All available resources

### Azure Verified Modules (AVM)
- Use the [Azure Verified Modules skill](../azure-verified-modules/) to find and reference AVM patterns for best practices in Azure resource configuration.

### Microsoft Documentation
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) - Resource naming guide
- [Azure Tagging Strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging) - Tagging best practices
- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/) - Enterprise-scale patterns

## Community Resources

### Style Guides and Standards
- [HashiCorp Style Guide](https://developer.hashicorp.com/terraform/language/style) - Official style conventions


