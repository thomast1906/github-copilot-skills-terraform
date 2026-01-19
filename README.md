# GitHub Copilot Terraform Skills for Azure

A **template repository** providing GitHub Copilot agents and skills for Terraform Azure operations. Copy these agents and skills into your infrastructure repositories to enhance your Terraform workflow with AI assistance.

## 🎯 Overview

This repository provides:

- **Custom GitHub Copilot Agents** - Specialized agent definitions for Terraform Azure operations
- **Agent Skills** - Reusable skills for security scanning, module discovery, and CI/CD patterns
- **Copilot Instructions** - Configuration templates for optimal Copilot assistance
- **Best Practices** - Guidelines for using MCP servers and Azure Verified Modules

> **Note:** This is NOT an infrastructure repository. It contains reusable agent definitions and skills that you copy into your actual Terraform projects.

## 📁 Repository Structure

**Current Structure:**
```
├── .github/
│   ├── agents/                  # GitHub Copilot agent definitions
│   │   ├── terraform-module-expert.agent.md
│   │   └── terraform-security.agent.md
│   ├── skills/                  # Reusable agent skills (agentskills.io spec)
│   │   ├── azure-verified-modules/
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   │       └── REFERENCE.md
│   │   ├── github-actions-terraform/
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   │       └── REFERENCE.md
│   │   └── terraform-security-scan/
│   │       ├── SKILL.md
│   │       └── references/
│   │           └── REFERENCE.md
│   └── copilot-instructions.md  # Global Copilot instructions
├── .vscode/
│   └── mcp.json                 # MCP server configuration
├── AGENTS.md                    # Context for AI coding agents
└── README.md                    # This file
```

**When Used in Target Infrastructure Repository:**
```
your-terraform-project/
├── .github/
│   ├── agents/                  # Copy agents from this repo
│   ├── skills/                  # Copy skills from this repo
│   ├── copilot-instructions.md  # Copy from this repo
│   └── workflows/               # Your CI/CD workflows
├── infra/
│   ├── modules/                 # Your custom Terraform modules
│   │   └── my-module/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       ├── versions.tf
│   │       ├── README.md
│   │       └── examples/        # Working examples INSIDE the module
│   │           └── basic/
│   │               ├── main.tf
│   │               ├── variables.tf
│   │               ├── outputs.tf
│   │               ├── terraform.tfvars.example
│   │               ├── example.auto.tfvars
│   │               └── README.md
│   ├── environments/            # Your environment configs
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── shared/                  # Your shared configurations
└── .vscode/
    └── mcp.json                 # MCP server configuration
```

## 🤖 Agents

Agents are defined in [.github/agents/](.github/agents/) as `.agent.md` files:

| Agent | Purpose | Status |
|-------|---------|--------|
| `terraform-coordinator` | Central routing agent for handoffs between specialists | 🚧 WIP |
| `terraform-security` | Security scanning and compliance checks | 🚧 WIP |
| `terraform-module-expert` | Azure Verified Modules discovery and implementation | ✅ Available |
| `azure-architecture-reviewer` | Validates against CAF and Well-Architected Framework | ✅ Available |

## 🛠 Skills

Skills follow the [Agent Skills specification](https://agentskills.io/specification) and are defined in [.github/skills/](.github/skills/):

| Skill | Description | Status |
|-------|-------------|--------|
| `terraform-security-scan` | Runs security analysis with tfsec/checkov | 🚧 WIP |
| `azure-verified-modules` | Searches and implements Azure Verified Modules | ✅ Available |
| `azure-architecture-review` | Validates CAF and WAF compliance using Azure MCP | ✅ Available |
| `github-actions-terraform` | CI/CD workflow patterns for Terraform | 🚧 WIP |

### Skill Structure

Each skill follows the spec-compliant structure:

```
.github/skills/{skill-name}/
├── SKILL.md              # Required - Instructions and metadata
└── references/           # Optional - Detailed documentation
    └── REFERENCE.md      # Reference material loaded on-demand
```

Skills use progressive disclosure - `SKILL.md` metadata loads first, then instructions, then references only when needed.

## 🔧 MCP Server Configuration

This repository includes an example MCP configuration in [.vscode/mcp.json](.vscode/mcp.json) for the **HashiCorp Terraform MCP Server** and **Azure MCP Server**.

When copying to your infrastructure repository, you can use this configuration as-is or customize it:

```json
{
  "servers": {
    "terraform": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "TFE_TOKEN=${input:tfe_token}",
        "-e", "TFE_ADDRESS=${input:tfe_address}",
        "hashicorp/terraform-mcp-server:0.3.3"
      ]
    }
  }
}
```

### Setting Up Azure MCP Server

The Azure MCP Server provides Azure-specific tools including Terraform best practices and resource queries.

**Installation:**

1. **Install the Azure MCP Server Extension:**
   ```bash
   code --install-extension ms-azuretools.vscode-azure-mcp-server
   ```
   Or install via VS Code Extensions Marketplace: [Azure MCP Server](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azure-mcp-server)

2. **Restart VS Code** to activate the extension

3. **Authenticate with Azure:**
   ```bash
   az login
   ```
   The Azure MCP Server automatically uses your Azure CLI credentials.

**What You Get:**

The Azure MCP Server extension automatically configures itself and provides:
- `azureterraformbestpractices` - **Must call before generating any Azure Terraform code**
- `azure_resources` - Query Azure Resource Graph
- `get_bestpractices` - Deployment and security best practices
- Azure-specific context for Copilot agents

> **Note:** Unlike the Terraform MCP Server which runs via Docker, the Azure MCP Server is a VS Code extension that handles its own configuration automatically. No manual mcp.json entry needed!

### Available MCP Tools

**Terraform MCP Server:**

| Tool | Description |
|------|-------------|
| `search_modules` | Search Terraform Registry for modules |
| `get_module_details` | Get module documentation and examples |
| `search_providers` | Search for provider resources |
| `get_provider_details` | Get resource documentation |

**Azure MCP Server:**

| Tool | Description |
|------|-------------|
| `azureterraformbestpractices` | **MUST call before generating Terraform code** - Returns current Azure Terraform best practices, security recommendations, and Azure provider-specific guidance |
| `azure_resources` | Query Azure Resource Graph for existing resources |
| `get_bestpractices` | Get deployment and implementation best practices |

## 🚀 Quick Start

### Using This Template

**Option 1: Copy agents and skills to existing Terraform repository**

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/github-copilot-skills-terraform.git

# Copy agents and skills to your infrastructure repo
cp -r github-copilot-skills-terraform/.github/agents your-terraform-repo/.github/
cp -r github-copilot-skills-terraform/.github/skills your-terraform-repo/.github/
cp github-copilot-skills-terraform/.github/copilot-instructions.md your-terraform-repo/.github/
cp -r github-copilot-skills-terraform/.vscode your-terraform-repo/
cp github-copilot-skills-terraform/AGENTS.md your-terraform-repo/
```

**Option 2: Create new infrastructure repository with these agents**

```bash
# Use this as a template and add your Terraform infrastructure
gh repo create my-terraform-azure --template github-copilot-skills-terraform
cd my-terraform-azure

# Create infrastructure structure
mkdir -p infra/{modules,environments/{dev,staging,prod},shared}
```

### Prerequisites for Target Infrastructure Repository

- Azure subscription with appropriate permissions
- GitHub repository with Copilot enabled
- Terraform >= 1.5.0
- Azure CLI installed locally

### Setup in Your Infrastructure Repository

1. **Copy agents and skills from this repository (see above)**

2. **Ensure MCP servers are configured** (see [.vscode/mcp.json](.vscode/mcp.json))
   - Terraform MCP Server for module/provider documentation
   - Azure MCP Server for `azureterraformbestpractices` and Azure-specific tools

3. **Configure Azure credentials (OIDC - Recommended)**

```bash
# Create App Registration for OIDC
az ad app create --display-name "github-actions-terraform"

# Get the App ID
APP_ID=$(az ad app list --display-name "github-actions-terraform" --query "[0].appId" -o tsv)

# Create Service Principal
az ad sp create --id $APP_ID

# Create Federated Credential for GitHub Actions
az ad app federated-credential create --id $APP_ID --parameters '{
  "name": "github-actions-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:YOUR_ORG/YOUR_REPO:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'

# Assign role to subscription
az role assignment create \
  --assignee $APP_ID \
  --role "Contributor" \
  --scope "/subscriptions/{subscription-id}"
```

3. **Add GitHub Secrets (for OIDC)**

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | App Registration Client ID |
| `AZURE_SUBSCRIPTION_ID` | Target Subscription ID |
| `AZURE_TENANT_ID` | Azure AD Tenant ID |

> **Note:** With OIDC, you don't need `AZURE_CLIENT_SECRET`!

4. **Configure backend storage**

```bash
# Create storage account for Terraform state
az storage account create \
  --name tfstate$RANDOM \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name <storage-account-name>
```

## 📚 Documentation

- [GitHub Copilot Instructions](.github/copilot-instructions.md) - Configuration for Copilot in Terraform projects
- [AGENTS.md](AGENTS.md) - Context for AI coding agents
- [Terraform Module Expert Agent](.github/agents/terraform-module-expert.agent.md)
- [Terraform Security Agent](.github/agents/terraform-security.agent.md)
- [Available Skills](.github/skills/) - Browse the skills directory

## 📖 Additional Reading & Inspiration

Learn more about GitHub Copilot agents and skills:

- [Agent Skills Specification](https://agentskills.io/specification) - Official Agent Skills format specification
- [GitHub Awesome Copilot](https://github.com/github/awesome-copilot) - Community-contributed instructions, agents, and skills
- [VS Code: Copilot Customization with Agents & Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills) - Official VS Code documentation
- [VS Code: Custom Agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents) - Creating custom agents
- [GitHub Copilot Now Supports Agent Skills](https://github.blog/changelog/2025-12-18-github-copilot-now-supports-agent-skills/) - Feature announcement
- [About Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) - GitHub Copilot concepts and documentation

## 🔒 Security

This repository follows Azure security best practices:

- ✅ Managed Identity preferred over Service Principals
- ✅ Federated credentials (OIDC) for GitHub Actions
- ✅ No hardcoded credentials
- ✅ Key Vault integration for secrets
- ✅ State file encryption
- ✅ RBAC with least privilege

## 📋 License

MIT License - See [LICENSE](LICENSE) for details.

## 🤝 Contributing

Contributions welcome! To contribute:

1. Fork this repository
2. Create a feature branch for your agent or skill
3. Add your agent to `.github/agents/` or skill to `.github/skills/`
4. Submit a pull request with a clear description

All agents should follow the `.agent.md` format, and skills should include a `SKILL.md` file.
