# file-to-url

Upload a local file to a remote service and get a public URL.

A skill for AI coding assistants (Claude Code, OpenCode, etc.) that uploads a local file via HTTP POST `multipart/form-data` to a configurable API endpoint, then returns the public URL from the response.

## Install

### Quick install (recommended)

One command to install **and** configure:

**macOS / Linux:**

```bash
bash <(curl -sSL https://raw.githubusercontent.com/shiiiiiiiit/file-to-url/main/install.sh) --api-url=https://your-api.com/upload --api-key=your-api-key
```

**Windows (PowerShell):**

```powershell
iwr https://raw.githubusercontent.com/shiiiiiiiit/file-to-url/raw/main/install.ps1 | iex -ApiUrl 'https://your-api.com/upload' -ApiKey 'your-api-key'
```

Or clone and run locally:

```bash
# macOS / Linux
bash install.sh --api-url=https://your-api.com/upload --api-key=your-api-key

# Windows (PowerShell)
.\install.ps1 -ApiUrl 'https://your-api.com/upload' -ApiKey 'your-api-key'
```

### Environment variables

Set `FILE_TO_URL_API_URL` and `FILE_TO_URL_API_KEY` before launching Claude Code. The skill reads them at runtime if no config file exists — no `setup.py` needed.

```bash
# macOS / Linux
export FILE_TO_URL_API_URL=https://your-api.com/upload
export FILE_TO_URL_API_KEY=your-api-key

# Windows (PowerShell)
$env:FILE_TO_URL_API_URL = 'https://your-api.com/upload'
$env:FILE_TO_URL_API_KEY = 'your-api-key'
```

### Manual install + configure

```bash
# Step 1: Install the skill
npx skills add https://github.com/shiiiiiiiit/file-to-url --skill file-to-url -y

# Step 2: Configure API credentials
# Windows
python %USERPROFILE%\.claude\skills\file-to-url\setup.py --api-url=https://your-api.com/upload --api-key=your-api-key

# macOS / Linux
python ~/.claude/skills/file-to-url/setup.py --api-url=https://your-api.com/upload --api-key=your-api-key
```

`setup.py` also reads environment variables as defaults when `--api-url` / `--api-key` flags are omitted.

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

Config is stored in `config.json` (inside the skill directory). Environment variables are used as a fallback when `config.json` is missing or has empty values.

| Field | Config key | Environment variable |
|-------|------------|---------------------|
| API URL | `api_url` | `FILE_TO_URL_API_URL` |
| API Key | `api_key` | `FILE_TO_URL_API_KEY` |

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
├── install.sh            # One-command installer (macOS / Linux)
├── install.ps1           # One-command installer (Windows)
├── .gitignore            # Prevents config.json from being committed
└── README.md
```

## Dependencies

- Python 3.7+ (uses `urllib` stdlib, no pip install needed)

## License

MIT
