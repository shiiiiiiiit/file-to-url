#!/usr/bin/env python3
"""Configure file-to-url skill with API credentials."""

import json
import os
import argparse


ENV_API_URL = "FILE_TO_URL_API_URL"
ENV_API_KEY = "FILE_TO_URL_API_KEY"


def main():
    parser = argparse.ArgumentParser(description="Configure file-to-url skill")
    parser.add_argument(
        "--api-url",
        default=os.environ.get(ENV_API_URL),
        help=f"Upload API endpoint URL (env: {ENV_API_URL})",
    )
    parser.add_argument(
        "--api-key",
        default=os.environ.get(ENV_API_KEY),
        help=f"API Bearer token (env: {ENV_API_KEY})",
    )
    args = parser.parse_args()

    if not args.api_url:
        parser.error(f"--api-url is required (or set {ENV_API_URL})")
    if not args.api_key:
        parser.error(f"--api-key is required (or set {ENV_API_KEY})")

    skill_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(skill_dir, "config.json")
    config = {"api_url": args.api_url, "api_key": args.api_key}

    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)

    print(f"Configuration saved to {config_path}")


if __name__ == "__main__":
    main()
