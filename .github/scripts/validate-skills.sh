#!/bin/bash
set -e

echo "=== Validating Agent Skills ==="
echo ""

FAILED=0
MAX_LINES=500

# Check file sizes
echo "📏 Checking SKILL.md file sizes (max $MAX_LINES lines)..."
for skill_file in .github/skills/*/SKILL.md; do
  if [ -f "$skill_file" ]; then
    LINE_COUNT=$(wc -l < "$skill_file")
    SKILL_NAME=$(dirname "$skill_file" | xargs basename)
    
    printf "   %-30s %3d lines " "$SKILL_NAME:" "$LINE_COUNT"
    
    if [ "$LINE_COUNT" -gt "$MAX_LINES" ]; then
      echo "❌ EXCEEDS LIMIT"
      echo "      Consider moving content to references/ directory"
      FAILED=1
    else
      echo "✅"
    fi
  fi
done
echo ""

# Check frontmatter format
echo "📝 Checking frontmatter format..."
for skill_file in .github/skills/*/SKILL.md; do
  if [ -f "$skill_file" ]; then
    SKILL_NAME=$(dirname "$skill_file" | xargs basename)
    printf "   %-30s " "$SKILL_NAME:"
    
    # Check file starts with ---
    FIRST_LINE=$(head -n 1 "$skill_file")
    if [ "$FIRST_LINE" != "---" ]; then
      echo "❌ Must start with '---'"
      FAILED=1
      continue
    fi
    
    # Check directory name matches name field
    NAME_FIELD=$(sed -n '2,10p' "$skill_file" | grep "^name:" | awk '{print $2}')
    if [ "$NAME_FIELD" != "$SKILL_NAME" ]; then
      echo "❌ Directory name mismatch"
      echo "      Directory: $SKILL_NAME"
      echo "      Name field: $NAME_FIELD"
      FAILED=1
      continue
    fi
    
    # Check required fields exist
    if ! grep -q "^name:" "$skill_file"; then
      echo "❌ Missing 'name' field"
      FAILED=1
      continue
    fi
    
    if ! grep -q "^description:" "$skill_file"; then
      echo "❌ Missing 'description' field"
      FAILED=1
      continue
    fi
    
    echo "✅"
  fi
done
echo ""

# Check for code blocks wrapping frontmatter
echo "🔍 Checking for code block issues..."
for skill_file in .github/skills/*/SKILL.md; do
  if [ -f "$skill_file" ]; then
    SKILL_NAME=$(dirname "$skill_file" | xargs basename)
    
    if head -n 1 "$skill_file" | grep -q '```'; then
      printf "   %-30s ❌ Frontmatter wrapped in code block\n" "$SKILL_NAME:"
      FAILED=1
    fi
  fi
done

if [ "$FAILED" -eq 0 ]; then
  echo "✅ No code block issues found"
  echo ""
fi

# Summary
if [ "$FAILED" -eq 1 ]; then
  echo "❌ Validation failed!"
  exit 1
fi

