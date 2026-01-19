# Azure Architecture Review Skill - Reference Guide

This document provides detailed reference information for **reviewing Terraform code** against Cloud Adoption Framework (CAF) and Well-Architected Framework (WAF).

**Key Focus:** Reviews Terraform configurations (`.tf` files), not live Azure infrastructure.

## MCP Commands Reference

### 1. Azure Terraform Best Practices

**When to use**: ALWAYS call this FIRST before any Terraform code generation or review.

**Command**:
```json
{
  "tool": "mcp_azure_mcp_azureterraformbestpractices",
  "parameters": {
    "command": "get",
    "intent": "Get Azure Terraform best practices before code review"
  }
}
```

**Returns**:
- Terraform workflow sequence (validate → plan → apply)
- HashiCorp style guide reference
- Azure-specific patterns
- Security defaults

**Example Output**:
```
- Ensure the request is for Azure resources
- Follow HashiCorp style guide: https://developer.hashicorp.com/terraform/language/style
- Workflow: terraform validate → terraform plan → terraform apply -auto-approve
- Provide Azure portal link after resource creation
```

### 2. Search Microsoft Documentation

**When to use**: Search for official Microsoft guidance on CAF, WAF, and service-specific best practices.

**Command**:
```json
{
  "tool": "mcp_azure_mcp_documentation",
  "parameters": {
    "command": "search",
    "intent": "Search Microsoft documentation for architecture guidance",
    "parameters": {
      "query": "Cloud Adoption Framework hub spoke network topology",
      "top": 10
    }
  }
}
```

**Query Patterns**:

**Cloud Adoption Framework**:
```
"Cloud Adoption Framework hub spoke network topology"
"CAF landing zone design areas network connectivity"
"CAF resource organization management groups subscriptions"
"CAF naming conventions Azure resources"
"CAF network segmentation NSG best practices"
```

**Well-Architected Framework - By Pillar**:
```
"Well-Architected Framework reliability availability zones disaster recovery"
"Well-Architected Framework security network NSG encryption"
"Well-Architected Framework cost optimization pricing SKU"
"Well-Architected Framework operational excellence monitoring diagnostics"
"Well-Architected Framework performance efficiency scalability"
```

**Service-Specific**:
```
"Azure Firewall Well-Architected Framework best practices"
"VPN Gateway Well-Architected Framework reliability"
"Azure Bastion Well-Architected Framework security"
"Virtual Network Well-Architected Framework"
```

**Returns**:
```json
{
  "results": [
    {
      "title": "Hub-spoke network topology in Azure",
      "content": "... detailed content ...",
      "contentUrl": "https://learn.microsoft.com/azure/..."
    }
  ]
}
```

## CAF Validation Checklists

### Universal Validation (All Resources)

**Naming Conventions** (applies to ALL Azure resources):
- [ ] Follows pattern: `{resource-type}-{workload}-{environment}-{region}-{instance}`
- [ ] Resource type abbreviation is correct (per CAF abbreviations)
- [ ] Environment is one of: dev, staging, prod
- [ ] Region is lowercase with no spaces (eastus, westeurope)
- [ ] Instance number is zero-padded (001, 002, etc.)

**Tagging Strategy** (applies to ALL Azure resources):
- [ ] `environment` tag present (dev/staging/prod)
- [ ] `project` tag present
- [ ] `owner` tag present
- [ ] `cost-center` tag present
- [ ] `managed-by` tag present (terraform)

**Security Baseline** (applies to ALL Azure resources):
- [ ] Managed identity used (not service principal with secret)
- [ ] Private endpoint used for PaaS services
- [ ] Public access disabled unless explicitly required
- [ ] Encryption at rest enabled
- [ ] Encryption in transit enforced (TLS 1.2+)
- [ ] RBAC follows least privilege
- [ ] Diagnostic settings configured
- [ ] No hardcoded secrets or credentials

### Resource-Specific Validation

#### Network Topology Validation

**Hub-Spoke Architecture**:
- [ ] Hub VNet contains shared services
- [ ] Azure Firewall in hub (optional but recommended)
- [ ] VPN/ExpressRoute Gateway in hub (for hybrid connectivity)
- [ ] Azure Bastion in hub (for secure VM access)
- [ ] DNS servers configured appropriately
- [ ] Spoke VNets peered to hub
- [ ] Route tables direct traffic through firewall

**Special Subnets**:
- [ ] `AzureFirewallSubnet` - Must be exactly this name, minimum /26
- [ ] `GatewaySubnet` - Must be exactly this name, minimum /27 (recommend /26)
- [ ] `AzureBastionSubnet` - Must be exactly this name, minimum /26

**Validation Commands**:
```bash
# Check for special subnet naming
grep -r "AzureFirewallSubnet" .
grep -r "GatewaySubnet" .
grep -r "AzureBastionSubnet" .

# Check subnet sizing (should see /26 or larger)
grep -r "address_prefix" . | grep -E "subnet"
```

### Naming Convention Validation

**Pattern**: `{resource-type}-{workload}-{environment}-{region}-{instance}`

**Examples**:
```
Resource Group:     rg-hub-prod-eastus-001
Virtual Network:    vnet-hub-prod-eastus-001
Subnet:            snet-management-prod-eastus-001
NSG:               nsg-management-prod-eastus-001
Azure Firewall:     afw-hub-prod-eastus-001
VPN Gateway:        vpngw-hub-prod-eastus-001
Public IP:          pip-afw-prod-eastus-001
Route Table:        rt-hub-prod-eastus-001
Bastion:           bastion-hub-prod-eastus-001
```

**Resource Type Abbreviations** (from CAF):
- `rg` - Resource Group
- `vnet` - Virtual Network
- `snet` - Subnet
- `nsg` - Network Security Group
- `afw` - Azure Firewall
- `vpngw` - VPN Gateway
- `ergw` - ExpressRoute Gateway
- `pip` - Public IP
- `rt` - Route Table
- `st` - Storage Account
- `kv` - Key Vault

**Validation**:
```bash
# Check naming consistency
grep -r "name.*=" . | grep -E "(resource_group_name|virtual_network_name)"
```

### Tagging Strategy Validation

**Required Tags** (per CAF):
```hcl
tags = {
  environment = "dev|staging|prod"
  project     = "project-name"
  owner       = "team-name"
  cost-center = "cost-allocation-code"
  managed-by  = "terraform"
}
```

**Validation**:
```hcl
# In variables.tf, should have validation:
variable "tags" {
  type = map(string)
  
  validation {
    condition     = can(var.tags["environment"]) && can(var.tags["project"])
    error_message = "Tags must include 'environment' and 'project' keys."
  }
}
```

#### Storage Account Validation

**Security**:
- [ ] `min_tls_version = "TLS1_2"` enforced
- [ ] `https_traffic_only_enabled = true`
- [ ] `public_network_access_enabled = false` (use private endpoint)
- [ ] `allow_nested_items_to_be_public = false` (no public containers)
- [ ] `shared_access_key_enabled = false` (use Azure AD)
- [ ] Encryption with customer-managed keys (if required)

**Reliability**:
- [ ] Appropriate replication: LRS, ZRS, GRS, GZRS
- [ ] Zone-redundant (ZRS/GZRS) for production
- [ ] Soft delete enabled for blobs and containers
- [ ] Versioning enabled

**Naming**:
```
st{workload}{env}{region}{instance}
Example: stappdata prod eastus001 (no hyphens, 3-24 chars, lowercase)
```

**Documentation Search**:
```bash
query: "Storage Account Well-Architected security encryption"
query: "Storage Account reliability replication zones"
```

#### App Service Validation

**Security**:
- [ ] `https_only = true`
- [ ] `minimum_tls_version = "1.2"`
- [ ] Managed identity enabled
- [ ] Private endpoint configured (for VNet integration)
- [ ] `public_network_access_enabled = false`
- [ ] Authentication configured (Easy Auth)

**Reliability**:
- [ ] Zone redundancy enabled (Premium SKU)
- [ ] Auto-scaling configured with appropriate rules
- [ ] Health check endpoint configured
- [ ] Deployment slots for production

**Performance**:
- [ ] Appropriate SKU for workload (B, S, P, PremiumV3)
- [ ] Always On enabled for production
- [ ] Application Insights integrated

**Naming**:
```
app-{workload}-{env}-{region}-{instance}
Example: app-webapp-prod-eastus-001
```

**Documentation Search**:
```bash
query: "App Service Well-Architected reliability zones"
query: "App Service security authentication private endpoint"
```

#### SQL Database Validation

**Security**:
- [ ] Azure AD authentication enabled
- [ ] Transparent Data Encryption (TDE) enabled
- [ ] Private endpoint configured
- [ ] `public_network_access_enabled = false`
- [ ] Advanced Threat Protection enabled
- [ ] Auditing enabled

**Reliability**:
- [ ] Zone-redundant configuration
- [ ] Active geo-replication (if multi-region)
- [ ] Automated backups configured
- [ ] Long-term retention policy defined
- [ ] Appropriate SLA tier (Business Critical, General Purpose)

**Performance**:
- [ ] DTU/vCore sizing appropriate for workload
- [ ] Query Performance Insights enabled
- [ ] Automatic tuning enabled

**Naming**:
```
sql-{workload}-{env}-{region}-{instance}
sqldb-{database-name}
Example: sql-webapp-prod-eastus-001
```

**Documentation Search**:
```bash
query: "Azure SQL Database Well-Architected reliability high availability"
query: "Azure SQL Database security encryption authentication"
```

#### Key Vault Validation

**Security**:
- [ ] `enable_rbac_authorization = true` (prefer RBAC over access policies)
- [ ] Private endpoint configured
- [ ] `public_network_access_enabled = false`
- [ ] Soft delete enabled (`soft_delete_retention_days = 90`)
- [ ] Purge protection enabled
- [ ] Network ACLs restrict access to specific VNets
- [ ] Managed HSM for highly sensitive keys (if required)

**Reliability**:
- [ ] Standard SKU (zone-redundant in most regions)
- [ ] Premium SKU for HSM-protected keys
- [ ] Backup and restore tested
- [ ] Multi-region replication strategy

**Access Control**:
- [ ] Least privilege RBAC assignments
- [ ] Separate Key Vaults per environment
- [ ] Managed identities for application access
- [ ] No service principal secrets stored

**Naming**:
```
kv-{workload}-{env}-{region}-{instance}
Example: kv-webapp-prod-eastus-001
(3-24 chars, alphanumeric and hyphens only)
```

**Documentation Search**:
```bash
query: "Key Vault Well-Architected security access control RBAC"
query: "Key Vault reliability backup recovery"
```

#### Virtual Machine Validation

**Security**:
- [ ] No public IP addresses (use Bastion)
- [ ] Managed identity for Azure resource access
- [ ] Azure Disk Encryption enabled
- [ ] VM extensions for antimalware/monitoring
- [ ] Just-In-Time access configured
- [ ] NSG associated with subnet/NIC

**Reliability**:
- [ ] Availability zones configured
- [ ] Availability set (if not using zones)
- [ ] Managed disks (zone-redundant storage)
- [ ] Azure Backup configured
- [ ] Update Management enabled

**Performance**:
- [ ] Appropriate VM size for workload
- [ ] Premium SSD for production workloads
- [ ] Accelerated networking enabled
- [ ] Proximity placement groups (if latency-sensitive)

**Naming**:
```
vm-{workload}-{env}-{region}-{instance}
Example: vm-web-prod-eastus-001
```

**Documentation Search**:
```bash
query: "Virtual Machines Well-Architected reliability availability zones"
query: "Virtual Machines security encryption Bastion"
```

#### AKS (Kubernetes Service) Validation

**Security**:
- [ ] Azure AD integration enabled
- [ ] RBAC enabled
- [ ] Network policy (Azure CNI or Calico)
- [ ] Private cluster enabled
- [ ] Azure Policy for Kubernetes
- [ ] Workload identity (not service principal)
- [ ] Secrets stored in Key Vault (CSI driver)

**Reliability**:
- [ ] Multiple node pools across availability zones
- [ ] System node pool separate from user pools
- [ ] Pod Disruption Budgets configured
- [ ] Horizontal Pod Autoscaler
- [ ] Cluster autoscaler enabled

**Operational**:
- [ ] Container Insights enabled
- [ ] Diagnostic settings configured
- [ ] GitOps deployment model
- [ ] Automated upgrades configured

**Naming**:
```
aks-{workload}-{env}-{region}-{instance}
Example: aks-webapp-prod-eastus-001
```

**Documentation Search**:
```bash
query: "Azure Kubernetes Service Well-Architected security baseline"
query: "AKS reliability availability zones node pools"
```

### Validation Command Reference

**Check for any Azure resource naming**:
```bash
grep -r "name\s*=" . | grep -v ".terraform"
```

**Check for public access**:
```bash
grep -r "public_network_access_enabled\|public_ip_address" .
```

**Check for encryption settings**:
```bash
grep -r "encryption\|tls_version\|https_only" .
```

**Check for managed identity usage**:
```bash
grep -r "identity\s*{" .
```

**Check for diagnostic settings**:
```bash
grep -r "azurerm_monitor_diagnostic_setting" .
```

**Check for private endpoints**:
```bash
grep -r "azurerm_private_endpoint" .
```

## WAF Pillar Validation Details

### 1. Reliability Pillar

**Key Questions** (Universal for ALL resources):
- Are critical services zone-redundant?
- Is there redundancy/failover configured?
- Are backups configured and tested?
- Is disaster recovery strategy defined?
- Are SLA requirements met?

**Examples by Resource Type**:

**Azure Firewall**:
```hcl
# Zone redundancy
zones = ["1", "2", "3"]  # ✅ 99.99% SLA
```

**Storage Account**:
```hcl
# Zone-redundant replication
account_replication_type = "GZRS"  # ✅ Geo-zone-redundant
```

**App Service**:
```hcl
# Zone redundancy (Premium SKU required)
zone_balancing_enabled = true
sku_name              = "P1v3"  # ✅ PremiumV3 supports zones
```

**SQL Database**:
```hcl
# Zone redundancy
sku_name        = "BC_Gen5_2"  # Business Critical
zone_redundant  = true  # ✅ 99.995% SLA
```

**Documentation Search**:
```bash
query: "Well-Architected reliability availability zones {service-name}"
query: "{service-name} high availability disaster recovery"
query: "{service-name} SLA uptime guarantees"
```

# SKU must be Standard or Premium (not Basic)
sku_tier = "Standard"  # ✅ Supports zones
```

**VPN Gateway**:
```hcl
# Active-active for redundancy
active_active = true  # ✅ Two instances

# BGP for dynamic routing
enable_bgp = true  # ✅ Automatic failover

# Zone-aware SKU
sku = "VpnGw1AZ"  # ✅ Zone redundant
```

**Scoring**:
- Zones on critical services: +25 points
- Active-active configuration: +25 points
- BGP enabled: +20 points
- Health monitoring: +15 points
- DR documentation: +15 points

**Documentation References**:
```
Query: "Well-Architected reliability availability zones Azure Firewall"
Query: "VPN Gateway active-active BGP reliability"
Query: "Azure Bastion availability SLA"
```

### 2. Security Pillar

**Key Questions**:
- Is network segmentation implemented (NSGs)?
- Are VMs accessible via Bastion (no public IPs)?
- Is encryption enforced (TLS 1.2+)?
- Is threat intelligence enabled on Firewall?
- Are service endpoints used for PaaS?
- Are there hardcoded credentials?
- Is RBAC configured with least privilege?

**Network Security Groups**:
```hcl
# NSG on every subnet
resource "azurerm_network_security_group" "subnets" {
  for_each = var.subnets  # ✅ One per subnet
  # ...
}

# Association
resource "azurerm_subnet_network_security_group_association" "subnets" {
  for_each = var.subnets  # ✅ All subnets protected
  # ...
}
```

**Azure Bastion** (Zero Trust):
```hcl
resource "azurerm_bastion_host" "hub" {
  # ✅ Secure access without public IPs on VMs
}
```

**Azure Firewall Threat Intelligence**:
```hcl
threat_intel_mode = "Alert"  # ⚠️ Should be "Deny" in prod
threat_intel_mode = "Deny"   # ✅ Block known threats
```

**Service Endpoints**:
```hcl
service_endpoints = [
  "Microsoft.Storage",    # ✅ Private access to storage
  "Microsoft.KeyVault"   # ✅ Private access to Key Vault
]
```

**Scoring**:
- NSG per subnet: +20 points
- Bastion (no public IPs): +20 points
- Firewall threat intel: +15 points
- Service endpoints: +15 points
- No hardcoded secrets: +15 points
- TLS 1.2+ enforced: +10 points
- RBAC implemented: +5 points

**Documentation References**:
```
Query: "Well-Architected security network segmentation NSG"
Query: "Azure Bastion security best practices zero trust"
Query: "Azure Firewall threat intelligence IDPS"
```

### 3. Cost Optimization Pillar

**Key Questions**:
- Are SKUs right-sized for workload?
- Are expensive resources optional?
- Is Firewall shared across spokes?
- Are resources tagged for cost tracking?
- Are unused resources cleaned up?

**SKU Selection**:
```hcl
# Firewall SKUs
firewall_sku_tier = "Basic"     # ~$304/month, 250 Mbps
firewall_sku_tier = "Standard"  # ~$912/month, 30 Gbps
firewall_sku_tier = "Premium"   # ~$1,551/month, 100 Gbps, IDPS

# VPN Gateway SKUs
vpn_gateway_sku = "Basic"       # ~$33/month, 100 Mbps
vpn_gateway_sku = "VpnGw1"      # ~$138/month, 650 Mbps
vpn_gateway_sku = "VpnGw1AZ"    # ~$190/month, 650 Mbps, zones

# Bastion SKUs
bastion_sku = "Basic"           # ~$138/month
bastion_sku = "Standard"        # ~$138/month + features
```

**Optional Resources**:
```hcl
variable "enable_firewall" {
  type    = bool
  default = true  # ✅ Optional, can disable for cost
}

variable "enable_vpn_gateway" {
  type    = bool
  default = false  # ✅ Only create if needed
}

variable "enable_bastion" {
  type    = bool
  default = false  # ✅ Only create if needed
}
```

**Cost Tracking**:
```hcl
tags = merge(
  var.tags,
  {
    cost-center = "..."  # ✅ Enables cost allocation
    project     = "..."  # ✅ Cost by project
    environment = "..."  # ✅ Cost by environment
  }
)
```

**Scoring**:
- Appropriate SKU selection: +25 points
- Optional expensive resources: +25 points
- Shared Firewall model: +20 points
- Cost tags present: +15 points
- Cost documentation: +15 points

**Documentation References**:
```
Query: "Well-Architected cost optimization Azure Firewall SKU pricing"
Query: "Azure Firewall cost optimization shared hub spoke"
Query: "VPN Gateway pricing SKU comparison"
```

### 4. Operational Excellence Pillar

**Key Questions**:
- Is infrastructure defined as code?
- Are provider versions pinned?
- Are inputs validated?
- Is documentation comprehensive?
- Are diagnostic settings configured?
- Are flow logs enabled?
- Is monitoring/alerting configured?

**Infrastructure as Code**:
```hcl
# ✅ Terraform with version constraints
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57"  # ✅ Pinned with flexibility
    }
  }
}
```

**Input Validation**:
```hcl
variable "address_space" {
  type = list(string)
  
  validation {
    condition     = alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "All address spaces must be valid CIDR blocks."
  }
}
```

**Diagnostic Settings** (Most Common Gap):
```hcl
# ⚠️ MISSING - Should add:
resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "firewall-diagnostics"
  target_resource_id         = azurerm_firewall.hub[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  enabled_log {
    category = "AzureFirewallApplicationRule"
  }
  
  enabled_log {
    category = "AzureFirewallNetworkRule"
  }
  
  metric {
    category = "AllMetrics"
  }
}
```

**NSG Flow Logs** (Often Missing):
```hcl
# ⚠️ MISSING - Should add:
resource "azurerm_network_watcher_flow_log" "nsg" {
  for_each = var.subnets
  
  network_watcher_name      = var.network_watcher_name
  resource_group_name       = var.network_watcher_rg
  network_security_group_id = azurerm_network_security_group.subnets[each.key].id
  storage_account_id        = var.flow_log_storage_account_id
  enabled                   = true
  
  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = var.location
    workspace_resource_id = var.log_analytics_workspace_resource_id
  }
}
```

**Scoring**:
- IaC with Terraform: +15 points
- Provider versions pinned: +10 points
- Input validation: +15 points
- Comprehensive docs: +10 points
- Diagnostic settings: +20 points
- NSG flow logs: +15 points
- Monitoring/alerting: +15 points

**Documentation References**:
```
Query: "Well-Architected operational excellence monitoring diagnostics"
Query: "Azure Firewall diagnostics logs monitoring"
Query: "NSG flow logs Traffic Analytics"
```

### 5. Performance Efficiency Pillar

**Key Questions**:
- Can resources autoscale?
- Are SKUs sufficient for performance requirements?
- Is network design optimized (minimal hops)?
- Are service endpoints used?
- Is accelerated networking enabled?

**Azure Firewall Performance**:
```hcl
# Autoscaling built-in
firewall_sku_tier = "Basic"     # 250 Mbps
firewall_sku_tier = "Standard"  # 30 Gbps (autoscales)
firewall_sku_tier = "Premium"   # 100 Gbps (autoscales)

# Zones for distribution
zones = ["1", "2", "3"]  # ✅ Distributes load
```

**VPN Gateway Performance**:
```hcl
vpn_gateway_sku = "Basic"       # 100 Mbps
vpn_gateway_sku = "VpnGw1"      # 650 Mbps
vpn_gateway_sku = "VpnGw2"      # 1 Gbps
vpn_gateway_sku = "VpnGw3"      # 1.25 Gbps
vpn_gateway_sku = "VpnGw1AZ"    # 650 Mbps + zones
```

**Service Endpoints** (Low Latency):
```hcl
service_endpoints = [
  "Microsoft.Storage",    # ✅ Bypasses internet
  "Microsoft.KeyVault",   # ✅ Private backbone
  "Microsoft.Sql"         # ✅ Lower latency
]
```

**Scoring**:
- Appropriate SKU for performance: +30 points
- Autoscaling where available: +20 points
- Service endpoints: +20 points
- Minimal network hops: +15 points
- Performance documentation: +15 points

**Documentation References**:
```
Query: "Well-Architected performance efficiency Azure Firewall throughput"
Query: "Azure Firewall performance testing warm-up"
Query: "VPN Gateway performance throughput comparison"
```

## Common Findings and Recommendations

### Finding: Missing Diagnostic Settings

**Impact**: Operational Excellence -15 points

**Code Fix**:
```hcl
variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace for diagnostics (required for production)"
  type        = string
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  count = var.enable_firewall ? 1 : 0
  
  name                       = "firewall-diagnostics"
  target_resource_id         = azurerm_firewall.hub[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  enabled_log {
    category = "AzureFirewallApplicationRule"
  }
  
  enabled_log {
    category = "AzureFirewallNetworkRule"
  }
  
  enabled_log {
    category = "AzureFirewallThreatIntel"
  }
  
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

**Reference**: [Azure Firewall Diagnostics](https://learn.microsoft.com/azure/firewall/firewall-diagnostics)

### Finding: No NSG Flow Logs

**Impact**: Security -10 points, Operational Excellence -10 points

**Code Fix**:
```hcl
variable "enable_nsg_flow_logs" {
  description = "Enable NSG flow logs for traffic analysis"
  type        = bool
  default     = true
}

variable "flow_log_storage_account_id" {
  description = "Storage account for NSG flow logs"
  type        = string
}

resource "azurerm_network_watcher_flow_log" "nsg" {
  for_each = var.enable_nsg_flow_logs ? var.subnets : {}
  
  network_watcher_name      = "NetworkWatcher_${var.location}"
  resource_group_name       = "NetworkWatcherRG"
  network_security_group_id = azurerm_network_security_group.subnets[each.key].id
  storage_account_id        = var.flow_log_storage_account_id
  enabled                   = true
  version                   = 2
  
  retention_policy {
    enabled = true
    days    = 30
  }
  
  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = var.location
    workspace_resource_id = var.log_analytics_workspace_resource_id
    interval_in_minutes   = 10
  }
}
```

**Reference**: [NSG Flow Logs](https://learn.microsoft.com/azure/network-watcher/nsg-flow-logs-overview)

### Finding: Threat Intelligence in Alert Mode

**Impact**: Security -5 points

**Code Fix**:
```hcl
variable "firewall_threat_intel_mode" {
  description = "Threat intelligence mode for Azure Firewall"
  type        = string
  default     = "Deny"  # Changed from "Alert"
  
  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.firewall_threat_intel_mode)
    error_message = "Threat intelligence mode must be 'Off', 'Alert', or 'Deny'."
  }
}
```

**Justification**: In production, known malicious traffic should be automatically blocked, not just alerted.

**Reference**: [Azure Firewall Threat Intelligence](https://learn.microsoft.com/azure/firewall/threat-intel)

## Scoring Framework

### Overall Compliance Score Calculation

```
Total Score = (CAF Score * 0.4) + (WAF Score * 0.6)

CAF Score = (Network Topology + Naming + Tagging + Organization) / 4
WAF Score = (Reliability + Security + Cost + OpEx + Performance) / 5
```

### Grade Interpretation

- **90-100%**: ✅ Excellent - Production ready
- **80-89%**: ✅ Good - Minor enhancements needed
- **70-79%**: ⚠️ Acceptable - Several improvements required
- **60-69%**: ⚠️ Needs Work - Significant gaps
- **Below 60%**: ❌ Not Recommended - Major revisions needed

### Priority Assignment

**High Priority** (Must Fix):
- Security vulnerabilities
- Missing reliability features for production
- CAF/WAF violations that impact SLA

**Medium Priority** (Should Fix):
- Missing monitoring/diagnostics
- Cost optimization opportunities
- Documentation gaps

**Low Priority** (Nice to Have):
- Performance optimizations
- Additional validation rules
- Enhanced documentation

## Integration Example

```markdown
## Architecture Review: Hub Module

### Step 1: Get Terraform Best Practices
Command: `azureterraformbestpractices get`
Result: ✅ Workflow validated, style guide confirmed

### Step 2: Search CAF Documentation
Query: "Cloud Adoption Framework hub spoke network topology"
Found: 10 relevant articles
Key Finding: Hub-spoke pattern correctly implemented

### Step 3: Search WAF Documentation

**Reliability**:
Query: "Well-Architected reliability availability zones"
Score: 90% - Zone redundancy present

**Security**:
Query: "Well-Architected security network NSG encryption"
Score: 95% - Strong security posture

**Cost**:
Query: "Well-Architected cost optimization Azure Firewall"
Score: 85% - Good SKU selection

**Operations**:
Query: "Well-Architected operational excellence monitoring"
Score: 80% - Missing diagnostics

**Performance**:
Query: "Well-Architected performance efficiency scalability"
Score: 90% - Appropriate sizing

### Overall Score: 88%

### Top 3 Recommendations:
1. Add diagnostic settings (High)
2. Enable NSG flow logs (High)
3. Document performance considerations (Medium)
```
