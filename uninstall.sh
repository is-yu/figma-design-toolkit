#!/bin/bash
set -e

echo ""
echo "=== Prototype with Design System — Uninstaller ==="
echo ""

SKILL_DIR="$HOME/.claude/skills/prototype-with-ds"
SETTINGS_FILE="$HOME/.claude/settings.local.json"

# 1. Remove skill files
if [ -d "$SKILL_DIR" ]; then
  rm -rf "$SKILL_DIR"
  echo "Removed skill from $SKILL_DIR"
else
  echo "Skill not found at $SKILL_DIR (already removed?)"
fi

# 2. Optionally remove permissions
if [ -f "$SETTINGS_FILE" ]; then
  read -p "Remove Figma MCP permissions from global settings? (y/N) " confirm
  if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    python3 -c "
import json

settings_path = '$SETTINGS_FILE'
perms_to_remove = {
    'mcp__plugin_figma_figma__whoami',
    'mcp__plugin_figma_figma__get_metadata',
    'mcp__plugin_figma_figma__get_libraries',
    'mcp__plugin_figma_figma__use_figma',
    'mcp__plugin_figma_figma__get_screenshot',
    'mcp__plugin_figma_figma__search_design_system',
    'mcp__plugin_figma_figma__get_variable_defs',
    'mcp__plugin_figma_figma__get_design_context',
}

with open(settings_path, 'r') as f:
    settings = json.load(f)

if 'permissions' in settings and 'allow' in settings['permissions']:
    settings['permissions']['allow'] = [
        p for p in settings['permissions']['allow']
        if p not in perms_to_remove
    ]

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"
    echo "Permissions removed."
  else
    echo "Permissions left in place."
  fi
fi

echo ""
echo "Uninstall complete."
