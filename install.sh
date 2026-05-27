#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/shiiiiiiiit/file-to-url"
SKILL_NAME="file-to-url"

API_URL=""
API_KEY=""

for arg in "$@"; do
    case "$arg" in
        --api-url=*) API_URL="${arg#--api-url=}" ;;
        --api-key=*) API_KEY="${arg#--api-key=}" ;;
        --help|-h)
            echo "Usage: bash install.sh --api-url=<url> --api-key=<key>"
            echo ""
            echo "Options:"
            echo "  --api-url=URL   Upload API endpoint URL"
            echo "  --api-key=KEY   API Bearer token"
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

echo "Installing skill..."
npx skills add "$REPO_URL" --skill "$SKILL_NAME" -y

SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
if [ ! -d "$SKILL_DIR" ]; then
    echo "Error: Skill directory not found at $SKILL_DIR"
    exit 1
fi

echo "Configuring API credentials..."
python3 "$SKILL_DIR/setup.py" --api-url="$API_URL" --api-key="$API_KEY"

echo "Done! Use /file-to-url <file_path> to upload files."
