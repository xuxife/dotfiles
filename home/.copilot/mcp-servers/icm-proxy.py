#!/usr/bin/env python3
"""IcM MCP stdio<->HTTP proxy using azureauth-acquired MSFT-tenant token."""
import json, os, sys, subprocess, urllib.request, urllib.error, base64, time

URL = "https://icm-mcp-prod.azure-api.net/v1/"
TOKEN_FILE = f"/tmp/icm-mcp-token-{os.getuid()}"
SESSION_ID = None
TOKEN = None

def log(msg):
    sys.stderr.write(f"[icm-proxy] {msg}\n"); sys.stderr.flush()

def _exp(tok):
    try:
        p = tok.split('.')[1]; p += '=' * (-len(p) % 4)
        return json.loads(base64.urlsafe_b64decode(p)).get('exp', 0)
    except Exception:
        return 0

def get_token(force=False):
    global TOKEN
    if TOKEN and not force and _exp(TOKEN) > time.time() + 60:
        return TOKEN
    r = subprocess.run(
        ["azureauth", "aad",
         "--client", "aebc6443-996d-45c2-90f0-388ff96faa56",
         "--tenant", "72f988bf-86f1-41af-91ab-2d7cd011db47",
         "--scope", "api://icmmcpapi-prod/mcp.tools",
         "--domain", "microsoft.com", "--mode", "broker",
         "--timeout", "1", "--output", "token"],
        capture_output=True, text=True, timeout=60)
    if r.returncode != 0:
        log(f"azureauth failed (rc={r.returncode}): {r.stderr.strip()}")
        raise SystemExit(1)
    TOKEN = r.stdout.strip().splitlines()[-1]
    try:
        with open(TOKEN_FILE, "w") as f: f.write(TOKEN)
        os.chmod(TOKEN_FILE, 0o600)
    except Exception: pass
    return TOKEN

if os.path.exists(TOKEN_FILE):
    try:
        TOKEN = open(TOKEN_FILE).read().strip()
        get_token()
    except Exception: TOKEN = None

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
    if sid: SESSION_ID = sid
    return resp.headers.get("Content-Type", ""), resp.read()

def parse_sse(body):
    for chunk in body.split(b"\n\n"):
        data_lines = [ln[5:].lstrip() for ln in chunk.split(b"\n") if ln.startswith(b"data:")]
        if data_lines:
            yield b"\n".join(data_lines)

def emit(b):
    sys.stdout.buffer.write(b)
    if not b.endswith(b"\n"): sys.stdout.buffer.write(b"\n")
    sys.stdout.buffer.flush()

for line in sys.stdin.buffer:
    line = line.strip()
    if not line: continue
    # MCP notifications (no id) don't expect a response from server in HTTP transport,
    # but we still POST them. Server returns 202 with empty body for notifications.
    try:
        ctype, body = post(line)
    except Exception as e:
        log(f"request failed: {e}")
        try:
            msg = json.loads(line)
            if msg.get("id") is not None:
                emit(json.dumps({"jsonrpc":"2.0","id":msg["id"],
                                 "error":{"code":-32000,"message":f"proxy error: {e}"}}).encode())
        except Exception: pass
        continue
    if "text/event-stream" in ctype:
        for obj in parse_sse(body):
            if obj: emit(obj)
    elif body:
        emit(body.strip())
