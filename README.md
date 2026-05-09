# oauth-openapi

A vendor-agnostic, RFC-canonical OpenAPI 3.1 specification of the OAuth 2.0 +
OpenID Connect authorization-server protocol surface.

## Why this exists

There is no official OpenAPI specification for OAuth 2.0. RFC 6749 was published
in 2012 — before OpenAPI / Swagger became a mature standard — so the OAuth
working group never produced one. The two community attempts that exist are both
**five years stale and miss every modern extension:**

- IBM's `api-connect-oauth-tutorial` (Swagger 2.0, archived in 2021)
- ybelenko's `oauth2_as_oas3_components` (OpenAPI 3.0.2, no commits since 2021)

Both are kept here under `references/` for comparison. See
[`references/NOTES.md`](references/NOTES.md) for what each covers and what each
misses.

This project is a fresh OpenAPI 3.1 spec that:

- Is built directly from the relevant IETF RFCs (each endpoint and field links
  to its source via `externalDocs`)
- Covers OAuth 2.0 + OIDC + every modern extension through 2025
- Applies OAuth 2.1 defaults (PKCE mandatory, Implicit and Password grants
  excluded)
- Is vendor-agnostic — change the `issuer` server variable and it retargets to
  any compliant authorization server

## What's covered

`oauth-openapi.yaml` (1413 lines) describes:

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
| RFC 7636 | 2015 | PKCE — Proof Key for Code Exchange |
| RFC 7662 | 2015 | Token Introspection |
| RFC 8414 | 2018 | Authorization Server Metadata |
| RFC 8628 | 2019 | Device Authorization Grant |
| RFC 8693 | 2020 | Token Exchange |
| RFC 9068 | 2021 | JWT Profile for OAuth 2.0 Access Tokens |
| RFC 9126 | 2021 | Pushed Authorization Requests (PAR) |
| RFC 9396 | 2023 | Rich Authorization Requests (RAR) |
| RFC 9449 | 2023 | DPoP — Demonstrating Proof of Possession |
| RFC 9700 | 2025 | OAuth 2.0 Security Best Current Practice |
| OAuth 2.1 (draft) | ongoing | Consolidated modern best practices |
| OIDC Core 1.0 | 2014 | OpenID Connect identity layer |
| OIDC Discovery 1.0 | 2014 | `.well-known/openid-configuration` schema |

## How to use

### View interactively

Both viewers are zero-install via `npx`:

```bash
# Redoc — read-only documentation, 3-panel layout, clean for reading
npx @redocly/cli preview-docs oauth-openapi.yaml --port 8765

# Swagger UI — interactive explorer with "Try it out" + "Authorize"
npx swagger-ui-watcher oauth-openapi.yaml --port 8767
```

Both watch the YAML for changes and auto-reload the browser. Pick the one
that matches your goal:

| Goal | Tool |
|---|---|
| Read the spec like documentation | Redoc |
| Click "Try it out" and send real HTTP requests | Swagger UI |
| Test OAuth flows via "Authorize" button | Swagger UI |
| Visually compare layouts | Run both side-by-side on different ports |

For deeper Swagger UI customization (custom plugins, request interceptors,
themes), embed the official [`swagger-ui-dist`](https://www.npmjs.com/package/swagger-ui-dist)
package in your own HTML — `swagger-ui-watcher` is a community CLI wrapper
around the same library and exposes only its CLI flags.

### Generate clients

```bash
# Python client
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml \
  -g python \
  -o generated/python

# TypeScript client
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml \
  -g typescript-axios \
  -o generated/typescript

# Go client
npx @openapitools/openapi-generator-cli generate \
  -i oauth-openapi.yaml \
  -g go \
  -o generated/go
```

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
├── oauth-openapi.yaml                     the spec
├── .gitignore
└── references/
    ├── NOTES.md                           description of the two reference specs
    ├── ibm-api-connect-oauth.yaml         IBM's archived spec (Swagger 2.0, 2021)
    └── ybelenko-oauth2-endpoints.yaml     ybelenko's community spec (OpenAPI 3.0.2, 2021)
```

## Roadmap

- [ ] Add Dynamic Client Registration (RFC 7591) endpoints
- [ ] Add JAR (RFC 9101) request-object handling beyond what PAR already references
- [ ] Add MTLS client authentication (RFC 8705) details
- [ ] Add RAR `authorization_details` JSON Schema reference types
- [ ] Add token-binding examples for DPoP
- [ ] Add CIBA (Client-Initiated Backchannel Authentication) endpoints

## License

The spec itself is licensed CC-BY-4.0 — use it freely, attribute the project.
