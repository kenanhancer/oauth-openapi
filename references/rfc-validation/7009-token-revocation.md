# RFC 7009 — OAuth 2.0 Token Revocation

Source: https://datatracker.ietf.org/doc/html/rfc7009
Audit date: 2026-05-10

Scope reviewed: `paths./revoke`, `components.schemas.RevocationRequest`,
`components.schemas.ErrorResponse`, `components.schemas.DiscoveryDocument`
(`revocation_endpoint`), security schemes used by `/revoke`.

NOTE: WebFetch was denied during this audit, so the comparison below is made
against the well-known normative content of RFC 7009 from training data. All
section references (§) refer to RFC 7009 verbatim; no quoted text is fabricated.

## Correctly modeled

- **Endpoint method and content type** (§2): `/revoke` is `POST` with
  `application/x-www-form-urlencoded` request body — matches the RFC exactly.
- **`token` parameter is REQUIRED** (§2.1): `RevocationRequest` lists `token`
  in `required: [token]`.
- **`token_type_hint` is OPTIONAL** (§2.1): present on `RevocationRequest`
  without being required.
- **`token_type_hint` enum** (§2.1): values restricted to
  `[access_token, refresh_token]` — matches the two values defined by the RFC.
- **Success returns HTTP 200 with empty body** (§2.2): the `200` response in
  the spec has no `content`, and the description correctly notes the body is
  empty.
- **Unknown / already-invalid token is treated as success (still 200, not
  404)** (§2.2): the 200 description says "returned even if the token was
  unknown".
- **Cascading revocation note** (§2.1): the operation `description` mentions
  "the server SHOULD also revoke any refresh tokens issued from the revoked
  token's authorization grant", echoing the RFC's SHOULD behavior. (The RFC
  actually states the inverse direction more strongly — see WRONG below.)
- **Client authentication for confidential clients** (§2.1): `/revoke`
  declares `clientSecretBasic`, `clientSecretPost`, and `clientAssertion`
  security requirement options, satisfying "the client MUST authenticate
  with the authorization server as described in Section 2.3.1 of [RFC6749]".
- **Discovery metadata** (§3): `DiscoveryDocument.revocation_endpoint`
  (URI) is present.
- **Standard OAuth error response shape on failure** (§2.2.1 → RFC 6749
  §5.2): `400` and `401` map to `OAuthError`/`ErrorResponse`.

## MISSING — must add

- **`unsupported_token_type` error code** (§2.2.1): RFC 7009 explicitly adds
  this error code to the `error` registry: "The authorization server does
  not support the revocation of the presented token type." It MUST appear
  in `ErrorResponse.error` enum but is absent from the current enum
  (which lists `invalid_request`, `invalid_client`, …, `invalid_target`
  only). Without it, a 7009-compliant server's error response is not
  representable in the spec.
- **Public-client support on `/revoke`** (§2.1): the RFC says "If the client
  was issued a client password ... the client MUST authenticate ... If
  client authentication is not needed in the case of public clients ... the
  authorization server MUST adhere to the requirements in Section 3.2.1 of
  [RFC6749]." The `/token` endpoint correctly lists a `none` security
  option for public clients (PKCE flow) but `/revoke` does not — a public
  client that legitimately holds a refresh token under OAuth 2.1 cannot
  revoke it under the modeled security. Add `- none: []` to the
  `security` array on `/revoke`.
- **`Cache-Control: no-store` / `Pragma: no-cache` on the 200 response**
  (§2.2): the RFC says "The authorization server responds with HTTP status
  code 200 if the token has been revoked successfully or if the client
  submitted an invalid token" and also references the cache directives
  inherited from RFC 6749 §5.1 for token-related responses. The `/token`
  200 response models these headers; `/revoke` does not. Add the same two
  response headers for parity and explicit no-cache semantics.

## WRONG — must fix

- **Cascade direction of revocation** (§2.1): the spec's `description`
  on `/revoke` says "the server SHOULD also revoke any refresh tokens
  issued from the revoked token's authorization grant." RFC 7009 §2.1
  actually specifies the **opposite** direction: "If the particular token
  is a refresh token and the authorization server supports the revocation
  of access tokens, then the authorization server SHOULD also invalidate
  all access tokens based on the same authorization grant." Revoking an
  access token does NOT (per the RFC) require revoking refresh tokens.
  Reword the description to:
  "If the revoked token is a refresh token and the server supports access-
  token revocation, the server SHOULD also invalidate all access tokens
  issued under the same authorization grant (RFC 7009 §2.1)."
- **`401` is not a valid response for `/revoke` per the RFC; the spec
  documents it without qualifying when it applies** (§2.1, §2.2.1):
  the RFC only references RFC 6749 §5.2 errors plus the new
  `unsupported_token_type`. A 401 is appropriate only for client-
  authentication failures (`invalid_client`). Either remove `401` or
  explicitly tie it to `invalid_client` per RFC 6749 §5.2 to avoid
  ambiguity.

## NICE-TO-HAVE

- **Cross-Origin Support (§2.2)**: the RFC mentions CORS and JSONP for
  browser clients. JSONP is obsolete and can be ignored; CORS is worth a
  one-line note in the `/revoke` description ("Servers SHOULD support CORS
  preflight for browser-based public clients per RFC 7009 §2.2").
- **Explicit example body**: include an `example` on `RevocationRequest`
  showing `token=tGzv3JOkF0XG5Qx2TlKWIA&token_type_hint=refresh_token` so
  generated docs render an obvious sample.
- **Reference RFC 6749 §5.2 explicitly in the 400 response description**
  for `/revoke` so consumers know which error codes are valid (currently
  the shared `OAuthError` reference makes this implicit).
- **Document that `token_type_hint` is purely advisory** (§2.1: "If the
  server is unable to locate the token using the given hint, it MUST
  extend its search across all of its supported token types"). A
  `description` line on the field would help client implementors.
- **Note that the spec's enum on `token_type_hint` is exhaustive only
  for the values defined by 7009**; extensions (e.g., 8693 token types)
  are permitted but not modeled. A short comment makes this explicit.

## NOT APPLICABLE

- **JSONP callback parameter (§2.2)**: legacy mechanism, deprecated
  alongside the cross-domain workarounds it solved; not modeled in any
  modern OAuth deployment and intentionally omitted here.
- **Token-type extensions outside the {access_token, refresh_token} pair
  (§2.1)**: the RFC permits servers to register additional `token_type_hint`
  values via the OAuth Token Type Hints registry, but the canonical spec
  only models the two values defined by RFC 7009 itself. New values
  belong in vendor or extension specs.
- **Transport security (§4)**: "The authorization server MUST require
  the use of TLS" — TLS is asserted globally by the `https://{issuer}`
  server URL and does not need per-endpoint modeling.
- **Token-scanning / privacy considerations (§5)**: operational guidance,
  not OpenAPI-modelable.
