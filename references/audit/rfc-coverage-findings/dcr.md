# Dynamic Client Registration — RFC 7591, 7592, OIDC Registration 1.0

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 7591](#rfc-7591-oauth-20-dynamic-client-registration-protocol) | July 2015 | Proposed Standard | referenced-only | 4 | 7 | 9 |
| [RFC 7592](#rfc-7592-oauth-20-dynamic-client-registration-management-protocol) | July 2015 | Experimental | none | 0 | 5 | 3 |
| [OIDC Dynamic Client Registration 1.0](#oidc-dynamic-client-registration-10-openid-connect-dynamic-client-registration-10-incorporating-errata-set-2) | February 2014 (errata set 2: December 2023) | OpenID Foundation Final Specification (errata set 2, 15 Dec 2023); also published as ISO/IEC 26133:2024 | referenced-only | 2 | 7 | 7 |

**Cluster notes.** BOTTOM LINE: Dynamic Client Registration is entirely unmodeled. The only DCR traces in oauth-openapi.yaml are (a) OAuthServerMetadata.registration_endpoint (lines 1965-1968), (b) mtls_endpoint_aliases.registration_endpoint (line 2010), and (c) the token-endpoint auth-method enum (lines 2041-2048), whose IANA registry RFC 7591 §4.2 created and which holds all 7 registered values. Missing: 0 of 4 operations modeled (POST /register; GET/PUT/DELETE on the client configuration endpoint); 0 of 4 RFC 7591 error codes; 0 of the 94 IANA client-metadata names modeled as client metadata. The 26 'present' hits in the IANA absence list are AS-metadata or prose tokens (scope, jwks_uri, jwks, client_id, client_secret, userinfo_signed_response_alg, the *_values_supported arrays, and so on). Breakdown of the 94: RFC 7591 20, RFC 7592 2, OIDC Registration 18, RFC 8705 6 plus use_mtls_endpoint_aliases, RFC 9101/9126/9396/9449 1 each, RFC 9701 3, OIDF logout 5, JARM 3, RP Metadata Choices 19 (registered 2026-08-03), OpenID Federation 7, OpenID4VP 2, UMA 1, ETSI NFV 3.

IANA HOUSEKEEPING (verified in today's XML): the four RFC 7591 §3.2.2 error codes entered the OAuth Extensions Error Registry only on 2026-02-03 (usage location 'registration endpoint'). software_statement entered the client-metadata registry only on 2026-05-18. RFC 7591's own §4 registered neither. The CIBA client metadata (CIBA Core §4) is not in the IANA registry at all.

RECOMMENDED SHAPE (prototype validated):
- Define ONE reusable components.schemas.ClientMetadata (RFC 7591 §2 + OIDC Registration §2 + the RFC extension fields), with additionalProperties: true, patternProperties for '#lang' members, jwks/jwks_uri mutual exclusion, redirect_uris required for code-flow clients, and dependentRequired for *_enc/*_alg.
- Build on it: ClientRegistrationRequest (+ software_statement), ClientInformationResponse (+ client_id REQUIRED, client_secret, client_id_issued_at, client_secret_expires_at with dependentRequired on client_secret, registration_access_token, registration_client_uri), a 201 variant ClientRegistrationResponse (both-or-neither on the token and URI), and ClientUpdateRequest (client_id required; output-only members forbidden).
- Add TokenEndpointAuthMethod (open), SoftwareStatement (3-segment JWS), securitySchemes initialAccessToken and registrationAccessToken (http bearer), headers.WWWAuthenticateBearer, and responses ClientRegistrationError (400) and RegistrationTokenError (401).
- Add paths /register (POST, security [{} , initialAccessToken]) and /register/{client_id} (GET/PUT/DELETE, registrationAccessToken, no 404), linked from the 201 via OpenAPI links.
- The prototype fragment and its test harness were scratch work; they are not kept in the repository.
- Results: Spectral 6.15.0 with the repo ruleset reports 0 errors and 0 warnings; the only hints are the 4 pre-existing documentation-only schemas. 25 of 25 cases pass, including every RFC 7591 §3.1/§3.1.1/§3.2.1, RFC 7592 §2.2/§3 and OIDC §3.1/§3.2/§4.3 example.
- Caveat: openapi-generator ignores most of the 2020-12 keywords used (dependentRequired, if/then, patternProperties, anyOf), so handlers must still enforce them.
- The same ClientMetadata model also serves manual or admin registration: OAuth 2.1 draft-16 §2, RFC 9126 §6 and RFC 9449 §5.2 all say the RFC 7591 data model is useful without DCR. It also serves Client ID Metadata Documents.

CORRECTION TO THE TASK PREMISE 'MCP relies on DCR' (verified today on GitHub, modelcontextprotocol/modelcontextprotocol docs/specification):
- MCP 2025-03-26 and 2025-06-18: AS and clients SHOULD support RFC 7591 (2025-03-26 even defaults the endpoint to /register).
- 2025-11-25: downgraded to MAY; Client ID Metadata Documents become SHOULD.
- Latest, 2026-07-28: 'Dynamic Client Registration is deprecated. New implementations should use Client ID Metadata Documents instead.' DCR stays MAY for backward compatibility, and MCP clients MUST send application_type in DCR.
So DCR is still needed to interoperate with deployed MCP clients. The forward path is draft-ietf-oauth-client-id-metadata-document-02 (WG Document, July 2026). It reuses RFC 7591 client metadata and adds the AS-metadata field client_id_metadata_document_supported, which is not yet IANA-registered. references/audit/rfc-audit-synthesis.md:280 skipped that field as an 'Auth0 vendor' field. That classification is outdated, which matters for the drafts cluster.

IN-FLIGHT REGISTRY GROWTH (keep enums open):
- attest_jwt_client_auth / attest_jwt_client_auth_dpop plus client_attestation_* metadata: draft-ietf-oauth-attestation-based-client-auth-11, in WG Last Call.
- spiffe_jwt / spiffe_x509 / spiffe_wit plus spiffe_id / spiffe_bundle_endpoint: draft-ietf-oauth-spiffe-client-auth-02.
- deferred_client_notification_endpoint: deferred-token-response-00.
- authorization_grant_profiles_supported: identity-assertion-authz-grant-04.

CROSS-CLUSTER TENSION (for the oauth21/core clusters): RFC 7591 defaults token_endpoint_auth_method to client_secret_basic. OAuth 2.1 draft-16 §2.4.1 makes client_secret_post MUST and HTTP Basic only MAY. Meanwhile securitySchemes.clientSecretBasic (lines 2662-2674) still calls Basic 'PREFERRED' per RFC 6749 §2.3.1. An OAuth 2.1-profile AS without Basic must substitute the default and echo the method it actually registered (RFC 7591 §3.2.1).

OUT OF SCOPE for a general AS (catalog-only or exclude): OpenID Federation, OpenID4VP, UMA and ETSI NFV client metadata. RP Metadata Choices 1.0 is optional.

## RFC 7591 OAuth 2.0 Dynamic Client Registration Protocol

*July 2015 · Proposed Standard · YAML coverage: **referenced-only** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 7591 defines a JSON API for registering clients at runtime instead of through a developer portal. The client software, or its developer, POSTs to the AS's client registration endpoint. The request body is a set of 'client metadata': redirect URIs, token-endpoint auth method, grant/response types, display name/logo/policy URLs, public keys (jwks or jwks_uri) and software id/version. It can optionally be vouched for by a signed 'software statement' JWT and authorized by an 'initial access token'. The AS answers 201 with a client_id and, for confidential clients, a client_secret plus its expiry, and echoes every value it actually registered. RFC 7591 also creates the two IANA registries (client metadata names and token-endpoint auth methods) that every later OAuth extension uses to add per-client settings.

**Why it was created.** Manual registration does not scale when one piece of client software must work with many authorization servers it cannot know at build time. Examples: a standardized API deployed by many organizations, native apps that need per-instance credentials, open ecosystems. Each ecosystem had already invented an incompatible registration API (OpenID Connect, UMA). The OAuth WG generalized them into one interoperable protocol. It added software statements so a trusted publisher can attest to a client's metadata (registration data is otherwise self-asserted and easy to spoof). It added initial access tokens so a server can restrict who may register.

<details><summary>Already modeled in the YAML (6)</summary>

- AS metadata pointer registration_endpoint: components.schemas.OAuthServerMetadata.properties.registration_endpoint (lines 1965-1968; RFC 8414 §2 field pointing at RFC 7591)
- mTLS alias mtls_endpoint_aliases.registration_endpoint (line 2010; RFC 8705 §5)
- Token Endpoint Authentication Methods registry (created by RFC 7591 §4.2): values none / client_secret_basic / client_secret_post defined by RFC 7591 §2 at lines 2042-2044, plus later registrations client_secret_jwt, private_key_jwt, tls_client_auth, self_signed_tls_client_auth at 2045-2048 (OAuthServerMetadata.token_endpoint_auth_methods_supported); all 7 IANA values present, but as a closed enum (see incorrect)
- Token-endpoint use of the credentials DCR issues: ClientAuthFields.client_id/client_secret (lines 1175-1190) and securitySchemes.clientSecretBasic (lines 2662-2674), i.e. the client_secret_post / client_secret_basic semantics that token_endpoint_auth_method selects
- TLS requirement of §3/§5 satisfied at server level: servers[0].url https://{issuer} (line 78)
- Reusable building blocks only, not DCR models: JWKS/JWK (lines 1813-1902) for client jwks, JWT (lines 2434-2441) for software_statement, NumericDate (2450-2456), Scope pattern (line 744), headers CacheControlNoStore/PragmaNoCache (990-999), securitySchemes.bearerAuth (2637-2646), ErrorResponse error/error_description shape (1465-1533)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation note exists for RFC 7591. Related items in other notes:
- references/audit/rfc-audit-synthesis.md:282 deferred 'RFC 7591 Dynamic Client Registration endpoints (separate roadmap item)'. Still open.
- rfc-validation/8414-as-metadata.md recorded registration_endpoint as present. Still true; it is now at lines 1965-1968, while the note cites old lines 1161-1164.
- rfc-validation/9449-dpop.md M5 asked to surface the dpop_bound_access_tokens client metadata on securitySchemes.dpop. Still open; lines 2648-2660 don't mention it.
- rfc-validation/9126-par.md left a TODO to add require_pushed_authorization_requests as client metadata once DCR is modeled. Still open.

**Notes.** IANA-absent attribution: all 20 client-metadata names registered for RFC 7591 are unmodeled as client metadata. 15 are listed as absent; scope, jwks_uri, jwks, client_id and client_secret match only as unrelated tokens. All 4 error codes are absent, while all 3 RFC 7591 auth-method values are present. Validation: a scratch prototype of these additions lints clean, and 25 of 25 schema cases behave as intended, including all RFC 7591 examples verbatim. The path /register matches the RFC examples and the MCP 2025-03-26 default.

### Findings (4 high · 7 medium · 9 low)

1. **[HIGH] Gap: Client registration endpoint: POST /register (operation, media types, status codes, security)**  
   *Reference:* RFC 7591 §3, §3.1, §3.2  
   No path or operation exists. The spec advertises registration_endpoint (lines 1965-1968) but never describes the endpoint; the README roadmap lists it as TODO and references/audit/rfc-audit-synthesis.md:282 deferred it. §3 requires the endpoint to accept HTTP POST with an application/json body whose top-level members are client metadata. §3.2 requires 201 Created with an application/json Client Information Response. Open registration SHOULD be allowed and MAY be rate-limited (§3). The RFC examples send Cache-Control: no-store and Pragma: no-cache because the body carries client_secret.  
   *Suggested change:* 1) Add tag 'Client Registration' (tags, after line 101). 2) Add paths./register.post: operationId registerClient, externalDocs RFC 7591 §3.1, requestBody required with application/json -> $ref '#/components/schemas/ClientRegistrationRequest'. 3) Responses: '201' with headers Cache-Control/Pragma -> existing CacheControlNoStore/PragmaNoCache (lines 990-999), body ClientRegistrationResponse, and links {ReadClientConfiguration: {operationId: readClientConfiguration, parameters: {client_id: '$response.body#/client_id'}}}; '400' -> new components.responses.ClientRegistrationError; '401' -> new RegistrationTokenError; optional '429'. 4) security: [{}, {initialAccessToken: []}]. A prototype of this surface merged into a scratch copy of the spec lints with Spectral at 0 errors and 0 warnings.  
   *Verifier: confirmed.*

2. **[HIGH] Gap: Client metadata model: redirect_uris, token_endpoint_auth_method, grant_types, response_types, client_name, client_uri, logo_uri, scope, contacts, tos_uri, policy_uri, jwks_uri, jwks, software_id, software_version**  
   *Reference:* RFC 7591 §2, §4.1.2  
   None of these exists as a schema property. The IANA-diff 'present' hits for scope, jwks_uri and jwks (lines 732-748, 1961, 1813) are the AS's own parameters and keys, not client metadata. redirect_uris is MUST-implement for servers that offer redirect-based flows (§2). Wire defaults matter: token_endpoint_auth_method defaults to client_secret_basic, grant_types to ['authorization_code'], response_types to ['code']. grant_types values MUST equal the grant_type sent to /token. OAuth 2.1 draft-16 §2.4.1 makes client_secret_post MUST and Basic only MAY, so an OAuth 2.1-profile AS without Basic must substitute the default and echo the method it registered (§3.2.1).  
   *Suggested change:* Add components.schemas.ClientMetadata (type: object, additionalProperties: true) with these properties: - redirect_uris: array of {type: string, format: uri, pattern: '^[^#]*$'} - token_endpoint_auth_method: $ref TokenEndpointAuthMethod (see incorrect), default client_secret_basic - grant_types: array of string, default [authorization_code], examples from the TokenRequest discriminator mapping at lines 1166-1171 - response_types: array of string, default [code] - client_name: string - client_uri, logo_uri, tos_uri, policy_uri, jwks_uri: string, format: uri - scope: string, reusing the pattern at line 744 - contacts: array of string - jwks: $ref JWKS, public keys only - software_id, software_version: string Document that, under this repo's OAuth 2.1 profile, implicit/password/token values are rejected with invalid_client_metadata (no need to model those grants).  
   *Verifier: confirmed.*

3. **[HIGH] Gap: Client Information Response: client_id (REQUIRED), client_secret, client_id_issued_at, client_secret_expires_at (REQUIRED if client_secret is issued; 0 = never expires), echo of all registered metadata**  
   *Reference:* RFC 7591 §3.2.1, §1.3 step (D)  
   No response schema. The AS MUST return all registered metadata, including values it provisioned or substituted. client_secret_expires_at is REQUIRED whenever client_secret is issued. Extensions MAY add fields. Times are seconds since 1970-01-01T00:00:00Z.  
   *Suggested change:* Add components.schemas.ClientInformationResponse: allOf [ {$ref: ClientMetadata}, {type: object, required: [client_id], properties: {client_id: {type: string}, client_secret: {type: string}, client_id_issued_at: {type: integer, minimum: 0}, client_secret_expires_at: {type: integer, minimum: 0, description: '0 = does not expire'}, software_statement: {$ref: SoftwareStatement}}, dependentRequired: {client_secret: [client_secret_expires_at]}} ]. Validated: the RFC §3.2.1 example passes; a body with client_secret but no client_secret_expires_at is rejected.  
   *Verifier: confirmed.*

4. **[HIGH] Gap: Registration error response: HTTP 400 application/json {error, error_description}; codes invalid_redirect_uri, invalid_client_metadata, invalid_software_statement, unapproved_software_statement**  
   *Reference:* RFC 7591 §3.2.2  
   ErrorResponse.error (enum at lines 1477-1517) has none of the four codes, as the IANA-absent list confirms. IANA added them to the OAuth Extensions Error Registry only on 2026-02-03, with usage location 'registration endpoint'. Clients MUST ignore members they don't understand. Note: registration_not_supported (line 1517) is unrelated; it is OIDC Core §3.1.2.6's error for the 'registration' authorization-request parameter.  
   *Suggested change:* After line 1517 add the comment '# RFC 7591 §3.2.2 — registration-endpoint-only' and the four codes. This keeps the 'union of all registered values' claim at lines 1466-1469 true. Then add components.responses.ClientRegistrationError: description 'HTTP 400', headers CacheControlNoStore/PragmaNoCache, content application/json -> ErrorResponse (or a dedicated ClientRegistrationErrorResponse with additionalProperties: true).  
   *Verifier: confirmed.*

5. **[MEDIUM] Gap: software_statement: request member, echoed response member, and decoded statement claims**  
   *Reference:* RFC 7591 §2.3, §3.1.1, §3.2.1, §5  
   Absent; IANA registered the name only on 2026-05-18. Rules from §2.3, §3.1.1 and §3.2.1: - It is a JWT that MUST be JWS-signed or MACed and MUST contain iss. - RS256 and a software_id claim are RECOMMENDED. - If the AS trusts it, its claims MUST take precedence over the plain JSON metadata. - If used, it MUST be returned unmodified in the response, with the metadata taken from it also returned as top-level members. The existing JWT schema (lines 2434-2441) also accepts 5-segment JWE strings.  
   *Suggested change:* 1) Add components.schemas.SoftwareStatement: type string, pattern '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$', with a description of the §2.3 rules. 2) Add a documentation-only SoftwareStatementClaims: type object, required [iss], properties software_id plus the ClientMetadata members, additionalProperties true. 3) Add software_statement: {$ref: SoftwareStatement} to ClientRegistrationRequest and ClientInformationResponse. Validated with the RFC's own RS256 example statement; a 5-segment value is rejected.  
   *Verifier: confirmed.*

6. **[MEDIUM] Gap: Initial access token (optional authorization for registration) and the token-error response**  
   *Reference:* RFC 7591 §1.2, §1.3 step (A), §3, §3.2.2  
   No security scheme and no 401 response for registration. The endpoint MAY be an OAuth 2.0 protected resource that accepts an initial access token (the example uses Bearer, but any token type is allowed), and it SHOULD also accept requests with no token. An invalid initial access token gets 'an error response appropriate to the OAuth 2.0 token type'; for Bearer that is 401 plus WWW-Authenticate per RFC 6750 §3. Existing pieces don't fit: bearerAuth (lines 2637-2646) describes resource-server access tokens, and WWWAuthenticateBearerDPoP (lines 1000-1025) also advertises DPoP.  
   *Suggested change:* Add components.securitySchemes.initialAccessToken {type: http, scheme: bearer, description: 'OPTIONAL initial access token (RFC 7591 §1.2, §3)'}, components.headers.WWWAuthenticateBearer (example: Bearer error=invalid_token) and components.responses.RegistrationTokenError (401 with WWW-Authenticate and Cache-Control). On POST /register use security: [{}, {initialAccessToken: []}].  
   *Verifier: confirmed.*

7. **[MEDIUM] Gap: Unknown/extension metadata handling and language-tagged human-readable members (e.g. client_name#ja-Jpan-JP)**  
   *Reference:* RFC 7591 §2 (closing paragraphs), §2.2  
   The AS MUST ignore client metadata it does not understand, not reject it, and MAY replace values with defaults. client_name, client_uri, logo_uri, tos_uri and policy_uri may repeat with a '#' plus BCP 47 tag suffix. A validator generated from a closed schema would reject both, yet the RFC's own examples contain example_extension_parameter and client_name#ja-Jpan-JP.  
   *Suggested change:* On ClientMetadata set additionalProperties: true explicitly and add patternProperties {'^(client_name|client_uri|logo_uri|tos_uri|policy_uri)#[A-Za-z0-9-]+$': {type: string}}. Describe how BCP 47 tags are handled: interpret them case-insensitively, and send an untagged value alongside (RECOMMENDED). Validated: both RFC examples pass, and a non-string tagged member is rejected.  
   *Verifier: confirmed.*

8. **[MEDIUM] Gap: Cross-field constraints: jwks XOR jwks_uri; redirect_uris required for redirect-based grants; grant_types/response_types correspondence**  
   *Reference:* RFC 7591 §2 (jwks_uri, jwks), §2.1, §5  
   Four rules apply: - jwks_uri and jwks MUST NOT both appear in a request or response. - For redirect-based grants the AS MUST require registered redirect URIs (§5), and an omitted grant_types defaults to authorization_code. - The AS SHOULD reject inconsistent grant/response combinations with invalid_client_metadata (§2.1). - Profiles that add values MUST document the correspondence between the two fields.  
   *Suggested change:* In ClientMetadata add: allOf [ {not: {required: [jwks_uri, jwks]}}, {if: {anyOf: [{not: {required: [grant_types]}}, {required: [grant_types], properties: {grant_types: {contains: {const: authorization_code}}}}]}, then: {required: [redirect_uris]}} ]. Also add a description table for the grants this spec models: authorization_code -> code; client_credentials, refresh_token, the device_code URN, the jwt-bearer URN and the token-exchange URN -> no response type. Validated: jwks plus jwks_uri, and a default code-flow client without redirect_uris, are rejected; a client_credentials-only registration passes.  
   *Verifier: partially correct —* The cited rules are right, but the proposed JSON-Schema enforcement over-rejects. Do not put 'if grant_types is absent or includes authorization_code then required [redirect_uris]' on the raw request or response schema. Enforce it after merging software-statement claims, either in handler logic or in a separate effective-metadata schema, and keep it off the OIDC read response. The jwks/jwks_uri exclusion can stay at the schema level.

9. **[MEDIUM] Gap: Registration-time redirect URI validation (rejected with invalid_redirect_uri)**  
   *Reference:* RFC 7591 §5, §3.2.2  
   Registered redirect URIs MUST be an https URL, an http URL on the local machine, or a non-HTTP private-use scheme available only to the client. OAuth 2.1 draft-16 §2.3 and §2.3.1 add more rules: the URI must be absolute, contain no fragment and be registered in full, and private-use schemes without a '.' SHOULD be rejected. The YAML describes only authorization-time exact matching (RedirectUri parameter, lines 716-730), not registration-time validation.  
   *Suggested change:* On ClientMetadata.redirect_uris.items add pattern '^[^#]*$'. Add a description of the allowed forms: https; http loopback, preferring 127.0.0.1 or [::1] over localhost per RFC 8252 §7.3/§8.3; a reverse-domain private-use scheme. State that violations return 400 invalid_redirect_uri. Validated: a URI with a fragment is rejected.  
   *Verifier: confirmed.*

10. **[MEDIUM] Gap: IANA client-metadata extensions from later RFCs for features this YAML already models: tls_client_auth_subject_dn, tls_client_auth_san_dns, tls_client_auth_san_uri, tls_client_auth_san_ip, tls_client_auth_san_email, tls_client_certificate_bound_access_tokens (RFC 8705); dpop_bound_access_tokens (RFC 9449); require_pushed_authorization_requests (RFC 9126); require_signed_request_object (RFC 9101)**  
   *Reference:* RFC 7591 §2, §4.1; RFC 8705 §2.1.2, §3.4; RFC 9449 §5.2; RFC 9126 §6; RFC 9101 §10.5, §9.3  
   All nine are in the IANA client-metadata registry and absent as client metadata. Only AS-level twins exist: tls_client_certificate_bound_access_tokens (line 2193), require_pushed_authorization_requests (2166), require_signed_request_object (2170). Consequences: - A DCR client cannot register for tls_client_auth, a method the YAML lists at line 2047; RFC 8705 §2.1.2 says the client MUST use exactly one subject parameter. - Per-client enforcement can't be expressed. RFC 9449 §5.2: if dpop_bound_access_tokens is true, the AS MUST reject token requests without a DPoP header. RFC 9101 §10.5: unsigned requests MUST be rejected. RFC 9126 §6: PAR-only.  
   *Suggested change:* Add to ClientMetadata: the five tls_client_auth_* properties (string), and booleans tls_client_certificate_bound_access_tokens, dpop_bound_access_tokens, require_pushed_authorization_requests and require_signed_request_object (each default: false). Add the conditional: if {required: [token_endpoint_auth_method], properties: {token_endpoint_auth_method: {const: tls_client_auth}}} then {oneOf: [{required: [tls_client_auth_subject_dn]}, {required: [tls_client_auth_san_dns]}, {required: [tls_client_auth_san_uri]}, {required: [tls_client_auth_san_ip]}, {required: [tls_client_auth_san_email]}]} (validated). Also mention dpop_bound_access_tokens in securitySchemes.dpop (lines 2648-2660).  
   *Verifier: confirmed.*

11. **[MEDIUM] Incorrect: lines 2037-2049 (values at 2042-2048): components.schemas.OAuthServerMetadata.properties.token_endpoint_auth_methods_supported.items.enum**  
   *Reference:* RFC 7591 §2 (token_endpoint_auth_method), §4.2  
   The items are a closed enum of the 7 currently registered methods. RFC 7591 §2 defines the token_endpoint_auth_method value space as the extensible IANA registry (§4.2) plus any absolute URI used without registration ('Absolute URIs can also be used as values for this parameter without being registered'). OIDC Registration §2 likewise allows methods defined by extensions. A schema validator therefore rejects valid metadata; verified, ['urn:example:auth:custom'] and ['private_key_jwt','attest_jwt_client_auth'] both fail against the current schema. New values are coming: attest_jwt_client_auth and attest_jwt_client_auth_dpop (draft-ietf-oauth-attestation-based-client-auth-11, in WG Last Call), and spiffe_jwt, spiffe_x509 and spiffe_wit (draft-ietf-oauth-spiffe-client-auth-02). The spec is also internally inconsistent: revocation_ and introspection_endpoint_auth_methods_supported (lines 2057-2068) are already open strings.  
   *Suggested change:* Extract components.schemas.TokenEndpointAuthMethod as anyOf [ {type: string, enum: [none, client_secret_basic, client_secret_post, client_secret_jwt, private_key_jwt, tls_client_auth, self_signed_tls_client_auth]}, {type: string, format: uri, pattern: '^[A-Za-z][A-Za-z0-9+.-]*:'} ]. Alternatively, follow the token_type_hint precedent at lines 1689-1696: plain type: string with examples, so future registrations need no spec change. Use it for these items, for the revocation and introspection *_auth_methods_supported arrays, and for ClientMetadata.token_endpoint_auth_method. Validated: registered values and absolute URIs pass.  
   *Verifier: partially correct —* The defect is real, but the primary fix does not meet its own goal of keeping the enum open for coming values. IANA registrations are bare names such as attest_jwt_client_auth (draft-ietf-oauth-attestation-based-client-auth-11 §15.6/§15.7), so the anyOf form still needs a spec edit for every new registration. Use type: string with examples (the token_type_hint precedent at 1689-1696), or anyOf [documented enum, {type: string}]. Also, draft-ietf-oauth-spiffe-client-auth-02 does not request IANA registration for spiffe_jwt/spiffe_x509/spiffe_wit; §4 only uses them in token_endpoint_auth_methods_supported. Until they are registered, they are outside RFC 7591 §2's value space (registered names or absolute URIs). Severity raised to medium: openapi-generator Java/C# clients deserialize enums strictly and would fail on conformant discovery documents.

12. **[LOW] Gap: Remaining RFC-registered client metadata: authorization_details_types (RFC 9396); introspection_signed_response_alg, introspection_encrypted_response_alg, introspection_encrypted_response_enc (RFC 9701); use_mtls_endpoint_aliases (IANA references RFC 8705 and FAPI 2.0)**  
   *Reference:* RFC 9396 §10; RFC 9701 §6; FAPI 2.0 Security Profile §5.2.2.1.1  
   Absent. Only AS-level counterparts exist: authorization_details_types_supported (line 2201), introspection_*_values_supported (2071-2079) and mtls_endpoint_aliases (1997-2013). Per RFC 9701 §6, introspection_signed_response_alg defaults to RS256, and introspection_encrypted_response_enc defaults to A128CBC-HS256 and MUST NOT be sent without introspection_encrypted_response_alg. A resource server registers these as a client, and they drive the application/token-introspection+jwt response at /introspect (lines 346-355).  
   *Suggested change:* Add to ClientMetadata: authorization_details_types (array of string); introspection_signed_response_alg (string, default RS256); introspection_encrypted_response_alg and introspection_encrypted_response_enc (string) with dependentRequired {introspection_encrypted_response_enc: [introspection_encrypted_response_alg]}; use_mtls_endpoint_aliases (boolean). Reference introspection_signed_response_alg in the /introspect JWT description.  
   *Verifier: confirmed.*

13. **[LOW] Gap: Security and privacy behaviors at registration: self-asserted metadata, display-URL checks, duplicate software_id/version, client-chosen client_id, shared secrets, public clients**  
   *Reference:* RFC 7591 §5, §6  
   These rules are description-level: - The AS MUST treat metadata not coming from a software statement as self-asserted, and MUST consider the whole request (statement, initial access token, JSON). - It SHOULD check that logo_uri, tos_uri, client_uri and policy_uri share host and scheme with redirect_uris. - It SHOULD treat a duplicate software_id plus software_version as suspect. - It SHOULD NOT issue the same client_secret to multiple instances. - Clients are forbidden from creating their own client_id (§6). - Public clients register token_endpoint_auth_method none. - Registrations MAY expire.  
   *Suggested change:* Add these points to the POST /register description. In ClientRegistrationRequest, describe client_id and client_secret as server-assigned: either ignored or rejected with invalid_client_metadata. Note that the value none means the response carries no client_secret and no client_secret_expires_at.  
   *Verifier: confirmed.*

14. **[LOW] Gap: Discovery hook and documentation tables**  
   *Reference:* RFC 7591 §1.2 (endpoint discovery out of scope); RFC 8414 §2 (registration_endpoint, service_documentation)  
   The registration_endpoint description (lines 1965-1968) says only 'Dynamic Client Registration endpoint (RFC 7591).' It doesn't link to an operation or say that RFC 8414 §2 makes the field OPTIONAL. RFC 7591 is also missing from the info.description 'Covered specifications' table (lines 18-45), from the tags (lines 88-102) and from the README endpoint table.  
   *Suggested change:* Extend the registration_endpoint description: 'OPTIONAL (RFC 8414 §2); URL of the POST /register operation; omit it when DCR is not offered, and use service_documentation to explain manual registration (RFC 8414 §2).' Add RFC 7591 rows to the covered-spec table and the README.  
   *Verifier: confirmed.*

15. **[LOW] Gap: The RFC's own example software statement violates §2.3's 'MUST contain an iss' rule** — *found by the verifier*  
   *Reference:* RFC 7591 §2.3, §3.1.1 (Errata ID 7969)  
   The RFC's own example software statement violates §2.3's 'MUST contain an iss' rule. A conformant AS has to reject it with invalid_software_statement, and it must not serve as a positive test vector for the proposed SoftwareStatementClaims (required [iss]). Neither the assessment nor the YAML says this.  
   *Suggested change:* In the SoftwareStatement and SoftwareStatementClaims descriptions, note that the RFC example lacks iss (Errata 7969) and that an AS enforcing §2.3 rejects it. Use an example that carries iss for positive tests.

16. **[LOW] Gap: Key-registration prerequisites for key-based auth methods are missing from the proposed cross-field rules** — *found by the verifier*  
   *Reference:* RFC 8705 §2.2, §2.2.2 (uses RFC 7591 §2 jwks/jwks_uri); OIDC Core §9  
   Key-registration prerequisites for key-based auth methods are missing from the proposed cross-field rules. self_signed_tls_client_auth requires the client to register its certificate(s) through jwks or jwks_uri, and private_key_jwt presupposes a registered public key. The assessment's conditionals cover only tls_client_auth's subject parameter.  
   *Suggested change:* Add: if token_endpoint_auth_method is self_signed_tls_client_auth or private_key_jwt, then anyOf [required [jwks], required [jwks_uri]]. Enforce it after merging software-statement claims, and describe the x5c certificate requirement for the self-signed method.

17. **[LOW] Gap: The MUST-level client_secret uniqueness rule is missing for RFC 7591; the assessment cites only §5's SHOULD NOT about reuse across instances.** — *found by the verifier*  
   *Reference:* RFC 7591 §3.2.1 (client_secret)  
   The MUST-level client_secret uniqueness rule is missing for RFC 7591; the assessment cites only §5's SHOULD NOT about reuse across instances.  
   *Suggested change:* In ClientInformationResponse.client_secret, add: 'MUST be unique per client_id (RFC 7591 §3.2.1); OIDC Registration §3.2 forbids reuse across clients altogether.'

18. **[LOW] Gap: Software statement used directly as client_id** — *found by the verifier*  
   *Reference:* RFC 7591 §2.3  
   Software statement used directly as client_id. RFC 7591 lets an AS accept a software statement as the client_id in an authorization request with no prior registration, but the YAML's ClientId parameter describes only an AS-issued identifier. CIMD URL client_ids, which the assessment cites as the forward path, likewise show that client_id is not always 'issued at registration time'.  
   *Suggested change:* Broaden the ClientId description: normally AS-issued, but an AS MAY accept a software statement (RFC 7591 §2.3) or a Client ID Metadata Document URL (draft-ietf-oauth-client-id-metadata-document) as client_id.

19. **[LOW] Gap: Registration-time checks of client-supplied URLs, and their SSRF exposure** — *found by the verifier*  
   *Reference:* RFC 7591 §2 (jwks_uri, client_uri, logo_uri, tos_uri, policy_uri), §5  
   Registration-time checks of client-supplied URLs, and their SSRF exposure. Several metadata URLs MUST point to valid documents, and §5 asks the AS to check that display URLs resolve and to protect users from malicious content. The assessment mentions SSRF-safe fetching only for sector_identifier_uri, and its security item quotes only the host/scheme check.  
   *Suggested change:* In the POST /register description, list the URLs the AS may fetch at registration: sector_identifier_uri MUST be fetched; jwks_uri and the display URLs SHOULD/MAY be. Require SSRF protections (https only, no private or loopback IP ranges, size and time limits) and state the resulting error (invalid_client_metadata).

20. **[LOW] Incorrect: A second YAML location conflicts with the OAuth 2.1 default and was missed by the cross-cluster note** — *found by the verifier*  
   *Reference:* RFC 7591 §2 (token_endpoint_auth_method default); OAuth 2.1 draft-16 §2.4.1  
   A second YAML location conflicts with the OAuth 2.1 default and was missed by the cross-cluster note. Besides securitySchemes.clientSecretBasic, ClientAuthFields.client_secret also calls Basic preferred and client_secret_post NOT RECOMMENDED. The YAML claims OAuth 2.1 defaults (line 8), and this wording determines which token_endpoint_auth_method an OAuth 2.1-profile AS should register when a DCR request omits it.  
   *Suggested change:* Reword ClientAuthFields.client_secret, together with securitySchemes.clientSecretBasic (2662-2674), to reflect OAuth 2.1 draft-16 §2.4.1. Say that an OAuth 2.1-profile AS replaces the RFC 7591 default with client_secret_post when Basic isn't supported, and echoes the method it registered (RFC 7591 §3.2.1).

## RFC 7592 OAuth 2.0 Dynamic Client Registration Management Protocol

*July 2015 · Experimental · YAML coverage: **none** · relevance to an AS: optional · vendoring: already-vendored*

**What it is.** RFC 7592 adds lifecycle management on top of RFC 7591. The registration response also returns a per-client 'client configuration endpoint' URL (registration_client_uri) and a 'registration access token' (a Bearer token bound to that one client). With these, the client can read its registration (GET), replace it (PUT, a full replacement rather than a patch) or deprovision it (DELETE, answered with 204). The AS can rotate the client secret and the registration access token on read or update. The RFC is Experimental, and not every DCR server offers it.

**Why it was created.** A client's registered metadata changes over its life: new redirect URIs, key rotation, expiring secrets. Without a management API the only remedy is re-registering, which issues a new client_id and orphans existing grants and user consents. RFC 7592 standardizes read/update/delete and credential rotation. The operations were kept outside the Standards-Track core and published as Experimental to gather implementation experience for a future standard (RFC 7592 §1).

<details><summary>Already modeled in the YAML (2)</summary>

- None of RFC 7592's own elements: the YAML has no 7592 reference, no registration_access_token and no registration_client_uri.
- Reusable building blocks only, not RFC 7592-specific: securitySchemes.bearerAuth (lines 2637-2646) as an RFC 6750 Bearer scheme; headers.WWWAuthenticateBearerDPoP (lines 1000-1025) for the Bearer error syntax; headers.CacheControlNoStore/PragmaNoCache (lines 990-999) for the 200/204 responses

</details>

**Follow-up on the May-2026 validation notes.** No prior validation note exists for RFC 7592, and no audit note mentions it, so there is nothing to follow up.

**Notes.** IANA-absent attribution: both RFC 7592 client-metadata names (registration_access_token, registration_client_uri) are absent. Design caveat: RFC 7592 §3 / App. A.1 and OIDC Registration §4.3 disagree on whether read responses must repeat these two values. Keep the base ClientInformationResponse permissive and enforce the rule per profile; the prototype passes both the RFC 7592 §3 and OIDC §4.3 examples.

### Findings (0 high · 5 medium · 3 low)

1. **[MEDIUM] Gap: Client configuration endpoint: GET (read), PUT (update), DELETE (deprovision) at registration_client_uri**  
   *Reference:* RFC 7592 §2, §2.1, §2.2, §2.3, Appendix B  
   No operations exist. The endpoint is an OAuth 2.0 protected resource at a fully qualified URL chosen by the server. Clients MUST use it exactly as given and never construct it (App. B); the RECOMMENDED forms are /register/{client_id} or /register?client_id=... Status codes: GET returns 200 with a Client Information Response, PUT (application/json) returns 200, and DELETE MUST return 204 No Content. A method the server does not support gets the appropriate error code, and for DELETE that MUST be 405.  
   *Suggested change:* Add paths./register/{client_id} with a path parameter client_id, described as illustrative of the App. B RECOMMENDED form (clients MUST NOT construct the URL). Operations, each with security [{registrationAccessToken: []}]: - get readClientConfiguration: 200 -> ClientInformationResponse with no-store headers; 401, 403, 405. - put updateClientConfiguration: requestBody application/json -> ClientUpdateRequest; 200; 400 -> ClientRegistrationError; 401, 403, 405. - delete deleteClientConfiguration: 204 with Cache-Control/Pragma; 401, 403, 405. Link the operations from the POST /register 201 response with OpenAPI links (client_id from $response.body#/client_id). The prototype lints at 0 errors and 0 warnings.  
   *Verifier: partially correct —* The gap is real, but the suggested change contradicts the gap's own detail. An OpenAPI link that copies $response.body#/client_id into /register/{client_id} is exactly constructing the URL from component pieces, which App. B forbids. A fixed /register/{client_id} path also can't express the other conformant layouts: the query form used by every OIDC Registration example (/connect/register?client_id=...) and the same-URL form App. B allows. Model the operations as illustrative only, drop the link (or replace it with prose saying the URL comes only from registration_client_uri), and document both alternatives.

2. **[MEDIUM] Gap: registration_client_uri and registration_access_token members of the client information response**  
   *Reference:* RFC 7592 §3, §4, Appendix A.1  
   §3 makes both REQUIRED in the client information response when the management protocol is offered; both are absent (IANA-absent list). App. A.1 says read and update responses MUST include the client's current registration access token and credentials. OIDC Registration differs: both are OPTIONAL but must come as a pair (§3.2), and a read response need not repeat them unless they were rotated (§4.3). A single unconditional required list would therefore reject valid OIDC responses; verified with the OIDC §4.3 example.  
   *Suggested change:* Add registration_access_token {type: string} and registration_client_uri {type: string, format: uri, pattern: '^https://'} to ClientInformationResponse. On the 201 variant (ClientRegistrationResponse) add dependentRequired {registration_access_token: [registration_client_uri], registration_client_uri: [registration_access_token]}. Document that an RFC 7592 deployment returns both on 201 and on every 200 (App. A.1).  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: Registration access token (Bearer) and error semantics: 401 for an invalid token or unknown client, 403 when forbidden, never 404**  
   *Reference:* RFC 7592 §1.2, §2, §2.1, §2.2, §2.3, §5  
   No security scheme exists. Rules: - The client MUST present its registration access token as an RFC 6750 Bearer token. - An invalid token gets an RFC 6750 error (401 plus WWW-Authenticate). - If the client does not exist, the AS MUST return 401 and SHOULD revoke the token. - Insufficient permission MUST return 403. - After deprovisioning, requests MUST be treated as an invalid token and get 401 (§5). OIDC Registration §4.4 adds that these endpoints MUST NOT return 404.  
   *Suggested change:* Add components.securitySchemes.registrationAccessToken {type: http, scheme: bearer, description: 'RFC 7592 §1.2 — bound to one client_id; SHOULD NOT expire while the client is registered; MUST have sufficient entropy (§5)'}. Reuse RegistrationTokenError (401 with WWW-Authenticate: Bearer) and add 403 responses. Say in each operation description that 404 is deliberately not used.  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: Client update request (PUT) body constraints**  
   *Reference:* RFC 7592 §2.2  
   PUT is a full replacement: - The body MUST include all metadata previously returned. Omitted fields count as deletions, and valid values replace the old ones rather than add to them. - It MUST include client_id equal to the issued one. - client_secret, if sent, MUST match the current secret; the client cannot choose its own. - It MUST NOT include registration_access_token, registration_client_uri, client_secret_expires_at or client_id_issued_at. - The AS MAY substitute defaults and MUST return them. - Invalid metadata gets the RFC 7591 §3.2.2 error.  
   *Suggested change:* Add components.schemas.ClientUpdateRequest: allOf [ {$ref: ClientMetadata}, {type: object, required: [client_id], properties: {client_id: {type: string}, client_secret: {type: string}, software_statement: {$ref: SoftwareStatement}}, not: {anyOf: [{required: [registration_access_token]}, {required: [registration_client_uri]}, {required: [client_secret_expires_at]}, {required: [client_id_issued_at]}]}} ]. Describe the replace semantics. Validated: the RFC 7592 §2.2 example passes; bodies carrying registration_access_token, or lacking client_id, are rejected.  
   *Verifier: confirmed.*

5. **[MEDIUM] Gap: Server-side binding check at the client configuration endpoint, plus the same-URL deployment option** — *found by the verifier*  
   *Reference:* RFC 7592 Appendix B; OIDC Registration §4.1  
   Server-side binding check at the client configuration endpoint, plus the same-URL deployment option. The server MUST verify that the client the request addresses (path or query client_id) is the client the registration access token was issued to; skipping this check lets one client read or change another client's record. The configuration endpoint MAY also be the registration endpoint URL itself, with behavior chosen by the token. The assessment never states the check (it only says 'bound to one client_id'), and its fixed /register/{client_id} design cannot express the same-URL option.  
   *Suggested change:* In securitySchemes.registrationAccessToken and in the GET/PUT/DELETE descriptions, add: 'The AS MUST verify that the client addressed by the URL is the client the registration access token was issued to; on mismatch respond 401 invalid_token (never 404, OIDC §4.4).' Also note that a deployment MAY serve these operations on registration_endpoint itself, and treat the path form as illustrative.

6. **[LOW] Gap: Deprovisioning side effects and 405 handling**  
   *Reference:* RFC 7592 §2, §2.3, §5  
   A successful DELETE invalidates client_id, client_secret and the registration access token. The AS SHOULD also invalidate all grants and tokens of the client, and MUST invalidate any outstanding registration access tokens (§5). A server that doesn't support a method MUST answer with the appropriate code (405).  
   *Suggested change:* Describe these effects on the DELETE operation. Declare 405 on GET, PUT and DELETE; a server implementing only OIDC Registration supports just GET. Send Cache-Control: no-store and Pragma: no-cache on the 204, as in the RFC example.  
   *Verifier: confirmed.*

7. **[LOW] Gap: Rotation of the client secret and the registration access token**  
   *Reference:* RFC 7592 §2.1, §2.2, §5, Appendix A, Appendix A.1  
   Read and update responses MAY carry a new client_secret and/or registration access token. The client MUST discard the old values immediately, and client_id MUST NOT change. Rotation SHOULD happen only on read or update, and the token SHOULD NOT expire while the client is registered. Without these descriptions, generated clients won't know to persist rotated values.  
   *Suggested change:* Add these rules to the ClientInformationResponse.client_secret and registration_access_token descriptions, and to the GET and PUT operation descriptions.  
   *Verifier: confirmed.*

8. **[LOW] Gap: Status signalling and documentation**  
   *Reference:* RFC 7592 §1, §1.3  
   Once the operations are added, readers should be told three things. RFC 7592 is Experimental. It is optional even among DCR servers. OIDC Registration defines only the GET read on the same endpoint.  
   *Suggested change:* Tag the operations 'Client Registration'. Add an experimental banner to their descriptions (or an x-status: experimental extension). Add a covered-spec row 'RFC 7592 | 2015 | DCR Management (Experimental)'.  
   *Verifier: confirmed.*

## OIDC Dynamic Client Registration 1.0 OpenID Connect Dynamic Client Registration 1.0 incorporating errata set 2

*February 2014 (errata set 2: December 2023) · OpenID Foundation Final Specification (errata set 2, 15 Dec 2023); also published as ISO/IEC 26133:2024 · YAML coverage: **referenced-only** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** This is the OpenID Foundation's registration protocol for Relying Parties. RFC 7591 later generalized it, and the two are wire-compatible: POST JSON metadata, get 201 with a client_id. It adds OIDC-specific metadata:
- application_type (web or native), which drives redirect-URI rules
- subject_type and sector_identifier_uri, for pairwise (per-RP) subject identifiers
- signing and encryption algorithm choices for ID Tokens, UserInfo responses and Request Objects
- default_max_age, require_auth_time and default_acr_values
- initiate_login_uri and request_uris
It also defines a read-only client configuration endpoint. OpenID Connect Core §15.2 makes it mandatory for OPs that serve RPs they have no prior relationship with.

**Why it was created.** OpenID Connect's open-ecosystem goal is that an RP can discover and use an OP it has never dealt with. That requires getting a client_id on the fly. The RP also needs to declare preferences that OAuth 2.0 core never defined: pairwise subjects to prevent correlation across RPs, encrypted ID Tokens or UserInfo, signed request objects, and its keys.

<details><summary>Already modeled in the YAML (4)</summary>

- registration_endpoint: OAuthServerMetadata.properties.registration_endpoint (lines 1965-1968), inherited by OpenIDProviderMetadata (lines 1907-1921). OIDC Discovery §3 makes it RECOMMENDED and https, but https is not enforced
- token_endpoint_auth_methods_supported values client_secret_jwt and private_key_jwt (lines 2045-2046), which OIDC Registration §10.2.1 registered (OIDC Core §9)
- OP-side counterparts of the client's choices: subject_types_supported [public, pairwise] (lines 2116-2121) for subject_type; the id_token_*/userinfo_*/request_object_* algorithm arrays (lines 2082-2113) for the *_response_alg/enc and request_object_* metadata; token_endpoint_auth_signing_alg_values_supported (2050-2056) for token_endpoint_auth_signing_alg; acr_values_supported (2149-2151) for default_acr_values; require_request_uri_registration (2162-2165) for request_uris
- userinfo_signed_response_alg is named in the prose of the GET and POST /userinfo application/jwt responses (lines 506-511, 556-561)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation note exists for OIDC Registration. Related items in other notes:
- rfc-validation/oidc-discovery-1.0.md recorded registration_endpoint as present. Still true (lines 1965-1968).
- The same note tied require_request_uri_registration to the request_uris registration parameter. The YAML description (lines 2162-2165) still doesn't mention request_uris.
- rfc-validation/oidc-core-1.0.md classified initiate_login_uri as RP-side and not applicable. Still unmodeled.
- The same note flagged the missing 'registration' authorization-request parameter (OIDC Core §7.2.1, self-issued OPs). Still absent; only the registration_not_supported error exists (line 1517).

**Notes.** The endpoint gap (first gap) duplicates RFC 7591's first gap by necessity. Other shared mechanics are listed only under RFC 7591 to avoid double counting: the core metadata fields, software statements, and language tags (OIDC §2.1 = RFC 7591 §2.2). IANA-absent attribution: 17 of OIDC Registration's 18 client-metadata names are listed absent; userinfo_signed_response_alg matches only in /userinfo prose. The spec was not vendored when this was written. *(Update 2026-10-11: now vendored as [`openid-connect-registration-1_0.html`](../../oidf-sources/openid-connect-registration-1_0.html), errata set 2, dated 15 Dec 2023.)* ISO/IEC 26133:2024 is the ISO publication of the same text.

### Findings (2 high · 7 medium · 7 low)

1. **[HIGH] Gap: Client Registration Endpoint (OIDC §3): the same missing POST operation as in the RFC 7591 entry, plus OIDC-specific rules**  
   *Reference:* OIDC Registration §3, §3.1, §3.2; OIDC Core §15.2  
   Absent (one operation fixes this and RFC 7591 gap 1). OIDC-specific rules: - The endpoint is an OAuth 2.0 Protected Resource. - It SHOULD accept requests without access tokens. - If an Initial Access Token is required, it MUST be accepted in the RFC 6750 manner. - It SHOULD support CORS for browser-based clients. - Success SHOULD be 201 with application/json. OIDC Core §15.2 makes Dynamic Registration a MUST for OPs serving RPs they have no pre-configured relationship with, and this YAML already invokes 'dynamic provider' rules in response_types_supported (lines 2022-2026).  
   *Suggested change:* Use the paths./register.post operation proposed for RFC 7591, and add to its description: 'OIDC Registration §3: SHOULD support CORS (Access-Control-Allow-Origin on 201/400 responses, plus an OPTIONS preflight)'. Add OpenID.Registration to externalDocs, and add pattern '^https://' to OAuthServerMetadata.registration_endpoint, as OIDC Discovery §3 requires https.  
   *Verifier: confirmed.*

2. **[HIGH] Gap: application_type (web or native, default web) and the AS-side check of redirect_uris**  
   *Reference:* OIDC Registration §2 (application_type, redirect_uris)  
   Absent. OIDC makes redirect_uris REQUIRED, with simple string comparison at authorization time. Native clients MUST register only custom-scheme URIs or http loopback URIs (localhost, 127.0.0.1, [::1]). Web clients using implicit MUST register only https URIs and MUST NOT use localhost. The AS MUST verify that every registered redirect URI conforms. MCP's latest spec (2026-07-28) requires MCP clients to send an appropriate application_type during DCR, because omitting it defaults to web and can break native loopback redirects. So the field shows up in real traffic even at OAuth-only servers.  
   *Suggested change:* Add application_type {type: string, enum: [web, native], default: web} to ClientMetadata. Document the per-type redirect URI rules and state that violations return 400 invalid_redirect_uri.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: subject_type (public or pairwise) and sector_identifier_uri, including the §5 registration-time validation**  
   *Reference:* OIDC Registration §2, §5; OIDC Core §8.1  
   Absent, although the OP-side subject_types_supported enum exists (lines 2116-2121). sector_identifier_uri MUST be an https URL of a JSON array that contains every registered redirect URI. The AS must fetch and validate it at registration time, and registration MUST fail otherwise. OPs that issue pairwise identifiers SHOULD use it when computing the pairwise sub value.  
   *Suggested change:* Add subject_type {type: string, enum: [public, pairwise]} (values must appear in subject_types_supported) and sector_identifier_uri {type: string, format: uri, pattern: '^https://'} to ClientMetadata. Describe the §5 fetch and validation, the resulting error (400 invalid_client_metadata or invalid_redirect_uri), and SSRF-safe fetching.  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: Algorithm preferences: id_token_signed_response_alg, id_token_encrypted_response_alg/_enc, userinfo_signed_response_alg, userinfo_encrypted_response_alg/_enc, request_object_signing_alg, request_object_encryption_alg/_enc, token_endpoint_auth_signing_alg**  
   *Reference:* OIDC Registration §2  
   All ten are absent as client metadata; only the OP-side *_values_supported arrays exist (lines 2050-2056, 2082-2113). Wire rules: - id_token_signed_response_alg defaults to RS256. The value none is allowed only when no ID Token comes from the authorization endpoint. - Each *_enc defaults to A128CBC-HS256 when its *_alg is set, and MUST NOT appear without it. - token_endpoint_auth_signing_alg MUST NOT be none. - A registered request_object_signing_alg MUST be used for every Request Object, by value or by reference. none MAY be used.  
   *Suggested change:* Add the ten string properties to ClientMetadata with these constraints, all validated: - id_token_signed_response_alg default RS256 - token_endpoint_auth_signing_alg {type: string, not: {const: none}} - dependentRequired {id_token_encrypted_response_enc: [id_token_encrypted_response_alg], userinfo_encrypted_response_enc: [userinfo_encrypted_response_alg], request_object_encryption_enc: [request_object_encryption_alg]} - if {required: [response_types], properties: {response_types: {contains: {pattern: 'id_token'}}}} then {properties: {id_token_signed_response_alg: {not: {const: none}}}} Cross-reference each property to its *_values_supported array.  
   *Verifier: confirmed.*

5. **[MEDIUM] Gap: Authentication defaults: default_max_age, require_auth_time, default_acr_values**  
   *Reference:* OIDC Registration §2  
   Absent. default_max_age (seconds) applies when a request carries no max_age. require_auth_time=true makes auth_time REQUIRED in the ID Token. default_acr_values (ordered by preference) requests acr as a voluntary claim and is overridden by acr_values or a claims request.  
   *Suggested change:* Add default_max_age {type: integer, minimum: 0}, require_auth_time {type: boolean, default: false} and default_acr_values {type: array, items: {type: string}}, with values drawn from acr_values_supported (lines 2149-2151).  
   *Verifier: confirmed.*

6. **[MEDIUM] Gap: OIDC rules for the registration response: https registration_client_uri, returned together with registration_access_token, no substitution of redirect_uris, unique client_id and client_secret, unknown fields ignored**  
   *Reference:* OIDC Registration §3.2  
   Not modeled. Rules: - registration_client_uri MUST use https. - Implementations MUST return both a Client Configuration Endpoint and a Registration Access Token, or neither. - The AS MAY replace requested values except redirect_uris, which must be accepted as sent or the request rejected. It MUST include every replaced field in the response. - client_id MUST NOT be valid for any other client. This is stricter than RFC 7591 §3.2.1, which says SHOULD NOT. - The same client_secret MUST NOT be assigned to multiple clients. - client_secret also seeds symmetric key derivation (OIDC Core §10.2).  
   *Suggested change:* Model the 201 body as ClientRegistrationResponse: allOf [ {$ref: ClientInformationResponse}, {dependentRequired: {registration_access_token: [registration_client_uri], registration_client_uri: [registration_access_token]}} ], with registration_client_uri pattern '^https://' (validated against the OIDC §3.2 example). Add the substitution and uniqueness rules to the descriptions.  
   *Verifier: confirmed.*

7. **[MEDIUM] Gap: Read on the Client Configuration Endpoint (OIDC defines GET only) and its error rules**  
   *Reference:* OIDC Registration §4, §4.1, §4.2, §4.3, §4.4  
   Not modeled; the RFC 7592 entry covers the full GET/PUT/DELETE surface. OIDC defines only GET: - It SHOULD be idempotent and SHOULD return 200 with all registered metadata. - It need not repeat registration_access_token or registration_client_uri unless they were updated. - An invalid token, or an unknown or invalid client, MUST get 401. No permission MUST get 403. - The endpoint MUST NOT return 404, to inhibit brute-force probing. - It SHOULD support CORS. The OIDC examples use the query form /connect/register?client_id=...  
   *Suggested change:* Reuse paths./register/{client_id}.get (readClientConfiguration) with the ClientInformationResponse schema, without an unconditional required [registration_access_token, registration_client_uri] (validated with the §4.3 example). Declare only 200, 401 and 403 (no 404), and note that the query-parameter URL form is an equally valid server choice.  
   *Verifier: confirmed.*

8. **[MEDIUM] Gap: Client metadata from OIDF companion specs whose server-side features this YAML already advertises: post_logout_redirect_uris; frontchannel_logout_uri, frontchannel_logout_session_required; backchannel_logout_uri, backchannel_logout_session_required; authorization_signed_response_alg, authorization_encrypted_response_alg, authorization_encrypted_response_enc; backchannel_token_delivery_mode, backchannel_client_notification_endpoint, backchannel_authentication_request_signing_alg, backchannel_user_code_parameter**  
   *Reference:* OIDC Registration §2 (closing paragraph: metadata defined by other specifications); RP-Initiated Logout 1.0 §3.1; Front-Channel Logout 1.0 §2; Back-Channel Logout 1.0 §2.2; JARM §3; CIBA Core 1.0 §4  
   The YAML advertises end_session_endpoint (line 1989), the front- and back-channel logout support flags (lines 2220-2231), the JWT response modes (line 2031) and CIBA metadata (lines 2238-2248). An RP that registers dynamically has no way to register the matching client values. The logout and JARM names are in the IANA client-metadata registry. The four CIBA names are defined in CIBA Core §4 but are not in the IANA registry (checked against the 2026-08-24 snapshot). Per CIBA §4, backchannel_token_delivery_mode is REQUIRED for CIBA clients, and backchannel_client_notification_endpoint is REQUIRED for ping and push and MUST be https.  
   *Suggested change:* Add the twelve properties to ClientMetadata, each with a one-line source citation: - URIs with format: uri; post_logout_redirect_uris as an array of uri - the logout *_session_required booleans, default false - backchannel_token_delivery_mode as enum [poll, ping, push] Optionally add: if delivery mode is ping or push, then backchannel_client_notification_endpoint is required.  
   *Verifier: confirmed.*

9. **[MEDIUM] Gap: Per-client algorithm pinning at the endpoints is not carried into the YAML** — *found by the verifier*  
   *Reference:* OIDC Registration §2 (token_endpoint_auth_signing_alg, request_object_signing_alg)  
   Per-client algorithm pinning at the endpoints is not carried into the YAML. A client that registered token_endpoint_auth_signing_alg must have token requests rejected when the client_assertion JWT uses any other alg. A client that registered request_object_signing_alg must have Request Objects rejected at /authorize and /par when they use any other alg. The assessment records only 'MUST NOT be none' as a metadata property rule and proposes no wiring into /token, /authorize or /par, unlike its dpop_bound_access_tokens item.  
   *Suggested change:* Extend ClientAuthFields.client_assertion: 'If the client registered token_endpoint_auth_signing_alg, the AS MUST reject assertions signed with any other alg (invalid_client).' Extend Request, RequestUri and PARRequest: 'If the client registered request_object_signing_alg, Request Objects using any other alg MUST be rejected (invalid_request_object).'

10. **[LOW] Gap: initiate_login_uri and request_uris**  
   *Reference:* OIDC Registration §2; OIDC Core §4, §6.2  
   Absent. initiate_login_uri is an https endpoint at the RP, accepting GET and POST, for login initiated by a third party. request_uris pre-registers request_uri values: https unless the Request Object is verifiably signed, with a fragment that SHOULD carry the base64url SHA-256 of the content. request_uris is what require_request_uri_registration (lines 2162-2165) refers to. By contrast, the RequestUri parameter (lines 857-868) deliberately models only PAR-issued URNs.  
   *Suggested change:* Add initiate_login_uri {type: string, format: uri, pattern: '^https://'} and request_uris {type: array, items: {type: string, format: uri}} to ClientMetadata. Extend the require_request_uri_registration description: 'values are pre-registered via the request_uris client metadata (OIDC Registration §2)'.  
   *Verifier: confirmed.*

11. **[LOW] Gap: Error semantics: OAuth errors per RFC 6750 §3; registration errors as 400 with an open error-code set**  
   *Reference:* OIDC Registration §3.3  
   OIDC defines invalid_redirect_uri and invalid_client_metadata (shared with RFC 7591) and adds 'Other error codes MAY also be used', so client-side schemas must not close the set. OAuth token errors use the RFC 6750 §3 format via WWW-Authenticate.  
   *Suggested change:* In ClientRegistrationErrorResponse.error use anyOf [ {type: string, enum: [invalid_redirect_uri, invalid_client_metadata, invalid_software_statement, unapproved_software_statement]}, {type: string} ] (validated: an unlisted code is accepted). Reference RegistrationTokenError for the 401.  
   *Verifier: confirmed.*

12. **[LOW] Gap: Existing YAML descriptions that depend on registered metadata are incomplete**  
   *Reference:* OIDC Registration §2 (userinfo_encrypted_response_alg, require_auth_time); OIDC Core §5.3.2  
   The GET and POST /userinfo application/jwt descriptions (lines 506-511, 556-561) cite only userinfo_signed_response_alg. Registering only userinfo_encrypted_response_alg also produces application/jwt; OIDC Core §5.3.2 says 'The response MAY be encrypted without also being signed'. Such an unsigned payload need not carry iss and aud, so it doesn't conform to UserInfoSignedResponse (line 2409). Separately, IDTokenClaims.auth_time (lines 2489-2491) lists the max_age and essential-claim triggers but omits require_auth_time=true, which also makes auth_time REQUIRED.  
   *Suggested change:* Reword lines 506-511 and 556-561 to: 'when the client registered userinfo_signed_response_alg and/or userinfo_encrypted_response_alg … iss and aud are mandatory only when signed'. Extend line 2491 to: 'REQUIRED if max_age was requested, auth_time is an Essential Claim, or the client registered require_auth_time=true (OIDC Registration §2)'.  
   *Verifier: confirmed.*

13. **[LOW] Gap: Grant-type and response-type correspondence under this repo's OAuth 2.1 profile**  
   *Reference:* OIDC Registration §2 (grant_types table); RFC 7591 §2.1  
   ResponseType (lines 703-706) allows id_token and 'code id_token'. OIDC Registration §2 says those response types require the grant_types value implicit ('code id_token' needs authorization_code plus implicit), yet this YAML excludes the implicit grant. This is not a request to model the implicit grant. A DCR validator does need a documented profile decision, for example: accept implicit in grant_types only as the OIDC label paired with id_token-bearing response types, and never together with token. Without one, hybrid-flow clients can't register consistently.  
   *Suggested change:* Add the correspondence table and the profile rule to the ClientMetadata.grant_types and response_types descriptions, and mirror them in the ResponseType description (lines 690-700).  
   *Verifier: confirmed.*

14. **[LOW] Gap: Rules for client key material in jwks_uri and jwks**  
   *Reference:* OIDC Registration §2 (jwks_uri, jwks)  
   Rules: - jwks_uri MUST use https. - When a set mixes signing and encryption keys, every key MUST carry use. - x5c, if present, must match the bare key. - The set MUST NOT contain private or symmetric key values. - jwks MUST NOT be used when jwks_uri is possible. Reusing the AS's JWK schema (lines 1822-1902) unchanged would accept a symmetric k member (line 1900) or private members.  
   *Suggested change:* Define components.schemas.PublicJWK: allOf [ {$ref: JWK}, {not: {anyOf: [{required: [d]}, {required: [p]}, {required: [q]}, {required: [dp]}, {required: [dq]}, {required: [qi]}, {required: [oth]}, {required: [k]}]}} ]. Define a ClientJWKS (keys: array of PublicJWK) and use it for ClientMetadata.jwks. Add pattern '^https://' to ClientMetadata.jwks_uri.  
   *Verifier: confirmed.*

15. **[LOW] Gap: Under OIDC a client_secret can be needed purely for symmetric-key derivation, including for private_key_jwt clients that request symmetric encryption, and reque** — *found by the verifier*  
   *Reference:* OIDC Registration §3.2 (client_secret), §2 (request_object_encryption_alg); OIDC Core §10.2  
   Under OIDC a client_secret can be needed purely for symmetric-key derivation, including for private_key_jwt clients that request symmetric encryption, and request_object_encryption_alg is the signal. The assessment's proposed note ('none means no client_secret') covers only the none case and misses when an AS must issue a secret to a client that doesn't authenticate with one.  
   *Suggested change:* Document in ClientInformationResponse.client_secret and request_object_encryption_alg that the AS issues a client_secret (with client_secret_expires_at) whenever symmetric JWE (ID Token, UserInfo or Request Object) is registered, whatever the token_endpoint_auth_method.

16. **[LOW] Gap: String comparison rules** — *found by the verifier*  
   *Reference:* OIDC Registration §6 (String Operations)  
   String comparison rules. OIDC Registration requires code-point equality with no Unicode normalization for its string comparisons, such as registered redirect_uris against the sector_identifier_uri array and the authorization-time redirect_uri. Neither the assessment nor the YAML states it.  
   *Suggested change:* Add to the redirect_uris and sector_identifier_uri descriptions (and to RedirectUri): 'compare as code-point sequences after JSON unescaping; no Unicode normalization (OIDC Registration §6; RFC 3986 §6.2.1 simple string comparison).'

## Verifier corrections to the summaries above

- RFC 7591 why_created: 'Each ecosystem had already invented an incompatible registration API (OpenID Connect, UMA)' is wrong. RFC 7591 §1 says it 'generalizes the registration mechanisms defined by OpenID Connect Dynamic Client Registration 1.0 and used by ... UMA ... in a way that is compatible with both'; UMA reused OIDC's mechanism. 'It added initial access tokens' is also inaccurate: OIDC Registration (Feb 2014) §1.2 and §3 already defined the Initial Access Token. The software statement was RFC 7591's genuinely new mechanism.
- RFC 7591 summary: 'two IANA registries ... that every later OAuth extension uses to add per-client settings' overgeneralizes. The Token Endpoint Authentication Methods registry holds client-authentication method names, used in both client and AS metadata, not per-client settings, and many extensions register no client metadata.
- cluster_notes and the drafts note: the audit line that classifies client_id_metadata_document_supported as an 'Auth0' field is references/audit/rfc-audit-synthesis.md:281, not :280. Line 282 is the DCR deferral.
- cluster_notes BOTTOM LINE: 'The only DCR traces ... are (a)(b)(c)' overstates. The YAML also references registered client metadata in the /userinfo application/jwt descriptions (506-511, 556-561: 'when the client registered a userinfo_signed_response_alg'). require_request_uri_registration (2162-2165) presupposes request_uris pre-registration. The OIDC entry's own modeled_elements list these and the OP-side counterparts.
- Validation claims (RFC 7591 notes and cluster_notes): '25 of 25 ... including all RFC 7591 examples verbatim' overstates. The harness truncates the §3.1 jwks example's 'n' value and omits both §3.2.2 error examples and the §2.3 claims set. I re-ran the verbatim examples and they pass, so the conclusion stands. Several 'validated' statements are not in the harness. The tls_client_auth one-of conditional and the id_token 'none' conditional work when tested separately, but the '^https://' pattern on registration_client_uri is absent from the prototype, and the prototype does not reject private or symmetric jwks keys or an http jwks_uri.
- cluster_notes IN-FLIGHT REGISTRY GROWTH: spiffe_jwt, spiffe_x509 and spiffe_wit are not 'registry growth'. draft-ietf-oauth-spiffe-client-auth-02 §9 requests only the client-assertion-type URN and the spiffe_id/spiffe_bundle_endpoint client metadata; §4 merely uses the three names in token_endpoint_auth_methods_supported. The attestation draft-11 does request attest_jwt_client_auth and attest_jwt_client_auth_dpop (§15.6, §15.7).
- cluster_notes RECOMMENDED SHAPE: 'TokenEndpointAuthMethod (open)' is not open. The anyOf [closed enum, absolute-URI pattern] rejects bare future registrations such as attest_jwt_client_auth and attest_jwt_client_auth_dpop (verified on the merged prototype). Use type: string with examples, or anyOf [enum, {type: string}].
- cluster_notes RECOMMENDED SHAPE: making 'redirect_uris required for code-flow clients' a JSON-Schema rule on the request body wrongly rejects RFC 7591 requests whose redirect_uris come from the software statement (§2: 'a mixture of both is also possible'); I reproduced this. The OpenAPI links from the 201 to /register/{client_id} build the configuration URL from client_id, which RFC 7592 App. B and OIDC §4.1 forbid ('MUST NOT construct this URL from component pieces').
- cluster_notes IANA HOUSEKEEPING: CIBA Core §16.2 does request registration of its four client-metadata names, so their absence from the 2026-08-24 registry is an IANA backlog, not an omission by CIBA. Also, IANA updated client_secret_jwt and private_key_jwt on 2026-05-05 to add a reference to RFC-ietf-oauth-rfc7523bis-11 alongside OIDC Core §9.
