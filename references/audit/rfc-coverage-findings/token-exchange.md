# Token exchange, AMR & Vectors of Trust — RFC 8693, 8176, 8485

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 8693](#rfc-8693-oauth-20-token-exchange) | January 2020 | Proposed Standard | mostly | 0 | 4 | 13 |
| [RFC 8176](#rfc-8176-authentication-method-reference-values) | June 2017 | Proposed Standard | referenced-only | 0 | 0 | 2 |
| [RFC 8485](#rfc-8485-vectors-of-trust) | October 2018 | Proposed Standard | none | 0 | 0 | 3 |

**Cluster notes.** Scope: RFC 8693, RFC 8176 and RFC 8485, checked on 2026-10-10 against the snapshot oauth-openapi.yaml (2,705 lines, read in full). RFC texts were read in full: the vendored 8693 and 8176, and the 8485 copy downloaded today. I also checked the IANA registries (oauth-parameters, jwt, and the AMR registry fetched today) and the RFC Editor errata pages.

Overall: the RFC 8693 request and response shape is now mostly modeled. That covers all 7 IANA-registered parameters, resource and audience as repeatable arrays, issued_token_type, the N_A token type, the six token-type URIs and invalid_target. Three classes of problem remain:
(1) TokenTypeURI is a closed enum, which contradicts RFC 8693 §3 ("Other URIs MAY be used"). It rejects token-type URIs from current OAuth WG profiles of token exchange: Transaction Tokens -11 (txn_token, self_signed, unsigned_json) and ID-JAG -04 (id-jag). The deferred-token-response -00 draft registers another one (deferral-code).
(2) The act and may_act JWT claims and introspection members are missing entirely. The IANA diff and grep agree: act, may_act, vtr, vot and vtm have zero occurrences in the YAML.
(3) Several MUST-level rules exist only as prose or not at all: issued_token_type REQUIRED, the actor_token/actor_token_type pairing, and error=invalid_request (not invalid_grant) for bad subject or actor tokens.

RFC 8176 is cited once, at IDTokenClaims.amr, without the registry values or OIDC Core §2's SHOULD-use-registered-values rule.

RFC 8485 (Vectors of Trust) is not a WG RFC and is not vendored. The YAML has no coverage of it. It is optional but in real use: GOV.UK One Login sends vtr=["Cl.Cm"] at /authorize and returns vot and vtm in ID Tokens (docs.sign-in.service.gov.uk, fetched today).

Items shared with other clusters:
- The ResourceIndicators description (RFC 8707 cluster) is wrong in the token-exchange context.
- The CacheControlNoStore const (RFC 6749 cluster) rejects RFC 8693's own example responses.

Do not apply one recommendation from the May-2026 notes. They were written without the RFC text and contain a quote that does not exist in RFC 8693: "default URI is ...token-type:access_token" for requested_token_type. They also have several wrong section numbers.

Related work in flight:
- draft-ietf-oauth-identity-chaining is in the RFC Editor queue. It profiles RFC 8693 and adds AS metadata identity_chaining_requested_token_types_supported, which the YAML lacks; that belongs to the drafts cluster.
- OAuth 2.1 draft-16 does not mention RFC 8693, so token exchange stays an optional extension grant.

How the findings were checked: a JSON Schema 2020-12 validator (jsonschema 4.26) was run on sample payloads. Every proposed fix was re-tested on an in-memory copy; the snapshot was not modified. Evidence used: the IANA Authentication Method Reference Values registry, the RFC errata pages and the GOV.UK One Login documentation.

## RFC 8693 OAuth 2.0 Token Exchange

*January 2020 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 8693 lets an OAuth 2.0 authorization server act as a Security Token Service (STS). A client POSTs a token it already holds (subject_token, plus an optional actor_token) to the token endpoint with grant_type=urn:ietf:params:oauth:grant-type:token-exchange. It gets back a new token aimed at a target service, named by resource and/or audience, optionally narrowed by scope and of a requested type (requested_token_type in the request, issued_token_type in the response). The RFC defines token-type URIs (access_token, refresh_token, id_token, saml1, saml2, plus jwt from RFC 7519), the token_type value N_A for issued tokens that are not access tokens, and the error rules: invalid_request for a bad subject or actor token, invalid_target for a target the server will not serve. It separates impersonation (subject token only; the new token is simply about the subject) from delegation (subject plus actor; the new composite token carries an act claim), and defines the act, may_act, scope and client_id JWT claims, with act and may_act also registered as token introspection members.

**Why it was created.** Before 2020 the only standard STS protocol was WS-Trust, which is XML/SOAP. REST/JSON systems, especially microservice chains where a resource server must call a downstream API on the user's behalf, had no interoperable way to trade an incoming token for one that is narrower, restricted to one audience, or in a different format. They also had no standard way to record delegation. Vendors therefore built proprietary 'on-behalf-of' grants, and services were tempted to forward broadly scoped tokens downstream. RFC 8693 standardizes that exchange and the delegation semantics (act, may_act).

<details><summary>Already modeled in the YAML (20)</summary>

- grant_type urn:ietf:params:oauth:grant-type:token-exchange: /token description (224), TokenRequest.oneOf and discriminator mapping (1162, 1171), TokenExchangeRequest.grant_type const (1358-1360)
- POST /token with an application/x-www-form-urlencoded body (210-246) and an application/json 200 response (257-260)
- subject_token, REQUIRED (1356, 1361-1363)
- subject_token_type, REQUIRED, typed as TokenTypeURI (1356, 1364-1365)
- actor_token (1366-1368)
- actor_token_type, typed as TokenTypeURI; the conditional requirement is in the description only (1369-1371)
- requested_token_type, typed as TokenTypeURI (1372-1374)
- audience as a repeatable array of strings (1375-1382)
- scope (1383-1384)
- resource as a repeatable array of absolute URIs, via the ResourceIndicators mixin (1203-1218, pulled in at 1353)
- Client authentication via ClientAuthFields (1175-1200, pulled in at 1352) and the clientSecretBasic / mtls / no-auth security options (265-268)
- The six §3 token-type URIs in components.schemas.TokenTypeURI (1386-1395)
- TokenResponse.access_token, REQUIRED (1408, 1411-1419)
- TokenResponse.issued_token_type, typed as TokenTypeURI and documented as REQUIRED for token exchange (1403-1404, 1449-1453)
- TokenResponse.token_type, REQUIRED, with N_A documented as an example (1408, 1420-1427)
- TokenResponse.expires_in, refresh_token and scope (1428-1442)
- Cache-Control: no-store and Pragma: no-cache on the /token 200 response (251-254, defined at 990-999)
- Error codes invalid_request (1479) and invalid_target (1499) in the ErrorResponse.error enum; the /token 400 response uses OAuthErrorWithDPoPNonce (261-262, 1074-1090)
- JWT claims scope (§4.2) and client_id (§4.3) in JWTAccessTokenClaims (2541-2543, 2556-2558); introspection scope and client_id (1713-1716)
- RFC 8693 listed in the info 'Covered specifications' table (30)

</details>

**Follow-up on the May-2026 validation notes.** The prior notes (2026-05-10) were written without access to the RFC text. They list 9 MISSING items (the synthesis counts 8), 3 WRONG and 7 NICE-TO-HAVE.

MISSING:
- Fixed (6): issued_token_type added (1449-1453; documented REQUIRED but not enforced); N_A documented (1420-1427); actor_token_type and requested_token_type typed via TokenTypeURI (1369-1374); resource and audience made repeatable arrays (1203-1218, 1375-1382).
- Partly fixed (1): actor_token_type's conditional requirement is prose only (1371), with no dependentRequired and no 'MUST NOT otherwise'.
- Already satisfied (1): Cache-Control/Pragma (251-254).
- Invalid (1): the quoted 'default URI is ...token-type:access_token' for requested_token_type does not exist in RFC 8693. §2.1 leaves the issued type to the AS's discretion, so the YAML is right to have no default. Do not apply this item.

WRONG: 3 of 3 fixed. However, the enum fix went too far: TokenTypeURI is now a closed enum that contradicts §3.

NICE-TO-HAVE: 7 of 7 still open (a token-exchange response variant, the refresh_token note, scope semantics, examples, act, may_act, the grant_types_supported note).

Newly found: the §2.2.2 invalid_request MUST is not documented, and act/may_act are absent from IntrospectionResponse and JWTAccessTokenClaims. The notes' 'NOT APPLICABLE' verdict on §4 is out of date: §7.5 registers act and may_act as introspection members, which are on the wire, and the YAML now has IntrospectionResponse and JWTAccessTokenClaims schemas.

Wrong section references in the notes:
- may_act is §4.4, not §4.3.
- TLS is §6, not §7.1.
- §5, §6 and §7 are Security, Privacy and IANA respectively.
- The example exchange is §2.3, not §2.1.1.
- The 'MAY include a query component' wording is from RFC 8693 §2.1, not RFC 8707 §2.

**Notes.** Errata: one Reported (unverified) technical erratum, ID 7511 (2023), proposes deleting §2.1's RFC 7523 client-authentication example. Its premise is that RFC 7523 would require grant_type=jwt-bearer. That is mistaken: RFC 7523 §2.2 client assertions use client_assertion_type, not grant_type, so the YAML's ClientAuthFields mixin on TokenExchangeRequest (1352) is correct.

IANA: all 6 token-type URIs, N_A and all 7 request/response parameters (audience, requested_token_type, subject_token, subject_token_type, actor_token, actor_token_type, issued_token_type) appear in the YAML. act and may_act are absent from both the JWT Claims and the Token Introspection Response registries' entries in the YAML.

Relevance: OAuth 2.1 draft-16 does not mention RFC 8693, so it remains an optional extension grant (RFC 6749 §4.5). It is rated 'recommended' because several current OAuth WG specs build on it: identity chaining (RFC Editor queue), Transaction Tokens -11 and ID-JAG -04.

### Findings (0 high · 4 medium · 13 low)

1. **[MEDIUM] Gap: act (actor) claim and token introspection response member**  
   *Reference:* RFC 8693 §4.1, §7.4, §7.5  
   act appears nowhere in the YAML (grep finds no matches). §4.1 defines it as a JSON object of identity claims (for example iss and sub) naming the current actor. Prior actors are recorded as nested act objects, with the least recent most deeply nested. Non-identity claims (exp, nbf, aud) are not used inside it. A token consumer MUST use only the top-level claims plus the outermost actor when making access-control decisions. §4.1 and §7.5 also register act as a top-level OAuth Token Introspection Response member with the same format. Neither IntrospectionResponse (1698-1758, which JWTIntrospectionResponse also nests at 1787-1789) nor JWTAccessTokenClaims (2514-2573) models it. Because both schemas allow additional properties, act passes through untyped; a validator accepts "act": "admin" as a plain string. act is the main output of a delegation exchange (Appendix A.2.5).  
   *Suggested change:* Add components.schemas.ActorClaim:

   ```yaml
   type: object
   additionalProperties: true
   description: RFC 8693 §4.1. Identity claims of the current actor; a nested act is a prior actor and is informational only; exp/nbf/aud are not used; consumers MUST use only top-level claims plus the outermost act for access control.
   properties:
     iss: {$ref: StringOrURI}
     sub: {type: string}
     act: {$ref: '#/components/schemas/ActorClaim'}
   ```

   Then add act: {$ref: '#/components/schemas/ActorClaim'} to IntrospectionResponse.properties and to JWTAccessTokenClaims.properties, and add act to the list of registered extension members in the IntrospectionResponse description (1701-1703). Validated: a nested act passes and a string act fails.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: actor_token and actor_token_type must appear together**  
   *Reference:* RFC 8693 §2.1  
   §2.1 says actor_token_type 'is REQUIRED when the actor_token parameter is present in the request but MUST NOT be included otherwise.' The YAML states only the first half, and only as prose (1371). Neither half is enforced: a request with actor_token but no actor_token_type validates, and so does one with actor_token_type but no actor_token (both verified). Without the type, the AS cannot perform the 'appropriate validation procedures for its indicated token type' that §2.1 requires (MUST).  
   *Suggested change:* In the inline object of TokenExchangeRequest.allOf (1355-1384), add dependentRequired: {actor_token: [actor_token_type], actor_token_type: [actor_token]}. This is JSON Schema 2020-12 and valid in OAS 3.1; validated in both directions. Change the description at 1371 to: 'REQUIRED when actor_token is present; MUST NOT be included otherwise (RFC 8693 §2.1).'  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: Token-exchange error-code rules: invalid_request MUST, invalid_target SHOULD**  
   *Reference:* RFC 8693 §2.2.2, §2.1.1  
   §2.2.2: if the request is invalid, or if the subject_token or actor_token is invalid for any reason or unacceptable by policy, the AS MUST respond per RFC 6749 §5.2 with error=invalid_request. If it is unwilling or unable to issue a token for a target named by resource or audience, it SHOULD use invalid_target; §2.1.1 also uses that code for requests naming too many targets. The YAML has both codes (1479, 1499) but gives no guidance: TokenExchangeRequest.description is only 'RFC 8693 §2.1.' (1350), and invalid_target is attributed only to RFC 8707 (1498). This is a common pitfall: for assertion grants, RFC 7521 §4.1.1 requires invalid_grant, so implementers often return invalid_grant for a bad subject_token too, which violates the §2.2.2 MUST.  
   *Suggested change:* Add an 'Errors (RFC 8693 §2.2.2)' paragraph to TokenExchangeRequest.description (1350): - Invalid or unacceptable request, subject_token or actor_token: HTTP 400 with error=invalid_request (MUST; not invalid_grant). - A resource or audience target the AS will not serve: invalid_target (SHOULD). - invalid_client, unauthorized_client or invalid_scope where appropriate. Also change the enum comment at 1498 to '# RFC 8707 §2; also RFC 8693 §2.2.2 (resource/audience targets)'.  
   *Verifier: confirmed.*

4. **[MEDIUM] Incorrect: lines 1386-1395, components.schemas.TokenTypeURI (closed enum). Referenced by TokenExchangeRequest subject_token_type, actor_token_type and requested_token_type (1364-1374) and by TokenResponse.issued_token_type (1449-1450).**  
   *Reference:* RFC 8693 §3  
   TokenTypeURI is a closed enum of the six §3 identifiers, but RFC 8693 §3 says 'Other URIs MAY be used to indicate other token types.' Requests and responses using legitimate extension token types are therefore rejected. Verified with a JSON Schema 2020-12 validator, all of these fail: - requested_token_type=urn:ietf:params:oauth:token-type:txn_token and subject_token_type=...:self_signed (draft-ietf-oauth-transaction-tokens-11 §11.1); - requested_token_type=...:id-jag (draft-ietf-oauth-identity-assertion-authz-grant-04); - a Txn-Token response with issued_token_type=...:txn_token; - and the whole TokenRequest oneOf for the txn_token request. Servers generated with openapi-generator enums would typically reject such requests with a framework validation error instead of an RFC 6749 §5.2 error body, and generated clients would fail to parse such responses. The same file deliberately keeps token_type_hint open 'so future registrations work without spec churn' (1690-1696).  
   *Suggested change:* Make the set open while keeping the known values visible: TokenTypeURI:

   ```yaml
   description: 'RFC 8693 §3 token type identifier (a URI). The values below are registered in the IANA OAuth URI registry; other URIs MAY be used.'
   anyOf:
     - enum: [the six URIs]
     - type: string
       format: uri
   examples: [the six URIs]
   ```

   Validated: accepts txn_token and id-jag, and still rejects non-URI values such as 'access_token'.  
   *Verifier: confirmed.*

5. **[LOW] Gap: issued_token_type REQUIRED in successful token-exchange responses**  
   *Reference:* RFC 8693 §2.2.1  
   TokenResponse.required is [access_token, token_type] (1408). issued_token_type (1449-1453) is optional; its REQUIRED status for token exchange exists only in prose (1403-1404, 1452). A server built from the shared /token 200 schema (257-260) can omit it and still pass validation; verified, {access_token, token_type: Bearer} validates. OpenAPI cannot tie a response schema to the request's grant_type, so a separately named schema is the practical way to make the rule visible to code generators and contract tests.  
   *Suggested change:* Add components.schemas.TokenExchangeResponse:

   ```yaml
   description: RFC 8693 §2.2.1 successful token-exchange response
   allOf:
     - $ref: TokenResponse
     - required: [access_token, issued_token_type, token_type]
   ```

   Then: - In TokenExchangeRequest.description, say the success body conforms to TokenExchangeResponse. - Add named examples under /token 200 application/json: RFC 8693 §2.3 Figure 3 (Bearer) and Appendix A.2.4 Figure 17 (N_A, issued_token_type jwt). - Either use anyOf: [TokenResponse, TokenExchangeResponse] as the 200 schema to wire it, or accept the oas3-unused-component hint, as the repo already does for its other documentation-only schemas. Validated: the schema rejects a response without issued_token_type.  
   *Verifier: confirmed.*

6. **[LOW] Gap: may_act (authorized actor) claim and token introspection response member**  
   *Reference:* RFC 8693 §4.4, §7.4, §7.5  
   may_act is absent from the YAML. §4.4 defines it as a JSON object of identity claims (for example iss, sub, email) naming a party that is authorized to act for the token's subject. When it appears in a subject_token, the AS can use it to decide whether the client, or the party in actor_token, may perform the requested delegation or impersonation (example in Appendix A.2.2). §7.5 registers it as an introspection response member with the same format. The AS itself is the main consumer, so this is low priority.  
   *Suggested change:* Add components.schemas.MayActClaim:

   ```yaml
   type: object
   additionalProperties: true
   description: RFC 8693 §4.4; exp/nbf/aud are not used
   properties:
     iss: {$ref: StringOrURI}
     sub: {type: string}
   ```

   Add may_act: {$ref: MayActClaim} to IntrospectionResponse and JWTAccessTokenClaims. In the TokenExchangeRequest.subject_token description (1361-1363), add: 'If the subject token carries may_act, the AS can use it to authorize the actor (RFC 8693 §4.4).'  
   *Verifier: confirmed.*

7. **[LOW] Gap: resource MUST NOT include a fragment component**  
   *Reference:* RFC 8693 §2.1 (also RFC 8707 §2)  
   The no-fragment rule is stated in prose (1209-1211) but not enforced: format: uri (1218) accepts https://backend.example.com/api#frag (verified).  
   *Suggested change:* Add pattern: '^[^#]*$' to ResourceIndicators.properties.resource.items (1216-1218), and to the /authorize Resource parameter items (892-895). Validated: a fragment is rejected and a query component is still accepted.  
   *Verifier: confirmed.*

8. **[LOW] Gap: Token-type URI meanings and the behavior when requested_token_type is omitted**  
   *Reference:* RFC 8693 §2.1, §3  
   TokenTypeURI (1386-1395) has only a YAML comment and no description. The requested_token_type description (1374) does not say what happens when the parameter is omitted. §2.1: if unspecified, 'the issued token type is at the discretion of the authorization server'; there is no default. §3 also explains a subtle distinction. access_token means an access token from this AS, opaque to the client. jwt means specifically a JWT, for example one to use as an RFC 7523 grant at a different AS. And saml1/saml2 mean base64url-encoded SAML assertions.  
   *Suggested change:* Give TokenTypeURI a description listing what each URI means, per §3 (and RFC 7519 §9 for jwt). Set requested_token_type.description to: 'OPTIONAL. If omitted, the issued token type is at the AS's discretion, possibly guided by resource or audience (RFC 8693 §2.1).' Do not add a default value.  
   *Verifier: confirmed.*

9. **[LOW] Gap: TokenResponse field meanings for token exchange, and token-exchange examples**  
   *Reference:* RFC 8693 §2.2.1, §2.3, Appendix A  
   The TokenResponse descriptions are written for ordinary grants: - access_token (1413-1416) says 'The access token issued'. In token exchange it carries whatever security token was issued, which 'need not be an OAuth access token' (it may be an ID token, a refresh token, or a base64url SAML assertion). - refresh_token (1435-1439) omits §2.2.1's note that a refresh token 'will typically not be issued' when one temporary credential is exchanged for another. - scope (1442) omits that it is REQUIRED when the granted scope differs from the requested scope. - expires_in (1431) refers only to the access token. There are also no token-exchange request or response examples anywhere in the file.  
   *Suggested change:* Add token-exchange sentences citing §2.2.1 to the TokenResponse access_token, refresh_token, scope and expires_in descriptions. Add request examples from §2.3 Figure 2 (impersonation) and Appendix A.2.1 Figure 14 (delegation with actor_token), and response examples from Figure 3 (Bearer) and Figure 17 (N_A with issued_token_type jwt).  
   *Verifier: confirmed.*

10. **[LOW] Gap: TokenExchangeRequest field descriptions: scope, actor_token, audience, client authentication**  
   *Reference:* RFC 8693 §1.1, §2.1, Appendix A.1.1  
   Four smaller description gaps: - scope (1383-1384) has no description and no RFC 6749 §3.3 pattern; the shared Scope parameter at 744 has one. - actor_token's phrase '(delegation/impersonation)' (1368) blurs §1.1 and Appendix A.1.1. Impersonation uses a subject_token alone; an actor_token is what makes a delegation (composite) token with an act claim possible. - audience does not mention that audience values 'must be unique within that server' (§2.1). - Nothing repeats §2.1's warning that omitting client authentication lets anyone holding a stolen token exchange it. This matters because /token allows the no-auth security option {} (268).  
   *Suggested change:* - scope: add the description 'Desired scope of the requested token in the context of the target service(s) (RFC 8693 §2.1; RFC 6749 §3.3)' and the same pattern as components.parameters.Scope (744). - actor_token: 'Presenting an actor_token typically yields a delegation (composite) token whose act claim identifies the actor; impersonation uses subject_token alone (RFC 8693 §1.1, Appendix A.1.1).' - audience: add the uniqueness note. - TokenExchangeRequest.description: 'Client authentication is a deployment decision, but omitting it lets anyone holding a compromised token exchange it (RFC 8693 §2.1); a safe AS should require it for this grant.'  
   *Verifier: partially correct —* Keep the scope, audience and client-authentication points. Drop the claim that actor_token's '(delegation/impersonation)' blurs the semantics, and do not adopt the wording 'impersonation uses subject_token alone': RFC 8693 does not say that. A better description is: 'Identifies the acting party. When present, the AS MAY issue a composite (delegation) token whose act claim names the actor, at its discretion (RFC 8693 §1.1, §4.1); the AS can check the subject token's may_act claim to authorize the actor (§4.4).'

11. **[LOW] Gap: Advertising token-exchange support in AS metadata (grant_types_supported)**  
   *Reference:* RFC 8693 §2.1 (grant type URI), via RFC 8414 §2 grant_types_supported  
   RFC 8693 defines no metadata of its own; an AS signals support by listing the grant-type URI in grant_types_supported. OAuthServerMetadata.grant_types_supported (2033-2036) mentions only the RFC 8414 default and gives no example values, so readers are not told that the token-exchange, device_code and jwt-bearer URNs belong there. (The May notes listed this as nice-to-have; it is still open.)  
   *Suggested change:* Add to grant_types_supported: examples: [[authorization_code, refresh_token, client_credentials, 'urn:ietf:params:oauth:grant-type:device_code', 'urn:ietf:params:oauth:grant-type:jwt-bearer', 'urn:ietf:params:oauth:grant-type:token-exchange']].  
   *Verifier: confirmed.*

12. **[LOW] Incorrect: lines 1206-1215, components.schemas.ResourceIndicators.properties.resource.description (inherited by TokenExchangeRequest via allOf at 1353)**  
   *Reference:* RFC 8693 §2.1, §7.2  
   This shared RFC 8707 text contradicts RFC 8693 when used for token exchange. (a) It says 'Some vendors use a non-standard audience parameter ... this spec models only the standard resource'. But RFC 8693 §2.1 defines audience, §7.2 registers it in the IANA OAuth Parameters registry with usage location 'token request', and the YAML itself models it at 1375-1382. (b) It says the value 'SHOULD NOT include a query component' (RFC 8707 §2), whereas RFC 8693 §2.1 says the resource URI 'MAY include a query component'. It also speaks of 'the access token', although token exchange may issue other token types.  
   *Suggested change:* Reword to: 'RFC 8707 §2: absolute URI, no fragment; SHOULD NOT include a query (RFC 8693 §2.1 permits one for token exchange). RFC 8693 also standardizes audience (logical target names) for the token-exchange grant; see TokenExchangeRequest. On other grants, an audience parameter (for example Auth0's) is a vendor extension and is not modeled here.'  
   *Verifier: confirmed.*

13. **[LOW] Incorrect: lines 990-994, components.headers.CacheControlNoStore (const 'no-store'), used by the /token 200 response (251-252) and the error responses**  
   *Reference:* RFC 8693 §2.2 and §2.3 examples; RFC 6749 §5.1  
   The const rejects RFC 8693's own example token-exchange responses, which send 'Cache-Control: no-cache, no-store' (§2.3 Figure 3, Appendix A.1.3 Figure 12, Appendix A.2.4 Figure 17); verified with a validator. RFC 6749 §5.1 and OAuth 2.1 draft-16 §3.2.3 require the no-store directive to be present. Cache-Control is a comma-separated list of directives (RFC 9111 §5.2), so additional directives are legitimate. This also affects the RFC 6749 cluster.  
   *Suggested change:* Replace const: 'no-store' with pattern: '(^|,)\s*no-store\s*(,|$)', add examples: ['no-store', 'no-cache, no-store'], and add the description 'MUST contain the no-store directive'. Validated: 'no-cache, no-store' and 'no-store' pass; 'no-cache' fails.  
   *Verifier: confirmed.*

14. **[LOW] Gap: The AS processing rules for token exchange are not documented anywhere in the YAML:
- The AS MUST validate subject_token, and actor_token when present, accordin** — *found by the verifier*  
   *Reference:* RFC 8693 §2.1 (final two paragraphs)  
   The AS processing rules for token exchange are not documented anywhere in the YAML: - The AS MUST validate subject_token, and actor_token when present, according to the indicated token type. - Absent one-time-use semantics, the exchange does not affect the validity of the input tokens. - The exchange is a one-time event with no tight linkage: the output token's expiry may reflect the input token's, but renewal of the input token is not reflected. The assessment cites the validation MUST only as rationale for the actor pairing.  
   *Suggested change:* Add a 'Processing (RFC 8693 §2.1)' paragraph to TokenExchangeRequest.description: the AS MUST validate each presented token per its *_token_type; exchanging does not revoke or alter the subject or actor tokens; the issued token's lifetime may be bounded by, but is not renewed with, the input token's; propagating revocation is implementation-specific.

15. **[LOW] Gap: The semantics of combining resource/audience with scope are undocumented** — *found by the verifier*  
   *Reference:* RFC 8693 §2.1.1  
   The semantics of combining resource/audience with scope are undocumented. A request asks for a token with the requested scope that is usable at ALL requested targets (the Cartesian product of scopes and targets), and clients should keep the number of targets small.  
   *Suggested change:* Add one sentence to the audience description (1377-1380) and the TokenExchangeRequest description: 'Multiple resource/audience values plus scope request a token valid for every listed target with the requested scope (RFC 8693 §2.1.1); the AS may answer invalid_target if too many targets are requested.'

16. **[LOW] Gap: The TokenResponse.token_type description does not say the value is case-insensitive, so clients may compare 'N_A' or 'Bearer' case-sensitively.** — *found by the verifier*  
   *Reference:* RFC 8693 §2.2.1 (token_type); also RFC 6749 §5.1  
   The TokenResponse.token_type description does not say the value is case-insensitive, so clients may compare 'N_A' or 'Bearer' case-sensitively.  
   *Suggested change:* Append to TokenResponse.token_type.description: 'Case-insensitive (RFC 6749 §5.1; RFC 8693 §2.2.1).'

17. **[LOW] Gap: The privacy requirements for issued tokens are not mentioned** — *found by the verifier*  
   *Reference:* RFC 8693 §6  
   The privacy requirements for issued tokens are not mentioned. When information must not be disclosed to the client, the token MUST be encrypted to its intended recipient, and deployments SHOULD minimize the data in issued tokens. The TLS-only MUST is already satisfied by the https server URL.  
   *Suggested change:* In the token-exchange note on TokenResponse.access_token, add: 'For token exchange, if claims must be hidden from the client the issued token MUST be encrypted (e.g., JWE) to its intended recipient; include only the minimally necessary data (RFC 8693 §6).'

## RFC 8176 Authentication Method Reference Values

*June 2017 · Proposed Standard · YAML coverage: **referenced-only** · relevance to an AS: optional · vendoring: already-vendored*

**What it is.** RFC 8176 creates the IANA 'Authentication Method Reference Values' registry. It holds the values used in the amr (Authentication Methods References) claim, which OpenID Connect Core §2 defines as a JSON array of case-sensitive strings. It registers 20 initial values: face, fpt, geo, hwk, iris, kba, mca, mfa, otp, pin, pwd, rba, retina, sc, sms, swk, tel, user, vbm and wia. Each names a family of methods; for example, otp covers both TOTP and HOTP. It also explains how amr (which methods were used) differs from acr (which business rules were satisfied). IANA has since added one more value, pop (2023, OpenID EAP ACR Values 1.0).

**Why it was created.** OpenID Connect defined the amr claim but deliberately left its values open. Each identity provider therefore invented its own strings, and a relying party could not interpret amr across providers, for example to tell whether MFA or a hardware key was used. A small shared registry of values already in use gives interoperable identifiers without slicing methods so finely that it hurts interoperability.

<details><summary>Already modeled in the YAML (2)</summary>

- IDTokenClaims.amr: open array of strings, cites RFC 8176 (2498-2501)
- JWTAccessTokenClaims.amr: open array of strings, no citation (2553-2555)

</details>

**Follow-up on the May-2026 validation notes.** There is no dedicated RFC 8176 validation file. Related notes: oidc-core-1.0.md lines 400-402 asked for amr as an array of strings, which is fixed at 2498-2500. The same note's 'values SHOULD be from the IANA AMR registry (RFC 8176)' was not carried over; only a bare citation was added, and that part is still open. 9068-jwt-access-token.md lines 86-88 asked for amr as an array, which is fixed at 2553-2555 but has no description.

**Notes.** The IANA AMR registry (last updated 2024-10-04, fetched today) holds 21 values: the 20 from RFC 8176 §2 plus pop (2023-05-08, OpenID Connect EAP ACR Values 1.0). The vendored OIDC Core 1.0 (errata set 2) §2 is what makes RFC 8176 normative by reference for an OpenID Provider (a SHOULD).

amr is not registered in the OAuth Token Introspection Response registry (checked in the IANA XML), so its absence from IntrospectionResponse is not a gap. No discovery metadata exists for amr.

Errata: one editorial erratum (ID 6314), rejected.

A closed enum would be wrong; the guidance is to keep the items open and add examples.

has_http_surface is true only in the sense that the values travel inside the amr claim of ID Tokens and JWT access tokens returned by /token.

### Findings (0 high · 0 medium · 2 low)

1. **[LOW] Gap: amr values from the IANA AMR registry, in IDTokenClaims**  
   *Reference:* RFC 8176 §2, §3, §6.1; OIDC Core 1.0 §2  
   IDTokenClaims.amr (2498-2501) is correctly an open array of strings, but its whole description is 'Authentication Methods Reference (RFC 8176).' Missing: - OIDC Core §2's rule (vendored text, errata set 2) that amr values are case-sensitive and SHOULD come from the IANA AMR registry established by RFC 8176. - Any of the 20 registered values (face, fpt, geo, hwk, iris, kba, mca, mfa, otp, pin, pwd, rba, retina, sc, sms, swk, tel, user, vbm, wia), plus pop added in 2023. - Examples. The description also attributes the claim itself to RFC 8176; the claim is defined by OIDC Core §2, and RFC 8176 defines its values. RFC 8176 §3's amr-versus-acr distinction is not explained next to acr (2495-2497).  
   *Suggested change:* Add components.schemas.AuthenticationMethodsReferences:

   ```yaml
   type: array
   items: {type: string}
   description: 'OIDC Core §2 amr: case-sensitive identifiers of the authentication methods used. Values SHOULD come from the IANA Authentication Method Reference Values registry (RFC 8176 §2: face, fpt, geo, hwk, iris, kba, mca, mfa, otp, pin, pwd, rba, retina, sc, sms, swk, tel, user, vbm, wia; plus pop). Unregistered values need prior agreement between the parties. amr says HOW the user authenticated; acr says WHICH policy was satisfied (RFC 8176 §3).'
   examples: [['pwd'], ['pwd', 'otp', 'mfa'], ['hwk', 'pin', 'user'], ['face']]
   ```

   Set IDTokenClaims.amr to $ref this schema. Keep the items open with no closed enum, because RFC 8176 §1 says the set is not exhaustive.  
   *Verifier: confirmed.*

2. **[LOW] Gap: amr in JWTAccessTokenClaims**  
   *Reference:* RFC 8176 §2 (via RFC 9068 §2.2.1 and OIDC Core §2)  
   JWTAccessTokenClaims.amr (2553-2555) has no description or reference at all. RFC 9068 §2.2.1 defines it 'as defined in Section 2 of [OpenID.Core]', so the same RFC 8176 registry guidance applies. RFC 9068 §2.2.1 also says auth_time, acr and amr stay fixed across all access tokens derived from one authorization response, including tokens obtained through RFC 8693 token exchange.  
   *Suggested change:* Set JWTAccessTokenClaims.amr to $ref: '#/components/schemas/AuthenticationMethodsReferences', with the note: 'Same value as the original authentication; unchanged across refresh and RFC 8693 exchanges (RFC 9068 §2.2.1).'  
   *Verifier: confirmed.*

## RFC 8485 Vectors of Trust

*October 2018 · Proposed Standard · YAML coverage: **none** · relevance to an AS: optional · vendoring: vendor*

**What it is.** RFC 8485 (Vectors of Trust, VoT) defines a compact way to describe how much to trust an identity transaction along several independent dimensions. A vector is a period-separated string such as P1.Cc.Ac, with components for identity proofing (P), primary credential usage (C), credential management (M) and assertion presentation (A). It is always interpreted within a trust framework named by an HTTPS trustmark URL. In OpenID Connect, the relying party requests acceptable vectors with vtr, a JSON array in which vectors are ORed and components within a vector are ANDed. The provider returns vot (the vector) and vtm (the trustmark) in the ID Token, and the same vot/vtm names may appear in token introspection responses. vtr is also registered as an OAuth authorization- and token-request parameter, and Appendix A supplies a default value set under the trustmark https://www.rfc-editor.org/info/rfc8485.

**Why it was created.** A single Level of Assurance number, as in NIST SP 800-63-2's LoA 1-4, collapses independent aspects into one value: how well a person's identity was proofed, and how strong the login credential was. It cannot express cases such as a strongly authenticated but pseudonymous user, and one community's 'LoA2' was not comparable to another's. NIST's 2017 third edition moved away from a single LoA. VoT gives a simple wire format for multi-dimensional trust that a relying party can still process easily.

**Follow-up on the May-2026 validation notes.** No prior validation notes exist. RFC 8485 was neither vendored nor audited in May 2026, and neither the YAML nor the audit documents mention it (grep finds no occurrences of vtr, vot, vtm or 8485).

**Notes.** Not vendored (outside the scope rule). It is an AD-sponsored Proposed Standard (RFC index working group: NON WORKING GROUP) with no errata.

Why vendor despite being niche: it registers entries in three OAuth-related IANA registries. Those are vtr in OAuth Parameters, and vot/vtm in both the JWT Claims and the OAuth Token Introspection Response registries, which the IANA-vs-YAML diff flags as absent. The repo also already vendors the comparable authentication-context RFC 8176. If the maintainers decide not to model VoT, catalog-only is acceptable, but then list RFC 8485 explicitly as intentionally unmodeled. *(Update 2026-10-11: not vendored, because RFC 8485 is outside the scope rule; [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md) lists it as catalogue-only.)*

No AS discovery metadata is defined for VoT.

Deployment confirmed today: GOV.UK One Login documents vtr at /authorize and in JAR request objects, and returns vot ('Cl.Cm') and vtm ('https://oidc.integration.account.gov.uk/trustmark') in its example ID Tokens.

### Findings (0 high · 0 medium · 3 low)

1. **[LOW] Gap: vtr (Vector of Trust request) parameter**  
   *Reference:* RFC 8485 §4, §4.1, §7.2  
   vtr is absent from the YAML. IANA OAuth Parameters registers it for 'authorization request, token request' (§7.2). Its value is a JSON array of vector strings: vectors are ORed, components within a vector are ANDed, and an omitted component means any value is acceptable (§4.1). §4.1 describes vtr as a claim in the request object; as a plain query or form parameter it therefore travels as a JSON-encoded string. GOV.UK One Login, for example, sends vtr=["Cl.Cm"] at /authorize and in JAR request objects. vtr is missing from the /authorize parameters (132-158) and from PARRequest (1594-1647).  
   *Suggested change:* Add components.parameters.VectorsOfTrustRequest:

   ```yaml
   name: vtr
   in: query
   required: false
   description: 'RFC 8485 §4.1: JSON-encoded array of acceptable vectors, for example ["P1.Cc.Ac","Ce.Ab"]; vectors ORed, components ANDed; may also appear as a JSON-array claim in a JAR request object.'
   schema: {type: string}
   ```

   This follows the same modeling as the claims parameter (939-948). Reference it from /authorize (132-158), and add vtr: {type: string} to the PARRequest properties.  
   *Verifier: confirmed.*

2. **[LOW] Gap: vot and vtm ID Token claims**  
   *Reference:* RFC 8485 §2, §3.1, §3.2, §5, §7.3  
   IDTokenClaims (2461-2509) lacks vot and vtm. When VoT is used with OIDC, the IdP MUST send the vector as a string in vot and MUST send the trustmark as a URL in vtm (§3.2). The vector MUST be a period-separated list of components; each component is one uppercase demarcator letter [A-Z] followed by one value character [0-9a-z], and the same component-value pair must not repeat (§2, §3.1). A vector MUST always travel with its trustmark (§3.1), and a trustmark is an HTTPS URL (§5).  
   *Suggested change:* Add to IDTokenClaims.properties:

   ```yaml
   vot:
     type: string
     pattern: '^[A-Z][0-9a-z](\.[A-Z][0-9a-z])*$'
     description: RFC 8485 §3.2 Vector of Trust value
     examples: ['P1.Cc.Ac']
   vtm:
     type: string
     format: uri
     pattern: '^https://'
     description: RFC 8485 §3.2 and §5 trustmark URL; REQUIRED whenever vot is present
   ```

   Also add dependentRequired: {vot: [vtm]}. Ideally define both as shared components (VectorOfTrust, Trustmark).  
   *Verifier: confirmed.*

3. **[LOW] Gap: vot and vtm token introspection response members**  
   *Reference:* RFC 8485 §3.2, §7.4  
   IntrospectionResponse (1698-1758) lacks vot and vtm. §7.4 registers both in the OAuth Token Introspection Response registry, and §3.2 says vector values MAY be returned, using the same claim names, in an introspection response about the ID token or access token issued during the OIDC transaction.  
   *Suggested change:* Add vot and vtm to IntrospectionResponse.properties using the same shared VectorOfTrust and Trustmark schemas, with dependentRequired: {vot: [vtm]}, and list them among the registered extension members in its description (1701-1703).  
   *Verifier: confirmed.*

## Verifier corrections to the summaries above

- RFC 8693 summary: the impersonation/delegation split is over-simplified. RFC 8693 §1.1 says 'When and if a composite token is issued is at the discretion of the authorization server', and §4.4 lets the party identified in the actor_token 'engage in the requested delegation or impersonation'. An actor_token therefore does not guarantee a composite token with an act claim. The RFC states only the converse (Appendix A.1.1): 'delegation is impossible with only a "subject_token" and no "actor_token"'.
- RFC 8693 why_created: 'Before 2020 the only standard STS protocol was WS-Trust' overstates the RFC. RFC 8693 §1 says only that Web Service clients 'have used WS-Trust'. Also, RFC 7521, 7522 and 7523 (May 2015) already standardized trading a SAML or JWT assertion for an access token at the token endpoint, a narrow form of token exchange.
- cluster_notes: the snapshot oauth-openapi.yaml has 2,704 lines (wc -l and awk NR both report 2704), not 2,705.
- cluster_notes: listing deferral-code (draft-ietf-oauth-deferred-token-response-00 §12.6) beside the token-exchange profiles is misleading. The draft uses that URI only as a token_type_hint at /revoke and says the successful polling response 'MUST NOT carry the urn:ietf:params:oauth:token-type:deferral-code type'. It is never a subject, actor, requested or issued token type, and the YAML's open token_type_hint (1803-1808) already accepts it. Only txn_token, self_signed, unsigned_json and id-jag are blocked by the closed enum.
- RFC 8693 incorrect[0]: the citation 'draft-ietf-oauth-transaction-tokens-11 §11.1' fits txn_token only. self_signed is defined in §11.2.1 and unsigned_json in §11.2.2, with the IANA registrations in §16.1. ID-JAG -04 registers id-jag in §10.2.
- RFC 8693 prior_validation_followup understates the May-2026 notes' quoting problem. Besides 'default URI is ...token-type:access_token', these quoted strings do not occur in RFC 8693 (string search of the vendored text): - resource: 'physical location' and 'This parameter MAY be included multiple times' (8693-token-exchange.md 94-97); - audience: 'MAY be included multiple times' (104-106); - scope: 'Indicates the requested scope of the issued security token' (167-168); - '§2.2.1 ... as specified in Section 5.1 of [RFC6749]' (112-115); the actual text is in §2.2 and says 'Section 5'. The notes also cite a nonexistent '§4.1.1' for act (176), while claiming 'no quoted text is fabricated' (14-15).
- RFC 8693 prior_validation_followup: 'NICE-TO-HAVE: 7 of 7 still open' slightly overstates. Item 1 offered an 'Acceptable alternative: add a description block on TokenResponse listing the 8693 deltas', and that is partly done: TokenResponse.description (1403-1404) and token_type (1425-1426) now state issued_token_type REQUIRED and N_A. The refresh_token and expires_in deltas remain open, so the count is 6 open and 1 partly addressed.
- Several 'Validated' claims on proposed fixes depend on validator configuration or are incomplete (re-tested by the verifier): - The open TokenTypeURI rejects 'access_token' only when format is asserted. - anyOf [TokenResponse, TokenExchangeResponse] enforces nothing. - The proposed vot pattern accepts the forbidden 'Cc.Cc'. - The proposed Cache-Control pattern rejects 'No-Store', although RFC 9111 §5.2 directives are case-insensitive. Everything else factual checks out: published dates and statuses (RFC Editor index), errata (8693: ID 7511 Reported, Technical, 2023-05-08; 8176: ID 6314 Rejected, Editorial; 8485: none), the AMR registry (21 values, pop on 2023-05-08, updated 2024-10-04), OAuth 2.1 -16's silence on RFC 8693, identity-chaining-17 §3 metadata, and the GOV.UK vtr/vot/vtm usage.
