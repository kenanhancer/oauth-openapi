---
description: Start Redoc (8765), Scalar (8767), and Swagger UI (8768) in parallel
allowed-tools: Bash
---

Start the three OpenAPI viewers for `oauth-openapi.yaml` in parallel, in the
background, so the user can compare them side-by-side.

For each viewer:

1. Check if the target port is already in use with `lsof -iTCP:<port> -sTCP:LISTEN -P -n -t`.
   - If a process is already listening on that port, **do not start a duplicate**;
     report "already running on <port>" and skip to the next viewer.
2. Start the server in the background using `run_in_background: true`:
   - Redoc:      `npx --yes @redocly/cli preview-docs oauth-openapi.yaml --port 8765`
   - Scalar:     `npx --yes @scalar/cli document serve oauth-openapi.yaml --port 8767`
   - Swagger UI: `./tools/serve-swagger-ui.sh oauth-openapi.yaml --port 8768 --no-open`
3. Wait ~3 seconds (a single `sleep`), then verify each port is listening with
   `lsof` and the server returns HTTP 200 with `curl -sf -o /dev/null -w '%{http_code}'`.
4. After all three are up, open all three URLs in the default browser with `open`.

Final report (concise, table form):

| Tool | Port | Status |
|---|---|---|
| Redoc | 8765 | ✅ / ❌ |
| Scalar | 8767 | ✅ / ❌ |
| Swagger UI | 8768 | ✅ / ❌ |

End with: "Use `/preview-stop` to stop them."
