# RFC audit synthesis

**Audit date:** 2026-05-10 · **Last updated:** 2026-06-07 (see the Update log at the end)
**Method:** 20 parallel agents, one per spec, comparing the spec against each
RFC/normative text.
**Disclosure:** WebFetch/curl was denied in the agents' sandbox for most runs;
agents worked from training-data knowledge of these stable specs (same source
the original spec used). The value of the audit is the *narrow per-RFC focus*
that the original drafting did not have, not "live RFC reading."

Per-RFC reports live under [`../rfc-validation/`](../rfc-validation/). The
discovery schema referred to below as `DiscoveryDocument` is implemented as
`OAuthServerMetadata` (+ `OpenIDProviderMetadata` via `allOf`).

## Tally by spec

| Spec | MISSING | WRONG | Notes |
|---|---|---|---|
| RFC 6749 — OAuth 2.0 Core | 8 | 6 | non-redirect 400, scope ABNF, WWW-Authenticate |
| RFC 6750 — Bearer Token | 4 | 2 | bearerFormat=JWT misleading; WWW-Authenticate |
| RFC 7009 — Revocation | 3 | 2 | unsupported_token_type missing; cascade direction |
| RFC 7517 — JWK | 12 | 4 | x5c base64 not base64url; key_ops; oct.k |
| RFC 7519 — JWT | 5 | 3 | NumericDate is number not integer; reusable JWT schema |
| RFC 7523 — JWT Bearer | 5 | 5 | client_assertion form fields modeled as fake header |
| RFC 7636 — PKCE | 7 | 5 | code_verifier pattern + length; default S256 vs RFC plain |
| RFC 7662 — Introspection | 6 | 4 | bearerAuth on introspect; additionalProperties |
| RFC 8414 — AS Metadata | 10 | 6 | revocation/introspection auth-methods + signing-algs |
| RFC 8628 — Device Grant | 5 | 4 | polling semantics; user_code charset; clientAssertion |
| RFC 8693 — Token Exchange | 8 | 3 | issued_token_type required; resource/audience arrays |
| RFC 8707 — Resource Indicators | 6 | 3 | resource as repeatable array on all grants |
| RFC 9068 — JWT Access Token | 14 | 4 | entire JWTAccessToken schema absent |
| RFC 9126 — PAR | 11 | 4 | invalid_request_uri; PARRequest blocks request_uri |
| RFC 9396 — RAR | 9 | 4 | AuthorizationDetail schema; cross-endpoint propagation |
| RFC 9449 — DPoP | 11 | 4 | dpop scheme invalid; cnf.jkt; DPoP-Nonce; dpop_jkt |
| RFC 9700 — Security BCP | 7 | 4 | iss param; drop hybrid token; drop plain |
| OAuth 2.1 (draft) | 14 | 11 | redirect_uri must NOT be required; 303 not 302 |
| OIDC Core 1.0 | 16 | 11 | display, ui_locales, claims, request, id_token_hint |
| OIDC Discovery 1.0 | 24 | 10 | encryption alg arrays; locale fields; capability flags |
| **TOTAL** | **185** | **99** | **284 actionable items** |

## Critical fixes (must apply — protocol-correctness)

These are spec-internal contradictions or RFC violations:

1. **`AuthorizationCodeTokenRequest.required` lists `redirect_uri`** — OAuth 2.1 §10.2 explicitly removes it from token requests. Move out of `required`.
2. **`response_type` enum has `code token` and `code id_token token`** — OAuth 2.1 §10.1 forbids hybrid front-channel token types. Remove.
3. **`code_challenge_method` enum has `plain`** — OAuth 2.1 §4.8 mandates S256 only. Remove.
4. **`securitySchemes.dpop.scheme: dpop`** — not a valid OpenAPI HTTP scheme; tools render incorrectly. Re-model.
5. **`bearerAuth.bearerFormat: JWT`** — Bearer tokens may be opaque per RFC 6750. Drop or annotate.
6. **`PARRequest.additionalProperties: true` allows `request_uri`** — RFC 9126 §2.1 forbids `request_uri` in PAR body.
7. **`code_challenge` REQUIRED at /authorize but OPTIONAL in PARRequest** — internal inconsistency.
8. **`audience` field on `ClientCredentialsTokenRequest` is non-standard** — RFC 8707 defines `resource`, not `audience`. Drop or document as vendor extension.
9. **`exp/iat/nbf` typed as `integer` everywhere** — RFC 7519 §2 NumericDate is `number`.
10. **`x5c` lacks documentation that it's base64 (NOT base64url)** — RFC 7517 §4.7. Common interop bug.

## Error codes — add to `ErrorResponse.error` enum

Currently has: invalid_request, invalid_client, invalid_grant, unauthorized_client, unsupported_grant_type, invalid_scope, access_denied, unsupported_response_type, server_error, temporarily_unavailable, invalid_token, insufficient_scope, authorization_pending, slow_down, expired_token, invalid_dpop_proof, use_dpop_nonce, invalid_target.

**Missing (add)**:
- `unsupported_token_type` (RFC 7009 §2.2.1)
- `invalid_request_uri` (RFC 9126 §2.3)
- `invalid_request_object` (RFC 9126 §2.3 + RFC 9101)
- `invalid_authorization_details` (RFC 9396 §5)
- 9 OIDC error codes (OIDC Core §3.1.2.6):
  - `interaction_required`
  - `login_required`
  - `account_selection_required`
  - `consent_required`
  - `request_not_supported`
  - `request_uri_not_supported`
  - `registration_not_supported`
  - (plus invalid_request_uri / invalid_request_object — already listed above)

## DiscoveryDocument (now `OAuthServerMetadata`) — add fields

Currently has 23 fields. Add the following (organized by spec):

**OIDC Discovery 1.0 §3 (RECOMMENDED + OPTIONAL):**
- `acr_values_supported` (array)
- `id_token_encryption_alg_values_supported` (array)
- `id_token_encryption_enc_values_supported` (array)
- `userinfo_signing_alg_values_supported` (array)
- `userinfo_encryption_alg_values_supported` (array)
- `userinfo_encryption_enc_values_supported` (array)
- `request_object_signing_alg_values_supported` (array)
- `request_object_encryption_alg_values_supported` (array)
- `request_object_encryption_enc_values_supported` (array)
- `display_values_supported` (array enum: page, popup, touch, wap)
- `claim_types_supported` (array enum: normal, aggregated, distributed)
- `claims_locales_supported` (array)
- `ui_locales_supported` (array)
- `claims_parameter_supported` (boolean)
- `request_parameter_supported` (boolean)
- `request_uri_parameter_supported` (boolean)
- `require_request_uri_registration` (boolean)
- `service_documentation` (uri)
- `op_policy_uri` (uri)
- `op_tos_uri` (uri)

**RFC 8414 §2:**
- `token_endpoint_auth_signing_alg_values_supported` (array)
- `revocation_endpoint_auth_methods_supported` (array)
- `revocation_endpoint_auth_signing_alg_values_supported` (array)
- `introspection_endpoint_auth_methods_supported` (array)
- `introspection_endpoint_auth_signing_alg_values_supported` (array)
- `signed_metadata` (string — JWT)

**OIDC Front/Back-Channel Logout 1.0:**
- `frontchannel_logout_supported` (boolean)
- `frontchannel_logout_session_supported` (boolean)
- `backchannel_logout_supported` (boolean)
- `backchannel_logout_session_supported` (boolean)
- `http_logout_supported` (boolean) — older Microsoft/legacy

**RFC 8705 mTLS:**
- `mtls_endpoint_aliases` (object — has each endpoint as a key)
- `tls_client_certificate_bound_access_tokens` (boolean)

**OIDC CIBA:**
- `backchannel_authentication_endpoint` (uri)
- `backchannel_token_delivery_modes_supported` (array enum: poll, ping, push)
- `backchannel_user_code_parameter_supported` (boolean)
- `backchannel_authentication_request_signing_alg_values_supported` (array)

**RFC 9207 Issuer Identifier:**
- `authorization_response_iss_parameter_supported` (boolean)

Also fix: `required` array should include OIDC's required fields (`jwks_uri`, `subject_types_supported`, `id_token_signing_alg_values_supported`).

## /authorize — add OIDC parameters

Currently has: response_type, client_id, redirect_uri, scope, state, code_challenge, code_challenge_method, nonce, prompt, login_hint, max_age, acr_values, response_mode, request_uri, authorization_details, resource.

**Missing (OIDC Core §3.1.2.1):**
- `display` (string enum: page, popup, touch, wap)
- `ui_locales` (string — space-separated language tags)
- `claims_locales` (string — space-separated)
- `id_token_hint` (string — JWT)
- `claims` (string — JSON)
- `request` (string — JWT, JAR per RFC 9101)

**Missing (RFC 9449 DPoP):**
- `dpop_jkt` (string — JWK thumbprint, for early authorization-code binding)

**Missing (RFC 9207):**
- Add `iss` to the 302 redirect Location header documentation

**Add 400 non-redirect response** — when `redirect_uri` is missing/invalid, RFC 6749 §4.1.2.1 says NEVER redirect to it. Currently only 302/200 modeled.

## Token requests — fixes per grant

**AuthorizationCodeTokenRequest:**
- Remove `redirect_uri` from `required` (OAuth 2.1 §10.2)
- Add `client_assertion` + `client_assertion_type` (RFC 7523)
- Add `dpop_jkt` reflection note (RFC 9449)
- Add `resource` (repeatable array — RFC 8707)

**ClientCredentialsTokenRequest:**
- Drop or document the non-standard `audience` field
- Convert `resource` to repeatable array
- Add `client_assertion` + `client_assertion_type`

**RefreshTokenRequest:**
- Convert `resource` to repeatable array
- Add `client_assertion` + `client_assertion_type`
- Document subset-of-original-resources rule
- Document refresh-token rotation expectation

**DeviceCodeTokenRequest:**
- Add `client_assertion` + `client_assertion_type`
- Add `resource` (repeatable array)

**JWTBearerTokenRequest:**
- Add `resource` (repeatable array)
- Add `client_assertion` + `client_assertion_type` (note: usually NOT used here since JWT is the assertion)

**TokenExchangeRequest:**
- Convert `resource` and `audience` to repeatable arrays
- Constrain `subject_token_type` and `requested_token_type` enums
- Constrain `actor_token_type` (and conditional-required when `actor_token` present)
- Add `client_assertion` + `client_assertion_type`

## TokenResponse — fixes

- Add `issued_token_type` (REQUIRED in token-exchange responses; RFC 8693 §2.2.1)
- Add `authorization_details` per RFC 9396 §6 (already partially there but as opaque object)
- Annotate that `token_type` may be `N_A` for token exchange (RFC 8693)
- Document that `id_token` payload conforms to OIDC Core §2 (point at IDTokenClaims schema)

## IntrospectionResponse — fixes

- Add `additionalProperties: true` (RFC 7662 §2.2 — extensible)
- Open `token_type_hint` to RFC 7009 registry (do not closed-enum)
- Fix `aud` items to be `StringOrURI`
- Fix `exp/iat/nbf` to `type: number` (NumericDate)
- Add `cnf` field for sender-constrained tokens (RFC 9449 §6.1)
- Add `authorization_details` field (RFC 9396 §9)
- Add `application/jwt` content type for signed introspection responses
- Add `Cache-Control: no-store` + `Pragma: no-cache` headers on 200

## /revoke — fixes

- Add `unsupported_token_type` to ErrorResponse enum
- Add `none` security option (public clients with PKCE are legitimate revokers)
- Add `Cache-Control: no-store` + `Pragma: no-cache` on 200
- Fix description: revoking a refresh token cascades to access tokens, not the other way round (RFC 7009 §2.1)

## /device_authorization — fixes

- Add `Cache-Control: no-store` + `Pragma: no-cache` on 200
- Pin response to `application/json`
- Add `clientAssertion` security
- Document polling semantics (interval, slow_down adds 5s, exponential backoff)
- Document `user_code` charset (BCP 47, dash-stripping, case-insensitivity)
- Add note: `device_code` MUST NOT be displayed to user

## /par — fixes

- Add `none` security
- Block `request_uri` in PARRequest (set `additionalProperties: false` or explicitly forbid)
- Add Cache-Control on 201
- Add 400 with `invalid_request_uri` / `invalid_request_object` examples
- Add 405/413/429 responses
- Make `code_challenge` REQUIRED in PARRequest (parity with /authorize)

## /userinfo — fixes

- Add `application/jwt` content type to POST operation (already on GET)
- For JWT response, add `iss` and `aud` REQUIRED claims to a new schema variant
- Add `WWW-Authenticate` header on 401 (RFC 6750)

## Reusable headers — add to components.headers

Currently 0 reusable headers. Add:
- `CacheControlNoStore` — `Cache-Control: no-store`
- `PragmaNoCache` — `Pragma: no-cache`
- `WWWAuthenticateBearer` — RFC 6750 §3
- `WWWAuthenticateDPoP` — RFC 9449 §7.1
- `DPoPNonce` — RFC 9449 §8

## Security schemes — fixes

- **`bearerAuth`**: drop `bearerFormat: JWT` (or change to "opaque or JWT, implementation-defined"). Bearer is opaque by definition.
- **`dpop`**: replace `scheme: dpop` (invalid). Use composite: bearerAuth-style apiKey for `Authorization: DPoP <token>` + mandatory `DPoP` header (already a parameter).
- **`clientAssertion`**: this fake header scheme is misleading — RFC 7523 §2.2 uses form fields `client_assertion` + `client_assertion_type`. Demote to a documentation marker like `clientSecretPost`, and add the actual form fields to every token-endpoint-style request schema.

## New schemas to add

- **`JWT`** (string with description of compact serialization, RFC 7519 §3)
- **`StringOrURI`** (string — RFC 7519 §2)
- **`NumericDate`** (number — RFC 7519 §2)
- **`IDTokenClaims`** (object — OIDC Core §2)
- **`JWTAccessTokenClaims`** (object — RFC 9068 §2.2)
- **`AuthorizationDetail`** (object — RFC 9396 §2.2)
- **`UserInfoSignedResponse`** (object extending UserInfoResponse with iss/aud)

## PKCE constraints to add

- `code_verifier`: `minLength: 43`, `maxLength: 128`, `pattern: '^[A-Za-z0-9._~-]+$'`
- `code_challenge`: `minLength: 43`, `maxLength: 128`, `pattern: '^[A-Za-z0-9._~-]+$'`

## /authorize 302 redirect Location header — additions

Document parameters that may appear on the redirect URL:
- `code` (success)
- `state` (echoed back)
- `iss` (RFC 9207 — REQUIRED if AS supports issuer parameter)
- `error`, `error_description`, `error_uri` (failure)
- For OIDC hybrid: `id_token`, `token_type`, `access_token`, `expires_in`

## Application policy

- Apply CRITICAL fixes — yes (10 items)
- Apply HIGH-PRIORITY missing fields/error codes — yes (~80 items)
- Apply MEDIUM (description tightening on existing fields) — yes
- Apply LOW (purely cosmetic doc improvements) — selectively

Skipped intentionally (vendor-specific or out of scope):
- Microsoft `cloud_*`, `tenant_region_scope`, `kerberos_endpoint`, `msgraph_host`, `rbac_url`
- Auth0 `mfa_challenge_endpoint`, `global_token_revocation_endpoint`, `client_id_metadata_document_supported`
- RFC 7591 Dynamic Client Registration endpoints (separate roadmap item)
- RFC 9101 JAR endpoint surface (mostly subsumed by PAR + `request` parameter)
- CIBA backchannel_authentication_endpoint operation modeling (only adding to discovery)

## Outcome

The spec moves from ~23 DiscoveryDocument fields → ~50; ErrorResponse error
enum expands by ~13 codes; ~6 new request schemas modify; security schemes
are corrected; ~7 new reusable schemas added; ~5 reusable headers added.
(The schema is now `OAuthServerMetadata`, 67 fields as of 2026-06-07.)

After all changes the spec should pass Spectral lint cleanly and represent
the OAuth 2.1 + OIDC + modern extensions surface area faithfully enough to
generate working clients against any RFC-compliant authorization server.

## Update log — 2026-06-07

Four newly vendored OAuth WG RFCs were incorporated into `oauth-openapi.yaml`
after a 17-RFC gap analysis (the full vendored set is listed in
[`../rfc-sources/README.md`](../rfc-sources/README.md)). Lint stays at
0 errors / 0 warnings.

| RFC | Added to the spec |
|---|---|
| **RFC 9728** Protected Resource Metadata | new `/.well-known/oauth-protected-resource` endpoint + `ProtectedResourceMetadata` schema; `protected_resources` AS-metadata field; `resource_metadata` `WWW-Authenticate` param |
| **RFC 9470** Step-Up Authentication | `insufficient_user_authentication` error code; `acr` + `auth_time` on `IntrospectionResponse`; `acr_values`/`max_age` challenge params |
| **RFC 9701** JWT Introspection Response | `/introspect` media type `application/token-introspection+jwt` + `JWTIntrospectionResponse` doc schema; 3× `introspection_*_values_supported` discovery fields |
| **RFC 9101** JAR | `require_signed_request_object` AS-metadata field |

**Schema naming:** the single `DiscoveryDocument` schema referenced throughout
this audit was split into `OAuthServerMetadata` (RFC 8414 base, 67 fields) and
`OpenIDProviderMetadata` (the OIDC wrapper — `allOf` + OIDC-required fields).
Decoded-payload schemas (`IDTokenClaims`, `JWTAccessTokenClaims`,
`JWTIntrospectionResponse`) are intentionally unwired documentation schemas, so
`oas3-unused-component` lint hints for them are expected.
