# Revocation & introspection — RFC 7009, 7662, 9701

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 7009](#rfc-7009-oauth-20-token-revocation) | August 2013 | Proposed Standard | mostly | 0 | 3 | 6 |
| [RFC 7662](#rfc-7662-oauth-20-token-introspection) | October 2015 | Proposed Standard | mostly | 0 | 7 | 7 |
| [RFC 9701](#rfc-9701-json-web-token-jwt-response-for-oauth-token-introspection) | January 2025 | Proposed Standard | partial | 0 | 6 | 6 |

**Cluster notes.** Scope and method: I read RFC 7009, RFC 7662 and RFC 9701 in full from references/rfc-sources, plus the two May-2026 rfc-validation notes and references/audit/rfc-audit-synthesis.md. I grepped every element in the snapshot oauth-openapi.yaml (2,704 lines) and parsed the IANA oauth-parameters registries (token-type-hint, token-introspection-response, extensions-error, client-metadata, AS-metadata). I also cross-checked OAuth 2.1 draft-16, RFC 10017 and the active OAuth WG drafts, and pulled the RFC Editor errata pages. As concrete evidence, I generated servers from a copy of the YAML with openapi-generator 7.26.0 (go-server and python-fastapi) and ran a Go probe and regex tests. The snapshot and the live repo were not modified.

Status: all three documents are vendored and are Proposed Standards with no updates or obsoletes. No newer RFC replaces them. RFC 9701 (Jan 2025) is the most recent document in this cluster. Two newer documents add requirements here. RFC 10017 (BCP 212, Aug 2026) §6.3.3.4 makes the AS responsible for CORS on the revocation and introspection endpoints when browser apps use them. OAuth 2.1 draft-16 §3.2 says the same, and its Appendix D lists RFC 7009 and RFC 7662 as well-established extensions.

Overall: the core wire surface is in good shape. The May-2026 MISSING and WRONG findings are largely fixed. The remaining problems, highest impact first:
(1) RFC 9701 §5 says an inactive token_introspection claim MUST NOT carry other members. The YAML reuses IntrospectionResponse, whose description says other fields 'MAY be omitted', and adds no constraint. The generated Go model marshals an inactive token as {"active":false,"aud":{},"cnf":{}}.
(2) RFC 7662 §2.2 defines exp, iat and nbf as 'Integer timestamp', but the YAML types them as non-integer NumericDate. The generated Go model uses float32 and sends 1419356238 as 1419356300.
(3) /introspect security offers no option for body-based client authentication (client_secret_post, private_key_jwt), even though IntrospectionRequest includes ClientAuthFields and RFC 9701 §4's own example uses private_key_jwt in the body.
(4) The JWT pattern rejects compact JWEs whose encrypted-key segment is empty (alg dir or ECDH-ES).
(5) RFC 9701 client metadata is absent, because the YAML has no dynamic client registration surface at all.
(6) Several MUST and SHOULD behaviours appear nowhere in the descriptions: the token-ownership check on /revoke, hint-search rules, the AS validity and audience checks, 400 for unauthenticated callers, and RS-identifying caller tokens.

Cross-cluster hand-offs:
- RFC 8414: descriptions, defaults and the 'none' ban for the revocation_/introspection_endpoint_auth_* fields.
- RFC 7591: a /register endpoint and a ClientMetadata schema, which would carry the RFC 9701 §6 fields.
- RFC 7523bis-11 §4 (in the RFC Editor queue): the aud of a client_assertion MUST be the AS issuer identifier as its sole value. This applies to client assertions sent to /revoke and /introspect. security-topics-update-03 §2.1.1.3 names the revocation endpoint as an audience-injection target.
- RFC 8693: act and may_act are registered introspection members.
- RFC 9449 §6.2: token_type MUST be DPoP for DPoP-bound tokens.
- Browser-based-apps cluster: CORS across all AS endpoints.

Drafts to watch:
- draft-ietf-oauth-deferred-token-response-00 §7: a urn:ietf:params:oauth:token-type:deferral-code token_type_hint and new AS metadata revocation_endpoint_token_type_values_supported.
- draft-ietf-oauth-refresh-token-expiration-03 §7: refresh_token_timeout and authorization_expires_in in introspection responses for refresh tokens.

Errata:
- RFC 7009 EID 6663 (Reported, Technical) proposes Bearer access-token authentication at /revoke. It is not verified and should not be adopted.
- RFC 7662 EID 4764 (Verified, Editorial) fixes §3.1 registry wording. EID 7607 (Reported) adds 'or client' to revoked-by.
- RFC 9701 has no errata.

Housekeeping: oauth-openapi-modular/ is generated from the monolith and carries the same text, so re-run split-oauth-openapi.py after any fix. The python-fastapi generator also stacks Basic and Bearer dependencies and ignores the mtls and {} alternatives. That is a generator limitation, not a YAML defect.

## RFC 7009 OAuth 2.0 Token Revocation

*August 2013 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** Defines a revocation endpoint. A client POSTs a token there (form-encoded), optionally with a token_type_hint, and authenticates exactly as it would at the token endpoint. Servers MUST support revoking refresh tokens and SHOULD support revoking access tokens. Revoking a refresh token SHOULD also invalidate the access tokens from the same grant. The AS returns HTTP 200 even when the token is already invalid; errors use the RFC 6749 §5.2 format plus the new unsupported_token_type code. The RFC also creates the IANA 'OAuth Token Type Hints' registry and allows CORS for browser apps.

**Why it was created.** RFC 6749 gave clients no standard way to tell the AS that tokens were no longer needed, for example on logout, identity change or app uninstall. Abandoned refresh tokens and grants stayed valid and kept appearing in users' lists of authorized apps, so they could be abused later. RFC 7009 lets clients clean up those credentials and the related grant.

<details><summary>Already modeled in the YAML (14)</summary>

- POST /revoke operation (paths./revoke.post, L273-310), tag Token Lifecycle (L91-92)
- application/x-www-form-urlencoded request body -> components.schemas.RevocationRequest (L289-294; schema L1794-1808)
- token REQUIRED (RevocationRequest required:[token], L1798-1802)
- token_type_hint OPTIONAL, open string tied to the IANA Token Type Hints registry with examples access_token/refresh_token (L1803-1808)
- Client authentication per RFC 6749 §2.3: security clientSecretBasic | mtls | {} (L307-310) plus ClientAuthFields allOf (L1795-1796; schema L1175-1200: client_id, client_secret, client_assertion, client_assertion_type const jwt-bearer)
- Public clients identify by client_id under the empty security option (L310; ClientAuthFields.client_id L1178-1184)
- Cascade semantics: revoking a refresh token SHOULD also invalidate its access tokens; revoking an access token MAY also revoke its refresh token (description L279-283)
- HTTP 200 with no body, also for unknown or invalid tokens (L284-285, L296-297)
- Cache-Control: no-store / Pragma: no-cache on 200 (L298-302; headers L990-999)
- 400 error per RFC 6749 §5.2 -> responses.OAuthError -> schemas.ErrorResponse (L303-304; L1063-1073; L1465-1533)
- unsupported_token_type error code (ErrorResponse.error enum L1492-1493)
- 401 invalid_client with WWW-Authenticate: Basic (L305-306 -> responses.ClientAuthError L1108-1125; headers.WWWAuthenticateBasic L1026-1037)
- HTTPS-only server URL https://{issuer} (servers L77-86)
- AS metadata: revocation_endpoint (OAuthServerMetadata L1973-1976), revocation_endpoint_auth_methods_supported (L2057-2059), revocation_endpoint_auth_signing_alg_values_supported (L2060-2062), mtls_endpoint_aliases.revocation_endpoint (L2005)

</details>

**Follow-up on the May-2026 validation notes.** The May-2026 notes listed 3 MISSING, 2 WRONG and 5 nice-to-haves. All 5 MISSING and WRONG items are fixed: unsupported_token_type is in the enum (L1493); the public-client {} security option exists (L310); Cache-Control/Pragma are on the 200 (L298-302); the cascade direction is corrected (L279-283); and 401 is tied to invalid_client through ClientAuthError (L305-306, L1108-1114). Nice-to-haves: 2 are fixed (RFC 6749 §5.2 is cited through OAuthError at L1064; token_type_hint is opened to the registry at L1803-1808) and 3 remain open: the CORS note, a request example on RevocationRequest, and the hint's MUST-extend-search / MAY-ignore semantics. The prior audit missed the token-ownership check (§2.1/§5) and 503/Retry-After (§2.2.1); both are reported as gaps above.

**Notes.** IANA's OAuth Token Type Hints registry has 3 values: access_token, refresh_token, and pct (UMA 2.0 Grant). The YAML's open string accepts all of them; pct is UMA-specific, so listing it in the catalog is enough. Erratum EID 6663 (Reported, not verified) proposes Bearer access-token authentication at /revoke; it is not normative and should not be adopted. Client assertions sent to /revoke are covered by draft-ietf-oauth-rfc7523bis-11 §4 (in the RFC Editor queue: aud MUST be the AS issuer identifier as its sole value), and draft-ietf-oauth-security-topics-update-03 §2.1.1.3 lists the revocation endpoint as an audience-injection target. The ClientAuthFields.client_assertion description (L1191-1196) should eventually say this; that belongs to the assertion cluster. Watch draft-ietf-oauth-deferred-token-response-00 §7, which adds a deferral-code URN hint and AS metadata revocation_endpoint_token_type_values_supported. No contradictions with RFC 7009 were found.

### Findings (0 high · 3 medium · 6 low)

1. **[MEDIUM] Gap: Token-ownership check before revoking**  
   *Reference:* RFC 7009 §2.1, §5  
   §2.1: the AS first validates the client credentials, 'then verifies whether the token was issued to the client making the revocation request. If this validation fails, the request is refused and the client is informed of the error'. §5: 'The token being revoked must also belong to the requesting client.' The /revoke description (L278-285) only says unknown tokens get 200. A server built from it could let any authenticated client revoke another client's tokens, a cross-client denial of service.  
   *Suggested change:* Append to paths./revoke.post.description: 'The AS authenticates the client (or identifies a public client by client_id) and MUST verify that the token was issued to that client; otherwise it refuses the request with an RFC 6749 §5.2 error (HTTP 400). Unknown or already-invalid tokens still return 200 (RFC 7009 §2.1, §2.2, §5).'  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: token_type_hint processing rules and when to use unsupported_token_type**  
   *Reference:* RFC 7009 §2.1, §2.2, §2.2.1, §4.1.1, §5  
   RevocationRequest.token_type_hint (L1803-1808) only says the values are open. The YAML does not say that: the AS MUST extend its search across all supported token types if the hint does not find the token; it MAY ignore the hint; an invalid hint value 'is ignored ... and does not influence the revocation response'; and unsupported_token_type (L1493) is only for a token type the AS cannot revoke (for example access tokens), not for unknown hint values. §5 also requires DoS countermeasures, because misleading hints cause extra lookups. The prior audit's nice-to-have on this is still open.  
   *Suggested change:* Extend the token_type_hint description with these rules, and add an inline comment or description next to unsupported_token_type in ErrorResponse.error: 'revocation endpoint only (RFC 7009 §4.1.1): the presented token type is not revocable here'. Add the RFC example as a schema-level example: token=45ghiukldjahdnhzdauz&token_type_hint=refresh_token.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: CORS for browser-based clients**  
   *Reference:* RFC 7009 §2.3; RFC 10017 §6.3.3.4; draft-ietf-oauth-v2-1-16 §3.2  
   RFC 7009 §2.3 says the endpoint MAY support CORS when it serves user-agent-based applications. RFC 10017 (BCP 212, Aug 2026) §6.3.3.4 states the AS 'is responsible for supporting CORS' on revocation and introspection endpoints that browser apps call. OAuth 2.1 draft-16 §3.2 says these endpoints 'will also need to have the CORS headers defined'. The YAML has no OPTIONS operations and no Access-Control-* headers anywhere (grep for CORS/Access-Control finds nothing), even though SPA logout is a primary use of /revoke. This was a prior nice-to-have and is still open.  
   *Suggested change:* Add components.headers.AccessControlAllowOrigin (plus Allow-Headers/Allow-Methods for preflight) and reference it on the /revoke (and /token) 200, 400 and 401 responses. Add an options operation on /revoke whose 204 response documents the preflight. Add a sentence to the /revoke description citing RFC 7009 §2.3 and RFC 10017 §6.3.3.4.  
   *Verifier: confirmed.*

4. **[LOW] Gap: 503 Service Unavailable with Retry-After, and DoS throttling**  
   *Reference:* RFC 7009 §2.2.1, §5  
   §2.2.1: on 503 'the client must assume the token still exists and may retry'; the server may send Retry-After. /revoke models only 200, 400 and 401. §5 says DoS countermeasures 'MUST be applied to the revocation endpoint' (RFC 6819 §4.4.1.11). On the wire that usually means 429 with Retry-After, which /par already models.  
   *Suggested change:* Add '503': {description: 'Service unavailable; the token was NOT revoked and the client retries later (RFC 7009 §2.2.1)', headers: {Retry-After: {schema: {type: string}}}}, and optionally a '429' with Retry-After.  
   *Verifier: partially correct —* /revoke should gain a 503 response per RFC 7009 §2.2.1, optionally with a Retry-After header. The YAML has no Retry-After header component at all, and the /par 429 (L471-472) is description-only, so this is new work, not reuse. RFC 7009 mentions only 503; a 429 is an implementation choice for meeting the §5 DoS MUST.

5. **[LOW] Gap: Statement of which token types the server can revoke**  
   *Reference:* RFC 7009 §2, §5  
   'Implementations MUST support the revocation of refresh tokens and SHOULD support the revocation of access tokens.' §5 adds that without access-token revocation, access tokens survive the revocation of their refresh token. The description only says 'Revokes an access or refresh token'.  
   *Suggested change:* Add to the /revoke description: 'MUST support refresh_token revocation; SHOULD support access_token revocation. A server that cannot revoke access tokens answers unsupported_token_type (RFC 7009 §2, §2.2.1).'  
   *Verifier: confirmed.*

6. **[LOW] Gap: Revocation endpoint metadata constraints**  
   *Reference:* RFC 7009 §2; RFC 8414 §2  
   revocation_endpoint (L1973-1976) is format: uri with no HTTPS constraint, although RFC 7009 §2 says the URL MUST be HTTPS and an HTTP alias MUST NOT be published as the revocation endpoint. revocation_endpoint_auth_methods_supported (L2057-2059) has no description or default; RFC 8414 §2 says the default is client_secret_basic and values come from the Token Endpoint Authentication Methods registry. revocation_endpoint_auth_signing_alg_values_supported (L2060-2062) does not say it MUST be present when *_jwt methods are listed, or that 'none' MUST NOT be used.  
   *Suggested change:* Add pattern '^https://' and a description to revocation_endpoint and mtls_endpoint_aliases.revocation_endpoint. Give revocation_endpoint_auth_methods_supported a description, default: [client_secret_basic], and the same item enum as token_endpoint_auth_methods_supported (L2041-2048). Add items: {type: string, not: {const: none}} to the signing-alg array.  
   *Verifier: confirmed.*

7. **[LOW] Gap: JSONP variant (GET with callback parameter)**  
   *Reference:* RFC 7009 §2.3  
   The legacy JSONP mode (GET /revoke?token=...&callback=...) is not modeled. Leaving it out is correct for OAuth 2.1, because query-string tokens leak and §2.3 itself warns of script injection, but the YAML never says the omission is deliberate.  
   *Suggested change:* Add one line to the /revoke description: 'The legacy JSONP GET variant of RFC 7009 §2.3 is intentionally not supported; only POST is defined.'  
   *Verifier: confirmed.*

8. **[LOW] Incorrect: The /revoke description states the cascade SHOULD without its condition, and leaves out grant revocation and immediate invalidation** — *found by the verifier*  
   *Reference:* RFC 7009 §2.1 (also §1)  
   The /revoke description states the cascade SHOULD without its condition, and leaves out grant revocation and immediate invalidation. The assessment lists the cascade as correctly modeled.  
   *Suggested change:* Reword L279-283: 'If the revoked token is a refresh token and the AS supports access-token revocation, the AS SHOULD also invalidate all access tokens from the same grant. Revoking an access token MAY also revoke the refresh token, and per AS policy the underlying grant may be revoked too. Invalidation is immediate, and implementations minimise propagation delay (RFC 7009 §2.1).'

9. **[LOW] Gap: RFC 7009 says the server SHOULD also accept revocations at the plain-HTTP alias** — *found by the verifier*  
   *Reference:* RFC 7009 §2; draft-ietf-oauth-v2-1-16 §1.5  
   RFC 7009 says the server SHOULD also accept revocations at the plain-HTTP alias. The YAML neither models this nor states that the profile declines it. The assessment's metadata gap covers only the 'MUST NOT publish' half.  
   *Suggested change:* Add one sentence to /revoke: 'This OAuth 2.1 profile does not offer the plain-HTTP revocation alias that RFC 7009 §2 recommends (SHOULD), because draft-ietf-oauth-v2-1 §1.5 requires https for all AS URLs. An HTTP alias is never published.'

## RFC 7662 OAuth 2.0 Token Introspection

*October 2015 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** Defines an introspection endpoint. A protected resource authenticates and POSTs a token (with an optional token_type_hint), and gets back a JSON object whose REQUIRED 'active' boolean says whether the token is currently valid. Optional metadata members describe the token: scope, client_id, username, token_type, exp, iat, nbf, sub, aud, iss and jti. An inactive, unknown or not-allowed token gets HTTP 200 {"active": false}, not an error. The RFC also creates the IANA 'OAuth Token Introspection Response' registry, which later RFCs extend (cnf, act, may_act, authorization_details, acr, auth_time and others).

**Why it was created.** Access tokens are opaque by design, and RFC 6749 never defined how a resource server learns what a token means. Deployments therefore used proprietary shared databases or service buses, or self-contained JWTs. RFC 7662 standardized how an RS asks the AS for a token's state and authorization context. This is essential for opaque reference tokens and for seeing revocation immediately. It also requires callers to be authenticated so attackers cannot scan for valid tokens.

<details><summary>Already modeled in the YAML (16)</summary>

- POST /introspect operation (paths./introspect.post, L315-363)
- Form-encoded body -> components.schemas.IntrospectionRequest (L328-333; schema L1680-1696, allOf ClientAuthFields L1681-1682)
- token REQUIRED (L1684-1688)
- token_type_hint OPTIONAL, open string per the RFC 7009 §4.1.2 registry (L1689-1696)
- Endpoint requires caller authorization, with no anonymous option: security clientSecretBasic | mtls | bearerAuth (L360-363)
- 200 application/json -> IntrospectionResponse; 'always 200, even for inactive tokens' (L335-345, L1699-1701)
- Cache-Control: no-store / Pragma: no-cache on 200 (L337-341)
- active REQUIRED boolean (required L1705; property L1708-1712)
- scope (L1713-1714), client_id (L1715-1716), username (L1717-1718), token_type (L1719-1721)
- exp / iat / nbf via NumericDate (L1722-1729)
- sub (L1730-1731), aud as string or array of StringOrURI (L1732-1737), iss (L1738-1739), jti (L1740-1741)
- Extensibility: additionalProperties: true plus a description pointing to §2.2 (L1699-1706)
- Registry extensions from later RFCs: acr and auth_time (RFC 9470 §6.2, L1742-1747), cnf (RFC 7800 / RFC 8705 §3.2 / RFC 9449 §6.2, L1748-1753 -> Confirmation L2575-2591), authorization_details (RFC 9396 §9.2, L1754-1758)
- 400 -> responses.OAuthError (L356-357)
- 401 -> responses.IntrospectionAuthError with WWW-Authenticate Basic or Bearer (L358-359; L1126-1142; headers.WWWAuthenticateBasicBearer L1038-1050)
- AS metadata: introspection_endpoint (L1969-1972), introspection_endpoint_auth_methods_supported (L2063-2065), introspection_endpoint_auth_signing_alg_values_supported (L2066-2068), mtls_endpoint_aliases.introspection_endpoint (L2006)

</details>

**Follow-up on the May-2026 validation notes.** The May-2026 notes listed 6 MISSING and 4 WRONG.
- Fixed (6): M1 open token_type_hint (L1689-1696); M3 Cache-Control/Pragma (L337-341); M4 WWW-Authenticate through IntrospectionAuthError (L1126-1142, L1038-1050); M6 additionalProperties plus the extensibility note (L1699-1706); W1 aud items typed StringOrURI (L1732-1737); W4 bearerAuth on /introspect (L363).
- Partly fixed (1): W3. token_type now has a description (L1721), but it is not tied to RFC 6749 §5.1 and omits the RFC 9449 §6.2 MUST.
- Open (1): M5 caching guidance.
- Not adopted (1): M2, the 403 response. This is defensible, because RFC 7662 §2.3 specifies 401 even for insufficient privileges.
- Fix introduced a new deviation (1): W2. The recommended switch to NumericDate (number) contradicts RFC 7662 §2.2 'Integer timestamp' (see the first incorrect item).
The 'token has no description' note is fixed (L1688).

**Notes.** Citation precision (no fix required): authorization_details in introspection responses is RFC 9396 §9.2 (the YAML says §9 at L1703 and L1756), and introspection of DPoP-bound tokens is RFC 9449 §6.2 (L1752 cites §6.1, which covers JWTs). The IANA confirmation-methods registry also lists jwe and jku (RFC 7800), which are absent from Confirmation; that belongs to the proof-of-possession cluster. Errata: EID 4764 (Verified, Editorial) fixes the §3.1 registry wording; EID 7607 (Reported) adds 'or client' to 'revoked by'. Neither changes the wire. Watch draft-ietf-oauth-refresh-token-expiration-03 §7, which adds refresh_token_timeout and authorization_expires_in to introspection responses for refresh tokens. Generator evidence comes from openapi-generator 7.26.0 go-server, using a copy in the scratch work directory.

### Findings (0 high · 7 medium · 7 low)

1. **[MEDIUM] Gap: Validity checks the AS must perform, and caller-specific responses**  
   *Reference:* RFC 7662 §4 (also §2.2, §5)  
   §4 says the AS 'MUST perform all applicable checks against a token's state': expiry, not-before, revocation, signature, and 'whether or not the token can be used at the resource server making the introspection call'. It also SHOULD require protected resources to be specifically authorized to call the endpoint. §2.2 lets the AS tailor responses per caller (for example limiting scopes), and §5 says privacy-sensitive data MUST be protected. The /introspect description (L320-324) and the active description (L1710-1712, 'Whether the token is currently valid') mention none of this. The audience check in particular is commonly missed by implementers.  
   *Suggested change:* Expand paths./introspect.post.description with the §4 checklist, including 'return active:false when the token is not usable at the calling RS', the 'specifically authorized' SHOULD, and per-RS scope narrowing and data minimisation (§2.2, §5).  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: token_type_hint processing rules**  
   *Reference:* RFC 7662 §2.1  
   IntrospectionRequest.token_type_hint (L1689-1696) leaves out two rules: if the hint does not locate the token, the AS MUST extend its search across all supported token types; and the AS MAY ignore the hint.  
   *Suggested change:* Append to the description: 'If the token is not found using the hint, the AS MUST search all supported token types; the AS MAY ignore the hint (RFC 7662 §2.1).'  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: act and may_act introspection members (registered by RFC 8693)**  
   *Reference:* RFC 7662 §2.2, §3.1; RFC 8693 §4.1, §4.4, §7.5  
   IANA's OAuth Token Introspection Response registry (25 entries) includes act and may_act from RFC 8693, and the IANA diff confirms both are absent from the YAML. The YAML models token exchange at /token, yet IntrospectionResponse (L1698-1758) has neither member. RSs need act because RFC 8693 §4.1 says the consumer 'MUST only consider the token's top-level claims and the party identified as the current actor'. additionalProperties: true lets these members validate, but the go-server model generated from this YAML has no additional-properties map, so it cannot emit any unmodeled member.  
   *Suggested change:* Add to IntrospectionResponse (and to JWTAccessTokenClaims): act: {type: object, additionalProperties: true, description: 'Current actor (RFC 8693 §4.1); nested act = prior actors, informational only'} and may_act: {type: object, additionalProperties: true, description: 'Authorized actor (RFC 8693 §4.4)'}.  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: token_type member semantics, including the DPoP rule**  
   *Reference:* RFC 7662 §2.2; RFC 6749 §5.1; RFC 9449 §6.2  
   token_type (L1719-1721) says only 'Typically Bearer (RFC 6750) or DPoP (RFC 9449)'. It is not tied to the RFC 6749 §5.1 access token types, and it does not state RFC 9449 §6.2: 'If the token_type member is included in the introspection response, it MUST contain the value DPoP' for DPoP-bound tokens. The May-2026 W3 finding is only partly addressed.  
   *Suggested change:* Change the description to: 'Access token type per RFC 6749 §5.1 / IANA OAuth Access Token Types (Bearer, DPoP); MUST be DPoP when the token is DPoP-bound (cnf.jkt), RFC 9449 §6.2.' Optionally add if: {required: [cnf], properties: {cnf: {required: [jkt]}}} then: {properties: {token_type: {const: DPoP}}}.  
   *Verifier: confirmed.*

5. **[MEDIUM] Incorrect: L1722-1729 components.schemas.IntrospectionResponse.exp/iat/nbf -> $ref NumericDate (L2450-2456: type number, 'fractional seconds are permitted')**  
   *Reference:* RFC 7662 §2.2, §4  
   RFC 7662 §2.2 defines exp, iat and nbf as 'Integer timestamp, measured in the number of seconds since January 1 1970 UTC'. The YAML types them as a non-integer number. openapi-generator 7.26.0 go-server maps this to float32. A probe built from the generated model serialized exp=1419356238 (the RFC's own example value) as 1419356300, 62 seconds later than the real expiry. That error also undermines §4's rule that a response 'MUST NOT be cached beyond' exp. The change came from the May-2026 W2 recommendation, which misread RFC 7662.  
   *Suggested change:* Override the three members in IntrospectionResponse with {type: integer, format: int64, minimum: 0, description: 'Integer seconds since the epoch (RFC 7662 §2.2)'}. Keep NumericDate for JWT claims, but add format: double to NumericDate so generators never choose float32 (this also protects auth_time and JWTIntrospectionResponse.iat).  
   *Verifier: confirmed.*

6. **[MEDIUM] Incorrect: L1708-1712 components.schemas.IntrospectionResponse.properties.active.description**  
   *Reference:* RFC 7662 §2.2, §4  
   The description says 'If false, all other fields MAY be omitted', which implies they may also be included. RFC 7662 §2.2 says the AS 'SHOULD NOT include any additional information about an inactive token', and §4 says an inactive response 'SHOULD NOT contain any additional claims beyond the required active claim'. The schema-level description at L1700-1701 ('only {"active": false} is included') is correct; the property description contradicts it.  
   *Suggested change:* Reword to: 'If false, the response SHOULD contain only {"active": false} (RFC 7662 §2.2, §4).' Add if: {properties: {active: {const: false}}, required: [active]} then: {maxProperties: 1}, or model an InactiveIntrospectionResponse variant with additionalProperties: false.  
   *Verifier: confirmed.*

7. **[MEDIUM] Incorrect: L360-363 paths./introspect.post.security (clientSecretBasic | mtls | bearerAuth), compared with IntrospectionRequest allOf ClientAuthFields (L1681-1682) and securitySchemes.clientSecretBasic.description (L2668-2674)**  
   *Reference:* RFC 7662 §2.1; RFC 6749 §2.3; RFC 9701 §4  
   RFC 7662 §2.1 accepts any RFC 6749 client authentication, and RFC 9701 §4's normative-context example authenticates with private_key_jwt in the request body. The request schema carries client_secret_post and client_assertion fields, and the clientSecretBasic description says body methods are 'covered' by the empty {} security option. /introspect has no {} option, so a request authenticated only by body credentials matches none of the security requirements, and spec-driven middleware rejects it. Omitting {} was probably meant to show that authentication is mandatory, but it also excludes methods the RFC permits.  
   *Suggested change:* Add '- {}' as /token and /par already do. In the operation description, state that the empty option is valid ONLY when ClientAuthFields carry client_secret_post or client_assertion credentials, and that requests with no caller authentication MUST be rejected (RFC 7662 §2.1, §4), with HTTP 400 on an RFC 9701 server (§5).  
   *Verifier: confirmed.*

8. **[LOW] Gap: Other registered members: vot, vtm (RFC 8485) and permissions (UMA 2.0)**  
   *Reference:* RFC 7662 §3.1; RFC 8485 §3.2, §7.4  
   The IANA diff also lists vot, vtm (Vectors of Trust) and permissions (Kantara UMA Federated Authorization) as absent. The registry entries ace_profile, cnonce, cti and exi come from RFC 9200 (ACE, CoAP/CBOR) and do not apply to an HTTP/JSON OAuth 2.1 AS.  
   *Suggested change:* Optionally add vot: {type: string} and vtm: {type: string, format: uri} with RFC 8485 references. Mention the remaining registry members in the IntrospectionResponse description as 'registered, not modeled'.  
   *Verifier: confirmed.*

9. **[LOW] Gap: Descriptions for scope, client_id, username, sub and jti**  
   *Reference:* RFC 7662 §2.2  
   scope (L1713-1714) does not say it is a space-separated list in RFC 6749 §3.3 format. client_id, username, sub and jti (L1715-1718, L1730-1731, L1740-1741) have no descriptions of their RFC 7662 meanings: the client that requested the token, a human-readable resource-owner identifier, a machine-readable subject, and a token identifier.  
   *Suggested change:* Add one-line descriptions, for example scope: 'Space-separated scopes (RFC 6749 §3.3); the AS MAY limit them per calling RS (RFC 7662 §2.2)'.  
   *Verifier: confirmed.*

10. **[LOW] Gap: Extra request parameters and the 'unknown state' rule**  
   *Reference:* RFC 7662 §2.1  
   The endpoint 'MAY accept other OPTIONAL parameters' (for example the client's IP address), and if the AS cannot determine the token's state without more information it SHOULD return active:false. The schema is open, which is correct, but neither rule is documented. The response shape is already modeled, so this is documentation only.  
   *Suggested change:* Add both sentences to the IntrospectionRequest description.  
   *Verifier: confirmed.*

11. **[LOW] Gap: Caching guidance**  
   *Reference:* RFC 7662 §2.2, §4  
   The May-2026 M5 finding is still open. The RS MAY cache responses but MUST NOT cache them beyond exp, and designers MUST weigh how long a revoked token could stay accepted from cache. None of this appears in the /introspect description (L320-324).  
   *Suggested change:* Add: 'Protected resources MAY cache responses but MUST NOT cache beyond exp; shorter caches see revocation sooner (RFC 7662 §2.2, §4).'  
   *Verifier: confirmed.*

12. **[LOW] Gap: introspection_endpoint_auth_* metadata semantics**  
   *Reference:* RFC 8414 §2 (caller authentication per RFC 7662 §2.1)  
   introspection_endpoint_auth_methods_supported (L2063-2065) has no description. Its valid values come from the Token Endpoint Authentication Methods registry OR the OAuth Access Token Types registry (for example 'Bearer'), and it has no default ('MUST be determined by other means'). introspection_endpoint_auth_signing_alg_values_supported (L2066-2068) does not say it MUST be present when *_jwt methods are listed, or that 'none' MUST NOT be used.  
   *Suggested change:* Add descriptions stating those rules, and add items: {type: string, not: {const: none}} to the signing-alg array.  
   *Verifier: confirmed.*

13. **[LOW] Incorrect: L1043-1045 components.headers.WWWAuthenticateBasicBearer.description**  
   *Reference:* RFC 7662 §2.1; RFC 9449 §6.2  
   'DPoP is intentionally absent; the introspection endpoint does not accept DPoP-bound tokens' presents a profile choice as if it were a protocol rule, and it is easy to misread. RFC 7662 §2.1 allows 'a separate OAuth 2.0 access token such as the bearer token', which means any access token type. RFC 9449 §6.2 explicitly defines introspection OF DPoP-bound tokens.  
   *Suggested change:* Reword to: 'This profile does not accept a DPoP-bound access token as the caller credential at /introspect (RFC 7662 §2.1 would allow any OAuth access token); DPoP-bound tokens can still be introspected (RFC 9449 §6.2).'  
   *Verifier: confirmed.*

14. **[LOW] Incorrect: The Cache-Control: no-store header on the /introspect and /revoke 200 responses carries a description citing an RFC requirement that does not apply to them** — *found by the verifier*  
   *Reference:* RFC 7662 §2.2, §4 (also RFC 7009 §2.2)  
   The Cache-Control: no-store header on the /introspect and /revoke 200 responses carries a description citing an RFC requirement that does not apply to them. Nothing says the RS may still cache introspection results.  
   *Suggested change:* Override the header description on these two responses: 'Profile choice, not an RFC 7662 or RFC 7009 requirement. It forbids storage by HTTP caches; the RS may still keep the result in application memory, never beyond exp (RFC 7662 §2.2, §4).' Alternatively, drop the headers from the bodiless /revoke 200.

## RFC 9701 JSON Web Token (JWT) Response for OAuth Token Introspection

*January 2025 · Proposed Standard · YAML coverage: **partial** · relevance to an AS: optional · vendoring: already-vendored*

**What it is.** Extends token introspection so that a resource server can send 'Accept: application/token-introspection+jwt' and receive a signed JWT instead of plain JSON. The JWT can optionally be signed and then encrypted. It carries iss (the AS), aud (the RS), iat, and a 'token_introspection' claim that wraps the RFC 7662 members, so they cannot be confused with top-level JWT claims. The RFC adds client metadata (per-RS signing and encryption algorithms) and AS metadata (supported algorithms). It also tightens security: callers MUST be authenticated, inactive tokens yield only {active:false}, and the JWT SHOULD NOT carry top-level sub or exp.

**Why it was created.** A plain JSON introspection response proves nothing about its origin beyond TLS. Some resource servers need verifiable, non-repudiable assurance that the AS issued the response, for example when the AS takes legal liability for the data, or when verified identity data is used to issue certificates for qualified electronic signatures (§1). They may also need the personal data in the response to be confidential.

<details><summary>Already modeled in the YAML (9)</summary>

- Response media type application/token-introspection+jwt on the /introspect 200, body = compact JWT (L346-355 -> schemas.JWT L2434-2441)
- Accept-header negotiation documented (L352, L1767-1768). This is the correct OAS 3.1 approach, because header parameters named Accept are ignored and the response content map is the negotiation mechanism.
- JOSE header typ = token-introspection+jwt documented in prose (L352-353, L1766-1767)
- Decoded-payload documentation schema JWTIntrospectionResponse with required [iss, aud, iat, token_introspection] (L1763-1789, required at L1771). It is intentionally unwired, per the audit synthesis.
- token_introspection claim -> $ref IntrospectionResponse, nested rather than flattened (L1787-1789)
- Other JWT claims permitted (additionalProperties: true, L1772)
- Signed or signed-then-encrypted compact form, 3 or 5 segments (L349-350; JWT pattern L2440)
- AS metadata: introspection_signing_alg_values_supported (L2071-2073), introspection_encryption_alg_values_supported (L2074-2076), introspection_encryption_enc_values_supported (L2077-2079)
- Caller authentication mandatory: no {} option on /introspect (L360-363)

</details>

**Follow-up on the May-2026 validation notes.** There is no rfc-validation file for RFC 9701. It was added in the 2026-06-07 update recorded in references/audit/rfc-audit-synthesis.md (the media type, the JWTIntrospectionResponse documentation schema, and the 3 introspection_*_values_supported metadata fields), so this is its first validation.

**Notes.** JWTIntrospectionResponse is intentionally an unwired documentation schema (see the audit synthesis update log), so the oas3-unused-component lint hint on it is expected and is not a gap. Modeling the Accept request header is not possible in OAS 3.1 (header parameters named Accept are ignored), so negotiating through the response content map is correct. No errata exist. The client-metadata gap depends on adding RFC 7591 dynamic client registration to the YAML.

### Findings (0 high · 6 medium · 6 low)

1. **[MEDIUM] Gap: Client metadata introspection_signed_response_alg, introspection_encrypted_response_alg and introspection_encrypted_response_enc**  
   *Reference:* RFC 9701 §6, §10.1  
   All three are absent (the IANA diff confirms it), and the YAML has no client-registration surface at all; only registration_endpoint exists (L1965-1968). The defaults change the wire: signing defaults to RS256; encryption is off unless an alg is set; enc defaults to A128CBC-HS256; enc MUST NOT be specified without alg; and signing plus encryption produces a Nested JWT.  
   *Suggested change:* Add components.schemas.ClientMetadata (RFC 7591 §2), or at least an RFC 9701 fragment, with introspection_signed_response_alg: {type: string, default: RS256, not: {const: none}}, introspection_encrypted_response_alg: {type: string}, introspection_encrypted_response_enc: {type: string, default: A128CBC-HS256}, and dependentRequired: {introspection_encrypted_response_enc: [introspection_encrypted_response_alg]}. Wire it into a /register operation in the RFC 7591 work.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: HTTP 400 for unauthenticated introspection requests**  
   *Reference:* RFC 9701 §5 (Note), §8.2  
   'An AS compliant with this specification MUST refuse to serve introspection requests that don't authenticate the caller and return an HTTP status code 400.' The /introspect 400 (L356-357) is the generic OAuthError, and the 401 (L358-359) says 'Authentication failed'. Nothing tells implementers that a request with no caller authentication must get 400, and generated security middleware typically answers 401 or 403.  
   *Suggested change:* Give /introspect its own 400 description: 'Malformed request, or (RFC 9701 §5) a request with no caller authentication; RFC 9701 servers return 400 here, and 401 is for presented-but-invalid credentials (RFC 7662 §2.3).'  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: Caller credentials must identify the resource server**  
   *Reference:* RFC 9701 §3, §4, §8.2  
   §4: an access token used to call /introspect must be one 'that is issued to the RS and identifies the RS as the subject'. §8.2: because RFC 7662 allows access tokens that do not identify the caller, the AS 'MUST require all requests to the token introspection endpoint to be authenticated'. §3: the AS MUST identify, authenticate and authorize resource servers, MUST restrict an RS's credentials to the calls it needs, and MUST determine whether the RS is an audience of the token. bearerAuth (L2637-2646) and the /introspect description are generic. See also RFC 7662 incorrect item 3: body-based client authentication cannot currently be expressed.  
   *Suggested change:* Add to the /introspect description: 'With bearerAuth, the access token MUST be issued to and identify the calling RS (sub = RS); anonymous or non-identifying tokens are rejected (RFC 9701 §4, §8.2). active:true is returned only when the calling RS is an audience of the token (RFC 9701 §3, §5).'  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: Top-level sub and exp SHOULD NOT appear in the response JWT**  
   *Reference:* RFC 9701 §5, §8.1  
   'The JWT SHOULD NOT include the sub and exp claims, as an additional measure to prevent misuse of the JWT as an access token.' JWTIntrospectionResponse (L1763-1789) allows any additional claims and says nothing about this. If the response carries sub and exp, an attacker could present it to a resource server as if it were an access token (cross-JWT confusion).  
   *Suggested change:* Add to the JWTIntrospectionResponse description: 'The JWT SHOULD NOT contain top-level sub or exp; the token's subject and expiry go inside token_introspection (RFC 9701 §5, §8.1).' Optionally adopt not: {anyOf: [{required: [sub]}, {required: [exp]}]} as a stricter reference-server profile.  
   *Verifier: confirmed.*

5. **[MEDIUM] Incorrect: L1787-1789 components.schemas.JWTIntrospectionResponse.properties.token_introspection -> $ref IntrospectionResponse (whose active description at L1710-1712 says 'If false, all other fields MAY be omitted')**  
   *Reference:* RFC 9701 §5  
   RFC 9701 §5: if the access token is invalid, expired, revoked, or not intended for the calling RS, the AS 'MUST set the value of the active member in the token_introspection claim to false and MUST NOT include other members'. The YAML allows other members and encodes no constraint. A go-server model generated from this YAML (openapi-generator 7.26.0) marshals IntrospectionResponse{Active:false} as {"active":false,"aud":{},"cnf":{}}, which violates this MUST.  
   *Suggested change:* Change token_introspection to allOf: [{$ref: IntrospectionResponse}] plus if: {properties: {active: {const: false}}, required: [active]} then: {maxProperties: 1}. Describe it as: 'active=false (invalid, expired, revoked, or wrong audience) means no other members (MUST, RFC 9701 §5); the AS SHOULD narrow scope to this RS.' Also fix the shared active wording (see RFC 7662 incorrect item 2).  
   *Verifier: partially correct —* The YAML neither documents nor encodes RFC 9701 §5's MUST NOT for an inactive token_introspection claim, and the shared active wording (L1710-1712) contradicts it. That is a medium-severity documentation and constraint defect in an unwired documentation schema. The generated Go output ({active:false, aud:{}, cnf:{}}) comes from non-pointer struct fields in the generator and is unrelated to the missing constraint.

6. **[MEDIUM] Incorrect: L2434-2441 components.schemas.JWT.pattern (used by the /introspect application/token-introspection+jwt body, L346-348)**  
   *Reference:* RFC 9701 §6, §10.3.1; RFC 7516 §7.1; RFC 7518 §4.5, §4.6  
   The pattern requires every segment to be non-empty. A compact JWE made with alg 'dir' or 'ECDH-ES' (direct key agreement) has an EMPTY JWE Encrypted Key segment (RFC 7518 §4.5, §4.6; RFC 7516 §7.1), and RFC 9701 §10.3.1 notes that JWT segments 'may be the empty string'. A regex test confirmed that an ECDH-ES response of the form 'eyJ...' + '..' + 'iv.ct.tag' fails the pattern. An RS that registered introspection_encrypted_response_alg=ECDH-ES would therefore receive valid responses that the schema rejects. The same pattern affects UserInfo application/jwt.  
   *Suggested change:* Use pattern: '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$|^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$' (a JWS has 3 non-empty segments; a JWE has 5, where the encrypted key and IV may be empty). This was tested: it accepts RS256 JWS, ECDH-ES and RSA-OAEP JWEs, and still rejects unsecured alg-none tokens.  
   *Verifier: confirmed.*

7. **[LOW] Gap: Nested JWT when the response is encrypted**  
   *Reference:* RFC 9701 §5, §6; RFC 7519 §5.2  
   'If the JWT is signed and encrypted, it MUST be a Nested JWT', and §6 says the response is signed then encrypted. The media-type description (L349-350) only says 'Signed (optionally encrypted)'. A server that encrypted the claims directly would violate §5.  
   *Suggested change:* Reword L349-355: 'JWS-signed; when the RS registered introspection_encrypted_response_alg, the JWS is then encrypted as a Nested JWT (JWE with cty "JWT"), per RFC 9701 §5, §6 and RFC 7519 §5.2.'  
   *Verifier: confirmed.*

8. **[LOW] Gap: JOSE header (typ, alg) not modeled**  
   *Reference:* RFC 9701 §5, §8.1  
   typ = token-introspection+jwt appears only in prose. §8.1 relies on typ to stop substitution attacks, and the JWT must be cryptographically secured, so alg 'none' is not acceptable.  
   *Suggested change:* Add a documentation schema JWTIntrospectionResponseHeader: {required: [typ, alg], properties: {typ: {const: token-introspection+jwt}, alg: {type: string, not: {const: none}}, kid: {type: string}}} and reference it from the JWTIntrospectionResponse description.  
   *Verifier: confirmed.*

9. **[LOW] Gap: Precision of iss and iat**  
   *Reference:* RFC 9701 §5  
   iss 'MUST be set to the issuer URL of the authorization server', but L1774-1776 types it as StringOrURI with the description 'Issuer (the authorization server)'. iat is the time the response was created, which is different from the token's own iat inside token_introspection; L1784-1786 says only 'Issued-at time'.  
   *Suggested change:* iss: add format: uri and 'MUST equal the AS metadata issuer'. iat: 'Time the introspection response was created (not the token's iat).'  
   *Verifier: confirmed.*

10. **[LOW] Gap: Descriptions for the RFC 9701 AS metadata fields**  
   *Reference:* RFC 9701 §7  
   introspection_signing_alg_values_supported, introspection_encryption_alg_values_supported and introspection_encryption_enc_values_supported (L2071-2079) have no descriptions (the AS SHOULD publish them; alg is content-key encryption and enc is content encryption). Because the response must be signed, 'none' does not belong in the signing array.  
   *Suggested change:* Add descriptions citing RFC 9701 §7, and add items: {type: string, not: {const: none}} to introspection_signing_alg_values_supported.  
   *Verifier: confirmed.*

11. **[LOW] Gap: Per-RS release policy**  
   *Reference:* RFC 9701 §5, §9  
   The AS SHOULD narrow the scope value to the scopes relevant to the calling RS. Which identity claims are released is decided by RS-specific policy, and release of personal data MUST have a legal basis. None of this is documented.  
   *Suggested change:* Add one paragraph to the JWTIntrospectionResponse description.  
   *Verifier: confirmed.*

12. **[LOW] Gap: Nothing tells the AS's own protected resource (/userinfo) to reject JWTs whose typ is not at+jwt** — *found by the verifier*  
   *Reference:* RFC 9701 §8.1; RFC 9068 §4  
   Nothing tells the AS's own protected resource (/userinfo) to reject JWTs whose typ is not at+jwt. A token-introspection+jwt response signed with the same AS keys could therefore be presented there as an access token.  
   *Suggested change:* Add to bearerAuth, or to the /userinfo description: 'JWT access tokens MUST carry typ at+jwt. Reject any other typ, in particular token-introspection+jwt, and reject JWTs that lack the required access-token claims (RFC 9068 §4, RFC 9701 §8.1).'

## Verifier corrections to the summaries above

- Generator version is wrong in three places: cluster_notes, RFC 7662 incorrect #1 and RFC 9701 incorrect #1 all say openapi-generator 7.26.0. The models were actually generated by 7.14.0. Evidence: the generated Go server's .openapi-generator/VERSION file reads 7.14.0, and the generation log shows the jar from the pip package openapi_generator_cli-7.14.0, whose manifest has implementation-version 7.14.0. The 7.26.0 appears only in the copied openapitools.json, which that jar ignores; the repo itself pins 7.14.0 (openapitools.json, commit 1a2a22e). The float32 and empty-struct observations reproduce with 7.14.0. 7.26.0 was never run.
- RFC 7009 summary: 'Revoking a refresh token SHOULD also invalidate the access tokens from the same grant' leaves out the condition in RFC 7009 §2.1, 'and the authorization server supports the revocation of access tokens'. The YAML (L279-282) has the same omission.
- RFC 7662 why_created: 'Access tokens are opaque by design' overstates the RFC. RFC 7662 §1 says 'the contents of tokens are opaque to clients'. RFC 6749 does not make tokens opaque to resource servers.
- RFC 7009 prior_validation_followup counts the nice-to-have 'cite RFC 6749 §5.2 explicitly in the /revoke 400 description' as fixed. Nothing was changed for it. In the pre-audit commit 367e59d (2026-05-09), OAuthError already read 'Standard OAuth 2.0 error response (RFC 6749 §5.2)' and /revoke's 400 already used $ref OAuthError, and that is still the state today (L303-304, L1064). The correct tally is 1 fixed (the token_type_hint is now open to the registry) and 4 open or unchanged; the §5.2 citation is arguably adequate as it stands.
- RFC 9701 incorrect #1 rates the defect 'high'. That is overstated: JWTIntrospectionResponse is an unwired documentation schema, and the Go marshal output is a generator artifact. The same probe emits 'aud':{} and 'cnf':{} for active tokens as well, and the proposed if/then fix would not change that code. Medium is the right severity.
- RFC 7662 incorrect #3 calls RFC 9701 §4's example a 'normative-context example'. The RFC labels it a 'non-normative example request'. The finding itself stands, and git history shows it is a regression introduced by commit 6cb2077 (2026-06-10), which dropped the clientSecretPost and clientAssertion marker schemes from /introspect without adding {}.
- The assessment flags only W2 as a misreading in the May-2026 validation notes, but both notes contain text that is not in the RFCs. 7009-token-revocation.md quotes a public-client sentence ('If the client was issued a client password ... Section 3.2.1') that does not appear in RFC 7009, and says §2.2 references RFC 6749 §5.1 cache directives, though RFC 7009 has no caching text. It also cites the wrong sections: CORS and JSONP are §2.3, not §2.2; revocation_endpoint metadata comes from RFC 8414, not RFC 7009 §3; the TLS requirement is in §2, not §4. 7662-introspection.md quotes 'the cache must take into account possible state changes of the token' (M5), which is not in RFC 7662. It appends 'See [JWT], Section 4.1.3 for details' to the aud definition (W1), which is also not in the RFC. Its M3 and W2 premises are likewise absent from the RFC text. This matters because those notes are kept as repo references.
- Drafts to watch leaves out draft-ietf-oauth-status-list, which is in the RFC Editor queue. IANA already lists status_list_aggregation_endpoint with reference 'RFC-ietf-oauth-status-list-21'. Its §1.1 positions it as an alternative to RFC 7662 introspection for checking the status of issued access tokens. It probably belongs to the JWT/SD-JWT cluster, but readers of this cluster should know about it.
