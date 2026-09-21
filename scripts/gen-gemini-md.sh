#!/usr/bin/env bash
# Regenerate GEMINI.md from the skill's SKILL.md.
#
# Gemini CLI extensions load a plain context file (GEMINI.md) — no YAML
# frontmatter, no description-based triggering like Claude Code skills. So the
# Gemini context is just SKILL.md with the frontmatter block stripped off.
#
# GEMINI.md is a GENERATED artifact. Do not edit it by hand — edit SKILL.md and
# let the pre-commit hook (or `bash scripts/gen-gemini-md.sh`) regenerate it.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="$repo_root/skills/edamam-barcode-lookup/SKILL.md"
dst="$repo_root/GEMINI.md"

if [[ ! -f "$src" ]]; then
  echo "gen-gemini-md: source not found: $src" >&2
  exit 1
fi

{
  echo "<!-- Generated from skills/edamam-barcode-lookup/SKILL.md — do not edit directly. -->"
  echo ""
  # Drop a leading YAML frontmatter block (--- ... ---), then emit the rest
  # verbatim. If there's no frontmatter, emit the whole file.
  awk '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---"  { infm=0; skipblank=1; next }
    infm              { next }
    skipblank && $0=="" { skipblank=0; next }
    { skipblank=0; print }
  ' "$src"
} > "$dst"

echo "gen-gemini-md: wrote $dst"
