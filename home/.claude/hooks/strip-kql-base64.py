"""UserPromptSubmit hook body. See strip-kql-base64.sh."""
import json, sys, re

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

prompt = d.get("prompt") or ""
if not prompt:
    sys.exit(0)

# H4sIA = gzip magic in base64; Kusto share URLs always use this prefix.
# Match ?query=H4sIA... up to whitespace, ), ", or > (URL terminators).
PATTERN = re.compile(r"\?query=H4sIA[A-Za-z0-9%+/=_\-]+")
new, n = PATTERN.subn("", prompt)
if n == 0:
    sys.exit(0)

saved = len(prompt) - len(new)
out = {
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "updatedPrompt": new,
    },
    "systemMessage": f"stripped {n} base64 KQL blob(s) from dataexplorer URL(s), saved ~{saved:,} chars",
}
print(json.dumps(out, ensure_ascii=False))
