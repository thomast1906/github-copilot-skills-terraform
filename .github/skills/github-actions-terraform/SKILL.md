---
name: github-actions-terraform
description: Debug and fix failing Terraform GitHub Actions workflows. Use this skill when debugging CI/CD failures, fixing Terraform pipeline issues, troubleshooting authentication errors, or setting up new GitHub Actions workflows for infrastructure deployments.
metadata:
  author: github-copilot-skills-terraform
  version: "1.0.0"
  category: terraform-cicd
---

# GitHub Actions Terraform Debugging Skill

This skill helps you debug and fix failing Terraform GitHub Actions workflows for Azure infrastructure deployments.

## When to Use This Skill

- Debugging failing Terraform CI/CD pipelines
- Troubleshooting authentication issues in GitHub Actions
- Fixing plan/apply workflow failures
- Optimizing Terraform workflow performance
- Setting up new Terraform pipelines

## Common Workflow Failures

### 1. Authentication Failures

#### OIDC/Federated Credentials (Recommended)

```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

**Common Issues:**
- Missing or incorrect federated credential configuration
- Wrong audience setting
- Repository/branch restrictions not matching

**Fix:**
```bash
# Create federated credential
az ad app federated-credential create \
  --id <app-object-id> \
  --parameters '{
    "name": "github-actions",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:org/repo:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### 2. State Backend Errors

#### State Lock Errors

```
Error: Error acquiring the state lock
```

**Fix:**
```bash
terraform force-unlock <LOCK_ID>
```

#### State Access Denied

**Fixes:**
- Verify storage account exists
- Check RBAC permissions (Storage Blob Data Contributor)
- Verify container exists
- Check network access (if private endpoint)

### 3. Provider Initialization Failures

```
Error: Failed to query available provider packages
```

**Fixes:**
```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    terraform_version: "1.6.0"
    
- name: Terraform Init
  run: terraform init -upgrade
  env:
    ARM_SKIP_PROVIDER_REGISTRATION: "true"
```

### 4. Plan/Apply Failures

#### Resource Already Exists

**Fix:**
```bash
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/rg-name
```

## Debugging Steps

### 1. Enable Debug Logging

```yaml
env:
  TF_LOG: DEBUG
  TF_LOG_PATH: terraform.log
```

### 2. Check Azure Context

```yaml
- name: Debug Azure Context
  run: |
    az account show
    az account list-locations -o table
```

## Best Practices

1. **Use OIDC** - Avoid long-lived secrets
2. **Pin versions** - Terraform, providers, actions
3. **Use environments** - For approval gates
4. **Cache providers** - Speed up runs
5. **Artifact plans** - Ensure apply uses exact plan
6. **Minimal permissions** - Least privilege for service principal

## Additional Resources

For complete workflow templates and detailed debugging guides, see the [reference guide](references/REFERENCE.md).
