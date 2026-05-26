# file-to-url

Upload a local file to a remote service and get a public URL.

A skill for AI coding assistants (Claude Code, OpenCode, etc.) that uploads a local file via HTTP POST `multipart/form-data` to a configurable API endpoint, then returns the public URL from the response.

## Install

### Claude Code

```bash
npx skills add https://github.com/shiiiiiiiit/file-to-url --skill file-to-url -y
```

Then configure with your API credentials:

```bash
# Windows
python %USERPROFILE%\.claude\skills\file-to-url\setup.py --api-url=https://your-api.com/upload --api-key=your-api-key

# macOS / Linux
python ~/.claude/skills/file-to-url/setup.py --api-url=https://your-api.com/upload --api-key=your-api-key
```

### One-liner install + configure

```bash
# Windows (PowerShell)
npx skills add https://github.com/<your-username>/file-to-url --skill file-to-url -y; python "$env:USERPROFILE\.claude\skills\file-to-url\setup.py" --api-url=https://your-api.com/upload --api-key=your-api-key

# macOS / Linux
npx skills add https://github.com/<your-username>/file-to-url --skill file-to-url -y && python ~/.claude/skills/file-to-url/setup.py --api-url=https://your-api.com/upload --api-key=your-api-key
```

### OpenCode

Copy the SKILL.md content to your project commands directory:

```bash
mkdir -p .opencode/commands
cp SKILL.md .opencode/commands/file-to-url.md
```

Then copy `upload_file.py`, `setup.py`, and `config.template.json` alongside it, and run setup:

```bash
python .opencode/commands/setup.py --api-url=https://your-api.com/upload --api-key=your-api-key
```

## Usage

In your AI assistant, type:

```
/file-to-url path/to/your/file.png
```

The assistant will upload the file and return a public URL.

## API contract

The skill expects a remote API that:

- Accepts `POST multipart/form-data` with a `file` field
- Requires `Authorization: Bearer <key>` header
- Returns JSON: `{"code": "00000", "msg": "ok", "data": "https://..."}`
- `code == "00000"` means success; the public URL is in `data`

## Configuration

Config is stored in `config.json` (inside the skill directory), **not** in environment variables.

| Field | Description |
|-------|-------------|
| `api_url` | Upload API endpoint URL |
| `api_key` | Bearer token for Authorization header |

To update:

```bash
python <skill-dir>/setup.py --api-url=<new-url> --api-key=<new-key>
```

## Project structure

```
file-to-url/
├── SKILL.md              # Skill definition for AI assistants
├── upload_file.py        # Upload script (urllib, no extra deps)
├── setup.py              # Configure API URL and key
├── config.template.json  # Template (copied to config.json by setup.py)
├── .gitignore            # Prevents config.json from being committed
└── README.md
```

## Dependencies

- Python 3.7+ (uses `urllib` stdlib, no pip install needed)

## License

MIT
