#!/bin/bash
set -e

REPO_URL="https://github.com/is-yu/figma-design-toolkit"
BRANCH="main"

echo ""
echo "=== Figma Design Toolkit for Claude Code ==="
echo ""

# Validate location
if [ ! -d ".git" ]; then
  echo "Warning: No .git found in current directory."
  read -p "Install here anyway? (y/N) " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted. Navigate to your project root and try again."
    exit 1
  fi
fi

# Download to temp
TMPDIR=$(mktemp -d)
echo "Downloading toolkit..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMPDIR/toolkit" 2>/dev/null || {
  echo "Error: Could not download from $REPO_URL"
  echo "Check that the repository exists and you have access."
  rm -rf "$TMPDIR"
  exit 1
}

# Handle existing .claude/settings.json
if [ -f ".claude/settings.json" ]; then
  echo "Existing .claude/settings.json found — backing up to .claude/settings.json.backup"
  cp .claude/settings.json .claude/settings.json.backup
fi

# Copy .claude structure
mkdir -p .claude/skills
cp "$TMPDIR/toolkit/.claude/settings.json" .claude/settings.json
cp -r "$TMPDIR/toolkit/.claude/skills/figma-preflight" .claude/skills/
cp -r "$TMPDIR/toolkit/.claude/skills/reference-interpreter" .claude/skills/
cp -r "$TMPDIR/toolkit/.claude/skills/figma-style-binding" .claude/skills/
cp -r "$TMPDIR/toolkit/.claude/skills/component-rules" .claude/skills/

# Handle CLAUDE.md
if [ -f "CLAUDE.md" ]; then
  echo ""
  echo "Existing CLAUDE.md found — appending toolkit config."
  echo "" >> CLAUDE.md
  echo "---" >> CLAUDE.md
  echo "" >> CLAUDE.md
  cat "$TMPDIR/toolkit/CLAUDE.md.template" >> CLAUDE.md
else
  cp "$TMPDIR/toolkit/CLAUDE.md.template" CLAUDE.md
fi

# Cleanup
rm -rf "$TMPDIR"

# Onboarding output
cat << 'EOF'

============================================
  Figma Design Toolkit — Installed
============================================

What was installed:
  .claude/settings.json       Figma MCP permissions + safety hooks
  .claude/skills/             4 skills:
    figma-preflight           Session startup + token map loading
    reference-interpreter     Screenshot/URL → Design Brief
    figma-style-binding       Enforces design system token binding
    component-rules           Library-first component construction
  CLAUDE.md                   Workflow rules + Figma file placeholder

Prerequisites (check before starting):
  1. Figma MCP plugin must be configured in Claude Code
     (https://github.com/anthropics/claude-code/wiki/Figma-MCP)
  2. Your target Figma file needs a design system library connected

Getting started:
  1. Open Claude Code in this directory
  2. Type: preflight
  3. Paste your Figma file URL when prompted
  4. Share a reference or describe what to build

EOF
