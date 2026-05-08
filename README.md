# Figma Design Toolkit for Claude Code

Automate design creation in Figma using your connected design system. Claude Code builds UI directly in your Figma file, binding every color, text style, and spacing value to your design tokens — no hardcoded values.

## Prerequisites

1. **Claude Code** installed ([claude.ai/code](https://claude.ai/code))
2. **Figma MCP plugin** configured in Claude Code
3. A **Figma file** with a design system library connected

## Install

From your project directory:

```bash
curl -fsSL https://raw.githubusercontent.com/is-yu/figma-design-toolkit/main/install.sh | bash
```

Or clone and run manually:

```bash
git clone https://github.com/is-yu/figma-design-toolkit.git /tmp/fdt
bash /tmp/fdt/install.sh
rm -rf /tmp/fdt
```

## Getting Started

1. Open Claude Code in your project directory
2. Type: **`preflight`**
3. Paste your Figma file URL when prompted
4. Share a reference (screenshot, URL, or description) of what you'd like to build

## Workflow

```
preflight → reference brief → confirmed → build → QA
```

| Step | What happens |
|---|---|
| **Preflight** | Connects to Figma, loads your design system tokens |
| **Reference** | Analyzes your screenshot/URL, maps to tokens, outputs a Design Brief |
| **Build** | Constructs in Figma using only your design system (library variables + text styles) |
| **QA** | Audits every node for proper token binding — fails block progress |

## What's Included

| File | Purpose |
|---|---|
| `.claude/settings.json` | Figma MCP permissions + pre/post safety hooks |
| `.claude/skills/figma-preflight/` | Session startup, token map loading |
| `.claude/skills/reference-interpreter/` | Screenshot/URL → structured Design Brief |
| `.claude/skills/figma-style-binding/` | Enforces design system token binding on every node |
| `.claude/skills/component-rules/` | Library-first component construction rules |
| `CLAUDE.md` | Workflow rules and Figma file configuration |

## Troubleshooting

**"MCP connection failed"** — Ensure the Figma MCP plugin is installed and authenticated. Run `figma whoami` to check.

**"No libraries connected"** — Your Figma file needs at least one design system library enabled. Open the file in Figma → Assets panel → Libraries → Enable your design system.

**"No matching token"** — The toolkit flags gaps when your design needs a token that doesn't exist in the connected library. You'll be asked whether to use the nearest match or add a new token.

## Course-Correcting

The toolkit is designed to be interrupted. If something seems wrong:
- Say "stop" at any point
- Correct the approach — Claude will adjust
- The Design Brief step exists specifically so you can review before anything is built
