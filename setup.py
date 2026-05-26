#!/usr/bin/env python3
"""Configure file-to-url skill with API credentials."""

import json
import os
import argparse


def main():
    parser = argparse.ArgumentParser(description="Configure file-to-url skill")
    parser.add_argument("--api-url", required=True, help="Upload API endpoint URL")
    parser.add_argument("--api-key", required=True, help="API Bearer token")
    args = parser.parse_args()

    skill_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(skill_dir, "config.json")
    config = {"api_url": args.api_url, "api_key": args.api_key}

    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)

    print(f"Configuration saved to {config_path}")


if __name__ == "__main__":
    main()
