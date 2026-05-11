# Style Binding + QA

Every visual value must come from the design system. No hardcoded colors, font sizes, or spacing.

---

## Pre-condition Check (before ANY `use_figma` that creates/modifies nodes)

Before writing code, verify:
- [ ] `search_design_system` has been called with the connected library key for needed tokens
- [ ] Library variables have been imported via `importVariableByKeyAsync`
- [ ] NO raw color/spacing values will be used — every value will have a binding
- [ ] The `localhost` collection is NOT being used (it is auto-generated and is NOT the design system)

If pre-conditions are not met, DO NOT proceed with the `use_figma` call.

---

## Binding Hierarchy

For any visual property, follow this order. Stop at the first match.

```
1. Connected Library  →  search_design_system → import → apply
2. Local Style        →  Style Registry → apply by ID
3. Local Variable     →  Variable Registry → apply by ID
4. Gap found          →  Report to user, wait for decision
```

---

## Text

Every text node must use `textStyleId`. Individual font properties (`fontSize`, `fontFamily`, etc.) are forbidden.

```js
const style = await figma.getStyleByIdAsync("<id>");
await figma.loadFontAsync(style.fontName);
node.textStyleId = "<id>";
```

If no local style matches, search libraries via `search_design_system`. If no match anywhere:
```
Text style gap: no style for "[role]". Available: [top 5]. Use closest, or add missing style?
```

---

## Color Fills

Every fill/stroke must bind to a COLOR Variable (preferred, supports theming) or Paint Style.

```js
// Variable binding (preferred)
const variable = await figma.variables.getVariableByIdAsync("<id>");
const fill = { type: "SOLID", color: { r: 0, g: 0, b: 0 } };
node.fills = [figma.variables.setBoundVariableForPaint(fill, "color", variable)];

// Paint Style binding
node.fillStyleId = "<id>";
```

Never use raw `{ r, g, b }` without a binding.

---

## Spacing, Padding, Gap, Radius

Bind to FLOAT Variables. `layoutMode` must be set BEFORE `setBoundVariable`.

```js
node.setBoundVariable("paddingTop", spacingVar);
node.setBoundVariable("paddingBottom", spacingVar);
node.setBoundVariable("paddingLeft", spacingVar);
node.setBoundVariable("paddingRight", spacingVar);
node.setBoundVariable("itemSpacing", spacingVar);
node.setBoundVariable("cornerRadius", radiusVar);
```

Spacing can fall back to raw values temporarily with user confirmation. Color and text cannot.

---

## Forbidden / Required

| Forbidden | Required |
|---|---|
| `node.fontSize = 24` | `node.textStyleId = id` |
| `node.fills = [{ type: "SOLID", color: { r: .2, g: .4, b: 1 } }]` | Variable or Style binding |
| `node.paddingLeft = 16` | `node.setBoundVariable("paddingLeft", var)` |
| `node.cornerRadius = 8` | `node.setBoundVariable("cornerRadius", var)` |
| Creating a Button from scratch | `importComponentByKeyAsync` from library |

---

## QA Verification

After every `use_figma` call that creates or modifies nodes, run this verification on the returned node IDs:

```javascript
const nodeIdsToAudit = [/* paste returned IDs */];
const results = [];

for (const id of nodeIdsToAudit) {
  const node = await figma.getNodeByIdAsync(id);
  if (!node) { results.push({ id, status: "NOT_FOUND" }); continue; }

  const checks = [];

  if (node.type === "TEXT") {
    checks.push({ prop: "textStyleId", bound: !!node.textStyleId });
  }

  if ("fills" in node && Array.isArray(node.fills) && node.fills.length > 0) {
    const bound = !!node.fillStyleId || (node.boundVariables?.fills?.length > 0);
    checks.push({ prop: "fills", bound });
  }

  if ("layoutMode" in node && node.layoutMode !== "NONE") {
    for (const p of ["paddingLeft","paddingRight","paddingTop","paddingBottom","itemSpacing"]) {
      if (p in node) checks.push({ prop: p, bound: !!(node.boundVariables && p in node.boundVariables) });
    }
  }

  if ("cornerRadius" in node && node.cornerRadius > 0) {
    checks.push({ prop: "cornerRadius", bound: !!(node.boundVariables && "cornerRadius" in node.boundVariables) });
  }

  const failed = checks.filter(c => !c.bound);
  results.push({ id, name: node.name, type: node.type, status: failed.length === 0 ? "PASS" : "FAIL", failed: failed.map(c => c.prop) });
}

return { auditResults: results };
```

**If FAIL:** Fix each unbound property using the binding rules above, then re-audit. Do not proceed to the next design step until all pass.

**Report format:**
```
All [N] nodes passed.
// or
FAIL "Card" (FRAME) — paddingTop, cornerRadius unbound. Fixing...
```
