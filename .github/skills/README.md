# Agent Skills

This directory contains GitHub Copilot Agent Skills following the [Agent Skills specification](https://agentskills.io/specification).

## Skills Overview

| Skill | Description | Lines |
|-------|-------------|-------|
| [azure-verified-modules](azure-verified-modules/) | Learn from Azure Verified Modules patterns to build better custom Terraform modules | 116 |
| [github-actions-terraform](github-actions-terraform/) | Debug and fix failing Terraform GitHub Actions workflows | 134 |
| [terraform-security-scan](terraform-security-scan/) | Perform security scanning and compliance checking of Terraform configurations | 165 |

## Skill Structure

Each skill follows the Agent Skills specification format:

```
skill-name/
├── SKILL.md              # Required: Main skill definition
└── references/           # Optional: Additional documentation
    └── REFERENCE.md      # Detailed technical reference
```

### SKILL.md Format

Each `SKILL.md` file contains:

1. **YAML Frontmatter** (required):
   - `name`: Skill identifier (must match directory name)
   - `description`: What the skill does and when to use it
   - `metadata`: Optional metadata (author, version, category)

2. **Markdown Body**: Step-by-step instructions and examples

Example:
```yaml
---
name: skill-name
description: What this skill does and when to use it.
metadata:
  author: github-copilot-skills-terraform
  version: "1.0.0"
  category: terraform-azure
---

# Skill Title

Instructions and examples go here...
```

## Validation

Skills are automatically validated on every push and pull request. The validation checks:

- ✅ SKILL.md files don't exceed 500 lines (per spec recommendation)
- ✅ Frontmatter is properly formatted YAML
- ✅ Directory name matches the `name` field
- ✅ Required fields are present (`name`, `description`)
- ✅ No code blocks wrapping frontmatter

### Run Validation Locally

```bash
# From repository root
./.github/scripts/validate-skills.sh
```

### Validation Output

```
=== Validating Agent Skills ===

📏 Checking SKILL.md file sizes (max 500 lines)...
   azure-verified-modules:        116 lines ✅
   github-actions-terraform:      134 lines ✅
   terraform-security-scan:       165 lines ✅

📝 Checking frontmatter format...
   azure-verified-modules:        ✅
   github-actions-terraform:      ✅
   terraform-security-scan:       ✅

🔍 Checking for code block issues...
✅ No code block issues found

✅ All skills passed validation!
```

## Creating New Skills

1. Create a new directory with the skill name (lowercase, hyphens only)
2. Add a `SKILL.md` file with proper frontmatter
3. Keep the main SKILL.md under 500 lines
4. Move detailed content to `references/REFERENCE.md`
5. Run validation: `./.github/scripts/validate-skills.sh`

### Template

```yaml
---
name: my-new-skill
description: Brief description of what this skill does and when to use it. Include trigger keywords.
metadata:
  author: github-copilot-skills-terraform
  version: "1.0.0"
  category: terraform-azure
---

# My New Skill

## When to Use This Skill

- Situation 1
- Situation 2

## Instructions

Step-by-step guide...

## Examples

Code examples...

## Additional Resources

For more details, see the [reference guide](references/REFERENCE.md).
```

## Best Practices

1. **Description field**: Include specific keywords that help agents identify when to use the skill
2. **Progressive disclosure**: Keep SKILL.md concise, move detailed content to references/
3. **Examples**: Include practical, working examples
4. **Trigger keywords**: Add common phrases users might say that should activate the skill
5. **File size**: Keep SKILL.md under 500 lines for optimal agent performance

## Specification Compliance

These skills comply with the [Agent Skills specification v1.0](https://agentskills.io/specification):

- ✅ Directory structure with `SKILL.md`
- ✅ YAML frontmatter with required fields
- ✅ Optional `references/` and `scripts/` directories
- ✅ Progressive disclosure (main file < 500 lines)
- ✅ Relative file references
- ✅ Proper naming conventions (lowercase, hyphens, no consecutive hyphens)

## Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [What are Skills?](https://agentskills.io/what-are-skills)
- [Integrate Skills](https://agentskills.io/integrate-skills)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
