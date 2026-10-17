#!/usr/bin/env bash
#
# fetch-specs — vendor specification documents (IETF RFCs, Internet-Drafts,
# and any other spec published at a stable URL), and check vendored copies for
# drift against the canonical upstream.
#
# RFCs are fetched from https://www.rfc-editor.org/rfc/rfcNNNN.txt (published
# RFC bytes never change, so a vendored RFC only "drifts" if it was corrupted
# or hand-edited). Internet-Drafts are fetched from
# https://www.ietf.org/archive/id/<name>-<rev>.txt; when no revision is given,
# the latest one is resolved through the IETF Datatracker API and the file is
# stored under the unversioned name, so it can be refreshed in place. Any other
# document (e.g. an OpenID Foundation spec, which can be revised in place) is
# named as <file>=<https-url>.
#
# This script is intentionally generic — drop it into any project that keeps
# local copies of specifications and run it.
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

readonly RFC_BASE_URL="https://www.rfc-editor.org/rfc"
readonly DRAFT_BASE_URL="https://www.ietf.org/archive/id"
readonly DATATRACKER_DOC_API="https://datatracker.ietf.org/api/v1/doc/document"
readonly DEFAULT_TIMEOUT="60"

# Exit codes (documented in --help).
readonly EXIT_OK=0
readonly EXIT_USAGE=2
readonly EXIT_MISSING_DEP=3
readonly EXIT_BAD_INPUT=4
readonly EXIT_FETCH_FAILED=5
readonly EXIT_DRIFT=6
readonly EXIT_RUNTIME=10

# -----------------------------------------------------------------------------
# Configuration globals (filled by parse_args)
# -----------------------------------------------------------------------------
OUT_DIR="."
LIST_FILE=""
CHECK_MODE=0
DRY_RUN=0
TIMEOUT="$DEFAULT_TIMEOUT"
QUIET=0
VERBOSE=0
DOC_IDS=()

# Runtime globals (set during execution; cleaned up by trap).
TMP_DIR=""
PARTIAL_FILE=""

# Result of normalize_doc (one document at a time).
DOC_KIND=""      # rfc | draft | url
DOC_NAME=""      # rfc6749 | draft-ietf-oauth-v2-1 | <file> for url documents
DOC_REV=""       # draft revision ("16"), empty for RFCs and for "latest"
DOC_FILE=""      # local file name, e.g. rfc6749.txt
DOC_URL=""       # upstream URL for url documents

# Tallies for the summary line.
N_ADDED=0
N_UPDATED=0
N_UNCHANGED=0
N_OK=0
N_DRIFT=0
N_FAILED=0

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

# One machine-readable status line per document on stdout:
#   <STATUS> <file> <detail>
report() {
  printf "%-10s %-36s %s\n" "$1" "$2" "${3:-}"
}

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------
print_help() {
  cat <<EOF
${SCRIPT_NAME} v${SCRIPT_VERSION}

Vendor IETF RFCs, Internet-Drafts and other specification documents, or check
vendored copies for drift against the canonical upstream.

USAGE
  ${SCRIPT_NAME} [options] <doc>...
  ${SCRIPT_NAME} [options] --file <list>
  ${SCRIPT_NAME} --help | --version

DOCUMENT IDENTIFIERS
  6749 | rfc6749 | RFC6749         An RFC        -> rfc6749.txt
  draft-ietf-oauth-v2-1            Latest draft  -> draft-ietf-oauth-v2-1.txt
                                   (revision resolved via the Datatracker API)
  draft-ietf-oauth-v2-1-16         Exact draft   -> draft-ietf-oauth-v2-1-16.txt
  <file>=<https-url>               Any document  -> <file>
  A trailing "-NN" (exactly two digits) is read as the draft revision.
  <file> is a bare file name ([A-Za-z0-9._-], no directories).

OPTIONS
  -d, --dir <path>        Directory holding the vendored files. Default: .
  -f, --file <path>       Read identifiers from a list file (one per line;
                          '#' starts a comment, so URLs cannot carry a
                          #fragment; blank lines are ignored). May be combined
                          with identifiers on the command line.
  -c, --check             Do not write anything. Compare each local file with
                          upstream and report OK / DIFFERENT / MISSING /
                          OUTDATED (a newer draft revision exists).
  -n, --dry-run           Print what would be fetched, without network writes.
  -t, --timeout <secs>    Per-request timeout. Default: ${DEFAULT_TIMEOUT}.
  -q, --quiet             Suppress informational logs (status lines remain).
  -v, --verbose           Print debug output.
  -h, --help              Show this help and exit.
      --version           Print version and exit.

OUTPUT
  One status line per document on stdout ("<STATUS> <file> <detail>"); logs
  go to stderr. Fetch mode statuses: ADDED, UPDATED, UNCHANGED, FAILED.
  Check mode statuses: OK, DIFFERENT, MISSING, OUTDATED, FAILED.
  Files are written atomically (downloaded to a hidden partial file in the
  target directory, verified, then renamed).

VERIFICATION
  RFC files must contain "Request for Comments: NNNN" (or the early-RFC form
  "RFC: NNN") in their first 60 lines.
  Draft files must name the expected "<draft>-<rev>" in their first 60 lines.
  Other documents must be non-empty; .html/.htm files must contain an <html>
  element (catches truncated or non-HTML responses).

EXAMPLES
  ${SCRIPT_NAME} --dir references/rfc-sources 6749 6750 9700
      Vendor three RFCs into references/rfc-sources/.

  ${SCRIPT_NAME} --dir references/rfc-sources --file references/rfc-sources/manifest.txt
      Fetch every document listed in a manifest (refresh in place).

  ${SCRIPT_NAME} --dir references/rfc-sources --file references/rfc-sources/manifest.txt --check
      Audit the vendored set: exit ${EXIT_DRIFT} if anything is missing, differs, or a
      newer draft revision exists. Suitable for CI.

  ${SCRIPT_NAME} --dir /tmp/drafts draft-ietf-oauth-v2-1-15 draft-ietf-oauth-v2-1-16
      Fetch two exact draft revisions side by side (e.g., to diff them).

  ${SCRIPT_NAME} --dir references/oidf-sources \
      oidc-core-1.0.html=https://openid.net/specs/openid-connect-core-1_0.html
      Vendor a non-IETF spec under a chosen local file name.

EXIT CODES
  ${EXIT_OK}  Success (check mode: everything up to date)
  ${EXIT_USAGE}  Bad arguments
  ${EXIT_MISSING_DEP}  Required dependency missing (curl, cmp; python3 for latest-draft lookup)
  ${EXIT_BAD_INPUT}  Unrecognized identifier, unreadable list file, or unwritable directory
  ${EXIT_FETCH_FAILED}  A download or content verification failed
  ${EXIT_DRIFT}  Check mode found a missing, different or outdated document
  ${EXIT_RUNTIME} Internal/runtime error

REQUIREMENTS
  - curl, cmp (macOS / Linux default)
  - python3 (only to resolve the latest revision of an unversioned draft)
  - Internet access to rfc-editor.org, ietf.org and datatracker.ietf.org
    (plus the hosts of any <file>=<url> documents)

SEE ALSO
  - RFC Editor:   https://www.rfc-editor.org/
  - Datatracker:  https://datatracker.ietf.org/
EOF
}

# -----------------------------------------------------------------------------
# Argument parsing — simple long-and-short option loop. No external libs.
# -----------------------------------------------------------------------------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)      print_help; exit "$EXIT_OK" ;;
      --version)      printf "%s %s\n" "$SCRIPT_NAME" "$SCRIPT_VERSION"; exit "$EXIT_OK" ;;
      -d|--dir)       [[ $# -ge 2 ]] || die "$EXIT_USAGE" "--dir requires a value"
                      OUT_DIR="$2"; shift 2 ;;
      -f|--file)      [[ $# -ge 2 ]] || die "$EXIT_USAGE" "--file requires a value"
                      LIST_FILE="$2"; shift 2 ;;
      -c|--check)     CHECK_MODE=1; shift ;;
      -n|--dry-run)   DRY_RUN=1; shift ;;
      -t|--timeout)   [[ $# -ge 2 ]] || die "$EXIT_USAGE" "--timeout requires a value"
                      TIMEOUT="$2"; shift 2 ;;
      -q|--quiet)     QUIET=1; shift ;;
      -v|--verbose)   VERBOSE=1; shift ;;
      --)             shift; while [[ $# -gt 0 ]]; do DOC_IDS+=("$1"); shift; done ;;
      -*)             die "$EXIT_USAGE" "Unknown option: $1 (use --help)" ;;
      *)              DOC_IDS+=("$1"); shift ;;
    esac
  done

  [[ "$TIMEOUT" =~ ^[0-9]+$ ]] || die "$EXIT_USAGE" "--timeout must be an integer: $TIMEOUT"
  (( CHECK_MODE && DRY_RUN )) && die "$EXIT_USAGE" "--check and --dry-run are mutually exclusive"
  return 0
}

# -----------------------------------------------------------------------------
# Validation — fail fast with a clear message.
# -----------------------------------------------------------------------------
require_command() {
  command -v "$1" >/dev/null 2>&1 \
    || die "$EXIT_MISSING_DEP" "Required command not found: $1"
}

load_list_file() {
  [[ -n "$LIST_FILE" ]] || return 0
  [[ -f "$LIST_FILE" && -r "$LIST_FILE" ]] || die "$EXIT_BAD_INPUT" "List file not readable: $LIST_FILE"
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"                                   # strip comments
    line="$(printf "%s" "$line" | tr -d '[:space:]')"   # strip whitespace
    [[ -n "$line" ]] && DOC_IDS+=("$line")
  done < "$LIST_FILE"
  return 0
}

validate_out_dir() {
  if (( CHECK_MODE )); then
    [[ -d "$OUT_DIR" ]] || die "$EXIT_BAD_INPUT" "Directory not found: $OUT_DIR"
  elif (( ! DRY_RUN )); then
    mkdir -p "$OUT_DIR" 2>/dev/null || die "$EXIT_BAD_INPUT" "Cannot create directory: $OUT_DIR"
    [[ -w "$OUT_DIR" ]] || die "$EXIT_BAD_INPUT" "Directory not writable: $OUT_DIR"
  fi
}

# normalize_doc <identifier> — sets DOC_KIND, DOC_NAME, DOC_REV, DOC_FILE.
# Returns non-zero for an unrecognized identifier.
normalize_doc() {
  local id lower
  id="$1"
  DOC_KIND="" DOC_NAME="" DOC_REV="" DOC_FILE="" DOC_URL=""

  # <file>=<https-url> — checked before lowercasing: names and URLs are case-sensitive.
  if [[ "$id" == *=* ]]; then
    DOC_FILE="${id%%=*}"
    DOC_URL="${id#*=}"
    [[ "$DOC_FILE" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || return 1
    [[ "$DOC_URL" =~ ^https://[^[:space:]]+$ ]] || return 1
    DOC_KIND="url"
    DOC_NAME="$DOC_FILE"
    return 0
  fi

  lower="$(printf "%s" "$id" | tr '[:upper:]' '[:lower:]')"
  lower="${lower%.txt}"

  if [[ "$lower" =~ ^(rfc)?([0-9]{1,6})$ ]] && (( 10#${BASH_REMATCH[2]} > 0 )); then
    DOC_KIND="rfc"
    DOC_NAME="rfc$((10#${BASH_REMATCH[2]}))"   # drop leading zeros
    DOC_FILE="${DOC_NAME}.txt"
  elif [[ "$lower" =~ ^(draft-[a-z0-9-]+)-([0-9]{2})$ ]]; then
    DOC_KIND="draft"
    DOC_NAME="${BASH_REMATCH[1]}"
    DOC_REV="${BASH_REMATCH[2]}"
    DOC_FILE="${DOC_NAME}-${DOC_REV}.txt"
  elif [[ "$lower" =~ ^draft-[a-z0-9-]+$ ]]; then
    DOC_KIND="draft"
    DOC_NAME="$lower"
    DOC_FILE="${DOC_NAME}.txt"
  else
    return 1
  fi
  return 0
}

# -----------------------------------------------------------------------------
# Cleanup — invoked from trap. Idempotent.
# -----------------------------------------------------------------------------
cleanup() {
  local exit_code=$?
  trap - EXIT INT TERM

  if [[ -n "$PARTIAL_FILE" ]] && [[ -f "$PARTIAL_FILE" ]]; then
    log_debug "Removing partial file: $PARTIAL_FILE"
    rm -f "$PARTIAL_FILE"
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
# http_get <url> <dest> — download with retries; non-zero on HTTP/network error.
http_get() {
  log_debug "GET $1"
  curl --fail --silent --show-error --location \
       --retry 2 --retry-delay 2 --max-time "$TIMEOUT" \
       --output "$2" "$1"
}

# latest_draft_rev <draft-name> — print the current revision from Datatracker.
latest_draft_rev() {
  require_command python3
  local json="$TMP_DIR/datatracker.json"
  http_get "${DATATRACKER_DOC_API}/$1/?format=json" "$json" || return 1
  python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["rev"])' "$json"
}

# local_draft_rev <file> <draft-name> — revision named in a vendored draft.
local_draft_rev() {
  head -n 60 "$1" | grep -oE "$2-[0-9]{2}" | sed -n -E '1s/.*-([0-9]{2})$/\1/p'
}

# verify_content <file> — check the downloaded text is the expected document.
verify_content() {
  local file="$1"
  [[ -s "$file" ]] || { log_error "Empty download: $DOC_FILE"; return 1; }
  if [[ "$DOC_KIND" == "url" ]]; then
    case "$DOC_FILE" in
      *.html|*.htm)
        head -c 65536 "$file" | grep -iE "<html|<!doctype html" >/dev/null \
          || { log_error "$DOC_FILE is not HTML (content check failed)"; return 1; } ;;
    esac
  elif [[ "$DOC_KIND" == "rfc" ]]; then
    local num="${DOC_NAME#rfc}"
    # Modern RFCs say "Request for Comments: NNNN"; early ones say "RFC: NNN".
    head -n 60 "$file" | grep -E "(Request for Comments|RFC): *0*${num}([^0-9]|$)" >/dev/null \
      || { log_error "$DOC_FILE does not look like RFC ${num} (header check failed)"; return 1; }
  else
    head -n 60 "$file" | grep -F "${DOC_NAME}-${DOC_REV}" >/dev/null \
      || { log_error "$DOC_FILE does not name ${DOC_NAME}-${DOC_REV} (header check failed)"; return 1; }
  fi
  return 0
}

# upstream_url — URL for the current DOC_* (DOC_REV must be resolved).
upstream_url() {
  if [[ "$DOC_KIND" == "url" ]]; then
    printf "%s" "$DOC_URL"
  elif [[ "$DOC_KIND" == "rfc" ]]; then
    printf "%s/%s.txt" "$RFC_BASE_URL" "$DOC_NAME"
  else
    printf "%s/%s-%s.txt" "$DRAFT_BASE_URL" "$DOC_NAME" "$DOC_REV"
  fi
}

# -----------------------------------------------------------------------------
# Per-document actions
# -----------------------------------------------------------------------------
fetch_doc() {
  local dest="$OUT_DIR/$DOC_FILE" url
  url="$(upstream_url)"

  if (( DRY_RUN )); then
    report "WOULD-GET" "$DOC_FILE" "$url"
    return 0
  fi

  PARTIAL_FILE="$OUT_DIR/.${DOC_FILE}.partial"
  if ! http_get "$url" "$PARTIAL_FILE" || ! verify_content "$PARTIAL_FILE"; then
    rm -f "$PARTIAL_FILE"; PARTIAL_FILE=""
    report "FAILED" "$DOC_FILE" "$url"
    N_FAILED=$((N_FAILED + 1))
    return 0
  fi

  if [[ -f "$dest" ]] && cmp -s "$PARTIAL_FILE" "$dest"; then
    rm -f "$PARTIAL_FILE"; PARTIAL_FILE=""
    report "UNCHANGED" "$DOC_FILE" "$url"
    N_UNCHANGED=$((N_UNCHANGED + 1))
  elif [[ -f "$dest" ]]; then
    mv -f "$PARTIAL_FILE" "$dest"; PARTIAL_FILE=""
    report "UPDATED" "$DOC_FILE" "$url"
    N_UPDATED=$((N_UPDATED + 1))
  else
    mv -f "$PARTIAL_FILE" "$dest"; PARTIAL_FILE=""
    report "ADDED" "$DOC_FILE" "$url"
    N_ADDED=$((N_ADDED + 1))
  fi
}

check_doc() {
  local dest="$OUT_DIR/$DOC_FILE" upstream="$TMP_DIR/upstream.txt" url
  url="$(upstream_url)"

  if [[ ! -f "$dest" ]]; then
    report "MISSING" "$DOC_FILE" "$url"
    N_DRIFT=$((N_DRIFT + 1))
    return 0
  fi

  if ! http_get "$url" "$upstream" || ! verify_content "$upstream"; then
    report "FAILED" "$DOC_FILE" "$url"
    N_FAILED=$((N_FAILED + 1))
    return 0
  fi

  if cmp -s "$upstream" "$dest"; then
    report "OK" "$DOC_FILE" "$url"
    N_OK=$((N_OK + 1))
  else
    report "DIFFERENT" "$DOC_FILE" "$url"
    N_DRIFT=$((N_DRIFT + 1))
  fi
}

process_doc() {
  local id="$1" explicit_rev local_rev
  if ! normalize_doc "$id"; then
    die "$EXIT_BAD_INPUT" "Unrecognized document identifier: $id"
  fi
  explicit_rev="$DOC_REV"

  # Unversioned draft: resolve the latest revision from Datatracker.
  if [[ "$DOC_KIND" == "draft" && -z "$explicit_rev" ]]; then
    if ! DOC_REV="$(latest_draft_rev "$DOC_NAME")" || [[ -z "$DOC_REV" ]]; then
      report "FAILED" "$DOC_FILE" "cannot resolve latest revision of $DOC_NAME"
      N_FAILED=$((N_FAILED + 1))
      return 0
    fi
    log_debug "$DOC_NAME latest revision: -$DOC_REV"

    if (( CHECK_MODE )) && [[ -f "$OUT_DIR/$DOC_FILE" ]]; then
      local_rev="$(local_draft_rev "$OUT_DIR/$DOC_FILE" "$DOC_NAME" || true)"
      if [[ -n "$local_rev" && "$local_rev" != "$DOC_REV" ]]; then
        report "OUTDATED" "$DOC_FILE" "local -${local_rev}, latest -${DOC_REV}"
        N_DRIFT=$((N_DRIFT + 1))
        return 0
      fi
    fi
  fi

  if (( CHECK_MODE )); then check_doc; else fetch_doc; fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
  parse_args "$@"
  load_list_file

  [[ ${#DOC_IDS[@]} -gt 0 ]] || die "$EXIT_USAGE" "No documents given (pass identifiers or --file; see --help)"

  require_command curl
  require_command cmp
  # Validate every identifier before any network access or file write.
  local id needs_python=0
  for id in "${DOC_IDS[@]}"; do
    normalize_doc "$id" || die "$EXIT_BAD_INPUT" "Unrecognized document identifier: $id"
    # python3 is needed only to resolve the latest revision of an unversioned draft.
    [[ "$DOC_KIND" == "draft" && -z "$DOC_REV" ]] && needs_python=1
  done
  (( needs_python )) && require_command python3
  validate_out_dir

  TMP_DIR="$(mktemp -d -t fetch-specs-XXXXXX)"
  trap cleanup EXIT INT TERM
  log_debug "Temp dir: $TMP_DIR"

  if (( CHECK_MODE )); then
    log_info "Checking ${#DOC_IDS[@]} document(s) in $OUT_DIR against upstream"
  else
    log_info "Fetching ${#DOC_IDS[@]} document(s) into $OUT_DIR"
  fi

  for id in "${DOC_IDS[@]}"; do
    process_doc "$id"
  done

  if (( CHECK_MODE )); then
    log_info "Summary: ${N_OK} ok, ${N_DRIFT} drifted/missing, ${N_FAILED} failed"
  elif (( ! DRY_RUN )); then
    log_info "Summary: ${N_ADDED} added, ${N_UPDATED} updated, ${N_UNCHANGED} unchanged, ${N_FAILED} failed"
  fi

  (( N_FAILED == 0 )) || exit "$EXIT_FETCH_FAILED"
  (( N_DRIFT == 0 ))  || exit "$EXIT_DRIFT"
  log_ok "Done."
  exit "$EXIT_OK"
}

main "$@"
