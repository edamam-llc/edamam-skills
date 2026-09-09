# edamam-skills

Claude Code / Cursor **skills** for Edamam. Each skill lives under `skills/` and is installed by
copying it into your Claude Code skills folder (see [Install the skill](#install-the-skill)).

## Skills

| Skill | Folder | What it does |
| --- | --- | --- |
| Barcode food lookup | [`skills/edamam-barcode-lookup/`](skills/edamam-barcode-lookup/SKILL.md) | Type or photograph a product barcode (UPC/EAN) and get calories, macros, and full nutrition from Edamam. |

## Install the skill

First get the repo:

```bash
git clone https://github.com/edamam-llc/edamam-skills.git
cd edamam-skills
```

A **skill** is just a folder containing a `SKILL.md`. Claude Code loads skills from a `skills/`
directory — you install this one by copying the `edamam-barcode-lookup` folder into the right place.
Pick the scope you want:

### Option A — Personal skill (available in all your projects)

Copy it into your user-level skills folder:

```bash
mkdir -p ~/.claude/skills
cp -R skills/edamam-barcode-lookup ~/.claude/skills/edamam-barcode-lookup
```

Windows: copy the `skills\edamam-barcode-lookup` folder into `%USERPROFILE%\.claude\skills\`.

### Option B — Project skill (available only in one project, and committable for your team)

From the project where you want the skill, copy it into that project's `.claude/skills/`:

```bash
mkdir -p /path/to/your-project/.claude/skills
cp -R skills/edamam-barcode-lookup /path/to/your-project/.claude/skills/edamam-barcode-lookup
```

Commit `.claude/skills/edamam-barcode-lookup/` to share it with everyone on that repo.

### Confirm it loaded

Restart / reload Claude Code, then run `/skills`. You should see **edamam-barcode-lookup** in the
list. (You still need the Edamam MCP connected below for it to actually fetch data.)

## Setup: connect Edamam (one-time)

The skill talks to Edamam through an **MCP server** that needs a free Edamam Food Database API key —
an **Application ID** and an **Application Key**. You register the server **once, in your own
terminal**, so the keys stay on your machine and never appear in a chat.

### 1. Get your Edamam credentials

1. Open **https://developer.edamam.com/food-database-api** and sign up (free).
2. In the **Applications** dashboard, create an application for the **Food Database API**.
3. Copy the **Application ID** (short) and **Application Key** (long). Treat the key like a password.

### 2. Connect the Edamam MCP to Claude

Pick the instructions below that match how you use Claude. In every case, replace `<app_id>` and
`<app_key>` with the two codes from Step 1, and **keep the colon (`:`) between them**.

- Server address (always): `https://mcp.edamam.com/mcp/food`
- Login header (always): `Authorization: Bearer <app_id>:<app_key>`

These configs live on **your own machine**, not in this repo — your keys are never committed and
never typed into a chat.

**Cursor** — Settings → Cursor Settings → MCP → **Add new global MCP server** (this opens `mcp.json`), and paste:

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

**Claude Code (the terminal app)** — paste into your terminal, fill in your two codes, press Enter:

```bash
claude mcp add --transport http --scope user edamam-food \
  https://mcp.edamam.com/mcp/food \
  --header "Authorization: Bearer <app_id>:<app_key>"
```

(`--scope user` makes it available in all your projects and saves the keys to your private
`~/.claude.json`.)

**VS Code** — open your MCP config (`.vscode/mcp.json`, or the MCP settings) and paste:

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

> **Paste your codes into these config files, not into a chat with Claude.** If you ever paste a key
> into a chat, treat it as compromised and rotate it in the Edamam dashboard.

### 3. Confirm it's connected

Fully restart / reload your Claude app so it picks up the new server.

- **Cursor / VS Code:** reopen the app; `edamam-food` should appear with a green / enabled status.
- **Claude Code:** run `/mcp` and confirm `edamam-food` shows as **connected**.

If it shows an error, the most common cause is a typo in the codes or a missing colon between
`<app_id>` and `<app_key>`. Re-check Step 2 and try again. Once connected, you're done with setup for
good.

<details>
<summary>Alternative: per-project config with environment variables (for teams sharing this repo)</summary>

Instead of pasting keys into each app, this repo ships a secret-free [`.mcp.json`](.mcp.json) that
reads two environment variables. Export them in your shell (add to `~/.zshrc` / `~/.bashrc` to
persist), then launch your editor from that same terminal:

```bash
export EDAMAM_APP_ID="your_app_id"
export EDAMAM_APP_KEY="your_app_key"
```

`.mcp.json` references `${EDAMAM_APP_ID}` / `${EDAMAM_APP_KEY}`, so the server connects automatically
when those variables are set. (They're read from the shell environment, not from a `.env` file.)

</details>

## Use it

Once the skill is installed and the MCP is connected, there are two ways it runs:

- **Automatically** — just give Claude a barcode: *"Look up this barcode: 049000042566"* (a photo of
  a barcode works too). Claude matches the request to the skill's description and runs
  **edamam-barcode-lookup**, returning the product, calories, and macros.
- **Explicitly** — type `/edamam-barcode-lookup` to invoke it directly, no guessing.

If Claude answers a barcode question *without* the skill (e.g. by calling the MCP tool directly),
it usually means the skill isn't installed yet — run `/skills` to check, and revisit
[Install the skill](#install-the-skill).

## Maintainers

The skill lives at `skills/edamam-barcode-lookup/SKILL.md` — a single source of truth that Claude
Code loads directly. Edit it there; there is no mirror copy to keep in sync.
