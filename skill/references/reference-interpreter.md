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

## Phase 1.5 — Token Resolution (MANDATORY)

After analyzing the reference, BEFORE mapping or outputting the brief:

1. **Identify every distinct color** used in the reference: backgrounds, text colors, borders, badges, status indicators, chart colors, accents.

2. **Call `search_design_system`** with the connected library key(s) for each color category:
   - Search for: `traffic`, `graph`, `surface`, `outline`, `error`, `success`, `warning`, `on surface`, `primary`, `secondary`, `tertiary`
   - Search for any domain-specific terms visible in the reference (e.g. "critical", "high", "medium", "low")

3. **Build a Color Token Map** — a table mapping every color in the reference to its closest DS variable:

   | Element | DS Token | Variable Key |
   |---------|----------|--------------|
   | [visual element] | [token name] | [key from search] |

4. **If no match exists** for a color, flag it as a gap in the brief.

This phase is NOT optional. The Design Brief MUST include the resolved Color Token Map. Do NOT output a brief with vague color descriptions like "red" or "green" — every color must resolve to a specific variable name and key.

---

## Phase 2 — Map to Design System

Using the Color Token Map from Phase 1.5 and the session's Token Map from Preflight, map ALL observations to specific tokens:

```
"Large dark headline" → Text Style: heading/h1 · Color: sys/On Surface
"Neutral section bg"  → Variable: sys/Surface
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

### Colors (resolved from design system)
| Element | DS Token | Variable Key |
|---------|----------|--------------|
| [from Phase 1.5 Color Token Map] | | |

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
