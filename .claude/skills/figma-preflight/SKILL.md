---
name: figma-preflight
description: "Triggers on 'preflight', 'let's start', 'begin', 'start the session', or when a Figma file URL is first shared. On first run, shows onboarding and prompts for Figma file URL. Then verifies MCP connection, audits connected libraries, and loads a Token Map of all Styles and Variables — required before any design work."
disable-model-invocation: false
---

# Figma Preflight

Run at the start of every design session. Do NOT start design work until all steps pass.

**Prerequisite:** Load `figma-use` skill before any `use_figma` call.

---

## Step 0 — First-Run Setup & Onboarding

Read CLAUDE.md. Check if the Figma file URL field contains a valid URL (starts with `https://www.figma.com/design/` or `https://www.figma.com/file/`).

**If URL is missing, placeholder (`{{FIGMA_FILE_URL}}`), or invalid:**

1. Display the toolkit introduction:

```
=== Figma Design Toolkit ===

This toolkit automates design creation in Figma using your connected
design system. Every color, text style, and spacing value is bound to
design tokens — no hardcoded values allowed.

Expected workflow:
1. Preflight — connects to Figma, discovers your design system tokens
2. Reference — share a screenshot/URL → get a structured Design Brief
3. Build — Claude constructs in Figma using only your design system
4. QA — every node is audited for proper token binding

If any step seems wrong, interrupt and course-correct. You're in control.

Requirement: Your Figma file must have a design system library connected.
```

2. Ask the user: **"Paste your Figma file URL (the file where designs should be created):"**

3. Validate the URL format (must contain `figma.com/design/` or `figma.com/file/`). If invalid, ask again.

4. Update CLAUDE.md: replace the placeholder with the provided URL. Use bash:
```bash
sed -i '' 's|{{FIGMA_FILE_URL}}|<USER_PROVIDED_URL>|' CLAUDE.md
```
Or if the line contains a different placeholder pattern, replace the entire Figma file line.

5. Confirm: **"URL saved to CLAUDE.md. All designs will be placed in this file. You can change it later by editing CLAUDE.md. Running preflight checks..."**

**If URL is already valid:** Skip to Step A silently.

---

## Step A — Connection + Config (parallel)

Run these two in parallel:

1. **MCP Connection:** Call `mcp__figma__whoami`. Must return user email and plan. Fail → stop, re-authenticate.
2. **CLAUDE.md:** Read CLAUDE.md. Extract Figma file URL (required — stop if missing), font families, session goal. If fonts field is a placeholder, auto-populate after Step C using STRING variables starting with "Family".

---

## Step B — File + Libraries (parallel)

Parse `fileKey` from the Figma URL, then run in parallel:

1. **File Access:** Call `get_metadata` with extracted nodeId and fileKey. Must return file name and pages.
2. **Libraries:** Call `get_libraries` with fileKey. Store subscribed libraries as **Library Registry** (name, libraryKey, description). These enable `search_design_system` to find library styles and components during design work.

---

## Step C — Styles + Variables + Components (single use_figma call)

Combine all three inventories in one script:

```javascript
const textStyles = await figma.getLocalTextStylesAsync();
const paintStyles = await figma.getLocalPaintStylesAsync();
const collections = await figma.variables.getLocalVariableCollectionsAsync();
const variables = await figma.variables.getLocalVariablesAsync();

const grouped = {};
for (const v of variables) {
  const key = v.resolvedType;
  if (!grouped[key]) grouped[key] = [];
  grouped[key].push({ name: v.name, scopes: v.scopes });
}

const components = {};
for (const page of figma.root.children) {
  await figma.setCurrentPageAsync(page);
  const sets = page.findAll(n => n.type === "COMPONENT_SET");
  const solos = page.findAll(n => n.type === "COMPONENT" && n.parent.type !== "COMPONENT_SET");
  if (sets.length > 0 || solos.length > 0) {
    components[page.name] = {
      sets: sets.map(c => c.name),
      solos: solos.map(c => c.name).slice(0, 15),
    };
  }
}

return {
  textStyles: textStyles.map(s => s.name),
  paintStyles: paintStyles.map(s => s.name),
  collections: collections.map(c => c.name),
  variableCount: variables.length,
  byType: Object.fromEntries(
    Object.entries(grouped).map(([type, vars]) => [type, vars.map(v => v.name)])
  ),
  components
};
```

Store **names only** in context. IDs are looked up on-demand during design work. Library styles/variables are discovered via `search_design_system`.

---

## Token Map

After Step C, derive a semantic index from variables grouped by `scopes`:

| Role | Scope | Example names |
|---|---|---|
| Background fill | `FRAME_FILL`, `SHAPE_FILL` | `background/surface`, `color/neutral-100` |
| Text color | `TEXT_FILL` | `text/primary`, `color/neutral-900` |
| Border / stroke | `STROKE_COLOR` | `border/default`, `color/neutral-300` |
| Gap | `GAP` | `gap/sm`, `spacing/xxs` |
| Padding | `PADDING` | `padding/md`, `spacing/section-xl` |
| Border radius | `CORNER_RADIUS` | `radius/sm`, `radius/full` |

---

## Status Report

```
✅ MCP Connection    — [name] ([email]) · [plan]
✅ CLAUDE.md         — Font: [primary] / [code] · Goal: [goal]
✅ Figma File        — [file name] · [N] pages
✅ Libraries         — [N] connected: [names]
✅ Styles            — [N] text + [N] paint
✅ Variables         — [N] across [N] collections
✅ Components        — [N] sets across [N] pages

── Token Map ──────────────────────────────
Background  : [names]
Text        : [names]
Border      : [names]
Gap         : [names]
Padding     : [names]
Radius      : [names]
────────────────────────────────────────────
```

If any step fails, output ❌ with error and stop.

---

## Step D — Prompt Next Action

After the status report, display:

```
Ready to design. Share a reference (screenshot, URL, or description) of what
you'd like to build, or describe your idea. The design system connected to
your file will be used for all visual values.
```
