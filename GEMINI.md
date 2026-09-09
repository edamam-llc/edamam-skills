# Barcode Food Lookup (Edamam Food MCP)

Turn a product **barcode** (the UPC/EAN number under the striped label on packaged food) into
nutrition facts — calories, macros, and a full nutrient breakdown — using Edamam's Food MCP server.

This guidance covers **barcodes only**. If the user hands you a barcode number, resolve it. If they
describe a food in words ("2 eggs") or send a photo of a plate, tell them this is for barcodes and
stop.

## Credentials — never handle them in chat

The Edamam Food MCP authenticates with secret credentials that are configured **once, outside the
conversation** (see the repository README). At runtime you must **never** ask for, accept, echo, or
store them:

- Don't prompt the user to paste credentials, and don't try to write or edit the MCP config yourself.
- If the user volunteers a key, don't repeat it — tell them to treat it as compromised, rotate it,
  and follow the README setup instead.

Your only job is to use the already-connected MCP. If it isn't connected, point the user at the
README setup — you do not collect the secrets yourself.

## Procedure: barcode → nutrition

### 1. Get the barcode number

- Accept the raw digits the user types (typically a **12-digit UPC** like `049000042566` or a
  **13-digit EAN**).
- If the user sends a **photo/scan** of the barcode, read the digits printed **beneath** the bars
  and use those. If you cannot read all the digits confidently, ask the user to type them.
- Strip spaces and dashes so you have a clean run of digits. Keep any leading zeros.
- If they gave you a food *description* instead of a barcode, stop and say this handles barcodes only.

### 2. Look up the barcode via the Edamam Food MCP

Use the connected Edamam Food MCP tool that returns nutrition for a food query, passing the barcode
digits as the query. You can look up several barcodes in one call. Only send barcodes here — no text
food descriptions.

If no such Edamam Food tool is available in the session, the MCP isn't connected. Don't ask for
credentials and don't try to configure it — tell the user to complete the one-time setup in the
repository README, then stop. (Fallback reference: the Edamam Food Database API,
https://developer.edamam.com/food-database-api.)

### 3. Handle the result

- **Found:** present the nutrition (Step 4).
- **Not found / empty:** tell the user that barcode isn't in Edamam's database. Do **not** invent
  numbers. Offer to try again if they re-check the digits.
- **Auth / connection error:** the credentials or connection need fixing — send the user to the
  README setup. Never ask for the keys in chat.

### 4. Present the nutrition clearly

From the tool's response, surface at minimum:

- **Product name** (and brand, if returned) alongside the barcode you looked up.
- **Serving basis** — state whether the numbers are per 100 g or per the returned serving, so the
  user knows what the values refer to. Don't silently assume.
- **Calories** and **macros** (protein, total fat, total carbohydrates). Add saturated fat, sugars,
  fiber, and sodium when the response includes them.
- Any notable **diet/health labels** or **allergen cautions** in the response.

Format it as a short, readable summary or a small table.

## Guardrails

- **Never handle credentials in chat.** Setup (including credentials) lives in the repository README.
- **Barcodes only.** Redirect typed food descriptions and plate photos elsewhere.
- **Never fabricate nutrition data.** If Edamam returns nothing, say so plainly.
- **Always state the serving basis** (per 100 g vs. per serving) so numbers aren't misread.
- Nutrition data is for general information, not medical or dietary-diagnosis advice.
