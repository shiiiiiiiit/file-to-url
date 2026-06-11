#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/shiiiiiiiit/file-to-url"
SKILL_NAME="file-to-url"

API_URL=""
API_KEY=""
TARGET="claude-code"

for arg in "$@"; do
    case "$arg" in
        --api-url=*) API_URL="${arg#--api-url=}" ;;
        --api-key=*) API_KEY="${arg#--api-key=}" ;;
        --target=*)  TARGET="${arg#--target=}" ;;
        --help|-h)
            echo "Usage: bash install.sh --api-url=<url> --api-key=<key> [--target=claude-code|codex]"
            echo ""
            echo "Options:"
            echo "  --api-url=URL    Upload API endpoint URL"
            echo "  --api-key=KEY    API Bearer token"
            echo "  --target=TARGET  Install target: claude-code (default) or codex"
            echo ""
            echo "Environment variables (fallback):"
            echo "  FILE_TO_URL_API_URL"
            echo "  FILE_TO_URL_API_KEY"
            exit 0
            ;;
    esac
done

# Fallback to environment variables
API_URL="${API_URL:-${FILE_TO_URL_API_URL:-}}"
API_KEY="${API_KEY:-${FILE_TO_URL_API_KEY:-}}"

if [ -z "$API_URL" ] || [ -z "$API_KEY" ]; then
    echo "Error: --api-url and --api-key are required."
    echo "Pass them as arguments or set FILE_TO_URL_API_URL / FILE_TO_URL_API_KEY environment variables."
    exit 1
fi

case "$TARGET" in
    claude-code)
        echo "Installing skill for Claude Code..."
        npx skills add "$REPO_URL" --skill "$SKILL_NAME" -y

        SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
        if [ ! -d "$SKILL_DIR" ]; then
            echo "Error: Skill directory not found at $SKILL_DIR"
            exit 1
        fi

        echo "Configuring API credentials..."
        mkdir -p "$SKILL_DIR"
        cat > "$SKILL_DIR/config.json" <<EOF
{
  "api_url": "$API_URL",
  "api_key": "$API_KEY"
}
EOF
        echo "Configuration saved to $SKILL_DIR/config.json"

        echo "Cleaning up non-skill files..."
        rm -f "$SKILL_DIR/.gitignore" "$SKILL_DIR/README.md" "$SKILL_DIR/README.zh-CN.md" "$SKILL_DIR/install.sh" "$SKILL_DIR/install.ps1" "$SKILL_DIR/config.template.json" "$SKILL_DIR/setup.py" "$SKILL_DIR/LICENSE"

        echo "Done! Use /file-to-url <file_path> to upload files."
        ;;
    codex)
        echo "Installing skill for Codex..."

        SKILL_DIR="$HOME/.agents/skills/$SKILL_NAME"

        # Clone to temp dir and copy skill files
        TMP_DIR=$(mktemp -d)
        git clone --depth 1 "$REPO_URL" "$TMP_DIR" 2>/dev/null

        if [ ! -d "$TMP_DIR" ]; then
            echo "Error: Failed to clone repository."
            exit 1
        fi

        mkdir -p "$SKILL_DIR"
        cp "$TMP_DIR/SKILL.md"        "$SKILL_DIR/"
        cp "$TMP_DIR/upload_file.py"   "$SKILL_DIR/"

        rm -rf "$TMP_DIR"

        echo "Configuring API credentials..."
        cat > "$SKILL_DIR/config.json" <<EOF
{
  "api_url": "$API_URL",
  "api_key": "$API_KEY"
}
EOF
        echo "Configuration saved to $SKILL_DIR/config.json"

        echo "Done! Use \$file-to-url <file_path> to upload files."
        ;;
    *)
        echo "Error: Unknown target '$TARGET'. Use 'claude-code' or 'codex'."
        exit 1
        ;;
esac
