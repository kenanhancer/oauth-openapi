# JWT access tokens & SD-JWT — RFC 9068, 9901, SD-JWT VC, Token Status List

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 9068](#rfc-9068-json-web-token-jwt-profile-for-oauth-20-access-tokens) | October 2021 | Proposed Standard | partial (verifier corrected from mostly) | 1 | 4 | 9 |
| [RFC 9901](#rfc-9901-selective-disclosure-for-json-web-tokens-sd-jwt) | November 2025 | Proposed Standard | not-applicable | 0 | 0 | 3 |
| [draft-ietf-oauth-sd-jwt-vc-19](#draft-ietf-oauth-sd-jwt-vc-19-sd-jwt-based-verifiable-digital-credentials-sd-jwt-vc) | August 2026 | Internet-Draft -19 (intended Proposed Standard; IESG state: Waiting for AD Go-Ahead) | none | 0 | 0 | 4 |
| [draft-ietf-oauth-status-list-21](#draft-ietf-oauth-status-list-21-token-status-list-tsl) | June 2026 | Internet-Draft -21 (intended Proposed Standard; in RFC Editor queue) | none | 0 | 0 | 6 |

**Cluster notes.** Of the four documents, only RFC 9068 places obligations on a plain OAuth 2.1 authorization server. The YAML covers its claim set well: JWTAccessTokenClaims (2514-2573) has the exact §2.2 required list. Three areas are thin. The §2.1 header and algorithm rules are missing. So are the §3 rules for deriving aud. And the §4 resource-server validation rules are absent, which is the most important gap (rated high) because the AS's own /userinfo is a resource server. The fixes made after the May-2026 audit introduced three new defects: sub is now 'MUST equal client_id', groups/roles/entitlements are typed as string arrays, and the JWT example lacks iat and jti.

RFC 9901 (SD-JWT) and SD-JWT VC belong to the issuer-holder-verifier (wallet) model and add no endpoint to an OAuth AS. An AS that wants to issue SD-JWT VCs does so through OpenID for Verifiable Credential Issuance 1.0 (OIDF Final, 16 Sep 2025, credential format 'dc+sd-jwt'). Its AS-side additions, such as the pre-authorized_code grant and credential-issuer metadata, are outside this cluster.

Token Status List (-21, RFC Editor queue) is directly useful to an AS that issues RFC 9068 JWT access tokens: it is the standard way to make self-contained tokens revocable. IANA already registered its values on 2026-06-12: the status, status_list and ttl JWT claims, the JWT Status Mechanisms registry, the OAuth Status Types registry, and the AS metadata status_list_aggregation_endpoint.

IANA cross-check:
- RFC 9068's groups/roles/entitlements are present in the YAML (2559-2567).
- RFC 9901's _sd, ..., _sd_alg and sd_hash are absent, which is expected.
- TSL's status_list_aggregation_endpoint, status_list, ttl, the status_list mechanism and all status types are absent.
- The IANA absence check marks the 'status' claim as present, but that is a false positive: the YAML only says 'status codes' at lines 172 and 183.
- SD-JWT VC values (vct, vct#integrity, aka_vcts, application/dc+sd-jwt, jwt-vc-issuer) are not yet registered (datatracker: IANA Not OK).

RFC 9068 has one Reported (unverified) erratum, 8802 (2026-03-04), proposing that iss become OPTIONAL. It confuses RFC 7519's general optionality with this profile's requirement, so keep iss REQUIRED.

Practical notes:
- JWTAccessTokenClaims and other decoded-payload schemas are intentionally unreferenced documentation schemas (.spectral.yaml downgrades oas3-unused-component).
- Any new schema or path must be added to SCHEMA_GROUP/PATH_FILE in oauth-openapi-modular/split-oauth-openapi.py (lines 37-66), or the split's asserts (lines 109, 111) fail.
- The prior RFC 9068 validation note contains several wrong RFC claims; do not carry them forward:
  - it says asymmetric signing is a MUST (it is RECOMMENDED);
  - it adds an auth_time-on-max_age MUST (that is OIDC Core's ID Token rule);
  - it lists nbf in §2.2 (it is not there);
  - it describes a 'seven-step' §4 algorithm with scope and jti checks (§4 has neither).

## RFC 9068 JSON Web Token (JWT) Profile for OAuth 2.0 Access Tokens

*October 2021 · Proposed Standard · YAML coverage: **partial (verifier corrected from mostly)** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 9068 defines one interoperable way to issue an OAuth 2.0 access token as a signed JWT. The JOSE header carries typ 'at+jwt'. The payload must contain iss, exp, aud, sub, client_id, iat and jti, and may add auth_time/acr/amr, identity claims and authorization claims (scope, groups, roles, entitlements). It explains how aud follows from the resource and scope request parameters, and gives resource servers a mandatory local validation recipe (typ, iss, aud, signature with alg not 'none', exp), answering failures with 'invalid_token'. The profile is optional — opaque tokens checked by introspection remain valid — but if an AS emits JWT access tokens, this is the standard shape.

**Why it was created.** RFC 6749 deliberately left the access-token format open. By 2019 most commercial authorization servers issued JWT access tokens with incompatible, vendor-specific claim layouts, so every resource server needed vendor-specific validation code. RFC 9068 standardized the common claim set and validation rules, built from sample tokens several vendors contributed. Its explicit 'at+jwt' typing also closes a real attack: an OpenID Connect ID Token (same issuer, same signing keys, similar claims) being replayed to an API as if it were an access token (JWT confusion, RFC 8725 §2.8).

<details><summary>Already modeled in the YAML (23)</summary>

- info.description covered-specs table row for RFC 9068 (33)
- components.schemas.JWTAccessTokenClaims (2514-2573): decoded §2.2 payload, intentionally an unreferenced documentation schema
- JWTAccessTokenClaims.required [iss, exp, aud, sub, client_id, iat, jti] (2521): exactly the §2.2 REQUIRED set
- JWTAccessTokenClaims additionalProperties: true (2522): allows §2.2.2 identity claims and private claims
- iss as StringOrURI (2524-2526)
- exp as NumericDate (2527-2528)
- aud as a string or array of StringOrURI (2529-2535)
- sub (2536-2540); its description is wrong, see incorrect
- client_id (2541-2543)
- iat as NumericDate (2544-2545)
- jti (2546-2548)
- auth_time, acr, amr (2549-2555): §2.2.1
- scope as a space-delimited string (2556-2558): §2.2.3
- groups, roles, entitlements (2559-2567): §2.2.3.1/§7.2; their typing is wrong, see incorrect
- cnf -> Confirmation (2568-2573, 2575-2591): an RFC 7800/9449/8705 extension claim used in JWT access tokens
- typ 'at+jwt' stated in the JWTAccessTokenClaims description (2517) and the securitySchemes.bearerAuth description (2644)
- TokenResponse.access_token (1411-1419): description points to RFC 9068 and JWTAccessTokenClaims; the JWT example header decodes to {alg: RS256, typ: at+jwt}
- securitySchemes.bearerAuth (2637-2646): token is opaque or a JWT; bearerFormat deliberately omitted
- OAuthServerMetadata.issuer 'MUST be byte-identical to tokens iss' (1944-1950) and jwks_uri (1961-1964): the §4 key and issuer discovery
- /jwks (573-598), /.well-known/oauth-authorization-server (630-648) and /.well-known/openid-configuration (603-625): the §4 publication methods
- resource parameter: parameters.Resource at /authorize (880-895, used at 148) and the ResourceIndicators mixin (1203-1219) on every token request (1242, 1272, 1292, 1313, 1331, 1353): the §3 input for aud
- invalid_token: ErrorResponse.error enum (1490), WWWAuthenticateBearerDPoP examples (1023-1024), ProtectedResourceError (1091-1107) used by /userinfo (512-515, 562-565): §4 error handling
- invalid_scope in the ErrorResponse.error enum (1484): the §3 rejection when scopes map to different default resources

</details>

**Follow-up on the May-2026 validation notes.** The prior note (audit 2026-05-10) had 27 items: 16 MISSING, 4 WRONG and 7 NICE-TO-HAVE.

Fixed (16): JWTAccessTokenClaims was added with the full §2.2 REQUIRED set, auth_time/acr/amr, and scope/groups/roles/entitlements. typ at+jwt is documented. The token response has a JWT-shaped example. bearerFormat: JWT was dropped. A dedicated schema replaced reuse of IntrospectionResponse. jti has a description.

Partial (2): only 'signed JWT' is stated, with no alg-not-none or RS256 rule; at+jwt on access_token appears only inside the example header.

Open (7):
- §4 resource-server validation steps (the most important; now rated high)
- identity-claims pointer (§2.2.2)
- a discovery note that JWT access tokens are verified via jwks_uri and issuer
- a decoded example on the schema
- aud cross-references to RFC 8707 and §3/§5
- aud-validation guidance on bearerAuth
- the access_token_signing_alg idea. That is not an IANA-registered field, and the YAML now wrongly implies such 'signing alg arrays' exist (2518).

Not applicable / wrong premise (2): nbf is not part of RFC 9068 §2.2, and token_type_values_supported does not exist.

The fixes also introduced new defects: sub 'MUST equal client_id' (2539-2540), groups/roles/entitlements typed string[] (2559-2567), and an example payload without iat/jti (1419).

The prior file itself misstates the RFC in places: asymmetric signing is a §2.1 RECOMMENDATION, not a MUST; the 'auth_time MUST when max_age' rule is OIDC Core's, not §2.2.1; and §4 has no scope or jti-replay steps.

**Notes.** Errata: one Reported, unverified technical erratum (8802, 2026-03-04) asks to make iss OPTIONAL. Reject it mentally: a profile may require claims RFC 7519 leaves optional. YAML 2521 is right.

OAuth 2.1 draft-16 cites RFC 9068 only as an example structured token format (§1.4, §1.4.2, §1.7.1, §5, §5.2, §7.1.2, Appendix D), so JWT access tokens stay optional for OAuth 2.1.

Claims from other specs that commonly appear in JWT access tokens but are not on JWTAccessTokenClaims (they belong to other clusters; additionalProperties already tolerates them):
- authorization_details (RFC 9396 §9.1, RECOMMENDED for JWT access tokens)
- act / may_act (RFC 8693 §4.1, §4.4)
- status (Token Status List §6.1)

Apply edits to oauth-openapi.yaml and regenerate oauth-openapi-modular with split-oauth-openapi.py.

### Findings (1 high · 4 medium · 9 low)

1. **[HIGH] Gap: How a resource server validates a JWT access token (typ, decrypt, iss, aud, signature/alg, exp, invalid_token)**  
   *Reference:* RFC 9068 §4 (and §5)  
   The YAML's only validation guidance is 'validated locally against jwks_uri' (securitySchemes.bearerAuth, 2644-2645) and 'verifying the signature against the JWKS' (/introspect description, 323-324). §4 requires the resource server to do six things (MUST unless noted): (1) Accept only typ 'at+jwt' or 'application/at+jwt' and reject every other value. Compare case-insensitively (RFC 7515 §4.1.9); RFC 9068's own Figure 2 writes 'at+JWT'. (2) Decrypt a JWE-wrapped token (SHOULD reject an unencrypted token if encryption was negotiated). (3) Require iss to exactly equal the AS issuer. (4) Require aud to contain its own resource indicator. (5) Verify the JWS with the header alg, using only keys the AS published, and reject alg 'none'. (6) Require the current time to be before exp (a few minutes of leeway is allowed). Any failure must be answered per RFC 6750 §3.1 with error 'invalid_token'. The AS's own /userinfo (481-568, secured by bearerAuth/dpop) is such a resource server. With signature-only checks it would accept an OIDC ID Token (same issuer, same keys) as an access token. That confusion is exactly what §5 says explicit typing exists to prevent.  
   *Suggested change:* Append a numbered 'JWT access token validation (RFC 9068 §4)' list with the six checks to securitySchemes.bearerAuth.description (2640-2646). End it with: 'on failure respond 401 with WWW-Authenticate: Bearer error="invalid_token" (components.responses.ProtectedResourceError)'. In /introspect (323-324), replace 'verifying the signature against the JWKS' with 'performing the RFC 9068 §4 checks (see bearerAuth)'. Add to /userinfo (486-490): 'If access tokens are RFC 9068 JWTs, apply the bearerAuth validation steps, in particular the typ=at+jwt check, so ID Tokens are rejected.'  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: JOSE header and algorithm rules (typ at+jwt / application/at+jwt, alg not 'none', RS256 mandatory to implement) and the application/at+jwt media type**  
   *Reference:* RFC 9068 §2.1, §4, §7.1  
   There is no JOSE-header schema for JWT access tokens. The media type application/at+jwt is never mentioned; only the short typ value appears (2517, 2644, and encoded in the example at 1419). Missing MUST-level rules from §2.1: - JWT access tokens MUST be signed and MUST NOT use alg 'none'. - Both AS and RS MUST include RS256 among their supported algorithms. The YAML's only RS256 MUST is for ID Tokens (2085). - typ MUST carry the application/at+jwt media type, and SHOULD use the short form 'at+jwt'. Also missing: asymmetric signing is RECOMMENDED (§2.1, §4).  
   *Suggested change:* Add a documentation-only components.schemas.JWTAccessTokenHeader next to JWTAccessTokenClaims: {type: object, required: [typ, alg], additionalProperties: true, properties: {typ: {type: string, examples: ['at+jwt'], description: 'Media type application/at+jwt (MUST); the short form at+jwt SHOULD be sent; resource servers accept at+jwt or application/at+jwt case-insensitively (RFC 9068 §2.1, §4, §7.1).'}, alg: {type: string, not: {const: none}, examples: [RS256, PS256, ES256], description: 'MUST NOT be none; asymmetric RECOMMENDED; AS and RS MUST support RS256 (RFC 9068 §2.1).'}, kid: {type: string, description: 'Key from the AS jwks_uri set.'}}}. Reference it from the JWTAccessTokenClaims description. Add 'JWTAccessTokenHeader' to SCHEMA_GROUP['claims'] in oauth-openapi-modular/split-oauth-openapi.py (line 51), or the split's unmapped-schema assert (line 109) fails.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: Deriving aud from resource and scope: default resource indicator, ambiguity, distinct audiences**  
   *Reference:* RFC 9068 §3, §5  
   None of parameters.Resource (880-895), ResourceIndicators.resource (1206-1219) or JWTAccessTokenClaims.aud (2529-2530, 'Resource server identifier(s).') says how aud is derived. §3 rules: - If the request has a resource parameter, aud SHOULD equal it. - If it does not, the AS MUST put a default resource indicator in aud, and SHOULD infer it from scope. - If the requested scopes map to different default resources, the AS SHOULD reject with invalid_scope (RFC 6749 §4.1.2.1). - The AS MUST NOT issue a JWT access token whose granted authorization would be ambiguous. §5 adds: the AS MUST use a distinct aud value for each distinct resource (cross-JWT confusion, RFC 8725 §2.8). The needed error codes already exist (invalid_scope 1484, invalid_target 1499).  
   *Suggested change:* Rewrite JWTAccessTokenClaims.aud.description (2530): 'REQUIRED. Resource indicator(s) of the intended resource server(s), not the client_id (contrast IDTokenClaims.aud). If the request carried resource (RFC 8707), aud SHOULD equal it. Otherwise the AS MUST use a default resource indicator (SHOULD be inferred from scope; reject with invalid_scope if the scopes imply different defaults). Each distinct resource MUST get a distinct aud value, and the AS must never issue a token whose authorization is ambiguous (RFC 9068 §3, §5).' Add a one-line 'becomes the JWT access token aud (RFC 9068 §3)' note to parameters.Resource (884-888) and ResourceIndicators.resource (1209-1215).  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: Clients must treat the access token as opaque**  
   *Reference:* RFC 9068 §6  
   TokenResponse.access_token (1413-1416) and JWTAccessTokenClaims (2516-2519, '`TokenResponse.access_token` will be one of these') point readers to the decoded JWT shape. That includes client developers generating SDKs from this file. Nowhere does the YAML say the client MUST NOT inspect the access token. The AS and RS may switch formats at any time (for example to opaque tokens), and client logic that reads the token would then break.  
   *Suggested change:* Add to both descriptions: 'Clients MUST treat access_token as opaque and MUST NOT inspect or depend on its content (RFC 9068 §6). JWTAccessTokenClaims documents what the authorization and resource servers see.'  
   *Verifier: confirmed.*

5. **[MEDIUM] Incorrect: 2536-2540 components.schemas.JWTAccessTokenClaims.properties.sub (description)**  
   *Reference:* RFC 9068 §2.2, §5; RFC 9700 §4.15-4.15.1  
   The description says '...for `client_credentials` grant this MUST equal `client_id`'. RFC 9068 §2.2 only says SHOULD. With a resource owner, sub SHOULD be the resource owner's subject identifier. Without one (client_credentials), sub SHOULD be 'an identifier the authorization server uses to indicate the client application', which need not be client_id. §5 and RFC 9700 §4.15 warn that if sub is the client_id, a client that can choose its own client_id can impersonate a user. Where client and user identifiers share a namespace, RFC 9700 §4.15.1 requires the AS to give resource servers another way to tell the two token kinds apart. Writing 'MUST equal client_id' turns a SHOULD into a MUST and steers implementers toward the risky design.  
   *Suggested change:* Replace the description with: 'REQUIRED (RFC 9068 §2.2). With a resource owner (e.g. authorization_code): SHOULD be the resource owner's subject identifier. Without one (client_credentials): SHOULD be an identifier the AS uses for the client application. If client_id is reused as sub, the AS must not let clients choose their client_id (RFC 9068 §5). Where client and user identifiers share a namespace, the AS MUST give resource servers another way to distinguish the two (RFC 9700 §4.15.1).'  
   *Verifier: confirmed.*

6. **[LOW] Gap: scope claim rules**  
   *Reference:* RFC 9068 §2.2.3  
   JWTAccessTokenClaims.scope (2556-2558) says only 'OAuth scopes granted (space-delimited).' §2.2.3 adds two rules. When the authorization request included scope, the token SHOULD carry a scope claim (RFC 8693 §4.2 syntax). Every scope string in it MUST have meaning for the resource(s) in aud.  
   *Suggested change:* description: 'Space-delimited scopes (RFC 8693 §4.2). SHOULD be present when the request included scope. Every value MUST be meaningful for the resource(s) in aud (RFC 9068 §2.2.3; see §5 on ambiguity).'  
   *Verifier: confirmed.*

7. **[LOW] Gap: Authentication claims auth_time / acr / amr: descriptions and stability across derived tokens**  
   *Reference:* RFC 9068 §2.2.1  
   auth_time (2549-2550), acr (2551-2552) and amr (2553-2555) have no descriptions; their IDTokenClaims counterparts do (2489-2501). Per §2.2.1 they are OPTIONAL and their semantics come from OIDC Core §2. They are issued only for grants that involve the resource owner. Their values are fixed for every access token derived from the same authorization response, including tokens obtained by refresh or by RFC 8693 token exchange.  
   *Suggested change:* Add descriptions. For auth_time: 'OPTIONAL (RFC 9068 §2.2.1; OIDC Core §2). Time the end-user authenticated for the original authorization response; stays the same in tokens later obtained by refresh or token exchange.' Use similar text for acr, and for amr (values from the RFC 8176 registry).  
   *Verifier: confirmed.*

8. **[LOW] Gap: Identity claims guidance**  
   *Reference:* RFC 9068 §2.2.2  
   Only additionalProperties: true (2522) hints that identity claims may appear. §2.2.2 says three things: - Identity attributes SHOULD use their IANA JWT-registry claim names, which include the OIDC Core §5.1 standard claims. - Other attributes need collision-resistant names unless the tokens stay within a private subsystem. - Clients have no way to request claims in an access token; the AS chooses them from client_id, scope and resource.  
   *Suggested change:* Append to the JWTAccessTokenClaims description: 'Additional claims (RFC 9068 §2.2.2): identity attributes SHOULD use IANA-registered names, e.g. the OIDC standard claims in UserInfoResponse; private names must be collision-resistant (RFC 7519 §4.2-4.3). Clients cannot request access-token claims; the AS chooses them from client_id, scope and resource.'  
   *Verifier: confirmed.*

9. **[LOW] Gap: Consistent metadata across both discovery documents; keys shared between ID tokens and access tokens**  
   *Reference:* RFC 9068 §4, §5  
   The YAML publishes both /.well-known/openid-configuration (603-625) and /.well-known/oauth-authorization-server (630-648). Its only statement relating them is that the RFC 8414 response 'is a strict subset' of the OIDC document (636-638), which is about shape, not values. §4 says that if an AS supports both, their values MUST be consistent. §4-5 also mean a resource server accepts a JWT access token signed by any key in jwks_uri, so using separate keys for ID Tokens and access tokens is not a security boundary. The prior audit's open item 'discovery should say how JWT access tokens are verified' also lands here.  
   *Suggested change:* Add to the /.well-known/oauth-authorization-server description: 'If /.well-known/openid-configuration is also served, every shared value (issuer, jwks_uri, endpoints) MUST be identical (RFC 9068 §4). JWT access tokens are verified with keys from jwks_uri and the issuer value.' Add to the /jwks description (578-582): 'Resource servers accept JWT access tokens signed by any key in this set, so separate keys for ID Tokens and access tokens are not a security boundary (RFC 9068 §4-5).'  
   *Verifier: confirmed.*

10. **[LOW] Incorrect: 2559-2567 components.schemas.JWTAccessTokenClaims.properties.groups / roles / entitlements**  
   *Reference:* RFC 9068 §2.2.3.1 (RFC 7643 §4.1.2, §8.2, §8.7.1)  
   All three are typed `type: array, items: {type: string}`. RFC 9068 §2.2.3.1 says the AS SHOULD use the RFC 7643 User attributes and SHOULD encode their values 'according to the guidance defined in [RFC7643]', pointing to the groups example in RFC 7643 §8.2. RFC 7643 defines these as multi-valued complex attributes, with sub-attributes value, display, type and primary, plus $ref for groups (§4.1.2, §8.2, §8.7.1). An example is [{"value":"e9e30dba...","$ref":".../Groups/e9e30dba...","display":"Tour Guides"}]. A token that follows the RFC's recommended encoding fails this schema, and generated types are string[] only.  
   *Suggested change:* Add components.schemas.SCIMMultiValuedAttribute {type: object, additionalProperties: true, properties: {value: {type: string}, display: {type: string}, type: {type: string}, primary: {type: boolean}}}. RFC 7643's '$ref' sub-attribute passes through additionalProperties; do not declare a property literally named $ref, because many OpenAPI tools treat that key as a reference. Set groups, roles and entitlements to items: {oneOf: [{type: string}, {$ref: '#/components/schemas/SCIMMultiValuedAttribute'}]}. Note that RFC 7643 objects are the RECOMMENDED encoding and plain strings are common practice. Map the new schema in split-oauth-openapi.py SCHEMA_GROUP.  
   *Verifier: confirmed.*

11. **[LOW] Incorrect: 1419 components.schemas.TokenResponse.properties.access_token.examples[1]**  
   *Reference:* RFC 9068 §2.2 (cf. Figure 2)  
   The example's header decodes to {"alg":"RS256","typ":"at+jwt"}, but its payload decodes to {"iss":"https://as.example.com","exp":1735693200,"aud":"https://api.example.com","sub":"user-123","client_id":"abc123"}. It lacks the REQUIRED iat and jti (RFC 9068 §2.2). So the YAML's only JWT access-token example violates the profile and the YAML's own JWTAccessTokenClaims.required (2521).  
   *Suggested change:* Regenerate the example from the header {"typ":"at+jwt","alg":"RS256","kid":"RjEwOwOA"} and a payload modelled on RFC 9068 Figure 2 (iss, sub, aud, exp, iat, jti, client_id, scope). Also add the decoded header and payload as `examples` on JWTAccessTokenClaims, so readers need not base64-decode.  
   *Verifier: confirmed.*

12. **[LOW] Incorrect: 2516-2519 components.schemas.JWTAccessTokenClaims.description**  
   *Reference:* RFC 9068 §4, §6  
   It says JWT access tokens are '(advertised via signing alg arrays in discovery)'. No such metadata exists. RFC 9068 defines none; RFC 8414 and IANA register no access-token signing-alg field, and the YAML has none either. §4 says the AS advertises only its keys (jwks_uri) and issuer, may sign with any advertised key, and 'does not provide a mechanism for identifying a specific key as the one used to sign JWT access tokens'. The same sentence says TokenResponse.access_token 'will be one of these', which reads as an invitation for clients to decode it, contrary to §6.  
   *Suggested change:* Replace the sentence with: 'RFC 9068 defines no metadata announcing that access tokens are JWTs. Resource servers get verification keys from jwks_uri and the expected iss from issuer (RFC 9068 §4). The payload below is what the resource server sees; clients MUST treat the token as opaque (§6).'  
   *Verifier: confirmed.*

13. **[LOW] Gap: RFC 9068 §4 says an AS SHOULD use RFC 8414 metadata to publish its signing keys (jwks_uri) and the expected iss (issuer) for JWT access tokens** — *found by the verifier*  
   *Reference:* RFC 9068 §4  
   RFC 9068 §4 says an AS SHOULD use RFC 8414 metadata to publish its signing keys (jwks_uri) and the expected iss (issuer) for JWT access tokens. The YAML instead says jwks_uri is OPTIONAL and needed only for OIDC, with no caveat for an AS that issues RFC 9068 tokens. Gap 8 addresses only consistency between the two discovery documents, not this SHOULD-publish rule.  
   *Suggested change:* Append to OAuthServerMetadata.jwks_uri.description: 'SHOULD be published by an AS that issues RFC 9068 JWT access tokens; resource servers use it together with `issuer` to validate them (RFC 9068 §4).'

14. **[LOW] Gap: The YAML has no RFC 9068 §6 privacy guidance and never mentions encrypted JWT access tokens** — *found by the verifier*  
   *Reference:* RFC 9068 §6 (and §4 decrypt bullet)  
   The YAML has no RFC 9068 §6 privacy guidance and never mentions encrypted JWT access tokens. JWTAccessTokenClaims says 'Wire form is a signed JWT' and invites identity claims through additionalProperties. Per §6, clients and end users can read an unencrypted token, so the AS needs to take explicit steps when that is a privacy problem: encrypt the token, encrypt or omit sensitive claims, or use opaque tokens. §6 also says sub should follow a privacy impact assessment, for example distinct sub values per resource server to prevent correlation. The first agent covered only the client MUST NOT inspect rule (gap 4) and the RS decrypt step (gap 1).  
   *Suggested change:* Add to JWTAccessTokenClaims.description: 'A JWT access token MAY additionally be encrypted (JWE wrapping the signed JWT) when claim confidentiality matters. Without encryption, every claim is visible to the client (RFC 9068 §6). Choose sub values per a privacy assessment, e.g. per-resource-server subjects to prevent correlation.'

## RFC 9901 Selective Disclosure for JSON Web Tokens (SD-JWT)

*November 2025 · Proposed Standard · YAML coverage: **not-applicable** · relevance to an AS: optional · vendoring: already-vendored*

**What it is.** SD-JWT lets an issuer sign a JWT in which chosen claims are replaced by salted digests (SHA-256 by default), listed under '_sd' or as {'...': digest} array entries. The matching cleartext values travel separately as base64url 'Disclosures' appended with '~' separators, so the holder can later reveal only what a verifier needs. Optional Key Binding appends a holder-signed KB-JWT (typ 'kb+jwt', with iat, aud, nonce and sd_hash) proving the presenter controls the key in the SD-JWT's cnf claim. It is a data format plus a verification algorithm, with media types application/sd-jwt, application/sd-jwt+json and application/kb+jwt; it defines no HTTP endpoints.

**Why it was created.** A normal signed JWT is all-or-nothing: whoever presents it reveals every claim. In the issuer-holder-verifier model (digital identity wallets), data minimization requires that a holder can show a verifier, say, only an age-over-18 claim, while the verifier can still check the issuer's signature. Salted hashes give selective disclosure with ordinary JOSE tooling, and Key Binding stops a leaked or forwarded credential from being replayed by someone else.

<details><summary>Already modeled in the YAML (2)</summary>

- (indirect) Confirmation.jwk (2587-2589): the cnf method RFC 9901 §4.1.2 suggests for Key Binding
- (indirect) JWKS / JWK schemas (1813-1903) and /jwks (573-598): the key-publication format §9.8 RECOMMENDS for issuer keys

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist: RFC 9901 was vendored on 2026-06-06 without an rfc-validation file (references/rfc-sources/README.md).

**Notes.** No errata (rfc-editor.org errata search, 2026-10-10). The IANA absence list confirms that _sd, '...', _sd_alg and sd_hash are absent from the YAML, which is expected for an OAuth AS. If the server ever issues SD-JWTs, the MUSTs that matter are:
- §4.1: signed, alg not none, no duplicate digests
- §4.1.1: must support sha-256
- §4.2.1 / §9.3: unique, cryptographically random salts (128 bits RECOMMENDED)
- §9.7: iss, aud, exp, nbf and cnf should not be selectively disclosable
- §10.3: JWE SHOULD be used when an SD-JWT travels in a URL
The §8 unprotected header members 'disclosures' and 'kb_jwt' are not registered as JOSE header parameters.

### Findings (0 high · 0 medium · 3 low)

1. **[LOW] Gap: Compact SD-JWT / SD-JWT+KB primitive and media types (application/sd-jwt, application/sd-jwt+json, application/kb+jwt)**  
   *Reference:* RFC 9901 §4, §4.3, §8, §11.2  
   The YAML's only token primitive, components.schemas.JWT (2434-2441), has a pattern for 3- or 5-segment JOSE compact serialization. An SD-JWT ('&lt;issuer-signed JWT>~&lt;Disclosure>~...~[&lt;KB-JWT>]') fails it. No OAuth AS endpoint carries SD-JWTs, so this matters only if the server later transports them, for example as an OpenID4VCI credential issuer or as a token-exchange subject_token.  
   *Suggested change:* When needed, add components.schemas.SDJWT: {type: string, description: 'SD-JWT or SD-JWT+KB in compact form (RFC 9901 §4); media type application/sd-jwt. A non-empty last component is a KB-JWT (typ kb+jwt, media type application/kb+jwt). The JWS JSON form (§8) is application/sd-jwt+json, with unprotected header members disclosures and kb_jwt.', pattern: '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+~(?:[A-Za-z0-9_-]+~)*(?:[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+)?$'}. The pattern is derived from the §4 ABNF. Map the schema in split-oauth-openapi.py.  
   *Verifier: confirmed.*

2. **[LOW] Gap: No record that RFC 9901 was considered and has no AS surface**  
   *Reference:* RFC 9901 §1-§3  
   RFC 9901 is vendored (references/rfc-sources/rfc9901.txt; listed in references/rfc-sources/README.md line 51). Yet the YAML never mentions it (0 hits for 9901, sd-jwt, _sd, kb+jwt), and there is no references/rfc-validation file for it. A reader cannot tell whether it was evaluated or forgotten.  
   *Suggested change:* After the covered-spec table in info.description (16-46), add a table 'Related specifications with no authorization-server HTTP surface'. List RFC 9901, SD-JWT VC and Token Status List, each with one line on why. Also add references/rfc-validation/9901-sd-jwt.md recording 'token format only; no AS endpoint'.  
   *Verifier: partially correct —* The repo does record that RFC 9901 was vendored on 2026-06-06 and not yet audited (rfc-sources/README.md 56-59), so a reader can tell it is pending rather than forgotten. What is missing is a recorded conclusion ('token format only; no AS endpoint') in the YAML or in an rfc-validation note.

3. **[LOW] Gap: cnf jwk confirmation method used for Key Binding**  
   *Reference:* RFC 9901 §4.1.2 (RFC 7800 §3.2)  
   Confirmation.jwk (2587-2589) is a bare `type: object` described as 'Embedded JWK; rarely used.' RFC 9901 §4.1.2 suggests cnf.jwk for binding an SD-JWT to the holder key, and SD-JWT VC §2.2.2.3 RECOMMENDS it. Typing it as a JWK gives real validation and generated types.  
   *Suggested change:* Change it to jwk: {$ref: '#/components/schemas/JWK', description: 'Public key by value (RFC 7800 §3.2). Suggested Key Binding method for SD-JWT (RFC 9901 §4.1.2).'}. Keep jkt and x5t#S256 as the methods for DPoP- and mTLS-bound access tokens.  
   *Verifier: confirmed.*

## draft-ietf-oauth-sd-jwt-vc-19 SD-JWT-based Verifiable Digital Credentials (SD-JWT VC)

*August 2026 · Internet-Draft -19 (intended Proposed Standard; IESG state: Waiting for AD Go-Ahead) · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** SD-JWT VC turns RFC 9901 into a format for verifiable digital credentials, such as a digital ID or diploma held in a wallet. The issuer-signed JWT uses typ 'dc+sd-jwt' (media type application/dc+sd-jwt) and must carry a 'vct' credential-type identifier, optionally with 'aka_vcts' and 'vct#integrity'. Registered claims such as iss, nbf, exp, cnf, vct and status must never be selectively disclosable. Verifiers find the issuer's key either through JWT VC Issuer Metadata at /.well-known/jwt-vc-issuer (issuer plus jwks_uri or jwks) or through an x5c certificate chain, and may fetch optional Type Metadata for display and claim rules. It is the credential format that OpenID for Verifiable Credential Issuance 1.0 issues as 'dc+sd-jwt'.

**Why it was created.** RFC 9901 supplies the selective-disclosure mechanism but no credential semantics. Wallet ecosystems, notably the EU Digital Identity Wallet, needed a simple JSON/JWT credential format as an alternative to JSON-LD W3C Verifiable Credentials and CBOR ISO mdoc. It needed a type system, issuer-key discovery, a status/revocation hook and display metadata, so that issuers, wallets and verifiers from different vendors interoperate.

<details><summary>Already modeled in the YAML (3)</summary>

- (indirect) components.schemas.JWKS (1813-1820) and JWK (1822-1903): reusable for the issuer-metadata 'jwks' member
- (indirect) /jwks (573-598): could be the target of the issuer metadata's jwks_uri if the AS also issues SD-JWT VCs
- (indirect) Confirmation.jwk (2587-2589): the cnf method §2.2.2.3 RECOMMENDS

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist; the draft was never audited or vendored.

**Notes.** As of 2026-10-10, -19 (31 Aug 2026) is at the IESG ('Waiting for AD Go-Ahead'). The IANA review is 'Not OK', so vct, vct#integrity, aka_vcts, application/dc+sd-jwt and jwt-vc-issuer are not yet registered.

-19 removed the transitional acceptance of the old typ 'vc+sd-jwt' (renamed to dc+sd-jwt in November 2024).

The AS-facing issuance protocol is OpenID4VCI 1.0 (OIDF Final, 16 Sep 2025, format 'dc+sd-jwt'), which is outside this cluster.

If this is co-hosted with an AS, read §7.1 (SSRF on iss- and vct-derived URLs) and §8.3 (issuer phone-home via holder-specific issuer identifiers).

Recommend vendoring once it becomes an RFC, and only if credential issuance enters scope.

### Findings (0 high · 0 medium · 4 low)

1. **[LOW] Gap: JWT VC Issuer Metadata endpoint: GET /.well-known/jwt-vc-issuer{issuer-path} returning application/json {issuer, jwks_uri | jwks}**  
   *Reference:* draft-ietf-oauth-sd-jwt-vc-19 §4, §4.1, §4.2, §4.3, §9.3  
   Absent: the YAML's only well-known documents are those of RFC 8414, OIDC Discovery and RFC 9728 (603-675). This is needed only if the server also issues SD-JWT VCs with an HTTPS iss. The rules: - The metadata MUST be served at /.well-known/jwt-vc-issuer, inserted between the host and the path of iss (a trailing '/' is removed). - It is fetched with GET and returned as application/json. - issuer is REQUIRED and must be identical to iss; otherwise the metadata MUST NOT be used. - Exactly one of jwks_uri or jwks must be present. - A kid in the SD-JWT header is RECOMMENDED. The well-known suffix is not yet IANA-registered.  
   *Suggested change:* Add a path '/.well-known/jwt-vc-issuer' (tag Discovery, marked draft): get -> '200': content application/json: schema $ref JWTVCIssuerMetadata. Add components.schemas.JWTVCIssuerMetadata: {type: object, required: [issuer], additionalProperties: true, properties: {issuer: {type: string, format: uri}, jwks_uri: {type: string, format: uri}, jwks: {$ref: '#/components/schemas/JWKS'}}, oneOf: [{required: [jwks_uri], not: {required: [jwks]}}, {required: [jwks], not: {required: [jwks_uri]}}]}. In the description, note that issuers with a path use /.well-known/jwt-vc-issuer/&lt;path> (as in RFC 8414 §3.1), and that jwks_uri may point at this server's /jwks. Register the path and schema in split-oauth-openapi.py.  
   *Verifier: confirmed.*

2. **[LOW] Gap: Credential shape: typ dc+sd-jwt, media type application/dc+sd-jwt, claims vct (REQUIRED), vct#integrity, aka_vcts, cnf, status, and which registered claims must not be disclosable**  
   *Reference:* draft-ietf-oauth-sd-jwt-vc-19 §2.1, §2.2.1, §2.2.2.1-§2.2.2.5, §6, §9.1, §9.2  
   No schema documents the credential. The key rules: - typ MUST be dc+sd-jwt. - vct is REQUIRED: a case-sensitive Collision-Resistant Name. - aka_vcts is a non-empty array that must not contain the vct value. - vct#integrity is a W3C SRI integrity string. - cnf is REQUIRED when Key Binding is supported (jwk RECOMMENDED). - iss, nbf, exp, cnf, vct, vct#integrity, aka_vcts and status (including their sub-claims) MUST NOT be selectively disclosed; sub and iat MAY be. - There is no _sd claim when nothing is selectively disclosable. - A Status List Token referenced from an SD-JWT VC MUST be in JWT format.  
   *Suggested change:* Only if credential issuance is added: create a documentation-only components.schemas.SDJWTVCClaims {type: object, required: [vct], additionalProperties: true, properties: {vct: {type: string}, 'vct#integrity': {type: string}, aka_vcts: {type: array, minItems: 1, items: {type: string}}, iss: {$ref: StringOrURI}, nbf: {$ref: NumericDate}, exp: {$ref: NumericDate}, iat: {$ref: NumericDate}, sub: {type: string}, cnf: {$ref: Confirmation}, status: {$ref: StatusClaim}}}. Its description should list the typ header, the media type and the non-disclosable-claim rule. Keep it unreferenced, like JWTAccessTokenClaims.  
   *Verifier: confirmed.*

3. **[LOW] Gap: HTTP serving rules for published documents (caching, nosniff, CSP)**  
   *Reference:* draft-ietf-oauth-sd-jwt-vc-19 §3, §7.2  
   These apply to documents an issuer serves (JWT VC Issuer Metadata, Type Metadata, rendering resources). They must be served over HTTPS only. Issuers and publishers SHOULD send an explicit freshness lifetime such as Cache-Control: max-age (§3). They SHOULD also send X-Content-Type-Options: nosniff and a restrictive Content-Security-Policy, e.g. default-src 'none' (§7.2). The existing CacheControlNoStore header component (990) is the opposite policy and must not be reused here.  
   *Suggested change:* On the 200 response of the new /.well-known/jwt-vc-issuer path, add three headers as new components.headers: Cache-Control (string, example 'max-age=3600'), X-Content-Type-Options (const 'nosniff') and Content-Security-Policy (example "default-src 'none'").  
   *Verifier: confirmed.*

4. **[LOW] Gap: SD-JWT VC Type Metadata document**  
   *Reference:* draft-ietf-oauth-sd-jwt-vc-19 §5.2, §5.3.1, §6  
   This matters only if the server also publishes credential types. Type Metadata is a JSON object: vct is REQUIRED; name, description, extends, extends#integrity, display[] and claims[] are optional. It is fetched with GET from the HTTPS vct URL as application/json, and integrity-checked when vct#integrity is present. This is not an authorization-server function.  
   *Suggested change:* No change for an OAuth 2.1 AS. If types are hosted later, add a documentation-only TypeMetadata schema and an example GET path, preferably in a separate credential-issuer OpenAPI document.  
   *Verifier: confirmed.*

## draft-ietf-oauth-status-list-21 Token Status List (TSL)

*June 2026 · Internet-Draft -21 (intended Proposed Standard; in RFC Editor queue) · YAML coverage: **none** · relevance to an AS: optional · vendoring: vendor*

**What it is.** Token Status List defines a compact, signed and cacheable bit array (1, 2, 4 or 8 bits per token, ZLIB-compressed, base64url-encoded). It is delivered at an HTTPS URL as a Status List Token, which is either a JWT with typ 'statuslist+jwt' or a CWT. A revocable token carries a claim status: {status_list: {idx, uri}}. A relying party fetches the list with GET (application/statuslist+jwt), verifies it, and reads the value at idx: 0x00 VALID, 0x01 INVALID, 0x02 SUSPENDED, or an application-specific value. The draft also registers the AS metadata 'status_list_aggregation_endpoint' and new IANA registries for status mechanisms and status types.

**Why it was created.** Self-contained tokens (JWT access tokens, SD-JWT VCs, mdocs) cannot be recalled after issuance. Certificate revocation lists scale poorly. OCSP-style per-token queries, and OAuth token introspection, make the verifier contact the issuer for every token and let the issuer see every use. Packing many statuses into one compressed list gives scalability, offline caching and 'herd privacy'. The draft explicitly names managing the status of OAuth access tokens as a use case, alongside wallet credentials.

<details><summary>Already modeled in the YAML (4)</summary>

- (indirect) components.schemas.JWT (2434-2441): the compact-JWS primitive also fits a Status List Token body
- (indirect) components.schemas.NumericDate (2450-2456): reusable for iat/exp
- (indirect) /revoke (273-310) and /introspect (315-363): the per-token revocation and status mechanisms TSL complements (§1.1)
- (indirect) OAuthServerMetadata additionalProperties: true (1936): tolerates status_list_aggregation_endpoint but does not declare it

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist; the draft was never audited or vendored.

**Notes.** As of 2026-10-10, -21 (21 Jun 2026) is in the RFC Editor queue (RFCEd: In Progress). IANA already lists its values, with reference RFC-ietf-oauth-status-list-21, dated 2026-06-12:
- JWT claims status, status_list and ttl
- the JWT Status Mechanisms registry (status_list)
- the OAuth Status Types registry
- AS metadata status_list_aggregation_endpoint

The IANA absence list reports 'status' as present; that is a false positive, since the YAML only says 'status codes' (172, 183).

The CWT variant (application/statuslist+cwt, CWT claims 65533/65534, CoAP content-format), the X.509 EKU id-kp-oauthStatusSigning (§10) and historical resolution's privacy effects (§12.7) have little or no OpenAPI surface.

SD-JWT VC -19 §2.2.2.3 requires the referenced Status List Token to be a JWT.

Vendor -21 now as references/rfc-sources/draft-ietf-oauth-status-list.txt (as the repo does for the OAuth 2.1 draft) and swap in the RFC text when it is published.

### Findings (0 high · 0 medium · 6 low)

1. **[LOW] Gap: Status List Token retrieval: GET &lt;status_list.uri>, content negotiation between application/statuslist+jwt and application/statuslist+cwt, optional 'time' query parameter**  
   *Reference:* draft-ietf-oauth-status-list-21 §5.1, §8.1, §8.2, §8.4, §14.7  
   The YAML has no path or media type for this. If the AS puts a status claim in its tokens (TSL §1.1 names OAuth access tokens as a use case), the Status Provider MUST answer an HTTP GET on that uri: - with a 2xx response and Content-Type application/statuslist+jwt (body: a compact JWS whose typ is statuslist+jwt) or application/statuslist+cwt (a binary CWT); - 3xx redirects are allowed; - CORS SHOULD be supported; - Content-Encoding (e.g. gzip) SHOULD be used for the JWT form; - relying parties MUST give exp and ttl priority over HTTP caching headers. Historical lookups use the query parameter time=&lt;unix timestamp>. The server SHOULD return 501 if it does not support the parameter and 404 if that time is unavailable.  
   *Suggested change:* Add an example path '/statuslists/{listId}' under a new tag 'Token Status', marked draft-ietf-oauth-status-list-21. Define get with parameters listId (path) and time (query, integer, minimum 0, optional). Responses: '200' with content application/statuslist+jwt: {schema: {$ref: '#/components/schemas/JWT'}} (decoded payload = StatusListTokenClaims) and application/statuslist+cwt: {} (binary); '404' and '501' with descriptions taken from §8.4. State in the description that the real URL is whatever status.status_list.uri contains. Express content negotiation only through the two response media types; OpenAPI ignores a header parameter named Accept. Map the path in split-oauth-openapi.py PATH_FILE.  
   *Verifier: confirmed.*

2. **[LOW] Gap: status claim in issued tokens (status.status_list.{idx, uri})**  
   *Reference:* draft-ietf-oauth-status-list-21 §1.1, §6.1, §6.2, §13.3, §14.1, §14.2  
   JWTAccessTokenClaims (2514-2573) has no status property; additionalProperties: true merely tolerates it. The claim is an object referencing at least one mechanism from the IANA 'JWT Status Mechanisms' registry. For this mechanism, status_list is REQUIRED, with idx (a non-negative integer) and uri (an RFC 3986 URI). The Status Issuer MUST prevent unintended double allocation of the same (uri, idx) pair (§13.3).  
   *Suggested change:* Add components.schemas.StatusClaim {type: object, minProperties: 1, additionalProperties: true, properties: {status_list: {type: object, required: [idx, uri], properties: {idx: {type: integer, minimum: 0}, uri: {type: string, format: uri}}}}}. Add an optional property to JWTAccessTokenClaims: status: {$ref: '#/components/schemas/StatusClaim', description: 'Token Status List reference (draft-ietf-oauth-status-list-21 §6.2); lets resource servers learn that a self-contained access token was revoked or suspended.'}.  
   *Verifier: confirmed.*

3. **[LOW] Gap: AS metadata status_list_aggregation_endpoint and the Status List Aggregation document**  
   *Reference:* draft-ietf-oauth-status-list-21 §9, §9.1, §9.2, §9.3, §14.6  
   OAuthServerMetadata (1922-2267) lacks status_list_aggregation_endpoint, which IANA registered on 2026-06-12 (it is listed in the IANA absence list). Per §9.1, an Issuer that is an OAuth AS is RECOMMENDED to publish the aggregation URL there. That URL returns application/json {"status_lists": [&lt;Status List Token URI>, ...]} (§9.3). Aggregation itself is optional (MAY).  
   *Suggested change:* Add to OAuthServerMetadata.properties: status_list_aggregation_endpoint: {type: string, format: uri, description: 'URL of the Status List Aggregation (JSON {status_lists: [uri...]}) for tokens this AS issues; draft-ietf-oauth-status-list-21 §9.1, §9.3.'}. Optionally add components.schemas.StatusListAggregation {type: object, required: [status_lists], properties: {status_lists: {type: array, items: {type: string, format: uri}}}} and an example GET path that returns it.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Status List Token payload and Status List structure (typ statuslist+jwt; sub, iat, exp, ttl, status_list{bits, lst, aggregation_uri})**  
   *Reference:* draft-ietf-oauth-status-list-21 §4.1, §4.2, §5.1, §14.1  
   No documentation schema exists. The Status List Token header typ MUST be statuslist+jwt. Its claims: sub REQUIRED (equal to the referencing token's status_list.uri), iat REQUIRED, exp RECOMMENDED, ttl RECOMMENDED (a positive number of seconds), status_list REQUIRED. The token MUST be signed or MACed. The StatusList object has bits REQUIRED (one of 1, 2, 4, 8), lst REQUIRED (base64url of the ZLIB/DEFLATE-compressed byte array, statuses packed least-significant-bit first) and aggregation_uri OPTIONAL.  
   *Suggested change:* Add two documentation-only schemas and map both in split-oauth-openapi.py: - StatusList {type: object, required: [bits, lst], properties: {bits: {type: integer, enum: [1, 2, 4, 8]}, lst: {type: string, pattern: '^[A-Za-z0-9_-]+$'}, aggregation_uri: {type: string, format: uri}}} - StatusListTokenClaims {type: object, required: [sub, iat, status_list], additionalProperties: true, properties: {sub: {type: string, format: uri}, iat: {$ref: NumericDate}, exp: {$ref: NumericDate}, ttl: {type: number, exclusiveMinimum: 0}, status_list: {$ref: StatusList}}}, with the 'typ statuslist+jwt, signed or MACed' rule in its description.  
   *Verifier: confirmed.*

5. **[LOW] Gap: Status Type values (VALID 0x00, INVALID 0x01, SUSPENDED 0x02, APPLICATION_SPECIFIC 0x03 and 0x0C-0x0F)**  
   *Reference:* draft-ietf-oauth-status-list-21 §7, §7.1, §8.3, §14.5  
   Not documented; the IANA absence list includes every 'OAuth Status Types' entry. Applications MUST use the registered values when the semantics match; all other values are reserved. Token processing rules take precedence: a token that is expired by exp stays invalid even if its list entry says VALID.  
   *Suggested change:* Document the values in StatusList.description, e.g. as a small table. Note that bits must be at least 2 to express SUSPENDED, and that token validation (exp, signature) happens before the status lookup (§7.1, §8.3).  
   *Verifier: confirmed.*

6. **[LOW] Gap: How Token Status List relates to /revoke and /introspect for self-contained access tokens**  
   *Reference:* draft-ietf-oauth-status-list-21 §1.1, §12.1  
   /revoke (273-310) and /introspect (315-363) describe revocation and status checks. But when a JWT access token is validated locally (RFC 9068), resource servers cannot see a revocation until exp. TSL is the standard way to propagate it without a per-token call to the AS, and it gives herd privacy (§12.1).  
   *Suggested change:* Add to the /revoke description: 'For self-contained JWT access tokens carrying a status claim, revocation should also set the token's Status List entry to INVALID (0x01), so resource servers that validate locally see it (draft-ietf-oauth-status-list §1.1).' Add a sentence to /introspect naming Token Status List as the pull-based, privacy-preserving alternative.  
   *Verifier: confirmed.*

## Verifier corrections to the summaries above

- TSL status/notes: the RFC Editor queue entry (queue.xml fetched 2026-10-10) is draft-ietf-oauth-status-list-20.txt, received 2026-06-04. -21 (21 June 2026) is the latest revision. Datatracker shows IESG 'RFC Ed Queue', RFCEd 'In Progress' and IANA 'Version Changed'. Better wording: 'in the RFC Editor queue (the queue entry is -20; -21 is the current revision)'.
- TSL summary: -21 does not require an HTTPS URL. status_list.uri only has to be an RFC 3986 URI fetched with HTTP GET (§6.2, §8.1), and Status List Tokens are self-protected 'without relying on… transport security' (§11, lines 1687-1690). 'Signed' should read 'signed or MACed' (§5.1 rule 2, §11.6). base64url applies only to the JSON form's lst; the CBOR form uses a byte string.
- Cluster IANA cross-check for TSL is incomplete. It omits the media types application/statuslist+jwt and application/statuslist+cwt, both registered in IANA Media Types on 2026-06-12 with reference RFC-ietf-oauth-status-list-21. For comparison, application/at+jwt (RFC 9068, 2021-09-03) and the RFC 9901 types (sd-jwt, sd-jwt+json, kb+jwt) are registered, while application/dc+sd-jwt is not (IANA page returns 404).
- The list of prior-note misstatements is incomplete. The 2026-05-10 note (9068-jwt-access-token.md) also invents RFC quotes that explain two of the three 'new defects'. Lines 100-103 claim the RFC says groups/roles/entitlements are '(arrays of strings)', which matches the string[] typing at 2559-2567. Lines 76-79 paraphrase §2.2 as 'sub SHOULD have the same value as client_id', which matches 'MUST equal client_id' at 2539-2540. Other fabricated or misattributed statements: 'Authorization servers MAY return additional claims' (60-61); 'The jti claim MUST be a unique identifier per token issued' (179-181); '§2.2… superset of the introspection response' (47-49); '§4 of 9068 specifically references access-token algorithm advertisement' (36-37); '`cty` SHOULD be omitted, RFC 9068 §2.1' (197-199); and Security Considerations cited as '§7' (214), when it is §5.
- RFC 9068 why_created: §1 (lines 85-86) says 'many commercial OAuth 2.0 implementations' issue such tokens, not 'most'.
- TSL notes: the CWT claim keys in §14.3 are requested (TBD) assignments: status 65535, status_list 65533 and ttl 65534. The note lists only 65533/65534 and omits 65535 for 'status'.
- RFC 9901 modeled_elements: §9.8 RECOMMENDS publishing issuer keys in a way that allows efficient rotation and revocation, and gives JWKS only 'for example' (lines 2265-2270). Calling JWKS 'the key-publication format §9.8 RECOMMENDS' overstates the text.
