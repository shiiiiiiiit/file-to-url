---
name: file-to-url
description: "Upload a local file to a remote service and get a public URL. Trigger: /file-to-url"
trigger: /file-to-url
---

# /file-to-url

Upload a local file to a remote service and return a public URL.

## Usage

```
/file-to-url <file_path>
```

## First-time setup

Before first use, the API endpoint and key must be configured. Check if the skill is configured:

```powershell
python SKILL_DIR/upload_file.py --check-config
```

If not configured, ask the user for:
1. **API URL** — the upload endpoint (e.g. `https://api.example.com/upload`)
2. **API Key** — the Bearer token for authentication

Then write the config:

```powershell
python SKILL_DIR/setup.py --api-url="<api_url>" --api-key="<api_key>"
```

Replace `SKILL_DIR` with the directory containing this skill (where `upload_file.py` resides).

## How to upload a file

```powershell
python SKILL_DIR/upload_file.py "<file_path>"
```

Replace `SKILL_DIR` with the skill directory path and `<file_path>` with the local file to upload.

## Determining SKILL_DIR

The skill directory is the folder containing this SKILL.md file. Common locations:

- **Claude Code (Windows):** `C:\Users\<user>\.claude\skills\file-to-url`
- **Claude Code (macOS/Linux):** `~/.claude/skills/file-to-url`

You can also locate it by searching for `upload_file.py` alongside this SKILL.md.

## Output format

The script outputs JSON to stdout:

- **Success:** `{"success": true, "url": "https://..."}`
- **Failure:** `{"success": false, "error": "error description"}`

On success, report the URL to the user. On failure, show the error message.

## Error handling

| Error | Cause | Action |
|-------|-------|--------|
| Config not found | setup.py has not been run | Run setup with API URL and key |
| API URL/key not configured | config.json has empty values | Re-run setup.py |
| File not found | Invalid file path | Verify the path exists |
| HTTP 4xx/5xx | Server rejected the request | Show status code and response |
| API code != 00000 | Business logic error | Show code and msg from API |
| Connection error | Network or URL issue | Check API URL and network |

## Updating configuration

To change the API URL or key, re-run setup:

```powershell
python SKILL_DIR/setup.py --api-url="<new_url>" --api-key="<new_key>"
```

This overwrites the existing config.
