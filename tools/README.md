# tools/

Developer utilities for working with this OpenAPI spec.

These scripts are **generic** — they take any OpenAPI YAML/JSON file as input,
not just the one in this repo. Drop them into another project and they'll work
the same way.

## Scripts

### `serve-swagger-ui.sh`

Spins up a local Swagger UI viewer for any OpenAPI spec on the fly. The HTML
bootstrap is generated in a temp directory (no files written into your
project), the official `swagger-ui-dist@5` package is loaded from the unpkg.com
CDN, and Python's built-in HTTP server serves both. Cleanup is automatic on
Ctrl+C.

#### Why this exists

The community npm CLIs that ostensibly serve Swagger UI (`swagger-ui-watcher`,
`swagger-ui-cli`, `swagger-ui-live`) are either broken, abandoned, or wrap an
older Swagger Editor that does not support OpenAPI 3.1. SmartBear publishes the
`swagger-ui-dist` library but never shipped a CLI for it. This script fills
that gap with a 250-line bash file you can audit in one sitting.

#### Quick start

```bash
# From the project root
./tools/serve-swagger-ui.sh oauth-openapi.yaml
# → opens http://127.0.0.1:8765/ in your browser
```

#### Usage

```text
serve-swagger-ui.sh <spec> [options]

ARGUMENTS
  <spec>                       Path to an OpenAPI YAML or JSON file.

OPTIONS
  -p, --port <number>          Port to bind (default: 8765, or $PORT env var).
  -H, --host <addr>            Address to bind (default: 127.0.0.1).
      --swagger-version <v>    Major version of swagger-ui-dist (default: 5).
      --title <text>           Browser tab title.
      --no-open                Do not auto-open a browser.
  -q, --quiet                  Suppress info logs.
  -v, --verbose                Print debug logs.
  -h, --help                   Show full help (with examples + exit codes).
      --version                Print version.
```

Run `./tools/serve-swagger-ui.sh --help` for the complete reference (env vars,
exit codes, requirements).

#### Examples

```bash
# Default — port 8765, opens browser
./tools/serve-swagger-ui.sh oauth-openapi.yaml

# Custom port, no browser, in background
./tools/serve-swagger-ui.sh oauth-openapi.yaml --port 9000 --no-open &

# Run silently with PORT env var
PORT=8888 ./tools/serve-swagger-ui.sh oauth-openapi.yaml --quiet --no-open &

# Pin to swagger-ui-dist@4 (for legacy specs)
./tools/serve-swagger-ui.sh openapi-2.0.yaml --swagger-version 4

# Custom title
./tools/serve-swagger-ui.sh openapi.yaml --title "My API Docs"

# Use in another project — script is fully self-contained
cp tools/serve-swagger-ui.sh ~/some-other-api/tools/
~/some-other-api/tools/serve-swagger-ui.sh ~/some-other-api/spec.yaml
```

#### Requirements

| Tool | Why | Where |
|---|---|---|
| `bash` (3.2+) | Script interpreter | macOS / Linux default |
| `python3` | HTTP server (`python3 -m http.server`) | macOS / Linux default |
| Internet (first load) | CDN-loaded Swagger UI assets (~500 KB) | unpkg.com |
| `lsof` (optional) | Port-in-use detection | macOS / Linux default |
| `nc` (optional) | Wait-for-port probe | macOS / Linux default |

After the first browser load, Swagger UI assets are usually browser-cached, so
the script works offline for repeat uses on the same browser profile.

#### Design principles applied

- **Strict mode**: `set -euo pipefail`, `IFS=$'\n\t'`
- **Single Responsibility**: each function does exactly one thing
- **Fail fast**: validation runs before any side effect
- **Idempotent cleanup**: trap survives partial state on early exit
- **Cross-platform**: portable `mktemp`, `lsof`/`nc` fallbacks, macOS+Linux browser opener
- **TTY-aware logging**: ANSI colors only when stderr is a terminal and `NO_COLOR` is unset
- **Safe templating**: filename is encoded as JSON before embedding into the JS string (handles spaces, quotes, etc.)
- **Documented exit codes**: 0/2/3/4/5/10 (see `--help`)
- **No surprise file writes**: only the temp dir is touched; project files untouched
- **Short and auditable**: single-file bash, no transpilation, ~250 lines

#### Troubleshooting

| Problem | Fix |
|---|---|
| `Required command not found: python3` | Install Python 3 (it's the only hard runtime dep). |
| `Port 8765 is already in use` | Pass `--port <other>` or stop whatever owns the port (`lsof -i:8765`). |
| Browser opens but page is blank | Check the browser console — usually CDN load failed. Retry or pin `--swagger-version 4`. |
| `Spec file not found` | Use the path relative to your shell's CWD, not the script location. |
| Spec renders but `Try it out` always fails with DNS error | Your `servers.url` is unreachable. Edit the `servers` block in the YAML, or use the Swagger UI server-selector at the top of the page. |

#### Running in CI / containers

The script binds to `127.0.0.1` by default. For container or remote use,
override the host:

```bash
./tools/serve-swagger-ui.sh openapi.yaml --host 0.0.0.0 --port 8080 --no-open
```
