# Reference Specifications

This folder holds two community/vendor OpenAPI specs for OAuth 2.0 that we used as
reference while building `../oauth-openapi.yaml`. **They are kept here for historical
comparison only — neither is current and neither should be used as-is.**

## ibm-api-connect-oauth.yaml

| Field | Value |
|---|---|
| Source | https://github.com/IBM/api-connect-oauth-tutorial/blob/master/resources/oauth_public_endpoint.yaml |
| Format | Swagger 2.0 (predates OpenAPI 3.x) |
| Last commit | 2021-04-14 |
| Repository status | **Archived by IBM** |
| Stars | 4 |
| What it covers | `/oauth2/authorize` (GET + POST), `/oauth2/token` with the four classic RFC 6749 grants |
| What it lacks | PKCE (RFC 7636), Device Authorization (RFC 8628), Token Introspection (RFC 7662), Token Revocation (RFC 7009), PAR (RFC 9126), DPoP (RFC 9449), OpenID Connect, Discovery metadata schema |
| Notable | Includes IBM-specific extensions like `x-ibm-name`, `x-ibm-oauth-provider` — not portable to other authorization servers |

## ybelenko-oauth2-endpoints.yaml

| Field | Value |
|---|---|
| Source | https://github.com/ybelenko/oauth2_as_oas3_components/blob/master/dist/oauth2_endpoints.yml |
| Format | OpenAPI 3.0.2 |
| Last commit | 2021-04-20 |
| Repository status | Inactive (not archived but no commits in 5 years) |
| Stars | 9 |
| What it covers | `/code/token`, `/password/token`, `/client/token`, `/refresh/token` — each grant gets its own path. Token + error response schemas. Each endpoint links to the relevant RFC 6749 section via `externalDocs`. |
| What it lacks | The `/authorize` endpoint (the author explicitly omitted it because OAS3 cannot model the HTML/302 redirect response cleanly), Introspection, Revocation, Device, PAR, DPoP, OpenID Connect, Discovery metadata |
| Notable | RFC-canonical naming and references; cleanly written; uses `$ref` and components heavily |

## What both miss (RFCs published after 2021-04)

| RFC | Year | Topic |
|---|---|---|
| RFC 9126 | 2021-09 | Pushed Authorization Requests (PAR) |
| RFC 9396 | 2023-05 | Rich Authorization Requests (RAR) |
| RFC 9449 | 2023-09 | Demonstrating Proof of Possession (DPoP) |
| RFC 9700 | 2025-01 | OAuth 2.0 Security Best Current Practice |
| OAuth 2.1 (draft) | ongoing | Consolidates best practices, deprecates Implicit + Password grants, mandates PKCE |
| FAPI 2.0 | 2022–2024 | Hardened profile for financial-grade APIs |
| OpenID Connect Core 1.0 | n/a | Was already published by 2021 but neither spec includes it |

## Why we wrote our own

The fresh spec at `../oauth-openapi.yaml` covers the modern surface that these two
omit, follows OAuth 2.1 defaults, and adds OpenID Connect on top. It is also
vendor-agnostic — no IBM or other vendor extensions — so it can be retargeted at any
issuer by changing the server URL.
