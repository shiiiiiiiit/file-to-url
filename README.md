**[English](README.md)** | [简体中文](README.zh-CN.md)

# file-to-url

Upload a local file to a remote service and get a public URL.

A skill for AI coding assistants (Claude Code, Codex, OpenCode, etc.) that uploads a local file via HTTP POST `multipart/form-data` to a configurable API endpoint, then returns the public URL from the response.

## Install

### Quick install — Claude Code (recommended)

One command to install **and** configure:

**macOS / Linux:**

```bash
bash <(curl -sSL https://raw.githubusercontent.com/shiiiiiiiit/file-to-url/main/install.sh) --api-url=https://your-api.com/upload --api-key=your-api-key
```

**Windows (PowerShell):**

```powershell
$tmp="$env:TEMP\install-file-to-url.ps1"; iwr -Uri https://raw.githubusercontent.com/shiiiiiiiit/file-to-url/main/install.ps1 -OutFile $tmp; & $tmp -ApiUrl 'https://your-api.com/upload' -ApiKey 'your-api-key'; Remove-Item $tmp
```

Or clone and run locally:

```bash
# macOS / Linux
bash install.sh --api-url=https://your-api.com/upload --api-key=your-api-key

# Windows (PowerShell)
.\install.ps1 -ApiUrl 'https://your-api.com/upload' -ApiKey 'your-api-key'
```

### Quick install — Codex

Same scripts, add `--target codex`:

**macOS / Linux:**

```bash
bash <(curl -sSL https://raw.githubusercontent.com/shiiiiiiiit/file-to-url/main/install.sh) --api-url=https://your-api.com/upload --api-key=your-api-key --target=codex
```

**Windows (PowerShell):**

```powershell
$tmp="$env:TEMP\install-file-to-url.ps1"; iwr -Uri https://raw.githubusercontent.com/shiiiiiiiit/file-to-url/main/install.ps1 -OutFile $tmp; & $tmp -Target codex -ApiUrl 'https://your-api.com/upload' -ApiKey 'your-api-key'; Remove-Item $tmp
```

The skill will be installed to `~/.agents/skills/file-to-url/`.

### Environment variables

Set `FILE_TO_URL_API_URL` and `FILE_TO_URL_API_KEY` before launching Claude Code or Codex. The skill reads them at runtime if no config file exists.

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
python %USERPROFILE%\.claude\skills\file-to-url\upload_file.py --setup --api-url=https://your-api.com/upload --api-key=your-api-key

# macOS / Linux
python ~/.claude/skills/file-to-url/upload_file.py --setup --api-url=https://your-api.com/upload --api-key=your-api-key
```

`--setup` also reads environment variables as defaults when `--api-url` / `--api-key` flags are omitted.

### OpenCode

Copy the SKILL.md content to your project commands directory:

```bash
mkdir -p .opencode/commands
cp SKILL.md .opencode/commands/file-to-url.md
```

Then copy `upload_file.py` alongside it, and run setup:

```bash
python .opencode/commands/upload_file.py --setup --api-url=https://your-api.com/upload --api-key=your-api-key
```

### Codex — Manual install

```bash
# Step 1: Create skill directory and copy files
mkdir -p ~/.agents/skills/file-to-url
cp SKILL.md upload_file.py ~/.agents/skills/file-to-url/

# Step 2: Configure API credentials
python ~/.agents/skills/file-to-url/upload_file.py --setup --api-url=https://your-api.com/upload --api-key=your-api-key
```

Codex discovers skills automatically from `~/.agents/skills/` — no further registration needed.

## Usage

In your AI assistant, type:

```
/file-to-url path/to/your/file.png    # Claude Code
$ file-to-url path/to/your/file.png   # Codex
```

The assistant will upload the file and return a public URL.

### Intent recognition

The skill also triggers automatically when the AI assistant detects that a tool, MCP, or API requires an `http`/`https` URL but the user only has a local file — for example, an image generation MCP that needs a reference image URL. In such cases, the assistant uploads the local file via this skill and passes the resulting URL to the target tool, without requiring an explicit `/file-to-url` (Claude Code) or `$file-to-url` (Codex) command.

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
python <skill-dir>/upload_file.py --setup --api-url=<new-url> --api-key=<new-key>
```

## Project structure

```
file-to-url/
├── SKILL.md              # Skill definition for AI assistants
├── upload_file.py        # Upload script + --setup for config (urllib, no extra deps)
├── config.template.json  # Template (copied to config.json by setup)
├── install.sh            # One-command installer (macOS / Linux)
├── install.ps1           # One-command installer (Windows)
├── .gitignore            # Prevents config.json from being committed
└── README.md
```

## Dependencies

- Python 3.7+ (uses `urllib` stdlib, no pip install needed)

## License

MIT
