#!/usr/bin/env bash
#
# serve-swagger-ui — spin up Swagger UI for any OpenAPI spec, on the fly.
#
# Generates a one-shot HTML bootstrap that loads `swagger-ui-dist` (the
# official SmartBear distribution package) from the unpkg.com CDN, then
# serves the bootstrap together with the spec via Python's built-in HTTP
# server. No persistent files are created in the spec's directory; the
# temp dir is removed on exit.
#
# This script is intentionally generic — drop it into any project that
# has an OpenAPI/Swagger spec and run it.
#
# Author:  oauth-openapi project
# License: CC-BY-4.0
#

# -----------------------------------------------------------------------------
# Strict mode
# -----------------------------------------------------------------------------
set -o errexit       # exit on first error
set -o nounset       # treat unset vars as error
set -o pipefail      # fail pipe if any command fails
IFS=$'\n\t'          # safer field splitting

# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_VERSION="1.0.0"

readonly DEFAULT_PORT="8765"
readonly DEFAULT_HOST="127.0.0.1"
readonly DEFAULT_SWAGGER_VERSION="5"

# Exit codes (documented in --help).
readonly EXIT_OK=0
readonly EXIT_USAGE=2
readonly EXIT_MISSING_DEP=3
readonly EXIT_BAD_INPUT=4
readonly EXIT_PORT_BUSY=5
readonly EXIT_RUNTIME=10

# -----------------------------------------------------------------------------
# Configuration globals (filled by parse_args)
# -----------------------------------------------------------------------------
SPEC_PATH=""
PORT="${PORT:-$DEFAULT_PORT}"
HOST="$DEFAULT_HOST"
SWAGGER_VERSION="$DEFAULT_SWAGGER_VERSION"
TITLE_OVERRIDE=""
OPEN_BROWSER=1
QUIET=0
VERBOSE=0

# Runtime globals (set during execution; cleaned up by trap).
TMP_DIR=""
SERVER_PID=""

# -----------------------------------------------------------------------------
# Logging — colored when stderr is a TTY and NO_COLOR is not set.
# -----------------------------------------------------------------------------
if [[ -t 2 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  readonly C_RED=$'\033[31m'
  readonly C_YELLOW=$'\033[33m'
  readonly C_GREEN=$'\033[32m'
  readonly C_BLUE=$'\033[34m'
  readonly C_DIM=$'\033[2m'
  readonly C_RESET=$'\033[0m'
else
  readonly C_RED='' C_YELLOW='' C_GREEN='' C_BLUE='' C_DIM='' C_RESET=''
fi

log_info()  { (( QUIET )) || printf "%s[INFO]%s  %s\n"  "$C_BLUE"   "$C_RESET" "$*" >&2; }
log_ok()    { (( QUIET )) || printf "%s[OK]%s    %s\n"  "$C_GREEN"  "$C_RESET" "$*" >&2; }
log_warn()  { printf "%s[WARN]%s  %s\n"  "$C_YELLOW" "$C_RESET" "$*" >&2; }
log_error() { printf "%s[ERROR]%s %s\n"  "$C_RED"    "$C_RESET" "$*" >&2; }
log_debug() { (( VERBOSE )) && printf "%s[DEBUG]%s %s\n" "$C_DIM" "$C_RESET" "$*" >&2 || true; }

die() {
  # die <exit-code> <message...>
  local code="${1:-$EXIT_RUNTIME}"; shift
  log_error "$*"
  exit "$code"
}

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------
print_help() {
  cat <<EOF
${SCRIPT_NAME} v${SCRIPT_VERSION}

Spin up Swagger UI for an OpenAPI spec on the fly.

Generates a temporary HTML bootstrap that loads swagger-ui-dist (the official
SmartBear distribution) from the unpkg.com CDN and serves it via Python's
built-in HTTP server. The temp directory is removed on exit; no files are
written into your project.

USAGE
  ${SCRIPT_NAME} <spec> [options]
  ${SCRIPT_NAME} --help | --version

ARGUMENTS
  <spec>                       Path to an OpenAPI YAML or JSON file.

OPTIONS
  -p, --port <number>          Port to bind. Default: ${DEFAULT_PORT} (or \$PORT env var).
  -H, --host <addr>            Address to bind. Default: ${DEFAULT_HOST}.
      --swagger-version <v>    Major version of swagger-ui-dist to load.
                               Default: ${DEFAULT_SWAGGER_VERSION}. Pin to '4' for legacy specs.
      --title <text>           Browser tab title. Default: derived from spec filename.
      --no-open                Do not open the URL in a browser.
  -q, --quiet                  Suppress informational output.
  -v, --verbose                Print debug output.
  -h, --help                   Show this help and exit.
      --version                Print version and exit.

ENVIRONMENT VARIABLES
  PORT                         Equivalent to --port.
  NO_COLOR                     Disable colored output if set (any value).
  BROWSER                      Override the browser opener command. Defaults
                               to 'open' on macOS, 'xdg-open' on Linux.

EXAMPLES
  ${SCRIPT_NAME} ./openapi.yaml
      Serve at http://${DEFAULT_HOST}:${DEFAULT_PORT}/ and open in browser.

  ${SCRIPT_NAME} ./openapi.yaml --port 9000 --no-open
      Custom port, do not auto-open.

  ${SCRIPT_NAME} ./openapi.yaml --swagger-version 4
      Pin to swagger-ui-dist@4 instead of @5.

  PORT=8888 ${SCRIPT_NAME} ./openapi.json
      Use the PORT environment variable.

  ${SCRIPT_NAME} ./openapi.yaml --quiet --no-open &
      Run silently in the background; remember to kill the script later.

EXIT CODES
  ${EXIT_OK}  Success
  ${EXIT_USAGE}  Bad arguments
  ${EXIT_MISSING_DEP}  Required dependency missing (python3)
  ${EXIT_BAD_INPUT}  Spec file not found or unreadable
  ${EXIT_PORT_BUSY}  Requested port is already in use
  ${EXIT_RUNTIME} Internal/runtime error

REQUIREMENTS
  - python3 (for the HTTP server)
  - Internet access for the first browser load (Swagger UI assets via CDN)

SEE ALSO
  - swagger-ui-dist:  https://www.npmjs.com/package/swagger-ui-dist
  - OpenAPI spec:     https://www.openapis.org/
EOF
}

# -----------------------------------------------------------------------------
# Argument parsing — simple long-and-short option loop. No external libs.
# -----------------------------------------------------------------------------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)              print_help; exit "$EXIT_OK" ;;
      --version)              printf "%s %s\n" "$SCRIPT_NAME" "$SCRIPT_VERSION"; exit "$EXIT_OK" ;;
      -p|--port)              [[ $# -ge 2 ]] || die "$EXIT_USAGE" "--port requires a value"
                              PORT="$2"; shift 2 ;;
      -H|--host)              [[ $# -ge 2 ]] || die "$EXIT_USAGE" "--host requires a value"
                              HOST="$2"; shift 2 ;;
      --swagger-version)      [[ $# -ge 2 ]] || die "$EXIT_USAGE" "--swagger-version requires a value"
                              SWAGGER_VERSION="$2"; shift 2 ;;
      --title)                [[ $# -ge 2 ]] || die "$EXIT_USAGE" "--title requires a value"
                              TITLE_OVERRIDE="$2"; shift 2 ;;
      --no-open)              OPEN_BROWSER=0; shift ;;
      -q|--quiet)             QUIET=1; shift ;;
      -v|--verbose)           VERBOSE=1; shift ;;
      --)                     shift; break ;;
      -*)                     die "$EXIT_USAGE" "Unknown option: $1 (use --help)" ;;
      *)
        if [[ -z "$SPEC_PATH" ]]; then
          SPEC_PATH="$1"
          shift
        else
          die "$EXIT_USAGE" "Unexpected positional argument: $1"
        fi
        ;;
    esac
  done

  [[ -n "$SPEC_PATH" ]] || die "$EXIT_USAGE" "Missing required argument: <spec> (use --help)"
}

# -----------------------------------------------------------------------------
# Validation — fail fast with a clear message.
# -----------------------------------------------------------------------------
require_command() {
  command -v "$1" >/dev/null 2>&1 \
    || die "$EXIT_MISSING_DEP" "Required command not found: $1"
}

validate_spec() {
  [[ -f "$SPEC_PATH" ]] || die "$EXIT_BAD_INPUT" "Spec file not found: $SPEC_PATH"
  [[ -r "$SPEC_PATH" ]] || die "$EXIT_BAD_INPUT" "Spec file not readable: $SPEC_PATH"
  case "$SPEC_PATH" in
    *.yaml|*.yml|*.json) : ;;
    *) log_warn "Spec extension is not .yaml/.yml/.json — Swagger UI may fail to parse." ;;
  esac
}

validate_port() {
  [[ "$PORT" =~ ^[0-9]+$ ]] || die "$EXIT_USAGE" "Port must be an integer: $PORT"
  (( PORT >= 1 && PORT <= 65535 )) || die "$EXIT_USAGE" "Port out of range (1-65535): $PORT"

  if command -v lsof >/dev/null 2>&1; then
    if lsof -iTCP:"$PORT" -sTCP:LISTEN -P -n >/dev/null 2>&1; then
      die "$EXIT_PORT_BUSY" "Port $PORT is already in use (try another with --port)"
    fi
  fi
}

validate_swagger_version() {
  [[ "$SWAGGER_VERSION" =~ ^[0-9]+$ ]] \
    || die "$EXIT_USAGE" "--swagger-version must be a major-version integer (e.g. 5)"
}

# -----------------------------------------------------------------------------
# Cleanup — invoked from trap. Idempotent.
# -----------------------------------------------------------------------------
cleanup() {
  local exit_code=$?
  trap - EXIT INT TERM

  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    log_debug "Stopping HTTP server (pid $SERVER_PID)"
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi

  if [[ -n "$TMP_DIR" ]] && [[ -d "$TMP_DIR" ]]; then
    log_debug "Removing temp dir: $TMP_DIR"
    rm -rf "$TMP_DIR"
  fi

  exit "$exit_code"
}

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
resolve_abs_path() {
  # Cross-platform absolute path (no realpath/readlink -f assumption).
  local path="$1"
  local dir base
  dir="$(cd "$(dirname "$path")" && pwd)"
  base="$(basename "$path")"
  printf "%s/%s" "$dir" "$base"
}

# Encode an arbitrary string as a JSON string literal — safe to embed in JS.
# Uses python (already a hard dependency).
js_quote() {
  python3 -c 'import json,sys; sys.stdout.write(json.dumps(sys.argv[1]))' "$1"
}

# Wait for the HTTP server to actually start listening (instead of `sleep N`).
wait_for_port() {
  local host="$1" port="$2" timeout="${3:-5}" elapsed=0
  while (( elapsed < timeout * 10 )); do
    if command -v nc >/dev/null 2>&1; then
      nc -z "$host" "$port" 2>/dev/null && return 0
    elif command -v lsof >/dev/null 2>&1; then
      lsof -iTCP:"$port" -sTCP:LISTEN -P -n >/dev/null 2>&1 && return 0
    else
      # No probe tool — fall back to a short fixed wait.
      sleep 0.5
      return 0
    fi
    sleep 0.1
    elapsed=$(( elapsed + 1 ))
  done
  return 1
}

generate_html() {
  local spec_filename_quoted="$1"   # already JS-quoted (includes surrounding quotes)
  local title="$2"
  local out_path="$3"
  local cdn="https://unpkg.com/swagger-ui-dist@${SWAGGER_VERSION}"

  cat > "$out_path" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>${title}</title>
  <link rel="stylesheet" href="${cdn}/swagger-ui.css">
  <link rel="icon" type="image/png" href="${cdn}/favicon-32x32.png">
  <style>
    html { box-sizing: border-box; overflow-y: scroll; }
    *, *:before, *:after { box-sizing: inherit; }
    body { margin: 0; background: #fafafa; }
  </style>
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="${cdn}/swagger-ui-bundle.js" charset="UTF-8"></script>
  <script src="${cdn}/swagger-ui-standalone-preset.js" charset="UTF-8"></script>
  <script>
    window.onload = function () {
      window.ui = SwaggerUIBundle({
        url: ${spec_filename_quoted},
        dom_id: '#swagger-ui',
        deepLinking: true,
        tryItOutEnabled: true,
        displayRequestDuration: true,
        filter: true,
        persistAuthorization: true,
        presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
        plugins: [SwaggerUIBundle.plugins.DownloadUrl],
        layout: 'StandaloneLayout'
      });
    };
  </script>
</body>
</html>
EOF
}

open_browser() {
  local url="$1"
  local opener="${BROWSER:-}"

  if [[ -z "$opener" ]]; then
    case "$(uname -s)" in
      Darwin) opener="open" ;;
      Linux)  opener="xdg-open" ;;
      *)      log_warn "No known browser opener for $(uname -s); skipping"; return 0 ;;
    esac
  fi

  if ! command -v "$opener" >/dev/null 2>&1; then
    log_warn "Browser opener not found in PATH: $opener"
    return 0
  fi

  log_debug "Opening browser via: $opener $url"
  "$opener" "$url" >/dev/null 2>&1 \
    || log_warn "Browser opener exited non-zero; open the URL manually."
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
  parse_args "$@"

  require_command python3
  validate_swagger_version
  validate_spec
  validate_port

  local spec_abs spec_filename spec_filename_quoted title
  spec_abs="$(resolve_abs_path "$SPEC_PATH")"
  spec_filename="$(basename "$SPEC_PATH")"
  spec_filename_quoted="$(js_quote "$spec_filename")"
  title="${TITLE_OVERRIDE:-Swagger UI — $spec_filename}"

  TMP_DIR="$(mktemp -d -t swagger-ui-XXXXXX)"
  trap cleanup EXIT INT TERM
  log_debug "Temp dir: $TMP_DIR"

  ln -s "$spec_abs" "$TMP_DIR/$spec_filename"
  generate_html "$spec_filename_quoted" "$title" "$TMP_DIR/index.html"

  local url="http://${HOST}:${PORT}/"

  log_info "Spec:  $spec_abs"
  log_info "URL:   $url"
  log_info "Title: $title"

  python3 -m http.server "$PORT" --directory "$TMP_DIR" --bind "$HOST" \
    >/dev/null 2>&1 &
  SERVER_PID=$!

  if ! wait_for_port "$HOST" "$PORT" 5; then
    die "$EXIT_RUNTIME" "HTTP server did not start listening on ${HOST}:${PORT}"
  fi
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    die "$EXIT_RUNTIME" "HTTP server exited unexpectedly"
  fi

  log_ok "Serving Swagger UI. Press Ctrl+C to stop."

  if (( OPEN_BROWSER )); then
    open_browser "$url"
  fi

  # Block on the server. Cleanup runs via trap on exit/signal.
  wait "$SERVER_PID"
}

main "$@"
