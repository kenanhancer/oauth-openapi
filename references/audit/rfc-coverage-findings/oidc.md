# OpenID Connect & OIDF response-mode / session / logout / CIBA specs

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [oidc-core-1.0](#oidc-core-10-openid-connect-core-10-incorporating-errata-set-2) | February 2014 (errata set 1: November 2014; errata set 2: December 2023) | OpenID Foundation Final Specification (errata set 2, 15 Dec 2023); also ISO/IEC 26131:2024 | mostly | 3 | 10 | 21 |
| [oidc-discovery-1.0](#oidc-discovery-10-openid-connect-discovery-10-incorporating-errata-set-2) | February 2014 (errata set 1: November 2014; errata set 2: December 2023) | OpenID Foundation Final Specification (errata set 2, 15 Dec 2023); ISO/IEC 26132:2024 | mostly | 0 | 3 | 10 |
| [oauth-v2-form-post-response-mode-1.0](#oauth-v2-form-post-response-mode-10-oauth-20-form-post-response-mode) | April 2015 | OpenID Foundation Final Specification (27 Apr 2015); ISO/IEC 26139:2024 | partial | 0 | 1 | 2 |
| [oauth-v2-multiple-response-types-1.0](#oauth-v2-multiple-response-types-10-oauth-20-multiple-response-type-encoding-practices) | February 2014 | OpenID Foundation Final Specification (25 Feb 2014); ISO/IEC 26138:2024 | partial | 1 | 1 | 4 |
| [openid-financial-api-jarm-draft-02](#openid-financial-api-jarm-draft-02-financial-grade-api-jwt-secured-authorization-response-mode-for-oauth-20-jarm-draft-02) | October 2018 | OIDF FAPI WG draft (Draft-02, 17 Oct 2018), superseded by the JARM Final Specification (Nov 2022) and its errata set 1 (Aug 2025); RFC 9700 still cites it as [OpenID.JARM] | referenced-only (verifier corrected from partial) | 0 | 3 | 1 |
| [oauth-v2-jarm-final](#oauth-v2-jarm-final-jwt-secured-authorization-response-mode-for-oauth-20-jarm) | November 2022 (errata set 1: August 2025) | OpenID Foundation Final Specification (9 Nov 2022). 'Incorporating errata set 1' (17 Aug 2025) is now served at https://openid.net/specs/oauth-v2-jarm.html | referenced-only (verifier corrected from partial) | 0 | 4 | 4 |
| [oidc-session-1.0](#oidc-session-10-openid-connect-session-management-10) | September 2022 | OpenID Foundation Final Specification (12 Sep 2022); ISO/IEC 26135:2024 | referenced-only | 0 | 1 | 3 |
| [oidc-frontchannel-logout-1.0](#oidc-frontchannel-logout-10-openid-connect-front-channel-logout-10) | September 2022 | OpenID Foundation Final Specification (12 Sep 2022); ISO/IEC 26136:2024 | referenced-only (verifier corrected from partial) | 0 | 1 | 5 |
| [oidc-backchannel-logout-1.0](#oidc-backchannel-logout-10-openid-connect-back-channel-logout-10-incorporating-errata-set-1) | September 2022 (errata set 1: December 2023) | OpenID Foundation Final Specification (errata set 1, 15 Dec 2023); ISO/IEC 26137:2024 | referenced-only (verifier corrected from partial) | 0 | 2 | 4 |
| [oidc-rpinitiated-logout-1.0](#oidc-rpinitiated-logout-10-openid-connect-rp-initiated-logout-10) | September 2022 | OpenID Foundation Final Specification (12 Sep 2022); ISO/IEC 26134:2024 | referenced-only | 0 | 1 | 2 |
| [oidc-ciba-core-1.0](#oidc-ciba-core-10-openid-connect-client-initiated-backchannel-authentication-flow---core-10) | September 2021 | OpenID Foundation Final Specification (1 Sep 2021, MODRNA WG) | referenced-only | 0 | 3 | 5 |

**Cluster notes.** Scope: 11 OpenID Foundation documents. The 5 vendored files (Core, Discovery, Form Post, Multiple Response Types, FAPI JARM Draft-02) are byte-identical to openid.net today. The YAML also uses metadata from 6 OIDF specs that are not vendored: JARM Final, Session Management, Front-Channel Logout, Back-Channel Logout, RP-Initiated Logout and CIBA. All 6 should be vendored. *(Update 2026-10-11: all 6, and OIDC Registration, are now vendored.)*

Highest-impact fixes:
(1) Add POST /authorize. It is a MUST in OIDC Core §3.1.2.1.
(2) The YAML keeps response_type=id_token and 'code id_token' but none of their safety rules. nonce is REQUIRED (§3.2.2.1/§3.3.2.1), c_hash is REQUIRED (§3.3.2.11), responses go in the fragment, and the query encoding MUST NOT be used (OAuth.Responses §3/§5/§7). A legitimate alternative is to drop both values and stay Code-flow only.
(3) Model the form_post response: an auto-submitting HTML page sent with no-store.
(4) Model the RP-Initiated Logout endpoint (end_session_endpoint is already advertised).
(5) Make the ResponseMode request enum (L855) match response_modes_supported (L2031), and add the JARM algorithm metadata.
(6) Model prompt as a space-delimited list.
(7) Allow only public keys in /jwks.
(8) Fix the semantics of request_uri_parameter_supported (RFC 9126 §5).

Design suggestions:
- Introduce one AuthorizationRequest object schema, using JSON Schema if/then for conditional requirements, and share it across GET /authorize (style: form, explode: true), POST /authorize and PAR.
- Use OpenAPI 3.1 top-level webhooks for calls the OP makes outward: back-channel logout, CIBA ping/push, and the form_post POST to the client.

Coverage by document:
- Core and Discovery: mostly covered.
- Form Post, Multiple Response Types and JARM: partially covered. Only the parameter or metadata values are modeled, not the encoding rules.
- Session Management, RP-Initiated Logout and CIBA: only their discovery metadata fields are modeled.
- Front-Channel and Back-Channel Logout: partially covered (metadata only; sid and the Logout Token are missing).

Dates and status (verified today):
- The OIDC specs were published as ISO/IEC 26131–26139:2024 in October 2024. The numbers map to Core, Discovery, Dynamic Client Registration, RP-Initiated Logout, Session Management, Front-Channel Logout, Back-Channel Logout (errata 1), Multiple Response Types and Form Post, in that order.
- Correction to the audit's working notes: https://openid.net/specs/oauth-v2-jarm.html now serves 'JARM incorporating errata set 1', dated 17 Aug 2025 (sha256 3a829c72…). It is not the -final bytes (8d08881d…). The errata are editorial only: IANA descriptions changed from 'introspection' to 'authorization', the reference now points to RFC 9700, and affiliations were updated. RFC 9700 still cites the 2018 FAPI draft.

IANA (OIDC-attributed values absent from the YAML):
- Parameter: session_state.
- JWT claims: at_hash, c_hash, sub_jwk, sid, _claim_names, _claim_sources, and events (RFC 8417, used by the Logout Token).
- Client metadata (these need a registration/client schema; overlaps the DCR cluster): frontchannel_logout_uri, frontchannel_logout_session_required, backchannel_logout_uri, backchannel_logout_session_required, post_logout_redirect_uris, authorization_signed/encrypted_response_*.
- The values 'registration', 'none', 'code token', 'id_token token' and 'code id_token token' are flagged present in the IANA diff only because the words appear in prose.
- JARM's three AS-metadata names do not appear in the IANA AS-metadata registry snapshot. authorization_signing_alg_values_supported and its two siblings appear only as client metadata (from RP Metadata Choices).

Adjacent OIDF specs outside this cluster that show up in the IANA diff: OIDC Dynamic Client Registration 1.0 (registration_endpoint is present but there is no /register operation; DCR cluster), RP Metadata Choices, OpenID Federation 1.0, OpenID for Verifiable Presentations 1.0, Identity Assurance (verified_claims) and FAPI 2.0.

Intentionally excluded and not reported: the token-bearing response types (id_token token, code token, code id_token token), the Implicit and Password grants, and vendor x-* extensions.

Prior-audit follow-up:
- Core: 18 of the 45 May-2026 bullets are fixed, 1 partly fixed and 21 still open (5 needed no action).
- Discovery: 38 of 45 fixed, 1 partly fixed, 6 still open.

## oidc-core-1.0 OpenID Connect Core 1.0 incorporating errata set 2

*February 2014 (errata set 1: November 2014; errata set 2: December 2023) · OpenID Foundation Final Specification (errata set 2, 15 Dec 2023); also ISO/IEC 26131:2024 · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** OpenID Connect Core adds a login (identity) layer on top of OAuth 2.0. When a client sends scope=openid, the authorization server (called an OpenID Provider, OP) authenticates the user and issues an ID Token. The ID Token is a signed JWT that says who the user is (iss+sub), which client it is for (aud), when and how the user authenticated (auth_time, acr, amr), and which request it answers (nonce). Core also defines the UserInfo endpoint, extra authorization-request parameters (nonce, prompt, display, max_age, ui_locales, claims_locales, id_token_hint, login_hint, acr_values, claims, request/request_uri), new error codes, the Code, Implicit and Hybrid flows, and the client-authentication methods. The vendored file is the errata-set-2 edition (15 Dec 2023).

**Why it was created.** OAuth 2.0 only delegates access. It gives the client no verifiable statement about who the user is or when they logged in. Sites still built 'login with OAuth' on access tokens and proprietary profile APIs. That allowed token substitution and impersonation: a token issued to a different client could be replayed. OpenID Connect (2014, successor to OpenID 2.0) standardized authentication with an audience-restricted, signed ID Token, nonce-based replay protection and a shared claims vocabulary, so any relying party (RP) can work with any OP.

<details><summary>Already modeled in the YAML (9)</summary>

- GET /authorize (paths./authorize.get L109-205) with the OIDC request parameters: scope with the openid note (components.parameters.Scope L732-748); response_type code|id_token|'code id_token' (ResponseType L686-706); redirect_uri (L716-730); state (L750-758); nonce (L797-805); prompt (L807-819); display (L897-906); max_age (L829-836); ui_locales (L908-917); claims_locales (L919-927); id_token_hint (L929-937); login_hint (L821-827); acr_values (L838-844); claims (L939-948); request (L950-960); request_uri, PAR form only (L857-868); response_mode (L846-855)
- Authorization responses: 302/303 with prose saying code id_token puts id_token in the fragment (L160-189); a 400 HTML error that does not redirect (L196-205); note that 303 is recommended and 307 prohibited (L171-172), matching §16.22
- §3.1.2.6 error codes in components.schemas.ErrorResponse.error: invalid_request_uri, invalid_request_object, request_not_supported, request_uri_not_supported (L1501-1504); interaction_required, login_required, account_selection_required, consent_required, registration_not_supported (L1512-1517); state echo (L1529-1533)
- §3.1.3.3 token response: TokenResponse.id_token (L1443-1448); Cache-Control: no-store on /token 200 (L250-254)
- §2 ID Token claims: components.schemas.IDTokenClaims (L2461-2509) with iss, sub, aud, exp, iat required plus auth_time, nonce, acr, amr (RFC 8176) and azp
- §5.3 UserInfo: GET (L482-518) and POST with the access_token form field (L519-568, L532-545); application/json UserInfoResponse and application/jwt bodies (L499-511, L549-561); bearerAuth plus dpop (L516-518, L566-568); 401/403 via ProtectedResourceError with a WWW-Authenticate challenge (L1091-1107, L1000-1025)
- §5.1 standard claims including the address sub-fields and NumericDate updated_at (UserInfoResponse L2343-2407); signed UserInfo payload with required iss/aud/sub (UserInfoSignedResponse L2409-2429)
- §9 client authentication: client_secret_basic (securitySchemes.clientSecretBasic L2662-2674); client_secret_post, client_secret_jwt and private_key_jwt (ClientAuthFields L1175-1200); none (empty {} security alternative); token_endpoint_auth_methods_supported enum (L2037-2049)
- §12 refresh tokens (RefreshTokenRequest L1284-1307); §5.4/§11 scopes in the Scope description (L737-739) and the oauth2 scheme (L2696-2700, partial)

</details>

**Follow-up on the May-2026 validation notes.** The May-2026 notes contain 45 bullets; 18 are fixed, 1 partly fixed, 21 open and 5 needed no action.
- MISSING (20): 13 fixed: signed-UserInfo iss/aud, the IDTokenClaims schema, auth_time, display, ui_locales, claims_locales, id_token_hint, claims, request, the 9 OIDC error codes, the UserInfo WWW-Authenticate challenge, claim_types_supported, and the signed-UserInfo aud rule. 5 open: fragment-encoded implicit/hybrid responses, aggregated/distributed claims, the §6.1 rule on repeating response_type/scope (now contradicted at L125-128), the token_type note, and the registration parameter. 2 needed no action.
- WRONG (13): 3 fixed: the userinfo POST body, application/jwt on POST, and NumericDate updated_at. 8 open: nonce conditionally REQUIRED (raised twice), prompt list syntax, sub maxLength 255, the max_age=0 note, acr examples, the address description, and additionalProperties/_claim_*. 2 needed no action.
- NICE-TO-HAVE (12): 2 fixed: request/request_uri mutual exclusion and amr as an array. 1 partly fixed: issuer https is described but not enforced with a pattern. 8 open, including POST /authorize, which is actually a §3.1.2.1 MUST and is now rated high, plus CORS and the address/phone scopes. 1 needed no action.
- The prior 'correctly modeled' list is outdated: code token and code id_token token have since been removed on purpose.

**Notes.** Intentional exclusions honoured: the token-bearing response types (id_token token, code token, code id_token token) and the Implicit grant. As a result, a server built from the YAML cannot be a Dynamic OP: §15.2 also requires id_token token, Discovery, Dynamic Registration and client-hosted request_uri. Not part of the AS surface: §4 third-party-initiated login (an RP endpoint) and §7 Self-Issued OP (the registration parameter and sub_jwk); registration_not_supported is still listed, which is harmless. In the IANA diff, at_hash, c_hash, sub_jwk, _claim_names and _claim_sources are absent; 'registration' and 'none' were reported present only because those words occur in prose. The covered-specifications table (L44) gives the year as 2014, although the vendored text is errata set 2 (2023).

### Findings (3 high · 10 medium · 21 low)

1. **[HIGH] Gap: POST /authorize (Authentication Request sent as a form body)**  
   *Reference:* OIDC Core §3.1.2.1, §13.2  
   §3.1.2.1 says: 'Authorization Servers MUST support the use of the HTTP GET and POST methods ... at the Authorization Endpoint'. With POST the parameters are form-serialized (§13.2). paths./authorize defines only get (L110), so a server generated from the YAML answers 405 to a conformant POST request. The May-2026 audit filed this as NICE-TO-HAVE, but it is a MUST.  
   *Suggested change:* Add paths./authorize.post with requestBody application/x-www-form-urlencoded → $ref an AuthorizationRequest schema. Build that schema from the same members as the GET parameters, factoring out the property list in PARRequest (L1583-1647). Reuse the GET responses (302/303/200/400). Optionally model the GET query as one object parameter (in: query, style: form, explode: true, $ref AuthorizationRequest) so GET, POST and PAR share one schema.  
   *Verifier: confirmed.*

2. **[HIGH] Gap: nonce REQUIRED for response_type=id_token and 'code id_token'**  
   *Reference:* OIDC Core §3.2.2.1, §3.3.2.1, §3.2.2.10, §2 (nonce)  
   nonce is REQUIRED in the Implicit Flow (id_token) and for Hybrid 'code id_token', and the AS MUST copy it into the ID Token. components.parameters.Nonce (L797-805) only calls it an 'opaque random value' and ResponseType (L686-706) says nothing. A generated server therefore accepts response_type=id_token without a nonce, which loses replay protection for ID Tokens delivered through the browser. Still open from the May-2026 audit.  
   *Suggested change:* Extend Nonce.description: 'REQUIRED when response_type contains id_token (§3.2.2.1/§3.3.2.1); OPTIONAL for code (OAuth 2.1 §7.5.1.1 lets confidential OIDC clients use nonce instead of PKCE); MUST be copied into the ID Token nonce claim'. In AuthorizationRequest/PARRequest add allOf: [{if: {required: [response_type], properties: {response_type: {pattern: '(^| )id_token( |$)'}}}, then: {required: [nonce]}}]. When nonce is missing, return invalid_request.  
   *Verifier: confirmed.*

3. **[HIGH] Gap: ID Token c_hash and at_hash claims**  
   *Reference:* OIDC Core §3.3.2.11, §3.1.3.6, §3.3.3.6  
   c_hash is REQUIRED when the ID Token is issued from the authorization endpoint together with a code. That is response_type 'code id_token', which the YAML allows (L706). at_hash is OPTIONAL in Code-flow ID Tokens, REQUIRED whenever a front-channel ID Token comes with an access token, and REQUIRED in CIBA push mode. IDTokenClaims (L2461-2509) has neither claim, and the IANA JWT-claims diff lists both as absent. A Hybrid implementation built from the YAML would therefore omit the mandatory c_hash, and the RP could not detect a substituted code.  
   *Suggested change:* Add to IDTokenClaims: c_hash {type: string, description: 'base64url of the left-most half of hash(code), using the hash of the ID Token alg; REQUIRED when issued from the authorization endpoint with a code (code id_token)'} and at_hash {type: string, description: 'same calculation over access_token; OPTIONAL in Code flow'}. Note that both MAY be omitted from the ID Token returned by the token endpoint (§3.3.3.6).  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: Structure of the claims request parameter (userinfo/id_token; essential, value, values)**  
   *Reference:* OIDC Core §5.5, §5.5.1, §5.5.1.1, §5.5.2, §3.1.2.2 step 4  
   Claims (L939-948) and PARRequest.claims (L1636-1638) are opaque strings. The AS has to parse a JSON object whose userinfo and id_token members map claim names (possibly language-tagged) to null or to {essential, value, values}. A mismatching sub value MUST make authentication fail. An essential acr with values MUST be met, or the attempt is treated as a failed authentication. The userinfo member requires a response type that yields an access token.  
   *Suggested change:* Add schemas.ClaimsRequest {type: object, properties: {userinfo: $ref IndividualClaimsRequests, id_token: $ref IndividualClaimsRequests}, additionalProperties: true} and IndividualClaimsRequests {type: object, additionalProperties: {oneOf: [{type: 'null'}, {type: object, properties: {essential: {type: boolean, default: false}, value: {}, values: {type: array}}, additionalProperties: true}]}}. Switch the Claims parameter to content: {application/json: {schema: $ref ClaimsRequest}} (OpenAPI 3.1 JSON-in-query) and state the §3.1.2.2/§5.5.1.1 rules in its description.  
   *Verifier: confirmed.*

5. **[MEDIUM] Gap: Implicit/Hybrid response encoding (id_token as a response parameter; fragment by default for success and errors)**  
   *Reference:* OIDC Core §3.2.2.5, §3.2.2.6, §3.3.2.5, §3.3.2.6  
   response_type=id_token returns id_token and state with no code. 'code id_token' returns code, id_token and state. Both go in the fragment unless response_mode says otherwise, and errors 'MUST' also go in the fragment. The 302 response (L160-181) has only query-string examples and never describes the response_type=id_token case.  
   *Suggested change:* Add a per-response_type table to the 302 description: code → query; id_token → fragment (id_token, state, iss); code id_token → fragment (code, id_token, state, iss); errors use the same mode. Add Location examples such as 'https://client.example.org/cb#code=Spl...&id_token=eyJ...&state=af0ifjsldkj' and '...#error=login_required&state=af0ifjsldkj'.  
   *Verifier: confirmed.*

6. **[MEDIUM] Gap: client_assertion claim rules for client_secret_jwt and private_key_jwt**  
   *Reference:* OIDC Core §9, §10.1  
   OIDC requires iss and sub to equal client_id, aud to identify the AS (SHOULD be the token endpoint URL), and both exp and jti. It also says 'These tokens MUST only be used once'. That is stricter than RFC 7523, where jti is optional. ClientAuthFields.client_assertion (L1191-1196) cites only RFC 7523 §2.2, so nothing tells an implementer to require jti or to keep a replay cache. Separately, an HS* signature uses the client_secret octets as the key.  
   *Suggested change:* Expand the client_assertion description with the §9 claim set, the single-use (jti replay cache) rule and the symmetric-key rule. Optionally add a documentation schema ClientAssertionClaims with required: [iss, sub, aud, jti, exp].  
   *Verifier: partially correct —* The YAML lacks the OIDC client-assertion rules: iss = sub = client_id, exp, and a single-use jti backed by a replay cache. An HS* assertion is keyed with the client_secret octets. Document these rules. For aud, use the post-CVE-2025-27370 rule (rfc7523bis-11): the issuer identifier is the sole audience, and token-endpoint or multi-valued audiences are rejected. Do not copy OIDC Core §9's 'SHOULD be the token endpoint URL', and state that the profile deliberately tightens §9.

7. **[MEDIUM] Gap: UserInfoResponse openness: extra, aggregated/distributed and language-tagged claims**  
   *Reference:* OIDC Core §5.1.2, §5.2, §5.3.2, §5.6.2  
   §5.3.2 allows claims beyond §5.1. §5.2 allows names such as family_name#ja-Kana-JP. §5.6.2 defines _claim_names and _claim_sources, and the IANA diff lists both as absent. UserInfoResponse (L2343-2407) never states additionalProperties. That is legal JSON Schema, but openapi-generator, which this project uses, defaults to disallowAdditionalPropertiesIfNotPresent=true, so generated models would drop these claims. claim_types_supported (L2126-2131) can advertise aggregated/distributed claims that the schema cannot represent.  
   *Suggested change:* Set additionalProperties: true on UserInfoResponse. Add patternProperties '^[A-Za-z0-9_]+#[A-Za-z0-9-]+$' for language-tagged claims. Add _claim_names {type: object, additionalProperties: {type: string}} and _claim_sources {type: object, additionalProperties: {oneOf: [{required: [JWT], properties: {JWT: $ref JWT}}, {required: [endpoint], properties: {endpoint: {type: string, format: uri}, access_token: {type: string}}}]}}.  
   *Verifier: confirmed.*

8. **[MEDIUM] Incorrect: L807-819 components.parameters.Prompt (enum [none, login, consent, select_account])**  
   *Reference:* OIDC Core §3.1.2.1 (prompt), §15.1  
   prompt is a space-delimited, case-sensitive list (e.g., 'login consent'). The single-value enum makes generated validators reject valid combinations, and also unknown values that an OP MAY ignore. It also cannot express that 'none' combined with any other value is an error. PARRequest.prompt (L1618-1619) is an unconstrained string, so the two are inconsistent.  
   *Suggested change:* Use style: spaceDelimited, explode: false with schema {type: array, uniqueItems: true, items: {type: string, examples: [none, login, consent, select_account]}}. Document the defined values, that 'none' must appear alone, and that unknown values may be ignored.  
   *Verifier: confirmed.*

9. **[MEDIUM] Incorrect: L716-730 components.parameters.RedirectUri (description 'REQUIRED when the client has more than one registered redirect URI; OPTIONAL otherwise')**  
   *Reference:* OIDC Core §3.1.2.1, §3.1.2.2, §3.2.2.1  
   In an OpenID Connect request redirect_uri is always REQUIRED, and the AS MUST verify that REQUIRED parameters are present. For response_type=id_token it also MUST NOT be http, except for native-app loopback. The YAML states only the OAuth 2.1 rule.  
   *Suggested change:* Append: 'OIDC requests (scope contains openid): REQUIRED, exact match against a registered value; for response_type=id_token MUST NOT use http except native loopback.'  
   *Verifier: confirmed.*

10. **[MEDIUM] Incorrect: L161-169 paths./authorize.get.responses.302.description**  
   *Reference:* OIDC Core §3.3.2.5, §3.3.2.6; OAuth 2.0 Multiple Response Type Encoding Practices §2.2, §5  
   The text says success carries code and state, and that for code id_token 'it also carries id_token in the URL fragment'. That implies a split between query and fragment. Hybrid responses are made like Implicit ones: code, id_token, state and iss ALL go in the fragment by default, and error responses MUST be in the fragment too.  
   *Suggested change:* Rewrite: 'code → query unless response_mode says otherwise; id_token or code id_token → every parameter, including errors, in the fragment by default; the query encoding MUST NOT be used.' Add fragment examples.  
   *Verifier: confirmed.*

11. **[MEDIUM] Incorrect: L125-128 paths./authorize.get.description; L698-700 components.parameters.ResponseType.description**  
   *Reference:* OIDC Core §6.1, §6.2, §6.3.3 (contrast RFC 9101 §5, §6.3)  
   The YAML says that with request/request_uri only client_id plus that parameter appear in the query and everything else comes from the request object. In an OIDC request using request or request_uri, response_type and client_id MUST also be sent as normal parameters, and scope containing openid MUST always be sent outside the Request Object. The AS combines both sources, with the Request Object winning on conflicts (§6.3.3), and an RP may send state or nonce only outside it. The YAML silently adopts the RFC 9101 §6.3 rule (use only the Request Object). An OP following it would drop an outside-only nonce, and the ID Token would then fail the RP's nonce check.  
   *Suggested change:* Document both models: OIDC Core clients also send response_type, client_id and scope=openid in the query, and the AS MUST check they match the Request Object. Then choose and state a policy: JAR-strict (RFC 9101 §6.3) or OIDC-merge (§6.3.3) with Request Object precedence.  
   *Verifier: confirmed.*

12. **[MEDIUM] Incorrect: L566-568 paths./userinfo.post.security (bearerAuth | dpop) vs the requestBody access_token field at L532-545**  
   *Reference:* OIDC Core §5.3.1; RFC 6750 §2, §2.2  
   The operation documents a token sent in the form body (RFC 6750 §2.2), but its security list contains only header-based schemes. Tooling that enforces security, such as generated or mock servers, will answer 401 to a POST that carries the token only in the body, so this modeled option can never succeed. /token already handles the same case with an empty {} alternative (L265-268).  
   *Suggested change:* Add '- {}' to the POST security list, explain that the credential is then the access_token form field, and say that requests sending the token by more than one method get invalid_request.  
   *Verifier: confirmed.*

13. **[MEDIUM] Gap: No CSRF or clickjacking protection is described for the interactive /authorize pages** — *found by the verifier*  
   *Reference:* OIDC Core §3.1.2.3 (via RFC 6749 §10.12, §10.13); RFC 9700 §4.16  
   No CSRF or clickjacking protection is described for the interactive /authorize pages. The 200 text/html login/consent response has no framing-control headers (CSP frame-ancestors / X-Frame-Options) and no note.  
   *Suggested change:* Add Content-Security-Policy (frame-ancestors, with a per-client allow-list as in RFC 9700 §4.16) and X-Frame-Options headers to the interactive 200 text/html response and to the future logout-confirmation page. Note that login and consent forms carry anti-CSRF tokens. Keep non-interactive prompt=none responses and the check_session_iframe page frameable, because Session Management §3.1-§3.2 relies on iframes.

14. **[LOW] Gap: sub length limit and stability**  
   *Reference:* OIDC Core §2 (sub), §5.7  
   sub 'MUST NOT exceed 255 ASCII characters', is case-sensitive, and is never reassigned; iss+sub is the only stable user key. IDTokenClaims.sub (L2473-2475) and UserInfoResponse.sub (L2350-2351) have no maxLength. Still open from the prior audit.  
   *Suggested change:* Introduce a shared SubjectIdentifier schema {type: string, minLength: 1, maxLength: 255, description: 'ASCII, locally unique, never reassigned (§2, §5.7)'} and $ref it from both schemas.  
   *Verifier: confirmed.*

15. **[LOW] Gap: offline_access processing rules**  
   *Reference:* OIDC Core §11  
   The AS MUST ignore offline_access unless prompt contains consent (or other conditions permit offline access) and the response_type returns a code. It MUST always obtain consent before issuing a refresh token that allows offline access. Neither Scope (L737-739) nor the oauth2 scope text (L2700) says this.  
   *Suggested change:* Add the §11 rules to Scope.description and to the offline_access scope text.  
   *Verifier: confirmed.*

16. **[LOW] Gap: ID Token returned from a refresh**  
   *Reference:* OIDC Core §12.2  
   If a refresh returns an ID Token, iss, sub and aud MUST equal the original, iat is new, auth_time stays the time of the original authentication, and nonce SHOULD be absent (if present it must equal the original). Neither TokenResponse.id_token (L1443-1448) nor RefreshTokenRequest (L1284-1307) says so.  
   *Suggested change:* Add the rules to the TokenResponse.id_token and IDTokenClaims descriptions.  
   *Verifier: confirmed.*

17. **[LOW] Gap: Parameter semantics missing from descriptions (max_age, id_token_hint, display, acr '0')**  
   *Reference:* OIDC Core §3.1.2.1, §3.1.2.2, §2 (acr), §15.1  
   MaxAge (L829-836) does not say that auth_time MUST then be returned or that max_age=0 equals prompt=login. IDTokenHint (L929-937) does not say the OP MUST check it issued the token or must return an error such as login_required. Display (L897-906) is a closed enum, although an OP MAY ignore unknown values and §15.1 says using display must not cause an error. IDTokenClaims.acr (L2495-2497) does not explain the special value '0'.  
   *Suggested change:* Add these sentences. For Display, use examples instead of an enum, or document that unknown values are ignored rather than rejected.  
   *Verifier: partially correct —* MaxAge (L829-836) lacks the note that max_age=0 is equivalent to prompt=login and a pointer to the auth_time rule; that rule itself is already stated in IDTokenClaims.auth_time at L2491. IDTokenHint lacks the issuer check (§3.1.2.2 step 5), the login_required error (a MUST) and the SHOULD to accept expired ID Tokens for current or recent sessions. Display is a closed enum, although unknown values MAY be ignored and its use must not cause an error. The special acr value '0' is undocumented.

18. **[LOW] Gap: UserInfo extras: CORS, 400 invalid_request, encrypted-only JWT**  
   *Reference:* OIDC Core §5.3, §5.3.2, §5.3.3 (via RFC 6750 §3.1)  
   UserInfo SHOULD support CORS. Errors follow RFC 6750 §3, where invalid_request is a 400, but /userinfo (L512-515, L562-565) has no 400. §5.3.2 allows a response that is encrypted without being signed, while the application/jwt text (L506-511, L556-561) mentions only userinfo_signed_response_alg.  
   *Suggested change:* Add a 400 response, a note on Access-Control-Allow-Origin, and reword application/jwt as 'signed, encrypted, or signed then encrypted (Nested JWT) per the client registration'.  
   *Verifier: confirmed.*

19. **[LOW] Gap: JWKS cache headers for key rotation**  
   *Reference:* OIDC Core §10.1.1, §10.2.1  
   The jwks_uri response SHOULD include Cache-Control with max-age, and kid is needed when the set holds several keys. /jwks 200 (L586-598) declares no headers.  
   *Suggested change:* Add headers.Cache-Control (example 'public, max-age=3600') to paths./jwks.get.responses.200, plus a note on key rotation.  
   *Verifier: confirmed.*

20. **[LOW] Gap: address and phone scopes; scope-to-claims mapping**  
   *Reference:* OIDC Core §5.4  
   securitySchemes.oauth2 scopes (L2696-2700) lack address and phone. Scope (L732-748) does not say which claims each scope releases, or that with response_type=id_token those claims go into the ID Token.  
   *Suggested change:* Add the address and phone scopes and a scope→claims table to Scope.description.  
   *Verifier: confirmed.*

21. **[LOW] Gap: Behaviour when response_mode is unsupported**  
   *Reference:* OIDC Core §3.1.2.6  
   An unsupported response_mode gets HTTP 400 without error parameters, because the AS cannot know how to return them. The /authorize 400 (L196-205) lists only bad redirect_uri and client_id.  
   *Suggested change:* Add unsupported response_mode to the 400 description.  
   *Verifier: confirmed.*

22. **[LOW] Gap: ID Token JOSE rules and standard claims inside the ID Token**  
   *Reference:* OIDC Core §2, §5.4, §16.14  
   ID Tokens MUST be JWS-signed. alg none is allowed only when no ID Token comes from the authorization endpoint and the client registered none. An encrypted ID Token MUST be signed first and then encrypted (Nested JWT), and x5u/x5c/jku/jwk headers SHOULD NOT be used. With response_type=id_token the scope claims travel in the ID Token. TokenResponse.id_token (L1443-1448) is a plain string, and IDTokenClaims does not mention the standard claims.  
   *Suggested change:* $ref JWT from TokenResponse.id_token, add these rules to its description, and note in IDTokenClaims that §5.1 claims MAY appear.  
   *Verifier: confirmed.*

23. **[LOW] Gap: Client-hosted request_uri; claims_locales at PAR**  
   *Reference:* OIDC Core §6.2, §6.2.3, §15.1, §15.2  
   RequestUri (L857-868) deliberately models only PAR-issued URNs. OIDC §6.2 request_uri (https unless the object is signed so the OP can verify it, SHOULD be ≤512 characters, fetched by the AS with GET) is mandatory only for Dynamic OPs. PARRequest (L1583-1647) also omits claims_locales, which every OP must support (§15.1).  
   *Suggested change:* State the deviation and its effect on Dynamic-OP conformance (see the Discovery finding on request_uri_parameter_supported), and add claims_locales: {type: string} to PARRequest.  
   *Verifier: confirmed.*

24. **[LOW] Incorrect: L690-697 components.parameters.ResponseType.description**  
   *Reference:* OIDC Core §3 (response_type table), §3.2.2.1, §3.3.2.1  
   'OIDC Core §3.1.2.1 also defines id_token and code id_token for OIDC Hybrid Flow' is inaccurate. §3.1.2.1 covers the Code Flow, which uses only code. id_token is the Implicit Flow value (§3.2.2.1) and 'code id_token' is a Hybrid Flow value (§3.3.2.1). Both are registered by OAuth.Responses §3/§5.  
   *Suggested change:* Cite §3.2.2.1/§3.3.2.1 and OAuth.Responses. Note that OAuth 2.1 §10.1 says removing response_type=token does not affect id_token.  
   *Verifier: confirmed.*

25. **[LOW] Incorrect: L2502-2509 components.schemas.IDTokenClaims.properties.azp.description**  
   *Reference:* OIDC Core §2 (azp), §3.1.3.7 steps 4-5 (errata set 2)  
   Gives the old rule ('Needed only when the ID Token has a SINGLE audience that differs...'). Errata set 2, which is the vendored text, replaced it: azp appears only when extensions are used, and implementations that do not use such extensions are encouraged not to emit it and to ignore it. Validation steps 4-5 changed to match.  
   *Suggested change:* Replace the text with the errata-2 wording.  
   *Verifier: confirmed.*

26. **[LOW] Incorrect: L2380-2382 components.schemas.UserInfoResponse.properties.birthdate (format: date)**  
   *Reference:* OIDC Core §5.1 (birthdate)  
   §5.1 allows a year on its own (YYYY) and the year 0000, meaning the year is withheld. format: date (RFC 3339 full-date) rejects '1980' wherever format validation is turned on.  
   *Suggested change:* Use pattern '^(\d{4}|\d{4}-\d{2}-\d{2})$' and describe the YYYY and 0000-MM-DD forms, instead of format: date.  
   *Verifier: confirmed.*

27. **[LOW] Incorrect: L2434-2441 components.schemas.JWT pattern, used by /userinfo application/jwt (L503-505, L553-555)**  
   *Reference:* OIDC Core §5.3.2, §10.2; OIDC Discovery §3  
   The pattern requires every segment to be non-empty. That rejects a JWE whose Encrypted Key segment is empty (alg dir, which OIDC allows with keys derived from client_secret) and an unsecured UserInfo JWT, whose signature segment is empty (Discovery allows none in userinfo_signing_alg_values_supported).  
   *Suggested change:* Relax to '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*(\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+)?$', or state that this profile excludes those forms.  
   *Verifier: confirmed.*

28. **[LOW] Incorrect: L541-545 paths./userinfo.post requestBody access_token.description**  
   *Reference:* OIDC Core §5.3.1; RFC 6750 §2.2  
   Credits OIDC Core §5.3.1 with 'SHOULD NOT be used unless the Authorization header is unavailable'. That SHOULD NOT comes from RFC 6750 §2.2. OIDC §5.3.1 only RECOMMENDS GET with the Authorization header.  
   *Suggested change:* Fix the citation.  
   *Verifier: confirmed.*

29. **[LOW] Gap: The prompt values' required behaviours are not documented** — *found by the verifier*  
   *Reference:* OIDC Core §3.1.2.1 (prompt), §3.1.2.3, §15.1  
   The prompt values' required behaviours are not documented. prompt=none must not show UI and must fail with an error; login, consent and select_account each map to a specific error. ErrorResponse lists these codes but nothing ties them to prompt.  
   *Suggested change:* Add a value-to-behaviour-to-error table to the Prompt description and cross-reference it from the ErrorResponse OIDC codes.

30. **[LOW] Gap: The YAML does not state where the OP must not return errors** — *found by the verifier*  
   *Reference:* OIDC Core §3.1.2.1 (ui_locales), §5.2 (claims_locales), §5.5, §5.5.1, §3.1.2.2 step 5, §15.1  
   The YAML does not state where the OP must not return errors. Unsupported ui_locales or claims_locales, unreturned requested claims, and an unsupported claims parameter are not errors, and an expired id_token_hint should still be accepted for a current or recent session.  
   *Suggested change:* Add these tolerance rules to the four parameter descriptions.

31. **[LOW] Incorrect: The /authorize description says only response_type=code is permitted under OAuth 2.1, which contradicts the YAML's own enum (id_token, 'code id_token')** — *found by the verifier*  
   *Reference:* OAuth 2.1 draft-16 §10.1, §4.1.1; OIDC Core §3.2.2.1, §3.3.2.1  
   The /authorize description says only response_type=code is permitted under OAuth 2.1, which contradicts the YAML's own enum (id_token, 'code id_token'). The ResponseType text also misreads OAuth 2.1 §10.1. The first agent flagged neither statement as wrong; its fix for L690-697 only touches L691 indirectly.  
   *Suggested change:* Reword both: 'OAuth 2.1 removes response_type=token; extension response types such as id_token and code id_token (OIDC) remain allowed', or drop those values if the profile is meant to be Code-only.

32. **[LOW] Gap: Request Object rules diverge between OIDC and JAR without documentation** — *found by the verifier*  
   *Reference:* OIDC Core §6.1, §6.2, §6.3.1-§6.3.2; OIDC Discovery §3 (request_object_signing_alg_values_supported); RFC 9101 §5  
   Request Object rules diverge between OIDC and JAR without documentation. OIDC allows unsigned (alg none) and encrypted-only Request Objects, and Discovery says servers SHOULD support none. The YAML follows RFC 9101 (signed only) without saying so. It also omits the MUST NOT on nested request/request_uri and does not tie the not-supported errors to the discovery flags.  
   *Suggested change:* State that the profile deliberately rejects unsigned and encrypted-only Request Objects (JAR and RFC 9700 posture, deviating from the OIDC/Discovery SHOULD). Add the 'no nested request/request_uri' rule, and tie the request_not_supported and request_uri_not_supported errors to the two discovery flags.

33. **[LOW] Gap: UserInfo claim-value rules are missing** — *found by the verifier*  
   *Reference:* OIDC Core §5.3.2, §5.1 (phone_number_verified)  
   UserInfo claim-value rules are missing. An unavailable claim should be omitted rather than sent as null or an empty string, and phone_number must be E.164 when phone_number_verified is true.  
   *Suggested change:* Add both rules to the UserInfoResponse description (and to the phone_number and phone_number_verified properties).

34. **[LOW] Gap: client_secret entropy and length rules for symmetric algorithms are missing (client_secret_jwt, HS* ID Tokens, client_secret-derived encryption keys).** — *found by the verifier*  
   *Reference:* OIDC Core §16.19, §10.1, §10.2  
   client_secret entropy and length rules for symmetric algorithms are missing (client_secret_jwt, HS* ID Tokens, client_secret-derived encryption keys).  
   *Suggested change:* Add the 32-octet minimum for HS256 (scaling with the algorithm) to the client_secret description and note the public-client prohibition.

## oidc-discovery-1.0 OpenID Connect Discovery 1.0 incorporating errata set 2

*February 2014 (errata set 1: November 2014; errata set 2: December 2023) · OpenID Foundation Final Specification (errata set 2, 15 Dec 2023); ISO/IEC 26132:2024 · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** Discovery explains how a relying party finds an OpenID Provider and learns its configuration. Finding the provider can optionally use WebFinger with rel http://openid.net/specs/connect/1.0/issuer. The configuration is a JSON document fetched from {issuer}/.well-known/openid-configuration. It lists the endpoints (authorization, token, userinfo, jwks_uri, registration) and the capabilities: response types and modes, subject types, signing and encryption algorithms, claims, display and locale values, and request-object support. RFC 8414 later generalized the same model to plain OAuth servers, and both share one IANA metadata registry.

**Why it was created.** Without discovery every RP hard-coded each provider's URLs, keys and features. That made multi-provider and multi-tenant integration, key rotation and dynamic registration brittle. A machine-readable document anchored to the issuer also lets RPs check that the issuer equals the URL prefix they used and the iss claim in ID Tokens, which blocks impersonation by look-alike configurations.

<details><summary>Already modeled in the YAML (7)</summary>

- GET /.well-known/openid-configuration → 200 application/json OpenIDProviderMetadata (L603-625)
- components.schemas.OpenIDProviderMetadata (L1907-1921) = allOf OAuthServerMetadata plus the OIDC REQUIRED set (authorization_endpoint, token_endpoint, jwks_uri, subject_types_supported, id_token_signing_alg_values_supported), with the base requiring issuer and response_types_supported (L1937-1940)
- Endpoints: issuer, with https / no query or fragment / iss-equality described (L1944-1950); authorization_endpoint (L1951); token_endpoint (L1954); userinfo_endpoint, RECOMMENDED (L1957-1960); jwks_uri (L1961-1964); registration_endpoint (L1965-1968)
- Capabilities: scopes_supported (L2016); response_types_supported with the Dynamic-OP note (L2019-2026); response_modes_supported with its default (L2027-2032); grant_types_supported with its default (L2033-2036); acr_values_supported (L2149); subject_types_supported, public|pairwise (L2116-2121)
- Crypto: id_token_signing_alg_values_supported with the RS256 note (L2082-2085); id_token_encryption_alg/enc (L2086-2091); userinfo_signing_alg and encryption_alg/enc (L2094-2102); request_object_signing_alg and encryption_alg/enc (L2105-2113); token_endpoint_auth_methods_supported with its default (L2037-2049); token_endpoint_auth_signing_alg_values_supported (L2050-2056)
- Claims/UI: display_values_supported (L2141-2145); claim_types_supported with default normal (L2126-2131); claims_supported (L2122-2125); claims_locales_supported (L2132-2134); ui_locales_supported (L2146-2148); claims_parameter_supported (L2135-2138); request_parameter_supported (L2154-2157); request_uri_parameter_supported (L2158-2161); require_request_uri_registration (L2162-2165); service_documentation, op_policy_uri, op_tos_uri (L2251-2259)
- Openness: additionalProperties: true (L1936); metadata from other OIDF specs (L1985-1996, L2219-2248)

</details>

**Follow-up on the May-2026 validation notes.** The May-2026 notes contain 45 items; 38 are fixed, 1 partly fixed and 6 open.
- MISSING (28): 26 fixed; all the absent metadata members were added between L2050 and L2262. 2 open: the issuer-path append rule, and Cache-Control on discovery. The second one does not hold up: Discovery §4.2 does not require it; caching guidance exists only for jwks_uri (OIDC Core §10.2.1).
- WRONG (11): 8 fixed: the OIDC required set, userinfo RECOMMENDED, the three defaults, the response_types note, the code_challenge attribution, and jwks https. 1 partly fixed: issuer https is described in prose only. 2 open: the token_endpoint conditional note and the subject_types meanings.
- NICE-TO-HAVE (6): 4 fixed: the split schema, the claims parameter, and the display/claim_types enums. 2 open: an example body and the well-known path explanation.

**Notes.** WebFinger (§2), the validation rules (§4.3) and string comparison (§5) are mostly RP-side concerns. Every Discovery-registered metadata name is present (IANA AS-metadata diff). Because the openid-configuration response reuses OAuthServerMetadata, the minItems and closed-enum findings also apply to the RFC 8414 endpoint.

### Findings (0 high · 3 medium · 10 low)

1. **[MEDIUM] Gap: CORS on endpoints that clients call directly**  
   *Reference:* OIDC Discovery §3 (last paragraph), §4  
   The token, UserInfo, jwks_uri, registration and openid-configuration endpoints SHOULD support CORS, while CORS at the authorization endpoint is NOT RECOMMENDED. No operation documents Access-Control-* headers or the preflight request.  
   *Suggested change:* Add components.headers.AccessControlAllowOrigin, reference it on the 200/4xx responses of discovery, /jwks, /token and /userinfo, and state in the /authorize description that CORS is NOT RECOMMENDED there.  
   *Verifier: confirmed.*

2. **[MEDIUM] Incorrect: L1813-1820 components.schemas.JWKS and L1822-1902 JWK (incl. k at L1900-1902), served by paths./jwks.get 200 (L586-598)**  
   *Reference:* OIDC Discovery §3 (jwks_uri)  
   The OP's JWK Set 'MUST NOT contain private or symmetric key values', and 'use' is REQUIRED on every key when both signing and encryption keys are published. The /jwks schema explicitly documents the symmetric member k, lets private members (d, p, q, dp, dq, qi, oth) through additionalProperties: true, and never requires use.  
   *Suggested change:* Serve a PublicJWKS/PublicJWK schema from /jwks: not: {anyOf: [{required: [d]}, {required: [k]}, {required: [p]}, {required: [q]}, {required: [dp]}, {required: [dq]}, {required: [qi]}, {required: [oth]}]}, kty other than oct, plus the conditional use rule.  
   *Verifier: confirmed.*

3. **[MEDIUM] Incorrect: L2158-2165 OAuthServerMetadata.request_uri_parameter_supported ('(OIDC Core §6, RFC 9126 PAR)', default true) and require_request_uri_registration**  
   *Reference:* OIDC Discovery §3; RFC 9126 §5; OIDC Core §6.2  
   These flags describe client-hosted Request Objects (OIDC Core §6.2). RFC 9126 §5 says a PAR request_uri works 'regardless of ... request_uri_parameter_supported or require_request_uri_registration'. Because the default is true, a PAR-only AS built from this profile (RequestUri L857-868) that omits the member advertises client-hosted request_uri support it does not implement.  
   *Suggested change:* Describe the flag as covering client-hosted request_uri only, independent of PAR, and tell PAR-only deployments to publish request_uri_parameter_supported: false.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Arrays with zero elements MUST be omitted**  
   *Reference:* OIDC Discovery §4.2  
   'Claims with zero elements MUST be omitted from the response.' None of the roughly 30 array members (e.g., scopes_supported L2016-2018, claims_supported L2122-2125) has minItems, so a generated server may emit [].  
   *Suggested change:* Add minItems: 1 to every array-valued metadata member, or define a reusable NonEmptyStringArray schema.  
   *Verifier: confirmed.*

5. **[LOW] Gap: Discovery URL for an issuer with a path (append rule)**  
   *Reference:* OIDC Discovery §4, §4.1, §4.3  
   The URL is the issuer (trailing / removed) followed by /.well-known/openid-configuration, e.g., /issuer1/.well-known/openid-configuration. RFC 8414 instead inserts the well-known segment between host and path. servers.variables.issuer (L80-86) describes a hostname and the path is anchored at the root (L603). Still open from the prior audit.  
   *Suggested change:* Document the OIDC append rule versus the RFC 8414 insert rule in the operation and in the server variable.  
   *Verifier: confirmed.*

6. **[LOW] Gap: WebFinger issuer discovery**  
   *Reference:* OIDC Discovery §2  
   Optional: GET /.well-known/webfinger?resource=...&rel=http://openid.net/specs/connect/1.0/issuer returns a JRD whose links[].href is the issuer (https, no query or fragment). The endpoint SHOULD support CORS. The IANA well-known diff lists webfinger as absent.  
   *Suggested change:* Optionally add paths./.well-known/webfinger.get → 200 application/jrd+json {subject, links:[{rel, href}]}, or declare it out of scope.  
   *Verifier: confirmed.*

7. **[LOW] Gap: Value constraints not encoded in the schema**  
   *Reference:* OIDC Discovery §3  
   issuer, the endpoints and jwks_uri MUST use https, and issuer has no query or fragment. id_token_signing_alg_values_supported MUST include RS256. token_endpoint_auth_signing_alg_values_supported MUST NOT include none. The openid scope MUST be supported. These rules are stated in prose (L1947-1950, L2085) but not enforced.  
   *Suggested change:* In OpenIDProviderMetadata add issuer pattern '^https://[^?#]+$', '^https://' patterns on the URLs, contains {const: RS256}, and not {contains: {const: none}} on the token endpoint signing algorithms.  
   *Verifier: confirmed.*

8. **[LOW] Gap: Closed enums on extensible metadata**  
   *Reference:* OIDC Discovery §3 (token_endpoint_auth_methods_supported: 'Other authentication methods MAY be defined by extensions')  
   response_modes_supported (L2028-2031), token_endpoint_auth_methods_supported (L2038-2048) and display_values_supported (L2142-2145) are closed enums, so extension values cannot be advertised.  
   *Suggested change:* Use examples, or an open string, with the known values listed in the description.  
   *Verifier: confirmed.*

9. **[LOW] Gap: Error responses and example document**  
   *Reference:* OIDC Discovery §4.2  
   'An error response uses the applicable HTTP status code value.' Only 200 is modeled and there is no example body. Still open from the prior audit.  
   *Suggested change:* Add default/404 responses and the §4.2 example.  
   *Verifier: confirmed.*

10. **[LOW] Gap: Descriptions of subject_types_supported and token_endpoint**  
   *Reference:* OIDC Discovery §3; OIDC Core §8  
   There is no explanation of public versus pairwise (L2116-2121). token_endpoint is REQUIRED 'unless only the Implicit Flow is used', but the YAML requires it unconditionally (L1918) without noting that. Both are open from the prior audit.  
   *Suggested change:* Add the §8 meanings and the conditional-requirement note.  
   *Verifier: confirmed.*

11. **[LOW] Incorrect: L608-615 paths./.well-known/openid-configuration.get.description**  
   *Reference:* OIDC Discovery §4; OIDC Core §15.2  
   Says the document is 'published by every OpenID Connect provider'. Discovery is optional and mandatory only for Dynamic OPs; §4 applies to 'OpenID Providers supporting Discovery'.  
   *Suggested change:* Reword to 'published by OPs that support Discovery (mandatory for Dynamic OPs)'.  
   *Verifier: confirmed.*

12. **[LOW] Incorrect: L636-638 paths./.well-known/oauth-authorization-server.get.description**  
   *Reference:* OIDC Discovery §3, §8.2; RFC 8414 §2  
   Calls the RFC 8414 document 'a strict subset of the OIDC discovery document'. RFC 8414 defines members that OIDC Discovery §3 does not (revocation, introspection, code_challenge_methods_supported, etc.). Both share one IANA registry and have different required sets.  
   *Suggested change:* Say 'same metadata vocabulary (shared IANA registry), fewer REQUIRED members'.  
   *Verifier: confirmed.*

13. **[LOW] Gap: JWKs that carry x5c must still include the bare key values, and Dynamic OPs must publish bare keys; the JWK schema says neither.** — *found by the verifier*  
   *Reference:* OIDC Discovery §3 (jwks_uri); OIDC Core §15.2  
   JWKs that carry x5c must still include the bare key values, and Dynamic OPs must publish bare keys; the JWK schema says neither.  
   *Suggested change:* Add the rule to JWK.x5c. In the proposed PublicJWK schema, require n and e for RSA and crv and x (plus y for EC) for EC/OKP.

## oauth-v2-form-post-response-mode-1.0 OAuth 2.0 Form Post Response Mode

*April 2015 · OpenID Foundation Final Specification (27 Apr 2015); ISO/IEC 26139:2024 · YAML coverage: **partial** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** Defines response_mode=form_post. Instead of redirecting with the response in the URL query or fragment, the authorization server returns an HTML page with a self-submitting form. The form POSTs the authorization response parameters (application/x-www-form-urlencoded) to the client's redirect URI. The server must tell the browser and any intermediaries not to store or reuse that page.

**Why it was created.** Response values in URLs leak through browser history, Referer headers, logs and proxies, and server-side code cannot read a fragment. Form post keeps codes and ID Tokens out of URLs while still delivering them through the browser. RFC 9700 §4.2.4 and §4.3 list it as a countermeasure.

<details><summary>Already modeled in the YAML (2)</summary>

- form_post value in components.parameters.ResponseMode enum (L846-855) and OAuthServerMetadata.response_modes_supported (L2027-2032)
- A generic /authorize 200 text/html response (L190-195), described only as the consent/login page

</details>

**Notes.** The vendored file is byte-identical to openid.net. RFC 9700 cites it as [OAuth.Post].

### Findings (0 high · 1 medium · 2 low)

1. **[MEDIUM] Gap: form_post response: auto-submitting HTML page with no-store**  
   *Reference:* Form Post §2, Appendix A  
   With form_post the AS returns 200 text/html. The form's action MUST be the redirect URI and its method MUST be POST, and it carries every response parameter, success or error. The AS 'MUST instruct the User Agent (and any intermediaries) not to store or reuse the content'; Appendix A shows Cache-Control: no-cache, no-store and Pragma: no-cache. The YAML accepts form_post (L855), but its only 200 (L190-195) is the consent page, with no cache headers. Nothing tells an implementer what the page looks like or that no-store is a MUST.  
   *Suggested change:* Describe two 200 cases under paths./authorize.get.responses.200: the interactive page and the form_post auto-submit page. Add Cache-Control ('no-cache, no-store') and Pragma ($ref PragmaNoCache) headers and a text/html example. Document the client-side form POST, for example as an OpenAPI 3.1 webhooks entry.  
   *Verifier: confirmed.*

2. **[LOW] Gap: Errors and default modes under form_post**  
   *Reference:* Form Post §2, §4; OAuth.Responses §2.2  
   Error responses use the same mode. It is safe to use form_post with response types whose default is query or fragment. Neither point is documented.  
   *Suggested change:* Add both to ResponseMode.description.  
   *Verifier: confirmed.*

3. **[LOW] Gap: Citation and rationale**  
   *Reference:* Form Post §4; RFC 9700 §4.2.4, §4.3.1, §4.3.2  
   The spec is named only inside ResponseMode (L851-852). It is missing from the covered-specifications table (L18-45), and the RFC 9700 reasons for using it are not stated.  
   *Suggested change:* Add the spec to the table and add an externalDocs link with the rationale.  
   *Verifier: confirmed.*

## oauth-v2-multiple-response-types-1.0 OAuth 2.0 Multiple Response Type Encoding Practices

*February 2014 · OpenID Foundation Final Specification (25 Feb 2014); ISO/IEC 26138:2024 · YAML coverage: **partial** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** Defines the response_mode request parameter with the values query and fragment, and says each response_type has a default response mode. It registers the response types id_token and none and the combinations code token, code id_token, id_token token and code id_token token. A multi-valued response type is a space-separated set whose order does not matter. All parameters of one response should use the same mode, and ID Tokens or access tokens must never be put in the query string.

**Why it was created.** RFC 6749 allowed extension and space-separated response types but did not say how to encode a response that mixes codes and tokens, or how a client could ask for a different encoding. OpenID Connect needed response types that carry an id_token, together with consistent encoding rules that keep tokens out of URLs that leak.

<details><summary>Already modeled in the YAML (3)</summary>

- response_mode with query/fragment (components.parameters.ResponseMode L846-855); PARRequest.response_mode as a free string (L1631-1632)
- Response types id_token and 'code id_token' (ResponseType L703-706); token-bearing combinations excluded with a stated reason (L693-696, L2024-2026)
- response_modes_supported default ['query','fragment'] (L2032); state echo (L164-169, ErrorResponse.state L1529-1533)

</details>

**Notes.** Intentional exclusions honoured: code token, id_token token and code id_token token are not reported. The response split between query and fragment at L161-169 is reported under OIDC Core. RFC 9700 cites this document as [OAuth.Responses].

### Findings (1 high · 1 medium · 4 low)

1. **[HIGH] Gap: Query encoding forbidden for response types that carry an id_token**  
   *Reference:* OAuth.Responses §3, §5, §7  
   For id_token and 'code id_token', 'the query encoding MUST NOT be used'. §7 adds that ID Tokens 'MUST NOT be encoded in the query string'. ResponseMode (L855) allows query with any response type, so a generated server would honour response_mode=query&response_type=id_token and leak the ID Token through Referer headers and browser history.  
   *Suggested change:* In AuthorizationRequest/PARRequest: if response_type contains id_token, then response_mode must not be query (and not query.jwt unless the JWT is encrypted). State the rule in ResponseMode.description and reject violations.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Default response mode for each response type**  
   *Reference:* OAuth.Responses §2.1, §3, §4, §5  
   code → query; id_token and 'code id_token' → fragment; none → query. Sending a response_mode equal to the default is NOT RECOMMENDED. The YAML lists values without defaults.  
   *Suggested change:* Add a defaults table to ResponseMode.description and reference it from the 302 description.  
   *Verifier: confirmed.*

3. **[LOW] Gap: none response type**  
   *Reference:* OAuth.Responses §4  
   A registered response type that returns no code, token or ID Token (default mode query). It carries no token, so the OAuth 2.1 exclusion does not cover it. It is absent from the enum; the IANA diff's 'present' result comes from the word none in prompt.  
   *Suggested change:* Add it with its semantics, or declare it outside this profile.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Consistency between PAR and /authorize**  
   *Reference:* OAuth.Responses §2.1  
   PARRequest.response_type (L1596-1597) and response_mode (L1631-1632) are free strings, while /authorize uses enums.  
   *Suggested change:* Make PARRequest reuse the ResponseType and ResponseMode schemas.  
   *Verifier: confirmed.*

5. **[LOW] Gap: Citation**  
   *Reference:* OAuth.Responses §6  
   The YAML never cites the source of response_mode and the multi-valued response types (covered-specifications table L18-45).  
   *Suggested change:* Add the spec to the table and to the externalDocs of ResponseType/ResponseMode.  
   *Verifier: confirmed.*

6. **[LOW] Incorrect: L701-706 components.parameters.ResponseType.schema.enum (code, id_token, 'code id_token')**  
   *Reference:* OAuth.Responses §1.2; RFC 6749 §3.1.1; OAuth 2.1 draft-16 §4.1.1  
   Multi-valued response types are compared as space-separated sets 'in which the order of values does not matter'. The exact-string enum rejects the equivalent 'id_token code', so a valid request gets a 400.  
   *Suggested change:* Add 'id_token code' to the enum (or use a set pattern) and state that response types are compared as unordered sets.  
   *Verifier: confirmed.*

## openid-financial-api-jarm-draft-02 Financial-grade API: JWT Secured Authorization Response Mode for OAuth 2.0 (JARM), Draft-02

*October 2018 · OIDF FAPI WG draft (Draft-02, 17 Oct 2018), superseded by the JARM Final Specification (Nov 2022) and its errata set 1 (Aug 2025); RFC 9700 still cites it as [OpenID.JARM] · YAML coverage: **referenced-only (verifier corrected from partial)** · relevance to an AS: informational · vendoring: already-vendored*

**What it is.** The 2018 FAPI working-group draft of JARM. The authorization response parameters (code, state, error, ...) are wrapped in a signed JWT, optionally also encrypted, that carries iss, aud and exp. The JWT is delivered in a single 'response' parameter through the response modes query.jwt, fragment.jwt, form_post.jwt and jwt. The draft also defines client metadata (authorization_signed_response_alg, ...) and AS metadata (authorization_signing_alg_values_supported, ...).

**Why it was created.** A plain authorization response is an unauthenticated set of URL parameters, open to code injection, authorization-server mix-up and leakage. Signing the response binds it to the issuer and the client audience, and encryption adds confidentiality. The need came from financial-grade (FAPI and open-banking) deployments.

<details><summary>Already modeled in the YAML (2)</summary>

- response_modes_supported enum includes jwt, query.jwt, fragment.jwt, form_post.jwt (L2027-2032)
- A generic compact JWT schema that could carry the response JWT (L2434-2441)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation file exists for this document.

**Notes.** Keep it vendored because RFC 9700 references this exact URL; implementations should follow the Final/errata-1 text. FAPI 1.0 Advanced allows 'code' together with response_mode=jwt (JARM) as an alternative to 'code id_token'.

### Findings (0 high · 3 medium · 1 low)

1. **[MEDIUM] Gap: AS metadata authorization_signing_alg_values_supported / authorization_encryption_alg_values_supported / authorization_encryption_enc_values_supported**  
   *Reference:* JARM Draft-02 §6 (Final §4)  
   The AS SHOULD publish the algorithms it uses for response JWTs. These members are absent, although the JARM response modes are advertised at L2031.  
   *Suggested change:* Add the three arrays next to response_modes_supported (see the Final entry).  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: The 'response' parameter and the JWT response document**  
   *Reference:* JARM Draft-02 §4.1, §4.3.1-§4.3.4  
   The /authorize responses (L160-195) do not describe response=&lt;JWT>, and no schema describes its claims.  
   *Suggested change:* Add a JARMResponseClaims schema and update the 302/200 descriptions, using the Final text.  
   *Verifier: confirmed.*

3. **[MEDIUM] Incorrect: L846-855 components.parameters.ResponseMode enum [query, fragment, form_post] vs L2027-2032 response_modes_supported (adds the jwt modes)**  
   *Reference:* JARM Draft-02 §4.3, §6  
   The AS can advertise the JARM modes, but the request enum rejects them, so a generated server returns 400 to exactly the requests its own metadata invites.  
   *Suggested change:* Use one shared response-mode schema for ResponseMode, PARRequest.response_mode and response_modes_supported.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Which version to reference**  
   *Reference:* JARM Draft-02 (front matter) vs Final (9 Nov 2022) and errata set 1 (17 Aug 2025)  
   The draft lacks rules the Final adds: exp of at most 10 minutes RECOMMENDED, alg none MUST NOT be accepted, and numbers sent as JSON numbers (§4.1.2 shows expires_in as "3600"). Its §4.1.1 error example omits iss, aud and exp, and it includes an example for response type token. The YAML cites no JARM version.  
   *Suggested change:* Cite https://openid.net/specs/oauth-v2-jarm.html (errata set 1) and keep this draft only as RFC 9700's historical reference.  
   *Verifier: partially correct —* The draft already forbids alg none for authorization_signed_response_alg (§5). The Final adds: the explicit client rule to reject alg none (§2.4 step 5); the 10-minute exp recommendation and the JSON-number rule (§2.1); iss, aud and exp in the error example. It also drops the token example. The YAML cites no JARM version. The stable URL of the current text is https://openid.net/specs/oauth-v2-jarm-errata1.html; it is byte-identical today to oauth-v2-jarm.html (sha256 3a829c72) and is the URL IANA cites.

## oauth-v2-jarm-final JWT Secured Authorization Response Mode for OAuth 2.0 (JARM)

*November 2022 (errata set 1: August 2025) · OpenID Foundation Final Specification (9 Nov 2022). 'Incorporating errata set 1' (17 Aug 2025) is now served at https://openid.net/specs/oauth-v2-jarm.html · YAML coverage: **referenced-only (verifier corrected from partial)** · relevance to an AS: optional · vendoring: vendor*

**What it is.** The final version of JARM. Every authorization response parameter, including errors, travels inside a JWT that is signed, or signed and then encrypted (Nested JWT). The JWT carries iss, aud and exp, and an exp of at most 10 minutes is recommended. It is delivered as a single 'response' parameter through query.jwt, fragment.jwt or form_post.jwt; jwt means query.jwt for code and fragment.jwt for other response types. query.jwt is forbidden for responses containing token or id_token unless the JWT is encrypted. Clients reject alg none and check iss, aud and exp before using the content. Errata set 1 changes only editorial text.

**Why it was created.** Same motivation as the draft: integrity, sender authentication and audience restriction for authorization responses, which defends against mix-up and code injection, plus optional confidentiality. It was finalized for FAPI deployments.

<details><summary>Already modeled in the YAML (2)</summary>

- response_modes_supported values query.jwt, fragment.jwt, form_post.jwt, jwt (L2027-2032)
- Compact JWT schema (L2434-2441)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation file exists for this document.

**Notes.** Vendor the errata-1 HTML (oauth-v2-jarm.html, sha256 3a829c72…). It differs from oauth-v2-jarm-final.html (8d08881d…) only editorially. IANA snapshot: JARM's AS-metadata names do not appear in the AS-metadata registry; authorization_signing_alg_values_supported and its siblings are listed only as client metadata, from RP Metadata Choices.

### Findings (0 high · 4 medium · 4 low)

1. **[MEDIUM] Gap: AS metadata authorization_signing_alg_values_supported, authorization_encryption_alg_values_supported, authorization_encryption_enc_values_supported**  
   *Reference:* JARM §4  
   Authorization servers 'SHOULD publish' these. They are absent, although the JARM modes are advertised.  
   *Suggested change:* Add the three members to OAuthServerMetadata as arrays of strings with minItems: 1, noting that alg none is not allowed.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: 'response' authorization-response parameter and JWT payload**  
   *Reference:* JARM §2.1, §2.3.1-§2.3.3  
   The JWT always contains iss (the AS issuer), aud (client_id) and exp, plus all response parameters for the response type, including error, error_description, error_uri and state, and extensions such as session_state. Nothing in the YAML describes it.  
   *Suggested change:* Add schemas.JARMResponseClaims {required: [iss, aud, exp], properties: {code, state, id_token, error, error_description, error_uri, ...}, additionalProperties: true}. Document response=&lt;JWT> in the 302/form responses with examples.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: query.jwt forbidden with token or id_token unless encrypted**  
   *Reference:* JARM §2.3.1  
   Once the JARM modes are accepted (see incorrect), an AS also supporting id_token or 'code id_token' (L705-706) MUST refuse query.jwt for those types when the JWT is not encrypted.  
   *Suggested change:* Add an if/then rule and a note in the shared AuthorizationRequest schema.  
   *Verifier: confirmed.*

4. **[MEDIUM] Incorrect: L846-855 components.parameters.ResponseMode enum vs L2027-2032 OAuthServerMetadata.response_modes_supported enum**  
   *Reference:* JARM §2.3, §4  
   The metadata can advertise jwt, query.jwt, fragment.jwt and form_post.jwt, but the authorization request rejects those values, so JARM cannot be used even when advertised. PARRequest.response_mode (L1631-1632) is unconstrained, which is a third behaviour.  
   *Suggested change:* Define one ResponseModeValue schema and $ref it from all three places.  
   *Verifier: confirmed.*

5. **[LOW] Gap: jwt defaults, lifetime and signing rules**  
   *Reference:* JARM §2.1, §2.2, §2.3.4, §2.4 step 5, §3  
   jwt → query.jwt for code and fragment.jwt for other types; exp of at most 10 minutes RECOMMENDED; signed or signed-then-encrypted; none is never allowed; the default signing algorithm is RS256.  
   *Suggested change:* Put these in ResponseMode.description and in the JARMResponseClaims description.  
   *Verifier: partially correct —* jwt resolves to query.jwt for code, and to fragment.jwt for token and for the OAuth.Responses response types other than none; the default for none is unspecified, not fragment.jwt. The rest of the item is accurate.

6. **[LOW] Gap: form_post.jwt delivery**  
   *Reference:* JARM §2.3.3 (uses the Form Post technique)  
   Delivered as a 200 text/html auto-post page with no-store, the same gap as Form Post §2.  
   *Suggested change:* Cover it in the same 200 form_post response description.  
   *Verifier: confirmed.*

7. **[LOW] Gap: Client metadata authorization_signed_response_alg / authorization_encrypted_response_alg / authorization_encrypted_response_enc**  
   *Reference:* JARM §3  
   Registered at IANA on 2026-08-24 with errata set 1 as the reference; absent from the YAML because there is no client or registration schema.  
   *Suggested change:* Add them when the client-metadata schema arrives (DCR cluster).  
   *Verifier: partially correct —* All three names are absent from the YAML because it has no client schema. IANA registered authorization_signed_response_alg on 2026-08-03 and the two encryption names on 2026-08-24, all with JARM errata set 1 (oauth-v2-jarm-errata1.html) as the reference.

8. **[LOW] Gap: Citation**  
   *Reference:* JARM (front matter)  
   No JARM reference appears in the YAML or in the covered-specifications table.  
   *Suggested change:* Cite https://openid.net/specs/oauth-v2-jarm.html.  
   *Verifier: confirmed.*

## oidc-session-1.0 OpenID Connect Session Management 1.0

*September 2022 · OpenID Foundation Final Specification (12 Sep 2022); ISO/IEC 26135:2024 · YAML coverage: **referenced-only** · relevance to an AS: optional · vendoring: vendor*

**What it is.** Lets an RP watch whether the user is still logged in at the OP without extra network requests. The OP returns a session_state value in each authentication response and publishes check_session_iframe. The RP embeds that OP iframe and keeps posting 'client_id session_state' to it with postMessage. The iframe answers changed, unchanged or error, and on changed the RP re-checks with prompt=none. Section 5.1 warns that browsers blocking third-party storage break this mechanism.

**Why it was created.** Single sign-on also needs logout awareness. RPs had no cheap way to learn that the user had logged out or switched accounts at the OP, and repeating prompt=none requests wastes traffic, especially on mobile.

<details><summary>Already modeled in the YAML (1)</summary>

- check_session_iframe metadata (OAuthServerMetadata.check_session_iframe L1993-1996)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation file exists for this document.

**Notes.** The YAML advertises a feature whose protocol is not modeled.

### Findings (0 high · 1 medium · 3 low)

1. **[MEDIUM] Gap: session_state authorization-response parameter**  
   *Reference:* Session Management §2, §3.2  
   An OP that supports session management MUST return session_state in every successful authentication response and SHOULD in error responses. The value is a string without spaces, a salted hash of client_id, the RP origin and the OP's user-agent state, and it should vary between error responses. It is not modeled; the IANA parameters diff lists session_state as absent, although an AS can advertise check_session_iframe.  
   *Suggested change:* Document session_state (pattern '^[^ ]+$') in the /authorize 302 and form_post descriptions and examples, and in the JARM response claims.  
   *Verifier: confirmed.*

2. **[LOW] Gap: OP iframe endpoint**  
   *Reference:* Session Management §3.2, §3.3, §6  
   The OP serves an HTML page that receives the postMessage, MUST check the caller's origin, recomputes the state, and replies changed, unchanged or error. OpenAPI cannot model postMessage, but the GET page itself is missing.  
   *Suggested change:* Add paths./check_session.get → 200 text/html, with the postMessage protocol and the origin checks in the description, and link it to check_session_iframe.  
   *Verifier: confirmed.*

3. **[LOW] Gap: Metadata description**  
   *Reference:* Session Management §3.3  
   The member is REQUIRED when Session Management and Discovery are both supported, and it MUST use https. Neither appears at L1996.  
   *Suggested change:* Extend the description and add pattern '^https://'.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Third-party storage blocking caveat**  
   *Reference:* Session Management §5.1  
   Blocked third-party storage makes every check return changed, which causes endless re-authentication loops. Back-Channel Logout is not affected.  
   *Suggested change:* Add the caveat and recommend Back-Channel Logout.  
   *Verifier: confirmed.*

## oidc-frontchannel-logout-1.0 OpenID Connect Front-Channel Logout 1.0

*September 2022 · OpenID Foundation Final Specification (12 Sep 2022); ISO/IEC 26136:2024 · YAML coverage: **referenced-only (verifier corrected from partial)** · relevance to an AS: optional · vendoring: vendor*

**What it is.** Logout through the browser. When the user logs out at the OP, the OP renders a page with hidden iframes pointing at each logged-in RP's registered frontchannel_logout_uri, optionally adding iss and sid. Each RP clears its own session. The spec defines OP metadata (frontchannel_logout_supported and frontchannel_logout_session_supported), RP metadata (frontchannel_logout_uri and frontchannel_logout_session_required), and the sid (session ID) claim.

**Why it was created.** Single sign-on without single logout leaves RP sessions alive after the user signs out at the OP, which is risky on shared devices. Front-channel logout lets the OP notify RPs through the browser without the polling iframe that Session Management uses.

<details><summary>Already modeled in the YAML (3)</summary>

- frontchannel_logout_supported (L2220-2222)
- frontchannel_logout_session_supported (L2223-2225)
- IDTokenClaims has additionalProperties: true (L2468), which permits sid without documenting it

</details>

**Follow-up on the May-2026 validation notes.** No prior validation file exists for this document.

**Notes.** The OP-side surface is small: metadata, the sid claim, and rendering the iframes during logout. The receiving URI is on the RP.

### Findings (0 high · 1 medium · 5 low)

1. **[MEDIUM] Gap: sid claim in ID Tokens**  
   *Reference:* Front-Channel Logout §3, §5  
   When frontchannel_logout_session_supported is true, 'the sid Claim is also included in ID Tokens issued by the OP'. sid is an opaque string, unique per issuer, with enough entropy. It is absent from IDTokenClaims (the IANA diff also lists sid as absent).  
   *Suggested change:* Add IDTokenClaims.sid {type: string, description: 'Session ID; present when front- or back-channel *_logout_session_supported is true'}.  
   *Verifier: confirmed.*

2. **[LOW] Gap: OP-rendered logout iframes (frontchannel_logout_uri?iss=&sid=)**  
   *Reference:* Front-Channel Logout §2, §3, §3.1  
   iss and sid go together (both or neither) and are required when the RP registered frontchannel_logout_session_required. The RP's response SHOULD include Cache-Control: no-store. The receiving URI is RP-side, and none of this is documented.  
   *Suggested change:* Describe it in the logout endpoint operation (once added), or as a webhooks entry: GET with iss and sid.  
   *Verifier: confirmed.*

3. **[LOW] Gap: RP registration metadata frontchannel_logout_uri / frontchannel_logout_session_required**  
   *Reference:* Front-Channel Logout §2  
   Absent (IANA client-metadata diff) because there is no client schema.  
   *Suggested change:* Add them with the DCR client schema.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Metadata descriptions and caveat**  
   *Reference:* Front-Channel Logout §3, §4.1  
   L2220-2225 have no descriptions, so the 'sid in ID Tokens' implication is lost. The third-party cookie caveat (§4.1) is also missing.  
   *Suggested change:* Add descriptions and the caveat.  
   *Verifier: confirmed.*

5. **[LOW] Incorrect: L2219 comment '# ---- OIDC Logout 1.0 ----' and L2232-2235 OAuthServerMetadata.http_logout_supported**  
   *Reference:* Front-Channel Logout §3, §6.3  
   No specification called 'OIDC Logout 1.0' exists; these members come from Front-Channel Logout 1.0 and Back-Channel Logout 1.0. http_logout_supported is the name used in the superseded 'HTTP-Based Logout' drafts (draft 04, Sep 2015). Front-Channel draft 01 (Aug 2016) renamed it frontchannel_logout_supported. It is not IANA-registered and appears in no final spec, yet it sits in the canonical schema.  
   *Suggested change:* Replace the comment with separate Front-Channel and Back-Channel headers. Mark http_logout_supported deprecated: true, with the note 'pre-final name of frontchannel_logout_supported, still emitted by some providers', or drop it as vendor-specific.  
   *Verifier: confirmed.*

6. **[LOW] Gap: The registration-time validation rules for logout URIs are missing** — *found by the verifier*  
   *Reference:* Front-Channel Logout §2; Back-Channel Logout §2.2; RP-Initiated Logout §2, §3.1  
   The registration-time validation rules for logout URIs are missing. The first agent lists the metadata names but not the constraints the AS must enforce.  
   *Suggested change:* Add these validations to the client metadata schema when it is introduced (DCR cluster).

## oidc-backchannel-logout-1.0 OpenID Connect Back-Channel Logout 1.0 incorporating errata set 1

*September 2022 (errata set 1: December 2023) · OpenID Foundation Final Specification (errata set 1, 15 Dec 2023); ISO/IEC 26137:2024 · YAML coverage: **referenced-only (verifier corrected from partial)** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** Server-to-server logout. The OP POSTs logout_token=&lt;Logout Token> to each RP's registered backchannel_logout_uri. The Logout Token is a signed JWT, similar to an ID Token, with iss, aud, iat, exp, jti and events {http://schemas.openid.net/event/backchannel-logout: {}}, plus sub and/or sid, and never a nonce. The RP validates it, ends the matching sessions, and answers 200 (or 400). The spec defines OP metadata (backchannel_logout_supported and backchannel_logout_session_supported), RP metadata, the sid claim, and the application/logout+jwt media type (typ logout+jwt).

**Why it was created.** Browser-based logout needs a live user agent and third-party iframes, which browsers increasingly block, and it cannot reach native apps. A signed, direct OP→RP call makes logout reliable.

<details><summary>Already modeled in the YAML (2)</summary>

- backchannel_logout_supported (L2226-2228)
- backchannel_logout_session_supported (L2229-2231)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation file exists for this document.

**Notes.** The Logout Token is compatible with the Security Event Token format (RFC 8417), which is why it has an events claim. The misleading 'OIDC Logout 1.0' label is reported under Front-Channel.

### Findings (0 high · 2 medium · 4 low)

1. **[MEDIUM] Gap: Logout Token claims and header**  
   *Reference:* Back-Channel Logout §2.4, §4, §4.1  
   The OP mints a signed JWT, optionally encrypted with the same keys as ID Tokens. It REQUIRES iss, aud, iat, exp, jti and events, needs sub and/or sid, PROHIBITS nonce, should be typed logout+jwt (RECOMMENDED), and should expire within about 2 minutes (encouraged). No schema exists; events and sid are absent per the IANA diff.  
   *Suggested change:* Add schemas.LogoutTokenClaims {required: [iss, aud, iat, exp, jti, events], properties: {events: {type: object, required: ['http://schemas.openid.net/event/backchannel-logout']}, sid: {type: string}, sub: {type: string, maxLength: 255}}, anyOf: [{required: [sub]}, {required: [sid]}], not: {required: [nonce]}}.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: sid claim in ID Tokens**  
   *Reference:* Back-Channel Logout §2.1  
   When backchannel_logout_session_supported is true, sid is also included in ID Tokens. IDTokenClaims lacks it (same finding as Front-Channel).  
   *Suggested change:* Add IDTokenClaims.sid.  
   *Verifier: confirmed.*

3. **[LOW] Gap: Logout request the OP sends to the RP**  
   *Reference:* Back-Channel Logout §2.5, §2.8  
   A form POST carrying logout_token. The RP answers 200 (the OP should accept 204) or 400 with an optional JSON {error, error_description}, and SHOULD send Cache-Control: no-store. The OP retries only on recoverable failures. The receiver is RP-side, so it is correctly absent from paths, but it is not documented anywhere.  
   *Suggested change:* Add OpenAPI 3.1 webhooks.backchannelLogout.post with requestBody {logout_token: $ref JWT} and responses 200/204/400 ($ref ErrorResponse).  
   *Verifier: confirmed.*

4. **[LOW] Gap: RP registration metadata backchannel_logout_uri / backchannel_logout_session_required**  
   *Reference:* Back-Channel Logout §2.2  
   Absent per the IANA client-metadata diff, because there is no client schema.  
   *Suggested change:* Add them with the DCR client schema.  
   *Verifier: confirmed.*

5. **[LOW] Gap: Media type and metadata descriptions**  
   *Reference:* Back-Channel Logout §2.1, §5.3  
   application/logout+jwt is never mentioned, and L2226-2231 have no descriptions.  
   *Suggested change:* Add the descriptions and reference the media type.  
   *Verifier: confirmed.*

6. **[LOW] Gap: The YAML does not say how refresh tokens are handled when a session is logged out.** — *found by the verifier*  
   *Reference:* Back-Channel Logout §2.7  
   The YAML does not say how refresh tokens are handled when a session is logged out.  
   *Suggested change:* Add a note to the offline_access scope and RefreshTokenRequest descriptions linking the refresh-token lifetime to the OP session and logout.

## oidc-rpinitiated-logout-1.0 OpenID Connect RP-Initiated Logout 1.0

*September 2022 · OpenID Foundation Final Specification (12 Sep 2022); ISO/IEC 26134:2024 · YAML coverage: **referenced-only** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** Defines the OP's Logout Endpoint, advertised as end_session_endpoint. An RP redirects the user there with GET or POST and the parameters id_token_hint, logout_hint, client_id, post_logout_redirect_uri, state and ui_locales. The OP logs the user out, asking for confirmation when needed, notifies the other RPs through the session, front-channel or back-channel mechanisms, and can redirect back to a pre-registered post_logout_redirect_uri with state.

**Why it was created.** Users expect 'log out' in an app to end the single sign-on session too. Every OP used to have its own logout URL and redirect rules, which also invited open redirects and logout-CSRF/denial-of-service.

<details><summary>Already modeled in the YAML (2)</summary>

- end_session_endpoint (OAuthServerMetadata.end_session_endpoint L1989-1992)
- Parameter components that a logout request could reuse: IDTokenHint (L929-937), UILocales (L908-917), State (L750-758)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation file exists for this document.

**Notes.** This endpoint is usually where the OP renders the front-channel iframes and sends the back-channel Logout Tokens.

### Findings (0 high · 1 medium · 2 low)

1. **[MEDIUM] Gap: Logout Endpoint operation (GET and POST)**  
   *Reference:* RP-Initiated Logout §2, §3, §4, §6  
   OPs MUST support GET and POST with the parameters id_token_hint (RECOMMENDED), logout_hint, client_id, post_logout_redirect_uri, state and ui_locales. The OP MUST verify that it issued the id_token_hint, and that client_id matches it when both are present. It SHOULD ask the user to confirm, and MUST when the hint is missing or does not match. It MUST NOT redirect unless the post_logout_redirect_uri exactly matches a registered value, nor without an id_token_hint unless it has another way to verify. It echoes state, and a repeated logout is not an error. The YAML advertises end_session_endpoint but has no path for it.  
   *Suggested change:* Add paths./end_session with get (query) and post (form) sharing an EndSessionRequest schema. Responses: 200 text/html (a confirmation page that may contain the front-channel iframes); 302/303 to post_logout_redirect_uri?state=...; 400 text/html with no redirect. Do not reuse components.parameters.ClientId, which is marked required: true.  
   *Verifier: confirmed.*

2. **[LOW] Gap: post_logout_redirect_uris client metadata**  
   *Reference:* RP-Initiated Logout §3.1  
   This is the registered list that post_logout_redirect_uri must exactly match. It is absent (IANA client-metadata diff).  
   *Suggested change:* Add it with the DCR client schema.  
   *Verifier: confirmed.*

3. **[LOW] Gap: end_session_endpoint description**  
   *Reference:* RP-Initiated Logout §2.1  
   The member is REQUIRED when RP-Initiated Logout and Discovery are both supported, and it MUST use https. L1992 only names the endpoint.  
   *Suggested change:* Extend the description and add pattern '^https://'.  
   *Verifier: confirmed.*

## oidc-ciba-core-1.0 OpenID Connect Client-Initiated Backchannel Authentication Flow - Core 1.0

*September 2021 · OpenID Foundation Final Specification (1 Sep 2021, MODRNA WG) · YAML coverage: **referenced-only** · relevance to an AS: optional · vendoring: vendor*

**What it is.** CIBA lets a client that already knows who the user is start a login without a browser redirect. The client identifies the user with login_hint, login_hint_token or id_token_hint and POSTs to the OP's backchannel_authentication_endpoint. The OP authenticates the user out-of-band on their own device and returns an auth_req_id. The client then gets tokens in one of three ways. Poll: it calls the token endpoint with grant_type urn:openid:params:grant-type:ciba. Ping: it is notified first and then calls the token endpoint. Push: the OP sends the tokens to the client's notification endpoint.

**Why it was created.** Redirect-based flows assume the user sits at the device running the client. Call centres, point-of-sale terminals and bank tellers need the user to authenticate and consent on a separate personal device instead.

<details><summary>Already modeled in the YAML (6)</summary>

- backchannel_authentication_endpoint (L1985-1988)
- backchannel_token_delivery_modes_supported, enum poll|ping|push (L2238-2242)
- backchannel_user_code_parameter_supported, default false (L2243-2245)
- backchannel_authentication_request_signing_alg_values_supported (L2246-2248)
- Token error codes that CIBA reuses (§11), present in ErrorResponse.error: invalid_request, invalid_grant, unauthorized_client, access_denied (L1479-1485), authorization_pending, slow_down, expired_token (L1495-1497)
- grant_types_supported is an open array, so it can list the CIBA grant (L2033-2036)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation file exists for this document.

**Notes.** Only the four AS-metadata names registered at IANA are modeled. The FAPI-CIBA profile builds on this specification.

### Findings (0 high · 3 medium · 5 low)

1. **[MEDIUM] Gap: Backchannel Authentication Endpoint operation**  
   *Reference:* CIBA §7.1, §7.1.1, §7.2, §7.3, §13  
   The client sends a form POST and authenticates like at the token endpoint. Parameters: scope (must include openid); client_notification_token (for ping/push; at most 1024 characters, bearer-token syntax); acr_values; exactly one of login_hint_token, id_token_hint or login_hint; binding_message; user_code; requested_expiry. Alternatively the parameters come only inside a signed request JWT (aud = issuer, iss = client_id, plus exp, iat, nbf, jti). The 200 response is {auth_req_id (characters A-Za-z0-9._- only), expires_in, interval (default 5)}. Errors are 400, 401 or 403 with JSON bodies. The YAML advertises the endpoint but does not model it.  
   *Suggested change:* Add paths./bc-authorize post (tag CIBA) with a CIBAAuthenticationRequest form schema (oneOf for the hint fields, plus a request variant), a 200 CIBAAuthenticationResponse, and 400/401/403 using OAuthError and ClientAuthError. Use the same security as /token, and add a description saying the AS MUST accept its issuer, its token endpoint URL or this endpoint's URL as the client-assertion aud.  
   *Verifier: partially correct —* The endpoint is missing as described. Its description should, however, tell the AS to accept only its own issuer identifier as the client-assertion aud (rfc7523bis-11; CIBA §7.1 already tells clients to SHOULD use it), and should state that this narrows CIBA §7.1's 2021 interoperability rule that the OP must accept the issuer, the token endpoint URL or the Backchannel Authentication Endpoint URL.

2. **[MEDIUM] Gap: CIBA grant in TokenRequest**  
   *Reference:* CIBA §4, §10.1, §10.1.1, §11  
   grant_type=urn:openid:params:grant-type:ciba with auth_req_id. The TokenRequest discriminator (L1163-1171) has no mapping for it, so a generated server rejects CIBA token requests. Push-mode clients MUST get unauthorized_client, and an auth_req_id is single-use.  
   *Suggested change:* Add CIBATokenRequest {grant_type const 'urn:openid:params:grant-type:ciba', auth_req_id} to the oneOf and the mapping, and document the polling errors.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: CIBA-specific error codes**  
   *Reference:* CIBA §12, §13  
   expired_login_hint_token, unknown_user_id, missing_user_code, invalid_user_code, invalid_binding_message and transaction_failed (push error payload) are missing from the closed ErrorResponse.error enum, so a generated server cannot send them.  
   *Suggested change:* Add them under a '# OIDC CIBA §12/§13' comment, or make the enum open.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Ping and Push callbacks to the client notification endpoint**  
   *Reference:* CIBA §9, §10.2, §10.3, §12  
   The OP POSTs JSON with Authorization: Bearer &lt;client_notification_token>. Ping sends {auth_req_id}. Push sends the token response plus auth_req_id, or {error, error_description, auth_req_id}. The client answers 204 (or 200), and the OP must not follow redirects.  
   *Suggested change:* Add webhooks cibaPing and cibaPush.  
   *Verifier: confirmed.*

5. **[LOW] Gap: ID Token claims in push mode**  
   *Reference:* CIBA §10.3.1  
   The OP MUST include at_hash, urn:openid:params:jwt:claim:auth_req_id, and urn:openid:params:jwt:claim:rt_hash when a refresh token is pushed. These are absent from IDTokenClaims.  
   *Suggested change:* Add the claims with a note that they apply only in push mode.  
   *Verifier: confirmed.*

6. **[LOW] Gap: Metadata descriptions**  
   *Reference:* CIBA §4  
   backchannel_token_delivery_modes_supported and backchannel_authentication_endpoint are REQUIRED when CIBA is supported. grant_types_supported includes the CIBA grant for poll and ping. Client authentication at the endpoint uses the token endpoint's methods.  
   *Suggested change:* Add these descriptions.  
   *Verifier: confirmed.*

7. **[LOW] Gap: Client metadata backchannel_token_delivery_mode, backchannel_client_notification_endpoint, backchannel_authentication_request_signing_alg, backchannel_user_code_parameter**  
   *Reference:* CIBA §4  
   There is no client schema, and the IANA snapshot has no entries for these either.  
   *Suggested change:* Add them with the DCR client schema.  
   *Verifier: confirmed.*

8. **[LOW] Gap: Polling semantics**  
   *Reference:* CIBA §10.1  
   Long polling of about 30 seconds; 503 with Retry-After under load; slow_down adds at least 5 seconds; no overlapping requests for the same auth_req_id.  
   *Suggested change:* Add a 503 response with a Retry-After header to /token and a polling note.  
   *Verifier: confirmed.*

## Verifier corrections to the summaries above

- Cluster design suggestion: 'use OpenAPI 3.1 webhooks for calls the OP makes outward: ..., and the form_post POST to the client' is wrong for form_post. The user agent makes that POST from an auto-submitted HTML form (Form Post §2: 'auto-submitted in the User Agent'), and the user agent also makes the front-channel logout GETs. Only Back-Channel Logout and CIBA ping/push are OP-originated calls. Document form_post in the /authorize 200 text/html response instead. The same applies to the suggested change in Form Post gap 1.
- Two suggested fixes would reintroduce the 2025 audience-injection weakness. They are the client_assertion description for OIDC Core §9 ('aud ... SHOULD be the token endpoint URL') and the CIBA endpoint description ('AS MUST accept its issuer, its token endpoint URL or this endpoint's URL'). CVE-2025-27370 (OIDC private_key_jwt) and CVE-2025-27371 (RFC 7521/7523) were announced in the OIDF notice of 25 Feb 2025. draft-ietf-oauth-rfc7523bis-11, now in the RFC Editor queue, requires the AS issuer identifier as the sole aud and requires the AS to reject anything else. OIDF errata for Core and CIBA have not appeared: the live Core is still errata set 2 and CIBA is still the 2021 Final; openid-connect-core-1_0-errata3.html and the CIBA -errata1 URL both return 404. A safe server should document the tightened rule as a deliberate deviation.
- Prior-audit tally for Core: the auth_time bullet asked for notes on both MaxAge and the ID Token schema. Only IDTokenClaims.auth_time (L2491) was added, so the bullet is partly fixed. The corrected tally is 17 fixed, 2 partly fixed (auth_time, issuer https), 21 open and 5 needing no action, still 45 in total.
- JARM: the versioned, stable URL for errata set 1 is https://openid.net/specs/oauth-v2-jarm-errata1.html. It is byte-identical today to oauth-v2-jarm.html (sha256 3a829c72...) and is the URL IANA cites for the JARM client metadata, so vendor and cite it rather than the oauth-v2-jarm.html alias, which can change. The agent's facts-item-9 correction (17 Aug 2025 date, editorial-only changes: introspection replaced by authorization in IANA descriptions, RFC 9700 references, affiliations) was verified by diff.
- JARM Final summary: 'jwt means query.jwt for code and fragment.jwt for other response types' is imprecise. Per §2.3.4, fragment.jwt applies to token and the OAuth.Responses response types except none; the default for none is unspecified.
- JARM client-metadata IANA date: authorization_signed_response_alg was registered on 2026-08-03; only authorization_encrypted_response_alg and _enc carry 2026-08-24.
- The coverage-by-document line ('Front-Channel and Back-Channel Logout: partially covered (metadata only...)') is inconsistent with Session Management, RP-Initiated Logout and CIBA, which are rated referenced-only for the same metadata-only state. JARM likewise has only its mode names (see coverage_level_corrections).
- The cluster note says 'the YAML also uses metadata from ... JARM Final'. The JARM response-mode values in L2031 are equally defined by the vendored Draft-02 (§4.3, §6), so the Final is not needed to explain them. Vendoring the Final (errata 1) is still advisable as the normative text.
- ISO dates: Michael B. Jones announced the ISO/IEC 26131-26139:2024 publications on 1 Oct 2024, but the Standards Council of Canada lists ISO/IEC 26131:2024 as published on 2024-09-30. Say 'published September/October 2024 (announced 1 Oct 2024)'. The agent's number-to-spec mapping is correct (26131 Core ... 26139 Form Post).
