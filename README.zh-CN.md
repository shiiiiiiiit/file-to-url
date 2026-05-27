[English](README.md) | **[简体中文](README.zh-CN.md)**

# file-to-url

将本地文件上传到远程服务并获取公开 URL。

一个面向 AI 编程助手（Claude Code、OpenCode 等）的技能插件，通过 HTTP POST `multipart/form-data` 将本地文件上传到可配置的 API 端点，然后从响应中返回公开 URL。

## 安装

### 快速安装（推荐）

一条命令完成安装**和**配置：

**macOS / Linux：**

```bash
bash <(curl -sSL https://raw.githubusercontent.com/shiiiiiiiit/file-to-url/main/install.sh) --api-url=https://your-api.com/upload --api-key=your-api-key
```

**Windows (PowerShell)：**

```powershell
$tmp="$env:TEMP\install-file-to-url.ps1"; iwr -Uri https://raw.githubusercontent.com/shiiiiiiiit/file-to-url/main/install.ps1 -OutFile $tmp; & $tmp -ApiUrl 'https://your-api.com/upload' -ApiKey 'your-api-key'; Remove-Item $tmp
```

也可以克隆后本地运行：

```bash
# macOS / Linux
bash install.sh --api-url=https://your-api.com/upload --api-key=your-api-key

# Windows (PowerShell)
.\install.ps1 -ApiUrl 'https://your-api.com/upload' -ApiKey 'your-api-key'
```

### 环境变量

在启动 Claude Code 之前设置 `FILE_TO_URL_API_URL` 和 `FILE_TO_URL_API_KEY`。如果不存在配置文件，技能会在运行时读取它们——无需 `setup.py`。

```bash
# macOS / Linux
export FILE_TO_URL_API_URL=https://your-api.com/upload
export FILE_TO_URL_API_KEY=your-api-key

# Windows (PowerShell)
$env:FILE_TO_URL_API_URL = 'https://your-api.com/upload'
$env:FILE_TO_URL_API_KEY = 'your-api-key'
```

### 手动安装 + 配置

```bash
# 第 1 步：安装技能
npx skills add https://github.com/shiiiiiiiit/file-to-url --skill file-to-url -y

# 第 2 步：配置 API 凭据
# Windows
python %USERPROFILE%\.claude\skills\file-to-url\setup.py --api-url=https://your-api.com/upload --api-key=your-api-key

# macOS / Linux
python ~/.claude/skills/file-to-url/setup.py --api-url=https://your-api.com/upload --api-key=your-api-key
```

当省略 `--api-url` / `--api-key` 参数时，`setup.py` 也会读取环境变量作为默认值。

### OpenCode

将 SKILL.md 内容复制到项目命令目录：

```bash
mkdir -p .opencode/commands
cp SKILL.md .opencode/commands/file-to-url.md
```

然后将 `upload_file.py`、`setup.py` 和 `config.template.json` 复制到同一目录，并运行配置：

```bash
python .opencode/commands/setup.py --api-url=https://your-api.com/upload --api-key=your-api-key
```

## 使用

在 AI 助手中输入：

```
/file-to-url path/to/your/file.png
```

助手将上传文件并返回公开 URL。

## API 契约

该技能期望远程 API 满足以下条件：

- 接受 `POST multipart/form-data`，包含 `file` 字段
- 需要 `Authorization: Bearer <key>` 请求头
- 返回 JSON：`{"code": "00000", "msg": "ok", "data": "https://..."}`
- `code == "00000"` 表示成功；公开 URL 在 `data` 字段中

## 配置

配置存储在 `config.json`（技能目录内）。当 `config.json` 缺失或值为空时，使用环境变量作为回退。

| 字段 | 配置键 | 环境变量 |
|------|--------|----------|
| API URL | `api_url` | `FILE_TO_URL_API_URL` |
| API Key | `api_key` | `FILE_TO_URL_API_KEY` |

更新配置：

```bash
python <skill-dir>/setup.py --api-url=<new-url> --api-key=<new-key>
```

## 项目结构

```
file-to-url/
├── SKILL.md              # AI 助手的技能定义
├── upload_file.py        # 上传脚本（urllib，无额外依赖）
├── setup.py              # 配置 API URL 和密钥
├── config.template.json  # 模板（由 setup.py 复制为 config.json）
├── install.sh            # 一键安装器（macOS / Linux）
├── install.ps1           # 一键安装器（Windows）
├── .gitignore            # 防止 config.json 被提交
└── README.md
```

## 依赖

- Python 3.7+（使用 `urllib` 标准库，无需 pip install）

## 许可证

MIT
