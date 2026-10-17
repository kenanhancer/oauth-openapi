# OAuth 2.1 — draft-ietf-oauth-v2-1-16

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [draft-ietf-oauth-v2-1-16](#draft-ietf-oauth-v2-1-16-the-oauth-21-authorization-framework) | September 2026 | Internet-Draft -16 (OAuth WG Document, intended Standards Track; not yet an RFC; expires 7 March 2027) | mostly | 3 | 8 | 36 |

**Cluster notes.** This cluster has one docs entry, for draft-ietf-oauth-v2-1-16, the current revision (3 Sep 2026). Revision -15 (2 Mar 2026), which references/rfc-sources held until this audit replaced it with -16, was used only for comparison. A paragraph-level diff of the two, with page breaks removed, confirms the -16 changelog and adds three more facts: the client rule for PKCE methods went from SHOULD to MUST, the 'S256 is MTI' sentence was deleted, and Security Considerations were renumbered (§7.5.2 and §7.9 inserted). The YAML was written against -15, so its PKCE and iss passages are now wrong. Two of its section citations also became stale. No IANA-absent entries belong to this cluster: OAuth 2.1 §11 requests no IANA actions. The intentional exclusions were not reported: Implicit, ROPC, vendor x-* extensions, and the limits of modeling /authorize redirects in OpenAPI.

## draft-ietf-oauth-v2-1-16 The OAuth 2.1 Authorization Framework

*September 2026 · Internet-Draft -16 (OAuth WG Document, intended Standards Track; not yet an RFC; expires 7 March 2027) · YAML coverage: **mostly** · relevance to an AS: required-oauth21 · vendoring: vendor*

**What it is.** OAuth 2.1 is the OAuth working group's consolidated rewrite of OAuth 2.0 (RFC 6749) and Bearer Token Usage (RFC 6750). It folds in PKCE (RFC 7636), Native Apps (RFC 8252), browser-app guidance and the Security BCP (RFC 9700), and once published it will obsolete RFC 6749 and RFC 6750. It keeps three grants (authorization code with mandatory PKCE, client credentials, refresh token) plus extension grants. It drops the Implicit and Resource Owner Password grants, requires exact redirect-URI matching, bans bearer tokens in URL query strings, and requires rotation or sender-constraining of public clients' refresh tokens. Revision -16 (3 Sep 2026) removes the PKCE `plain` method, so code_challenge_method is now REQUIRED and S256 is the only defined value; it also makes the `iss` authorization-response parameter REQUIRED and adds Value Sizes (§1.7.1) and Consent Phishing (§7.9) sections.

**Why it was created.** By the 2020s a secure OAuth 2.0 deployment meant reading RFC 6749 together with a stack of later documents (RFC 6750, 7636, 8252, 9700 and the browser-apps BCP), and knowing which original features had turned dangerous. Real attacks had shown the problems: implicit-grant and URL-borne tokens leaked through browser history and Referer headers; loose redirect-URI matching created open redirectors and code theft; authorization codes could be intercepted or injected; public clients' refresh tokens could be replayed; clients talking to several authorization servers were open to mix-up attacks; 307 redirects could forward user passwords; and password-sharing grants trained users to hand credentials to apps. OAuth 2.1 packages these lessons into one secure-by-default specification, so new implementers start from the safe subset.

<details><summary>Already modeled in the YAML (38)</summary>

- Authorization endpoint, GET required (§3.1): paths./authorize.get, lines 109-205
- PAR at the authorization endpoint, mentioned in §3.1 since -16: /authorize description lines 125-128; parameters.RequestUri lines 857-868; paths./par lines 422-476
- response_type=code; implicit `token` excluded (§4.1.1, §10.1): parameters.ResponseType lines 686-706
- client_id REQUIRED at /authorize (§4.1.1): parameters.ClientId lines 708-714 (required: true, line 711)
- redirect_uri exact-string matching, REQUIRED when several URIs are registered (§2.3.1, §2.3.2): parameters.RedirectUri lines 716-730
- scope with the §1.4.1/A.4 ABNF pattern: parameters.Scope lines 732-748 (pattern at line 744)
- state (§4.1.1, §4.1.2): parameters.State lines 750-758
- code_challenge, 43-128 unreserved characters, REQUIRED except in the §7.5.1.1 confidential-client + nonce case (§4.1.1, §7.5.1.1, A.18): parameters.CodeChallenge lines 760-778
- code_challenge_method limited to S256 (§4.1.1): parameters.CodeChallengeMethod lines 780-795 (enum at line 795; description outdated, see incorrect)
- Success redirect with code, state and iss in Location (§4.1.2): /authorize responses.302 lines 160-181 (examples lines 180-181)
- Error redirect with error, error_description, error_uri, state and iss (§4.1.2.1): /authorize 302 description lines 168-169, example line 181
- 303 alternative and 307 prohibition (§7.5.4, §1.6): lines 171-172; responses.303 lines 182-189
- Non-redirecting HTTP 400 for an invalid redirect_uri or client_id (§2.3.5, §4.1.2.1): /authorize responses.400 lines 196-205
- Token endpoint, POST only, application/x-www-form-urlencoded (§3.2, §3.2.2, App. C.2): paths./token.post lines 210-268 (media type at line 244)
- grant_type dispatch for authorization_code, client_credentials, refresh_token and absolute-URI extension grants (§3.2.2, §4.4): schemas.TokenRequest lines 1152-1171
- Authorization-code token request: code and code_verifier REQUIRED, redirect_uri optional for back-compat (§4.1.3, §10.2): schemas.AuthorizationCodeTokenRequest lines 1235-1266 (required at line 1244)
- Client credentials request with optional scope (§4.2.1): schemas.ClientCredentialsTokenRequest lines 1268-1282
- Refresh-token request: refresh_token REQUIRED, scope no broader than granted, plus rotation/sender-constraint note for public clients (§4.3.1): schemas.RefreshTokenRequest lines 1284-1307
- client_secret_post body fields client_id and client_secret (§2.4.1): schemas.ClientAuthFields lines 1175-1190
- client_secret_basic (§2.4.1, MAY): securitySchemes.clientSecretBasic lines 2662-2674; /token security lines 265-268
- Private Key JWT and client_secret_jwt via client_assertion + client_assertion_type (§2.4, §2.4.2): ClientAuthFields lines 1191-1200
- mTLS client authentication (§2.4, §2.4.2): securitySchemes.mtls lines 2676-2681
- Public clients with no credentials (§2.1, §3.2.2): /token security `{}` at line 268; description lines 229-235
- Token response: access_token and token_type REQUIRED, plus expires_in, scope, refresh_token (§3.2.3): schemas.TokenResponse lines 1400-1442 (required at line 1408)
- Cache-Control: no-store on token responses and token errors (§3.2.3, §3.2.4): headers.CacheControlNoStore lines 990-994; /token 200 lines 251-252; responses.OAuthError lines 1066-1067; OAuthErrorWithDPoPNonce lines 1081-1082; ClientAuthError lines 1118-1119
- Token error body: §3.2.4 error codes, error_description character-set pattern, error_uri (§3.2.4, A.7-A.9): schemas.ErrorResponse lines 1465-1533 (codes 1478-1488, pattern line 1524)
- invalid_client returned as HTTP 401 with a WWW-Authenticate matching the client's scheme (§3.2.4): responses.ClientAuthError lines 1108-1125; headers.WWWAuthenticateBasic lines 1026-1037; /token 401 lines 263-264
- Unrecognized parameters ignored (§3.1, §3.2, §3.2.3): no additionalProperties:false anywhere; TokenResponse additionalProperties: true (line 1409); ErrorResponse (line 1472)
- Bearer token in the Authorization header (§5.1.1): securitySchemes.bearerAuth lines 2637-2646
- Form-encoded access_token in the request body, POST only (§5.1.2): paths./userinfo.post requestBody lines 532-545
- No bearer tokens in URI query (§5.1, §7.1.3.7): stated at schemas.ProtectedResourceMetadata.bearer_methods_supported lines 2296-2304; no query-token parameter is modeled
- Resource-server errors: WWW-Authenticate Bearer challenge, invalid_token and insufficient_scope (§5.3.1, §5.3.2): headers.WWWAuthenticateBearerDPoP lines 1000-1025; responses.ProtectedResourceError lines 1091-1107; ErrorResponse codes lines 1489-1491
- Sender-constrained tokens via DPoP or mTLS (§1.4.3, §4.3.1): parameters.DPoPHeader lines 972-984; securitySchemes.dpop lines 2648-2660; schemas.Confirmation lines 2575-2591; tls_client_certificate_bound_access_tokens lines 2193-2198
- Discoverable PKCE methods (§7.10): OAuthServerMetadata.code_challenge_methods_supported lines 2176-2185 (enum [S256])
- Issuer identification for mix-up defense (§4.1.2, §7.15.1): OAuthServerMetadata.issuer lines 1944-1950; authorization_response_iss_parameter_supported lines 2206-2211
- HTTPS-only endpoints (§1.5): servers 'https://{issuer}' lines 77-86
- Implicit and ROPC excluded as intended (§10, §10.1): /authorize description lines 120-123; /token description lines 226-227; ResponseType enum lines 703-706; TokenRequest mapping lines 1165-1171
- Value sizes (§1.7.1): no maxLength on client_id, code, tokens or state; only the ABNF-defined PKCE bounds (CodeChallenge lines 776-777, code_verifier lines 1261-1262)

</details>

**Follow-up on the May-2026 validation notes.** The May-2026 note (references/rfc-validation/oauth-2.1-draft.md) audited draft -13 against an older YAML, so its line numbers no longer match. MISSING (18 bullets): 6 fixed — redirect_uri removed from the token request's required list, the public-client refresh-token rotation/sender-constraint note, the /authorize 400 non-redirect response, the 303 alternative with the 307 ban, Cache-Control on /token 400, and WWW-Authenticate on /token 401. 5 partially fixed — iss is documented but only conditionally (now contradicted by -16's REQUIRED); exact redirect matching is stated without the loopback exception; the query-token ban appears only under bearer_methods_supported; the mix-up defense appears only through the RFC 9207 metadata flag; the error-code partition exists only as enum comments. 7 still open — GET/optional-POST note, CORS on /token, CORS ban at /authorize, 10-minute code lifetime, single-use codes, token entropy, and client_credentials limited to confidential clients. WRONG (12 bullets): 5 fixed — required redirect_uri, hybrid 'code token' and 'code id_token token' removed, PAR request_uri documented, unknown parameters no longer rejected (no additionalProperties:false), and code_challenge_methods_supported profiled to S256. 3 partially fixed — the plain deprecation cites RFC 9700 rather than OAuth 2.1 §7.5.2; the scope ABNF pattern exists only on the /authorize Scope parameter; the rule that scope is required when it differs is only paraphrased. 1 superseded — the YAML adopted the note's recommended 'OPTIONAL, defaults to plain' wording for code_challenge_method, and -16 now contradicts it (the main open high item). 3 still open — token_type case-insensitivity, the expires_in caveat, and the prompt=none note. The synthesis file tallies this note as 14 MISSING / 11 WRONG; the counts above are per bullet.

**Notes.** Comparison with -15 (2 Mar 2026, the revision vendored before this audit) by paragraph-level diff. Normative changes: (1) §4.1.1 code_challenge_method went from OPTIONAL with default plain to REQUIRED (S256 or a future extension); plain is 'removed and explicitly prohibited' (new §7.5.2; new §10 bullet); the client rule went from 'SHOULD use' to 'MUST use' code challenge methods that do not expose the verifier; the 'S256 is Mandatory To Implement' sentence was deleted. (2) iss went from OPTIONAL to REQUIRED in §4.1.2 and §4.1.2.1, and §7.15.1 now names iss as the issuer transport. (3) New §1.7.1 Value Sizes replaces the per-section size notes in §2.2, §3.2.3 and §4.1.2, and adds a state-length note in §4.1.1. (4) New §7.9 Consent Phishing. (5) §4.1.2.1 now says SHOULD use HTTP 400 for direct errors, says 401 does not apply, and requires validating client_id and redirect URI before redirecting errors. (6) §3.1 now mentions PAR. Renumbering: §7.5.2 became §7.5.3, §7.5.3 became §7.5.4, and §7.9-§7.14 became §7.10-§7.15; this breaks YAML lines 171 and 183. Editorial changes: the TLS reference moved from RFC 8446 to RFC 9846 (July 2026); the loopback cross-reference moved from RFC 8252 §7.3 to §8.4.2; references were bumped (rfc7523bis-11, attestation-based-client-auth-10, browser-based-apps-27, RFC 9112) and client-id-metadata-document-02 was added. The YAML matched -15 on PKCE and iss, and those passages are now incorrect. Citation audit of the 14 YAML lines that cite OAuth 2.1: valid as written — 123 (§7.5.1.1), 695, 722 (§2.3.1), 768 (§4.1.1/§7.5.1.1), 1237 (§10.2), 2304 (§5.1); imprecise — 691 (§10.1), 1256 (§10.2), 1286 and 1436 (§4.3.1), 2183 (§4.1.1 MTI); stale numbering — 171 and 183 (§7.5.3 should be §7.5.4); contradicted by -16 — 785 (§4.1.1). Tension inside the draft: the last processing bullet of §4.1.3 ('If there was no code_challenge … MUST reject the token request') conflicts with the §7.5.1.1 exception for confidential clients using nonce. The YAML documents the exception at /authorize (lines 120-123, 768-771), but it requires code_verifier unconditionally (line 1244) and code_challenge at /par (line 1594), which follows the strict reading; the YAML should say so explicitly. Also, -16 lists rfc7523bis only as an informative reference even though §2.4 says implementations MUST follow it. IANA: no IANA-absent entries are attributed to OAuth 2.1 (§11: no IANA actions), and every OAuth-core registry value it uses appears in the YAML. Status: -16 is a WG Document (not yet in IESG review) that expires 2027-03-07. It still cites I-D browser-based-apps-27 even though that became RFC 10017 in Aug 2026, and §9 Browser-Based Apps is still a TODO, so a -17 is likely. Vendoring: replace references/rfc-sources/draft-ietf-oauth-v2-1.txt with -16 (bump the -15 curl line in rfc-sources/README.md), pin the revision in info.description (line 43 says only 'ongoing'), and redo references/rfc-validation/oauth-2.1-draft.md. That note is still titled draft-13, and the cached source file it mentions is not in the repo. Intentional exclusions (Implicit, ROPC, vendor x-* extensions, redirect-modeling limits) were not reported as gaps.

### Findings (3 high · 8 medium · 36 low)

1. **[HIGH] Gap: Audience rule for JWT client authentication (client_assertion aud and typ, per rfc7523bis)**  
   *Reference:* §2.4, §2.4.2 (draft-ietf-oauth-rfc7523bis-11 §4 item 3b and the §3.2 addition)  
   Since -15, OAuth 2.1 §2.4 says 'clients and authorization servers MUST follow the updated guidance around aud values in [I-D.ietf-oauth-rfc7523bis]'. That draft is now in the RFC Editor queue. For client authentication it requires `aud` to be the AS issuer identifier as the sole value, forbids the token endpoint URL as audience, and requires the AS to reject any JWT that does not carry its issuer identifier as the sole audience. It adds `typ: client-authentication+jwt` as a SHOULD and says servers are NOT RECOMMENDED to reject untyped JWTs. The YAML's ClientAuthFields.client_assertion (lines 1191-1196) cites only RFC 7523 §2.2 and says nothing about aud or typ. JWTBearerTokenRequest.assertion (lines 1341-1345) tells readers aud is 'the AS token endpoint URL'. Implementers are likely to apply that to client_assertion too, which is the audience-injection pattern the update closes.  
   *Suggested change:* Add to components.schemas.ClientAuthFields.properties.client_assertion.description: 'Per OAuth 2.1 §2.4 and draft-ietf-oauth-rfc7523bis §4: `aud` MUST be the AS issuer identifier (metadata `issuer`) as a single string. The token endpoint URL MUST NOT be used. The AS MUST reject an assertion whose aud is not exactly its issuer (RFC 3986 §6.2.1 simple string comparison). iss and sub = client_id; exp REQUIRED. Clients SHOULD send JOSE header typ=client-authentication+jwt; servers SHOULD NOT reject untyped JWTs.' Change JWTBearerTokenRequest.assertion to 'aud: the AS issuer identifier or its token endpoint URL (rfc7523bis §4 item 3a)'. Add RFC 7521 / RFC 7523 / rfc7523bis to the info.description spec table.  
   *Verifier: confirmed.*

2. **[HIGH] Incorrect: lines 780-795, components.parameters.CodeChallengeMethod (description lines 785-792; required: false at line 783)**  
   *Reference:* §4.1.1, §4.1.2.1, §7.5.2, §10  
   The description says 'In OAuth 2.1 §4.1.1 the parameter is OPTIONAL (defaulting to `plain`), and `plain` is permitted only when the client cannot compute S256 … S256 is mandatory to implement'. That is the -15 text. In -16, §4.1.1 makes code_challenge_method 'REQUIRED, the value S256 or a value defined by a future extension' and says 'Clients MUST use code challenge methods that do not expose the code_verifier'. It also says the RFC 7636 plain method 'is removed and explicitly prohibited', as do §7.5.2 and §10. A server following the YAML would accept a request without the method and, per the description, default to plain, which is the downgrade -16 forbids. The YAML is also internally inconsistent: PARRequest already requires the parameter (line 1594).  
   *Suggested change:* Replace the description with: 'REQUIRED on a plain (non-PAR/JAR) authorization request (OAuth 2.1 §4.1.1, draft-16): S256, or a value defined by a future extension. The RFC 7636 plain method is removed and explicitly prohibited (§4.1.1, §7.5.2). The AS MUST NOT default a missing value to plain; a missing or unsupported method gives error=invalid_request (§4.1.2.1). required:false only because PAR request_uri and JAR request carry the value inside the request object.' Keep enum [S256], and drop the meaningless `default: S256` from PARRequest.code_challenge_method (line 1615).  
   *Verifier: confirmed.*

3. **[HIGH] Incorrect: lines 160-172, paths./authorize.get.responses.302.description (iss conditional at lines 164-165 and 168-169); also responses.303 (lines 182-189)**  
   *Reference:* §4.1.2, §4.1.2.1, §7.15.1 (RFC 9207 §2, §2.3)  
   Says the success redirect carries iss only 'when the AS advertises authorization_response_iss_parameter_supported', and the error redirect carries iss 'per RFC 9207', which is also conditional. -16 changed iss from OPTIONAL to REQUIRED in both the success response (§4.1.2) and the error response (§4.1.2.1), and §7.15.1 now says the issuer 'is transported via the response parameter iss'. A server built from the YAML may omit iss and so violate -16.  
   *Suggested change:* Rewrite the 302 description as: 'Success: code (REQUIRED), state (REQUIRED if sent), iss (REQUIRED, OAuth 2.1 §4.1.2; the AS issuer identifier, byte-identical to metadata issuer per RFC 9207 §2.3). Failure: error (REQUIRED), error_description, error_uri, state (REQUIRED if sent), iss (REQUIRED, §4.1.2.1). With fragment or form_post response modes, iss travels with code/error.' Mirror this on the 303 response. The Location examples at lines 180-181 already show iss.  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: Client credentials grant limited to confidential clients; AS MUST authenticate the client**  
   *Reference:* §4.2, §4.2.1 (also §3.2.1, §3.2.4)  
   §4.2 says 'The client credentials grant type MUST only be used by confidential clients' and §4.2.1 says 'The authorization server MUST authenticate the client.' /token offers the empty security alternative `{}` (line 268) to every grant. ClientCredentialsTokenRequest (lines 1268-1282) requires only grant_type, and no text restricts the `{}` option. A server generated from the YAML would therefore accept `grant_type=client_credentials&client_id=x` with no client authentication. The May-2026 audit raised this too, and it is still open.  
   *Suggested change:* Add to ClientCredentialsTokenRequest.description: 'OAuth 2.1 §4.2/§4.2.1: only confidential clients may use this grant, and the AS MUST authenticate the client (client_secret_post/basic, private_key_jwt, mTLS). Unauthenticated requests are rejected with invalid_client (§3.2.4).' In the /token description (lines 229-235) and the clientSecretBasic description, state that the `{}` alternative applies only to public clients on authorization_code, refresh_token and device_code requests.  
   *Verifier: confirmed.*

5. **[MEDIUM] Gap: authorization_response_iss_parameter_supported must be true for an OAuth 2.1 AS**  
   *Reference:* §4.1.2, §4.1.2.1 (RFC 9207 §2.3)  
   Since -16, iss is REQUIRED in every authorization response. RFC 9207 §2.3 says an AS that supports iss and publishes RFC 8414 metadata MUST set authorization_response_iss_parameter_supported to true. The YAML (lines 2206-2211) keeps RFC 9207's default of false and has no OAuth 2.1 profile note. A generated discovery document could therefore omit the flag, and clients that rely on metadata would treat iss as absent.  
   *Suggested change:* Description for authorization_response_iss_parameter_supported: 'An OAuth 2.1 AS (draft-16 §4.1.2) always returns iss and MUST publish this as true (RFC 9207 §2.3). Omitted or false describes a legacy OAuth 2.0 AS only.' Add an example value of true, and list the field as required in any OAuth 2.1 profile overlay.  
   *Verifier: confirmed.*

6. **[MEDIUM] Gap: Redirect-URI rules: loopback with variable port, private-use schemes, no fragment, https**  
   *Reference:* §2.3, §2.3.1, §4.1.1, §8.4.2, §8.4.3, §1.5  
   RedirectUri (lines 716-730) states only exact-string matching and omits the normative exception. For loopback IP redirect URIs (http://127.0.0.1:{port}/… and http://[::1]:{port}/…) the AS MUST allow any port at request time (§4.1.1, §8.4.2), and these URIs may use http (§1.5); localhost is NOT RECOMMENDED. Private-use schemes must be reverse-domain names, and the AS SHOULD reject schemes without a period (§2.3.1, §8.4.3). Redirect URIs MUST be absolute and MUST NOT contain a fragment (§2.3). A server applying the YAML text literally would reject native-app loopback redirects that use ephemeral ports. Neither 'loopback' nor 'fragment' appears in the redirect_uri text.  
   *Suggested change:* Extend parameters.RedirectUri.description: 'Exact match, except for loopback IP literals 127.0.0.1 and [::1] over http, where the AS MUST ignore the port (OAuth 2.1 §4.1.1, §8.4.2). Private-use schemes must be reverse-DNS names such as com.example.app:/cb, and the AS SHOULD reject schemes without a period (§2.3.1). MUST be absolute and fragment-free (§2.3); https is required except for loopback (§1.5).' Add schema pattern '^[^#]*$' and examples 'http://127.0.0.1:51004/oauth2redirect/example-provider' and 'com.example.app:/oauth2redirect/example-provider'.  
   *Verifier: confirmed.*

7. **[MEDIUM] Gap: Discoverable PKCE support: code_challenge_methods_supported published and containing S256**  
   *Reference:* §7.10, §4.1.1 (RFC 9700 §2.1.1)  
   §7.10: 'AS therefore MUST provide a way to detect their supported code challenge methods either via AS metadata according to [RFC8414] or provide a deployment-specific way.' The YAML field (lines 2176-2185) is optional, is not in any required list, and permits an empty array because it has no minItems or contains.  
   *Suggested change:* Add `minItems: 1` and `contains: {const: S256}` to OAuthServerMetadata.code_challenge_methods_supported, with the description 'OAuth 2.1 §7.10: publish this field (or document a deployment-specific alternative); it MUST include S256.' Consider making it required in an OAuth 2.1 profile.  
   *Verifier: confirmed.*

8. **[MEDIUM] Gap: CORS policy: forbidden at /authorize, needed at /token and other browser-reachable endpoints**  
   *Reference:* §3.1, §3.2  
   §3.1: 'Cross-Origin Resource Sharing [WHATWG.CORS] MUST NOT be supported at the Authorization Endpoint.' §3.2: an AS that supports browser-based apps needs CORS headers on the token endpoint, and also on metadata, registration, revocation, introspection, discovery and userinfo endpoints. The YAML never mentions CORS (no hits for CORS or Access-Control).  
   *Suggested change:* Add components.headers.AccessControlAllowOrigin (type string). Reference it optionally on the 200/400/401 responses of /token and /revoke, and on the 200 responses of /userinfo, /jwks and /.well-known/*, citing OAuth 2.1 §3.2 and RFC 10017. Add to the /authorize description: 'CORS MUST NOT be supported here (§3.1): never emit Access-Control-Allow-* headers or answer preflight requests.'  
   *Verifier: confirmed.*

9. **[MEDIUM] Gap: Clickjacking defenses on the /authorize HTML (Content-Security-Policy frame-ancestors, X-Frame-Options)**  
   *Reference:* §7.11  
   'Authorization servers MUST prevent clickjacking attacks' and 'SHOULD also use Content Security Policy (CSP) level 2 or greater' on the authorization endpoint, login, consent, device-verification and error pages. The /authorize 200 and 400 text/html responses (lines 190-205) declare no response headers.  
   *Suggested change:* Add components.headers.ContentSecurityPolicy (example "frame-ancestors 'none'") and components.headers.XFrameOptions (example DENY), and reference both from /authorize responses 200 and 400 with a §7.11 note. Mention that the same applies to the RFC 8628 verification_uri page.  
   *Verifier: confirmed.*

10. **[MEDIUM] Gap: Authorization code lifecycle: single use, short lifetime, bindings, invalid_grant**  
   *Reference:* §4.1.2, §4.1.3, §7.5.3, §3.2.4  
   Codes 'MUST expire shortly after' issuance (a maximum of 10 minutes is RECOMMENDED) and are bound to the client_id, code challenge and redirect URI (§4.1.2). The AS 'MUST return an access token only once for a given authorization code'. A second valid request MUST be denied, and the AS SHOULD revoke tokens already issued from that code, but SHOULD NOT revoke when the replayed request carries invalid parameters (§4.1.3, §7.5.3). AuthorizationCodeTokenRequest.code (lines 1249-1251) says only 'The authorization code received from /authorize'. The terms 'only once', 'single use' and '10 minutes' appear nowhere in the YAML.  
   *Suggested change:* Extend AuthorizationCodeTokenRequest.properties.code.description: 'Single use: a second valid exchange MUST be denied with invalid_grant, and the AS SHOULD revoke tokens issued from that code unless the replayed request is otherwise invalid (§4.1.3, §7.5.3). Short-lived (10 minutes or less RECOMMENDED, §4.1.2). Bound to client_id, code_challenge and redirect URI; any mismatch gives invalid_grant (§3.2.4).'  
   *Verifier: confirmed.*

11. **[MEDIUM] Incorrect: lines 1185-1190, components.schemas.ClientAuthFields.properties.client_secret; lines 2662-2674, components.securitySchemes.clientSecretBasic**  
   *Reference:* §2.4, §2.4.1, §10  
   client_secret calls the form-body method 'NOT RECOMMENDED per RFC 6749 §2.3.1' and says Basic 'is preferred'. clientSecretBasic calls itself 'PREFERRED over the form-body client_secret_post variant'. OAuth 2.1 reverses RFC 6749 on this point. §2.4.1 says the AS 'MUST support the client including the client credentials in the request body content', makes HTTP Basic only a MAY, and explains that body credentials avoid Basic's encoding interop problems. §10 lists 'Authorization servers must support client credentials in the request body', and §2.4 RECOMMENDS asymmetric methods (mTLS, private_key_jwt). Because the YAML claims OAuth 2.1 defaults (line 8), this wording could lead an implementer to drop client_secret_post.  
   *Suggested change:* client_secret: 'client_secret_post: an OAuth 2.1 AS MUST support client_id + client_secret in the form body for clients issued a secret (§2.4.1), never in the URI. RFC 6749 §2.3.1 called this NOT RECOMMENDED; OAuth 2.1 reverses that.' clientSecretBasic: 'OPTIONAL for an OAuth 2.1 AS (§2.4.1 MAY); client_id and client_secret are form-urlencoded before Base64. Asymmetric methods (private_key_jwt, tls_client_auth) are RECOMMENDED (§2.4).'  
   *Verifier: confirmed.*

12. **[LOW] Gap: Encoding of HTTP Basic client credentials**  
   *Reference:* §2.4.1, Appendix B  
   Under client_secret_basic, client_id and client_secret are each application/x-www-form-urlencoded before being joined with ':' and Base64-encoded. -16 notes that skipping this step has caused interop failures. The clientSecretBasic description (lines 2662-2674) does not mention it.  
   *Suggested change:* Add to securitySchemes.clientSecretBasic: 'username = form-urlencode(client_id), password = form-urlencode(client_secret) (OAuth 2.1 §2.4.1, App. B). Servers must URL-decode both after Base64 decoding.'  
   *Verifier: confirmed.*

13. **[LOW] Gap: Explicit metadata instead of RFC 8414 defaults (token_endpoint_auth_methods_supported, grant_types_supported)**  
   *Reference:* §2.4.1, §10, §10.1  
   The RFC 8414 defaults in the YAML (line 2049 [client_secret_basic]; line 2036 [authorization_code, implicit]) misdescribe an OAuth 2.1 server. Such a server MUST support client_secret_post when it issues secrets, and it has no implicit grant.  
   *Suggested change:* Add: 'An OAuth 2.1 AS SHOULD publish both arrays explicitly. Include client_secret_post whenever client secrets are issued (§2.4.1), and never rely on the RFC 8414 default that implies implicit (§10.1).'  
   *Verifier: partially correct —* The YAML's defaults are accurate RFC 8414 text, and line 2036 already warns that implicit is gone, so the grant_types part is largely handled. What remains is token_endpoint_auth_methods_supported: an OAuth 2.1 AS that issues client secrets and omits the field would advertise Basic only, contrary to §2.4.1. Recommend publishing it with client_secret_post listed.

14. **[LOW] Gap: Value Sizes (new §1.7.1)**  
   *Reference:* §1.7.1, §2.2, §3.2.3, §4.1.1 (state), §4.1.2  
   New in -16: the lengths of client_id, codes and access/refresh tokens are undefined. Receivers MUST NOT assume a maximum, issuers SHOULD document their lengths, implementations SHOULD support values up to the 8000-octet request line (RFC 9112 §3), and resource servers should accept structured tokens over 1 KB. The YAML complies by imposing no maxLength, but it documents none of this (no hits for '8000' or 'length').  
   *Suggested change:* Add a 'Value sizes' bullet under info.description modeling notes. Add a short note to ClientId, State, AuthorizationCodeTokenRequest.code and TokenResponse.access_token/refresh_token: 'length undefined (OAuth 2.1 §1.7.1); the issuer SHOULD document it; keep authorization URLs within the 8000-octet request line, and use PAR for large requests.'  
   *Verifier: confirmed.*

15. **[LOW] Gap: PKCE error mapping**  
   *Reference:* §3.2.4, §4.1.3, §4.1.2.1  
   code_verifier is REQUIRED if and only if a code_challenge was sent. A code_verifier without a prior code_challenge yields invalid_request (§3.2.4); this is the PKCE-downgrade check. A missing or unsupported code_challenge_method yields error=invalid_request on the redirect (§4.1.2.1). code_verifier (lines 1259-1266) documents only the syntax.  
   *Suggested change:* Add to code_verifier.description: 'Present iff code_challenge was sent (§4.1.3). A verifier for a code issued without a challenge gives invalid_request (§3.2.4); a mismatch gives invalid_grant.'  
   *Verifier: confirmed.*

16. **[LOW] Gap: Token response semantics (token_type, expires_in, scope)**  
   *Reference:* §3.2.3, §1.4.1  
   token_type is case-insensitive. For expires_in, clients MUST NOT expect validity for the full lifetime, and if it is omitted the AS SHOULD document the default. scope is RECOMMENDED when identical to the request and REQUIRED otherwise (§1.4.1 MUST). The YAML (lines 1420-1442) states none of these precisely; all three were open items in the prior audit.  
   *Suggested change:* Add these sentences to TokenResponse.properties.token_type, expires_in and scope, citing §3.2.3 and §1.4.1.  
   *Verifier: confirmed.*

17. **[LOW] Gap: Bearer usage and resource-server challenge details**  
   *Reference:* §5.1, §5.1.1, §5.3.1, §5.3.2, §7.1.3.7  
   The bearerAuth description (lines 2640-2646) does not state that clients MUST NOT send tokens in the URI query and that resource servers MUST ignore such tokens; that rule appears only under bearer_methods_supported. Also undocumented: the `realm` and `scope` auth-params (`scope` accompanies insufficient_scope), and the rule that realm/scope/error/error_description/error_uri each appear at most once. /userinfo models 401 and 403 but not 400 invalid_request.  
   *Suggested change:* Add the query prohibition to securitySchemes.bearerAuth. Document realm and scope in headers.WWWAuthenticateBearerDPoP, with an example such as 'Bearer realm="example", error="insufficient_scope", scope="openid profile"'. Add a 400 response using ProtectedResourceError on /userinfo GET and POST.  
   *Verifier: confirmed.*

18. **[LOW] Gap: Parameter hygiene: no repeats, empty means omitted, one client-auth method per request**  
   *Reference:* §3.1, §3.2, §2.4, §3.2.4  
   Parameters MUST NOT be repeated unless an extension allows it (RFC 8707 resource does), parameters sent without a value MUST be treated as omitted, and a client MUST NOT use more than one authentication method per request (each violation gives invalid_request). None of these rules is documented.  
   *Suggested change:* Add a modeling note in info.description and a sentence on ClientAuthFields: 'Exactly one client-authentication method per request; combining Basic with client_secret or client_assertion gives invalid_request (OAuth 2.1 §2.4, §3.2.4).'  
   *Verifier: confirmed.*

19. **[LOW] Gap: Appendix A ABNF on scope, state, code and token values outside /authorize**  
   *Reference:* A.4, A.5, A.11, A.12, A.15  
   The scope ABNF pattern exists only on parameters.Scope (line 744). The scope fields in token requests (lines 1280-1282, 1302-1307, 1346-1347, 1383-1384, 1548-1550, 1603-1604) and TokenResponse.scope (lines 1440-1442) are unconstrained strings. state, code, access_token and refresh_token are 1*VSCHAR (%x20-7E) but have no pattern.  
   *Suggested change:* Create components.schemas.ScopeString with the line-744 pattern and $ref it from every scope field. Add pattern '^[\x20-\x7E]+$' to State, code, access_token and refresh_token.  
   *Verifier: confirmed.*

20. **[LOW] Gap: Optional POST at the authorization endpoint**  
   *Reference:* §3.1  
   The AS 'MAY support the POST method' at the authorization endpoint, but only GET is modeled (line 110). OIDC Core §3.1.2.1, a separate cluster, makes POST mandatory for OPs.  
   *Suggested change:* Add paths./authorize.post with an application/x-www-form-urlencoded body that reuses the authorize parameters, noting it is OPTIONAL in OAuth 2.1 §3.1.  
   *Verifier: confirmed.*

21. **[LOW] Gap: Refresh-token response and rotation rules**  
   *Reference:* §4.3.1, §4.3.2, §4.3.3  
   When a new refresh token is issued the client MUST discard the old one, and the new token's scope MUST equal the presented token's scope. Refresh tokens SHOULD expire after a period of inactivity. Under rotation, replaying an invalidated refresh token revokes the active token and the grant. None of this is documented (no hits for 'discard').  
   *Suggested change:* Extend TokenResponse.properties.refresh_token and RefreshTokenRequest descriptions with these §4.3.1-§4.3.3 rules.  
   *Verifier: confirmed.*

22. **[LOW] Gap: Credential entropy**  
   *Reference:* §7.7 (also §1.4, §1.4.2, §4.3)  
   The probability of guessing generated tokens MUST be at most 2^-128 and SHOULD be at most 2^-160. The YAML does not state this anywhere (no hits for entropy, 2^ or guess).  
   *Suggested change:* Add one sentence to TokenResponse.access_token/refresh_token, AuthorizationCodeTokenRequest.code and ClientAuthFields.client_secret.  
   *Verifier: confirmed.*

23. **[LOW] Gap: Consent phishing (new §7.9)**  
   *Reference:* §7.9  
   New in -16, SHOULD-level and with no wire impact. The AS should restrict which scopes a client may request, verify developers before granting sensitive scopes, show the client name, organization and requested scopes on the consent page, and let users and admins view and revoke grants (RFC 7009). The /authorize 200 description (line 191) says only 'HTML consent or authentication page'.  
   *Suggested change:* Expand /authorize responses.200.description with these §7.9 points.  
   *Verifier: confirmed.*

24. **[LOW] Gap: Extension grants and unsupported_grant_type**  
   *Reference:* §4.4, §6.3, §3.2.4  
   TokenRequest is a closed oneOf/discriminator over six grant types (lines 1152-1171). Any other absolute-URI grant_type (§4.4) therefore fails schema validation instead of receiving a 400 unsupported_grant_type JSON error (§3.2.4).  
   *Suggested change:* Document in the TokenRequest description that unknown grant types MUST produce ErrorResponse error=unsupported_grant_type. Optionally add a catch-all ExtensionGrantTokenRequest with grant_type {type: string, format: uri}.  
   *Verifier: confirmed.*

25. **[LOW] Gap: prompt=none and the AS as an open redirector**  
   *Reference:* §7.13.2  
   Attackers can use silent requests (prompt=none) with an attacker-registered redirect_uri to bounce users to phishing sites. The AS MUST take precautions and SHOULD auto-redirect only to trusted URIs. The Prompt parameter (lines 807-819) has no note; the prior audit also left this open.  
   *Suggested change:* Add a §7.13.2 note to parameters.Prompt.  
   *Verifier: confirmed.*

26. **[LOW] Gap: Cache-Control: no-store on other sensitive AS responses**  
   *Reference:* §3.2.3  
   §3.2.3 requires no-store 'in any response containing tokens, credentials, or other sensitive information'. The /userinfo 200 responses (lines 497-511 and 547-561) return personal claims without it.  
   *Suggested change:* Add the Cache-Control: no-store header ($ref headers.CacheControlNoStore) to the /userinfo GET and POST 200 responses.  
   *Verifier: confirmed.*

27. **[LOW] Gap: Authorization-endpoint error routing as clarified in -16**  
   *Reference:* §2.3.5, §4.1.2.1  
   -16 makes three points. The AS MUST validate client_id and redirect_uri before redirecting any error. A missing or invalid client_id (including an unknown one) or a bad redirect_uri is never redirected, and the AS SHOULD answer with HTTP 400. 401 does not apply at the authorization endpoint. The YAML's 400 text (lines 197-201) cites RFC 6749 and mentions only a 'malformed client_id'.  
   *Suggested change:* Reword /authorize responses.400.description to cite OAuth 2.1 §4.1.2.1 and cover missing, invalid and unknown client_id, the 400-not-401 rule, and validation before redirecting.  
   *Verifier: confirmed.*

28. **[LOW] Incorrect: line 171 (paths./authorize.get.responses.302.description) and line 183 (paths./authorize.get.responses.303.description)**  
   *Reference:* §7.5.4, §1.6  
   Both cite 'OAuth 2.1 §7.5.3' for the 303/307 rule, which is -15 numbering. -16 inserted §7.5.2 'PKCE plain Code Challenge Method', so §7.5.3 is now 'Reuse of Authorization Codes' and the HTTP 307 rule is §7.5.4, as §1.6 and §3.1 also reference.  
   *Suggested change:* Change both citations to 'OAuth 2.1 §7.5.4', and pin the revision (draft-ietf-oauth-v2-1-16) in info.description.  
   *Verifier: confirmed.*

29. **[LOW] Incorrect: line 691, components.parameters.ResponseType.description**  
   *Reference:* §4.1.1, §6.4, §10.1  
   'OAuth 2.1 §10.1 permits only `code`' misstates §10.1. That section removes response_type=token and says the removal 'does not have an effect on other extension response types … for example, response_type=id_token'. OAuth 2.1 defines only code (§4.1.1) but allows extension response types (§4.1.1, §6.4), as the YAML's own enum does.  
   *Suggested change:* 'OAuth 2.1 §4.1.1 defines only `code`; §10.1 removes `token` but leaves extension response types such as OIDC `id_token` and `code id_token` unaffected.'  
   *Verifier: confirmed.*

30. **[LOW] Incorrect: lines 1286-1289, components.schemas.RefreshTokenRequest.description; lines 1436-1439, components.schemas.TokenResponse.properties.refresh_token.description**  
   *Reference:* §4.3, §4.3.1 (RFC 9700 §2.2.2, §4.14.2)  
   Both claim that rotation or sender-constraining is 'RECOMMENDED' for confidential clients, citing OAuth 2.1 §4.3.1 and RFC 9700 §2.2.2. Neither source says this. Both impose the MUST on public clients only and note that confidential clients' refresh tokens are already bound by client authentication; RFC 9700 §4.14.2 says the same. OAuth 2.1 §4.3 adds a SHOULD only 'when client authentication is not possible'. Both YAML texts also name only DPoP, although §4.3.1 cites DPoP or mTLS (RFC 8705).  
   *Suggested change:* 'Per OAuth 2.1 §4.3.1 (RFC 9700 §2.2.2), refresh tokens issued to public clients MUST be sender-constrained (DPoP per RFC 9449, or mTLS per RFC 8705) or rotated on every use. Confidential clients' refresh tokens are bound to the client through client authentication (§4.3).'  
   *Verifier: confirmed.*

31. **[LOW] Incorrect: lines 2181-2185, components.schemas.OAuthServerMetadata.properties.code_challenge_methods_supported.description**  
   *Reference:* §4.1.1, §7.5.2, §7.10  
   Cites 'S256 is mandatory to implement on the AS (OAuth 2.1 §4.1.1)', a sentence that existed in -15 but was deleted in -16. It also justifies omitting plain only with RFC 9700 §2.1.1's SHOULD. In -16, S256 is the only defined method, clients MUST use non-exposing methods (§4.1.1), and plain is explicitly forbidden (§7.5.2).  
   *Suggested change:* 'Profiled to ["S256"]: S256 is the only method OAuth 2.1 defines (§4.1.1) and plain is explicitly prohibited (§7.5.2). Per §7.10 the AS MUST make supported methods discoverable, so publish this field.'  
   *Verifier: confirmed.*

32. **[LOW] Incorrect: lines 1255-1258, components.schemas.AuthorizationCodeTokenRequest.allOf[2].properties.redirect_uri.description**  
   *Reference:* §4.1.3, §10.2  
   '(was REQUIRED in OAuth 2.0 §4.1.3)' oversimplifies. RFC 6749 §4.1.3 required redirect_uri only when it was included in the authorization request, and then the values had to be identical. -16 §10.2 says the parameter was removed, and that an AS also serving OAuth 2.0 clients MUST allow it and MUST enforce it as RFC 6749 describes.  
   *Suggested change:* 'Not sent by OAuth 2.1 clients (§10.2). An AS that also serves OAuth 2.0 clients MUST accept it and enforce RFC 6749 §4.1.3: REQUIRED if redirect_uri was in the authorization request, values MUST be identical, else invalid_grant (§3.2.4).'  
   *Verifier: confirmed.*

33. **[LOW] Incorrect: line 1022, components.headers.WWWAuthenticateBearerDPoP.schema.examples[0] ('Bearer, DPoP algs="ES256 PS256"'); line 1049, components.headers.WWWAuthenticateBasicBearer.schema.examples[0] ('Basic realm="as.example.com", Bearer')**  
   *Reference:* §5.3.1 (RFC 6750 §3; RFC 9449 §7.2 Figure 17)  
   Both examples emit a bare Bearer challenge. OAuth 2.1 §5.3.1, like RFC 6750 §3, says the Bearer scheme 'MUST be followed by one or more auth-param values'. The first example copies RFC 9449 Figure 17, so the conflict originates there, but an OAuth 2.1 server should not emit this form.  
   *Suggested change:* Use 'Bearer realm="example", DPoP algs="ES256 PS256"' and 'Basic realm="as.example.com", Bearer realm="as.example.com"', and note the RFC 6750 vs RFC 9449 discrepancy in the description.  
   *Verifier: confirmed.*

34. **[LOW] Incorrect: lines 701-706, components.parameters.ResponseType.schema.enum**  
   *Reference:* §4.1.1, §6.4, A.3  
   The enum accepts the composite response type only in the order 'code id_token'. OAuth 2.1 §4.1.1 and §6.4 say space-delimited response types are order-insensitive ('a b' is the same as 'b a'), so a valid 'id_token code' request fails validation.  
   *Suggested change:* Add 'id_token code' to the enum (or use pattern '^(code|id_token|code id_token|id_token code)$') and state that the AS compares composite values as unordered sets.  
   *Verifier: confirmed.*

35. **[LOW] Incorrect: The YAML contradicts itself on the PKCE exception** — *found by the verifier*  
   *Reference:* §4.1.3, §7.5.1.1, §4.1.2.1  
   The YAML contradicts itself on the PKCE exception. /authorize and CodeChallenge let a confidential client that uses the OIDC nonce omit code_challenge. But AuthorizationCodeTokenRequest requires code_verifier unconditionally, and -16 §4.1.3 says code_verifier 'MUST NOT be used' when no code_challenge was sent. A client using the exception therefore cannot send a schema-valid token request. The first agent mentioned this only in its notes, not as an item.  
   *Suggested change:* Pick one reading and state it. Either (a) drop the nonce exception from /authorize and CodeChallenge and declare that this profile always requires PKCE, which matches §4.1.3's last bullet, /par 1594 and /token 1244; or (b) keep the exception, make code_verifier conditional ('present iff code_challenge was sent', §4.1.3), and note the draft's internal conflict.

36. **[LOW] Gap: No protection against brute-force attacks on endpoints that accept a client secret** — *found by the verifier*  
   *Reference:* §2.4.1 (also §7.7)  
   No protection against brute-force attacks on endpoints that accept a client secret. The only 429 response is on /par, which comes from RFC 9126.  
   *Suggested change:* Add components.responses.TooManyRequests (429 with a Retry-After header) to every endpoint that accepts client_secret_basic or client_secret_post, with a note citing §2.4.1.

37. **[LOW] Gap: Native apps with a statically embedded secret must be treated as public clients** — *found by the verifier*  
   *Reference:* §8.1, §8.1.1, §2.4  
   Native apps with a statically embedded secret must be treated as public clients. The YAML says nothing about this, and its refresh-token text relaxes protection for 'confidential' clients, so an embedded secret could earn confidential-client treatment.  
   *Suggested change:* Add to ClientAuthFields and clientSecretBasic: 'A secret embedded in a distributed native app does not make the client confidential (OAuth 2.1 §8.1). The AS MUST treat such clients as public: PKCE plus refresh-token rotation or sender-constraint.'

38. **[LOW] Gap: The YAML does not say what happens when scope is omitted, or that scope values are case-sensitive and order-insensitive.** — *found by the verifier*  
   *Reference:* §1.4.1  
   The YAML does not say what happens when scope is omitted, or that scope values are case-sensitive and order-insensitive.  
   *Suggested change:* Add to parameters.Scope: 'Case-sensitive, order-insensitive. If omitted, the AS applies a documented default or fails with invalid_scope (OAuth 2.1 §1.4.1).'

39. **[LOW] Gap: WWW-Authenticate is never marked required on 401 responses, or on the /userinfo 403, although the drafts make it mandatory there.** — *found by the verifier*  
   *Reference:* §5.3.1, §3.2.4 (RFC 9110 §15.5.2)  
   WWW-Authenticate is never marked required on 401 responses, or on the /userinfo 403, although the drafts make it mandatory there.  
   *Suggested change:* Set required: true on WWW-Authenticate in ProtectedResourceError (used for /userinfo 401 and 403) and IntrospectionAuthError. For ClientAuthError, either mark it required (RFC 9110 requires a challenge on every 401) or document when it may be absent.

40. **[LOW] Incorrect: Several problems in ErrorResponse** — *found by the verifier*  
   *Reference:* §6.5, §3.2.4, §4.1.2.1, A.7, A.8, A.9  
   Several problems in ErrorResponse. The error value is a closed enum, which shuts out extension error codes. error_uri is constrained as an absolute URI, error_description may be empty, and an enum comment attributes authorization-endpoint codes to the token-endpoint section.  
   *Suggested change:* Make error open: anyOf [the enum, {type: string, pattern: '^[\x20-\x21\x23-\x5B\x5D-\x7E]+$'}]. Use format: uri-reference for error_uri. Change the error_description quantifier to +. Split the enum comment into §3.2.4 (token endpoint) and §4.1.2.1 (authorization endpoint) groups.

41. **[LOW] Gap: ErrorResponse models state for authorization-endpoint redirect errors but has no iss property, which -16 makes REQUIRED in every authorization error response.** — *found by the verifier*  
   *Reference:* §4.1.2.1  
   ErrorResponse models state for authorization-endpoint redirect errors but has no iss property, which -16 makes REQUIRED in every authorization error response.  
   *Suggested change:* Add iss (string, format uri) to ErrorResponse, described as 'REQUIRED in authorization-endpoint error responses (OAuth 2.1 §4.1.2.1); not used in token-endpoint errors'. Alternatively, drop the redirect-error mention from state.

42. **[LOW] Gap: Nothing says the AS must bind code_challenge and code_challenge_method to the issued code, or must not expose the challenge in an extractable form, for example ** — *found by the verifier*  
   *Reference:* §4.1.2  
   Nothing says the AS must bind code_challenge and code_challenge_method to the issued code, or must not expose the challenge in an extractable form, for example inside a self-contained code.  
   *Suggested change:* Add to the 302 description or to code: 'The AS binds code_challenge and code_challenge_method to the code. If the code is self-contained, they must be encrypted (OAuth 2.1 §4.1.2).'

43. **[LOW] Gap: Endpoint URL rules are missing: no fragment in the authorization or token endpoint URL; an existing query component must be kept when the AS adds parameters; al** — *found by the verifier*  
   *Reference:* §1.5, §2.3, §3.1, §3.2  
   Endpoint URL rules are missing: no fragment in the authorization or token endpoint URL; an existing query component must be kept when the AS adds parameters; all OAuth URLs must use https.  
   *Suggested change:* Add pattern '^https://[^#]*$', or equivalent description text, to authorization_endpoint, token_endpoint and the other endpoint URLs. Note in the /authorize 302 description that response parameters are appended to the redirect URI's existing query component.

44. **[LOW] Gap: Refresh-token request processing rules are undocumented: an omitted scope means the originally granted scope; the AS must check that the grant is still active a** — *found by the verifier*  
   *Reference:* §4.3, §4.3.1, §3.2.3  
   Refresh-token request processing rules are undocumented: an omitted scope means the originally granted scope; the AS must check that the grant is still active and that the token belongs to the client; refresh tokens are bound to the consented scope and resource servers.  
   *Suggested change:* Add these §4.3.1 and §3.2.3 processing rules to the RefreshTokenRequest description and to refresh_token.scope.

45. **[LOW] Incorrect: JWTAccessTokenClaims.sub hardens RFC 9068's SHOULD into 'MUST equal client_id' for client-credentials tokens, without the OAuth 2.1 §7.4 warning about client ID** — *found by the verifier*  
   *Reference:* §7.4  
   JWTAccessTokenClaims.sub hardens RFC 9068's SHOULD into 'MUST equal client_id' for client-credentials tokens, without the OAuth 2.1 §7.4 warning about client IDs colliding with user identifiers. This is mainly an RFC 9068 item that crosses into OAuth 2.1 §7.4.  
   *Suggested change:* Replace with: 'SHOULD identify the client (RFC 9068 §2.2). If client_id is used, prevent client_id values that collide with user subjects, or give resource servers another way to tell client tokens from user tokens (OAuth 2.1 §7.4).'

46. **[LOW] Gap: /userinfo POST accepts the token in either the Authorization header or the access_token body field, but never says the client must not use both in one request.** — *found by the verifier*  
   *Reference:* §5.1, §5.3.2  
   /userinfo POST accepts the token in either the Authorization header or the access_token body field, but never says the client must not use both in one request.  
   *Suggested change:* Add to the /userinfo POST description: 'Send the token in the Authorization header or as access_token, never both. A request using both gets 400 invalid_request (OAuth 2.1 §5.1, §5.3.2).'

47. **[LOW] Gap: Access tokens are opaque to clients, but the YAML points client readers at a decoded JWT shape without saying so.** — *found by the verifier*  
   *Reference:* §1.4  
   Access tokens are opaque to clients, but the YAML points client readers at a decoded JWT shape without saying so.  
   *Suggested change:* Add to TokenResponse.access_token: 'Opaque to clients (OAuth 2.1 §1.4; RFC 9068 §6). The decoded shape is for resource servers only.'

## Verifier corrections to the summaries above

- summary: 'It folds in ... browser-app guidance' overstates -16. §10 does list the browser-apps draft among the consolidated documents, but §9 'Browser-Based Apps' still reads 'TODO: Bring in the normative text of the browser-based apps BCP when it is finalized'. Only the §2.1 client profile and the §3.2 CORS note are present, and the reference is still draft-ietf-oauth-browser-based-apps-27 although that became RFC 10017 in Aug 2026. The assessment's own notes say §9 is a TODO.
- why_created: listing 'RFC 9700 and the browser-apps BCP' among the documents a deployment had to read when OAuth 2.1 was created is anachronistic. OAuth 2.1 began as draft-parecki-oauth-v2-1-00 (7 March 2020) and became draft-ietf-oauth-v2-1-00 (30 July 2020). At that point both were Internet-Drafts: RFC 9700 was published in January 2025, and the browser-apps BCP became RFC 10017 only in August 2026.
- summary: 'authorization code with mandatory PKCE' needs the -16 caveat. §7.5.1.1 and §4.1.2.1 still let the AS accept a confidential client without code_challenge when there is reasonable assurance that it uses the OIDC nonce correctly; PKCE is then only RECOMMENDED.
- prior_validation_followup: the error-code partition (prior MISSING bullet 17) should count as still open, not partially fixed. The enum comment '# RFC 6749 §5.2' (YAML line 1478) labels access_denied, unsupported_response_type, server_error and temporarily_unavailable, all authorization-endpoint codes (§4.1.2.1), as token-endpoint codes, so the §3.2.4 versus §4.1.2.1 split is not represented at all. The MISSING tally becomes 6 fixed, 4 partially fixed, 8 open. The other per-bullet counts (18 MISSING, 12 WRONG; synthesis 14/11) check out.
- notes: RFC 9112 was newly added to the -16 informative references (for §1.7.1), not 'bumped'. The other reference changes listed (rfc7523bis-05 to -11, attestation-based-client-auth-07 to -10, browser-based-apps-26 to -27, client-id-metadata-document-02 added, RFC 8446 to RFC 9846) are correct.
