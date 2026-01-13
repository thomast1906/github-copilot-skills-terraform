# GitHub Actions Terraform Reference Guide

This reference contains detailed technical information for debugging and configuring Terraform GitHub Actions workflows.

## Complete Workflow Template

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
    environment: production
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

## OIDC Federated Credential Setup

```bash
# Create federated credential for GitHub Actions
az ad app federated-credential create \
  --id <app-object-id> \
  --parameters '{
    "name": "github-actions-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:org/repo:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# For pull requests
az ad app federated-credential create \
  --id <app-object-id> \
  --parameters '{
    "name": "github-actions-pr",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:org/repo:pull_request",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## Debugging Steps

### Enable Debug Logging

```yaml
env:
  TF_LOG: DEBUG
  TF_LOG_PATH: terraform.log
```

### Check Azure Context

```yaml
- name: Debug Azure Context
  run: |
    az account show
    az account list-locations -o table
```

### Verify Permissions

```yaml
- name: Check Permissions
  run: |
    az role assignment list --assignee ${{ secrets.AZURE_CLIENT_ID }} -o table
```

### Test State Access

```yaml
- name: Test State Backend
  run: |
    az storage blob list \
      --account-name ${{ secrets.STATE_STORAGE_ACCOUNT }} \
      --container-name tfstate \
      --auth-mode login
```

## Common Error Solutions

### State Lock Errors

```
Error: Error acquiring the state lock
```

**Solution:**
```bash
terraform force-unlock <LOCK_ID>
```

### Provider Initialization Failures

```
Error: Failed to query available provider packages
```

**Solution:**
```yaml
- name: Terraform Init
  run: terraform init -backend-config="..." -upgrade
  env:
    ARM_SKIP_PROVIDER_REGISTRATION: "true"
```

### Resource Already Exists

```
Error: A resource with the ID already exists
```

**Solution:**
```bash
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/rg-name
```
