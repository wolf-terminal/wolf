#!/usr/bin/env bash
# Wolf Terminal — WFK Setup Script
#
# Installs Wolf Workflow Kit from the public wolf-workflow-kit repo.
# Safe to re-run. Never overwrites LOCAL.md or settings.local.json.
# Never reads from or copies local ~/.claude/skills/.

set -e

WOLF_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WFK_REPO="https://github.com/ellenwolf0-hub/wolf-workflow-kit"
WFK_DIR="${HOME}/.wolf-workflow-kit"
CLAUDE_DIR="${HOME}/.claude"
FONTS_DIR="${HOME}/Library/Fonts"
WARP_OSS_THEMES_DIR="${HOME}/.warp-oss/themes"
WARP_OSS_SETTINGS="${HOME}/.warp-oss/settings.toml"

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────

print_step() { echo ""; echo "── $1"; }
print_ok()   { echo "   ✓ $1"; }
print_skip() { echo "   · $1 (skipped)"; }
print_warn() { echo "   ⚠ $1"; }

confirm() {
  local prompt="$1"
  read -rp "   ? ${prompt} [y/N] " answer
  [[ "$(echo "$answer" | tr '[:upper:]' '[:lower:]')" == "y" ]]
}

# ─────────────────────────────────────────────
# Step 1 — Check for Claude Code
# ─────────────────────────────────────────────

print_step "Checking for Claude Code"

if ! command -v claude &>/dev/null; then
  print_warn "claude not found in PATH."
  echo ""
  echo "   Install Claude Code first:"
  echo "   https://claude.ai/download"
  echo ""
  echo "   After installing, re-run this script."
  exit 1
fi

print_ok "claude found at $(command -v claude)"

# ─────────────────────────────────────────────
# Step 2 — Clone or update wolf-workflow-kit
# ─────────────────────────────────────────────

print_step "Fetching wolf-workflow-kit"

if [ -d "${WFK_DIR}/.git" ]; then
  echo "   Updating existing clone at ${WFK_DIR}"
  git -C "${WFK_DIR}" pull --quiet origin main
  print_ok "wolf-workflow-kit up to date"
else
  echo "   Cloning from ${WFK_REPO}"
  git clone --quiet "${WFK_REPO}" "${WFK_DIR}"
  print_ok "wolf-workflow-kit cloned to ${WFK_DIR}"
fi

# ─────────────────────────────────────────────
# Step 3 — Install WFK skills
# ─────────────────────────────────────────────

print_step "Installing WFK skills"

SKILLS_SRC="${WFK_DIR}/skills"
SKILLS_DST="${CLAUDE_DIR}/skills"

if [ ! -d "${SKILLS_SRC}" ]; then
  print_warn "No skills/ directory found in wolf-workflow-kit. Skipping."
else
  mkdir -p "${SKILLS_DST}"
  installed=0
  skipped=0

  for skill_dir in "${SKILLS_SRC}"/*/; do
    skill_name="$(basename "${skill_dir}")"
    dest="${SKILLS_DST}/${skill_name}"

    if [ -d "${dest}" ]; then
      # Skill already exists — only update if contents differ
      if diff -rq --exclude="LOCAL.md" "${skill_dir}" "${dest}" &>/dev/null; then
        ((skipped++)) || true
      else
        if confirm "Skill '${skill_name}' differs from installed version. Update?"; then
          # Never overwrite LOCAL.md
          rsync -a --exclude="LOCAL.md" "${skill_dir}/" "${dest}/"
          ((installed++)) || true
        else
          ((skipped++)) || true
        fi
      fi
    else
      cp -r "${skill_dir}" "${dest}"
      ((installed++)) || true
    fi
  done

  print_ok "${installed} skill(s) installed, ${skipped} unchanged"
fi

# ─────────────────────────────────────────────
# Step 4 — Merge settings.json (never replace wholesale)
# ─────────────────────────────────────────────

print_step "Merging Claude Code settings"

SETTINGS_SRC="${WFK_DIR}/defaults/settings.json"
SETTINGS_DST="${CLAUDE_DIR}/settings.json"

if [ ! -f "${SETTINGS_SRC}" ]; then
  print_skip "No defaults/settings.json in wolf-workflow-kit"
else
  if command -v python3 &>/dev/null; then
    python3 - <<PYEOF
import json, os, sys

src_path = "${SETTINGS_SRC}"
dst_path = "${SETTINGS_DST}"

with open(src_path) as f:
    defaults = json.load(f)

existing = {}
if os.path.exists(dst_path):
    with open(dst_path) as f:
        try:
            existing = json.load(f)
        except json.JSONDecodeError:
            print("   ⚠ Existing settings.json is invalid JSON — skipping merge")
            sys.exit(0)

conflicts = []
for key, val in defaults.items():
    if key in existing and existing[key] != val:
        conflicts.append((key, existing[key], val))

if conflicts:
    print("   Conflicts found in settings.json:")
    for key, old, new in conflicts:
        print(f"     {key}: current={old!r}  →  wolf default={new!r}")
        answer = input(f"   ? Keep wolf default for '{key}'? [y/N] ").strip().lower()
        if answer == "y":
            existing[key] = new

for key, val in defaults.items():
    if key not in existing:
        existing[key] = val

os.makedirs(os.path.dirname(dst_path) if os.path.dirname(dst_path) else ".", exist_ok=True)
with open(dst_path, "w") as f:
    json.dump(existing, f, indent=2)

print("   ✓ settings.json merged")
PYEOF
  else
    print_warn "python3 not found — skipping settings.json merge"
  fi
fi

# Never touch settings.local.json — enforced here as a hard guard
if [ -f "${CLAUDE_DIR}/settings.local.json" ]; then
  print_ok "settings.local.json left untouched (protected)"
fi

# ─────────────────────────────────────────────
# Step 5 — Install MCP server stubs
# ─────────────────────────────────────────────

print_step "Installing MCP server stubs"

MCP_DIR="${CLAUDE_DIR}/mcp-servers"
mkdir -p "${MCP_DIR}"

# Coda stub — no credentials, pointer only
CODA_STUB="${MCP_DIR}/coda/README.md"
if [ ! -f "${CODA_STUB}" ]; then
  mkdir -p "${MCP_DIR}/coda"
  cat > "${CODA_STUB}" <<'README'
# Coda MCP Server

Install: https://coda.io/developers/mcp
Follow the Coda MCP installation guide to add your API key.
README
  print_ok "Coda MCP stub created"
else
  print_skip "Coda MCP stub already present"
fi

# Slack stub — no credentials, pointer only
SLACK_STUB="${MCP_DIR}/slack/README.md"
if [ ! -f "${SLACK_STUB}" ]; then
  mkdir -p "${MCP_DIR}/slack"
  cat > "${SLACK_STUB}" <<'README'
# Slack MCP Server

Install: npm install -g @modelcontextprotocol/server-slack
Configure with your Slack Bot token and Team ID in ~/.claude/settings.json.
README
  print_ok "Slack MCP stub created"
else
  print_skip "Slack MCP stub already present"
fi

# Note: Granola is auto-detected by Claude Code — no stub needed.

# ─────────────────────────────────────────────
# Step 6 — Install SuperSansMono fonts
# ─────────────────────────────────────────────

print_step "Installing SuperSansMono fonts"

FONTS_SRC="${WOLF_REPO_DIR}/fonts"
installed_fonts=0
skipped_fonts=0

if [ ! -d "${FONTS_SRC}" ]; then
  print_warn "fonts/ directory not found in Wolf repo. Skipping."
else
  mkdir -p "${FONTS_DIR}"
  for font in "${FONTS_SRC}"/SuperSansMono-*.otf; do
    font_name="$(basename "${font}")"
    if [ -f "${FONTS_DIR}/${font_name}" ]; then
      ((skipped_fonts++)) || true
    else
      cp "${font}" "${FONTS_DIR}/${font_name}"
      ((installed_fonts++)) || true
    fi
  done
  print_ok "${installed_fonts} font(s) installed, ${skipped_fonts} already present"
fi

# ─────────────────────────────────────────────
# Step 7 — Install Wolf theme to ~/.warp-oss/themes/
# ─────────────────────────────────────────────

print_step "Installing Wolf theme"

THEME_SRC="${WOLF_REPO_DIR}/themes/wolf.yaml"
mkdir -p "${WARP_OSS_THEMES_DIR}"

if [ ! -f "${THEME_SRC}" ]; then
  print_warn "themes/wolf.yaml not found in Wolf repo"
else
  if [ -f "${WARP_OSS_THEMES_DIR}/wolf.yaml" ]; then
    if diff -q "${THEME_SRC}" "${WARP_OSS_THEMES_DIR}/wolf.yaml" &>/dev/null; then
      print_skip "wolf.yaml already up to date"
    else
      if confirm "wolf.yaml differs from installed version. Update?"; then
        cp "${THEME_SRC}" "${WARP_OSS_THEMES_DIR}/wolf.yaml"
        print_ok "wolf.yaml updated"
      else
        print_skip "wolf.yaml update skipped"
      fi
    fi
  else
    cp "${THEME_SRC}" "${WARP_OSS_THEMES_DIR}/wolf.yaml"
    print_ok "wolf.yaml installed to ${WARP_OSS_THEMES_DIR}/"
  fi
fi

# ─────────────────────────────────────────────
# Step 8 — Install settings.toml to ~/.warp-oss/
# ─────────────────────────────────────────────

print_step "Installing Wolf terminal settings"

SETTINGS_TOML_SRC="${WOLF_REPO_DIR}/defaults/settings.toml"
WOLF_THEME_PATH="${HOME}/.warp-oss/themes/wolf.yaml"
mkdir -p "$(dirname "${WARP_OSS_SETTINGS}")"

if [ ! -f "${SETTINGS_TOML_SRC}" ]; then
  print_warn "defaults/settings.toml not found in Wolf repo"
else
  # Substitute the real home-directory path for the theme file — Warp's theme
  # map keys use full absolute paths, so the settings.toml must match exactly.
  GENERATED_SETTINGS=$(sed "s|WOLF_THEME_PATH_PLACEHOLDER|${WOLF_THEME_PATH}|g" "${SETTINGS_TOML_SRC}")

  if [ -f "${WARP_OSS_SETTINGS}" ]; then
    EXISTING=$(cat "${WARP_OSS_SETTINGS}")
    if [ "${GENERATED_SETTINGS}" = "${EXISTING}" ]; then
      print_skip "settings.toml already up to date"
    else
      if confirm "~/.warp-oss/settings.toml exists and differs. Overwrite with Wolf defaults?"; then
        echo "${GENERATED_SETTINGS}" > "${WARP_OSS_SETTINGS}"
        print_ok "settings.toml installed"
      else
        print_skip "settings.toml update skipped"
      fi
    fi
  else
    echo "${GENERATED_SETTINGS}" > "${WARP_OSS_SETTINGS}"
    print_ok "settings.toml installed to ${WARP_OSS_SETTINGS}"
  fi
fi

# ─────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────

echo ""
echo "────────────────────────────────────────"
echo "  Wolf Terminal setup complete."
echo ""
echo "  Next: build and launch Wolf Terminal."
echo "  See README.md for build instructions."
echo "────────────────────────────────────────"
echo ""
