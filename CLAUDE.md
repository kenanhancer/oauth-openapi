# CLAUDE.md — oauth-openapi project conventions

This file is read automatically by Claude Code at session start. It captures the
conventions specific to this project so they don't have to be re-explained each
time.

## Purpose

This repository exists to **deeply understand OAuth 2.0 + OpenID Connect by
building a canonical spec from the source RFCs.** The working artifact is
`oauth-openapi.yaml` — a vendor-agnostic, RFC-canonical OpenAPI 3.1 description
of every grant type, endpoint, and modern extension through 2025.

The spec is the teaching aid, not the end goal. The intended workflow is:
read the relevant RFC (text vendored under `references/rfc-sources/`) → encode
the shape in YAML with `externalDocs` pointing back to the clause → cross-check
against `references/audit/rfc-audit-synthesis.md` → run `openapi-generator` to
scaffold a server in Python (FastAPI), Node.js (Express), C# (ASP.NET Core),
Java (Spring Boot), Go, etc., and see the protocol made concrete. Everything
else (`tools/`, `references/`, slash commands) exists to support that loop.

When suggesting changes, prefer explanations that tie each YAML edit back to
its RFC clause — the goal is learning the protocol, not just keeping the spec
file passing lint.

## Commit conventions

- **No AI attribution.** Never add `Co-Authored-By: Claude`, never add a
  `🤖 Generated with [Claude Code]` footer, never reference Claude in commit
  messages, PR titles, PR bodies, or branch names.
- Commit messages explain **why**, not **what** — the diff already shows what
  changed. Reach for context the diff cannot convey (motivation, alternative
  considered, tradeoff accepted).
- First line ≤ 72 characters; body wrapped at ~80; blank line between subject
  and body.

## Spec-change workflow

When editing `oauth-openapi.yaml`:

1. Make the change.
2. Run `/lint` (or `npx @stoplight/spectral-cli lint oauth-openapi.yaml`).
   **Must be 0 errors and 0 warnings before committing.**
3. Visually verify in at least one viewer (`/preview` opens all three:
   Redoc, Scalar, Swagger UI).
4. Stage the YAML and commit.

If `/lint` reports `oas3-unused-component`, decide whether to:
- delete the schema (preferred if it isn't really needed yet), or
- wire it into a real `$ref` (preferred if it has documentation value).

Do not silence the rule globally without thinking — the warning is usually a
signal that the schema is dead code.

## Repository conventions

- `oauth-openapi.yaml` — source of truth; modify only the YAML, never write
  a duplicate or "v2".
- `tools/` — generic developer scripts. Anything here should work in another
  project unchanged (drop the `.sh` into a sibling repo and run it). Each
  tool is documented in `tools/README.md`.
- `references/` — mixed, with different rules per area:
  - `ibm-api-connect-oauth.yaml`, `ybelenko-oauth2-endpoints.yaml` — historical
    community specs. **Read-only**; never overwrite or "fix" them — they
    document the past, not the present.
  - `rfc-sources/` — vendored canonical IETF RFC/draft text (every OAuth WG RFC
    plus the OAuth 2.1 draft). **Refreshable**: re-pull when a draft revises (see
    `rfc-sources/README.md`). Published RFC bytes never change; the OAuth 2.1
    draft does.
  - `oidf-sources/` — vendored OpenID Foundation specs (OpenID Connect Core /
    Discovery, the OAuth response-mode specs, and JARM). These are **not** RFCs
    (HTML published by the OpenID Foundation) and can be revised in place, so
    re-pull when auditing against a newer revision (see `oidf-sources/README.md`).
  - `rfc-validation/` and `audit/` (`rfc-audit-synthesis.md`,
    `live-idp-comparison.md`, `community-reference-specs.md`) — audit evidence;
    update when re-auditing.
- `.claude/` — Claude Code project config (permissions + slash commands).
  Do not add user-specific overrides; those go in `.claude/settings.local.json`.

## Tooling principles

- **Script-first**: when a workflow is repeated more than twice, write a
  script for it under `tools/` and document it in `tools/README.md`. Never
  paste long shell snippets into the README — reference the script instead.
- **Production-grade bash**: any script in `tools/` uses `set -euo pipefail`,
  `IFS=$'\n\t'`, a `trap` for cleanup, documented exit codes, a `--help`
  block with examples, and dependency checks. See `tools/serve-swagger-ui.sh`
  as the reference implementation.
- **Runbooks**: every script gets a section in `tools/README.md` explaining
  what it does, when to use it, and known caveats.

## Three viewers — when to use which

| Need | Tool |
|---|---|
| Read the spec like documentation | Redoc (`/preview` port 8765) |
| Modern API reference, search by Cmd+K | Scalar (`/preview` port 8767) |
| Classic "Try it out" + OAuth Authorize | Swagger UI (`/preview` port 8768) |

`/preview` starts all three for side-by-side comparison. `/preview-stop` kills
them.

## What NOT to add to this project

- Skills (`.claude/skills/`) — overkill for a single-spec repo; user-level skills
  cover broader workflows.
- Hooks (in `settings.json`) — pre-commit lint belongs in a real git hook
  (e.g. `pre-commit` framework or `.git/hooks/pre-commit`), not Claude hooks,
  so it works for non-Claude users too.
- Generated client SDKs and server scaffolds — the `generated/` directory is
  gitignored; never commit generator output.

## Out-of-scope reminders

- The deprecated OAuth 2.0 grants (Implicit, Resource Owner Password) are
  intentionally excluded per OAuth 2.1. Do not add them back.
- IBM-style vendor extensions (`x-ibm-*`, etc.) belong in vendor-specific
  forks, not in this canonical spec.
