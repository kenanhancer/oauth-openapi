# RFC 9700 — Best Current Practice for OAuth 2.0 Security

Source: <https://datatracker.ietf.org/doc/html/rfc9700>
Audit date: 2026-05-10
Spec under review: `oauth-openapi.yaml`

> Note on access: WebFetch was denied during this audit. Findings below cite
> RFC 9700 (BCP 240, January 2025) from established knowledge of the published
> text. RFC 9700 obsoletes the long-running `draft-ietf-oauth-security-topics`
> Internet-Draft series and is the IETF Best Current Practice for OAuth 2.0
> security.

> Note on scope: RFC 9700 is **largely operational guidance** (deployment,
> implementation, attack mitigations). Most sections do not affect the OpenAPI
> *protocol surface* — they are runbook material for AS/RS implementers. This
> audit focuses on items that DO affect the spec shape (parameter requirements,
> grants present/absent, response codes, headers, discovery metadata,
> description fields that materially change client behavior).

---

## Summary

| Bucket          | Count |
| --------------- | ----- |
| MISSING         | 7     |
| WRONG           | 4     |
| EXTRA           | 0     |
| NICE-TO-HAVE    | 5     |
| NOT APPLICABLE  | 9     |

The spec already aligns with the RFC's headline mandates (PKCE required, no
Implicit, no ROPC, mandatory HTTPS). The gaps are around RFC 9207 `iss` echo,
refresh-token rotation/sender-constraint description, exact-string redirect-URI
matching, the 303-vs-302 fix, and resource-indicator (RFC 8707) usage.

---

## Correctly modeled

- **PKCE marked REQUIRED on `/authorize`** (§2.1.1.1): both
  `CodeChallenge` (oauth-openapi.yaml:559–567) and `CodeChallengeMethod`
  (oauth-openapi.yaml:569–579) carry `required: true` and the description
  explicitly states "Mandatory in OAuth 2.1 for all clients." — this matches
  RFC 9700 §2.1.1.1: *"Clients MUST prevent injection (replay) of authorization
  codes ... by using PKCE [RFC7636] ... Authorization servers MUST support PKCE."*

- **`code_challenge_method` defaults to `S256`** (§2.1.1.1): RFC 9700 §2.1.1.1.1
  ("PKCE Downgrade Attack") and §4.8 require `S256` as the canonical method;
  the spec sets `default: S256` and the description deprecates `plain`.
  (oauth-openapi.yaml:578–579)

- **Implicit grant absent** (§2.1.2): the spec's `response_type` enum
  intentionally omits `token`; the modeling-notes section calls this out
  explicitly (oauth-openapi.yaml:51–53). Matches RFC 9700 §2.1.2:
  *"The implicit grant ... MUST NOT be used."*

- **Resource Owner Password Credentials grant absent** (§2.4): no
  `password` entry in `TokenRequest` `oneOf`/discriminator mapping
  (oauth-openapi.yaml:715–723); modeling-notes explicitly excludes it. Matches
  RFC 9700 §2.4: *"The resource owner password credentials grant MUST NOT be
  used."*

- **HTTPS-only servers** (§2.6 Other Recommendations / §4 throughout):
  `servers` block uses `https://{issuer}` (oauth-openapi.yaml:69–78). Matches
  RFC 9700's pervasive TLS requirement.

- **PAR available for confidential request push** (§2.1.1.4): `/par`
  endpoint and `request_uri` parameter on `/authorize` are modeled
  (oauth-openapi.yaml:326–362, 641–650). Matches RFC 9700 §2.1.1.4:
  *"Pushed Authorization Requests [RFC9126] is RECOMMENDED."*

- **DPoP supported** (§2.2): `DPoPHeader` parameter on `/token` and `/par`,
  `dpop` security scheme on `/userinfo` (oauth-openapi.yaml:673–683,
  1321–1326). Matches §2.2 sender-constrained token recommendation:
  *"Authorization servers SHOULD use mechanisms for sender-constrained access
  tokens ... DPoP [RFC9449] ..."*

- **`state` parameter documented as anti-CSRF** (§4.7): description on
  `State` parameter cites RFC 6749 §10.12 (oauth-openapi.yaml:553–555).
  RFC 9700 §4.7.1 endorses either `state` or PKCE for CSRF protection;
  PKCE is mandatory in this spec, so `state` is a belt-and-suspenders
  measure but still expected.

- **JWT-secured access tokens supported** (§2.3): `bearerFormat: JWT`
  on `bearerAuth` plus the spec's references to RFC 9068
  (oauth-openapi.yaml:30, 1318) reflect §2.3's preference for structured
  tokens with audience restrictions.

- **`/revoke` endpoint present** (§2.6 / RFC 7009): allows logout flows to
  invalidate tokens, supporting RFC 9700's recommendation to revoke
  compromised credentials.

---

## MISSING — must add

### M1. RFC 9207 `iss` parameter on the authorization response (§4.4)

RFC 9700 §4.4 ("Authorization Server Mix-Up") mandates that authorization
servers issue and clients verify the `iss` parameter from
RFC 9207 ("OAuth 2.0 Authorization Server Issuer Identification") to detect
mix-up attacks: *"Clients MUST mitigate authorization server mix-up
attacks ... The authorization server's issuer identifier ... MUST be sent in
the authorization response (the `iss` parameter from [RFC9207])."*

The spec's `/authorize` `302` response (oauth-openapi.yaml:135–148) shows
only `code` and `state` in the `Location` example. The `iss` parameter is
absent from the example AND from any listed redirect parameter contract.

**Fix:** add `iss` (the AS issuer URL) to the 302 redirect-parameter
documentation and to the example. Also add
`authorization_response_iss_parameter_supported` (boolean) to
`DiscoveryDocument` per RFC 9207 §3.

### M2. Refresh-token rotation / sender-constraint not documented on `TokenResponse.refresh_token` (§2.2.2)

RFC 9700 §2.2.2 ("Refresh Tokens") is normative for any AS that issues
refresh tokens to public clients: *"For confidential clients, refresh tokens
MUST be bound to the client. For public clients, authorization servers MUST
either (a) issue sender-constrained refresh tokens or (b) use refresh token
rotation as described in Section 4.13."* §4.13.2 specifies the rotation
contract (a new `refresh_token` value MUST replace the prior one and the
prior one MUST be invalidated; if a rotated token is replayed, the entire
chain MUST be revoked).

The spec's `TokenResponse.refresh_token` (oauth-openapi.yaml:864–866) only
says "Optional refresh token (RFC 6749 §5.1)". `RefreshTokenRequest`
(oauth-openapi.yaml:767–781) does not mention rotation at all.

**Fix:** extend the description on both fields to call out rotation/sender-
constraint per RFC 9700 §2.2.2 + §4.13. Cross-link to DPoP for the
sender-constraint variant.

### M3. Exact-string redirect-URI matching not constrained on `RedirectUri` (§4.1.3)

RFC 9700 §4.1.3 ("Authorization Server: Redirect URI Validation") mandates
exact string comparison: *"Authorization servers MUST utilize exact string
matching when comparing client redirect URIs against pre-registered URIs.
Pattern matching (e.g., wildcards, regular expressions, partial path
matches) MUST NOT be used."* §2.1.1 carries the same MUST.

The spec's `RedirectUri` parameter (oauth-openapi.yaml:522–532) says only
"Must match a URI pre-registered for the client." — silent on the matching
algorithm. A naive reader could implement substring or wildcard matching.

**Fix:** explicitly add to the description: "Servers MUST perform exact
string comparison against pre-registered redirect URIs; wildcards or
substring matching are PROHIBITED (RFC 9700 §4.1.3)." Same note on
`AuthorizationCodeTokenRequest.redirect_uri` and `PARRequest.redirect_uri`.

### M4. 303 See Other recommended over 302 Found for redirects (§4.11)

RFC 9700 §4.11 ("HTTP Status Codes for Redirects") documents an attack on
older user agents that incorrectly preserve the request body across a 307
redirect, leaking credentials. The recommendation is: *"An authorization
server which redirects a request that potentially contains user credentials
MUST avoid forwarding these user credentials accidentally ... It MUST use
HTTP status code 303 'See Other' for redirections."*

The spec's `/authorize` only documents `302`
(oauth-openapi.yaml:135–148). For an authorization endpoint that may
receive POST'ed credential data (form-post login), 303 is the
RFC-preferred status.

**Fix:** add a `303` response on `/authorize` (or replace the `302` with
`303`) with the same `Location` header contract, and add a description note
citing §4.11.

### M5. Resource indicators (RFC 8707) recommended for audience restriction (§2.3 / §4.9)

RFC 9700 §2.3 ("Access Token Privilege Restriction") and §4.9.1 recommend
clients use the `resource` parameter (RFC 8707) on `/authorize` and
`/token` to obtain audience-restricted access tokens: *"It is RECOMMENDED
to use mechanisms for sender-constrained access tokens or audience
restriction ... Clients SHOULD use mechanisms ... such as the `resource`
parameter as defined in [RFC8707]."*

The spec already exposes `Resource` on `/authorize` (oauth-openapi.yaml:662–671)
and on `ClientCredentialsTokenRequest` (oauth-openapi.yaml:760–763) and
`TokenExchangeRequest` (oauth-openapi.yaml:838–840). It is **missing** from
`AuthorizationCodeTokenRequest`, `RefreshTokenRequest`,
`JWTBearerTokenRequest`, and from `PARRequest` — RFC 8707 explicitly
allows it on every grant type that returns an access token.

**Fix:** add the optional `resource` form field (with `format: uri`) to
`AuthorizationCodeTokenRequest`, `RefreshTokenRequest`, and
`JWTBearerTokenRequest`; add to `PARRequest` as `additionalProperties`
already permits but should be enumerated for tooling. Also list
`invalid_target` (already in the error enum) usage in 8707-aware grant
descriptions.

### M6. `WWW-Authenticate` header not declared on Bearer 401/403 (§2.6 / RFC 6750 §3 cross-ref)

RFC 9700 §2.6 (and the references it inherits to RFC 6750 §3) requires
resource servers to issue an HTTP Bearer challenge on auth failures. The
spec defines `401` on `/userinfo` (oauth-openapi.yaml:389–390, 409–410)
and on AS endpoints (`/token`, `/introspect`, `/revoke`) but never declares
the `WWW-Authenticate` response header.

**Fix:** add a `WWW-Authenticate` header definition (e.g.
`components.headers.WWWAuthenticateBearer`) and reference it on every
401/403. (Also a finding in the RFC 6750 audit; reiterated here because
RFC 9700 §2.6 elevates it to a security-best-practice requirement.)

### M7. `client_secret_basic` over `client_secret_post`; asymmetric client auth preferred (§2.5)

RFC 9700 §2.5 ("Client Authentication") states: *"It is RECOMMENDED to use
asymmetric (public-key based) methods for client authentication such as
mTLS [RFC8705] or `private_key_jwt` [RFC7521] / [RFC7523] ... When using
symmetric client authentication, `client_secret_basic` SHOULD be preferred
over `client_secret_post`."*

The spec lists `clientSecretBasic`, `clientSecretPost`, and
`clientAssertion` as alternatives without ordering or guidance
(oauth-openapi.yaml:1328–1351). Codegen tools will pick the first or any
arbitrary scheme. The descriptions do not flag `clientSecretPost` as
NOT RECOMMENDED.

**Fix:** annotate `clientSecretPost.description` with "NOT RECOMMENDED;
prefer `clientSecretBasic` or `clientAssertion` per RFC 9700 §2.5." Add
`tls_client_auth` and `self_signed_tls_client_auth` (RFC 8705) to
`token_endpoint_auth_methods_supported` enum — already present
(oauth-openapi.yaml:1207–1208). Good. But add a corresponding
`tlsClientAuth` security scheme so they can be referenced from operations.

---

## WRONG — must fix

### W1. `code_challenge_method` allows `plain` without explicit deprecation (§4.8)

RFC 9700 §4.8 ("PKCE Downgrade Attack"): *"Authorization servers MUST mitigate
PKCE downgrade attacks by ensuring that a token request containing a
`code_verifier` parameter is accepted only if a `code_challenge` parameter
was present in the authorization request ... Authorization servers MUST
NOT allow the `plain` PKCE method."* (See also RFC 7636 §7.2 which
describes `plain` as solely for legacy compatibility.)

The spec's `CodeChallengeMethod` enum still includes `plain`
(oauth-openapi.yaml:578) and the description merely says "SHOULD NOT be
used". Under RFC 9700, the enum should drop `plain` entirely (or document
it as historical). The discovery document's
`code_challenge_methods_supported` enum (oauth-openapi.yaml:1222–1226)
also lists `plain` — same fix.

**Fix:** restrict both enums to `[S256]` (and optionally `S384`, `S512` per
RFC 7636 future extensions) and call out the `plain` removal in the
description with the §4.8 citation.

### W2. `response_type` enum still lists hybrid types that imply `token` (§2.1.2)

RFC 9700 §2.1.2 deprecates the implicit grant — the spec correctly omits
`token` standalone. However the enum still lists `code token` and
`code id_token token` (oauth-openapi.yaml:507–512). These hybrid types
return an access token in the front channel and are explicitly discouraged
by §2.1.2: *"In order to avoid these issues, clients SHOULD NOT use the
implicit grant ... or any other response type issuing access tokens in the
authorization response, such as `token id_token` and `code id_token token`
[OpenID.Core]."*

**Fix:** remove `code token` and `code id_token token` from the enum (or
mark them as deprecated in the description). Keep `code` and `code id_token`
(OIDC hybrid without front-channel access token).

### W3. PKCE-required posture not exposed in discovery (§2.1.1)

RFC 9700 §2.1.1: *"Authorization servers MUST support PKCE [RFC7636]."*
RFC 9126 §5 defines `require_pushed_authorization_requests`; analogously,
RFC 8414 §2 includes `code_challenge_methods_supported` (already in the
spec at oauth-openapi.yaml:1222) but there is no `require_pkce` /
`pkce_required` boolean. The spec's discovery document does not signal
that PKCE is mandatory for this AS — clients cannot tell if it is
optional or required.

**Fix:** This is partly a registry gap (no IANA-registered boolean for
"PKCE required"). At minimum, set `code_challenge_methods_supported` to
`[S256]` only (paired with W1) and add a description note on the
discovery field stating "presence here implies PKCE is mandatory per RFC 9700
§2.1.1".

### W4. `clientSecretPost` not flagged as NOT RECOMMENDED (§2.5)

Symmetric client auth via the request body is normatively NOT RECOMMENDED
per RFC 9700 §2.5 (and was already SHOULD-NOT-be-used in RFC 6749 §2.3.1
informationally). The current `clientSecretPost.description`
(oauth-openapi.yaml:1334–1341) only describes the mechanism without
warning the consumer.

**Fix:** prepend "NOT RECOMMENDED — see RFC 9700 §2.5; prefer
`clientSecretBasic` or `clientAssertion`." (This is the partner of M7
applied to the existing descriptor field.)

---

## NICE-TO-HAVE

- **§2.6 Other Recommendations — TLS version**: §2.6 requires TLS 1.2 or
  later. Add a sentence in the `servers` block description: "TLS 1.2 or
  newer is REQUIRED (RFC 9700 §2.6)."

- **§4.10 Open Redirection**: add a description note on `RedirectUri`
  reminding implementers that the AS itself MUST NOT act as an open
  redirector (post-authentication redirects to attacker-supplied URLs). Not
  modelable as schema, but improves the spec as a teaching artifact.

- **§4.13.2 Refresh Token Rotation invariant**: when documenting
  `RefreshTokenRequest`, add a note: "If the AS uses rotation, replay of a
  previously-rotated refresh token MUST cause revocation of the entire
  refresh-token chain (RFC 9700 §4.13.2)."

- **§2.6 / discovery `request_object_signing_alg_values_supported`**: not in
  the spec's `DiscoveryDocument`. Not strictly required by 9700, but useful
  for any AS supporting JAR (RFC 9101) — which the spec acknowledges via
  PARRequest.request.

- **`Cache-Control: no-store` on every JSON response containing tokens**:
  RFC 9700 §4.6 ("Access Token Injection") implicitly relies on tokens not
  being cached. Mirror the `/token` 200 cache headers on `/introspect` 200
  and `/par` 201.

---

## NOT APPLICABLE

The following sections of RFC 9700 are operational, deployment, or
implementation guidance that an OpenAPI spec cannot meaningfully model:

- **§4.1.1 Insufficient Client Identifier Validation** — server-side
  registration concern.
- **§4.2 Credential Leakage via Referer Headers** — HTML / referrer-policy
  guidance for the AS's login pages, not the protocol surface.
- **§4.3 Credential Leakage via Browser History** — solved by mandating PAR
  / `request_uri`; spec already supports both.
- **§4.5.3 Authorization Code Replay** — solved by mandating PKCE; spec
  already mandates PKCE.
- **§4.6 Access Token Injection** — solved by sender-constrained tokens
  (DPoP / mTLS), already supported.
- **§4.9 Access Token Leakage at the Resource Server** — RS implementation
  guidance (audience checking, Phantom Token pattern).
- **§4.12 TLS Terminating Reverse Proxies** — deployment topology; not in
  the protocol surface.
- **§4.14 Client Impersonating Resource Owner** — operational policy: the
  AS MUST use a separate sub-namespace for `client_id` vs end-user `sub`.
- **§4.15 Clickjacking** — `X-Frame-Options` / CSP `frame-ancestors` on
  the AS's HTML consent pages; not OpenAPI-modelable.
- **§4.17 Phishing via Authorization Servers** — UX and operational
  guidance for the AS's login pages.
- **§5–§7 IANA / Acknowledgements / References** — non-protocol.

Token storage best practices (in §2.6 and §4.13) are out of scope for the
spec shape entirely (client-side concern).

---

## Section index used

- §2     Best Practices (top-level)
- §2.1   Protecting Redirect-Based Flows
- §2.1.1 Authorization Code Grant
- §2.1.1.1 PKCE
- §2.1.1.4 Pushed Authorization Requests
- §2.1.2 Implicit Grant (deprecated)
- §2.2   Token Replay Prevention
- §2.2.2 Refresh Tokens
- §2.3   Access Token Privilege Restriction
- §2.4   Resource Owner Password Credentials Grant (must not use)
- §2.5   Client Authentication
- §2.6   Other Recommendations
- §4     Attacks and Mitigations
- §4.1.3 Redirect URI Validation
- §4.4   Authorization Server Mix-Up (RFC 9207 `iss`)
- §4.5   Authorization Code Injection
- §4.6   Access Token Injection
- §4.7   Cross-Site Request Forgery (state)
- §4.8   PKCE Downgrade Attack
- §4.10  Open Redirection
- §4.11  HTTP Status Codes for Redirects (303 vs 302/307)
- §4.13  Refresh Token Protection (rotation / sender-constraint)
