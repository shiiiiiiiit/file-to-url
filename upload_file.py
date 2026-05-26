#!/usr/bin/env python3
"""Upload a local file to a remote service and return the public URL."""

import json
import sys
import os
import mimetypes
import uuid
import urllib.request
import urllib.error


def get_config_path():
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json")


def load_config():
    config_path = get_config_path()
    if not os.path.exists(config_path):
        return None
    with open(config_path, "r", encoding="utf-8") as f:
        return json.load(f)


def is_configured():
    config = load_config()
    if not config:
        return False
    return bool(config.get("api_url", "").strip()) and bool(
        config.get("api_key", "").strip()
    )


def build_multipart(files):
    boundary = uuid.uuid4().hex
    body = bytearray()

    for field_name, (filename, file_data, content_type) in files.items():
        body.extend(f"--{boundary}\r\n".encode())
        body.extend(
            f'Content-Disposition: form-data; name="{field_name}"; filename="{filename}"\r\n'.encode()
        )
        body.extend(f"Content-Type: {content_type}\r\n\r\n".encode())
        body.extend(file_data)
        body.extend(b"\r\n")

    body.extend(f"--{boundary}--\r\n".encode())

    content_type = f"multipart/form-data; boundary={boundary}"
    return bytes(body), content_type


def upload_file(file_path):
    config = load_config()
    if not config:
        return {"success": False, "error": "Config file not found. Run setup.py first."}

    api_url = config.get("api_url", "").strip()
    api_key = config.get("api_key", "").strip()

    if not api_url or not api_key:
        return {
            "success": False,
            "error": "API URL or API key not configured. Run setup.py first.",
        }

    file_path = os.path.abspath(file_path)
    if not os.path.isfile(file_path):
        return {"success": False, "error": f"File not found: {file_path}"}

    filename = os.path.basename(file_path)
    mime_type = mimetypes.guess_type(file_path)[0] or "application/octet-stream"

    with open(file_path, "rb") as f:
        file_data = f.read()

    body, content_type = build_multipart({"file": (filename, file_data, mime_type)})

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": content_type,
    }

    req = urllib.request.Request(api_url, data=body, headers=headers, method="POST")

    try:
        with urllib.request.urlopen(req) as resp:
            resp_data = json.loads(resp.read().decode("utf-8"))
            code = resp_data.get("code", "")
            if code == "00000":
                url = resp_data.get("data", "")
                return {"success": True, "url": url}
            else:
                msg = resp_data.get("msg", "Unknown error")
                return {"success": False, "error": f"API error (code={code}): {msg}"}
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8", errors="replace")
        return {"success": False, "error": f"HTTP {e.code}: {error_body}"}
    except urllib.error.URLError as e:
        return {"success": False, "error": f"Connection error: {e.reason}"}
    except json.JSONDecodeError as e:
        return {"success": False, "error": f"Invalid JSON response: {e}"}


def main():
    if len(sys.argv) >= 2 and sys.argv[1] == "--check-config":
        result = {"configured": is_configured()}
        if result["configured"]:
            config = load_config()
            result["api_url"] = config.get("api_url", "")
            result["api_key_set"] = bool(config.get("api_key", "").strip())
        print(json.dumps(result, ensure_ascii=False))
        sys.exit(0 if result["configured"] else 1)

    if len(sys.argv) < 2:
        print(
            json.dumps(
                {"success": False, "error": "Usage: python upload_file.py <file_path>"},
                ensure_ascii=False,
            )
        )
        sys.exit(1)

    result = upload_file(sys.argv[1])
    print(json.dumps(result, ensure_ascii=False))

    if not result.get("success"):
        sys.exit(1)


if __name__ == "__main__":
    main()
