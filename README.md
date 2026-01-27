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
│   ├── terraform-provider-upgrade.agent.md
│   └── azure-architecture-reviewer.agent.md
├── skills/                     # Reusable agent skills
│   ├── azure-verified-modules/
│   ├── terraform-security-scan/
│   ├── terraform-provider-upgrade/
│   ├── azure-architecture-review/
│   └── github-actions-terraform/
└── copilot-instructions.md     # Global Copilot configuration
.vscode/
└── mcp.json                    # MCP server configuration
AGENTS.md                       # AI agent context documentation
```

## Agents

Pre-configured agents for specialized Terraform operations ([.github/agents/](.github/agents/)):

| Agent | Purpose | Status |
|-------|---------|--------|
| `terraform-module-expert` | Discovers and implements Azure Verified Modules with best practices | ✅ Ready |
| `terraform-security` | Performs security scanning and compliance validation | 🚧 [WIP] |
| `azure-architecture-reviewer` | Validates configurations against CAF and Well-Architected Framework | ✅ Ready |
| `terraform-provider-upgrade` | Safely upgrades providers with automatic resource migration and breaking change detection | ✅ Ready |
| `terraform-coordinator` | Routes requests between specialized agents | 🚧 [WIP] |

## Skills

Modular capabilities following [Agent Skills specification](https://agentskills.io/specification) ([.github/skills/](.github/skills/)):

| Skill | Description | Status |
|-------|-------------|--------|
| `azure-verified-modules` | Searches and implements Azure Verified Modules | ✅ Ready |
| `terraform-security-scan` | Executes security analysis with tfsec and checkov | 🚧 [WIP] |
| `terraform-provider-upgrade` | Safe provider upgrades with automatic resource migration using moved blocks | ✅ Ready |
| `azure-architecture-review` | Validates CAF and WAF compliance | ✅ Ready |
| `github-actions-terraform` | CI/CD workflow patterns for Terraform deployments | 🚧 [WIP] |

## Prerequisites

To use the agents and skills in this template:

- [Azure MCP Server](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azure-mcp-server) extension
- Docker (for HashiCorp Terraform MCP Server)
- Azure CLI (`az login` required)

MCP configuration is included in [.vscode/mcp.json](.vscode/mcp.json).

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
