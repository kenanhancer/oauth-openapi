# OAuth 1.0 — RFC 5849

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

> **Scope note:** these documents are catalogued for completeness. They are outside
> the authorization-server surface this spec models, so their "gaps" are informational,
> not a to-do list.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 5849](#rfc-5849-the-oauth-10-protocol) | April 2010 | Informational (IETF stream, non-WG; obsoleted by RFC 6749) | not-applicable | 0 | 0 | 0 |

**Cluster notes.** The cluster has one document, RFC 5849. Facts were re-checked online today: the rfc-editor.org JSON, the RFC index, datatracker (draft-hammer-oauth-10 → RFC 5849, IANA state "No IANA Actions") and IANA http-authschemes.xml (registry created 2014-02-17, updated 2025-02-18).

IANA-vs-YAML:
- The only IANA value that comes from RFC 5849 is the HTTP Authentication Scheme "OAuth". It is an undated initial record with reference "RFC5849, Section 3.5.1".
- The IANA absence list counts "OAuth" as present in the YAML. That is a false positive: the word-match hits the word "OAuth" in prose. The YAML never uses `Authorization: OAuth` or `OAuth realm=`.
- "Mutual" (RFC 8120) is a false positive for the same reason. It matches "Mutual-TLS" at L31 and "Mutual TLS" at L2679.
- So the auth-scheme count really modeled is 3/14 (Basic, Bearer, DPoP), not 5/14.
- Not modeling the OAuth 1.0 scheme is correct for an OAuth 2.x AS, so this is not a gap.

Result: no contradictions, no gaps, and no prior validation notes for RFC 5849.

Cross-cluster pointer for the RFC 6749 / OAuth 2.1 owners:
- RFC 5849 §2 says temporary credentials are single-use and short-lived. The direct descendant is the authorization-code rule: single use, 10-minute maximum lifetime (RFC 6749 §4.1.2; OAuth 2.1 §4.1.2-§4.1.3).
- AuthorizationCodeTokenRequest.code at L1252-1254 still says only "The authorization code received from `/authorize`."
- So the item flagged in references/rfc-validation/oauth-2.1-draft.md L236-249 is still open.

A short scratch script (not kept in the repository) rebuilt the RFC 5849 §3.4.1 signature base string and the HMAC-SHA1 signature from first principles, and reproduced erratum 2550. Writing one yourself is a good exercise. Evidence used: the RFC 5849 errata page, the 2009 security advisory, the WRAP draft, early OAuth 2.0 drafts and Datatracker records. Nothing under the repo or the snapshot was modified.

## RFC 5849 The OAuth 1.0 Protocol

*April 2010 · Informational (IETF stream, non-WG; obsoleted by RFC 6749) · YAML coverage: **not-applicable** · relevance to an AS: informational · vendoring: vendor*

**What it is.** RFC 5849 is the IETF's Informational publication of the community protocol OAuth Core 1.0 Revision A ('OAuth 1.0a'), with errata fixes and editorial clarifications. It is the first OAuth RFC and was obsoleted in October 2012 by RFC 6749 (OAuth 2.0), which is not backward compatible with it (RFC 6749 §1). Its first half (§2) is the three-legged redirect flow: the client gets temporary credentials (the old 'request token' plus a secret), sends the resource owner's browser to the Resource Owner Authorization endpoint, then trades the temporary credentials plus an oauth_verifier for token credentials (the old 'access token' plus a secret). Its second half (§3) authenticates every HTTP request with two credential sets, client plus token: the client signs a normalized 'signature base string' with HMAC-SHA1 or RSA-SHA1 (or sends both secrets over TLS with PLAINTEXT), adds a nonce and timestamp against replay, and sends the parameters in the 'OAuth' Authorization header, a form body or the query string.

**Why it was created.** Before OAuth, a third-party site that wanted a user's data asked for the user's username and password. That gave the site full, unscoped access that could only be revoked by changing the password. Providers each had their own proprietary delegation schemes, and RFC 5849 §5 says OAuth was 'modeled after existing proprietary protocols and best practices'. A small community of web developers designed a common protocol: the user approves access directly at the server, and the client gets its own revocable, limited token credentials (§1). Per oauth.net's history page, the work started around November 2006 from Twitter's OpenID work, and the OAuth Core 1.0 final draft was released on 3 October 2007. Because the protocol had to be safe even without TLS (§3.3, §4.2), every request was signed with shared secrets plus a nonce and timestamp, so captured requests could not be replayed and their signed parts could not be changed. A session-fixation attack on the request-token approval step (OAuth Security Advisory 2009.1, 23 April 2009) produced Revision A in June 2009. Revision A moved oauth_callback into the signed temporary-credential request and added oauth_callback_confirmed and the oauth_verifier (§2.1-§2.3). The authors then gave change control to the IETF, which published 1.0a as RFC 5849 (April 2010, from draft-hammer-oauth-10) while the new OAuth Working Group designed OAuth 2.0 for the standards track (§1).

<details><summary>Already modeled in the YAML (16)</summary>

- [successor] Resource Owner Authorization endpoint (§2.2, GET + oauth_token) -> paths./authorize.get L109-205 (HTML consent page 200 at L190-195; 302/303 redirect at L160-189)
- [successor] oauth_callback (§2.1, REQUIRED absolute URI or 'oob') -> components.parameters.RedirectUri L716-730 (now pre-registered and exact-match, RFC 9700 §2.1)
- [successor] callback redirect carrying oauth_token + oauth_verifier (§2.2) -> /authorize 302 Location with code, state, iss at L160-181
- [successor] oauth_verifier + per-flow temporary-credential secret (§2.2, §2.3; the Revision A session-fixation fix) -> schemas.AuthorizationCodeTokenRequest.code L1252-1254; PKCE parameters.CodeChallenge L760-778, CodeChallengeMethod L780-795, code_verifier L1259-1266; parameters.State L750-757 (also the §4.13 CSRF successor); RFC 9207 iss (authorization_response_iss_parameter_supported L2206-2210)
- [successor] Token Request endpoint (§2.3, POST; form-encoded oauth_token/oauth_token_secret response) -> paths./token.post L210-268 (form-encoded request L241-246, JSON 200 L248-260), schemas.AuthorizationCodeTokenRequest L1235-1266, schemas.TokenResponse L1400-1458
- [successor] token credentials (oauth_token + oauth_token_secret) -> TokenResponse.access_token L1411-1419 (no secret) + token_type L1420-1427 (Bearer/DPoP/N_A); new in 2.0: expires_in L1428-1432, refresh_token L1433-1439, scope L1440-1442
- [successor] client credentials (oauth_consumer_key + client shared secret or RSA key; §3.1, §3.4) -> parameters.ClientId L708-714; schemas.ClientAuthFields L1175-1201 (client_secret_post; client_assertion for client_secret_jwt = HMAC, private_key_jwt = asymmetric); securitySchemes.clientSecretBasic L2662-2674; securitySchemes.mtls L2676-2681; token_endpoint_auth_methods_supported L2037-2049 (includes 'none' for public clients, cf. §4.6); token_endpoint_auth_signing_alg_values_supported L2050-2055
- [successor] 'OAuth' HTTP auth scheme + WWW-Authenticate realm (§3.5.1) -> securitySchemes.bearerAuth L2637-2646 ('Bearer', RFC 6750) and securitySchemes.dpop L2648-2660 ('DPoP', RFC 9449); headers.WWWAuthenticateBearerDPoP L1000-1025; Basic realm examples in headers.WWWAuthenticateBasic L1026-1037
- [successor; proof of possession reintroduced] request signing + oauth_nonce/oauth_timestamp (§3.3, §3.4) -> parameters.DPoPHeader L972-984 (proof JWT with jti, htm, htu, iat, ath, nonce); headers.DPoPNonce L1051-1057; responses.OAuthErrorWithDPoPNonce L1074-1090; parameters.DPoPJKT L962-970; dpop_signing_alg_values_supported L2188-2190; schemas.Confirmation (cnf jkt / x5t#S256) L2575-2591; tls_client_certificate_bound_access_tokens L2193-2198; schemas.NumericDate L2450-2456 (epoch seconds, like oauth_timestamp)
- [successor] §3.2 status-code guidance (400 vs 401; details MAY go in the body) -> schemas.ErrorResponse L1465-1535 (registered error codes), responses.OAuthError L1063-1072, responses.ClientAuthError L1108-1124, responses.ProtectedResourceError L1091-1106
- [successor] endpoint advertisement and configuration discovery (out of scope in §2 and §3) -> paths./.well-known/oauth-authorization-server L630-647; schemas.OAuthServerMetadata L1922ff (issuer L1944-1950, authorization_endpoint L1951-1953, token_endpoint L1954-1956, revocation_endpoint L1973-1976, device_authorization_endpoint L1977-1980, pushed_authorization_request_endpoint L1981-1984)
- [successor] 'Servers SHOULD enable resource owners to revoke token credentials' (§2) -> paths./revoke L273-314, schemas.RevocationRequest L1794-1810 (client-initiated revocation per RFC 7009)
- [successor] scoping, which 1.0 did not have (§4.8) -> parameters.Scope L732-748, TokenResponse.scope L1440-1442, parameters.AuthorizationDetails L870-878 (RAR), parameters.Resource L880-895 (RFC 8707)
- [successor] 'oob' callback + manual verifier entry on limited devices (§2.1, §2.2) -> paths./device_authorization L368-421, schemas.DeviceAuthorizationResponse L1552-1578 (user_code, verification_uri)
- [successor] protecting authenticated content from proxies and caches (§4.4) -> headers.CacheControlNoStore L990-994 and PragmaNoCache L995-999 on /token 200 (L251-254)
- [loose analog; this analysis's own observation, RFC 9126 does not cite RFC 5849] temporary-credential request (§2.1: client-authenticated back-channel POST that registers the callback and returns a short-lived handle used in the browser redirect) -> paths./par L422-480, schemas.PARRequest L1583-1647, schemas.PARResponse L1649-1678 (request_uri, expires_in), parameters.RequestUri L857-868

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 5849: references/rfc-validation has no file for it and the May-2026 audit never cited it. Nothing to follow up.

**Notes.** VERIFICATION (2026-10-10)
- rfc-editor.org metadata: April 2010, Informational, IETF stream / NON WORKING GROUP, from draft-hammer-oauth-10, 38 pages, obsoleted by RFC 6749, no updates, DOI 10.17487/RFC5849.
- The local text is byte-identical to https://www.rfc-editor.org/rfc/rfc5849.txt (sha256 89e6fca1...a31441, 80,786 bytes).
- RFC 5849 has no IANA Considerations section. Datatracker shows IANA state 'No IANA Actions'.
- Errata: 1 verified technical, 3 held for document update (2718, 2860, 3328, all editorial), 1 rejected (2549).
  - Verified erratum 2550: the example oauth_signature in §3.1, §3.4.1.1 and §3.4.1.3.1 was computed for GET, but the example request is POST. The correct value is r6%2FTJjbCOr97%2F%2BUU0NsvSne7s5g%3D.
  - This analysis recomputed the base string and HMAC-SHA1 from scratch and confirmed it: the printed bYT5CMsGcbgUdFHObYMEfcx6bsw%3D is the GET signature.

ELEMENTS ENUMERATED (none appear in the YAML, which is correct for an OAuth 2.x server)
- Endpoints: Temporary Credential Request (§2.1, POST), Resource Owner Authorization (§2.2, GET), Token Request (§2.3, POST).
- Request parameters: oauth_callback (REQUIRED; absolute URI or case-sensitive 'oob'), oauth_token, oauth_verifier, oauth_consumer_key, oauth_signature_method, oauth_signature, oauth_timestamp, oauth_nonce, oauth_version (OPTIONAL, MUST be '1.0'), realm.
- Response parameters: oauth_token, oauth_token_secret, oauth_callback_confirmed (MUST be 'true'), sent as application/x-www-form-urlencoded with status 200.
- Signature methods: HMAC-SHA1 (§3.4.2), RSA-SHA1 (§3.4.3), PLAINTEXT (§3.4.4).
- Signature base string (§3.4.1) and its percent-encoding rules (§3.6).
- The 'OAuth' auth scheme in Authorization and WWW-Authenticate (§3.5.1).
- Three parameter transmission methods (§3.5).
- 400 vs 401 status guidance (§3.2).

Grep evidence from oauth-openapi.yaml:
- 0 hits for 5849, 'OAuth 1', 'oauth_', HMAC-SHA1, RSA-SHA1, PLAINTEXT, 'base string', 'oob', 'temporary credential', 'token secret', 'Authorization: OAuth' or 'OAuth realm'.
- All 30 lines matching 'nonce' are the OIDC nonce or the DPoP nonce.
- All 6 'verifier' lines are PKCE.
- All 3 'realm' lines are Basic-challenge examples (L1036-1037, L1049).
- The 'Covered specifications' table (L16-43) starts at RFC 6749 and makes no claim about OAuth 1.0.
- Nothing contradicts RFC 5849, so 'gaps' and 'incorrect' are empty by design.

CARRIED INTO OAUTH 2.0 (renamed)
- Roles (§1.1). RFC 6749 §1.1 split the single 'server' into an authorization server and a resource server, an idea that came from OAuth WRAP.
- Consumer key and secret became client_id and client_secret.
- The Resource Owner Authorization endpoint became /authorize; the Token Request endpoint became /token.
- oauth_callback became redirect_uri. It is now pre-registered and matched exactly (RFC 9700 §2.1) instead of being sent in the signed back-channel step.
- oauth_verifier became the authorization code: a one-time value that travels through the browser redirect and must be presented at the token endpoint.
- 'The server MUST revoke the temporary credentials after being used once' and 'RECOMMENDED limited lifetime' (§2) became single-use, short-lived codes (RFC 6749 §4.1.2).
- 'Servers SHOULD enable resource owners to revoke token credentials' (§2) became RFC 7009 revocation.
- 'TLS MUST' for credential exchanges (§2.1, §2.3, §3.4.4; Appendix A raised it from SHOULD) became mandatory TLS (RFC 6749 §3.1/§3.2, RFC 6750 §1).
- Security considerations carried forward into RFC 6749 §10, RFC 6819 and RFC 9700: CSRF (§4.13), clickjacking (§4.14), phishing (§4.7), entropy (§4.9). The §4.6 warning that client secrets in desktop apps are not secret became public clients plus PKCE.
- The §1.2 photo-printing example reappears almost word for word in RFC 6749 §1.
- A subtle carry-over: with HMAC-SHA1 or PLAINTEXT, the §2.3 token request must be signed with the per-flow temporary-credential secret. So an attacker who steals oauth_token and oauth_verifier from the callback URL cannot redeem them. RSA-SHA1 ignores the token secret (§4.1), so this only holds for the other two methods.
  - OAuth 2.0 lost this property for public clients; RFC 7636 §1 calls the result the 'authorization code interception attack'.
  - PKCE's code_verifier restored it.

DROPPED, AND WHY
- What was dropped:
  - the temporary-credential step (OAuth 2.0 starts directly at /authorize with client_id)
  - oauth_callback_confirmed and oauth_version (version flags that 2.0 does not need)
  - token secrets and all request signing: oauth_signature_method, oauth_signature, the base string, the §3.6 encoding rules, and nonce/timestamp
  - form-encoded credential responses (OAuth 2.0 returns JSON, RFC 6749 §5.1)
- Why signing was dropped:
  - (a) Normalizing the base string (decode, sort, re-encode, host/port rules) was the main interoperability pain point. Even RFC 5849's own worked example got it wrong (erratum 2550).
  - (b) HMAC forced servers to store secrets in plaintext (§4.5).
  - (c) SHA-1 was weakening (§4.11).
  - (d) The base string never covered the body or most headers (§3.4.1, §4.12), so TLS was needed anyway (§4.2).
- Where the alternative came from:
  - OAuth WRAP (draft-hardt-oauth-01, 15 January 2010; authors from Microsoft, Yahoo! and Google) used short-lived opaque bearer access tokens plus refresh tokens, always over HTTPS. RFC 6749 Appendix C names WRAP as OAuth 2.0's second ancestor.
  - RFC 6750 then made TLS mandatory (§1). Its §1.2 defines a bearer token as usable by 'any party in possession'.
- How the 'OAuth' scheme became 'Bearer' (verified in archived drafts):
  - early OAuth 2.0 drafts used 'Token' (draft-ietf-oauth-v2-05/-08, May-June 2010)
  - then reused 'OAuth' (draft-ietf-oauth-v2-10, July 2010; draft-ietf-oauth-v2-bearer-00, November 2010)
  - then 'OAuth2' (bearer-02, January 2011)
  - finally 'Bearer' (bearer-04, March 2011)
- Because IANA's 'OAuth' entry still means RFC 5849 §3.5.1, an OAuth 2.1 server should not accept 'Authorization: OAuth &lt;token>' as an alias for Bearer. It should answer 401 with a Bearer/DPoP challenge, which the YAML already models (responses.ProtectedResourceError L1091-1106).
- Sending parameters in the query string (§3.5.3) survived in RFC 6750 §2.3. RFC 9700 §4.3.2 now says clients MUST NOT pass access tokens in a URI query parameter.

NEW IN 2.0 (absent from 1.0)
- scope (§4.8 admits 1.0 had none)
- expires_in
- refresh tokens
- a registered error-code vocabulary
- more grant types
- discovery (RFC 8414; §2 and §3 left discovery out of scope)

WHAT CAME BACK (proof of possession)
- RFC 6749 §7.1 already sketched a 'mac' token type. Three later attempts all expired on datatracker:
  - draft-ietf-oauth-v2-http-mac (expired at -05, 2014)
  - draft-ietf-oauth-signed-http-request (expired at -03, 2017)
  - draft-ietf-oauth-token-binding (expired at -08, 2019)
- What shipped: RFC 7800 cnf (April 2016), RFC 8705 certificate-bound tokens (February 2020), and RFC 9449 DPoP (September 2023).
- DPoP is OAuth 1.0's signing idea, slimmed down:
  - jti and iat play the roles of oauth_nonce and oauth_timestamp.
  - An optional server nonce (DPoP-Nonce) adds freshness.
  - htm and htu are the HTTP method and the URI without query or fragment. These are the same pieces as RFC 5849's base string URI (§3.4.1.2), minus the parameters.
  - ath binds the proof to the access token.
- RFC 9449 §4.2 says DPoP signs only the method and URI 'to avoid the substantial difficulties inherent in attempting to normalize HTTP messages'.
- §4.2 also forbids symmetric MAC algorithms, so the server never stores a shared secret (fixing §4.5).
- §11.7 says DPoP intentionally does not protect the integrity of the body or headers.
- Unlike 1.0, where every resource request carried both client and token credentials, DPoP binds the token to a key. It does not authenticate the client at the resource server (RFC 9449 §11.11).
- Full-message signing lives on in HTTP Message Signatures (RFC 9421, February 2024). Its Acknowledgements credit draft-ietf-oauth-signed-http-request-03. GNAP uses it for key proofing (RFC 9635 §7.3.1). Neither is modeled in the YAML, and both are outside this cluster.

VENDORING ADVICE
Add rfc5849.txt to references/rfc-sources as a clearly labelled historical reference ('Informational, Apr 2010 - obsoleted by RFC 6749 - not modeled'):
- Add an index row to references/rfc-sources/README.md.
- Add 5849 to the refresh loop.
- Note that this extends the README's inclusion rule ('every OAuth WG RFC' plus audit sources) with one historical, non-WG origin document.
Why:
- The user asked for all RFCs from the beginning.
- The vendored RFC 6749 cites it in its Abstract, §1 and Appendix C.
- IANA's 'OAuth' auth-scheme entry still references it.
- It is small and frozen (80,786 bytes).
Do not add it to the YAML's 'Covered specifications' table. A one-line 'Lineage (not modeled): RFC 5849 OAuth 1.0 (2010) -> obsoleted by RFC 6749' note in info.description (L9-60) is optional and documentation only, not a gap. OAuth WRAP (draft-hardt-oauth-01) is the other ancestor named in RFC 6749 Appendix C; as a non-RFC draft it is catalog-only.

_No open findings._
