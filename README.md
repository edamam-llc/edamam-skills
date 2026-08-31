# edamam-skills

Claude Code / Cursor **skills** for Edamam. Each skill lives in its own top-level folder and is
mirrored under `.claude/skills/` so Claude Code picks it up automatically.

## Skills

| Skill | Folder | What it does |
| --- | --- | --- |
| Barcode food logging | [`barcode-logging/`](barcode-logging/SKILL.md) | Type or photograph a product barcode (UPC/EAN) and get calories, macros, and full nutrition from Edamam. |

## Get it from GitHub

```bash
git clone https://github.com/edamam-llc/edamam-skills.git
cd edamam-skills
```

Then make the skill available to Claude Code — pick one:

- **Use it inside this repo** — open the folder in Cursor (`cursor .`). The skill is already in
  `.claude/skills/`, so Claude Code loads it automatically. Nothing to install.
- **Use it in every project** — copy it into your personal skills folder:

  ```bash
  mkdir -p ~/.claude/skills
  cp -R barcode-logging ~/.claude/skills/barcode-logging   # Windows: copy the folder there manually
  ```

Restart Cursor / Claude Code afterward.

## Before first use: connect Edamam

Each skill talks to Edamam through its MCP server, which needs a free Edamam API key. **Full
step-by-step setup lives in the skill itself → [`barcode-logging/SKILL.md`](barcode-logging/SKILL.md)
(Part 1).** 

## Use it

Give Claude a barcode: *"Log this barcode: 049000042566"*. Claude runs the **barcode-logging** skill
and returns the product, calories, and macros. A photo of a barcode works too.

## Maintainers

Top-level `barcode-logging/SKILL.md` is the source of truth; `.claude/skills/barcode-logging/SKILL.md`
is the copy Claude Code loads. Keep them in sync after edits:

```bash
cp barcode-logging/SKILL.md .claude/skills/barcode-logging/SKILL.md
```
