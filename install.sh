#!/bin/bash
set -e

echo ""
echo "=== Prototype with Design System — Installer ==="
echo ""

SKILL_DIR="$HOME/.claude/skills/prototype-with-ds"
SETTINGS_FILE="$HOME/.claude/settings.local.json"

# Determine script location (for local installs) or use temp clone
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/skill/SKILL.md" ]; then
  SOURCE_DIR="$SCRIPT_DIR"
else
  echo "Downloading toolkit..."
  TEMP_DIR=$(mktemp -d)
  git clone --quiet --depth 1 https://github.com/is-yu/figma-design-toolkit.git "$TEMP_DIR"
  SOURCE_DIR="$TEMP_DIR"
  trap "rm -rf $TEMP_DIR" EXIT
fi

# 1. Install skill files
echo "Installing skill to $SKILL_DIR..."
mkdir -p "$SKILL_DIR/references"
cp "$SOURCE_DIR/skill/SKILL.md" "$SKILL_DIR/SKILL.md"
cp "$SOURCE_DIR/skill/references/"*.md "$SKILL_DIR/references/"

# 2. Add Figma MCP permissions to global settings
echo "Configuring permissions..."

mkdir -p "$HOME/.claude"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{"permissions":{"allow":[]}}' > "$SETTINGS_FILE"
fi

python3 -c "
import json

settings_path = '$SETTINGS_FILE'
perms_to_add = [
    'mcp__plugin_figma_figma__whoami',
    'mcp__plugin_figma_figma__get_metadata',
    'mcp__plugin_figma_figma__get_libraries',
    'mcp__plugin_figma_figma__use_figma',
    'mcp__plugin_figma_figma__get_screenshot',
    'mcp__plugin_figma_figma__search_design_system',
    'mcp__plugin_figma_figma__get_variable_defs',
    'mcp__plugin_figma_figma__get_design_context',
]

try:
    with open(settings_path, 'r') as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

if 'permissions' not in settings:
    settings['permissions'] = {}
if 'allow' not in settings['permissions']:
    settings['permissions']['allow'] = []

existing = set(settings['permissions']['allow'])
for perm in perms_to_add:
    if perm not in existing:
        settings['permissions']['allow'].append(perm)

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"

# 3. Success message
cat << 'EOF'

============================================
  Prototype with Design System — Installed
============================================

Usage:
  Open Claude Code in any project and type:

    /prototype-with-ds

  You'll be prompted for:
    1. A Figma file URL (must have a design system library connected)
    2. A description of what to build (+ optional reference screenshots)

Prerequisite:
  Figma MCP plugin must be configured in Claude Code
  (https://github.com/anthropics/claude-code/wiki/Figma-MCP)

To uninstall:
  bash <(curl -fsSL https://raw.githubusercontent.com/is-yu/figma-design-toolkit/main/uninstall.sh)

EOF
