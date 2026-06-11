[CmdletBinding()]
param(
    [ValidateSet("claude-code", "codex")]
    [string]$Target = "claude-code",
    [string]$ApiUrl = "",
    [string]$ApiKey = ""
)

$RepoUrl = "https://github.com/shiiiiiiiit/file-to-url"
$SkillName = "file-to-url"

# Fallback to environment variables
if (-not $ApiUrl) { $ApiUrl = $env:FILE_TO_URL_API_URL }
if (-not $ApiKey) { $ApiKey = $env:FILE_TO_URL_API_KEY }

if (-not $ApiUrl -or -not $ApiKey) {
    Write-Error "ApiUrl and ApiKey are required. Pass them as parameters or set FILE_TO_URL_API_URL / FILE_TO_URL_API_KEY environment variables."
    exit 1
}

switch ($Target) {
    "claude-code" {
        Write-Host "Installing skill for Claude Code..."
        npx skills add $RepoUrl --skill $SkillName -y

        $SkillDir = Join-Path $env:USERPROFILE ".claude\skills\$SkillName"
        if (-not (Test-Path $SkillDir)) {
            Write-Error "Skill directory not found at $SkillDir"
            exit 1
        }

        Write-Host "Configuring API credentials..."
        $config = @{ api_url = $ApiUrl; api_key = $ApiKey } | ConvertTo-Json
        Set-Content -Path "$SkillDir\config.json" -Value $config -Encoding UTF8
        Write-Host "Configuration saved to $SkillDir\config.json"

        Write-Host "Cleaning up non-skill files..."
        Remove-Item -Force -ErrorAction SilentlyContinue "$SkillDir\.gitignore", "$SkillDir\README.md", "$SkillDir\README.zh-CN.md", "$SkillDir\install.sh", "$SkillDir\install.ps1", "$SkillDir\config.template.json", "$SkillDir\setup.py", "$SkillDir\LICENSE"

        Write-Host "Done! Use /file-to-url <file_path> to upload files."
    }
    "codex" {
        Write-Host "Installing skill for Codex..."

        $SkillDir = Join-Path $env:USERPROFILE ".agents\skills\$SkillName"

        # Clone to temp dir and copy skill files
        $TmpDir = Join-Path $env:TEMP "file-to-url-clone-$(Get-Random)"
        git clone --depth 1 $RepoUrl $TmpDir 2>$null

        if (-not (Test-Path $TmpDir)) {
            Write-Error "Failed to clone repository."
            exit 1
        }

        New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null
        Copy-Item "$TmpDir\SKILL.md"        $SkillDir -Force
        Copy-Item "$TmpDir\upload_file.py"   $SkillDir -Force

        Remove-Item -Recurse -Force $TmpDir

        Write-Host "Configuring API credentials..."
        $config = @{ api_url = $ApiUrl; api_key = $ApiKey } | ConvertTo-Json
        Set-Content -Path "$SkillDir\config.json" -Value $config -Encoding UTF8
        Write-Host "Configuration saved to $SkillDir\config.json"

        Write-Host "Done! Use `$file-to-url <file_path> to upload files."
    }
}
