# Reference Interpreter

Analyze a reference (screenshot, URL, or description) and produce a **Design Brief** that maps visual observations to design system tokens. Output the Brief, then **stop and wait for user confirmation** before building anything.

---

## Hard Gate

If the user shares a URL, image, or screenshot AND says "build", "start", "create", or "make" in the same message, this skill MUST run BEFORE any construction begins. The intent to build does NOT override the requirement for a confirmed Design Brief. Do NOT call `use_figma` to create nodes until the user explicitly types "confirmed" or equivalent approval.

---

## Phase 1 — Analyze

Examine the reference across these dimensions:

1. **Layout** — structure, columns, section heights, grid width, alignment
2. **Typography** — heading/body hierarchy, weight contrast, tracking
3. **Color** — dark/light sections, accent usage, neutral dominance
4. **Spacing** — generous vs compact, section padding, internal gap
5. **Visual Anchor** — what draws the eye: large type, hero image, illustration
6. **Components** — what UI elements are visible: cards, buttons, forms, nav

---

## Phase 2 — Map to Design System

For each observation, identify the specific Token or Style from the session's Token Map:

```
"Large dark headline" → Text Style: heading/h1 · Color: text/primary
"Neutral section bg"  → Variable: background/surface-2
"Tight card spacing"  → Gap: gap/xs · Padding: padding/sm
```

If no token exists, flag it:
```
Gap: [observation] — no matching token. Options: (a) nearest match: [name], (b) add token first.
```

---

## Phase 3 — Output the Design Brief

```
## Design Brief

**Reference**: [source]
**Output**: [Figma file URL with target page/node]
**Section**: [what this covers]
**Aesthetic**: [3-5 keywords]

### Layout
[structure, height, alignment]

### Typography
- Heading: [Style name] — [why]
- Body: [Style name]

### Colors
- Background: [Variable] — [context]
- Text: [Variable]
- Accent: [Variable] — [used for]

### Spacing
- Section padding: [Variable]
- Internal gap: [Variable]

### Components needed
- [Name]: [from library? source]

### Gaps
- [Gap description] — awaiting decision
- (none) [if all mapped]
```

---

## Phase 4 — Wait

Output exactly:

```
Brief complete. Type "confirmed" to begin building, or tell me what to adjust.
```

Do NOT call `use_figma` or place any nodes until user confirms.
