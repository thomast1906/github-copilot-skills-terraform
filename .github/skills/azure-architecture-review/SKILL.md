```skill
---
name: azure-architecture-review
description: Review Terraform Azure code against Microsoft Cloud Adoption Framework (CAF) and Azure Well-Architected Framework (WAF). Use this skill when reviewing Terraform configurations, validating code against Microsoft frameworks, checking infrastructure-as-code compliance, or performing architecture reviews of .tf files before deployment.
metadata:
  author: github-copilot-skills-terraform
  version: "1.0.0"
  category: terraform-azure-governance
---

# Azure Architecture Review Skill

This skill **reviews Terraform code** for Azure resources against Microsoft's Cloud Adoption Framework (CAF) and Well-Architected Framework (WAF). It analyzes `.tf` files to ensure your infrastructure-as-code follows Microsoft's frameworks.

## When to Use This Skill

- **Reviewing Terraform code** - Check `.tf` files against CAF/WAF before deployment
- **Pull request reviews** - Validate infrastructure-as-code changes
- **Architecture validation** - Ensure Terraform designs follow Microsoft frameworks
- **Before terraform apply** - Catch compliance issues early in development
- **Code refactoring** - Align existing Terraform with CAF/WAF best practices
- **Compliance audits** - Review infrastructure-as-code for governance

## Applicable to ALL Azure Resources

This skill works for:
- **Networking**: Virtual Networks, Firewalls, VPN Gateways, Load Balancers
- **Compute**: Virtual Machines, App Service, AKS, Container Instances
- **Storage**: Storage Accounts, Managed Disks, File Shares
- **Databases**: SQL Database, Cosmos DB, PostgreSQL, MySQL
- **Security**: Key Vault, Managed Identity, Private Endpoints
- **Monitoring**: Log Analytics, Application Insights, Alerts
- **And more**: Any Azure service with Terraform support

## Prerequisites

**Required MCP Tools**:
- `mcp_azure_mcp_documentation` - Search Microsoft Learn documentation
- `mcp_azure_mcp_azureterraformbestpractices` - Get Terraform-specific Azure guidance

**Context Needed**:
- Understanding of the infrastructure being reviewed
- Business requirements (SLA, security, compliance)
- Current state (greenfield vs brownfield)

## Review Methodology

### Step 1: Get Terraform Best Practices (MANDATORY)

**Always call this FIRST before generating or reviewing Terraform code:**

```bash
# MCP Command
mcp_azure_mcp_azureterraformbestpractices
  command: get
  intent: "Get Azure Terraform best practices before code review"
```

**Returns**:
- Terraform validation workflow (validate → plan → apply)
- Azure-specific Terraform patterns
- Security defaults
- Naming conventions

### Step 2: Search Cloud Adoption Framework Documentation

**Query Pattern**: `"Cloud Adoption Framework {resource-type} {design-area}"`

**Examples for Different Resources**:

**Networking**:
```bash
mcp_azure_mcp_documentation search
  query: "Cloud Adoption Framework hub spoke network topology"
```

**Storage Accounts**:
```bash
mcp_azure_mcp_documentation search
  query: "Cloud Adoption Framework storage account security encryption private endpoint"
```

**App Service**:
```bash
mcp_azure_mcp_documentation search
  query: "Cloud Adoption Framework App Service landing zone networking"
```

**SQL Database**:
```bash
mcp_azure_mcp_documentation search
  query: "Cloud Adoption Framework Azure SQL Database security encryption"
```

**Key Vault**:
```bash
mcp_azure_mcp_documentation search
  query: "Cloud Adoption Framework Key Vault secrets management access control"
```

**Key CAF Design Areas** (apply to ALL resources):

1. **Resource Organization**
   - Naming conventions: `{type}-{workload}-{env}-{region}-{instance}`
   - Resource group strategy
   - Subscription design
   - Management group placement

2. **Security**
   - Authentication (Managed Identity preferred)
   - Encryption at rest and in transit
   - Private endpoints for PaaS services
   - Network isolation
   - RBAC with least privilege

3. **Network Topology and Connectivity**
   - Virtual network integration
   - Service endpoints vs private endpoints
   - Public vs private access
   - Hybrid connectivity needs

4. **Identity and Access Management**
   - Managed identities over service principals
   - RBAC roles (built-in preferred)
   - Azure AD integration
   - Key Vault for secrets

5. **Governance**
   - Required tags (environment, project, owner, cost-center)
   - Azure Policy compliance
   - Diagnostic settings
   - Cost tracking

### Step 3: Search Well-Architected Framework Documentation

**Query Pattern**: `"Well-Architected Framework {pillar} {service-name} {concern}"`

**Generic Pillar Queries**:
```bash
# Reliability
query: "Well-Architected Framework reliability availability zones disaster recovery"

# Security  
query: "Well-Architected Framework security encryption network access control"

# Cost Optimization
query: "Well-Architected Framework cost optimization pricing SKU right-sizing"

# Operational Excellence
query: "Well-Architected Framework operational excellence monitoring diagnostics"

# Performance Efficiency
query: "Well-Architected Framework performance efficiency scalability throughput"
```

**Service-Specific Queries**:
```bash
# Storage Account
query: "Well-Architected Framework Storage Account security encryption replication"
query: "Well-Architected Framework Storage Account performance throughput"

# App Service
query: "Well-Architected Framework App Service reliability availability zones"
query: "Well-Architected Framework App Service security authentication"

# SQL Database
query: "Well-Architected Framework Azure SQL Database reliability high availability"
query: "Well-Architected Framework Azure SQL Database security encryption"

# Key Vault
query: "Well-Architected Framework Key Vault security access policies"
query: "Well-Architected Framework Key Vault reliability backup recovery"
```

### Step 4: Service-Specific Guidance

**For each Azure service**, search for service-specific WAF guidance:

```bash
# Networking
query: "Azure Firewall Well-Architected best practices"
query: "VPN Gateway Well-Architected reliability"
query: "Load Balancer Well-Architected availability zones"

# Compute
query: "Virtual Machines Well-Architected best practices"
query: "App Service Well-Architected reliability"
query: "Azure Kubernetes Service Well-Architected security"

# Storage
query: "Storage Account Well-Architected security encryption"
query: "Managed Disks Well-Architected performance"

# Data
query: "Azure SQL Database Well-Architected reliability"
query: "Cosmos DB Well-Architected performance"
query: "PostgreSQL Well-Architected high availability"

# Security
query: "Key Vault Well-Architected security access control"
query: "Managed Identity Well-Architected best practices"

# Monitoring
query: "Log Analytics Well-Architected operational excellence"
query: "Application Insights Well-Architected monitoring"
```

## Validation Checklist

### Cloud Adoption Framework (CAF)

#### ✅ Network Topology
- [ ] Hub-spoke or Virtual WAN topology implemented correctly
- [ ] Hub contains shared services (Firewall, VPN/ER Gateway, Bastion)
- [ ] Spoke networks isolated and peered to hub
- [ ] Appropriate subnet sizing (/26 for Firewall, /27+ for Gateway)
- [ ] Reserved IP space for future growth

#### ✅ Naming Conventions
Pattern: `{resource-type}-{workload}-{environment}-{region}-{instance}`

Examples:
- `rg-hub-prod-eastus-001`
- `vnet-hub-prod-eastus-001`
- `afw-hub-prod-eastus-001`
- `vpngw-hub-prod-eastus-001`

#### ✅ Resource Organization
- [ ] Resources in appropriate management groups
- [ ] Connectivity resources in dedicated subscription
- [ ] Landing zone subscriptions for workloads
- [ ] Consistent resource group strategy

#### ✅ Tagging Strategy
Required tags:
- `environment` (dev/staging/prod)
- `project` (project/workload name)
- `owner` (team or individual)
- `cost-center` (billing allocation)
- `managed-by` (terraform)

### Well-Architected Framework (WAF)

#### ✅ Reliability (RE)
- [ ] **Availability Zones** - Zone-redundant deployments for critical services
- [ ] **Redundancy** - Active-active configurations where supported
- [ ] **BGP** - Dynamic routing for resilient connectivity
- [ ] **Health Monitoring** - Diagnostic settings enabled
- [ ] **Backup/Recovery** - DR strategy defined

**Documentation Check**:
```bash
query: "reliability availability zones Azure Firewall VPN Gateway high availability"
```

#### ✅ Security (SE)
- [ ] **Network Segmentation** - NSGs on all subnets
- [ ] **Zero Trust** - No direct public IP exposure (use Bastion)
- [ ] **Encryption** - TLS 1.2+ enforced
- [ ] **Threat Protection** - Firewall threat intelligence enabled
- [ ] **Service Endpoints** - Private connectivity for PaaS
- [ ] **RBAC** - Least privilege access
- [ ] **Secrets Management** - No hardcoded credentials

**Documentation Check**:
```bash
query: "security network segmentation NSG Azure Firewall threat intelligence"
```

#### ✅ Cost Optimization (CO)
- [ ] **Right-Sizing** - Appropriate SKUs for workload
- [ ] **Shared Resources** - Single Firewall for multiple spokes
- [ ] **Optional Components** - Expensive resources are optional
- [ ] **Monitoring** - Cost tracking via tags
- [ ] **Cleanup** - Unused resources removed

**Documentation Check**:
```bash
query: "cost optimization Azure Firewall SKU pricing shared resources"
```

**Cost Considerations**:
- Basic Firewall: ~$0.42/hr (~$304/month)
- Standard Firewall: ~$1.25/hr (~$912/month)
- Premium Firewall: ~$2.125/hr (~$1,551/month)
- VPN Gateway Basic: ~$0.045/hr (~$33/month)
- VPN Gateway VpnGw1: ~$0.19/hr (~$138/month)
- Bastion Basic: ~$0.19/hr (~$138/month)

#### ✅ Operational Excellence (OE)
- [ ] **IaC** - Infrastructure as Code (Terraform)
- [ ] **Version Control** - Provider versions pinned
- [ ] **Validation** - Input validation rules
- [ ] **Documentation** - README with examples
- [ ] **Tagging** - Consistent metadata
- [ ] **Monitoring** - Diagnostic settings configured
- [ ] **Alerting** - Critical events monitored

**Documentation Check**:
```bash
query: "operational excellence monitoring diagnostics logging Azure Firewall VPN Gateway"
```

**Missing Enhancement Check**:
- Are diagnostic settings required?
- Is Log Analytics workspace configured?
- Are NSG flow logs enabled?
- Are alerts configured for critical events?

#### ✅ Performance Efficiency (PE)
- [ ] **Scalability** - Autoscaling where supported
- [ ] **SKU Selection** - Performance requirements met
- [ ] **Network Design** - Minimal hops, low latency
- [ ] **Service Endpoints** - Optimized PaaS connectivity
- [ ] **Accelerated Networking** - Enabled where applicable

**Documentation Check**:
```bash
query: "performance efficiency Azure Firewall throughput scalability latency"
```

**Performance Baselines**:
- Firewall Basic: 250 Mbps
- Firewall Standard: 30 Gbps
- Firewall Premium: 100 Gbps
- VPN Gateway Basic: 100 Mbps
- VPN Gateway VpnGw1: 650 Mbps

## Review Output Template

### Summary
- **Architecture Type**: [Hub-Spoke / Virtual WAN]
- **Environment**: [Production / Non-Production]
- **Compliance Score**: [X/100]

### CAF Alignment
**Network Topology**: ✅ Compliant / ⚠️ Partial / ❌ Non-Compliant
- Details: [specific findings]

**Naming Conventions**: ✅ / ⚠️ / ❌
- Details: [specific findings]

**Resource Organization**: ✅ / ⚠️ / ❌
- Details: [specific findings]

**Tagging Strategy**: ✅ / ⚠️ / ❌
- Details: [specific findings]

### WAF Pillar Scores

| Pillar | Score | Critical Issues | Recommendations |
|--------|-------|-----------------|-----------------|
| Reliability | 90% | None | Consider multi-region |
| Security | 95% | None | Enable IDPS |
| Cost Optimization | 85% | None | Review SKU sizing |
| Operational Excellence | 85% | Missing diagnostics | Add Log Analytics |
| Performance Efficiency | 90% | None | Document performance |

### Recommended Actions

#### High Priority
1. **[Issue]** - [Recommendation with code example]
2. **[Issue]** - [Recommendation with documentation link]

#### Medium Priority
1. **[Enhancement]** - [Recommendation]

#### Low Priority / Nice to Have
1. **[Enhancement]** - [Recommendation]

## Example Usage

### Example 1: Validating a Hub Network Module

```markdown
## Review Request
Validate the hub module against CAF and WAF.

## Steps Taken

1. Called `azureterraformbestpractices get`
2. Searched CAF: "Cloud Adoption Framework hub spoke network topology"
3. Searched WAF: Each pillar for networking services
4. Validated: Hub-spoke pattern, special subnets, zone redundancy

## Overall Score: 88%
- CAF: 95% ✅
- WAF Reliability: 90% ✅ (zones implemented)
- WAF Security: 95% ✅ (NSGs, Bastion, Firewall)
- WAF Cost: 85% ✅ (optional resources)
- WAF Operations: 80% ⚠️ (missing diagnostics)
- WAF Performance: 90% ✅ (appropriate SKUs)
```

### Example 2: Validating a Storage Account Module

```markdown
## Review Request
Review my storage account Terraform for CAF/WAF compliance.

## Steps Taken

1. Called `azureterraformbestpractices get`
2. Searched CAF: "Cloud Adoption Framework storage account security"
3. Searched WAF: "Well-Architected Storage Account security encryption replication"

## Overall Score: 75%
- CAF: 85% ✅ (naming correct, tags present)
- WAF Security: 70% ⚠️ (Issues found)
- WAF Reliability: 60% ⚠️ (LRS replication - not zone-redundant)
- WAF Cost: 90% ✅ (appropriate tier)
- WAF Operations: 80% ✅ (diagnostics configured)

## Critical Findings:

### High Priority
1. **Public Access Enabled** (Security)
   ```hcl
   # Current (❌)
   public_network_access_enabled = true
   
   # Should be (✅)
   public_network_access_enabled = false
   
   resource "azurerm_private_endpoint" "storage" {
     name                = "pe-${var.storage_account_name}"
     location            = var.location
     resource_group_name = var.resource_group_name
     subnet_id           = var.subnet_id
     
     private_service_connection {
       name                           = "psc-storage"
       private_connection_resource_id = azurerm_storage_account.this.id
       subresource_names             = ["blob"]
       is_manual_connection          = false
     }
   }
   ```
   Reference: [Storage Account Private Endpoints](https://learn.microsoft.com/azure/storage/common/storage-private-endpoints)

2. **LRS Replication Not Zone-Redundant** (Reliability)
   ```hcl
   # Current (⚠️)
   account_replication_type = "LRS"  # Single zone
   
   # Production (✅)
   account_replication_type = "ZRS"   # Zone-redundant (same region)
   # OR
   account_replication_type = "GZRS"  # Geo-zone-redundant (multi-region)
   ```
   Reference: [Storage Redundancy](https://learn.microsoft.com/azure/storage/common/storage-redundancy)

3. **Public Blob Access Allowed** (Security)
   ```hcl
   # Add this (✅)
   allow_nested_items_to_be_public = false
   ```
```

### Example 3: Validating an App Service Module

```markdown
## Review Request
Check App Service Terraform against Microsoft best practices.

## Steps Taken

1. Called `azureterraformbestpractices get`
2. Searched CAF: "Cloud Adoption Framework App Service landing zone"
3. Searched WAF: "Well-Architected App Service reliability zones"
4. Searched WAF: "Well-Architected App Service security private endpoint"

## Overall Score: 82%
- CAF: 90% ✅
- WAF Reliability: 75% ⚠️ (not zone-redundant)
- WAF Security: 90% ✅ (good security posture)
- WAF Cost: 80% ✅ (appropriate SKU)
- WAF Operations: 85% ✅ (App Insights configured)
- WAF Performance: 80% ✅

## Findings:

### Medium Priority
1. **Zone Redundancy Not Enabled** (Reliability)
   ```hcl
   # Current (⚠️)
   sku_name = "P1v2"  # PremiumV2 doesn't support zones
   
   # Production (✅)
   sku_name              = "P1v3"  # PremiumV3
   zone_balancing_enabled = true   # Zone redundancy
   ```
   Impact: Improves availability from 99.95% → 99.99%
   Reference: [App Service Zone Redundancy](https://learn.microsoft.com/azure/app-service/how-to-zone-redundancy)

2. **No Health Check Configured** (Reliability)
   ```hcl
   # Add this (✅)
   site_config {
     health_check_path = "/health"
     health_check_eviction_time_in_min = 5
   }
   ```
```

### Example 4: Validating SQL Database Module

```markdown
## Review Request
Validate Azure SQL Database against CAF and WAF.

## Steps Taken

1. Called `azureterraformbestpractices get`
2. Searched: "Cloud Adoption Framework Azure SQL Database security"
3. Searched: "Well-Architected Azure SQL Database reliability"
4. Searched: "Azure SQL Database security baseline"

## Overall Score: 85%
- CAF: 95% ✅
- WAF Reliability: 80% ✅
- WAF Security: 85% ⚠️ (missing private endpoint)
- WAF Cost: 90% ✅
- WAF Operations: 90% ✅
- WAF Performance: 80% ✅

## High Priority Recommendations:

1. **Enable Private Endpoint** (Security)
   ```hcl
   resource "azurerm_private_endpoint" "sql" {
     name                = "pe-sql-${var.database_name}"
     location            = var.location
     resource_group_name = var.resource_group_name
     subnet_id           = var.subnet_id
     
     private_service_connection {
       name                           = "psc-sql"
       private_connection_resource_id = azurerm_mssql_server.this.id
       subresource_names             = ["sqlServer"]
       is_manual_connection          = false
     }
   }
   
   # Disable public access
   public_network_access_enabled = false
   ```

2. **Enable Advanced Threat Protection** (Security)
   ```hcl
   resource "azurerm_mssql_server_security_alert_policy" "this" {
     resource_group_name = var.resource_group_name
     server_name         = azurerm_mssql_server.this.name
     state               = "Enabled"
     email_addresses     = ["security@example.com"]
   }
   ```
```

## Tips and Best Practices

### 🔍 Search Query Optimization

**Good queries** (specific, actionable):
- "Cloud Adoption Framework {service} security best practices"
- "Well-Architected Framework {service} reliability zones"
- "CAF {service} naming conventions"
- "{service} encryption private endpoint security baseline"

**Examples for Different Resources**:
- Storage: "Storage Account encryption private endpoint security"
- Compute: "App Service zone redundancy high availability"
- Data: "Azure SQL Database security encryption authentication"
- Security: "Key Vault RBAC access control policies"

**Poor queries** (too broad):
- "Azure best practices" ❌
- "Cloud Adoption Framework" ❌
- "security" ❌

### 📊 Universal Validation Checklist

Use this for **ANY** Azure resource:

**CAF Validation**:
- [ ] Naming convention: `{type}-{workload}-{env}-{region}-{instance}`
- [ ] Tags: environment, project, owner, cost-center, managed-by
- [ ] Resource organization: appropriate subscription/RG
- [ ] Documentation: README with usage examples

**WAF Reliability**:
- [ ] Zone redundancy or appropriate SLA
- [ ] Backup/recovery strategy
- [ ] Health monitoring configured

**WAF Security**:
- [ ] Managed identity (not service principal)
- [ ] Private endpoint (no public access)
- [ ] Encryption at rest and in transit
- [ ] RBAC with least privilege
- [ ] No hardcoded secrets

**WAF Cost**:
- [ ] Right-sized SKU for workload
- [ ] Appropriate replication/redundancy level
- [ ] Cost tags for tracking

**WAF Operations**:
- [ ] Diagnostic settings enabled
- [ ] Log Analytics integration
- [ ] Infrastructure as Code (Terraform)
- [ ] Input validation

**WAF Performance**:
- [ ] SKU meets performance requirements
- [ ] Scaling configured appropriately
- [ ] Optimized for workload patterns

### 🎯 Resource-Agnostic Approach

The skill works the same way for ALL resources:

1. **Call Terraform best practices** (always first)
2. **Search CAF** for resource-specific guidance
3. **Search WAF** for each pillar
4. **Generate report** with scores and recommendations

**The queries change, the methodology doesn't!**

### 📚 Documentation Links to Reference

Always link to official Microsoft documentation in recommendations:
- CAF: https://learn.microsoft.com/azure/cloud-adoption-framework/
- WAF: https://learn.microsoft.com/azure/well-architected/
- Hub-Spoke: https://learn.microsoft.com/azure/architecture/networking/architecture/hub-spoke

### ⚡ Common Gaps to Check

1. **Missing diagnostic settings** - Most common WAF gap
2. **No NSG flow logs** - Security and operational visibility
3. **Hardcoded values** - Should use variables
4. **No cost estimates** - Users need to understand spend
5. **Missing examples** - Modules need working examples

### 🎯 Validation Priority

1. **Security** - Always highest priority (breaches are expensive)
2. **Reliability** - Downtime impacts business
3. **Operational Excellence** - Reduces long-term costs
4. **Cost Optimization** - Balance with other pillars
5. **Performance Efficiency** - Optimize after stability

## Integration with Other Skills

- **azure-verified-modules** - Learn implementation patterns from AVM
- **terraform-security-scan** - Deep security validation with tfsec/checkov
- **github-actions-terraform** - CI/CD pipeline best practices

## References

- [Azure Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Hub-Spoke Network Topology](https://learn.microsoft.com/azure/architecture/networking/architecture/hub-spoke)
- [Azure Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Network Design Area](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/network-topology-and-connectivity)
```
