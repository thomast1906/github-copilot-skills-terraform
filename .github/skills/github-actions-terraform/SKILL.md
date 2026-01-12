---
name: github-actions-terraform
description: Debug and fix failing Terraform GitHub Actions workflows. Use this skill when asked to debug CI/CD failures, fix Terraform pipeline issues, or troubleshoot GitHub Actions for infrastructure deployments.
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

#### Service Principal (Legacy)

```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}
```

**Common Issues:**
- Expired client secret
- Incorrect JSON format in secret
- Missing permissions

### 2. State Backend Errors

#### State Lock Errors

```
Error: Error acquiring the state lock
```

**Fix:**
```bash
# Force unlock (use carefully)
terraform force-unlock <LOCK_ID>
```

#### State Access Denied

```
Error: Failed to get existing workspaces: storage: service returned error
```

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
    terraform_version: "1.6.0"  # Pin version
    
- name: Terraform Init
  run: terraform init -backend-config="..." -upgrade
  env:
    ARM_SKIP_PROVIDER_REGISTRATION: "true"  # If no provider registration perms
```

### 4. Plan/Apply Failures

#### Resource Already Exists

```
Error: A resource with the ID already exists
```

**Fix:**
```bash
# Import existing resource
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/rg-name
```

#### Quota Exceeded

```
Error: QuotaExceeded
```

**Fix:**
- Request quota increase in Azure Portal
- Use different region
- Use smaller SKU

## Optimized Workflow Template

```yaml
name: Terraform CI/CD

on:
  push:
    branches: [main]
    paths:
      - 'infra/**'
      - '.github/workflows/terraform*.yml'
  pull_request:
    branches: [main]
    paths:
      - 'infra/**'

permissions:
  id-token: write  # Required for OIDC
  contents: read
  pull-requests: write  # For PR comments

env:
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  ARM_USE_OIDC: true
  TF_VERSION: "1.6.0"

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Terraform Format Check
        run: terraform fmt -check -recursive
        working-directory: infra
      
      - name: Terraform Init
        run: terraform init -backend=false
        working-directory: infra
      
      - name: Terraform Validate
        run: terraform validate
        working-directory: infra

  plan:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Terraform Init
        run: terraform init
        working-directory: infra
      
      - name: Terraform Plan
        id: plan
        run: |
          terraform plan -no-color -out=tfplan
        working-directory: infra
        continue-on-error: true
      
      - name: Comment PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const output = `#### Terraform Plan 📖
            \`\`\`
            ${{ steps.plan.outputs.stdout }}
            \`\`\`
            `;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })
      
      - name: Upload Plan
        uses: actions/upload-artifact@v4
        with:
          name: tfplan
          path: infra/tfplan

  apply:
    needs: plan
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production  # Requires approval
    steps:
      - uses: actions/checkout@v4
      
      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Download Plan
        uses: actions/download-artifact@v4
        with:
          name: tfplan
          path: infra
      
      - name: Terraform Init
        run: terraform init
        working-directory: infra
      
      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
        working-directory: infra
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

### 3. Verify Permissions

```yaml
- name: Check Permissions
  run: |
    az role assignment list --assignee ${{ secrets.AZURE_CLIENT_ID }} -o table
```

### 4. Test State Access

```yaml
- name: Test State Backend
  run: |
    az storage blob list \
      --account-name ${{ secrets.STATE_STORAGE_ACCOUNT }} \
      --container-name tfstate \
      --auth-mode login
```

## Best Practices

1. **Use OIDC** - Avoid long-lived secrets
2. **Pin versions** - Terraform, providers, actions
3. **Use environments** - For approval gates
4. **Cache providers** - Speed up runs
5. **Artifact plans** - Ensure apply uses exact plan
6. **Minimal permissions** - Least privilege for service principal
