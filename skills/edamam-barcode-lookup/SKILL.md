---
name: barcode-logging
description: Log food and get nutrition facts from a product barcode (UPC/EAN) using the Edamam Food MCP. Use when the user provides a barcode number (or a photo/scan of one) and wants calories, macros, or full nutrition for that packaged product. Barcode input only — for typed food descriptions or plate photos, this skill is not the right fit.
---

# Barcode Food Logging (Edamam Food MCP)

Turn a product **barcode** (the UPC/EAN number under the striped label on packaged food) into
nutrition facts — calories, macros, and a full nutrient breakdown — using Edamam's Food MCP server.

This skill covers **barcodes only**. If the user hands you a barcode number, resolve it. If they
describe a food in words ("2 eggs") or send a photo of a plate, tell them this skill is for
barcodes and stop.

---

## Part 1 — One-time setup (for non-technical users)

The skill talks to Edamam through an **MCP server**. You only have to connect it **once**; after
that it stays connected. Follow these steps in order. If the MCP is already connected (you can call
a tool named `get_food_nutrition`), skip straight to Part 2.

### Step 1 — Get your free Edamam credentials

You need two secret codes from Edamam: an **Application ID** and an **Application Key**.

1. Open **https://developer.edamam.com/food-database-api** in your web browser.
2. Click **Sign Up** (or **Log In** if you already have an account) and create a free account.
3. After logging in, go to the **Applications** / **Dashboard** area and create a new application
   for the **Food Database API**.
4. On that application's page you will see two values:
   - **Application ID** — a short code (looks like `1a2b3c4d`)
   - **Application Key** — a longer code (a long string of letters and numbers)
5. Keep this page open, or copy both values into a safe note. Treat the Application Key like a
   password — don't share it or post it publicly.

### Step 2 — Connect the Edamam MCP to Claude

Pick from the instructions below that match how you use Claude. In every case, replace `<app_id>` and
`<app_key>` with the two codes from Step 1, and keep the colon (`:`) between them.

> The server address is always: `https://mcp.edamam.com/mcp/food`
> The login header is always: `Authorization: Bearer <app_id>:<app_key>`

**Cursor (recommended for the PM)** — open Settings → **Cursor Settings** → **MCP** → *Add new
global MCP server* (this opens `mcp.json`) and paste:

```json
{
  "mcpServers": {
    "edamam-food": {
      "url": "https://mcp.edamam.com/mcp/food",
      "headers": {
        "Authorization": "Bearer <app_id>:<app_key>"
      }
    }
  }
}
```

**Claude Code (the terminal app)** — copy this into your terminal, fill in your two codes, press Enter:

```bash
claude mcp add --transport http edamam-food \
  https://mcp.edamam.com/mcp/food \
  --header "Authorization: Bearer <app_id>:<app_key>"
```

**VS Code** — open your MCP config (`.vscode/mcp.json` or the MCP settings) and paste:

```json
{
  "servers": {
    "edamam-food": {
      "type": "http",
      "url": "https://mcp.edamam.com/mcp/food",
      "headers": {
        "Authorization": "Bearer <app_id>:<app_key>"
      }
    }
  }
}
```

### Step 3 — Confirm it's connected
1. Fully **restart / reload** your Claude app so it picks up the new server.
   - Cursor / VS Code: reopen the app; the server should appear with a green/enabled status.
   - Claude Code: run `/mcp` and confirm `edamam-food` shows as **connected**.
2. If it shows an error, the most common cause is a typo in the codes or a missing colon between
   `<app_id>` and `<app_key>`. Re-check Step 2 and try again.

Once connected, you're done with setup forever. Move on to Part 2.

---

## Part 2 — Main procedure: barcode → nutrition

Do this every time the user gives you a barcode.

### 1. Get the barcode number

- Accept the raw digits the user types (typically a **12-digit UPC** like `049000042566` or a
  **13-digit EAN**).
- If the user sends a **photo/scan** of the barcode, read the digits printed **beneath** the bars
  and use those. If you cannot read all the digits confidently, ask the user to type them.
- Strip spaces and dashes so you have a clean run of digits. Keep any leading zeros.
- If they gave you a food *description* instead of a barcode, stop and say this skill handles
  barcodes only.

### 2. Verify the MCP is available

Confirm the `get_food_nutrition` tool exists (Edamam Food MCP is connected). If it isn't, point the
user to **Part 1** setup instead of guessing nutrition values.

### 3. Look up the barcode

Call the **`get_food_nutrition`** tool. Pass the barcode as a string inside the `queries` list:

```json
{
  "name": "get_food_nutrition",
  "arguments": {
    "queries": ["049000042566"]
  }
}
```

- You can log several products at once by putting multiple barcodes in the list:
  `"queries": ["049000042566", "038000000010"]`.
- **Only put barcodes here for this skill** — do not mix in text food descriptions.

### 4. Handle the result

- **Found:** continue to Step 5.
- **Not found / empty result:** tell the user that barcode isn't in Edamam's database. Do **not**
  invent numbers. Offer to try again if they re-check the digits.
- **Auth / connection error:** the credentials or connection likely need fixing — send them back to
  **Part 1, Step 2–3**.

### 5. Present the nutrition clearly

From the tool's response, report at minimum:

- **Product name** (and brand, if returned) with the barcode you looked up.
- **Serving basis** — state whether the numbers are per 100 g or per the returned serving, so the
  user knows what the values refer to. Don't silently assume.
- **Calories** (kcal).
- **Macros:** protein, total fat, and total carbohydrates (in grams). Add saturated fat, sugars,
  fiber, and sodium when present.
- Any notable **diet labels**, **health labels**, or **cautions** (e.g. allergens) the response
  includes.

Format it as a short, readable summary or a small table. Example shape:

```
🥫 Coca-Cola Classic (barcode 049000042566) — per 100 g
Calories: 42 kcal
Carbs: 10.6 g  (Sugars: 10.6 g)
Protein: 0 g   Fat: 0 g   Sodium: 4 mg
Health labels: Vegan, Vegetarian
```

---

## Guardrails

- **Barcodes only.** Redirect typed food descriptions and plate photos elsewhere.
- **Never fabricate nutrition data.** If Edamam returns nothing, say so plainly.
- **Always state the serving basis** (per 100 g vs. per serving) so numbers aren't misread.
- **Keep credentials private.** Never echo the user's Application Key back in plain text or commit
  it to a repo!
- Nutrition data is for general information, not medical or dietary-diagnosis advice.
