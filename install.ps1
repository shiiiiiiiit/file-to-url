[CmdletBinding()]
param(
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

Write-Host "Installing skill..."
npx skills add $RepoUrl --skill $SkillName -y

$SkillDir = Join-Path $env:USERPROFILE ".claude\skills\$SkillName"
if (-not (Test-Path $SkillDir)) {
    Write-Error "Skill directory not found at $SkillDir"
    exit 1
}

Write-Host "Cleaning up non-skill files..."
Remove-Item -Force -ErrorAction SilentlyContinue "$SkillDir\.gitignore", "$SkillDir\README.md", "$SkillDir\install.sh", "$SkillDir\install.ps1", "$SkillDir\config.template.json", "$SkillDir\setup.py"

Write-Host "Configuring API credentials..."
python "$SkillDir\setup.py" --api-url="$ApiUrl" --api-key="$ApiKey"

Write-Host "Done! Use /file-to-url <file_path> to upload files."
