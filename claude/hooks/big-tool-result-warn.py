"""PostToolUse hook body. See big-tool-result-warn.sh."""
import json, sys, os

threshold = int(os.environ.get("CC_BIG_TOOL_THRESHOLD", "20000"))
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

resp = d.get("tool_response")
if resp is None:
    sys.exit(0)

s = resp if isinstance(resp, str) else json.dumps(resp, ensure_ascii=False)
size = len(s)
if size < threshold:
    sys.exit(0)

tool = d.get("tool_name", "?")
tinput = d.get("tool_input", {}) or {}
hint = {
    "Read":  "use offset+limit, or grep the file first",
    "Bash":  "pipe through head/grep/awk, or redirect to a file and read excerpts",
    "Grep":  "narrow the pattern, or use head_limit",
    "Glob":  "tighten the glob pattern",
    "WebFetch": "ask a more targeted prompt so the model summarizes harder",
}.get(tool, "narrow the query or summarize before returning")

inp_brief = json.dumps(tinput, ensure_ascii=False)
if len(inp_brief) > 200:
    inp_brief = inp_brief[:200] + "…"

toks = size // 4
msg = (
    f"⚠ Large tool result: {tool} returned ~{size:,} chars (~{toks:,} tokens). "
    f"Input: {inp_brief}. "
    f"This eats into the 168k Copilot context. "
    f"Next time: {hint}. "
    f"If the data is genuinely needed, consider dispatching a subagent that returns a summary."
)

out = {
    "systemMessage": f"big tool result: {tool} {size:,} chars",
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": msg,
    },
}
print(json.dumps(out))
