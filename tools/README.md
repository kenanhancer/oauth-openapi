# tools/

Developer utilities for working with this OpenAPI spec and the standards it is
built from.

These scripts are **generic** — they take any OpenAPI YAML/JSON file or any
specification identifier/URL as input, not just the ones in this repo. Drop
them into another project and they'll work the same way.

| Script | What it does |
|---|---|
| [`serve-swagger-ui.sh`](#serve-swagger-uish) | Serve Swagger UI for any OpenAPI spec, on the fly |
| [`fetch-specs.sh`](#fetch-specssh) | Vendor RFCs, Internet-Drafts and other specs (e.g. OpenID Foundation), and detect drift in vendored copies |

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

---

### `fetch-specs.sh`

Downloads specification documents into a directory, and audits an
already-vendored set for drift. RFCs come from
`https://www.rfc-editor.org/rfc/rfcNNNN.txt`; Internet-Drafts from
`https://www.ietf.org/archive/id/<name>-<rev>.txt`. When a draft is named
without a revision, the latest one is resolved through the IETF Datatracker
API and the file is stored under the unversioned name, so it refreshes in place.
Any other document — e.g. an OpenID Foundation spec — is named
`<file>=<https-url>`.

#### Why this exists

`references/rfc-sources/` and `references/oidf-sources/` were refreshed by
hand several times (initial snapshot, the RFC 8705 + OAuth 2.1 refresh, the
17-RFC gap fill, the OIDF move). Each run was a pasted `curl` loop with no
verification, and nothing told us when the vendored set had gone stale — e.g.
when OAuth 2.1 moved from draft-15 to -16, when RFC 10017 / RFC 10027 were
published, or when an OIDF spec gained an errata set in place. This script makes
the refresh repeatable and the staleness detectable (`--check` exits non-zero).
Each folder keeps its document list in a `manifest.txt`.

#### Quick start

```bash
# From the project root — refresh everything listed in the manifests
./tools/fetch-specs.sh --dir references/rfc-sources  --file references/rfc-sources/manifest.txt
./tools/fetch-specs.sh --dir references/oidf-sources --file references/oidf-sources/manifest.txt

# Read-only audit: is anything missing, changed upstream, or a newer draft out?
./tools/fetch-specs.sh --check --dir references/rfc-sources  --file references/rfc-sources/manifest.txt
./tools/fetch-specs.sh --check --dir references/oidf-sources --file references/oidf-sources/manifest.txt
```

#### Usage

```text
fetch-specs.sh [options] <doc>...
fetch-specs.sh [options] --file <list>

DOCUMENT IDENTIFIERS
  6749 | rfc6749 | RFC6749         An RFC        -> rfc6749.txt
  draft-ietf-oauth-v2-1            Latest draft  -> draft-ietf-oauth-v2-1.txt
  draft-ietf-oauth-v2-1-16         Exact draft   -> draft-ietf-oauth-v2-1-16.txt
  <file>=<https-url>               Any document  -> <file>

OPTIONS
  -d, --dir <path>        Directory holding the vendored files (default: .).
  -f, --file <path>       Read identifiers from a list file ('#' comments allowed;
                          so URLs cannot carry a #fragment).
  -c, --check             Compare local files with upstream; write nothing.
  -n, --dry-run           Print what would be fetched.
  -t, --timeout <secs>    Per-request timeout (default: 60).
  -q, --quiet             Suppress info logs (status lines remain).
  -v, --verbose           Print debug logs.
  -h, --help              Full help (examples, exit codes).
      --version           Print version.
```

Each document produces one status line on stdout — `<STATUS> <file> <detail>`
— and logs go to stderr, so the output can be piped or grepped:

| Mode | Statuses |
|---|---|
| fetch (default) | `ADDED`, `UPDATED`, `UNCHANGED`, `FAILED` |
| `--check` | `OK`, `DIFFERENT`, `MISSING`, `OUTDATED` (newer draft revision exists), `FAILED` |

#### Examples

```bash
# Vendor specific RFCs
./tools/fetch-specs.sh --dir references/rfc-sources 10017 10027 5849

# Track the latest OAuth 2.1 draft under a stable file name
./tools/fetch-specs.sh --dir references/rfc-sources draft-ietf-oauth-v2-1

# Pin two exact revisions side by side, then diff them
./tools/fetch-specs.sh --dir /tmp/oauth21 draft-ietf-oauth-v2-1-15 draft-ietf-oauth-v2-1-16
diff -u /tmp/oauth21/draft-ietf-oauth-v2-1-15.txt /tmp/oauth21/draft-ietf-oauth-v2-1-16.txt

# Vendor a non-IETF spec under a chosen local name
./tools/fetch-specs.sh --dir references/oidf-sources \
  oidc-core-1.0.html=https://openid.net/specs/openid-connect-core-1_0.html

# CI gate: fail the build when the vendored set drifts
./tools/fetch-specs.sh -q --check --dir references/rfc-sources \
  --file references/rfc-sources/manifest.txt || exit 1
```

#### Exit codes

| Code | Meaning |
|---|---|
| 0 | Success (`--check`: everything up to date) |
| 2 | Bad arguments |
| 3 | Missing dependency (`curl`, `cmp`; `python3` only for latest-draft lookup) |
| 4 | Unrecognized identifier, unreadable list file, or unwritable directory |
| 5 | A download or content verification failed |
| 6 | `--check` found a missing, different, or outdated document |
| 10 | Internal/runtime error |

#### Requirements

| Tool | Why | Where |
|---|---|---|
| `bash` (3.2+) | Script interpreter | macOS / Linux default |
| `curl` | Downloads (with retries and a timeout) | macOS / Linux default |
| `cmp` | Byte-for-byte comparison | macOS / Linux default |
| `python3` (optional) | Parse the Datatracker JSON for the latest draft revision | macOS / Linux default |

#### Design principles applied

- **Strict mode** and **documented exit codes**, as in `serve-swagger-ui.sh`
- **Fail fast**: every identifier is validated before any network access or write
- **Atomic writes**: downloads land in a hidden `.partial` file in the target
  directory, are verified, then renamed — an interrupted run never leaves a
  truncated RFC behind
- **Content verification**: an RFC must carry `Request for Comments: NNNN`
  (or the early-RFC `RFC: NNN`) in its header; a draft must name its exact
  `<name>-<rev>`; an `.html` document must contain an `<html>` element — so an
  error page or a wrong file saved with a 200 status is rejected
- **Read-only audit mode** (`--check`) suitable for CI
- **Idempotent**: re-running reports `UNCHANGED` and rewrites nothing

#### Troubleshooting

| Problem | Fix |
|---|---|
| `Unrecognized document identifier` | Use `6749` / `rfc6749`, a `draft-…` name (a trailing `-NN` is read as the revision), or `<file>=https://…` with a bare file name. |
| `FAILED … cannot resolve latest revision` | The draft name is wrong or Datatracker is unreachable; pass an exact `-NN` revision instead. |
| `header check failed` | Upstream returned something other than the document (maintenance page, wrong number). Retry, or inspect with `--verbose`. |
| `DIFFERENT` on a published RFC | Published RFC bytes never change — the local copy was edited or corrupted. Re-run without `--check` to restore it. |
| `DIFFERENT` on a `<file>=<url>` document | The publisher revised it in place (OIDF errata sets do this). Review the change, then re-run without `--check` and note the new revision in the folder README. |
