#!/usr/bin/env bash
# UserPromptSubmit hook: strip the base64 ?query=H4sIA... blob from dataexplorer
# share URLs. Kusto auto-copy embeds the same KQL twice (base64 + plaintext),
# so dropping the base64 keeps the readable query and saves ~10k chars per URL.
set -euo pipefail
exec python3 /home/xingfeixu/.claude/hooks/strip-kql-base64.py
