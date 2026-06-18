#!/bin/bash
# IcM MCP stdio<->HTTP proxy, using azureauth-acquired MSFT-tenant token.
# Replaces broken `agency mcp icm` which falls back to az CLI on headless Linux
# and fails because the az first-party app isn't consented for IcM scope.

set -euo pipefail

ICM_URL="https://icm-mcp-prod.azure-api.net/v1/"
AAD_CLIENT="aebc6443-996d-45c2-90f0-388ff96faa56"
AAD_TENANT="72f988bf-86f1-41af-91ab-2d7cd011db47"
AAD_SCOPE="api://icmmcpapi-prod/mcp.tools"

# Cache token to a tmp file; refresh from azureauth when missing/expired (silent).
TOKEN_FILE="${TMPDIR:-/tmp}/icm-mcp-token-$UID"

get_token() {
    if [[ -s "$TOKEN_FILE" ]]; then
        # JWT exp check
        local t exp now
        t=$(cat "$TOKEN_FILE")
        exp=$(echo -n "${t}" | cut -d. -f2 | { read p; pad=$((4 - ${#p} % 4)); [[ $pad -lt 4 ]] && p="${p}$(printf '%*s' $pad '' | tr ' ' '=')"; echo "$p"; } | tr '_-' '/+' | base64 -d 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('exp',0))" 2>/dev/null || echo 0)
        now=$(date +%s)
        if (( exp > now + 60 )); then
            echo "$t"
            return 0
        fi
    fi
    azureauth aad --client "$AAD_CLIENT" --tenant "$AAD_TENANT" --scope "$AAD_SCOPE" \
        --domain microsoft.com --mode broker --timeout 1 --output token 2>/dev/null \
        | tail -1 | tee "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
}

exec python3 - "$ICM_URL" "$TOKEN_FILE" <<'PYEOF'
import json, os, sys, subprocess, threading, urllib.request, urllib.error, base64, time

URL = sys.argv[1]
TOKEN_FILE = sys.argv[2]
SESSION_ID = None
TOKEN = None

def log(msg):
    sys.stderr.write(f"[icm-proxy] {msg}\n"); sys.stderr.flush()

def get_token(force=False):
    global TOKEN
    if TOKEN and not force:
        # check exp
        try:
            p = TOKEN.split('.')[1]
            p += '=' * (-len(p) % 4)
            exp = json.loads(base64.urlsafe_b64decode(p)).get('exp', 0)
            if exp > time.time() + 60:
                return TOKEN
        except Exception:
            pass
    # refresh
    r = subprocess.run(
        ["azureauth", "aad",
         "--client", "aebc6443-996d-45c2-90f0-388ff96faa56",
         "--tenant", "72f988bf-86f1-41af-91ab-2d7cd011db47",
         "--scope", "api://icmmcpapi-prod/mcp.tools",
         "--domain", "microsoft.com", "--mode", "broker",
         "--timeout", "1", "--output", "token"],
        capture_output=True, text=True, timeout=60)
    if r.returncode != 0:
        log(f"azureauth failed: {r.stderr}")
        raise SystemExit(1)
    TOKEN = r.stdout.strip().splitlines()[-1]
    try:
        with open(TOKEN_FILE, "w") as f:
            f.write(TOKEN)
        os.chmod(TOKEN_FILE, 0o600)
    except Exception:
        pass
    return TOKEN

# preload cached token if any
if os.path.exists(TOKEN_FILE):
    try:
        TOKEN = open(TOKEN_FILE).read().strip()
        get_token()  # validates exp
    except Exception:
        TOKEN = None

def post(payload_bytes, retry=True):
    global SESSION_ID
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
        "Authorization": "Bearer " + get_token(),
    }
    if SESSION_ID:
        headers["Mcp-Session-Id"] = SESSION_ID
    req = urllib.request.Request(URL, data=payload_bytes, headers=headers, method="POST")
    try:
        resp = urllib.request.urlopen(req, timeout=120)
    except urllib.error.HTTPError as e:
        if e.code == 401 and retry:
            log("401 — refreshing token and retrying")
            get_token(force=True)
            return post(payload_bytes, retry=False)
        log(f"HTTP {e.code}: {e.read()[:500]!r}")
        raise
    sid = resp.headers.get("Mcp-Session-Id")
    if sid:
        SESSION_ID = sid
    ctype = resp.headers.get("Content-Type", "")
    body = resp.read()
    return ctype, body

def parse_sse(body):
    """Yield JSON objects from text/event-stream body."""
    for chunk in body.split(b"\n\n"):
        data_lines = []
        for line in chunk.split(b"\n"):
            if line.startswith(b"data:"):
                data_lines.append(line[5:].lstrip())
        if data_lines:
            yield b"\n".join(data_lines)

def emit(obj_bytes):
    sys.stdout.buffer.write(obj_bytes)
    if not obj_bytes.endswith(b"\n"):
        sys.stdout.buffer.write(b"\n")
    sys.stdout.buffer.flush()

# Read line-delimited JSON-RPC from stdin
for line in sys.stdin.buffer:
    line = line.strip()
    if not line:
        continue
    try:
        ctype, body = post(line)
    except Exception as e:
        log(f"request failed: {e}")
        try:
            msg = json.loads(line)
            err = {"jsonrpc": "2.0", "id": msg.get("id"),
                   "error": {"code": -32000, "message": f"proxy error: {e}"}}
            emit(json.dumps(err).encode())
        except Exception:
            pass
        continue
    if "text/event-stream" in ctype:
        for obj in parse_sse(body):
            if obj:
                emit(obj)
    elif body:
        # plain JSON response (or empty)
        emit(body.strip())
PYEOF
