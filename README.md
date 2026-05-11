# Figma Design Toolkit

A collection of Figma skills for [Claude Code](https://claude.ai/code). Each skill adds a slash command that integrates Figma's design capabilities directly into your workflow.

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Prototype with DS | `/prototype-with-ds` | Build production-quality Figma designs using your connected design system. Every color, text style, and spacing value is bound to design tokens. |

More skills coming soon.

## Prerequisites

1. **Claude Code** installed ([claude.ai/code](https://claude.ai/code))
2. **Figma MCP plugin** configured in Claude Code

## Install

Paste this repo link in Claude Code and say "install":

```
https://github.com/is-yu/figma-design-toolkit
```

Or run directly from any terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/is-yu/figma-design-toolkit/main/install.sh)
```

Or clone and run:

```bash
git clone https://github.com/is-yu/figma-design-toolkit.git /tmp/fdt
bash /tmp/fdt/install.sh
rm -rf /tmp/fdt
```

## Usage — `/prototype-with-ds`

Open Claude Code in **any project** and type:

```
/prototype-with-ds
```

You'll be prompted for:
1. A Figma file URL (must have a design system library connected)
2. A description of what to build, plus optional reference screenshots or URLs

### Workflow

```
/prototype-with-ds → preflight → reference brief → confirmed → build → QA
```

| Step | What happens |
|---|---|
| **Prompt** | Asks for Figma URL + description/references |
| **Preflight** | Connects to Figma, loads your design system tokens |
| **Reference** | Analyzes your screenshot/URL, maps to tokens, outputs a Design Brief |
| **Build** | Constructs in Figma using only your design system (library variables + text styles) |
| **QA** | Audits every node for proper token binding — blocks progress on failures |

## Uninstall

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/is-yu/figma-design-toolkit/main/uninstall.sh)
```

## Troubleshooting

**"MCP connection failed"** — Ensure the Figma MCP plugin is installed and authenticated. Run `figma whoami` to check.

**"No libraries connected"** — Your Figma file needs at least one design system library enabled. Open the file in Figma → Assets panel → Libraries → Enable your design system.

**"No matching token"** — The toolkit flags gaps when your design needs a token that doesn't exist in the connected library. You'll be asked whether to use the nearest match or add a new token.

## Course-Correcting

The toolkit is designed to be interrupted. If something seems wrong:
- Say "stop" at any point
- Correct the approach — Claude will adjust
- The Design Brief step exists specifically so you can review before anything is built
