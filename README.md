# oauth-openapi

A vendor-agnostic, RFC-canonical OpenAPI 3.1 specification of the OAuth 2.0 +
OpenID Connect authorization-server protocol surface.

## Learning goal

The primary aim of this repository is **to deeply understand OAuth 2.0 grant
types and flows** by working through the authoritative IETF RFCs, distilling
them into a single machine-readable spec, and turning that spec into running
server scaffolds in multiple languages.

The arc is three steps:

1. **Read the RFCs.** Canonical source text is vendored under
   `references/rfc-sources/` so each part of the spec can be cross-checked
   against authoritative material. `references/audit/rfc-audit-synthesis.md` walks
   through the audit that reconciled the spec against 20 RFCs and related
   specs.
2. **Encode the protocol.** Every endpoint, parameter, grant type, and error
   response is a typed YAML entry in `oauth-openapi.yaml`, with `externalDocs`
   pointing back to the RFC clause that justifies it.
3. **Generate servers.** A single `openapi-generator` command turns the spec
   into a FastAPI / Express / ASP.NET Core / Spring Boot / Go server scaffold
   — making the protocol concrete enough to run and inspect, not just read
   about. See [Generate servers and clients](#generate-servers-and-clients)
   below.

The spec is the teaching aid; the generated servers are the final proof that
the model is faithful to the standard.

## Why this exists

There is no official OpenAPI specification for OAuth 2.0. RFC 6749 was published
in 2012 — before OpenAPI / Swagger became a mature standard — so the OAuth
working group never produced one. The two community attempts that exist are both
**five years stale and miss every modern extension:**

- IBM's `api-connect-oauth-tutorial` (Swagger 2.0, archived in 2021)
- ybelenko's `oauth2_as_oas3_components` (OpenAPI 3.0.2, no commits since 2021)

Both are kept here under `references/` for comparison. See
[`references/audit/community-reference-specs.md`](references/audit/community-reference-specs.md)
for what each covers and what each misses.

This project is a fresh OpenAPI 3.1 spec that:

- Is built directly from the relevant IETF RFCs (each endpoint and field links
  to its source via `externalDocs`)
- Covers OAuth 2.0 + OIDC + every modern extension through 2025
- Applies OAuth 2.1 defaults (PKCE mandatory, Implicit and Password grants
  excluded)
- Is vendor-agnostic — change the `issuer` server variable and it retargets to
  any compliant authorization server

## What's covered

`oauth-openapi.yaml` describes:

### Endpoints

| Path | Spec | Purpose |
|---|---|---|
| `GET /authorize` | RFC 6749 §4.1.1, OIDC Core §3.1.2.1 | Browser-driven authorization request |
| `POST /token` | RFC 6749 §3.2 | Token issuance — all grants via `grant_type` discriminator |
| `POST /revoke` | RFC 7009 | Revoke an access or refresh token |
| `POST /introspect` | RFC 7662 | Inspect token state, scopes, subject |
| `POST /device_authorization` | RFC 8628 §3.1 | Start the device-code flow |
| `POST /par` | RFC 9126 | Pushed Authorization Request |
| `GET /userinfo` | OIDC Core §5.3 | Standard OIDC user claims |
| `POST /userinfo` | OIDC Core §5.3.1 | Same, via POST |
| `GET /jwks` | RFC 7517 | Public signing keys |
| `GET /.well-known/openid-configuration` | OIDC Discovery 1.0 | OIDC provider metadata |
| `GET /.well-known/oauth-authorization-server` | RFC 8414 | OAuth-only provider metadata |
| `GET /.well-known/oauth-protected-resource` | RFC 9728 | Protected-resource metadata |

### Grant types modeled

All current grants supported by OAuth 2.1, with full request/response schemas:

- `authorization_code` (RFC 6749 §4.1.3, with PKCE per RFC 7636)
- `client_credentials` (RFC 6749 §4.4)
- `refresh_token` (RFC 6749 §6)
- `urn:ietf:params:oauth:grant-type:device_code` (RFC 8628 §3.4)
- `urn:ietf:params:oauth:grant-type:jwt-bearer` (RFC 7523)
- `urn:ietf:params:oauth:grant-type:token-exchange` (RFC 8693)

The deprecated `password` and `implicit` grants are intentionally excluded.

### Specifications referenced

| Spec | Year | Subject |
|---|---|---|
| RFC 6749 | 2012 | OAuth 2.0 Authorization Framework |
| RFC 6750 | 2012 | Bearer Token Usage |
| RFC 7009 | 2013 | Token Revocation |
| RFC 7517 | 2015 | JSON Web Key (JWK / JWKS) |
| RFC 7519 | 2015 | JSON Web Token (JWT) |
| RFC 7523 | 2015 | JWT Bearer — client auth & authorization grant |
| RFC 7636 | 2015 | PKCE — Proof Key for Code Exchange |
| RFC 7662 | 2015 | Token Introspection |
| RFC 8414 | 2018 | Authorization Server Metadata |
| RFC 8628 | 2019 | Device Authorization Grant |
| RFC 8693 | 2020 | Token Exchange |
| RFC 8705 | 2020 | Mutual-TLS client auth & certificate-bound tokens |
| RFC 8707 | 2020 | Resource Indicators |
| RFC 9068 | 2021 | JWT Profile for OAuth 2.0 Access Tokens |
| RFC 9101 | 2021 | JAR — JWT-Secured Authorization Requests |
| RFC 9126 | 2021 | Pushed Authorization Requests (PAR) |
| RFC 9207 | 2022 | `iss` Authorization Response Parameter |
| RFC 9396 | 2023 | Rich Authorization Requests (RAR) |
| RFC 9449 | 2023 | DPoP — Demonstrating Proof of Possession |
| RFC 9470 | 2023 | Step-Up Authentication Challenge |
| RFC 9700 | 2025 | OAuth 2.0 Security Best Current Practice |
| RFC 9701 | 2025 | JWT Response for Token Introspection |
| RFC 9728 | 2025 | Protected Resource Metadata |
| OAuth 2.1 (draft) | ongoing | Consolidated modern best practices |
| OIDC Core 1.0 | 2014 | OpenID Connect identity layer |
| OIDC Discovery 1.0 | 2014 | `.well-known/openid-configuration` schema |

## How to use

### View interactively

Three viewers cover different use cases — pick the one that matches your goal:

| Tool | Command | Port (in command) | Use it for |
|---|---|---|---|
| **Redoc** | `npx @redocly/cli preview-docs oauth-openapi.yaml --port 8765` | 8765 | Read-only 3-panel documentation; clean for reading |
| **Scalar** | `npx @scalar/cli document serve oauth-openapi.yaml --port 8767` | 8767 | Modern API reference with `Cmd+K` search and `Test Request`; supports OpenAPI 3.1 |
| **Swagger UI** | `./tools/serve-swagger-ui.sh oauth-openapi.yaml --port 8768` | 8768 | Classic interactive UI with `Try it out` + `Authorize` for OAuth flows |

The script runs all three on different ports so you can compare side-by-side.
You can also start them all at once with the `/preview` slash command (see
[Claude Code integration](#claude-code-integration) below).

Why a script for Swagger UI? The community npm CLIs that claim to wrap Swagger
UI (`swagger-ui-watcher`, `swagger-ui-cli`, `swagger-ui-live`) are either
broken, abandoned, or bundle an older Swagger Editor that does not support
OpenAPI 3.1. SmartBear publishes the [`swagger-ui-dist`](https://www.npmjs.com/package/swagger-ui-dist)
library but never shipped a CLI for it. `tools/serve-swagger-ui.sh` is a
generic, production-grade bash script that fills that gap — see
[`tools/README.md`](tools/README.md) for full options, exit codes, and design
notes.

### Generate servers and clients

The spec is valid OpenAPI 3.1, so any generator that understands 3.1 can
scaffold both server stubs and client SDKs from it. **Servers are the more
useful artifact for learning** — the generated routes, parameters, content
types, and response shapes show exactly what each grant requires, end to end.

#### Servers

```bash
# Python — FastAPI
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml -g python-fastapi -o generated/server-fastapi

# Node.js — Express
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml -g nodejs-express-server -o generated/server-express

# C# — ASP.NET Core
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml -g aspnetcore -o generated/server-aspnetcore

# Java — Spring Boot
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml -g spring -o generated/server-spring

# Go — net/http
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml -g go-server -o generated/server-go
```

#### Clients

```bash
# Python
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml -g python -o generated/client-python

# TypeScript (Axios)
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml -g typescript-axios -o generated/client-typescript

# Go
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml -g go -o generated/client-go
```

`generated/` is gitignored — re-run the generator any time the spec changes.
For the full list of supported targets, see
`npx @openapitools/openapi-generator-cli list`.

### Lint

```bash
# Spectral — catches OpenAPI errors
npx @stoplight/spectral-cli lint oauth-openapi.yaml
```

### Try it against a real issuer

The `servers` section is templated:

```yaml
servers:
  - url: 'https://{issuer}'
    variables:
      issuer:
        default: as.example.com
```

To target Google, set `issuer` to `accounts.google.com`. To target Microsoft,
set it to `login.microsoftonline.com/common`. Note that real providers may use
different paths (e.g. Microsoft uses `/common/oauth2/v2.0/authorize`, not
`/authorize`); that is the point of the discovery endpoints.

## Modeling caveats

Three places where the spec is approximate, not because of laziness but because
OpenAPI's request/response model does not fit the OAuth flow precisely:

1. **`/authorize` returns a 302 redirect or HTML.** OpenAPI cannot model a
   redirect to a client-controlled URL with semantic query parameters. The
   request parameters are accurate; the response section is a placeholder. See
   RFC 6749 §4.1.2 for the real semantics.

2. **`/token` uses a discriminator.** All grants POST to `/token` and are
   dispatched by the `grant_type` form field. This is faithful to RFC 6749 but
   OpenAPI tooling that does not handle `oneOf` + discriminator may need
   manual flattening.

3. **`/device_authorization` polling is implicit.** The polling loop happens
   client-side and is documented in the operation's `description`, not modeled
   as a long-running operation.

These limits mean the spec covers maybe 90% of the protocol surface
machine-readably, with the remaining 10% (browser flows) documented in prose.

## Repository layout

```
oauth-openapi/
├── README.md                              this file
├── CLAUDE.md                              Claude Code project conventions
├── oauth-openapi.yaml                     the OpenAPI 3.1 spec (source of truth)
├── .spectral.yaml                         Spectral lint config (extends spectral:oas)
├── openapitools.json                      openapi-generator version pin (7.14.0)
├── .gitignore
├── .claude/                               Claude Code project config
│   ├── settings.json                      tool permissions for the dev workflow
│   └── commands/                          slash commands
│       ├── preview.md                     start all 3 viewers
│       ├── preview-stop.md                stop them
│       └── lint.md                        run Spectral
├── tools/
│   ├── README.md                          runbook for the scripts in this folder
│   └── serve-swagger-ui.sh                generic on-the-fly Swagger UI launcher
└── references/
    ├── audit/                             spec-vs-standard audit evidence
    │   ├── rfc-audit-synthesis.md         audit of the spec against 20 RFCs and related specs
    │   ├── live-idp-comparison.md         how the spec compares to live issuers (Google, Microsoft)
    │   └── community-reference-specs.md   survey of the two community reference specs
    ├── rfc-sources/                       vendored canonical RFC text snapshots — primary study material
    ├── oidf-sources/                      vendored OpenID Foundation specs (OIDC, JARM, response modes)
    ├── rfc-validation/                    per-RFC validation evidence backing the audit
    ├── ibm-api-connect-oauth.yaml         IBM's archived spec (Swagger 2.0, 2021)
    └── ybelenko-oauth2-endpoints.yaml     ybelenko's community spec (OpenAPI 3.0.2, 2021)
```

## Claude Code integration

If you use [Claude Code](https://claude.com/claude-code), the project ships
with a `CLAUDE.md` (project conventions) and `.claude/` (permissions + slash
commands) so that common workflows are one-liners:

| Slash command | Effect |
|---|---|
| `/preview` | Start Redoc (8765), Scalar (8767), and Swagger UI (8768) in parallel; opens browsers. |
| `/preview-stop` | Kill any process listening on those three ports. |
| `/lint` | Run Spectral against `oauth-openapi.yaml` and surface errors. |

These are convenience wrappers around the same `npx` and script commands
documented above — usable from any shell, but pre-flighted for Claude Code
sessions to skip permission prompts.

## Roadmap

- [ ] Add Dynamic Client Registration (RFC 7591) endpoints
- [ ] Add JAR (RFC 9101) request-object handling beyond what PAR already references
- [ ] Add RAR `authorization_details` JSON Schema reference types
- [ ] Add token-binding examples for DPoP
- [ ] Add CIBA (Client-Initiated Backchannel Authentication) endpoints

## License

The spec itself is licensed CC-BY-4.0 — use it freely, attribute the project.
