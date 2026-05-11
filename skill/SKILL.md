---
name: prototype-with-ds
description: "Design and prototype UI in Figma using your connected design system. Invoke with /prototype-with-ds. Prompts for a Figma file URL, accepts ideas and references (screenshots, URLs, descriptions), generates a Design Brief, then builds in Figma with full design-system token binding and QA verification."
---

# Prototype with Design System

Build production-quality Figma designs using your connected design system. Every color, text style, and spacing value is bound to design tokens.

**Prerequisite:** The Figma MCP plugin must be configured in Claude Code and your target Figma file must have a design system library connected.

---

## Step 1 — Session Setup

On each invocation, determine the Figma file to use:

**If no Figma URL exists in this conversation:**
Display:
```
Paste your Figma file URL (the file where designs should be created).
It must have a design system library connected.
```
Wait for URL. Validate format: must contain `figma.com/design/` or `figma.com/file/`.

**If a Figma URL was already used this session:**
Display:
```
Use [previous URL / file name] again? Or paste a new Figma file URL.
```

**Then always ask:**
```
Describe what you'd like to build, and optionally share screenshots or reference URLs.
```

---

## Step 2 — Preflight

Run these checks before any design work. Skip if preflight already completed this session for the same file.

**A. Connection (parallel):**
1. Call `mcp__plugin_figma_figma__whoami` — must return user email. Fail → stop.
2. Parse `fileKey` and optional `nodeId` from URL.

**B. File + Libraries (parallel):**
1. Call `get_metadata` with fileKey + nodeId — get file name and pages.
2. Call `get_libraries` with fileKey — store subscribed libraries as **Library Registry** (name, libraryKey).

**C. Token Discovery (single `use_figma` call):**

Load the `figma:figma-use` skill, then run:

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

const byScope = {};
for (const v of variables) {
  for (const scope of v.scopes) {
    if (!byScope[scope]) byScope[scope] = [];
    byScope[scope].push(v.name);
  }
}

return {
  textStyles: textStyles.map(s => s.name),
  paintStyles: paintStyles.map(s => s.name),
  collections: collections.map(c => ({ name: c.name, modes: c.modes.map(m => m.name), varCount: c.variableIds.length })),
  variableCount: variables.length,
  byScope
};
```

**D. Derive Token Map:**

| Role | Scope | Example names |
|---|---|---|
| Background fill | `FRAME_FILL`, `SHAPE_FILL` | background/surface, color/neutral-100 |
| Text color | `TEXT_FILL` | text/primary, color/neutral-900 |
| Border / stroke | `STROKE_COLOR` | border/default, color/neutral-300 |
| Gap | `GAP` | gap/sm, spacing/xxs |
| Padding | `PADDING` | padding/md, spacing/section-xl |
| Border radius | `CORNER_RADIUS` | radius/sm, radius/full |

**E. Status Report:**

```
--- Preflight Complete ---
MCP: [name] ([email])
File: [file name] - [N] pages
Libraries: [N] connected: [names]
Styles: [N] text + [N] paint
Variables: [N] across [N] collections
Token Map: [summary of roles]
---
```

---

## Step 3 — Reference Interpretation

**Trigger:** If the user provided a screenshot, URL, or visual description.

Load and follow `references/reference-interpreter.md` to produce a structured Design Brief.

**Color resolution is mandatory:** Before outputting the brief, call `search_design_system` with the connected library keys to resolve ALL colors in the reference to specific DS variable names and keys. The brief must include a Color Token Map table. Never output a brief with unresolved color descriptions like "red" or "green".

**Hard gate:** Output the Design Brief, then display:
```
Brief complete. Type "confirmed" to begin building, or tell me what to adjust.
```

Do NOT call `use_figma` to create/modify nodes until the user explicitly confirms.

**Skip condition:** If the user gave only a text description with no visual reference AND says to just build it, proceed directly to Step 4.

---

## Step 4 — Build

Load `references/component-rules.md` and `references/style-binding.md` before building.

**Mandatory before every `use_figma` call:**
1. Load the `figma:figma-use` skill
2. Call `search_design_system` with the connected library key for needed tokens
3. Import variables via `importVariableByKeyAsync`
4. Confirm NO raw values will be used

**Build rules:**
- One section per `use_figma` call (incremental)
- Return ALL created/mutated node IDs
- Every fill, text style, spacing, radius must bind to a variable or style
- Library-first: import existing components, never rebuild primitives
- Name every node semantically

---

## Step 5 — QA

After each `use_figma` call, run the QA verification from `references/style-binding.md`.

- If all nodes PASS → proceed to next section or complete
- If any node FAILs → fix unbound properties, re-audit, block progress until all pass

---

## Step 6 — Session Continuity

After completing a build:
```
Ready for the next element. Describe what to build next or share another reference.
The same Figma file will be used unless you provide a new URL.
```

No need to re-run preflight within the same session (token map is already loaded).

---

## Rules (always enforced)

1. Every visual value must bind to a Style or Variable. Never hardcode colors, font sizes, or spacing.
2. Always `search_design_system` with connected library keys before building any component from scratch.
3. Never start building before the Design Brief is confirmed (when a reference is provided).
4. Never use the `localhost` collection — it is auto-generated and NOT the design system.
5. Every `use_figma` call must return all created/mutated node IDs.
6. QA audit must pass before proceeding to the next build step.
