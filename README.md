# edamam-skills

Portable **agent skills** for [Edamam](https://www.edamam.com)'s food & nutrition services, shipped
as a monorepo. Skills follow the [Agent Skills open standard](https://agentskills.io), so the same
top-level [`skills/`](skills/) library works across Claude Code, Gemini CLI, and other compatible
agents. They fetch data through Edamam's hosted **MCP server**.

Packaging is thin: the repo is simultaneously a Claude Code **plugin marketplace** and a Gemini CLI
**extension**, both wrapping the one shared `skills/` folder.

## Skills

| Skill | Folder | What it does |
| --- | --- | --- |
| Barcode food lookup | [`skills/edamam-barcode-lookup/`](skills/edamam-barcode-lookup/SKILL.md) | Type or photograph a product barcode (UPC/EAN) and get calories, macros, and full nutrition from Edamam. |

## Process
Lookups send the barcode digits and your Edamam API key to `https://mcp.edamam.com/mcp/food`; nutrition data comes back from there. 

## Install

### Claude Code — plugin (recommended)

This repo is a Claude Code plugin marketplace. Installing the **`edamam`** plugin gives you every
skill plus the Edamam MCP configuration in one step:

```
/plugin marketplace add edamam-llc/edamam-skills
/plugin install edamam@edamam
```

Restart Claude Code, then run `/plugin` to confirm **edamam** is installed. You still need to supply
your Edamam credentials once — see [Setup](#setup-connect-edamam-one-time).

<details>
<summary>Alternative: install a single skill by hand</summary>

A skill is just a folder containing a `SKILL.md`. Copy the one you want into your skills folder:

```bash
git clone https://github.com/edamam-llc/edamam-skills.git
# personal (all your projects):
mkdir -p ~/.claude/skills && cp -R edamam-skills/skills/edamam-barcode-lookup ~/.claude/skills/
# or project-scoped (committable for your team):
mkdir -p /path/to/project/.claude/skills && cp -R edamam-skills/skills/edamam-barcode-lookup /path/to/project/.claude/skills/
```

The manual copy gives you the skill only — you'll configure the Edamam MCP separately in
[Setup](#setup-connect-edamam-one-time).

</details>

### Gemini CLI — extension

Gemini CLI reads the same `skills/` folder natively (Agent Skills, stable since Gemini CLI v0.23.0),
and this repo ships a `gemini-extension.json`. Install it as an extension:

```
gemini extensions install https://github.com/edamam-llc/edamam-skills
```

The extension declares two credential settings (`EDAMAM_APP_ID`, `EDAMAM_APP_KEY`); Gemini prompts
for them on install and keeps them in its own secret storage.

## Setup: connect Edamam (one-time)

The skills talk to Edamam through an **MCP server** that needs a free Edamam Food Database API key —
an **Application ID** and an **Application Key**. You provide these **once, in your own environment**,
so the keys stay on your machine and never appear in a chat.

### 1. Get your Edamam credentials

1. Open **https://developer.edamam.com/food-database-api** and sign up (free).
2. In the **Applications** dashboard, create an application for the **Food Database API**.
3. Copy the **Application ID** (short) and **Application Key** (long). Treat the key like a password.

### 2. Provide the credentials

**Claude Code (plugin):** you don't set any environment variables. When you install and enable the
**edamam** plugin, Claude Code prompts you for your Edamam Authorization header in a secure dialog
and stores it in your operating system's credential store — you won't re-enter it each session.
Enter it as `Bearer <app_id>:<app_key>` (the word `Bearer`, a space, then your Application ID and
Application Key joined by a colon). Type it into that prompt; never paste it into a chat message.

<details>
<summary>Advanced: register the server manually instead</summary>

If you install a single skill by hand (without the plugin), the credential prompt above doesn't
apply, so register the Edamam MCP server yourself:

```bash
claude mcp add --transport http --scope user edamam-food \
  https://mcp.edamam.com/mcp/food \
  --header "Authorization: Bearer <app_id>:<app_key>"
```

**Keep the colon (`:`) between `<app_id>` and `<app_key>`.** Don't combine this with the plugin —
running both registers two `edamam-food` servers that shadow each other.

</details>

**Gemini CLI:** you already entered the two codes when installing the extension (above). To change
them, reinstall or edit the extension's settings.

> **Enter your codes in the secure prompt (or config), never in a chat.** If you ever paste a key
> into a chat, treat it as compromised and rotate it in the Edamam dashboard.

### 3. Confirm it's connected

Fully restart your agent so it picks up the server.

- **Claude Code:** run `/mcp` and confirm `edamam-food` shows as **connected**.
- **Gemini CLI:** the `edamam-food` server should load on startup.

If it errors, the most common cause is a typo in the codes, a missing colon between `<app_id>` and
`<app_key>`, or (plugin) a missing `Bearer ` prefix. Re-check step 2.

## Use it

Once a skill is installed and the MCP is connected, there are two ways it runs:

- **Automatically** — just give the agent a barcode: *"Look up this barcode: 049000042566"* (a photo
  of a barcode works too). It matches the request to the skill and returns the product, calories, and
  macros.
- **Explicitly (Claude Code)** — invoke it by its namespaced name: `/edamam:edamam-barcode-lookup`.

## Contributing

Skills live under `skills/<name>/SKILL.md` — the single source of truth, loaded directly by every
platform. Add a skill by dropping a new `skills/<name>/` folder in; it ships with the `edamam` plugin
and the Gemini extension automatically. Follow the existing `edamam-<capability>` naming convention.

## License

This skill is licensed under Apache 2.0. It requires access to the Edamam MCP, which is governed separately by the [Edamam Terms of Service](https://www.edamam.com/terms/api/).
