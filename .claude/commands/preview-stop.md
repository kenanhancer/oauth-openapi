---
description: Stop the OpenAPI viewers running on ports 8765, 8767, 8768
allowed-tools: Bash
---

Stop any processes listening on the three viewer ports (Redoc 8765, Scalar
8767, Swagger UI 8768).

For each port:

1. Find listening PID(s) with `lsof -iTCP:<port> -sTCP:LISTEN -P -n -t`.
2. If a PID is found, send `SIGTERM` (`kill <pid>`).
3. Wait ~1 second, then re-check; if still listening, escalate to `kill -9 <pid>`.
4. Report whether the port was freed.

Final report (concise, table form):

| Tool | Port | Action |
|---|---|---|
| Redoc | 8765 | stopped (pid X) / was not running |
| Scalar | 8767 | stopped (pid Y) / was not running |
| Swagger UI | 8768 | stopped (pid Z) / was not running |

Be silent if all three were already free; just confirm "all three ports were
already free."
