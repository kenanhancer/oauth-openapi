# Bearer tokens & HTTP authentication — RFC 6750, 8996, 7617, 9110

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 6750](#rfc-6750-the-oauth-20-authorization-framework-bearer-token-usage) | October 2012 | Proposed Standard (Standards Track); updated by RFC 8996 and RFC 9700 | mostly | 0 | 3 | 10 |
| [RFC 8996](#rfc-8996-deprecating-tls-10-and-tls-11) | March 2021 | Best Current Practice (BCP 195) | none | 0 | 0 | 2 |
| [RFC 7617](#rfc-7617-the-basic-http-authentication-scheme) | September 2015 | Proposed Standard (Standards Track); obsoletes RFC 2617 together with RFC 7235, 7615 and 7616 | mostly | 0 | 2 | 4 |
| [RFC 9110](#rfc-9110-http-semantics) | June 2022 | Internet Standard (STD 97) | mostly | 0 | 1 | 7 |

**Cluster notes.** Scope: RFC 6750 (vendored), RFC 8996, RFC 7617 and the parts of RFC 9110 the YAML uses (§4.2.2, §10.2.1-10.2.3, §11.1-11.6, §15.4.3-15.4.4, §15.5.1/.2/.4/.6/.14). All texts were read from the local copies.

Progress since the May-2026 audit: the YAML now has reusable WWW-Authenticate components (L1000-1050), ProtectedResourceError on both 401 and 403 for GET/POST /userinfo, a form-body access_token on POST /userinfo, and no longer sets bearerFormat: JWT. No high-severity gaps remain.

Open medium items:
(1) POST /userinfo security (bearerAuth|dpop) makes the documented RFC 6750 §2.2 body method unreachable.
(2) The RS 401 body is ErrorResponse with required `error`, which conflicts with RFC 6750 §3.1's SHOULD NOT for unauthenticated requests.
(3) No WWW-Authenticate header is `required: true` anywhere (RFC 9110 §15.5.2 and RFC 6750 §3 MUST).
(4) /userinfo has no 400 invalid_request.
(5) The challenge parameters scope, realm and error_uri, plus the token68 syntax of token values, are undocumented.
(6) The 405 on /par lacks `Allow`.
(7) client_secret_basic form-urlencoding is undocumented.
(8) The YAML still calls Basic PREFERRED and client_secret_post NOT RECOMMENDED (RFC 6749 §2.3.1), but OAuth 2.1 (-11 through -16 §2.4.1) makes client_secret_post a MUST and Basic a MAY.
(9) No TLS version floor (RFC 8996 / BCP 195) is stated anywhere.

IANA check: the IANA absence list has no value attributed to RFC 6750, 7617, 9110 or 8996. The Basic and Bearer HTTP auth schemes, the Bearer token type and invalid_request/invalid_token/insufficient_scope are all present.

Verified today:
- RFC 6750 is updated by RFC 8996 and RFC 9700. RFC 9700 §4.3.2 says clients MUST NOT use the query method. OAuth 2.1-16 §5.1 removes that method and requires the RS to ignore it, but keeps the form-body method.
- BCP 195 = RFC 8996 + RFC 9325 + RFC 9852 (July 2026; new protocols using TLS MUST require TLS 1.3).
- TLS 1.3 is now RFC 9846 (July 2026). It obsoletes RFC 8446 and RFC 5246 and is the version OAuth 2.1-16 §1.5 cites.

Corrections to the prior audit:
- The 6750 note's claim that OAuth 2.1 forbids §2.2 is wrong; only the query method (§2.3) is removed.
- The synthesis's claim that `type: http, scheme: dpop` is invalid OpenAPI is wrong. DPoP is IANA-registered, and OAS 3.1 accepts registered schemes.

Cross-cluster observations, to route elsewhere:
- L1010-1011 cites RFC 9449 §5 for the `algs` challenge parameter, which is defined in RFC 9449 §7.1.
- The ErrorResponse comment at L1507 cites 'DPoP §10' for invalid_dpop_proof/use_dpop_nonce. Those codes are defined in §5, §7.1 and §8-9 and registered in §12.2.
- The /introspect security list (L360-363) has no `{}` option, although IntrospectionRequest allows body-based client authentication. This is the same unreachable-method pattern as POST /userinfo.

Vendoring: RFC 6750 is already vendored. Vendor RFC 8996 (it formally updates the vendored RFC 6749 and 6750) and RFC 7617 (30 KB; defines the Basic scheme modeled by clientSecretBasic). Keep RFC 9110 catalog-only, with section links.

## RFC 6750 The OAuth 2.0 Authorization Framework: Bearer Token Usage

*October 2012 · Proposed Standard (Standards Track); updated by RFC 8996 and RFC 9700 · YAML coverage: **mostly** · relevance to an AS: required-oauth21 · vendoring: already-vendored*

**What it is.** RFC 6750 defines the 'Bearer' access-token type: any party holding the token can use it, with no proof of a cryptographic key, so the token must be protected in transit and in storage. It defines three ways to present a token to a resource server. The `Authorization: Bearer <token>` header is the one resource servers MUST support. The others are a form-encoded `access_token` body parameter and an `access_token` URI query parameter; the query method is discouraged and removed by OAuth 2.1. When a request fails, the resource server answers with a `WWW-Authenticate: Bearer` challenge (realm, scope, error, error_description, error_uri) using the codes invalid_request (400), invalid_token (401) and insufficient_scope (403). Its security section explains why TLS, short lifetimes and audience restriction matter for tokens that work for whoever holds them.

**Why it was created.** RFC 6749 deliberately left out how a client presents an access token to a resource server. OAuth 1.0 (RFC 5849) had required clients to sign every request, which developers found hard to get right. The WRAP profiles (credited in RFC 6750's acknowledgements) and then OAuth 2.0 moved to simple tokens protected by TLS. RFC 6750 standardised that simplest token type and a uniform challenge and error format, so clients and resource servers from different vendors interoperate. It also spelled out the threats that come with bearer semantics: token disclosure, redirect, replay and forgery. Proof-of-possession alternatives came later (RFC 8705 mTLS, RFC 9449 DPoP).

<details><summary>Already modeled in the YAML (12)</summary>

- §2.1 Authorization: Bearer header: components.securitySchemes.bearerAuth (type http, scheme bearer) L2637-2646; applied on GET /userinfo L516-518, POST /userinfo L566-568 and /introspect L360-363
- §2.2 form-encoded access_token body parameter: paths./userinfo.post.requestBody (application/x-www-form-urlencoded, access_token) L532-545
- §2.3 URI query method correctly not modeled; the prohibition (OAuth 2.1 §5.1, RFC 9700 §4.3.2) is documented in components.schemas.ProtectedResourceMetadata.bearer_methods_supported (enum header/body/query) L2296-2304
- §3 WWW-Authenticate Bearer challenge: components.headers.WWWAuthenticateBearerDPoP L1000-1025 (examples with error and error_description) via components.responses.ProtectedResourceError L1091-1107; Bearer challenge at /introspect via WWWAuthenticateBasicBearer L1038-1050 and IntrospectionAuthError L1126-1142
- §3 'other auth-params MAY be used': resource_metadata (RFC 9728 §5.1) example L1024; acr_values/max_age (RFC 9470 §3) example L1025
- §3.1 401 and 403 responses on GET /userinfo L512-515 and POST /userinfo L562-565
- §3.1/§6.2 error codes in components.schemas.ErrorResponse.error enum: invalid_request L1479, invalid_token L1490, insufficient_scope L1491
- §3 character set for error_description (%x20-21 / %x23-5B / %x5D-7E): ErrorResponse.error_description pattern L1518-1524; error_uri as absolute URI L1525-1528
- §4/§6.1 'Bearer' token type: TokenResponse.token_type examples L1420-1427; IntrospectionResponse.token_type L1719-1721; Cache-Control: no-store and Pragma: no-cache on the /token 200 L250-254
- Token format left to the implementation (opaque or JWT), bearerFormat deliberately omitted: TokenResponse.access_token L1411-1419, bearerAuth.description L2640-2646
- §5.2/§5.3 limited lifetime and audience restriction: JWTAccessTokenClaims required [iss, exp, aud, sub, client_id, iat, jti] L2521; TokenResponse.expires_in L1428-1432; RFC 8707 resource parameter L880-895 and ResourceIndicators L1203-1218
- §5.2/§5.3 TLS (https) only: servers[0].url 'https://{issuer}' L77-86

</details>

**Follow-up on the May-2026 validation notes.** The May-2026 note (6750-bearer-token.md) listed 10 actionable items: 4 MISSING, 2 WRONG and 4 NICE-TO-HAVE.

Fixed (4):
- WWW-Authenticate is now declared on every RS 401 via ProtectedResourceError → WWWAuthenticateBearerDPoP (still not required: true).
- 403 has been added to GET and POST /userinfo.
- bearerFormat: JWT was removed; bearerAuth L2640-2646 now explains opaque-or-JWT.
- Example challenges were added (L1021-1025, L1048-1050).

Partially fixed (2):
- Challenge parameter set: error and error_description are shown, but realm, scope and error_uri are still undocumented.
- §2.2/§2.3: the form-body access_token is now modeled on POST /userinfo and the query ban is documented in bearer_methods_supported. However, bearerAuth.description still says nothing, and the POST security requirement blocks the body method.

Open (4):
- Error-code → HTTP-status mapping; there is also no 400 on /userinfo.
- Cache-Control: no-store on RS errors (non-normative, not re-raised).
- Realm convention.
- §5 security text (TLS, lifetimes) on bearerAuth.

Correction to the note: it said OAuth 2.1 forbids both §2.2 and §2.3. OAuth 2.1 (-15/-16 §5.1.2) keeps the form-encoded body method; only the URI-query method is removed. The note's YAML line numbers are stale.

**Notes.** The vendored text was verified against rfc-editor.org per the orchestrator's facts.

Not applicable to an OpenAPI contract, but worth keeping on the implementation checklist for the planned server:
- Client-side MUSTs in §5.2/§5.3: validate TLS chains including revocation, verify the RS identity, and don't keep tokens in clear-text cookies.
- The §5.2 rule that tokens stay confidential between a TLS-terminating front end and the back end.

§2.3 (URI query) is correctly not modeled: OAuth 2.1-16 §5.1 removes it and RFC 9700 §4.3.2 forbids clients from using it. The bearer_methods_supported description (L2299-2304) cites RFC 9700 §4.3.2 and OAuth 2.1 §5.1 together for 'resource servers MUST ignore'. Only OAuth 2.1 §5.1 states the RS rule; RFC 9700 constrains clients only.

OAuth 2.1-16 §5 restates RFC 6750 §2.1, §2.2, §3 and §3.1 almost verbatim, so these findings apply equally to the OAuth 2.1 profile.

Builder note: an RS that accepts both schemes MUST reject a DPoP-bound token presented as Bearer (RFC 9449 §7.2).

### Findings (0 high · 3 medium · 10 low)

1. **[MEDIUM] Gap: Mandatory WWW-Authenticate on protected-resource 401/403**  
   *Reference:* RFC 6750 §3 (also OAuth 2.1-16 §5.3.1)  
   components.headers.WWWAuthenticateBearerDPoP (L1000-1025) is referenced by ProtectedResourceError (L1100-1101) but has no `required: true` (the OpenAPI default is false). The contract therefore treats the challenge as optional on /userinfo 401/403 (L512-515, L562-565). RFC 6750 §3 says the RS MUST include it whenever the request lacks credentials or the token does not enable access, which covers the 403 insufficient_scope case too. Contract tests and mock servers will not flag a missing challenge.  
   *Suggested change:* Add `required: true` to components.headers.WWWAuthenticateBearerDPoP (L1000). This is safe because ProtectedResourceError is its only user and is used only for 401/403. Add to its description: 'MUST be present on every resource-server 401/403 (RFC 6750 §3) and on a 400 invalid_request (cf. RFC 9449 §7.2 Fig. 19).'  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Access-token value syntax (b64token/token68) and unguessable reference tokens**  
   *Reference:* RFC 6750 §2.1 (b64token), §2.2 (ASCII), §5.2; RFC 9110 §11.2 (token68); OAuth 2.1-16 §5.1.1; RFC 6749 §A.12, §10.10  
   Bearer credentials are `"Bearer" 1*SP b64token`, where b64token = 1*( ALPHA / DIGIT / "-" / "." / "_" / "~" / "+" / "/" ) *"=". RFC 6749 §A.12 allows any VSCHAR in access_token, including space, quotes and %. An AS built from the YAML could therefore mint Bearer tokens that cannot be placed in the Authorization header, which every RS MUST support. Neither TokenResponse.access_token (L1411-1419) nor the POST /userinfo access_token field (L539-545, which §2.2 also requires to be ASCII-only) has a pattern. Nothing states that opaque reference tokens MUST be infeasible to guess (RFC 6750 §5.2; at most 2^-128 guessing probability per RFC 6749 §10.10).  
   *Suggested change:* Add to TokenResponse.access_token.description: 'When token_type is Bearer or DPoP the value MUST match token68 (RFC 6750 §2.1 / RFC 9110 §11.2): ^[A-Za-z0-9._~+/-]+=*$. Opaque reference tokens MUST be infeasible to guess (RFC 6750 §5.2; RFC 6749 §10.10).' Optionally enforce this with an OAS 3.1 if/then on token_type; N_A token-exchange results can carry other token types, so don't apply the pattern unconditionally. Add `pattern: '^[A-Za-z0-9._~+/-]+=*$'` to paths./userinfo.post.requestBody access_token (L539).  
   *Verifier: confirmed.*

3. **[MEDIUM] Incorrect: L566-568 paths./userinfo.post.security (vs. requestBody access_token at L532-545)**  
   *Reference:* RFC 6750 §2.2; OAuth 2.1-16 §5.1.2; OIDC Core §5.3.1  
   The operation documents the RFC 6750 §2.2 form-body token (requestBody.access_token), but its security requirement is bearerAuth OR dpop, and both need an Authorization header. A request that carries the token only in the body satisfies neither. Generated servers and security middleware will reject it with 401 before the handler runs, so the documented method is unreachable.  
   *Suggested change:* Add the empty alternative that the YAML already uses for body credentials on /token: `security: [ {bearerAuth: []}, {dpop: []}, {} ]`. State in the operation description that `{}` means 'access token in the form body (RFC 6750 §2.2); never anonymous', and that a request with no token in either the header or the body gets 401 plus a challenge. If the RS chooses not to support §2.2 (it is only a MAY), delete the requestBody instead.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Bearer challenge parameters realm, scope and error_uri, plus an insufficient_scope example**  
   *Reference:* RFC 6750 §3, §3.1  
   The header description (L1001-1018) and examples (L1021-1025) cover error, error_description and the extension parameters resource_metadata, acr_values, max_age and algs. They never document realm (MAY, at most once), scope (OPTIONAL, space-delimited, used with insufficient_scope) or error_uri (MAY, absolute URI). They also omit the rule that each attribute appears at most once and the per-attribute character sets. No example shows the 403 insufficient_scope challenge, even though /userinfo now returns 403 through the same component. ProtectedResourceError.description (L1092-1098) calls every case an 'authentication error', which misdescribes the 403.  
   *Suggested change:* Add a parameter table to WWWAuthenticateBearerDPoP.description: - realm: MAY, quoted-string. - scope: OPTIONAL; characters %x21/%x23-5B/%x5D-7E with SP as separator. - error: SHOULD when a presented token failed; omitted when no credentials were sent. - error_description: MAY; characters %x20-21/%x23-5B/%x5D-7E. - error_uri: MAY; URI-reference. Each parameter appears at most once. Add these examples: - 'Bearer realm="as.example.com", error="insufficient_scope", scope="openid profile"' - 'Bearer realm="as.example.com", error="invalid_token", error_uri="https://as.example.com/docs/errors#invalid_token"' Reword ProtectedResourceError.description to cover both 401 (authentication failed) and 403 (insufficient_scope).  
   *Verifier: confirmed.*

5. **[LOW] Gap: 400 invalid_request on /userinfo, including the 'one presentation method only' rule**  
   *Reference:* RFC 6750 §2, §3.1; OIDC Core §5.3.3; RFC 9449 §7.2 Fig. 19  
   GET and POST /userinfo declare only 200, 401 and 403 (L496-515, L546-565). RFC 6750 §3.1 maps invalid_request to HTTP 400. It covers a missing or duplicated parameter, and a token sent by more than one method, which §2 says clients MUST NOT do. OIDC Core §5.3.3 requires UserInfo errors to follow RFC 6750 §3. POST /userinfo accepts both the header and a body access_token but never says that sending both is an error, and a server generated from the YAML has no 400 path at all.  
   *Suggested change:* Add `'400': $ref: '#/components/responses/ProtectedResourceError'` (or a ProtectedResourceBadRequest variant) to GET and POST /userinfo. Use the example 'Bearer realm="as.example.com", error="invalid_request", error_description="Multiple methods used to include access token"'. Add to POST /userinfo.description: 'Clients MUST NOT send the token in both the Authorization header and the body (RFC 6750 §2); such requests get 400 invalid_request.'  
   *Verifier: confirmed.*

6. **[LOW] Gap: Error-code to HTTP-status mapping and the resource-server error subset**  
   *Reference:* RFC 6750 §3, §3.1  
   ErrorResponse.error (L1474-1517) mixes token-endpoint, authorization-endpoint and resource-server codes. Nothing tells an RS implementer the mapping: invalid_request → 400, invalid_token → 401, insufficient_scope → 403, plus extension codes on 401 (invalid_dpop_proof and use_dpop_nonce per RFC 9449; insufficient_user_authentication per RFC 9470). Nothing says the normative error channel is the WWW-Authenticate challenge and the JSON body is only a mirror. A generated RS could return, say, invalid_grant from /userinfo. The May-2026 audit flagged this, and it is still open.  
   *Suggested change:* Add the mapping to ProtectedResourceError.description. Point its content at a ResourceErrorResponse schema whose error enum is [invalid_request, invalid_token, insufficient_scope, invalid_dpop_proof, use_dpop_nonce, insufficient_user_authentication], with `error` not required (see the related incorrect item).  
   *Verifier: confirmed.*

7. **[LOW] Gap: Presentation-method policy stated on the bearerAuth security scheme**  
   *Reference:* RFC 6750 §2, §2.2, §2.3; OAuth 2.1-16 §5.1, §5.1.2; RFC 9700 §4.3.2  
   bearerAuth.description (L2640-2646), which Swagger UI, Redoc and Scalar display, mentions only §2.1. The §2.3 query ban (clients MUST NOT; RS MUST ignore) appears only in ProtectedResourceMetadata.bearer_methods_supported (L2299-2304). The §2.2 form-body option (RS MAY support it; it SHOULD NOT be used unless the header is unavailable) appears only on POST /userinfo. A reader of the security scheme does not learn that `GET /userinfo?access_token=...` must be ignored, or that only one method may be used per request.  
   *Suggested change:* Append to bearerAuth.description: 'Form-body presentation (RFC 6750 §2.2, access_token) is accepted only on POST /userinfo. URI-query presentation (§2.3) is not supported: clients MUST NOT use it and resource servers MUST ignore it (OAuth 2.1 §5.1; RFC 9700 §4.3.2). Each request MUST use exactly one method (RFC 6750 §2).'  
   *Verifier: confirmed.*

8. **[LOW] Gap: Bearer token lifetime guidance**  
   *Reference:* RFC 6750 §5.2, §5.3  
   TokenResponse.expires_in (L1428-1432) says only 'Lifetime of the access token in seconds.' RFC 6750 §5.2 says the token lifetime MUST be limited, and §5.3 says token servers SHOULD issue short-lived bearer tokens (one hour or less), especially to browser-based clients. JWT access tokens are covered because JWTAccessTokenClaims requires exp (L2521); opaque tokens have no guidance.  
   *Suggested change:* Extend the expires_in description: 'Bearer token lifetime MUST be limited (RFC 6750 §5.2) and SHOULD be one hour or less (RFC 6750 §5.3); RECOMMENDED in the response (RFC 6749 §5.1).' Keep 3600 as the example. Do not add `maximum`, because the one-hour limit is only a SHOULD.  
   *Verifier: confirmed.*

9. **[LOW] Incorrect: L1104-1107 components.responses.ProtectedResourceError.content -> components.schemas.ErrorResponse (required: [error], L1471)**  
   *Reference:* RFC 6750 §3.1  
   RFC 6750 §3.1, repeated in OAuth 2.1-16 §5.3.2 and RFC 9449 §7.2, says that if the request lacked any authentication information the RS SHOULD NOT include an error code or other error information. The header example follows this rule ('Bearer, DPoP algs=...', L1022), but the response body is always ErrorResponse with a mandatory `error`. The contract therefore forces error information into every 401 body, including the no-credentials case.  
   *Suggested change:* Point ProtectedResourceError at a ResourceErrorResponse schema with no required members, or document that the body is omitted for unauthenticated requests. Add to the description: 'For a request without credentials, send only the challenge (e.g. WWW-Authenticate: Bearer realm="as.example.com") with no error, error_description or error_uri. The WWW-Authenticate header is the normative error channel (RFC 6750 §3); the JSON body is optional.'  
   *Verifier: partially correct —* When a /userinfo 401 carries a JSON body, the shared ErrorResponse schema requires `error`. That conflicts with the RFC 6750 §3.1 SHOULD NOT for requests with no credentials. The contract offers no neutral body for that case and never says to omit the body, but it does not require a body to be sent.

10. **[LOW] Incorrect: L1022 components.headers.WWWAuthenticateBearerDPoP.schema.examples[0] ('Bearer, DPoP algs="ES256 PS256"') and L1049 components.headers.WWWAuthenticateBasicBearer.schema.examples[0] ('Basic realm="as.example.com", Bearer')**  
   *Reference:* RFC 6750 §3  
   Both examples send a Bearer challenge with no auth-param. RFC 6750 §3 (and OAuth 2.1-16 §5.3.1) say the Bearer scheme MUST be followed by one or more auth-param values. The first example copies RFC 9449 §7.2 Figure 17 verbatim, and that figure conflicts with RFC 6750. The RFC 9110 §11.3 grammar allows a bare scheme, but strict Bearer parsers may reject it.  
   *Suggested change:* Use 'Bearer realm="as.example.com", DPoP algs="ES256 PS256"' and 'Basic realm="as.example.com", Bearer realm="as.example.com"'. realm satisfies both RFCs in the no-credentials case because it carries no error information.  
   *Verifier: confirmed.*

11. **[LOW] Incorrect: L541-545 paths./userinfo.post.requestBody.content.application/x-www-form-urlencoded.schema.properties.access_token.description**  
   *Reference:* RFC 6750 §2.2  
   The text attributes 'SHOULD NOT be used unless the Authorization header is unavailable' to OIDC Core §5.3.1. That SHOULD NOT comes from RFC 6750 §2.2 (restated in OAuth 2.1-16 §5.1.2). OIDC Core §5.3.1 only RECOMMENDS GET with the Authorization header and requires the token to be sent per RFC 6750 §2.  
   *Suggested change:* Rewrite as: 'SHOULD NOT be used except where the client cannot use the Authorization header (RFC 6750 §2.2; OAuth 2.1 §5.1.2). OIDC Core §5.3.1 RECOMMENDS GET with the Authorization header.'  
   *Verifier: confirmed.*

12. **[LOW] Gap: The MUST to encrypt self-contained access tokens whose contents the client must not see is absent** — *found by the verifier*  
   *Reference:* RFC 6750 §5.2 (rfc6750.txt L623-626); see RFC 9068 §6  
   The MUST to encrypt self-contained access tokens whose contents the client must not see is absent. The YAML offers JWT access tokens and describes them only as signed.  
   *Suggested change:* Add to TokenResponse.access_token and JWTAccessTokenClaims: 'If the token carries information the client must not see, the AS MUST encrypt it (JWE) in addition to TLS (RFC 6750 §5.2; RFC 9068 §6), or issue an opaque reference token instead.'

13. **[LOW] Gap: https is enforced only through servers[0]** — *found by the verifier*  
   *Reference:* RFC 6750 §5.3 'Always use TLS (https)' (L692-695); OAuth 2.1-16 §1.5; RFC 9728 §2  
   https is enforced only through servers[0]. The metadata URLs that tell clients where to send bearer tokens have no https constraint.  
   *Suggested change:* Add pattern '^https://' (or a MUST statement) to userinfo_endpoint, the mtls_endpoint_aliases members, ProtectedResourceMetadata.resource and authorization_servers.

## RFC 8996 Deprecating TLS 1.0 and TLS 1.1

*March 2021 · Best Current Practice (BCP 195) · YAML coverage: **none** · relevance to an AS: required-oauth21 · vendoring: vendor*

**What it is.** RFC 8996, part of BCP 195, formally retires TLS 1.0 and TLS 1.1 (and DTLS 1.0). They MUST NOT be used, and negotiating them MUST NOT be permitted (§4, §5). It updates about 80 RFCs that still referenced these versions, including RFC 6749 §1.6 and RFC 6750 §5.2. Any stated minimum becomes TLS 1.2, and the old advice that TLS 1.0 gives 'the broadest interoperability' is deleted (§1.1). For an OAuth server this means every endpoint runs over TLS 1.2 or later, with TLS 1.3 preferred under the rest of BCP 195 (RFC 9325, RFC 9852).

**Why it was created.** TLS 1.0 (1999) and TLS 1.1 (2006) rely on SHA-1/MD5 for handshake integrity and peer authentication, which allows a handshake downgrade at roughly 2^77 work (§3). They also lack AEAD cipher suites and force obsolete mandatory cipher suites. Libraries and government and industry profiles (e.g., NIST SP 800-52r2, §2) were already dropping them. Many IETF RFCs, including OAuth's RFC 6749 §1.6 and RFC 6750 §5.2, still recommended TLS 1.0 for interoperability, so one document was needed to retire those versions in every protocol at once.

<details><summary>Already modeled in the YAML (1)</summary>

- Only indirectly: servers[0].url 'https://{issuer}' (L77-86) makes every endpoint https-only. That is a prerequisite, but no TLS version floor is stated anywhere in the YAML.

</details>

**Follow-up on the May-2026 validation notes.** No prior validation note exists, and the May-2026 audit raised no TLS-version item. The gap is new.

**Notes.** There is no HTTP-level wire surface: RFC 8996 constrains the TLS layer under every endpoint.

Verified today:
- BCP 195 = RFC 8996 + RFC 9325 (Nov 2022) + RFC 9852 (July 2026, 'New Protocols Using TLS Must Require TLS 1.3'). RFC 9852 updates RFC 9325 §3.1.1: for new protocols TLS 1.3 becomes MUST and TLS 1.2 MAY.
- TLS 1.3 is now specified by RFC 9846 (July 2026), which obsoletes RFC 8446 and RFC 5246. RFC 9846 is the version OAuth 2.1-16 §1.5 cites.
- OAuth 2.1-16 §7.5.2 refers to 'OAuth 2.1's requirement for TLS 1.2+'.
- RFC 9700 §2.6 RECOMMENDS end-to-end TLS per BCP 195, and RFC 8705 §7.3 defers TLS versions to BCP 195.

Why vendor: RFC 8996 is a TLS WG document, outside the OAuth WG set the repo vendors. Even so, it formally updates two vendored RFCs (6749 and 6750), changes their normative TLS text, and is small (about 50 KB). Consider also cataloguing RFC 9325 and RFC 9852 as the rest of BCP 195. *(Update 2026-10-11: RFC 8996 is now vendored. RFC 9325 and RFC 9852 are catalogued in [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md).)*

### Findings (0 high · 0 medium · 2 low)

1. **[LOW] Gap: TLS version floor (TLS 1.0/1.1 forbidden, TLS 1.2 minimum, TLS 1.3 preferred)**  
   *Reference:* RFC 8996 §4, §5, §1.1; BCP 195 (RFC 9325 §3.1.1; RFC 9852 §4-§5); OAuth 2.1-16 §1.5; RFC 9700 §2.6; RFC 8705 §7.3  
   servers[0] (L77-86) is https-only, which matches RFC 6750 §5.3 and OAuth 2.1 §1.5. Nowhere does the YAML state a TLS version requirement: not in info.description (L9-64), servers, bearerAuth, clientSecretBasic or mtls (L2676-2681). RFC 8996 says TLS 1.0/1.1 MUST NOT be used or negotiated and replaces the TLS 1.0 guidance in RFC 6749 §1.6 and RFC 6750 §5.2. RFC 9325 §3.1.1 requires TLS 1.2 support and says implementations SHOULD support TLS 1.3 and MUST prefer it. OAuth 2.1 §1.5 defers versions to BCP 195. Bearer tokens and Basic client secrets are only as safe as this channel, and mTLS client authentication depends on it. OpenAPI cannot enforce TLS settings, so this is documentation, but it is the contract the planned server will be built from.  
   *Suggested change:* Add a 'Transport security' bullet to the info.description modeling notes (after L64) and to servers[0].description: 'All endpoints MUST be served over https (OAuth 2.1 §1.5) using TLS 1.2 or later. SSL, TLS 1.0 and TLS 1.1 MUST NOT be negotiated (RFC 8996 §4-§5; RFC 9325 §3.1.1). Support and prefer TLS 1.3 (RFC 9325 §3.1.1); RFC 9852 makes TLS 1.3 mandatory for new protocols. Clients validate server certificates per RFC 9110 §4.3.4.' Mention the same floor in the mtls scheme description, referencing RFC 8705 §7.3.  
   *Verifier: confirmed.*

2. **[LOW] Gap: Record that RFC 8996 supersedes the TLS text in vendored RFC 6749/6750**  
   *Reference:* RFC 8996 §1.1  
   The vendored rfc6749.txt §1.6 (lines 635-647) and rfc6750.txt §5.2 (lines 598-605) still say TLS 1.0 'is the most widely deployed version and will [give|provide] the broadest interoperability'. RFC 8996 §1.1 removes those statements without replacement and raises the minimums to TLS 1.2. Neither the 'Covered specifications' table in info.description (L18-45) nor references/rfc-sources/README.md records this 'Updated by' relationship, so a learner reading the vendored text gets outdated advice.  
   *Suggested change:* Add RFC 8996 (2021, BCP 195) to the Covered specifications table: 'TLS 1.0/1.1 deprecated; updates RFC 6749 §1.6 and RFC 6750 §5.2'. Vendor rfc8996.txt. Add an 'Updated by' column to references/rfc-sources/README.md, e.g. 6749 ← 8252, 8996, 9700 and 6750 ← 8996, 9700.  
   *Verifier: confirmed.*

## RFC 7617 The 'Basic' HTTP Authentication Scheme

*September 2015 · Proposed Standard (Standards Track); obsoletes RFC 2617 together with RFC 7235, 7615 and 7616 · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** RFC 7617 re-defines the HTTP 'Basic' authentication scheme. The client sends `Authorization: Basic base64(user-id ":" password)`, and a server challenges with `WWW-Authenticate: Basic realm="..."`. realm is REQUIRED, and the server may add `charset="UTF-8"` to ask for UTF-8 credentials. OAuth uses Basic for the `client_secret_basic` client-authentication method: the client_id and client_secret are first form-urlencoded, then used as the user-id and password (RFC 6749 §2.3.1; OAuth 2.1 §2.4.1). Basic gives no confidentiality on its own, so it must only be sent over TLS.

**Why it was created.** Basic was first defined in RFC 2617 (1999) alongside Digest. That text never said which character encoding to use for the user-id and password, which broke interoperability for non-ASCII credentials, and it predated the cleaned-up HTTP authentication framework. During the HTTPbis/httpauth work, RFC 2617 was split into the generic framework (RFC 7235, now RFC 9110 §11) and separate scheme documents. RFC 7617 is the Basic part: it aligns Basic with the new framework and adds the 'charset' auth-param.

<details><summary>Already modeled in the YAML (5)</summary>

- §2 Basic credentials (token68 = base64(user-id ':' password)): components.securitySchemes.clientSecretBasic (type http, scheme basic) L2662-2674; required on /token L265-268, /revoke L307-310, /introspect L360-363, /device_authorization L414-417 and /par L473-476
- §2 Basic challenge with realm: components.headers.WWWAuthenticateBasic L1026-1037 (examples 'Basic realm="as.example.com"'), used by components.responses.ClientAuthError L1108-1125 on the 401s at L263-264, L305-306, L412-413 and L465-466
- Combined Basic + Bearer challenge for /introspect: components.headers.WWWAuthenticateBasicBearer L1038-1050 via IntrospectionAuthError L1126-1142
- client_secret_basic auth-method value and the RFC 8414 default: OAuthServerMetadata.token_endpoint_auth_methods_supported L2037-2049
- §4 Basic only over TLS: https-only servers L77-86

</details>

**Follow-up on the May-2026 validation notes.** No prior validation note exists for RFC 7617. The May-2026 audit did not flag the OAuth 2.1 change of preference between Basic and client_secret_post.

**Notes.** client-id and client-secret are *VSCHAR (RFC 6749 App. A.1/A.2) and may contain ':' or spaces. That is why the form-urlencoding step matters: for example, client_id 'urn:example:client' must be sent as 'urn%3Aexample%3Aclient'.

The OAuth 2.1 preference change dates from draft -11; its changelog says client credentials are 'required to be supported in the request body to avoid HTTP Basic authentication encoding interop issues'.

Not applicable to an AS: §2.2 (reusing credentials within a protection space) and the proxy forms (Proxy-Authorization / 407).

Why vendor: RFC 7617 is small (about 30 KB), defines a wire format the YAML models directly (securitySchemes.clientSecretBasic, headers.WWWAuthenticateBasic), and is cited at L1032. It was not vendored when this was written. *(Update 2026-10-11: now vendored.)*

### Findings (0 high · 2 medium · 4 low)

1. **[MEDIUM] Gap: Form-urlencoding of client_id and client_secret before Basic encoding**  
   *Reference:* RFC 6749 §2.3.1 and Appendix B; OAuth 2.1-16 §2.4.1; RFC 7617 §2  
   clientSecretBasic.description (L2665-2674) says only 'HTTP Basic with client_id:client_secret'. RFC 6749 §2.3.1 and OAuth 2.1 §2.4.1 require each value to be application/x-www-form-urlencoded first: UTF-8, space → '+', ':' → %3A. The AS reverses this after Base64-decoding and splitting at the first ':'. The step matters because client-id and client-secret are *VSCHAR (RFC 6749 App. A.1/A.2), so they may contain ':' or spaces. RFC 7617 §2 says a user-id containing ':' is invalid and forbids control characters. OAuth 2.1 §2.4.1 notes that skipping or partially applying this step caused many interoperability failures.  
   *Suggested change:* Append to clientSecretBasic.description: 'Wire format: Basic base64( urlencode(client_id) ":" urlencode(client_secret) ), where urlencode is application/x-www-form-urlencoded over UTF-8 (RFC 6749 App. B). The AS Base64-decodes, splits at the FIRST ":", then form-url-decodes both parts. Example: s6BhdRkqt3 / 7Fjfp0ZBr1KtDRbnfVdmIw → Authorization: Basic czZCaGRSa3F0Mzo3RmpmcDBaQnIxS3REUmJuZlZkbUl3.'  
   *Verifier: confirmed.*

2. **[MEDIUM] Incorrect: L2665-2668 components.securitySchemes.clientSecretBasic.description ('PREFERRED over the form-body client_secret_post variant'); L1185-1190 components.schemas.ClientAuthFields.properties.client_secret.description ('HTTP Basic (client_secret_basic) is preferred; this form-body variant is NOT RECOMMENDED per RFC 6749 §2.3.1')**  
   *Reference:* draft-ietf-oauth-v2-1-16 §2.4.1 (vs. RFC 6749 §2.3.1); Basic per RFC 7617 §2  
   The statement is accurate for RFC 6749 §2.3.1, but the YAML declares OAuth 2.1 as its default profile (info.summary L8; modeling notes L59-61). Since draft -11, and still in -15 and the current -16, OAuth 2.1 §2.4.1 reverses the preference. The AS MUST support client credentials in the request body (client_secret_post) and MAY support HTTP Basic, because the Basic form-encoding step caused interoperability problems. An implementer following the YAML text might disable client_secret_post, which is mandatory under OAuth 2.1.  
   *Suggested change:* Rephrase both descriptions: 'OAuth 2.1 §2.4.1: the AS MUST support client_secret_post and MAY support client_secret_basic (RFC 6749 §2.3.1 had the opposite preference). OAuth 2.1 notes that body credentials avoid the Basic encoding issues. client_secret_basic remains the default auth method when metadata omits it (RFC 8414 §2, RFC 7591 §2), so supporting it helps interop with OAuth 2.0 clients.' Keep the security alternatives as they are.  
   *Verifier: confirmed.*

3. **[LOW] Gap: realm REQUIRED in Basic challenges; optional charset="UTF-8"**  
   *Reference:* RFC 7617 §2, §2.1; RFC 9110 §11.5  
   WWWAuthenticateBasic (L1026-1037) shows realm in its examples but does not say realm is REQUIRED in Basic challenges. It also doesn't say that no other parameters are defined, or that the optional charset="UTF-8" parameter asks clients to send UTF-8/NFC credentials. charset is relevant because RFC 6749 Appendix B encodes client credentials as UTF-8.  
   *Suggested change:* Add to the description: 'Basic challenges MUST carry realm (RFC 7617 §2), sent as a quoted-string (RFC 9110 §11.5). The only other defined parameter is charset, whose only value is "UTF-8" (§2.1).' Add the example 'Basic realm="as.example.com", charset="UTF-8"'.  
   *Verifier: partially correct —* Document that realm is REQUIRED in Basic challenges, sent as a quoted-string (RFC 7617 §2; RFC 9110 §11.5), and that Basic defines no other parameters besides the advisory charset. charset="UTF-8" is allowed but has no effect on OAuth client authentication, because the form-urlencoded credentials are pure ASCII.

4. **[LOW] Incorrect: L1037 components.headers.WWWAuthenticateBasic.schema.examples[1] ('Basic realm="as.example.com", error="invalid_client"')**  
   *Reference:* RFC 7617 §2  
   RFC 7617 §2 says of Basic challenges: 'No other authentication parameters are defined -- unknown parameters MUST be ignored by recipients, and new parameters can only be defined by revising this specification.' `error` is a Bearer parameter (RFC 6750 §3), not a Basic one. Clients will ignore it; RFC 6749 §5.2 carries invalid_client in the JSON body.  
   *Suggested change:* Replace the example with 'Basic realm="as.example.com", charset="UTF-8"' and state that the error code travels in the JSON body (ErrorResponse.error = invalid_client).  
   *Verifier: confirmed.*

5. **[LOW] Gap: The YAML says nothing about protecting password-based client authentication (Basic or client_secret_post) against brute force, or about how to store secrets.** — *found by the verifier*  
   *Reference:* RFC 6749 §2.3.1; OAuth 2.1-16 §2.4.1; RFC 7617 §4  
   The YAML says nothing about protecting password-based client authentication (Basic or client_secret_post) against brute force, or about how to store secrets.  
   *Suggested change:* Add to both descriptions: 'Endpoints accepting client secrets MUST be protected against brute-force guessing (RFC 6749 §2.3.1; OAuth 2.1 §2.4.1), e.g. by rate limiting. Store secrets hashed, unless client_secret_jwt requires the raw secret.' Optionally declare 429 on the client-authenticated endpoints.

6. **[LOW] Gap: RFC 7617 is modeled and cited, but the 'Covered specifications' table does not list it.** — *found by the verifier*  
   *Reference:* RFC 7617 §2  
   RFC 7617 is modeled and cited, but the 'Covered specifications' table does not list it.  
   *Suggested change:* Add a row: 'RFC 7617 | 2015 | HTTP Basic authentication scheme (client_secret_basic)'.

## RFC 9110 HTTP Semantics

*June 2022 · Internet Standard (STD 97) · YAML coverage: **mostly** · relevance to an AS: required-oauth21 · vendoring: catalog-only*

**What it is.** RFC 9110 (HTTP Semantics) defines what HTTP methods, status codes and header fields mean, independent of whether HTTP/1.1, HTTP/2 or HTTP/3 carries them. Section 11 is the authentication framework every OAuth scheme plugs into: case-insensitive auth-scheme names, `auth-param` and `token68` syntax, challenges in `WWW-Authenticate`, credentials in `Authorization`, and realms. Section 15 gives the status-code rules the YAML relies on. A 401 MUST carry at least one challenge, 403 means the credentials were valid but not sufficient, and a 405 MUST list the allowed methods in `Allow`.

**Why it was created.** HTTP/1.1 was specified first in RFC 2616 (1999) and then in the RFC 7230-7235 series (2014), which mixed version-independent semantics with HTTP/1.1 wire syntax. Once HTTP/2 and HTTP/3 existed, the IETF consolidated the shared semantics into one document, alongside RFC 9111 (caching) and RFC 9112 (HTTP/1.1). RFC 9110 obsoletes RFC 7230-7235, RFC 2818 (HTTP over TLS), RFC 7615 and others. For OAuth, it replaces RFC 2617 and RFC 7235 as the framework that RFC 6750's Bearer challenge and RFC 7617's Basic scheme build on.

<details><summary>Already modeled in the YAML (8)</summary>

- §11.6.1/§15.5.2 a WWW-Authenticate challenge on every 401: ClientAuthError L1108-1125 (/token L263-264, /revoke L305-306, /device_authorization L412-413, /par L465-466), IntrospectionAuthError L1126-1142 (/introspect L358-359) and ProtectedResourceError L1091-1107 (/userinfo L512-515, L562-565)
- §11.3/§11.6.1 several challenges in one field value: WWWAuthenticateBearerDPoP L1000-1025 and WWWAuthenticateBasicBearer L1038-1050 (§11.6.1 cited at L1004, L1043, L1096); the more widely supported scheme is listed first, as the §11.3 note advises
- §11.5 realm sent as a quoted-string: examples L1036-1037 and L1049
- §11.6.2 Authorization credentials: securitySchemes bearerAuth L2637-2646 and clientSecretBasic L2662-2674 (type http); dpop L2648-2660 (apiKey on the Authorization header)
- §11.4/§15.5.4 403 for valid but insufficient credentials: /userinfo 403 L514-515 and L564-565
- §10.2.2 Location required on /authorize 302/303: L173-189
- §15.5.6/§15.5.14 405 and 413 status codes on /par: L467-470 (no headers)
- §4.2.2 https scheme: servers L77-86

</details>

**Follow-up on the May-2026 validation notes.** No dedicated validation note exists for RFC 9110. The May-2026 synthesis said 'securitySchemes.dpop.scheme: dpop — not a valid OpenAPI HTTP scheme'. OAS 3.1 accepts any IANA-registered scheme in `type: http`, and DPoP is registered, so the claim is wrong. The scheme has since been remodeled as apiKey; see the low gap above.

**Notes.** Only the parts the YAML uses were assessed: §4.2.2, §10.2.1-10.2.3, §11.1-11.6, §15.4.3-15.4.4, and §15.5.1, §15.5.2, §15.5.4, §15.5.6 and §15.5.14.

RFC 9110 obsoletes RFC 7235, the HTTP authentication framework that RFC 6750 §3 and RFC 7617 reach through RFC 2617/7235. It also obsoletes RFC 2818 (HTTP over TLS), which RFC 6750 §5.2 cites for server-identity checks; that rule is now RFC 9110 §4.3.4, which OAuth 2.1-16 §1.5 cites.

Correctly modeled: realm values are quoted-strings (§11.5), Location is required on 302/303, 403 is used for valid but insufficient credentials (§11.4), and combined challenges list the widely supported scheme first.

The header schemas are free-form strings. That is reasonable, because the challenge grammar (lists, quoted-string escapes) is impractical to express as a regex.

Cache-Control and Pragma come from RFC 9111, and 429 from RFC 6585; both are outside this cluster.

Catalog-only rather than vendored: the text is large (about 500 KB) and general-purpose. Cite precise section links instead. Vendor it only if the repo adopts a rule to vendor every RFC the YAML cites (it is cited at L1004, L1043 and L1096). *(Update 2026-10-11: the repo adopted that rule, and RFC 9110 is now vendored.)*

### Findings (0 high · 1 medium · 7 low)

1. **[MEDIUM] Gap: WWW-Authenticate required on the authorization server's 401 responses**  
   *Reference:* RFC 9110 §11.6.1, §15.5.2; RFC 6749 §5.2; RFC 7662 §2.3  
   Every AS 401 references a challenge header: ClientAuthError → WWWAuthenticateBasic (L1116-1117), and IntrospectionAuthError → WWWAuthenticateBasicBearer (L1133-1134), which also covers the Bearer branch for resource servers calling /introspect. Neither header component sets `required: true`, yet RFC 9110 says a server generating a 401 MUST send WWW-Authenticate with at least one challenge. WWWAuthenticateBasic's description (L1027-1032) also says it is returned 'when the client used the Authorization header'. That implies the header may be omitted on 401s caused by failed client_secret_post, private_key_jwt or mTLS authentication. RFC 6749 §5.2 only adds the rule that the scheme must match the one the client used; HTTP still requires a challenge on every 401. The alternative is to return 400 invalid_client.  
   *Suggested change:* Add `required: true` to components.headers.WWWAuthenticateBasic (L1026) and WWWAuthenticateBasicBearer (L1038). Reword the Basic description: 'MUST be present on every 401 (RFC 9110 §15.5.2). If the client used Basic, the challenge MUST be Basic (RFC 6749 §5.2). After failed body or mTLS client authentication, return either 401 with an applicable challenge (e.g. Basic realm="...") or 400 invalid_client.' The Bearer resource-server header is covered under RFC 6750.  
   *Verifier: confirmed.*

2. **[LOW] Gap: Allow header on the 405 from /par**  
   *Reference:* RFC 9110 §15.5.6, §10.2.1; RFC 9126 §2.3  
   /par declares a 405 (L467-468) with no headers. RFC 9110 says the origin server MUST send an Allow header listing the supported methods in every 405. Most frameworks add Allow automatically to their own 405s, but the contract and any hand-written handler would miss it. Also, a 405 declared under the `post` operation can only describe requests that use other methods on /par; the description should say so.  
   *Suggested change:* Add to the 405 response: `headers: { Allow: { required: true, description: 'Methods supported by /par (RFC 9110 §10.2.1)', schema: { type: string, examples: ['POST'] } } }`. Reword the description: 'Returned for any method other than POST (RFC 9126 §2.3); MUST include Allow (RFC 9110 §15.5.6).'  
   *Verifier: confirmed.*

3. **[LOW] Gap: Retry-After and an error body on the 413 and 429 from /par**  
   *Reference:* RFC 9110 §15.5.14, §15.5, §10.2.3 (429's Retry-After is defined in RFC 6585 §4)  
   The /par 413 and 429 responses (L469-472) have no headers or content. Under RFC 9110 §15.5.14, the server SHOULD send Retry-After when a 413 condition is temporary. Under §15.5, 4xx responses SHOULD carry a representation explaining the error. The 429 status and its Retry-After are defined by RFC 6585, outside this cluster.  
   *Suggested change:* Add an optional Retry-After header (delay-seconds integer or HTTP-date string, RFC 9110 §10.2.3) to the 413 and 429. Add `content: application/json: {$ref: ErrorResponse}` (or application/problem+json) to the 405, 413 and 429.  
   *Verifier: partially correct —* Add an explanatory body (e.g. ErrorResponse) to the /par 405, 413 and 429 per RFC 9110 §15.5. An optional Retry-After fits the 429 (RFC 6585 §4 MAY), but it usually does not fit the PAR 413, because a size limit is not a temporary condition.

4. **[LOW] Gap: Interop caveat for several challenges on one header line**  
   *Reference:* RFC 9110 §11.6.1, §11.3 (note)  
   WWWAuthenticateBearerDPoP and WWWAuthenticateBasicBearer (descriptions at L1004-1006 and L1043-1044, plus ProtectedResourceError at L1094-1096) present the single-line form 'Bearer ..., DPoP ...' as the way to offer two schemes. RFC 9110 §11.6.1 allows this form but warns that some user agents don't recognise several challenges on one field line. It notes that the field may instead appear several times.  
   *Suggested change:* Add to both descriptions: 'Servers MAY instead send one WWW-Authenticate field line per scheme; RFC 9110 §11.6.1 notes the single-line form is not always interoperable. Clients MUST parse both forms. Keep the more widely supported scheme first (§11.3).'  
   *Verifier: confirmed.*

5. **[LOW] Gap: Case-insensitive auth-scheme and auth-param names**  
   *Reference:* RFC 9110 §11.1, §11.2; OAuth 2.1-16 §5.1.1; RFC 7617 §2  
   Nothing tells AS or RS implementers that 'Bearer', 'bearer' and 'BEARER' (and likewise Basic and DPoP) must all be accepted. Nor does it say that auth-param names are case-insensitive while values such as error codes and scopes are case-sensitive (RFC 6750 §1.1). OAuth 2.1 §5.1.1 calls this out explicitly because exact string comparison is a common interop bug.  
   *Suggested change:* Add to the bearerAuth and clientSecretBasic descriptions: 'The auth-scheme name is matched case-insensitively (RFC 9110 §11.1; OAuth 2.1 §5.1.1). auth-param names are case-insensitive (§11.2); their values are case-sensitive.'  
   *Verifier: confirmed.*

6. **[LOW] Gap: dpop scheme modeled as an apiKey on the Authorization header**  
   *Reference:* RFC 9110 §11.6.2 (credentials = auth-scheme [ 1*SP ( token68 / #auth-param ) ]), §11.1 (IANA scheme registry)  
   securitySchemes.dpop (L2648-2660) is `type: apiKey, in: header, name: Authorization`. That treats the whole header value as an opaque key and loses the auth-scheme/token68 structure. DPoP is a registered HTTP Authentication Scheme (IANA, RFC 9449), and OpenAPI 3.1's `type: http` accepts any registered scheme name, so `type: http, scheme: dpop` is valid. The May-2026 synthesis called it invalid; tool support is weaker, but it is valid. This overlaps the RFC 9449 cluster.  
   *Suggested change:* Either switch to `type: http, scheme: dpop`, keeping the proof header documented through components.parameters.DPoPHeader, or keep apiKey and state the exact value format 'DPoP &lt;token68>' and that apiKey was chosen for tooling reasons.  
   *Verifier: confirmed.*

7. **[LOW] Gap: RFC 9110 is relied on and cited three times, but the 'Covered specifications' table does not list it.** — *found by the verifier*  
   *Reference:* RFC 9110 §11, §15.5  
   RFC 9110 is relied on and cited three times, but the 'Covered specifications' table does not list it.  
   *Suggested change:* Add a row: 'RFC 9110 | 2022 | HTTP Semantics — authentication framework (§11), status codes (§15)'.

8. **[LOW] Incorrect: The /par 413 still uses the obsolete reason phrase 'Payload Too Large'.** — *found by the verifier*  
   *Reference:* RFC 9110 §15.5.14  
   The /par 413 still uses the obsolete reason phrase 'Payload Too Large'.  
   *Suggested change:* Change the description to 'Content Too Large (RFC 9110 §15.5.14; "Payload Too Large" in RFC 9126 §2.3)'.

## Verifier corrections to the summaries above

- RFC 7617 why_created: 'Basic was first defined in RFC 2617 (1999) alongside Digest' is wrong. Basic was first specified in RFC 1945 §11.1 (HTTP/1.0, May 1996; checked: 'The "basic" authentication scheme ... WWW-Authenticate: Basic realm="WallyWorld"') and again in RFC 2068 §11.1 (HTTP/1.1, January 1997). Digest first appeared in RFC 2069 (January 1997). RFC 2617 (June 1999) re-specified both schemes and obsoleted RFC 2069.
- RFC 9110 why_created: 'HTTP/1.1 was specified first in RFC 2616 (1999)' is wrong. HTTP/1.1 was first published as RFC 2068 (January 1997), which RFC 2616 (June 1999) obsoleted (rfc-index: RFC2616 obsoletes RFC2068).
- RFC 9110 why_created: 'RFC 9110 obsoletes RFC 7230-7235' is wrong for RFC 7234 (Caching), which RFC 9111 obsoletes. Per the RFC index, RFC 9110 obsoletes RFC 2818, 7230 (jointly with RFC 9112), 7231, 7232, 7233, 7235, 7538, 7615 and 7694.
- RFC 8996 prior_validation_followup: 'the May-2026 audit raised no TLS-version item. The gap is new' is false. references/rfc-validation/9700-security-bcp.md (NICE-TO-HAVE, L298-300) proposed adding 'TLS 1.2 or newer is REQUIRED (RFC 9700 §2.6)' to the servers block, and 8414-as-metadata.md (L205-208) proposed a 'TLS 1.2+' note on the discovery URL. Both wrongly attribute a TLS 1.2 floor to RFC 9700 §2.6, which only RECOMMENDS end-to-end TLS per BCP 195. The item was raised before and never implemented.
- RFC 7617 prior_validation_followup is incomplete. The May-2026 9700-security-bcp.md M7 (L206-221) and W4 (L282-293) did not just miss the OAuth 2.1 change; they pushed the opposite preference. They quote RFC 9700 §2.5 as saying 'When using symmetric client authentication, client_secret_basic SHOULD be preferred over client_secret_post'. The vendored RFC 9700 §2.5 contains no such sentence (it only RECOMMENDS asymmetric methods), and RFC 9700 never mentions client_secret_basic or client_secret_post. That audit item should be marked wrong. The YAML now attributes the preference to RFC 6749 §2.3.1, which is accurate for RFC 6749 only.
- RFC 6750 why_created: 'OAuth 1.0 (RFC 5849) had required clients to sign every request' oversimplifies. RFC 5849 §3.4 required an oauth_signature value on every request, but the PLAINTEXT method (§3.4.4) 'does not employ a signature algorithm' and relies on TLS. The hard part was HMAC-SHA1/RSA-SHA1 signing over the signature base string.
- RFC 7617 summary: 'so it must only be sent over TLS' misattributes the requirement level. RFC 7617 §4 says only that Basic 'SHOULD NOT be used (without enhancements such as HTTPS) to protect sensitive or valuable information'. The MUST comes from RFC 6749 §2.3.1 ('MUST require the use of TLS') and OAuth 2.1 §1.5.
- RFC 9110 summary: '403 means the credentials were valid but not sufficient' is narrower than §15.5.4. A 403 means the server understood the request but refuses it. Credentials that were sent are considered insufficient, but 'a request might be forbidden for reasons unrelated to the credentials'.
- RFC 7617 modeled_elements: clientSecretBasic is not 'required on' /token, /revoke, /introspect, /device_authorization and /par. In each security list it is one alternative, alongside mtls and `{}` (or alongside mtls and bearerAuth on /introspect).
- Cluster notes: the BCP 195 membership (RFC 8996, 9325, 9852) and RFC 9846 obsoleting RFC 8446 and 5246 are correct per the RFC index. They omit RFC 10015 (July 2026, Proposed Standard, not part of BCP 195), which updates RFC 9325 and RFC 5246 and deprecates RSA and finite-field DH key exchange in (D)TLS 1.2. Any 'TLS 1.2 minimum' text in the YAML should reflect it.
- Cluster notes 'open medium items', re-graded after verification: items (1), (3), (7) and (8) stay medium; (2), (4), (5), (6) and (9) are low. The RS 401 body item (2) is only partially correct, because OAS does not make a response body mandatory.
- Verified, no correction needed: the cross-cluster observations hold. The `algs` challenge parameter is defined in RFC 9449 §7.1 (rfc9449.txt L931), not §5 (YAML L1010-1011). The ErrorResponse comment at L1507 ('DPoP §10') is wrong: the codes are defined in §5 (L560), §7.1 (L922-925), §8 (L1093) and §9 (L1222) and registered in §12.2 (L1576, L1589). The /introspect security list (L360-363) has no `{}` although IntrospectionRequest includes ClientAuthFields. The 6750 note's '10 actionable items (4 MISSING / 2 WRONG / 4 NICE-TO-HAVE)' count and its incorrect claim that 'OAuth 2.1 forbids both §2.2 and §2.3' are also confirmed.
