# JAR, PAR & issuer identification — RFC 9101, 9126, 9207

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 9101](#rfc-9101-the-oauth-20-authorization-framework-jwt-secured-authorization-request-jar) | August 2021 | Proposed Standard | partial | 0 | 5 | 5 |
| [RFC 9126](#rfc-9126-oauth-20-pushed-authorization-requests) | September 2021 | Proposed Standard | mostly | 1 | 7 | 12 |
| [RFC 9207](#rfc-9207-oauth-20-authorization-server-issuer-identification) | March 2022 | Proposed Standard | mostly | 0 | 2 | 4 |

**Cluster notes.** Cluster jar-par-iss covers RFC 9101 (JAR), RFC 9126 (PAR) and RFC 9207 (iss). All three are Proposed Standards and all are vendored in references/rfc-sources, byte-identical to rfc-editor.org. As of 2026-10-10 the RFC index shows none of them obsoleted or updated. Errata: RFC 9101 and RFC 9207 have none. RFC 9126 has three reported, unverified errata: 6711 (technical: client_id must accompany 'request' in a pushed request), 7254 (a stray '&' in the §1.1 example) and 7410 (the §1.1 example uses 'urn:example:'). Two pending changes matter: (a) draft-ietf-oauth-rfc7523bis-11, now in the RFC Editor queue, formally updates RFC 9126 §2 so that the issuer identifier is the only accepted client-assertion audience; (b) draft-ietf-oauth-v2-1-16 (2026-09-03) changed the 'iss' authorization-response parameter from OPTIONAL (-15) to REQUIRED in both §4.1.2 and §4.1.2.1. The YAML still reflects -15. Highest-impact findings: (1) PARRequest requires response_type, code_challenge and code_challenge_method at the top level, so RFC 9126 §3 JAR-in-PAR requests fail. This was confirmed with a schema-validation script and by the FastAPI server generated from the identical YAML (`src/openapi_server/apis/par_api.py`, lines 55-58). (2) 'iss' is still optional, but OAuth 2.1 -16 requires it. (3) The RequestUri text 'takes precedence' and the /authorize text 'only client_id plus one parameter' contradict two rules: JAR's 'use only the Request Object parameters' (RFC 9101 §5, §6.3) and OIDC Core §6.1's duplication rules. (4) The request_uri_parameter_supported description contradicts RFC 9126 §5; together with its default of true, the AS over-advertises client-hosted request_uri support it does not have. (5) There is no client-metadata schema, so the per-client require_signed_request_object and require_pushed_authorization_requests are missing, as are request_object_signing_alg/encryption_alg/encryption_enc and request_uris. (6) There is no Request Object claims schema and no 'oauth-authz-req+jwt' typing or media type. The IANA-absent list has no entries attributed to these three RFCs, but that is only because its token match finds the same names used for AS metadata and for other JWT claims; it hides item (5) and the RFC 9101 §9.1 registrations of iss/sub/aud/exp/nbf/iat/jti as authorization-request parameters. The orchestrator's list of intentional exclusions does not include client-hosted request_uri, but the YAML documents that it chose not to model it (RequestUri lines 864-865). It is reported as a low-severity gap with that context.

## RFC 9101 The OAuth 2.0 Authorization Framework: JWT-Secured Authorization Request (JAR)

*August 2021 · Proposed Standard · YAML coverage: **partial** · relevance to an AS: optional · vendoring: already-vendored*

**What it is.** JAR lets a client put every authorization-request parameter into a JWT called a Request Object. The client signs it with its own key, may also encrypt it to the AS, and sends it to /authorize by value in the 'request' parameter or by reference in 'request_uri', always together with 'client_id'. The AS must check the signature against a key that belongs to the client, confirm that the outer and inner client_id are equal, and then use only the parameters inside the Request Object. The RFC also defines the 'require_signed_request_object' AS and client metadata and the 'application/oauth-authz-req+jwt' media type (also the recommended JOSE 'typ'), and it reuses OpenID Connect's four request-object error codes.

**Why it was created.** In RFC 6749 the authorization request is a set of plain query parameters carried by the browser. That has three weaknesses: (a) values such as redirect_uri or scope can be changed in transit (no integrity protection); (b) the AS cannot tell whether the client really sent the request (no source authentication); (c) the parameters leak through browser history, logs and referrers (no confidentiality). Attacks such as redirect-URI rewriting followed. JAR takes OpenID Connect's Request Object and generalizes it to plain OAuth. A JWS signature adds integrity and source authentication, JWE adds confidentiality, and passing by reference copes with requests too large for a URL.

<details><summary>Already modeled in the YAML (11)</summary>

- 'request' authorization-request parameter: components.parameters.Request (lines 950-960), referenced from paths./authorize.get (line 156); the schema text says 'A signed (and optionally encrypted) JWT' (line 960), which matches §5 (a)/(b)
- 'request' in the pushed body: components.schemas.PARRequest.properties.request (lines 1642-1644)
- 'request_uri' authorization-request parameter, PAR-issued form only (a documented choice, lines 864-865): components.parameters.RequestUri (lines 857-868), referenced from /authorize (line 146)
- client_id REQUIRED alongside request/request_uri (§5): components.parameters.ClientId, required: true (lines 708-714)
- 'request' and 'request_uri' are mutually exclusive (§5): prose in components.parameters.Request (lines 956-957)
- Error codes invalid_request_uri, invalid_request_object, request_not_supported, request_uri_not_supported (§7): components.schemas.ErrorResponse.properties.error enum (lines 1500-1504)
- AS metadata require_signed_request_object, boolean, default false (§9.2, §10.5): OAuthServerMetadata (lines 2170-2173)
- AS metadata request_object_signing_alg_values_supported, request_object_encryption_alg_values_supported and request_object_encryption_enc_values_supported (named in §4): OAuthServerMetadata (lines 2104-2113)
- OIDC Discovery flags that gate JAR: request_parameter_supported (default false), request_uri_parameter_supported (default true) and require_request_uri_registration (default false): OAuthServerMetadata (lines 2153-2165)
- With JAR or PAR, the parameters come from the Request Object: prose in paths./authorize.get.description (lines 125-128), components.parameters.ResponseType (lines 698-700) and components.parameters.CodeChallenge (lines 772-773)
- Entry in the covered-specifications table: info.description (line 34)

</details>

**Follow-up on the May-2026 validation notes.** references/rfc-validation has no note for RFC 9101. Related items elsewhere are all fixed: the audit synthesis asked for the 'request' parameter at /authorize (done, lines 950-960 and 156), for request_not_supported and request_uri_not_supported (done, lines 1503-1504) and for require_signed_request_object (done, lines 2170-2173, per the 2026-06-07 update log). The oidc-core-1.0.md finding 'spec only models request_uri, not request' is fixed. The 9700-security-bcp.md request to add request_object_signing_alg_values_supported is fixed (lines 2105-2107). The 'RFC 9101 JAR endpoint surface' remains deliberately skipped.

**Notes.** JAR is optional for an OAuth 2.1 AS: request_parameter_supported correctly defaults to false (line 2157). OIDC Core §6 and JAR differ in three ways: OIDC allows unsigned or encrypt-only Request Objects (JAR does not), OIDC merges query parameters with the Request Object (JAR ignores the query), and OIDC requires response_type and scope to be duplicated in the query. The YAML should say plainly that it follows JAR semantics; see the two medium-severity incorrect items. The four JAR error codes are in the IANA OAuth Extensions Error registry with OIDC Core as the reference.

### Findings (0 high · 5 medium · 5 low)

1. **[MEDIUM] Gap: Request Object claim set (all parameters as claims, plus iss, aud, client_id, exp/nbf/iat/jti, sub)**  
   *Reference:* RFC 9101 §4, §5, §6.3, §9.1, §10.8  
   No schema describes the decoded Request Object, so the YAML never states these rules: the JWT MUST hold every authorization parameter, extensions included, as claims, with strings as JSON strings and numbers as JSON numbers (§4); a signed Request Object SHOULD carry 'iss' and 'aud', with aud equal to the AS issuer (§4); the 'client_id' claim MUST equal the client_id request parameter (§5, §6.3); 'request' and 'request_uri' MUST NOT appear inside the Request Object (§4); iss/sub/aud/exp/nbf/iat/jti are reserved as authorization-request parameters (§9.1); 'sub' should never be the client ID, to avoid cross-JWT confusion with RFC 7523 client assertions (§10.8). The YAML already uses documentation-only decoded-payload schemas for the same pattern: IDTokenClaims (line 2461), JWTAccessTokenClaims (line 2514) and JWTIntrospectionResponse (line 1763).  
   *Suggested change:* Add components.schemas.RequestObjectClaims, documentation-only and unwired like IDTokenClaims: type: object; additionalProperties: true; required: [client_id]. Properties: iss ($ref StringOrURI; 'SHOULD be present when signed; normally the client_id'); aud (StringOrURI or array; 'SHOULD be the AS issuer identifier, RFC 9101 §4'); client_id ('MUST equal the client_id request parameter, §6.3'); exp/nbf/iat ($ref NumericDate); jti; sub ('never the client ID, §10.8'); plus the authorization parameters (response_type, redirect_uri, scope, state, code_challenge, code_challenge_method, nonce, max_age as integer, authorization_details as array, resource, dpop_jkt) and, optionally, the §10.3 explicit-endpoint claims. Add not: {anyOf: [{required: [request]}, {required: [request_uri]}]}. Point to the schema from the descriptions of components.parameters.Request and PARRequest.properties.request.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Client metadata require_signed_request_object, request_object_signing_alg, request_object_encryption_alg, request_object_encryption_enc (and request_uris)**  
   *Reference:* RFC 9101 §4, §9.3, §10.5; OIDC Dynamic Client Registration 1.0 §2  
   The YAML has no client-metadata (RFC 7591) schema, so per-client JAR policy cannot be expressed. §10.5 says that when a client's require_signed_request_object is true, the server MUST reject that client's non-JAR requests. §4 names request_object_signing_alg, request_object_encryption_alg and request_object_encryption_enc as the client-side counterparts of the modeled *_values_supported arrays. The IANA diff counts require_signed_request_object as present only because the AS-metadata field has the same name. request_object_signing_alg, request_object_encryption_alg, request_object_encryption_enc and request_uris do appear in the IANA absence list under client-metadata.  
   *Suggested change:* When a ClientMetadata schema is added (DCR cluster), include: require_signed_request_object {type: boolean, default: false, description: 'RFC 9101 §10.5 - when true the AS MUST reject this client's authorization requests that are not Request Objects, and any Request Object with alg none'}; request_object_signing_alg {type: string, not: {const: none}}; request_object_encryption_alg and request_object_encryption_enc (strings, OIDC Registration §2); request_uris (array of https URIs), but only if client-hosted request_uri is ever supported.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: AS validation rules for Request Objects**  
   *Reference:* RFC 9101 §5, §6.1, §6.2, §6.3, §10.7  
   The YAML never tells an implementer the following MUSTs: decrypt a JWE Request Object and return invalid_request_object if decryption fails (§6.1); verify the JWS with a key associated with the client (a present 'kid' MUST name a client key), apply the RFC 8725 §3.1/§3.2 algorithm checks, and return invalid_request_object otherwise (§6.2); require the client_id parameter and the Request Object client_id claim to be identical (§6.3); use only the Request Object's parameters and ignore duplicates in the query (§5, §6.3, §10.7). The error codes exist in the enum (lines 1500-1504), but nothing links them to these conditions.  
   *Suggested change:* Add a numbered 'AS processing' list to the description of components.parameters.Request: (1) if the object is a JWE, decrypt it; on failure return invalid_request_object (§6.1). (2) Verify the JWS with a client key; a kid, if present, MUST name a client key, and alg must be an allowed value other than none; on failure return invalid_request_object (§6.2). (3) The client_id query parameter MUST equal the client_id claim (§6.3). (4) Use only the Request Object's parameters; duplicates in the query are ignored (§5). (5) Return request_not_supported or request_uri_not_supported when the mechanism is unsupported (§7).  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: Signing-algorithm policy for Request Objects (alg none)**  
   *Reference:* RFC 9101 §5, §10.1, §10.5; RFC 8725 §3.2  
   request_object_signing_alg_values_supported and its encryption siblings (lines 2105-2113) have no descriptions or constraints. The require_signed_request_object description (line 2172) does not say that, when it is true, the AS MUST also reject Request Objects that use alg none (§10.5). OIDC Discovery §3 still says servers SHOULD support 'none' and RS256 for these arrays, which conflicts with JAR's rule that a Request Object be JWS-signed (§5 (a)/(b), §10.1). A server generated from the YAML gets no guidance either way.  
   *Suggested change:* request_object_signing_alg_values_supported: add the description 'JWS algs accepted for Request Objects (RFC 9101 §4). Do not advertise none for JAR (RFC 9101 §10.1, RFC 8725 §3.2); OIDC Discovery's SHOULD support none does not apply to an OAuth 2.1 AS', with items: {type: string, not: {const: none}} and examples: [[PS256, ES256]]. require_signed_request_object: append 'When true, the AS MUST reject requests that are not Request Objects and any Request Object that uses alg none (RFC 9101 §10.5). At /par it MUST answer 400 invalid_request (RFC 9126 §2.3).'  
   *Verifier: confirmed.*

5. **[MEDIUM] Incorrect: lines 861-863 components.parameters.RequestUri.description**  
   *Reference:* RFC 9101 §5, §6.3, §10.7; RFC 9126 §4  
   'When present, takes precedence over individual query parameters' describes OIDC-style merging, where query values are used for anything the Request Object lacks. JAR, which RFC 9126 §4 applies to PAR request_uris, says the AS MUST use only the parameters in the Request Object, even when the same parameter is also in the query (§5, §6.3). §10.7 explains why: merging enables parameter-mismatch attacks, for example a man-in-the-browser adding a prompt or scope value to the query that was never pushed.  
   *Suggested change:* Replace with: 'When present, the authorization request consists solely of the pushed or referenced parameters. All other query parameters except client_id are ignored (RFC 9101 §5, §6.3), and client_id MUST match the client that pushed the request.'  
   *Verifier: confirmed.*

6. **[LOW] Gap: Explicit typing and media type 'oauth-authz-req+jwt'**  
   *Reference:* RFC 9101 §4, §9.4.1, §10.4.1, §10.8 (RFC 8725 §3.11)  
   The string 'oauth-authz-req' appears nowhere in the YAML. §10.8 recommends typing Request Objects with the JOSE header 'typ: oauth-authz-req+jwt' and calls requiring it 'a good idea for new OAuth deployment profiles', which describes this project. §4 and §9.4.1 register 'application/oauth-authz-req+jwt', and §10.4.1/§10.4.2 tell the AS to check that media type when it fetches a request_uri. The YAML does document typ for other JWT kinds: at+jwt (line 2517), dpop+jwt (line 980) and token-introspection+jwt (line 352). Neither Request field reuses the JWT compact-serialization schema (lines 2434-2441).  
   *Suggested change:* In components.parameters.Request (lines 950-960) and PARRequest.properties.request (lines 1642-1644), use $ref: '#/components/schemas/JWT' and add this text: 'JOSE header typ SHOULD be oauth-authz-req+jwt (RFC 9101 §10.8). A new deployment profile MAY require it and reject untyped or differently typed JWTs (RFC 8725 §3.11). Media type: application/oauth-authz-req+jwt (§9.4.1); application/jwt is a legacy alternative (§4).'  
   *Verifier: partially correct —* The YAML never mentions the oauth-authz-req+jwt typ or media type. RFC 9101 treats explicit typing as optional hardening (recommended only as a profile choice for new deployments), so this is a low-severity gap. Document typ as optional, or as this AS's own profile requirement, without claiming the RFC says SHOULD. Do not $ref the shared JWT schema until its pattern allows an empty second segment (e.g. '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+(\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+)?$'). Otherwise Request Objects encrypted with ECDH-ES or dir are rejected.

7. **[LOW] Gap: Client-hosted Request Object URI (JAR by reference)**  
   *Reference:* RFC 9101 §5.2, §5.2.1, §5.2.3, §10.4.1, §10.4.2  
   RequestUri (lines 857-868) deliberately models only PAR-issued values (lines 864-865), so the AS-side fetch is undocumented. Per the RFC, the AS MUST GET the https request_uri (§5.2.3). It should also check that the response media type is application/oauth-authz-req+jwt, set timeouts, refuse unexpected locations and never fetch recursively (§10.4.1, §10.4.2). Such URIs SHOULD NOT exceed 512 ASCII characters (§5.2). This is a documented scope decision (README roadmap: 'Add JAR (RFC 9101) request-object handling beyond what PAR already references'; audit synthesis: 'RFC 9101 JAR endpoint surface' skipped). However, the request_uri_parameter_supported default then over-advertises; see the RFC 9126 incorrect item.  
   *Suggested change:* Option (a), keep the exclusion and say so in RequestUri: 'This AS accepts only request_uri values it issued itself (PAR). Client-hosted https Request Object URIs are answered with request_uri_not_supported (RFC 9101 §7), and request_uri_parameter_supported is published as false.' Option (b), model it: schema {type: string, format: uri, maxLength: 512, pattern: '^(https://|urn:)'}, with a description of the §5.2.3 GET fetch and the §10.4 safeguards.  
   *Verifier: confirmed.*

8. **[LOW] Gap: Format of request_uri values the AS issues itself**  
   *Reference:* RFC 9101 §5.2, §10.2(d), §11.2.1  
   When the AS issues the request_uri itself (as with PAR), RFC 9101 §5.2 says it MUST be a URN (RFC 8141). §10.2(d) adds: short lifetime (guidance: under a minute), preferably one-time use, and at least 128 bits of randomness. RFC 9126 §7.1 makes these entropy considerations a MUST. PARResponse.request_uri (lines 1656-1667) is typed only as format: uri and says the format is 'at the AS's discretion'. That wording is true for RFC 9126 §2.2, but it omits JAR's URN requirement and the entropy and lifetime guidance.  
   *Suggested change:* PARResponse.request_uri: add pattern: '^urn:' and extend the description: 'MUST be a URN when issued by the AS (RFC 9101 §5.2); random part of at least 128 bits and a short lifetime (RFC 9101 §10.2(d), RFC 9126 §7.1).'  
   *Verifier: confirmed.*

9. **[LOW] Incorrect: lines 125-128 paths./authorize.get.description; lines 698-700 components.parameters.ResponseType.description; lines 435-437 paths./par.post.description**  
   *Reference:* RFC 9101 §5; RFC 9126 §4; OIDC Core 1.0 §6.1  
   The text says that with PAR ('request_uri') or JAR ('request') 'only client_id plus that one parameter appear in the query string', and that response_type is 'omitted'. RFC 9101 §5 explicitly allows the client to repeat Request Object parameters in the query ('MAY ... for backward compatibility'); the AS must then ignore them. OpenID Connect Core §6.1, which this YAML also covers, goes further: response_type and client_id, plus a scope containing openid, MUST appear as ordinary query parameters even when a Request Object is used. An AS that implements the YAML's wording could reject conformant OIDC JAR requests.  
   *Suggested change:* Reword: 'With PAR or JAR the client normally sends only client_id plus request_uri or request. It MAY repeat other parameters, and OIDC Core §6.1 requires response_type and scope=openid to be repeated, but the AS MUST use only the values inside the Request Object or pushed request (RFC 9101 §5, §6.3).' In ResponseType, replace 'omitted' with 'taken from the Request Object; a query copy is ignored (for OIDC it MUST be present and match).'  
   *Verifier: partially correct —* The wording wrongly implies that clients send only client_id plus request or request_uri. JAR lets clients duplicate parameters (MAY), and OIDC Core §6.1/§6.2 requires response_type, client_id and scope=openid in the query. The AS-side rule the text states is JAR-conformant. Low severity: a documentation inaccuracy that can mislead client authors and over-strict AS implementers, not a schema defect.

10. **[LOW] Incorrect: line 1500 components.schemas.ErrorResponse.properties.error (enum comment)**  
   *Reference:* RFC 9101 §7; RFC 9126 §2.3  
   The comment '# RFC 9126 (PAR §2.3) and RFC 9101 (JAR)' credits RFC 9126 §2.3 with invalid_request_uri, invalid_request_object, request_not_supported and request_uri_not_supported. §2.3 defines none of them. They come from RFC 9101 §7, which inherited them from OIDC Core §3.1.2.6; the IANA registry cites OIDC Core, with usage location 'authorization endpoint'.  
   *Suggested change:* Change the comment to '# RFC 9101 §7 / OIDC Core §3.1.2.6 - authorization endpoint (also usable at /par per RFC 9126 §2.3)'.  
   *Verifier: confirmed.*

## RFC 9126 OAuth 2.0 Pushed Authorization Requests

*September 2021 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** PAR adds a back-channel endpoint. The client POSTs the whole authorization request there as a form, authenticating exactly as it would at the token endpoint. The AS answers 201 Created with a short-lived, single-use 'request_uri' (typically urn:ietf:params:oauth:request_uri:...) and 'expires_in'. The browser then carries only client_id and request_uri to /authorize. The pushed body may itself be a JAR Request Object ('request'). The RFC defines the AS metadata pushed_authorization_request_endpoint and require_pushed_authorization_requests, plus a client-metadata field of the same name, so an AS can require PAR globally or per client.

**Why it was created.** Front-channel authorization requests have no integrity or confidentiality protection. They leak through browser history, logs and referrers, and they can exceed URL size limits once JAR or RAR payloads are added. Mobile apps cannot easily POST to the authorization endpoint. The AS also only learns who the client is at the token endpoint, after the user has already interacted. PAR grew out of the OpenID FAPI working group's 'Pushed Request Object'. It moves the request into an authenticated, TLS-protected POST, so the AS can authenticate the client and reject bad or forged requests before any user interaction, and the browser carries only an opaque, short-lived reference.

<details><summary>Already modeled in the YAML (16)</summary>

- POST /par endpoint with an application/x-www-form-urlencoded body: paths./par.post (lines 422-448); tag PAR (lines 95-96)
- Request schema with the authorization-request parameters plus client-authentication fields (allOf ClientAuthFields and ResourceIndicators): components.schemas.PARRequest (lines 1583-1647)
- client_id required in the pushed body (§2.1): PARRequest required list (line 1594)
- 'request_uri MUST NOT be sent to /par' (§2.1): prose only (lines 434, 1586-1588)
- Client authentication 'same as the token endpoint' (§2): security [clientSecretBasic, mtls, {}] (lines 473-476) plus ClientAuthFields (lines 1175-1200)
- 201 Created with application/json PARResponse {request_uri, expires_in}, both required (§2.2): lines 450-462; components.schemas.PARResponse (lines 1649-1675)
- request_uri CSPRNG requirement and the urn:ietf:params:oauth:request_uri: form (§2.2, §9.3): PARResponse.request_uri description and example (lines 1656-1667)
- expires_in as a positive integer, typically 5-600 s (§2.2): PARResponse.expires_in, minimum: 1, example 60 (lines 1668-1675)
- Cache-Control no-store and Pragma no-cache on the 201: lines 453-456 (components.headers.CacheControlNoStore, lines 990-994)
- Error responses (§2.3): 400 OAuthErrorWithDPoPNonce (lines 463-464, 1074-1090); 401 ClientAuthError with a WWW-Authenticate Basic challenge (lines 465-466, 1108-1125); 405, 413 and 429 (lines 467-472)
- Use of request_uri at /authorize with only client_id plus request_uri (§4): components.parameters.RequestUri (lines 857-868); /authorize description (lines 125-128); /par description (lines 435-437)
- JAR Request Object inside PAR (§3): PARRequest.properties.request (lines 1642-1644)
- AS metadata pushed_authorization_request_endpoint (§5): OAuthServerMetadata (lines 1981-1984), plus mtls_endpoint_aliases.pushed_authorization_request_endpoint (line 2008)
- AS metadata require_pushed_authorization_requests, default false (§5): OAuthServerMetadata (lines 2166-2169)
- DPoP with PAR (RFC 9449 §10.1): DPoP header parameter on /par (lines 441-442); DPoP-Nonce on the 201 (lines 457-458) and on the 400 (via OAuthErrorWithDPoPNonce); dpop_jkt in PARRequest (lines 1645-1647)
- invalid_request_uri for a bad or expired request_uri at /authorize: ErrorResponse enum (line 1501)

</details>

**Follow-up on the May-2026 validation notes.** The prior note, 9126-par.md (2026-05-10), has 12 MISSING, 5 WRONG and 8 NICE-TO-HAVE items. MISSING: 8 fixed. These are invalid_request_uri and invalid_request_object in the enum (lines 1501-1502); the 'only client_id and request_uri' note (lines 125-128, 435-437); the CSPRNG note (lines 1661-1664); expires_in minimum and range (lines 1668-1675); Cache-Control and Pragma on the 201 (lines 453-456); the public-client {} security option (line 476); and 405/413/429 (lines 467-472). One is partial: the request_uri prohibition is now in prose but not enforced. Three are open: single-use and expiry on RequestUri; binding to the client on PARResponse.request_uri; and the request_uri_parameter_supported/require_request_uri_registration note. Those two fields are now modeled (lines 2158-2165), but line 2160 states the opposite of RFC 9126 §5. WRONG: 3 fixed. code_challenge and its method are now required (line 1594), but that fix broke JAR-in-PAR (see the high-severity item); the URN note is in (lines 1663-1667); the 401 now uses ClientAuthError with WWW-Authenticate (line 466). One finding was invalid as written: 'format: uri' already requires an absolute URI under JSON Schema 2020-12 §7.3.5, so only the no-fragment rule is missing. One needed no change (the tag name). NICE-TO-HAVE: none fully done. Two are partial: field-level examples only, and PARRequest.request cites §5 rather than §4. Six are open: Content-Type prose on the 201, a PARRequest example, §2.4 redirect relaxation, the client metadata require_pushed_authorization_requests, client-assertion aud guidance (now overtaken by draft-ietf-oauth-rfc7523bis-11 §5) and the §7.5 swapping note. The prior note also contains errors and stale references. invalid_request_uri is not defined in RFC 6749 §4.1.2.1. /authorize CodeChallenge is not required: true. It refers to the removed DiscoveryDocument schema and to the removed clientSecretPost, clientAssertion and 'none' security options.

**Notes.** Evidence for the high-severity item is the FastAPI server generated from a YAML identical to the snapshot (diff confirmed): lines 55-58 of the generated `src/openapi_server/apis/par_api.py`. Its code_challenge_method gets the default 'S256', so it is not actually enforced there. One thing the YAML gets right: DPoP appears on /par as a header parameter, not as the 'dpop' security scheme. The 9449-dpop.md M8 suggestion to add 'dpop: []' to /par would be wrong, because /par receives a DPoP proof, not a DPoP-bound access token. The RFC 9126 errata are all 'Reported' (unverified): 6711 (technical, client_id with 'request'), 7254 (a stray '&' in the §1.1 example) and 7410 (the §1.1 example uses 'urn:example:').

### Findings (1 high · 7 medium · 12 low)

1. **[HIGH] Incorrect: lines 1583-1647 components.schemas.PARRequest (required list at line 1594)**  
   *Reference:* RFC 9126 §3 (and reported erratum 6711), §2.1  
   PARRequest always requires response_type, code_challenge and code_challenge_method at the top level of the form body. RFC 9126 §3 says that when the client pushes a JAR Request Object, the form body holds only 'request', 'client_id' (per reported erratum 6711) and the client-authentication parameters; every authorization parameter MUST be a claim inside the JWT. The RFC's own §3 example body (client_assertion_type, client_assertion, request, client_id) therefore fails validation for missing code_challenge, code_challenge_method and response_type; a schema-validation script confirms this. The FastAPI server generated from this YAML declares response_type and code_challenge as required Form(...) fields (par_api.py lines 56-57), so it rejects conformant PAR+JAR requests with 422 and pushes clients to break §3 by sending the parameters outside the JWT. The description's claim of 'parity with /authorize' is also inaccurate: at /authorize, CodeChallenge is required: false (line 763), following the exception in OAuth 2.1 -16 §4.1.1 and §7.5.1.  
   *Suggested change:* Keep required: [client_id] unconditionally. Move the remaining requirements into a JSON Schema 2020-12 conditional, which OAS 3.1 supports: if: {required: [request]}, then: {properties: {response_type: false, redirect_uri: false, scope: false, state: false, code_challenge: false, code_challenge_method: false, nonce: false, dpop_jkt: false, authorization_details: false, resource: false}}, else: {required: [response_type, code_challenge, code_challenge_method]}. Document that with 'request', PKCE and the other parameters are checked inside the Request Object. Alternatively, split the schema into oneOf: PARPlainRequest | PARRequestObjectRequest.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Prohibition of request_uri in the PAR body**  
   *Reference:* RFC 9126 §2.1 (paragraph 1 and processing step 2)  
   The rule exists only in prose (lines 434, 1586-1588). The schema neither declares nor forbids request_uri, so a body containing it validates; a schema-validation script confirms this. The FastAPI server generated from this YAML (par_api.py) silently drops the unknown field, when §2.1 step 2 says the request MUST be rejected.  
   *Suggested change:* In PARRequest's inline object add properties: {request_uri: false} (a JSON Schema 2020-12 boolean schema meaning the property must be absent), or not: {required: [request_uri]}. In the /par 400 description add: 'invalid_request when the body contains request_uri (RFC 9126 §2.1 step 2)'.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: Client metadata require_pushed_authorization_requests**  
   *Reference:* RFC 9126 §6, §9.2 (and §4, per-client policy)  
   Only the AS-metadata field of the same name exists (lines 2166-2169). The per-client flag that forces PAR for one client has nowhere to go, because the YAML has no RFC 7591 client-metadata schema. The IANA diff counts it as present only because the AS field shares the name.  
   *Suggested change:* Add to a ClientMetadata schema: require_pushed_authorization_requests {type: boolean, default: false, description: 'RFC 9126 §6 - when true, PAR is the only way this client may start an authorization request; other /authorize requests are refused with invalid_request (§4)'}.  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: Audience of client-authentication JWTs sent to /par**  
   *Reference:* RFC 9126 §2 (last paragraph); draft-ietf-oauth-rfc7523bis-11 §5  
   RFC 9126 §2 says the issuer identifier SHOULD be the aud of a private_key_jwt or client_secret_jwt assertion, and that the AS MUST accept its issuer identifier, its token endpoint URL or its PAR endpoint URL. The YAML is silent: ClientAuthFields.client_assertion (lines 1191-1196) gives no aud guidance. draft-ietf-oauth-rfc7523bis-11 is in the RFC Editor queue and states 'Updates: 7521, 7522, 7523, 9126'. It replaces that paragraph: the issuer identifier MUST be the only audience, and the AS MUST reject any other value. This is the fix for audience injection; draft-ietf-oauth-security-topics-update-03 §2.1.1.3 lists the PAR endpoint as one of the attack surfaces.  
   *Suggested change:* Add to ClientAuthFields.client_assertion and to the /par description: 'aud = the AS issuer identifier. As published, RFC 9126 §2 also requires the AS to accept the token or PAR endpoint URL. draft-ietf-oauth-rfc7523bis-11 §5 tightens this to the issuer as the only aud accepted, which is recommended for new servers (optional typ: client-authentication+jwt).'  
   *Verifier: confirmed.*

5. **[MEDIUM] Gap: Rules for DPoP binding at the PAR endpoint**  
   *Reference:* RFC 9449 §10.1 (with RFC 9126 §2.1)  
   The YAML wires the pieces (DPoP header lines 441-442, DPoP-Nonce lines 457-458 and 464, PARRequest.dpop_jkt lines 1645-1647) but states none of the rules. An AS that supports both PAR and DPoP MUST accept both dpop_jkt in the body and a DPoP header. A valid DPoP proof at /par MUST be treated as if its key thumbprint had been sent as dpop_jkt, so the later token request must use the same key. If both are present and the thumbprints differ, the AS MUST reject the request.  
   *Suggested change:* Append to the /par description: 'DPoP (RFC 9449 §10.1): bind the code to a DPoP key either with dpop_jkt in the body or with a DPoP proof header (htm=POST, htu=the PAR endpoint URL). The AS MUST support both. A proof here binds the code exactly like dpop_jkt. If both are sent and the JWK SHA-256 thumbprints differ, the AS MUST reject the request (400).' Add a one-line note to PARRequest.properties.dpop_jkt.  
   *Verifier: confirmed.*

6. **[MEDIUM] Gap: Processing a pushed Request Object and the signed-request policy**  
   *Reference:* RFC 9126 §3 (steps 1-3), §2.3 (paragraph 2)  
   For a pushed Request Object the AS MUST decrypt it if needed and validate its signature (RFC 9101 §6.1, §6.2). It MUST reject the request if the authenticated client_id differs from the Request Object's client_id claim; whether iss must also equal client_id is the AS's choice. When AS or client policy requires signed Request Objects, the AS MUST refuse every PAR request that does not use 'request', with HTTP 400 invalid_request. None of this appears in the /par or PARRequest descriptions; PARRequest.request (line 1644) says only 'Optional signed JWT request object'.  
   *Suggested change:* Add §3 steps 1-3 to the PARRequest.properties.request description. Add to the /par 400 description: 'When require_signed_request_object is true (for the AS or the client), requests without request are refused with 400 invalid_request (RFC 9126 §2.3). An invalid Request Object yields invalid_request_object.'  
   *Verifier: confirmed.*

7. **[MEDIUM] Gap: request_uri lifecycle: single use, expiry, binding to the client**  
   *Reference:* RFC 9126 §2.2, §4, §7.1, §7.3  
   PARResponse.request_uri (lines 1656-1665) does not say the value is a single-use reference that MUST be bound to the client that pushed it (§2.2). RequestUri (lines 857-868) does not say that the client MUST use the value only once, that the AS SHOULD treat it as one-time (MAY tolerate a page reload), or that an expired value MUST be rejected, normally with invalid_request_uri (RFC 9101 §7). This has been open since the May-2026 audit.  
   *Suggested change:* PARResponse.request_uri: add 'single-use reference; MUST be bound to the client that pushed it (§2.2)'. RequestUri: add 'For PAR-issued values the client MUST use the value once. The AS SHOULD enforce one-time use and MUST reject expired or unknown values, and values pushed by a different client, with invalid_request_uri (§4, §7.3).'  
   *Verifier: confirmed.*

8. **[MEDIUM] Incorrect: lines 2158-2161 components.schemas.OAuthServerMetadata.properties.request_uri_parameter_supported (and lines 2162-2165 require_request_uri_registration)**  
   *Reference:* RFC 9126 §5 (last paragraph); RFC 9101 §5.2; OIDC Discovery 1.0 §3  
   The description says the flag covers the request_uri parameter of 'OIDC Core §6, RFC 9126 PAR'. RFC 9126 §5 says the opposite: a request_uri obtained from the PAR endpoint works regardless of request_uri_parameter_supported or require_request_uri_registration, and those OIDC Discovery flags govern only client-hosted Request Object URIs. The OIDC Discovery default is true (correctly reproduced at line 2161), and the YAML deliberately supports only PAR-issued URIs (lines 864-865). So an AS that follows the YAML and omits the field advertises by-reference JAR support it does not implement.  
   *Suggested change:* request_uri_parameter_supported: 'Whether the AS accepts client-hosted Request Object URIs that it must fetch (RFC 9101 §5.2; OIDC Discovery §3). Defaults to true when omitted. Independent of PAR: PAR-issued request_uri values always work (RFC 9126 §5). An AS that accepts only PAR-issued URIs should publish false.' require_request_uri_registration: add 'pre-registration through the request_uris client metadata; never applies to PAR-issued URIs (RFC 9126 §5).'  
   *Verifier: confirmed.*

9. **[LOW] Gap: Refusing non-PAR requests; endpoint metadata notes**  
   *Reference:* RFC 9126 §2, §4, §5  
   The require_pushed_authorization_requests description (line 2168) says /authorize must be reached via PAR but not how refusals look: §4 specifies error invalid_request. The pushed_authorization_request_endpoint entry (lines 1981-1984) does not say that the endpoint URL MUST be https (§2), or that the field's presence alone tells clients they may use PAR (§5).  
   *Suggested change:* require_pushed_authorization_requests: append 'Non-PAR authorization requests are refused with invalid_request (§4).' pushed_authorization_request_endpoint: add pattern: '^https://' and the sentence 'Its presence alone signals PAR support (§5).'  
   *Verifier: confirmed.*

10. **[LOW] Gap: Redirect-URI handling for pushed requests**  
   *Reference:* RFC 9126 §2.4, §7.2  
   PARRequest.redirect_uri (lines 1600-1602) has no description. §2.4 lets the AS accept unregistered, per-request redirect URIs from authenticated clients, which relaxes the exact-match rule stated in RedirectUri (lines 720-727). §7.2 says the AS MUST accept new redirect URIs only from authenticated clients.  
   *Suggested change:* Add the description: 'Exact match against registered URIs by default (OAuth 2.1 §2.3.1). The AS MAY accept an unregistered per-request redirect_uri, but only from an authenticated client (RFC 9126 §2.4); it MUST NOT accept new redirect URIs from public clients (§7.2).'  
   *Verifier: confirmed.*

11. **[LOW] Gap: Which error codes /par returns**  
   *Reference:* RFC 9126 §2.3 (paragraph 1)  
   The /par 400 reuses the generic OAuthErrorWithDPoPNonce and never says the following: PAR errors use the token-endpoint JSON format, with codes from RFC 6749 §5.2 or §4.1.2.1 or from extensions; redirect-URI problems use invalid_request; and the user-interaction codes in the shared enum (interaction_required, login_required, account_selection_required, consent_required at lines 1513-1516) are never returned by /par.  
   *Suggested change:* Give the /par 400 its own description: 'RFC 9126 §2.3 - JSON error per RFC 6749 §5.2. invalid_request for redirect_uri problems and for a forbidden request_uri. Extension codes where applicable: invalid_request_object, invalid_authorization_details, invalid_target, invalid_dpop_proof, use_dpop_nonce. Interaction codes are never returned.' Add one example.  
   *Verifier: confirmed.*

12. **[LOW] Gap: Details of the 405 response**  
   *Reference:* RFC 9126 §2.3; RFC 9110 §15.5.6  
   The 405 (lines 467-468) is attached to the POST operation, but 405 is returned only for non-POST methods, so this operation can never produce it. It also lacks the Allow header that RFC 9110 §15.5.6 requires the origin server to send with every 405. RFC 9110 §15.5.14 has since renamed 413 to 'Content Too Large'.  
   *Suggested change:* Add headers: {Allow: {required: true, schema: {type: string, const: POST}}} to the 405 and reword it as 'returned when /par is called with any method other than POST'. Optionally note 'Content Too Large (RFC 9110 §15.5.14)' on the 413.  
   *Verifier: confirmed.*

13. **[LOW] Gap: PARRequest kept in step with /authorize**  
   *Reference:* RFC 9126 §2, §2.1  
   PAR accepts every authorization-endpoint parameter, but PARRequest omits claims_locales, which /authorize has (ClaimsLocales, lines 919-927). It also leaves response_type, response_mode and prompt as free strings, while /authorize restricts them with enums (lines 703-706, 855, 815-819). The two descriptions of the same request can drift apart.  
   *Suggested change:* Move the value sets into shared schemas (for example components.schemas.ResponseTypeValue, ResponseModeValue and PromptValue) and $ref them from both the /authorize parameters and PARRequest. Add claims_locales: {type: string}.  
   *Verifier: confirmed.*

14. **[LOW] Gap: Security-consideration notes**  
   *Reference:* RFC 9126 §7.4, §7.5  
   The YAML does not say that the AS should re-check the pushed request against the current client policy when the request_uri is used (§7.4). It also does not say that clients SHOULD put PKCE, a unique state or an OIDC nonce into the pushed request to defeat request-URI swapping (§7.5).  
   *Suggested change:* Add two sentences to the /par description that cite §7.4 and §7.5.  
   *Verifier: confirmed.*

15. **[LOW] Incorrect: lines 990-994 components.headers.CacheControlNoStore, used by the /par 201 (lines 453-454) and 400 (via OAuthErrorWithDPoPNonce, lines 1081-1082)**  
   *Reference:* RFC 9126 §2.2, §2.3 (examples)  
   The header schema is const: 'no-store', but every RFC 9126 example response (§1.1, §2.2, §2.3) sends 'Cache-Control: no-cache, no-store'. A response validator built from the YAML would flag the RFC's own responses as invalid. RFC 9126 does not mandate either value.  
   *Suggested change:* Relax to pattern: '(^|,) *no-store *(,|$)' with examples ['no-store', 'no-cache, no-store']. This still satisfies RFC 6749 §5.1's no-store requirement for /token.  
   *Verifier: confirmed.*

16. **[LOW] Incorrect: lines 976-979 components.parameters.DPoPHeader.description**  
   *Reference:* RFC 9449 §10.1 (PAR endpoint)  
   The description says the DPoP header is 'Required on /token, /par, protected resources, and /userinfo whenever DPoP-bound access tokens are in use'. At /par it is never required. RFC 9449 §10.1 offers it as one of two alternatives (dpop_jkt in the body or a DPoP proof header), and a client can still obtain DPoP-bound tokens with neither, by presenting a proof at /token.  
   *Suggested change:* Reword: 'Required on /token, protected resources and /userinfo when DPoP is used. OPTIONAL on /par, where it is an alternative to dpop_jkt for binding the authorization code (RFC 9449 §10.1).'  
   *Verifier: confirmed.*

17. **[LOW] Incorrect: lines 1178-1184 components.schemas.ClientAuthFields.properties.client_id (inherited by PARRequest via allOf at line 1591)**  
   *Reference:* RFC 9126 §2.1, §3 (erratum 6711)  
   The inherited description says client_id is 'OPTIONAL when authenticating via client_assertion'. In a pushed authorization request client_id is always required: RFC 9126 §2.1 says 'it is similarly required in a pushed authorization request', and reported erratum 6711 confirms it travels alongside 'request'. PARRequest's own required list (line 1594) is correct, so generated docs show two contradictory texts for the same field.  
   *Suggested change:* Give PARRequest.properties.client_id (lines 1598-1599) its own description: 'REQUIRED in every PAR request, whatever the client-authentication method (RFC 9126 §2.1). MUST match the authenticated client and the Request Object's client_id claim (§3).'  
   *Verifier: confirmed.*

18. **[LOW] Incorrect: PARRequest.code_challenge_method declares default: S256 (L1612-1615)** — *found by the verifier*  
   *Reference:* RFC 7636 §4.3; draft-ietf-oauth-v2-1-16 §4.1.1; RFC 9126 §2 (PAR accepts the authorization-endpoint parameters)  
   PARRequest.code_challenge_method declares default: S256 (L1612-1615). RFC 7636 says an omitted method defaults to plain. OAuth 2.1 -16 makes the parameter REQUIRED with no default. The /authorize CodeChallengeMethod (L780-795) has no default and describes the -15 rule 'OPTIONAL (defaulting to plain)'. Generators use the default: par_api.py L58 declares code_challenge_method as Form('S256'). So the 'required' entry at L1594 is not enforced, and an omitted method is silently treated as S256 instead of being rejected (-16) or treated as plain (RFC 7636).  
   *Suggested change:* Delete 'default: S256' from PARRequest.code_challenge_method, keep it in required (or in the else-branch of the JAR-in-PAR conditional), and describe it as 'REQUIRED; S256 only (OAuth 2.1 -16 §4.1.1)'.

19. **[LOW] Gap: The AS's validation duties for pushed requests are undocumented** — *found by the verifier*  
   *Reference:* RFC 9126 §2.1 (processing step 3), §4 (paragraph 2)  
   The AS's validation duties for pushed requests are undocumented. At /par it must validate the pushed request as it would an /authorize request (redirect_uri, scope, PKCE ...), and any check it defers MUST be done at /authorize. Requests arising from a pushed request MUST be validated like any other; steps already performed may be skipped only if the AS can verify the request was pushed and neither the request nor its policy has changed. The first agent covered only §7.4's lowercase 'recommended' policy re-check.  
   *Suggested change:* Add to the /par description: 'The AS validates the pushed request exactly as an /authorize request (RFC 9126 §2.1 step 3); any check it defers MUST run at /authorize.' Add to RequestUri: 'Requests arising from a pushed request are validated like any other authorization request (RFC 9126 §4).'

20. **[LOW] Gap: The client-authentication metadata is not tied to /par** — *found by the verifier*  
   *Reference:* RFC 9126 §2 (paragraphs 2 and 4)  
   The client-authentication metadata is not tied to /par. RFC 9126 §2 says token_endpoint_auth_methods_supported (and the client's token_endpoint_auth_method) also govern client authentication at the PAR endpoint, and that an AS supporting PAR SHOULD publish pushed_authorization_request_endpoint. The YAML's descriptions of token_endpoint_auth_methods_supported (L2037-2049), token_endpoint_auth_signing_alg_values_supported (L2050-2056) and pushed_authorization_request_endpoint (L1981-1984) say neither.  
   *Suggested change:* Append '(also applies to client authentication at the PAR endpoint, RFC 9126 §2)' to both token_endpoint_auth_* descriptions, and 'SHOULD be published by an AS that supports PAR (RFC 9126 §2)' to pushed_authorization_request_endpoint.

## RFC 9207 OAuth 2.0 Authorization Server Issuer Identification

*March 2022 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: required-oauth21 · vendoring: already-vendored*

**What it is.** RFC 9207 adds an 'iss' parameter to authorization responses, both successful and error ones. Its value is the AS's issuer identifier: an https URL with no query or fragment, identical to the 'issuer' in the AS metadata. It also adds the AS metadata flag authorization_response_iss_parameter_supported. The client compares 'iss' with the issuer it sent the request to and rejects any mismatch, which defeats mix-up attacks. Since OAuth 2.1 draft -16, every AS must send it.

**Why it was created.** A client that works with several authorization servers cannot tell which AS produced an authorization response arriving through the browser. An attacker who controls or compromises one AS (for example by registering it dynamically) can run a 'mix-up attack': trick the client into sending an honest AS's authorization code or access token to the attacker. The formal analysis by Fett, Küsters and Schmitz (arXiv 1601.01229) showed that having the AS name itself explicitly in the response stops this class of attack.

<details><summary>Already modeled in the YAML (4)</summary>

- 'iss' authorization-response parameter on success and error redirects: prose in paths./authorize.get.responses.302.description (lines 161-169) and the Location examples (lines 180-181, form-urlencoded https issuer); the 303 is described as 'Same as 302' (line 183)
- AS metadata authorization_response_iss_parameter_supported, boolean, default false (§3): OAuthServerMetadata (lines 2205-2211)
- Issuer identifier format, HTTPS with no query or fragment (§2): OAuthServerMetadata.issuer description (lines 1944-1950)
- Entry in the covered-specifications table: info.description (line 36)

</details>

**Follow-up on the May-2026 validation notes.** references/rfc-validation has no note for RFC 9207. The audit synthesis and 9700-security-bcp.md item M1 asked for iss in the 302 Location documentation and example, and for authorization_response_iss_parameter_supported. Both are done (lines 164-169, 180-181, 2206-2211). Relative to today's OAuth 2.1 -16, the requiredness of iss is still open. M1 also quotes RFC 9700 as saying the issuer 'MUST be sent in the authorization response'. That sentence is not in RFC 9700: its §2.1 says clients SHOULD use iss, and §4.4.2.1 only describes the defense.

**Notes.** The YAML does not contradict RFC 9207 itself: its conditional wording matches the RFC read alone, so the outdated requiredness is reported as a gap measured against OAuth 2.1 -16. Client-side checks (§2.4, §4: decode, compare by simple string comparison, remember per-AS support, reject a missing iss) are outside an AS spec but matter for a client SDK. When JARM is used, iss lives inside the response JWT; that belongs to the JARM cluster.

### Findings (0 high · 2 medium · 4 low)

1. **[MEDIUM] Gap: Whether 'iss' is required in authorization responses**  
   *Reference:* RFC 9207 §2; draft-ietf-oauth-v2-1-16 §4.1.2, §4.1.2.1  
   The /authorize 302 description (lines 161-169) makes 'iss' on success conditional ('when the AS advertises authorization_response_iss_parameter_supported'), and the 303 (line 183) inherits that. This matches RFC 9207 read alone and the vendored OAuth 2.1 -15, where iss was OPTIONAL. But draft-ietf-oauth-v2-1-16 (2026-09-03) changed both §4.1.2 and §4.1.2.1 to 'iss: REQUIRED'; its changelog says 'Make iss response parameter required to be sent by the AS'. The YAML's info.summary (line 8) says 'Defaults follow OAuth 2.1', so a server generated from it would treat iss as optional and break the current OAuth 2.1 text. The description also never says that iss accompanies every response mode: query, fragment and form_post.  
   *Suggested change:* Rewrite the 302 bullets: 'on success: code, state (if sent), iss - REQUIRED (OAuth 2.1 -16 §4.1.2; RFC 9207 §2); on failure: error, error_description, error_uri, state, iss - REQUIRED (-16 §4.1.2.1). iss is the AS issuer identifier, identical to the metadata issuer, form-urlencoded in the Location query or fragment, or included in the form_post body.' Make the same change for the 303.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Value of authorization_response_iss_parameter_supported**  
   *Reference:* RFC 9207 §2.3, §3  
   The field (lines 2205-2211) is correctly a boolean with RFC 9207 §3's default of false. Its description does not say that an AS supporting RFC 9207 MUST publish true when it publishes RFC 8414 metadata (§2.3). Under OAuth 2.1 -16 every AS sends iss, so every compliant AS must publish true, and clients rely on the flag to reject responses that lack iss (§2.4).  
   *Suggested change:* Keep default: false and add: 'An AS that sends iss MUST set this to true (RFC 9207 §2.3). An OAuth 2.1 (-16) AS always sends iss and therefore publishes true. Clients reject responses without iss from an AS that sets true (§2.4).' Add examples: [true].  
   *Verifier: confirmed.*

3. **[LOW] Gap: 'iss' missing from the list of authorization-error parameters**  
   *Reference:* RFC 9207 §2, §2.2; OAuth 2.1 -16 §4.1.2.1  
   ErrorResponse (lines 1465-1533) documents 'state' for 'authorization-endpoint redirect errors' (lines 1529-1533) but has no 'iss'. The only schema that lists authorization-error parameters therefore omits one that is now REQUIRED. This gap concerns the parameter list, not OpenAPI's documented inability to model the redirect itself.  
   *Suggested change:* Either add iss: {type: string, format: uri, description: 'authorization-endpoint error redirects only (RFC 9207 §2; OAuth 2.1 -16 §4.1.2.1); never sent in token-endpoint error bodies'} to ErrorResponse, or add documentation-only schemas AuthorizationResponseParameters {code, state, iss} and AuthorizationErrorResponseParameters {error, error_description, error_uri, state, iss} and point to them from the 302 description.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Constraints on the iss value and equality with the metadata issuer**  
   *Reference:* RFC 9207 §2, §2.3  
   iss MUST be an https URL with no query or fragment, identical to the metadata 'issuer'. OAuthServerMetadata.issuer (lines 1944-1950) says 'HTTPS (no query/fragment)' and 'byte-identical to tokens' iss claim', but has no pattern and does not mention the iss response parameter.  
   *Suggested change:* On issuer, add pattern: '^https://[^?#]+$' and the text 'identical to the iss authorization-response parameter (RFC 9207 §2.3)'.  
   *Verifier: confirmed.*

5. **[LOW] Gap: Consistency with the ID Token iss in OIDC hybrid responses**  
   *Reference:* RFC 9207 §2.4, §4  
   The 302 description mentions the hybrid response_type 'code id_token' (lines 166-167) but not that, when an ID Token comes back from the authorization endpoint, the iss parameter MUST equal its iss claim, and that clients reject responses whose issuer identifiers disagree.  
   *Suggested change:* Append: 'For code id_token, the iss parameter MUST be identical to the ID Token iss claim (RFC 9207 §2.4).'  
   *Verifier: confirmed.*

6. **[LOW] Incorrect: The 302 description places the hybrid response, and with it iss, wrongly** — *found by the verifier*  
   *Reference:* RFC 9207 §2; OAuth 2.0 Multiple Response Type Encoding Practices §2.2, §5  
   The 302 description places the hybrid response, and with it iss, wrongly. It lists code, state and iss for the Location and says that for response_type=code id_token it 'also carries id_token in the URL fragment', which implies a query-plus-fragment split. For code id_token the default response mode is fragment, the query encoding MUST NOT be used, and all parameters SHOULD use the same mode. So code, state, iss and id_token all travel in the fragment (or in the form_post body). This is cross-cluster (OIDC / Multiple Response Types), but it decides where RFC 9207's iss must appear.  
   *Suggested change:* Reword the hybrid bullet: 'For response_type=code id_token the whole response (code, state, iss, id_token) is fragment-encoded unless response_mode=form_post (Multiple Response Types §5); iss accompanies the response in every response mode (RFC 9207 §2).'

## Verifier corrections to the summaries above

- RFC 9101 summary: 'the application/oauth-authz-req+jwt media type (also the recommended JOSE typ)' overstates RFC 9101 §10.8. That section presents explicit typing as one optional cross-JWT-confusion mitigation, warns that requiring it 'will break most existing deployments', and says requiring it 'would be a good idea for new OAuth deployment profiles'. There is no RECOMMENDED or SHOULD. Suggest: '(also usable as the JOSE typ value for explicit typing, §10.8)'.
- RFC 9207 category 'security-bcp' is only a grouping label. RFC 9207 is a Standards Track Proposed Standard, not a BCP; the status field correctly says Proposed Standard.
- Cluster notes: draft-ietf-oauth-rfc7523bis-11 does not yet 'formally update' RFC 9126. Its header reads 'Updates: 7521, 7522, 7523, 9126 (if approved)', it is still in the RFC Editor queue (RFCEd: In Progress), and the RFC index shows no updated_by for RFC 9126. The agent is right that it rewrites the last paragraph of RFC 9126 §2.
- Cluster notes: the RFC Editor classifies all three RFC 9126 errata (6711, 7254, 7410) as status Reported, type Technical (re-fetched 2026-10-10). 7254 and 7410 are editorial in substance. Labelling only 6711 'technical' is accurate but incomplete. RFC 9101 and RFC 9207 still show 'No matching errata found'.
- Cluster notes item (3): only the RequestUri 'takes precedence' text contradicts JAR's rule to use only the Request Object parameters (RFC 9101 §6.3). The /authorize 'only client_id plus one parameter' text agrees with that rule on the AS side; it conflicts instead with JAR §5's MAY-duplicate allowance and OIDC Core §6.1/§6.2's MUST-duplicate rule for response_type, client_id and scope=openid.
- RFC 9207 summary 'Since OAuth 2.1 draft -16, every AS must send it' is accurate for -16 §4.1.2/§4.1.2.1. But -16 is a WG draft (state 'WG Document'), not an RFC, and -16 §4.1.2 keeps 'unless specified otherwise by an extension'; for example, JARM carries iss inside the response JWT (RFC 9207 §2.4 note).
