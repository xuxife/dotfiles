#!/usr/bin/env bash
# PostToolUse hook: warn Claude (via additionalContext) when a tool returns a
# very large payload, so it knows to use head/grep/offset+limit next time.
# Threshold: 20000 chars (~5k tokens). Override with CC_BIG_TOOL_THRESHOLD.
set -euo pipefail
export CC_BIG_TOOL_THRESHOLD="${CC_BIG_TOOL_THRESHOLD:-20000}"
exec python3 /home/xingfeixu/.claude/hooks/big-tool-result-warn.py
