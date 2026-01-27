# Agent Skills

GitHub Copilot skills for Terraform Azure operations, following the [Agent Skills specification](https://agentskills.io/specification).

## Available Skills

| Skill | Description |
|-------|-------------|
| [azure-architecture-review](azure-architecture-review/) | Review Terraform code against Microsoft Cloud Adoption Framework and Well-Architected Framework |
| [azure-verified-modules](azure-verified-modules/) | Learn from Azure Verified Modules patterns to build custom Terraform modules |
| [github-actions-terraform](github-actions-terraform/) | Debug and fix failing Terraform GitHub Actions workflows |
| [terraform-provider-upgrade](terraform-provider-upgrade/) | Safe Terraform provider upgrades with automatic resource migration and breaking change detection |
| [terraform-security-scan](terraform-security-scan/) | Security scanning and compliance checking of Terraform configurations |

## Skill Structure

```
skill-name/
├── SKILL.md              # Main skill definition (< 500 lines)
└── references/           # Optional detailed documentation
    └── REFERENCE.md
```

### SKILL.md Format

```yaml
---
name: skill-name
description: What this skill does and when to use it
metadata:
  author: github-copilot-skills-terraform
  version: "1.0.0"
  category: terraform-azure
---

# Skill Content
```

## Validation

Run validation locally:

```bash
./.github/scripts/validate-skills.sh
```

Validates:
- File size (< 500 lines)
- YAML frontmatter format
- Required fields (`name`, `description`)
- Naming conventions

## Creating New Skills

1. Create directory: `skill-name/` (lowercase, hyphens only)
2. Add `SKILL.md` with proper frontmatter
3. Keep under 500 lines; use `references/REFERENCE.md` for details
4. Run validation before committing

## Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
