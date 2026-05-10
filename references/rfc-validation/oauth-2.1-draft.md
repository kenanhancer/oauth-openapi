# OAuth 2.1 Authorization Framework (draft-ietf-oauth-v2-1-13)

Source: https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/
Draft archive: https://www.ietf.org/archive/id/draft-ietf-oauth-v2-1-13.txt
Audit date: 2026-05-10
Cached source: `.draft-ietf-oauth-v2-1-source.txt` in this directory.

> Note: WebFetch was denied during this audit; the draft was retrieved with
> `curl https://www.ietf.org/archive/id/draft-ietf-oauth-v2-1-13.txt` (28 May
> 2025, draft-13). All section citations are taken verbatim from the draft as
> downloaded. Note that the draft uses §10 for "Differences from OAuth 2.0"
> (the task brief said §1.7 — that section in -13 is now "Interoperability";
> the differences list is §10 with the consolidated normative text in §1.8
> "Compatibility with OAuth 2.0").

## Scope reminder

The audited OpenAPI spec (`oauth-openapi.yaml`) explicitly declares OAuth 2.1
defaults at lines 8 and 51-53 ("OAuth 2.1 defaults are applied"). This audit
verifies that the spec actually applies the OAuth 2.1 mandates listed in the
draft's §10 "Differences from OAuth 2.0" plus the relevant normative MUSTs
from §§ 2-7. Items intentionally omitted by OAuth 2.1 (Implicit, ROPC) are
treated as correct exclusions, not gaps.

## Correctly modeled

- **PKCE parameters present and marked REQUIRED on `/authorize`** (§4.1.1,
  §7.5.2): `CodeChallenge` parameter (oauth-openapi.yaml:559-567) is
  `required: true` and the description states "**Mandatory in OAuth 2.1 for
  all clients.**" `CodeChallengeMethod` (oauth-openapi.yaml:569-579) is also
  `required: true` with enum `[S256, plain]` and default `S256`. This matches
  §10 first bullet ("PKCE such that the default method of using the
  authorization code grant according to this specification requires the
  addition of the PKCE parameters") and §7.5.2 ("using code_challenge and
  code_verifier is REQUIRED for clients, and authorization servers MUST
  enforce their use").

- **`code_verifier` REQUIRED on `/token` for `authorization_code`**
  (§4.1.3): `AuthorizationCodeTokenRequest` (oauth-openapi.yaml:725-747)
  lists `code_verifier` in `required: [grant_type, code, redirect_uri,
  code_verifier]`. The 43-128 character length matches the §4.1.1 ABNF
  `code-verifier = 43*128unreserved`.

- **Implicit grant (`response_type=token`) excluded** (§10.1): the
  `ResponseType` enum (oauth-openapi.yaml:507-512) does not include `token`.
  Spec preamble (lines 51-53, 175-176) states the omission is intentional
  per OAuth 2.1.

- **Resource Owner Password Credentials grant excluded** (§10 fourth
  bullet): the `TokenRequest` discriminator mapping
  (oauth-openapi.yaml:717-723) does not include `password`. Spec
  preamble (line 53, 175-176) acknowledges the deliberate omission.

- **Bearer token presentation only via Authorization header** (§5.1, §10
  fifth bullet, §7.1.3.7): the only Bearer-related security scheme is
  `bearerAuth` (oauth-openapi.yaml:1315-1319) with `scheme: bearer` (i.e.,
  Authorization header), and the spec does not model the §2.3 URI query
  parameter method nor the §2.2 form-encoded body method (the latter is
  still permitted by OAuth 2.1 §5.1.2 but with multiple conditions).

- **Single token endpoint with `grant_type` discriminator** (§3.2.2): the
  `TokenRequest` schema (oauth-openapi.yaml:704-723) is a discriminated
  union by `grant_type`, matching the draft's §3.2.2 dispatch model.

- **POST-only token endpoint** (§3.2): `/token` declares only `post:`
  (oauth-openapi.yaml:160), satisfying "The client MUST use the HTTP POST
  method when making requests to the token endpoint."

- **`Cache-Control: no-store` on token response** (§3.2.3): the `/token`
  200 response declares the `Cache-Control` header with example value
  `no-store` (oauth-openapi.yaml:191-195). Matches "The authorization
  server MUST include the HTTP Cache-Control response header field ...
  with a value of no-store in any response containing tokens".

- **`access_token` and `token_type` REQUIRED in token response** (§3.2.3):
  `TokenResponse` (oauth-openapi.yaml:847-851) lists
  `required: [access_token, token_type]`.

- **Confidential-client authentication options on `/token`** (§3.2.1,
  §2.4): `/token` lists `clientSecretBasic`, `clientSecretPost`, and
  `clientAssertion` security options (oauth-openapi.yaml:208-212),
  matching the §2.4.1 / §2.4.2 methods.

- **Public clients permitted at `/token`** (§3.2.2 "client_id OPTIONAL",
  §4.1.3 "client_id REQUIRED if the client is not authenticating"): the
  `none` security option is present on `/token` (oauth-openapi.yaml:212),
  and `AuthorizationCodeTokenRequest.client_id` description
  (oauth-openapi.yaml:745-747) notes it is "REQUIRED if the client is not
  authenticating with the server (e.g. public client)".

- **HTTPS-only servers** (§1.5): the `servers` block uses
  `https://{issuer}` (oauth-openapi.yaml:70-71), matching "All the OAuth
  protocol URLs ... MUST use the https scheme".

- **DPoP referenced and modeled** (§1.4.3, §7.1.3): the `DPoPHeader`
  parameter (oauth-openapi.yaml:673-683) and `dpop` security scheme
  (oauth-openapi.yaml:1321-1326) reference RFC 9449. §1.4.3 RECOMMENDS
  sender-constraining; the spec exposes the mechanism even though it is
  not made mandatory.

- **Refresh-token rotation acknowledged in metadata**: the
  `DiscoveryDocument.dpop_signing_alg_values_supported`
  (oauth-openapi.yaml:1230-1234) and the `none` security scheme description
  (oauth-openapi.yaml:1357-1359 — "Permitted for native and SPA clients
  per OAuth 2.1, provided PKCE is used") show the spec is aware of
  OAuth 2.1's §4.3.1 rules, even if the rotation/sender-constraining is
  not enforceable in OpenAPI itself.

---

## MISSING — must add to the spec

- **`iss` parameter (RFC 9207) on the `/authorize` 302 redirect response**
  (§4.1.2, §4.1.2.1, §7.14.1): the draft adds a new authorization-response
  parameter:
  > "iss":  OPTIONAL.  The identifier of the authorization server which
  >    the client can use to prevent mix-up attacks ...  See Section 7.14
  >    and [RFC9207] for additional details
  And §7.14.1 ("Mix-Up Defense via Issuer Identification") makes RFC 9207
  RECOMMENDED. The spec's `Location` header documentation
  (oauth-openapi.yaml:140-148) lists only `code` and `state` (success) /
  `error` and `state` (failure); there is no mention of `iss`. Add `iss` to
  the redirect-parameter examples and call out RFC 9207 explicitly. (This
  also affects the OIDC discovery document — `authorization_response_iss_
  parameter_supported` is missing from `DiscoveryDocument`.)

- **`redirect_uri` REMOVED from `AuthorizationCodeTokenRequest`'s required
  list** (§10 seventh bullet, §10.2): the draft says explicitly:
  > "The token endpoint request containing an authorization code no
  >  longer contains the redirect_uri parameter"
  and §10.2 states "it has been removed". The spec's
  `AuthorizationCodeTokenRequest` (oauth-openapi.yaml:728) still lists
  `redirect_uri` as REQUIRED:
  ```yaml
  required: [grant_type, code, redirect_uri, code_verifier]
  ```
  This is a direct OAuth-2.1 violation. Move `redirect_uri` out of
  `required`, mark it as OPTIONAL with a description note explaining the
  §10.2 backwards-compatibility allowance ("AS MAY accept it for OAuth 2.0
  client compatibility but MUST NOT require it from OAuth 2.1 clients").

- **Exact-string-match requirement for `redirect_uri`** (§2.3.1, §10
  second bullet): the draft is explicit:
  > "Authorization servers MUST reject authorization requests that
  >  specify a redirect URI that doesn't exactly match one that was
  >  registered, with an exception for loopback redirects"
  The `RedirectUri` parameter (oauth-openapi.yaml:522-532) only says "Must
  match a URI pre-registered for the client. Required when more than one
  is registered." It does not mention the exact-string-match mandate or
  the loopback exception (variable port). Add a description note: "Per
  OAuth 2.1 §2.3.1, the AS MUST perform exact-string comparison; no
  wildcards, prefix-matching, or regex allowed. Loopback URIs (`127.0.0.1`,
  `[::1]`) are matched ignoring port."

- **Refresh tokens for public clients MUST be sender-constrained or
  rotated** (§4.3.1, §10 sixth bullet): the draft says:
  > "Authorization servers MUST utilize one of these methods to detect
  >  refresh token replay by malicious actors for public clients:
  >  Sender-constrained refresh tokens ... or Refresh token rotation"
  The spec's `RefreshTokenRequest` and `TokenResponse.refresh_token`
  (oauth-openapi.yaml:864-866) say nothing about this. Add a description
  note on `RefreshTokenRequest` and on the `none` security scheme that
  refresh tokens issued to clients authenticating via `none` MUST be
  rotated (one-time use) or sender-constrained (DPoP/mTLS bound).

- **`/authorize` 400 response for invalid `redirect_uri` / `client_id`**
  (§2.3.5, §4.1.2.1): the draft says
  > "the authorization server SHOULD inform the resource owner of the
  >  error and MUST NOT automatically redirect the user agent to the
  >  invalid redirect URI."
  The spec's `/authorize` operation only declares `302` and `200`
  responses (oauth-openapi.yaml:135-154). When `redirect_uri` /
  `client_id` are invalid, the AS MUST NOT redirect — so a `400` (or
  similar non-redirecting) response must be modeled. Add a `400`
  response that returns an HTML/JSON body to the resource owner.

- **HTTP 303 See Other RECOMMENDED for redirects** (§7.5.4): the draft
  says:
  > "If an HTTP redirection (and not, for example, JavaScript) is used
  >  for such a request, AS SHOULD use the status code 303 ('See Other')."
  > "An authorization server which redirects a request that potentially
  >  contains user credentials MUST NOT use the 307 status code"
  The spec's `/authorize` declares only `302` (oauth-openapi.yaml:135),
  not `303`. Add a `303` response with the same `Location` header schema,
  or document `303` as the RECOMMENDED status alongside `302`. Also add
  a description note explicitly forbidding `307` per §7.5.4.

- **Bearer token in URI query string PROHIBITION explicitly stated**
  (§5.1, §7.1.3.7, §10 fifth bullet): the draft says
  > "clients MUST NOT send the access token in a URI query parameter,
  >  and resource servers MUST ignore access tokens in a URI query
  >  parameter."
  The `bearerAuth` security scheme description (oauth-openapi.yaml:
  1315-1319) only says "OAuth 2.0 Bearer Token in the Authorization
  header". Add an explicit MUST-NOT note: "Per OAuth 2.1 §5.1, bearer
  tokens MUST NOT be passed in URI query parameters; resource servers
  MUST ignore them if present."

- **`Cache-Control: no-store` MUST also appear on `/token` 400 error
  response** (§3.2.4 example shows `Cache-Control: no-store` on the 400
  response): the spec only models cache headers on the 200 response
  (oauth-openapi.yaml:191-199), not on 400/401. Add the same headers to
  the error responses (also relevant to RFC 6749 §5.2 cache directives).

- **`WWW-Authenticate` response header on `/token` 401** (§3.2.4
  `invalid_client` clause):
  > "If the client attempted to authenticate via the Authorization
  >  request header field, the authorization server MUST respond with an
  >  HTTP 401 (Unauthorized) status code and include the WWW-Authenticate
  >  response header field matching the authentication scheme used by the
  >  client."
  The spec returns `401` from `/token` (oauth-openapi.yaml:206-207) but
  declares no `WWW-Authenticate` header. Add it as a response header.

- **Authorization endpoint MUST support GET and MAY support POST** (§3.1):
  > "The authorization server MUST support the use of the HTTP GET method
  >  ... for the authorization endpoint and MAY support the POST method"
  The spec models only `get:` on `/authorize` (oauth-openapi.yaml:102).
  This is acceptable (POST is MAY), but worth a description note: "POST
  is OPTIONAL per OAuth 2.1 §3.1 and intentionally not modeled here."

- **CORS requirement on `/token` for browser-based apps** (§3.2):
  > "Authorization servers that wish to support browser-based
  >  applications ... will need to ensure the token endpoint supports the
  >  necessary CORS [WHATWG.CORS] headers"
  The spec models no CORS-related headers on `/token` (or `/revoke`,
  `/introspect`, `/userinfo`). Add a description note acknowledging the
  CORS requirement, and ideally document expected response headers
  (`Access-Control-Allow-Origin`, etc.).

- **Cross-Origin Resource Sharing FORBIDDEN at `/authorize`** (§3.1):
  > "Cross-Origin Resource Sharing [WHATWG.CORS] MUST NOT be supported
  >  at the Authorization Endpoint"
  Worth a description note on `/authorize`.

- **Authorization-code maximum lifetime SHOULD be 10 minutes** (§4.1.2):
  > "A maximum authorization code lifetime of 10 minutes is RECOMMENDED."
  The spec does not document the lifetime anywhere. Add a note on
  `/authorize` 302 response or in the description: "Per OAuth 2.1 §4.1.2,
  authorization codes SHOULD expire within 10 minutes of issuance."

- **Authorization-code one-time use** (§4.1.3, §7.5.3):
  > "The authorization server MUST return an access token only once for
  >  a given authorization code."
  > "If a second valid token request is made with the same authorization
  >  code as a previously successful token request, the authorization
  >  server MUST deny the request and SHOULD revoke (when possible) all
  >  access tokens and refresh tokens previously issued"
  Not surfaced in `AuthorizationCodeTokenRequest.code` description
  (oauth-openapi.yaml:733-735). Add a note.

- **Token entropy requirement** (§7.7):
  > "The probability of an attacker guessing generated tokens ... MUST be
  >  less than or equal to 2^(-128) and SHOULD be less than or equal to
  >  2^(-160)."
  Worth a description note on `TokenResponse.access_token` and
  `TokenResponse.refresh_token`.

- **Mix-up defenses must be supported** (§7.14): the draft mandates
  > "clients MUST prevent mix-up attacks"
  with two defenses (RFC 9207 `iss` parameter, distinct redirect URIs).
  The spec does not surface `iss` in the redirect (see first MISSING
  item) and does not document either defense.

- **`error` enum per §3.2.4 vs §4.1.2.1**: §3.2.4 (token endpoint) and
  §4.1.2.1 (authorization endpoint) define disjoint error code sets.
  The spec mixes them in one shared `ErrorResponse.error` enum
  (oauth-openapi.yaml:889-907). Acceptable for an umbrella spec, but
  the description should note the §3.2.4 vs §4.1.2.1 partition.

- **Client Credentials grant restricted to confidential clients only**
  (§4.2): the draft says "The client credentials grant type MUST only be
  used by confidential clients." `ClientCredentialsTokenRequest`
  (oauth-openapi.yaml:749-766) is part of `/token` which lists `none` as
  an accepted security option (line 212). Add a description note that
  Client Credentials specifically MUST NOT use `none` (i.e., the `none`
  security option applies only to authorization-code public clients).

---

## WRONG — must fix

- **`AuthorizationCodeTokenRequest.redirect_uri` is REQUIRED**
  (oauth-openapi.yaml:728) — direct contradiction of §10 seventh bullet
  and §10.2 (redirect_uri removed from token request). See first MISSING
  item; this is also WRONG because the current `required` list forces
  every OAuth 2.1 client into a backwards-compatibility mode that the
  spec elsewhere claims to apply OAuth 2.1 defaults.

- **`code_challenge_method` default `plain`** (§4.1.1):
  > "code_challenge_method:  OPTIONAL, defaults to plain if not present
  >  in the request."
  > "If the client is capable of using S256, it MUST use S256, as S256
  >  is Mandatory To Implement (MTI) on the server."
  The spec's `CodeChallengeMethod` (oauth-openapi.yaml:569-579) sets
  `default: S256` and marks the parameter `required: true`. This is
  *stricter* than the draft (the draft makes it OPTIONAL with default
  `plain`) but is consistent with the spec's stated OAuth 2.1 + S256-only
  posture. The mismatch is in the draft's wording vs. the spec's
  intent — but the description "Always `S256` per OAuth 2.1. The plain
  method exists for legacy compatibility only and SHOULD NOT be used"
  needs clarification: §4.1.1 says the default is `plain` (not S256),
  and §7.5.2 only RECOMMENDs disabling `plain`. A safer wording: "OAuth
  2.1 §4.1.1 makes this OPTIONAL with default `plain`, but §7.5.2
  RECOMMENDS S256 only; this spec mandates S256." Also reconsider whether
  marking `required: true` is correct (the draft says OPTIONAL).

- **`response_type=code token` listed in `ResponseType.enum`**
  (oauth-openapi.yaml:511): this hybrid response type returns an access
  token in the front channel, identical to the implicit grant's leakage
  surface. While not literally `response_type=token`, the `code token`
  combination is a classic implicit-style flow. §10.1 says:
  > "The intent of removing the Implicit grant is to no longer issue
  >  access tokens in the authorization response, as such tokens are
  >  vulnerable to leakage and injection"
  Since `code token` issues an access token in the front channel, it
  contradicts the *intent* of OAuth 2.1's §10.1, even though it is
  technically defined by OIDC Core. Either drop `code token` and `code
  id_token token` from the enum, or add a description note: "OIDC
  hybrid flows that include `token` issue an access token in the
  authorization response, contradicting OAuth 2.1 §10.1's intent.
  Modern deployments SHOULD use only `code` (or `code id_token` for
  ID-token-bound CSRF protection)."

- **`/par` (PAR) and `/authorize` `request_uri` parameter** (§4.1.1
  silent on PAR): PAR (RFC 9126) is referenced via the `RequestUri`
  parameter (oauth-openapi.yaml:641-650), but the spec does not
  document the §4.1.1 rule that `request_uri` and the inline parameters
  are mutually exclusive. Not OAuth 2.1-specific, but also missing from
  the spec.

- **Missing description that OAuth 2.1 deprecates `plain` PKCE**
  (§7.5.2 / §4.1.1): the description on `CodeChallengeMethod` already
  says "SHOULD NOT be used" for `plain`. Per §7.5.2:
  > "Clients SHOULD use code challenge methods that do not expose the
  >  code_verifier in the authorization request ... Currently, S256 is
  >  the only such method."
  The wording in the spec is correct in intent but cite §7.5.2 instead
  of (or in addition to) §4.1.1.

- **Missing acknowledgement of §3.2.2 "AS MUST ignore unrecognized
  request parameters"**: the spec's `additionalProperties` is not set
  on `TokenRequest` schemas (oauth-openapi.yaml:725-842), but the
  draft explicitly says:
  > "The authorization server MUST ignore unrecognized request
  >  parameters sent to the token endpoint."
  Add `additionalProperties: true` (or omit `additionalProperties` —
  the OpenAPI default — and add a description note) on every token-
  request schema so codegen and validators do not reject extra fields.
  The `PARRequest` schema (oauth-openapi.yaml:990) correctly sets
  `additionalProperties: true`.

- **`scope` parameter ABNF not enforced** (§1.4.1):
  > "scope       = scope-token *( SP scope-token )
  >  scope-token = 1*( %x21 / %x23-5B / %x5D-7E )"
  The `Scope` parameter schema (oauth-openapi.yaml:534-547) is plain
  `string`. Add a `pattern` matching the ABNF:
  `^[\\x21\\x23-\\x5B\\x5D-\\x7E]+( [\\x21\\x23-\\x5B\\x5D-\\x7E]+)*$`.
  (Same finding as the RFC 6749 audit; restated here because §1.4.1 is
  the OAuth 2.1 normative source now.)

- **Token-type case insensitivity not surfaced** (§3.2.3):
  > "token_type:  REQUIRED.  The type of the access token issued ...
  >  Value is case insensitive."
  `TokenResponse.token_type` (oauth-openapi.yaml:856-859) is plain
  `string` with examples `Bearer`, `DPoP`. Add a description note about
  case-insensitive comparison.

- **`expires_in` typed as integer rather than RECOMMENDED note** (§3.2.3):
  > "expires_in:  RECOMMENDED.  A JSON number ... clients MUST NOT
  >  expect an access token to be valid for the provided lifetime."
  `TokenResponse.expires_in` (oauth-openapi.yaml:860-863) is `type:
  integer`. The draft uses "JSON number" (no integer restriction).
  Per the literal text, integer is sufficient (no fractional seconds
  expected for token lifetimes), but the description should note the
  "MUST NOT expect ... valid for the provided lifetime" caveat.

- **`scope` in the token response REQUIRED if different from request**
  (§1.4.1, §3.2.3):
  > "scope:  RECOMMENDED, if identical to the scope requested by the
  >  client; otherwise, REQUIRED."
  The `TokenResponse.scope` description (oauth-openapi.yaml:867-869)
  says "Granted scope, if different from requested" — but the field is
  not marked REQUIRED conditionally. Add a description note: "REQUIRED
  if the granted scope differs from the requested scope; OPTIONAL
  otherwise (per §1.4.1)."

- **Discovery `code_challenge_methods_supported` should mark S256 as
  required** (§4.1.1 MTI rule):
  > "S256 is Mandatory To Implement (MTI) on the server."
  `DiscoveryDocument.code_challenge_methods_supported`
  (oauth-openapi.yaml:1222-1226) declares the field as an array of
  strings with enum `[S256, plain]` but does not require `S256` to be
  present. Add a note that `S256` MUST be present in the array.

- **`prompt=none` not addressed in spec for OAuth 2.1 silent-auth
  considerations** (§7.12.2 third bullet): the `Prompt` parameter
  (oauth-openapi.yaml:591-603) accepts `none` without any security
  caveat. §7.12.2 third bullet describes `prompt=none` being abused for
  open-redirector phishing. Add a description note pointing to §7.12.2.

---

## NICE-TO-HAVE

- **Explicit cross-reference to §1.8 "Compatibility with OAuth 2.0"** in
  the spec's preamble: list which legacy features are still supported
  for backwards compatibility (e.g., the `/authorize` 302 status,
  `redirect_uri` in token request when AS chooses to support older
  clients).

- **Document §3.2 token-endpoint URL constraints**:
  > "The token endpoint URL MUST NOT include a fragment component, and
  >  MAY include a query string component"
  Currently the spec leaves the path unspecified; a note in the
  preamble would help.

- **Surface §1.4.3 "It is RECOMMENDED to use end-to-end TLS between the
  client and the resource server"** as a description note on `bearerAuth`.

- **Reference §8 "Native Applications" + §9 "Browser-Based Apps"**:
  the spec does not distinguish redirect URI types (private-use scheme,
  loopback, claimed https). At minimum, the `RedirectUri` description
  should mention the §8.4.1-§8.4.3 patterns and the loopback exception
  to exact-string matching.

- **Document `state` is not REQUIRED but RECOMMENDED for CSRF**
  (§2.3.3):
  > "Clients that have ensured that the authorization server supports
  >  the code_challenge parameter MAY rely on the CSRF protection
  >  provided by that mechanism. ... Otherwise, one-time use CSRF
  >  tokens carried in the state parameter that are securely bound to
  >  the user agent MUST be used for CSRF protection."
  The `State` parameter (oauth-openapi.yaml:549-557) cites RFC 6749
  §10.12; refresh to cite OAuth 2.1 §2.3.3 / §7.9.

- **Add an `examples` block for the `Location` header** showing the
  `iss` parameter alongside `code` and `state`.

- **Add a security considerations note** on the spec preamble linking
  to §7 (especially §7.5.4 about HTTP redirect status codes).

- **`x5t#S256` and `kid` matching rules** for JWK selection (cross-cuts
  RFC 7517) are out of OAuth 2.1 scope but worth a pointer.

- **`session_state` / `sid` for OIDC session management**: not in
  OAuth 2.1 but noting it as out-of-scope avoids questions.

---

## NOT APPLICABLE

- **§1.7 "Interoperability"**: lists optional companion specs (RFC 8414,
  RFC 7591, etc.) that the umbrella spec already models or references.

- **§1.8 "Compatibility with OAuth 2.0"**: meta-statement; the spec's
  posture (OAuth 2.1 defaults) is the operationalization.

- **§2.5 "Unregistered Clients"**: the draft says "the use of
  unregistered clients is beyond the scope of this specification";
  likewise outside the OpenAPI surface.

- **§7.1.x Access Token Security Considerations**: text guidance that
  cannot be enforced at the OpenAPI schema level. The audit covers
  schema-relevant items above (sender-constraining, audience
  restriction).

- **§7.5.x Authorization Code Security Considerations**: most items are
  AS-implementation behavior (one-time use, replay detection); the
  schema-relevant items are flagged in MISSING above.

- **§7.6 "Ensuring Endpoint Authenticity"**: TLS guidance covered by
  the spec's `https://{issuer}` server entry.

- **§7.10 "Clickjacking"** / **§7.12 "Open Redirection"** /
  **§7.13 "Transport Security"**: AS-side operational guidance, not
  modelable in OpenAPI beyond the description notes already suggested.

- **§8 "Native Applications"** subsections (loopback, private-use URI,
  embedded user agents): redirect-URI patterns; partly captured in
  the NICE-TO-HAVE about documenting §8.4 redirect types.

- **§9 "Browser-Based Apps"**: marked TODO in the draft itself ("Bring
  in the normative text of the browser-based apps BCP when it is
  finalized"); no normative content to validate against yet.

- **§11 "IANA Considerations"**: the draft says "This document does not
  require any IANA actions"; nothing to model.

- **Appendices A-F (ABNF, document history, etc.)**: format/process
  metadata, not API surface — except where the ABNF is referenced in
  WRONG above.
