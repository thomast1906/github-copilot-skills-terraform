# GitHub Copilot Agents & Skills for Terraform on Azure

Template repository providing specialized GitHub Copilot agents and reusable skills for Terraform Azure operations. Enhance your infrastructure-as-code workflow with AI-powered assistance for security scanning, module discovery, and architecture validation.

## Overview

This template provides ready-to-use components for Copilot-enhanced Terraform workflows:

- **Specialized Agents** - Pre-configured agents for module management, security analysis, and architecture review
- **Reusable Skills** - Modular capabilities following the [Agent Skills specification](https://agentskills.io/specification)
- **MCP Integration** - Configuration for HashiCorp Terraform and Azure MCP servers
- **Best Practices** - Guidelines aligned with Azure Well-Architected Framework and Cloud Adoption Framework

> **Important:** This is a template repository, not infrastructure code. Copy these components into your Terraform projects.

## Repository Structure

```
.github/
├── agents/                     # Specialized Copilot agents
│   ├── terraform-module-expert.agent.md
│   ├── terraform-security.agent.md
│   ├── terraform-coordinator.agent.md
│   └── azure-architecture-reviewer.agent.md
├── skills/                     # Reusable agent skills
│   ├── azure-verified-modules/
│   ├── terraform-security-scan/
│   ├── azure-architecture-review/
│   └── github-actions-terraform/
└── copilot-instructions.md     # Global Copilot configuration
.vscode/
└── mcp.json                    # MCP server configuration
AGENTS.md                       # AI agent context documentation
```

When integrated into your Terraform repository:

```
your-terraform-project/
├── .github/
│   ├── agents/                 # Copied from this template
│   ├── skills/                 # Copied from this template
│   ├── copilot-instructions.md # Copied from this template
│   └── workflows/              # Your CI/CD pipelines
├── infra/
│   ├── modules/                # Custom Terraform modules
│   ├── environments/           # Environment configurations (dev/staging/prod)
│   └── shared/                 # Shared infrastructure
└── .vscode/
    └── mcp.json                # MCP server configuration
```

## Agents

Pre-configured agents for specialized Terraform operations ([.github/agents/](.github/agents/)):

| Agent | Purpose |
|-------|---------|
| `terraform-module-expert` | Discovers and implements Azure Verified Modules with best practices |
| `terraform-security` | Performs security scanning and compliance validation |
| `azure-architecture-reviewer` | Validates configurations against CAF and Well-Architected Framework |
| `terraform-coordinator` | Routes requests between specialized agents |

## Skills

Modular capabilities following [Agent Skills specification](https://agentskills.io/specification) ([.github/skills/](.github/skills/)):

| Skill | Description |
|-------|-------------|
| `azure-verified-modules` | Searches and implements Azure Verified Modules |
| `terraform-security-scan` | Executes security analysis with tfsec and checkov |
| `azure-architecture-review` | Validates CAF and WAF compliance |
| `github-actions-terraform` | CI/CD workflow patterns for Terraform deployments |

Each skill follows a progressive disclosure pattern with `SKILL.md` (metadata and instructions) and optional `references/` directory for detailed documentation.

## MCP Server Configuration

This template includes MCP configuration for enhanced Terraform tooling ([.vscode/mcp.json](.vscode/mcp.json)).

### HashiCorp Terraform MCP Server

Provides module and provider documentation access:

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

**Available Tools:**
- `search_modules` - Search Terraform Registry
- `get_module_details` - Retrieve module documentation
- `search_providers` - Find provider resources
- `get_provider_details` - Get resource specifications

### Azure MCP Server

Install via VS Code Extension Marketplace:

```bash
code --install-extension ms-azuretools.vscode-azure-mcp-server
az login  # Authenticate with Azure
```

**Available Tools:**
- `azureterraformbestpractices` - Azure Terraform best practices (call before code generation)
- `azure_resources` - Query Azure Resource Graph
- `get_azure_bestpractices` - Deployment and security guidance

> The Azure MCP Server extension auto-configures and uses Azure CLI credentials.

## Quick Start

**Use as GitHub Template:**

```bash
gh repo create my-terraform-azure --template YOUR_USERNAME/github-copilot-skills-terraform
```

**Copy to Existing Repository:**

```bash
cp -r .github/agents your-terraform-repo/.github/
cp -r .github/skills your-terraform-repo/.github/
cp .github/copilot-instructions.md your-terraform-repo/.github/
cp .vscode/mcp.json your-terraform-repo/.vscode/
cp AGENTS.md your-terraform-repo/
```

**Configure MCP Servers:**

1. Install [Azure MCP Server](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azure-mcp-server) extension
2. Ensure Docker is running for Terraform MCP Server
3. Run `az login` to authenticate Azure MCP

## Documentation

- [Copilot Instructions](.github/copilot-instructions.md) - Global configuration
- [AGENTS.md](AGENTS.md) - AI agent context and guidelines
- [Agent Definitions](.github/agents/) - Individual agent documentation
- [Skills Directory](.github/skills/) - Skill specifications and references

## Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [GitHub Awesome Copilot](https://github.com/github/awesome-copilot)
- [VS Code Copilot Customization](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [About Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)

## Contributing

Contributions are welcome. To contribute:

1. Fork this repository
2. Create a feature branch
3. Add your agent (`.github/agents/`) or skill (`.github/skills/`)
4. Submit a pull request with clear description

Follow the `.agent.md` format for agents and include `SKILL.md` for skills.

## License

MIT License - See [LICENSE](LICENSE) for details.
