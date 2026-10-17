# OAuth-adjacent families — SECEVENT, SASL, GNAP, Token Binding and others

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
| [RFC8417](#rfc8417-security-event-token-set) | July 2018 | Proposed Standard (IETF SECEVENT WG) | none | 0 | 1 | 2 |
| [RFC8935](#rfc8935-push-based-security-event-token-set-delivery-using-http) | November 2020 | Proposed Standard (IETF SECEVENT WG) | none | 0 | 0 | 0 |
| [RFC8936](#rfc8936-poll-based-security-event-token-set-delivery-using-http) | November 2020 | Proposed Standard (IETF SECEVENT WG) | none | 0 | 0 | 0 |
| [RFC9493](#rfc9493-subject-identifiers-for-security-event-tokens) | December 2023 | Proposed Standard (IETF SECEVENT WG) | none | 0 | 0 | 0 |
| [RFC9967](#rfc9967-system-for-cross-domain-identity-management-scim-profile-for-security-event-tokens-sets) | May 2026 | Proposed Standard (IETF SCIM WG); updates RFC 7643 and RFC 7644 | none | 0 | 0 | 0 |
| [RFC7628](#rfc7628-a-set-of-simple-authentication-and-security-layer-sasl-mechanisms-for-oauth) | August 2015 | Proposed Standard (IETF KITTEN WG) | not-applicable | 0 | 0 | 0 |
| [RFC9635](#rfc9635-grant-negotiation-and-authorization-protocol-gnap) | October 2024 | Proposed Standard (IETF GNAP WG) | none | 0 | 0 | 0 |
| [RFC9767](#rfc9767-grant-negotiation-and-authorization-protocol-resource-server-connections) | April 2025 | Proposed Standard (IETF GNAP WG) | none | 0 | 0 | 0 |
| [RFC8471](#rfc8471-the-token-binding-protocol-version-10) | October 2018 | Proposed Standard (IETF TOKBIND WG, now concluded); never deployed by browsers | not-applicable | 0 | 0 | 1 |
| [RFC8472](#rfc8472-transport-layer-security-tls-extension-for-token-binding-protocol-negotiation) | October 2018 | Proposed Standard (IETF TOKBIND WG, now concluded) | not-applicable | 0 | 0 | 0 |
| [RFC8473](#rfc8473-token-binding-over-http) | October 2018 | Proposed Standard (IETF TOKBIND WG, now concluded); never deployed by browsers | none | 0 | 0 | 0 |
| [RFC7635](#rfc7635-session-traversal-utilities-for-nat-stun-extension-for-third-party-authorization) | August 2015 | Proposed Standard (IETF TRAM WG) | none | 0 | 0 | 0 |
| [RFC8898](#rfc8898-third-party-token-based-authentication-and-authorization-for-session-initiation-protocol-sip) | September 2020 | Proposed Standard (IETF SIPCORE WG); updates RFC 3261 | not-applicable | 0 | 0 | 1 |
| [RFC8959](#rfc8959-the-secret-token-uri-scheme) | January 2021 | Informational (IETF, non-WG) | none (verifier corrected from not-applicable) | 0 | 0 | 0 |
| [RFC9560](#rfc9560-federated-authentication-for-the-registration-data-access-protocol-rdap-using-openid-connect) | April 2024 | Proposed Standard (IETF REGEXT WG) | none (verifier corrected from partial) | 0 | 0 | 0 |
| [RFC9711](#rfc9711-the-entity-attestation-token-eat) | April 2025 | Proposed Standard (IETF RATS WG) | none | 0 | 0 | 0 |
| [RFC7033](#rfc7033-webfinger) | September 2013 | Proposed Standard (IETF APPSAWG) | none | 0 | 0 | 1 |
| [RFC7165](#rfc7165-use-cases-and-requirements-for-json-object-signing-and-encryption-jose) | April 2014 | Informational (IETF JOSE WG) | not-applicable | 0 | 0 | 0 |

**Cluster notes.** Catalog of 18 OAuth-adjacent RFCs from other IETF working groups (SECEVENT, SCIM, KITTEN, GNAP, TOKBIND, TRAM, SIPCORE, REGEXT, RATS, APPSAWG, JOSE, plus one non-WG RFC). None is an OAuth WG RFC, none is vendored under references/rfc-sources, oauth-openapi.yaml cites none of them, and no references/rfc-validation notes exist for them. Every IANA value attributed to them that is absent from the YAML is an expected absence under a catalog-only treatment: JWT claims events/toe/txn (RFC 8417), sub_id (RFC 9493), rdap_allowed_purposes/rdap_dnt_allowed (RFC 9560), the 21 EAT claims (RFC 9711); the GNAP HTTP authentication scheme (RFC 9635); and the well-known URIs webfinger (RFC 7033), stun-key (RFC 7635) and gnap-as-rs (RFC 9767).

RECOMMENDATION: vendor only RFC 8417. The YAML already advertises backchannel_logout_supported/backchannel_logout_session_supported, whose Logout Token is a SET-compatible JWT. RFC 8417 §4 (preventing confusion between SETs, ID Tokens and JWT access tokens) also applies to any AS that mints several kinds of JWT, and the vendored RFC 8725 §3.11 uses it as its explicit-typing example. Keep the other 17 catalog-only. Each falls into one of four groups: SET plumbing that matters only if the AS becomes an OpenID Shared Signals transmitter (8935, 8936, 9493, 9967); consumer-side profiles that need nothing new from the AS (7628 SASL, 8898 SIP, 9560 RDAP, 7635 STUN); a separate protocol (GNAP 9635/9767); or historical and abandoned work (Token Binding 8471-8473), plus background material (7165, 9711, 8959, 7033).

IN-CLUSTER YAML FINDINGS (all low severity):
(1) RFC 7033: the openid-configuration description (lines 609-615) says this is the only standardized OIDC path. That ignores /.well-known/webfinger and the RFC 8414 and RFC 9728 well-known paths that the YAML itself models.
(2) RFC 8471: components.schemas.Confirmation (line 2577) calls the RFC 7800 cnf members 'Token-binding' methods. This conflates them with the abandoned IETF Token Binding protocol, and README.md:329 does the same.
(3) RFC 8417: the backchannel_logout_* booleans (lines 2226-2231) say nothing about the SET-compatible Logout Token they commit the OP to sending. Separately, the ID-token and access-token payload schemas do not exclude the events claim.

CROSS-CLUSTER OBSERVATIONS TO FORWARD (verified against vendored text):
(a) The components.schemas.JWT pattern (line 2440) requires every segment to be non-empty. As a result it rejects valid JWE compact serializations with an empty Encrypted Key (alg dir or ECDH-ES, RFC 7516 §5.1 step 5 and §7.1). It also rejects unsecured JWTs (RFC 7519 §6), even though OIDC Discovery says 'none' MAY appear in userinfo_signing_alg_values_supported. Both affect the application/jwt and application/token-introspection+jwt bodies (lines 348, 505, 555).
(b) The ResponseType description (lines 692-693) calls id_token a Hybrid Flow value. OIDC Core §3.2.2.1 makes it an Implicit Flow value; the Hybrid values are code id_token, code token and code id_token token (§3.3.2.1).
(c) IDTokenClaims (lines 2461-2509) has no sid claim, yet the YAML advertises frontchannel_logout_session_supported and backchannel_logout_session_supported. Under OIDC Back-Channel Logout 1.0 §2.1, advertising these means the OP puts sid in ID Tokens.
(d) The comment at line 2219 names a non-existent spec, 'OIDC Logout 1.0'. The fields actually come from Front-Channel Logout 1.0 and Back-Channel Logout 1.0.
(e) Line 609 says the document is 'published by every OpenID Connect provider'. That overstates OIDC Core §15.2, which makes Discovery mandatory only for dynamic OPs.

All fixes go into oauth-openapi.yaml; then regenerate oauth-openapi-modular with python3 split-oauth-openapi.py, because the same text is mirrored in spec/paths/well-known.yaml:12, spec/components/schemas/claims.yaml:129 and spec/components/parameters.yaml:8.

SOURCES fetched 2026-10-10:
- [OIDC Back-Channel Logout 1.0 errata set 1](https://openid.net/specs/openid-connect-backchannel-1_0.html)
- [OpenID Shared Signals Framework 1.0, 29 Aug 2025](https://openid.net/specs/openid-sharedsignals-framework-1_0.html)
- [Chromium blink-dev 'Intent to Remove: Token Binding', 1 Aug 2018](https://groups.google.com/a/chromium.org/g/blink-dev/c/OkdLUyYmY1E/m/YJrsadYKDQAJ)
- [Microsoft Edge AllowTokenBindingForUrls policy (Token Binding no longer supported from Edge 130)](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/allowtokenbindingforurls)
- [datatracker draft-ietf-oauth-token-binding (expired at -08)](https://datatracker.ietf.org/doc/draft-ietf-oauth-token-binding/); the TOKBIND WG is concluded, and draft-ietf-tokbind-tls13-03 has also expired
- [RFC Editor errata, e.g. RFC 8959 erratum 6440](https://www.rfc-editor.org/errata/eid6440)

## RFC8417 Security Event Token (SET)

*July 2018 · Proposed Standard (IETF SECEVENT WG) · YAML coverage: **none** · relevance to an AS: optional · vendoring: vendor*

**What it is.** Defines the Security Event Token (SET), a JWT profile for statements of fact about a security subject, such as 'this session was logged out', 'this token was revoked' or 'this account was disabled'. Its core is the `events` claim: a JSON object whose member names are event-type URIs and whose values are event-payload objects. Around it sit `iss`, `iat` and `jti` (REQUIRED), `aud` (RECOMMENDED), optional `sub`, `txn` and `toe`, and `exp`, which is NOT RECOMMENDED (§2.2). It registers the application/secevent+jwt media type (JOSE typ secevent+jwt, §2.3) and the +jwt structured-syntax suffix (§7.2). §4 gives concrete rules that stop SETs being confused with ID Tokens and JWT access tokens, while delivery is left to RFC 8935/8936.

**Why it was created.** Identity providers, relying parties and provisioning systems needed one interoperable, signable, self-describing way to tell each other asynchronously that something security-relevant had happened: a logout, a credential reset, a token revocation or an account compromise. Without it, every protocol invented its own message. SETs are also JWTs, often minted by the same issuers as ID Tokens and access tokens, so the design also had to prevent one kind of JWT being substituted for another.

<details><summary>Already modeled in the YAML (3)</summary>

- +jwt structured-syntax suffix (RFC 8417 §7.2): the modeled media type application/token-introspection+jwt relies on it (line 346, paths./introspect.post.responses.200.content, RFC 9701)
- Related touch point, not an RFC 8417 element: OIDC Back-Channel Logout metadata backchannel_logout_supported (line 2226) and backchannel_logout_session_supported (line 2229) in components.schemas.OAuthServerMetadata. When these are true, the OP must emit SET-compatible Logout Tokens
- Related consistency that the §4.1-§4.2 confusion defences rely on: IDTokenClaims requires exp (line 2467), and JWTAccessTokenClaims requires exp and documents explicit typing with typ at+jwt (lines 2517, 2521)

</details>

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 8417. The audit synthesis (references/audit/rfc-audit-synthesis.md lines 109-114) added the four logout booleans but never assessed the Logout Token they imply.

**Notes.** Relevance to an AS: only if it implements OIDC Back-Channel Logout (advertised in this YAML) or acts as an OpenID Shared Signals Framework transmitter (SSF 1.0, 29 Aug 2025, which profiles RFC 8417, 9493, 8935 and 8936 for CAEP/RISC). OIDC Back-Channel Logout 1.0 errata set 1 (Dec 2023) §2.4 says its Logout Token is compatible with SET but uses a more specific typ, logout+jwt. It requires iss, aud, iat, exp, jti, events and a sub and/or sid, and it prohibits nonce. That is a deliberate divergence: RFC 8417 §2.2 calls exp NOT RECOMMENDED, and §4.1 asks ID-token-confusable SET profiles to omit it. Back-Channel Logout instead relies on the prohibited nonce, the events claim and explicit typing. Delivery is not RFC 8935: the OP form-POSTs logout_token to the RP and expects 200 (or 204) or 400. The IANA JWT claims events, toe and txn are absent from the YAML, as expected. Why vendor: §4 is directly applicable to an AS that mints ID tokens, RFC 9068 access tokens, RFC 9701 introspection JWTs and logout tokens, and the vendored RFC 8725 §3.11 uses RFC 8417 as its explicit-typing example. Reported erratum 7175 (a 'cause-time' mention in the RISC example) does not affect the YAML.

### Findings (0 high · 1 medium · 2 low)

1. **[MEDIUM] Incorrect: The assessment lists the +jwt structured-syntax suffix as a modeled element (application/token-introspection+jwt, line 346), but the schema it uses contradicts ** — *found by the verifier*  
   *Reference:* RFC 8417 §7.2.1 (+jwt Encoding Considerations); RFC 7519 §10.3.1; RFC 7516 §5.1 step 5 / §7.1  
   The assessment lists the +jwt structured-syntax suffix as a modeled element (application/token-introspection+jwt, line 346), but the schema it uses contradicts the suffix. components.schemas.JWT (line 2440) requires every compact-serialization segment to be non-empty, whereas RFC 8417 §7.2.1 defines +jwt content as 'a series of base64url-encoded values ... some of which may be the empty string'. RFC 7519 §10.3.1 uses identical wording for application/jwt, so the /userinfo application/jwt bodies (lines 503-505 and 553-555) have the same conflict.  
   *Suggested change:* Replace the pattern with '^[A-Za-z0-9_-]+(\.[A-Za-z0-9_-]*){2}((\.[A-Za-z0-9_-]*){2})?$'. It requires a non-empty protected header, lets later segments be empty, and allows exactly 3 or 5 segments. Tested: it accepts JWS, RSA-OAEP JWE, dir/ECDH-ES JWE and unsecured JWTs, and rejects 2-, 4- and 6-segment strings and an empty header. In the description, say that JWE segments may be empty and cite RFC 8417 §7.2.1 and RFC 7519 §10.3.1.

2. **[LOW] Gap: Logout Token (a SET profile) implied by backchannel_logout_supported**  
   *Reference:* RFC 8417 §2, §2.3, §4.1; OIDC Back-Channel Logout 1.0 §2.1, §2.4-§2.5, §2.8  
   Lines 2226-2231 (components.schemas.OAuthServerMetadata.properties.backchannel_logout_supported and backchannel_logout_session_supported) are bare booleans with no description or reference. Nothing in the YAML says that advertising true commits the OP to POSTing a SET-compatible Logout Token to each RP's backchannel_logout_uri. That token has an events claim whose member is http://schemas.openid.net/event/backchannel-logout, a RECOMMENDED typ of logout+jwt, a prohibited nonce, and a sub and/or a sid. Nothing says either that *_session_supported=true also puts sid into ID Tokens. An implementation generated from the YAML would advertise the feature with no contract for the token it must send.  
   *Suggested change:* Add descriptions to both booleans citing Back-Channel Logout 1.0 §2.1 and RFC 8417 §2. Add a documentation-only schema, components.schemas.LogoutTokenClaims: {type: object, required: [iss, aud, iat, exp, jti, events], anyOf: [{required: [sub]}, {required: [sid]}], not: {required: [nonce]}, properties: {events: {type: object, required: ['http://schemas.openid.net/event/backchannel-logout'], additionalProperties: {type: object}}, sid: {type: string}}}, and note that the JOSE typ is logout+jwt. Optionally document the outbound call as an OpenAPI 3.1 top-level webhooks.backchannelLogout entry: POST with requestBody application/x-www-form-urlencoded {logout_token: $ref JWT}, success responses 200/204, and 400 with ErrorResponse and Cache-Control no-store. Unused components are only a hint under .spectral.yaml, so lint stays at 0 errors and 0 warnings.  
   *Verifier: confirmed.*

3. **[LOW] Gap: events claim as a SET discriminator in the JWT payload schemas**  
   *Reference:* RFC 8417 §4.2, §4.3  
   IDTokenClaims (lines 2461-2468) and JWTAccessTokenClaims (lines 2514-2522) set additionalProperties: true and say nothing about events. A SET payload that happens to carry the required claims would therefore validate as an ID-token or access-token payload. RFC 8417 §4.2 recommends that access-token validation check for the events claim to detect SETs, and §4.3 suggests rejecting JWTs that contain events unless a SET is expected.  
   *Suggested change:* Add `not: {required: [events]}` to both documentation schemas, plus one sentence: 'This AS never emits the events claim in ID Tokens or access tokens. Its presence identifies a Security Event Token (RFC 8417 §4.2-§4.3), so validators can reject such a JWT here.'  
   *Verifier: partially correct —* The observation is accurate, but this is optional hardening rather than a missing RFC element. RFC 8417 §4.2-§4.3 are non-normative suggestions to SET-profile authors and JWT validators; they place no requirement on ID-token or JWT-access-token issuers. Adding not: {required: [events]} is a project-specific restriction and should be documented that way. Its main practical effect would be to reject Logout Tokens, which do carry exp.

## RFC8935 Push-Based Security Event Token (SET) Delivery Using HTTP

*November 2020 · Proposed Standard (IETF SECEVENT WG) · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Defines push delivery: a SET Transmitter sends one SET per HTTPS POST to an endpoint hosted by the SET Recipient. The request carries Content-Type application/secevent+jwt and Accept application/json, and the body is the SET itself. The recipient validates it (it parses, it is authentic, the audience matches, the issuer and transmitter are trusted). It then answers 202 Accepted with an empty body, or 400 with a JSON object {err, description} plus a Content-Language header. The RFC creates the IANA 'Security Event Token Error Codes' registry: invalid_request, invalid_key, invalid_issuer, invalid_audience, authentication_failed and access_denied.

**Why it was created.** RFC 8417 deliberately left SET transport undefined. When the transmitter can make outbound calls and the recipient can host a TLS endpoint, both sides needed an interoperable push mechanism with clear acknowledgement and machine-readable errors, so that retries and duplicate handling work.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 8935.

**Notes.** Relevant only if the AS also acts as an SSF, CAEP or RISC transmitter (SSF 1.0 identifies this delivery method by the URN urn:ietf:rfc:8935). The call goes outbound from the AS, so if it is ever modeled it belongs in an OpenAPI 3.1 top-level webhooks entry, not in paths. Do not merge its error codes into the YAML's ErrorResponse (lines 1465-1533). SET delivery errors use the members err and description and their own IANA registry, while OAuth errors use error and error_description from the OAuth Extensions Error registry. OIDC Back-Channel Logout does not use this RFC: it form-POSTs logout_token and expects 200/204. Catalog-only because it is not part of an OAuth 2.1 AS's core surface.

_No open findings._

## RFC8936 Poll-Based Security Event Token (SET) Delivery Using HTTP

*November 2020 · Proposed Standard (IETF SECEVENT WG) · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Defines pull delivery: the SET Recipient POSTs application/json to a polling endpoint hosted by the SET Transmitter. In that request it acknowledges earlier SETs (ack is an array of jti values; setErrs maps each jti to {err, description}) and asks for more (maxEvents, where 0 means acknowledge-only, and returnImmediately to choose short or long polling). The response is {sets: {&lt;jti>: &lt;SET string>}, moreAvailable}, and an invalid poll request gets 400. It reuses RFC 8935's error-code registry. When OAuth access tokens authenticate the poll, implementers MUST consider the RFC 7521 §8 threats (§4.4).

**Why it was created.** Some recipients can make outbound HTTPS requests but cannot, or prefer not to, host a reachable endpoint. They still need at-least-once, acknowledged delivery of a SET stream, with long polling to keep latency low.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 8936.

**Notes.** If the AS were an SSF transmitter, it would host this poll endpoint (POST, JSON). SSF says its authorization_schemes (for example spec_urn urn:ietf:rfc:6749) SHOULD protect the endpoint. Receivers would typically get tokens through the client_credentials grant already modeled (ClientCredentialsTokenRequest, line 1268) and present them via bearerAuth (line 2637). Not part of an OAuth 2.1 AS core; catalog-only.

_No open findings._

## RFC9493 Subject Identifiers for Security Event Tokens

*December 2023 · Proposed Standard (IETF SECEVENT WG) · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Defines Subject Identifiers: JSON objects with a required format member that names how the subject is identified. The formats are account (an acct: URI), email, iss_sub (an issuer plus subject pair, as in OIDC ID Tokens), opaque, phone_number (E.164), did, uri, and aliases (a list of the other forms). It also registers the JWT sub_id claim so any JWT can carry such an object, because sub must stay a plain string. When both sub and sub_id are present, they MUST identify the same subject (§4.1).

**Why it was created.** Events, and other JWTs, must say who or what they concern, yet parties know the same account by different identifiers: email, phone, an issuer-scoped sub, an opaque ID. Free-form subject fields were ambiguous to parse, and the string-valued sub claim cannot hold typed, structured identifiers.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 9493.

**Notes.** Used by SSF, CAEP and RISC event subjects, by RFC 9967 SCIM events, and by GNAP (sub_id_formats_supported). Do not confuse it with OIDC 'Subject Identifier Types' (public/pairwise), which subject_types_supported models at lines 2116-2121; that is an unrelated OIDC Core §8 concept. The YAML's StringOrURI (line 2443) correctly treats sub as a string, which matches §4.1. IDTokenClaims, JWTAccessTokenClaims and IntrospectionResponse allow extra members (lines 2468, 2522, 1706), so a sub_id claim would validate if it were ever emitted. The IANA claim sub_id is absent, as expected. Verified erratum 7727 renames the registry from 'Security Event Identifier Formats' to 'Subject Identifier Formats'.

_No open findings._

## RFC9967 System for Cross-Domain Identity Management (SCIM) Profile for Security Event Tokens (SETs)

*May 2026 · Proposed Standard (IETF SCIM WG); updates RFC 7643 and RFC 7644 · YAML coverage: **none** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** Profiles SETs for SCIM. It defines feed events (urn:ietf:params:scim:event:feed:add and feed:remove), provisioning events (prov:create, prov:patch and prov:put in notice or full variants, plus prov:delete, prov:activate and prov:deactivate) and an asynchronous-completion event (misc:asyncresp). SCIM SETs MUST identify the resource with a top-level sub_id of format scim (the SCIM uri, plus externalId or id) and MUST NOT use sub; txn correlates the SETs from one transaction. It also lets a SCIM client request asynchronous processing with Prefer: respond-async, which returns 202 plus a new Set-Txn response header, and it adds a securityEvents block to ServiceProviderConfig.

**Why it was created.** Keeping identity data consistent across domains by repeatedly polling SCIM with GET does not scale as resources and change rates grow. Providers needed event-driven change notification, for both domain replication and coordinated provisioning, and a way to finish long-running SCIM operations asynchronously.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 9967.

**Notes.** This is the surface of a SCIM service provider, not of an OAuth AS. It becomes relevant when an identity platform pairs its AS with a SCIM server; SCIM APIs are typically protected by OAuth bearer tokens, as the §2.5.1.1 example's Authorization: Bearer shows. The ban on sub (§2.1) exists explicitly 'to prevent confusion with JWT authorization tokens', the same theme as RFC 8417 §4. It is the newest document in this cluster. Catalog-only.

_No open findings._

## RFC7628 A Set of Simple Authentication and Security Layer (SASL) Mechanisms for OAuth

*August 2015 · Proposed Standard (IETF KITTEN WG) · YAML coverage: **not-applicable** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** Defines SASL mechanisms that let non-HTTP protocols such as IMAP, SMTP and XMPP accept OAuth credentials. OAUTHBEARER carries an RFC 6750 bearer token as auth=Bearer &lt;token> inside a GS2 header followed by %x01-separated key/value pairs (with host and port). OAUTH10A carries an OAuth 1.0a signature instead. On failure the server returns a JSON error with status (a code from the OAuth Extensions Error registry, such as invalid_token), an optional scope, and an optional openid-configuration URL that points the client at the authorization server's discovery document (§3.2.2).

**Why it was created.** OAuth access tokens could only be presented over HTTP (RFC 6750), so mail and messaging clients that authenticate through SASL kept using users' long-term passwords. RFC 7628 lets those protocols accept short-lived, revocable OAuth tokens instead.

<details><summary>Already modeled in the YAML (4)</summary>

- The discovery document that the SASL error's openid-configuration member points to (§3.2.2): /.well-known/openid-configuration (line 603), schema components.schemas.OpenIDProviderMetadata (line 1907)
- registration_endpoint, which §3.2.2 says that discovery document SHOULD contain: OAuthServerMetadata.properties.registration_endpoint (line 1965)
- offline_access scope, RECOMMENDED by §3.2.2 for obtaining refresh tokens: Scope parameter description (lines 739, 748) and securitySchemes.oauth2 scopes (line 2700)
- Error codes used in the SASL status member (IANA OAuth Extensions Error registry, §3.2.2): ErrorResponse.error enum (lines 1474-1517), for example invalid_token (line 1490) and invalid_scope (line 1484)

</details>

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 7628.

**Notes.** Nothing needs adding to the AS's HTTP surface. An AS that serves IMAP/SMTP clients only needs standard grants (native-app code flow with PKCE), refresh tokens with offline_access, discovery, and ideally Dynamic Client Registration. All of these are modeled except the registration endpoint itself, which is a README roadmap item. §3.2.2 also recommends that clients use the issuer (iss) to decide whether an existing registration or refresh token can be reused. Reported errata 8564 and 8637 only fix base64 in the §4 examples. Catalog-only.

_No open findings._

## RFC9635 Grant Negotiation and Authorization Protocol (GNAP)

*October 2024 · Proposed Standard (IETF GNAP WG) · YAML coverage: **none** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** GNAP is a separate delegation protocol, not an OAuth extension, that covers the same ground as OAuth 2.0 and OpenID Connect. Every grant starts with one JSON POST to a single grant endpoint. The AS then negotiates how the user interacts (start modes redirect, app, user_code and user_code_uri; finish via redirect or push), and the grant continues through a key-protected continuation API. Client instances are identified by their keys, so a pre-registered client_id is optional; access is requested as rich access arrays in which plain strings behave like scopes; and subject information can be returned directly. Every request is bound to a client key (httpsig, mtls, jwsd or jws), and bound tokens are presented as Authorization: GNAP &lt;token> plus a proof. §1 says GNAP is not intended to be directly compatible with OAuth 2.0, and Appendix A compares the two.

**Why it was created.** OAuth 2.0 has built-in assumptions: browser-redirect grant types at different endpoints, a mandatory pre-registered client_id, bearer secrets with sender-constraint bolted on later in inconsistent ways, an overloaded scope string, and a user who is also the resource owner. These made device, decentralized-identity and asynchronous use cases awkward, so the GNAP WG designed a protocol with negotiation, key binding and rich access requests built in.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 9635.

**Notes.** An OAuth 2.1 AS does not implement GNAP, but GNAP is a useful mirror for understanding OAuth's extensions: GNAP access arrays correspond to RFC 9396 RAR (AuthorizationDetail, line 2596); key proofing corresponds to DPoP and mTLS (securitySchemes dpop at line 2648, mtls at line 2676); the JSON grant request corresponds to PAR (line 422); and the user_code interaction corresponds to the device grant (line 368). Token rotation through the continuation and token-management APIs replaces refresh tokens, and discovery is an HTTP OPTIONS request on the grant endpoint rather than a /.well-known document. Appendix B.5 shows how an OAuth client_id and scope map into a GNAP request. The GNAP HTTP authentication scheme and the four application/gnap-binding-* media types are absent from the YAML, as expected for a different protocol. Catalog-only.

_No open findings._

## RFC9767 Grant Negotiation and Authorization Protocol Resource Server Connections

*April 2025 · Proposed Standard (IETF GNAP WG) · YAML coverage: **none** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** Extends GNAP with an API on the AS for resource servers to call. It offers discovery at /.well-known/gnap-as-rs; token introspection, in which the RS POSTs JSON {access_token, proof, resource_server, access} signed with its own key; registration of resource sets, which yields opaque resource references; and derivation of downstream tokens for chained RS calls (existing_access_token). It also defines a general access-token data model and a 'GNAP Token Formats' registry (jwt-signed, jwt-encrypted, macaroon, biscuit, zcap).

**Why it was created.** Core GNAP leaves AS-to-RS interaction undefined. When one AS protects many independently operated resource servers, they need interoperable token validation, discovery and resource registration rather than tight coupling through shared storage.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 9767.

**Notes.** OAuth counterparts already in the YAML: /introspect (line 315, RFC 7662), where the RS authenticates as a client with a form body instead of signing a JSON request with its own key; JWT access tokens (JWTAccessTokenClaims, line 2514), which correspond to the jwt-signed format; and RFC 8693 token exchange (TokenExchangeRequest, line 1349), which corresponds to downstream token derivation. The IANA well-known URI gnap-as-rs is absent, as expected. Catalog-only.

_No open findings._

## RFC8471 The Token Binding Protocol Version 1.0

*October 2018 · Proposed Standard (IETF TOKBIND WG, now concluded); never deployed by browsers · YAML coverage: **not-applicable** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** Defines Token Binding 1.0. The client keeps a long-lived key pair per server and proves possession on each TLS connection by signing that connection's Exported Keying Material; the public key forms the Token Binding ID. A server binds a token (a cookie or an OAuth token) to that ID by embedding the ID or its hash, and MUST reject a bound token that arrives on a connection without the matching binding (§5). It covers TLS 1.2 only; the TLS 1.3 version never completed.

**Why it was created.** Bearer tokens and cookies can be stolen (by malware, XSS or log leaks) and replayed from anywhere. Binding them to a key that the client proves at the TLS layer makes a stolen token useless without the private key.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 8471.

**Notes.** Why browsers abandoned it: Chrome's blink-dev 'Intent to Remove: Token Binding' (1 Aug 2018) said the feature had sat behind a flag for over two years without shipping, fewer than 0.01% of HTTPS requests attempted it, industry adoption was low, and the engineering and maintenance cost outweighed the security benefit. Firefox and Safari never implemented it ([Chromium blink-dev](https://groups.google.com/a/chromium.org/g/blink-dev/c/OkdLUyYmY1E/m/YJrsadYKDQAJ)). Microsoft Edge kept a Windows-only implementation, enabled per site by the AllowTokenBindingForUrls policy in Edge 83-129, and stopped supporting it from Edge 130 ([Microsoft Learn](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/allowtokenbindingforurls)). On datatracker, the TOKBIND WG is concluded, and draft-ietf-oauth-token-binding (-08) and draft-ietf-tokbind-tls13 (-03) both expired in 2019. OAuth turned instead to mTLS-bound tokens (RFC 8705, whose Appendix B contrasts them with Token Binding) and to DPoP (RFC 9449 §1 cites 'a lack of support for HTTP token binding' for browser apps). RFC 9700 §4.10.2 mentions Token Binding in the past tense. The expired OAuth profile would have added cnf.tbh, AS and client metadata such as as_access_token_token_binding_supported, and a PKCE method referred_tb. None of these were registered at IANA, and the YAML correctly omits them. Security detail: §7.4 forbids negotiating Token Binding on TLS 1.2 or older unless extended master secret and renegotiation indication are also negotiated (because of the triple-handshake attack).

### Findings (0 high · 0 medium · 1 low)

1. **[LOW] Incorrect: line 2577: components.schemas.Confirmation.description (mirrored at oauth-openapi-modular/spec/components/schemas/claims.yaml:129)**  
   *Reference:* RFC 8471 §1, §5; RFC 7800 §3.1  
   The description calls the cnf members 'Token-binding confirmation methods per RFC 7800'. In IETF terminology, Token Binding is the specific TLS-layer protocol of RFC 8471-8473. None of the modeled members is Token Binding: jkt is DPoP (RFC 9449 §6.1), x5t#S256 is mTLS (RFC 8705 §3.1), and jwk and kid come from RFC 7800 §3.2 and §3.4. The OAuth Token Binding confirmation member, cnf.tbh from draft-ietf-oauth-token-binding-08, was never published. A learner would wrongly conclude that the YAML supports Token Binding. README.md line 329 ('Add token-binding examples for DPoP') makes the same conflation.  
   *Suggested change:* Reword the description to: 'Proof-of-possession (sender-constraint) confirmation members of the cnf claim (RFC 7800 §3.1): jkt for DPoP (RFC 9449 §6.1), x5t#S256 for mTLS (RFC 8705 §3.1), jwk and kid (RFC 7800 §3.2, §3.4). IETF Token Binding (RFC 8471-8473) is not supported.' Edit oauth-openapi.yaml, regenerate the modular tree (python3 split-oauth-openapi.py), and reword the README roadmap item to 'Add sender-constrained token (DPoP) examples'.  
   *Verifier: partially correct —* This is ambiguous wording, not a factual error. 'Token-binding' is generic binding vocabulary that RFC 9449 itself uses, but a reader could take it to mean IETF Token Binding (RFC 8471-8473), which the YAML does not support. Rewording line 2577 and README.md:329 to RFC 7800's own term ('proof-of-possession (sender-constraint) confirmation methods') is a worthwhile editorial fix. Afterwards, regenerate claims.yaml:129 and rebuild the dist bundle (line 2535).

## RFC8472 Transport Layer Security (TLS) Extension for Token Binding Protocol Negotiation

*October 2018 · Proposed Standard (IETF TOKBIND WG, now concluded) · YAML coverage: **not-applicable** · relevance to an AS: not-applicable · vendoring: catalog-only*

**What it is.** Defines the token_binding TLS 1.2 extension (type 24). Through it, the ClientHello and ServerHello agree on the Token Binding protocol version and key parameters (rsa2048_pkcs1.5, rsa2048_pss or ecdsap256) without extra round trips. Negotiation for TLS 1.3 is explicitly out of scope.

**Why it was created.** Token Binding (RFC 8471) needs client and server to agree on the protocol version and key algorithm before any binding message is sent, without adding latency to the handshake.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 8472.

**Notes.** A pure TLS-handshake detail with no OAuth or HTTP surface. It is the piece Edge's AllowTokenBindingForUrls policy switched on ('sends the Token Binding ClientHello'). The TLS 1.3 counterpart, draft-ietf-tokbind-tls13, expired at -03 in 2019 and was never published. Catalog it only together with RFC 8471 and RFC 8473 as historical background.

_No open findings._

## RFC8473 Token Binding over HTTP

*October 2018 · Proposed Standard (IETF TOKBIND WG, now concluded); never deployed by browsers · YAML coverage: **none** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** Carries Token Binding over HTTPS. Once Token Binding is negotiated, the client MUST send exactly one Sec-Token-Binding request header (a base64url TokenBindingMessage) holding a Provided Token Binding for that server. A server that receives more than one such header MUST answer 400, and if a binding fails, every associated bound token MUST be rejected. For federation, a Token Consumer such as an OIDC RP can add Include-Referred-Token-Binding-ID: true to its redirect. The browser then also reveals, as a Referred Token Binding, the ID it uses with the RP, so the Token Provider (the IdP or AS) can bind ID Tokens or codes to the client's connection with the RP.

**Why it was created.** To make RFC 8471 usable on the Web. It defines how binding messages travel in HTTP/1.1 and HTTP/2, how browsers scope binding keys (no wider than eTLD+1, §2.1), and how a token issued by one server, an IdP, can be bound to the client's connection with another server, an RP, in redirect-based federation.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 8473.

**Notes.** An AS supporting Token Binding would have accepted Sec-Token-Binding at /authorize (via the referred binding from the RP's redirect) and at /token, and embedded the binding hash in its tokens (cnf.tbh in the expired OAuth draft). The YAML correctly models none of this. Its DPoP request header (DPoPHeader, line 972) is the application-layer successor, which works without support from the TLS stack or the browser. Sec-Token-Binding and Include-Referred-Token-Binding-ID are registered as permanent HTTP header fields. Catalog-only, as historical background.

_No open findings._

## RFC7635 Session Traversal Utilities for NAT (STUN) Extension for Third-Party Authorization

*August 2015 · Proposed Standard (IETF TRAM WG) · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Lets STUN and TURN servers, the NAT-traversal relays that WebRTC uses, accept short-lived OAuth 2.0 access tokens instead of long-term username/password credentials. A STUN server signals support by including the THIRD-PARTY-AUTHORIZATION attribute in a 401 error. The client then obtains a self-contained, AEAD-encrypted token plus a session key (mac_key) from an authorization server, sends the token in the ACCESS-TOKEN attribute, and protects the STUN message with an HMAC under mac_key. The AS and the STUN server share a long-term symmetric key, which the STUN server can fetch from the AS with GET /.well-known/stun-key?service=stun&name=... over mutually authenticated TLS; the JSON response carries k, kid, exp and enc.

**Why it was created.** In WebRTC the JavaScript client cannot keep long-term STUN/TURN credentials secret, so leaked credentials let unauthorized users and applications use the server. Ephemeral OAuth tokens scoped to one server limit the damage.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 7635.

**Notes.** If the AS issued STUN/TURN tokens, it would expose the AS-hosted /.well-known/stun-key endpoint (§4.1.1, protected by mTLS, and SHOULD be supported per §4.1.2). It would also mint the binary self-contained token of §6.2, with the STUN server name as AEAD associated data. Historical lesson: §3 specifies the OAuth Implicit grant, and the non-normative Appendix B uses token_type pop and the alg and aud request parameters from the expired OAuth PoP key-distribution draft. Today, OAuth 2.1 and RFC 9700 §2.1.2 would use the code grant with PKCE, or client_credentials, at /token; the YAML intentionally excludes Implicit. The RFC defines the scope value stun. The stun-key JSON reuses JOSE member names, such as k from RFC 7518 §6.4.1, which is the YAML's JWK.k at line 1900. The IANA well-known URI stun-key is absent, as expected. The STUN-level errata (4826 and 4923 Held for Document Update; 5059 and 5060 Reported) do not affect the YAML. Catalog-only.

_No open findings._

## RFC8898 Third-Party Token-Based Authentication and Authorization for Session Initiation Protocol (SIP)

*September 2020 · Proposed Standard (IETF SIPCORE WG); updates RFC 3261 · YAML coverage: **not-applicable** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** Defines a Bearer authentication scheme for SIP so that a registrar or proxy can delegate user authentication to an OAuth 2.0 authorization server or OpenID Provider. A 401/407 challenge can carry realm, scope, error and an authz_server HTTPS URI. The user agent gets tokens from that AS with ordinary OAuth/OIDC flows (native apps per RFC 8252, refresh tokens to renew) and presents the access token in the SIP Authorization header. Because SIP passes through proxies, access tokens placed in SIP requests MUST be encrypted JWTs unless another mechanism limits who can read them (§2.1.2).

**Why it was created.** SIP Digest authentication needs separate credentials for each service. Operators wanted single sign-on for SIP registration, with MFA and federation handled by the identity provider, and wanted to reuse the same OAuth tokens across SIP and non-SIP services.

<details><summary>Already modeled in the YAML (3)</summary>

- Refresh tokens that the UAC uses to renew access tokens (§2.1.1): TokenResponse.refresh_token (line 1433) and RefreshTokenRequest (line 1284)
- A token format that can carry the encrypted JWT access tokens SIP requires (§2.1.2): the components.schemas.JWT pattern accepts the five-segment JWE form (line 2440)
- Error values reused in the SIP Bearer challenge (§4): ErrorResponse.error invalid_token (line 1490) and invalid_scope (line 1484)

</details>

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 8898.

**Notes.** The AS needs nothing SIP-specific. authz_server is SIP's counterpart to the RFC 9728 resource_metadata WWW-Authenticate parameter that the YAML documents (WWWAuthenticateBearerDPoP, line 1015). §2.1.1 requires the UA to check the advertised AS against a configured allow-list, the same phishing and mix-up concern behind RFC 9207 and RFC 9728. An AS that issues encrypted JWT access tokens with alg dir or ECDH-ES would hit the JWT-pattern limitation described in the cluster notes. Only editorial erratum 6495 (Reported) exists. Catalog-only.

### Findings (0 high · 0 medium · 1 low)

1. **[LOW] Gap: The YAML documents JWT access tokens as signed only** — *found by the verifier*  
   *Reference:* RFC 8898 §2.1.2; RFC 9068 §4  
   The YAML documents JWT access tokens as signed only. RFC 8898 §2.1.2 requires access tokens carried in SIP requests to be encrypted JWTs unless another mechanism restricts who can read them, and RFC 9068 §4 explicitly provides for encrypted JWT access tokens. Yet JWTAccessTokenClaims says 'Wire form is a signed JWT with JOSE header typ: at+jwt' (line 2517), and neither TokenResponse.access_token (1411-1419) nor bearerAuth (2640-2646) mentions JWE or nested JWTs. The assessment's RFC 8898 modeled_elements instead cite components.schemas.JWT, which access_token does not reference.  
   *Suggested change:* In JWTAccessTokenClaims.description, and in the bearerAuth description, say the wire form is a signed JWT (typ at+jwt) that MAY be nested inside a JWE (RFC 9068 §4), and note that SIP deployments (RFC 8898 §2.1.2) need the encrypted form. RFC 8898 itself stays catalog-only.

## RFC8959 The "secret-token" URI Scheme

*January 2021 · Informational (IETF, non-WG) · YAML coverage: **none (verifier corrected from not-applicable)** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Registers the provisional secret-token: URI scheme so that issuers can format bearer secrets (API keys, access or refresh tokens, client secrets) as secret-token:&lt;pchar...>. Leaked secrets then become easy for CI systems, repository hosts and scanners to recognize and block. The complete URI is both issued and presented, character for character (§2).

**Why it was created.** Bearer tokens were increasingly disclosed by accident, for example by being committed to public source repositories. An unambiguous, machine-detectable marker helps prevent such leaks, although it cannot stop intentional disclosure.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 8959.

**Notes.** Design caveat for an AS: the colon, and any percent-escapes, fall outside the syntax for Authorization: Bearer (RFC 6750 §2.1 b64token; OAuth 2.1 draft-16 §5.1.1 token68). That is so even though RFC 6749 and OAuth 2.1 Appendix A.12 allow access-token = 1*VSCHAR. The author's own erratum 6440 (Reported, Feb 2021) concedes that the RFC's header example is not technically allowed, though it interoperates, and proposes a form-body example instead. The YAML leaves access_token (line 1411), refresh_token (line 1433) and client_secret (line 1185) unconstrained, so it permits the scheme but never discusses it. If adopted, the scheme suits secrets that never travel in a Bearer header, such as refresh tokens and client secrets; many issuers instead use vendor prefixes that are safe in token68, such as GitHub's ghp_. Catalog-only.

_No open findings._

## RFC9560 Federated Authentication for the Registration Data Access Protocol (RDAP) Using OpenID Connect

*April 2024 · Proposed Standard (IETF REGEXT WG) · YAML coverage: **none (verifier corrected from partial)** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Profiles OpenID Connect so that RDAP servers (the RESTful successor to WHOIS that registries use to publish domain-name and IP registration data) can act as Relying Parties and grant tiered access based on identities from external OpenID Providers. Session-oriented clients log in through the RDAP server (farv1_session/login, status, refresh and logout, plus device and devicepoll built on RFC 8628). Token-oriented clients obtain tokens from the OP themselves and send Authorization: Bearer with each query. It defines OP-side claims under the rdap scope, rdap_allowed_purposes (a stated need-to-know purpose) and rdap_dnt_allowed (do-not-track), requires the authorization code flow, and says the Implicit Flow MUST NOT be used (§10).

**Why it was created.** Separate username/password accounts on each server do not scale across hundreds of registries, and they say nothing about who the user is or why they need the data (law enforcement, IP protection, DNS operations). Federated OIDC identities let registries make fine-grained, privacy-aware access decisions.

<details><summary>Already modeled in the YAML (9)</summary>

- Authorization code flow, required because the Implicit Flow MUST NOT be used (§3.1.4.2, §10): /authorize (line 109), with the ResponseType enum excluding token (lines 703-706)
- login_hint, RECOMMENDED for the RP (§3.1.4.2): components.parameters.LoginHint (line 821) and PARRequest.login_hint (line 1620)
- Token endpoint and ID Token (§3.1.4.5, §6.1): /token (line 210), TokenResponse.id_token (line 1443), IDTokenClaims.aud (line 2476)
- UserInfo for retrieving claims (§3.1.4.6, §6.2): /userinfo GET and POST (lines 481, 519)
- Device Authorization Grant for UI-constrained clients (§5.2.4): /device_authorization (line 368) and DeviceCodeTokenRequest (line 1309)
- Token introspection for validating access tokens (§6.3): /introspect (line 315)
- Token exchange to obtain tokens with a trusted aud (§6.4): TokenExchangeRequest (line 1349)
- OIDC Discovery for finding the provider (§3.1.4.1): /.well-known/openid-configuration (line 603)
- Open metadata arrays that can advertise the rdap scope and claims: scopes_supported (line 2016) and claims_supported (line 2122)

</details>

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 9560.

**Notes.** Coverage is partial: every generic OAuth/OIDC mechanism the RFC relies on is modeled, but its own OP-side elements are not documented. Those are the rdap scope and the IANA JWT claims rdap_allowed_purposes (an array of StringOrURI) and rdap_dnt_allowed (a boolean). They are not reported as gaps because they are optional (an OP SHOULD support them) and fit unchanged into scopes_supported, claims_supported and the open ID Token and UserInfo schemas. Per §6.1, the OP SHOULD include the RDAP server's client_id in the ID Token's aud. §3.1.4.1 notes that OIDC Discovery issuer discovery (WebFinger) is 'not widely implemented' and allows out-of-band OP lists or an explicit farv1_iss query parameter instead. Cross-cluster note: the YAML's ResponseType description calls id_token a Hybrid value, but OIDC Core §3.2.2.1 makes it an Implicit Flow value, and RFC 9560 §3.1.4.2 calls that flow insecure. Catalog-only.

_No open findings._

## RFC9711 The Entity Attestation Token (EAT)

*April 2025 · Proposed Standard (IETF RATS WG) · YAML coverage: **none** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** Defines the Entity Attestation Token (EAT): a JWT or CWT whose claims describe the identity and state of a device or software 'entity'. Examples are eat_nonce for freshness, ueid (a unique device ID), oemid, hwmodel, swname and swversion, dbgstat, oemboot, measurements and measres, submods for composite devices, eat_profile and intuse. It follows the RATS architecture (RFC 9334): an Attester signs Evidence, and a Verifier appraises it and may issue Attestation Results (which can also be EATs) to a Relying Party. Profiles narrow EAT for particular use cases.

**Why it was created.** Relying parties such as networks and payment or enterprise services need standardized, signed, verifiable statements about a device's identity, software and security posture to decide how far to trust it. These statements are signed with attestation keys that manufacturers provision, not with user credentials, and the earlier proprietary attestation formats did not interoperate.

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 9711.

**Notes.** The link to OAuth is conceptual only. OAuth 2.0 Attestation-Based Client Authentication (draft-ietf-oauth-attestation-based-client-auth-11, in WG Last Call, 3 Sep 2026) maps its roles to RATS in §14, describing its flow as the RATS 'Passport Model': the client is the Attester, the AS or RS is the Relying Party, the Client Attester is the Verifier, and the Client Attestation JWT is the Attestation Result. But it defines its own JWTs (typ oauth-client-attestation+jwt and oauth-client-attestation-pop+jwt) and HTTP headers (OAuth-Client-Attestation and OAuth-Client-Attestation-PoP), and it neither uses EAT claims nor cites RFC 9711. A client attester could internally appraise EAT evidence from a device before issuing that JWT. The 21 EAT JWT claims are absent from the YAML, as expected. The Verified errata fix only examples and CDDL. Catalog-only.

_No open findings._

## RFC7033 WebFinger

*September 2013 · Proposed Standard (IETF APPSAWG) · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Defines WebFinger: an HTTPS GET to /.well-known/webfinger?resource=&lt;URI>, optionally with one or more rel=&lt;link relation> parameters. It returns a JSON Resource Descriptor (application/jrd+json) with subject, aliases, properties and links (each with rel, href, type, titles and properties) describing the entity behind a non-locator URI such as acct:carol@example.com. OpenID Connect Discovery 1.0 §2 uses it, optionally, for issuer discovery. The RP queries the host from the user's identifier with rel http://openid.net/specs/connect/1.0/issuer, takes the OP's issuer URL from links[].href, and then fetches /.well-known/openid-configuration.

**Why it was created.** There was no simple HTTP/JSON way to get from an identifier people actually type, such as an email-style account, to the services associated with it, such as the user's OpenID Provider. WebFinger standardized a single well-known, query-based endpoint that returns the JRD format first introduced by host-meta (RFC 6415).

**Follow-up on the May-2026 validation notes.** There is no RFC 7033 note. The related OIDC Discovery 1.0 validation (references/rfc-validation/oidc-discovery-1.0.md lines 312-315) classified WebFinger issuer discovery as NOT APPLICABLE because it is served by the user's account domain. The current YAML is unchanged and still has no /.well-known/webfinger path, so that decision still holds.

**Notes.** If the endpoint is ever modeled (for example for an enterprise or self-hosted OP that also owns its users' domain), its elements are: GET /.well-known/webfinger; query parameter resource, REQUIRED exactly once (§4.2); rel, OPTIONAL and repeatable (§4.3); 200 with application/jrd+json; 400 when resource is missing or malformed and 404 when it is unknown (§4.2); an Access-Control-Allow-Origin header that MUST be present and SHOULD be * (§5); HTTPS only, with redirects only to https. The issuer returned in links[].href must later equal OpenIDProviderMetadata.issuer (line 1944). The IANA well-known URI webfinger is absent, as expected. RFC 7628 §1 and RFC 9560 §3.1.4.1 also mention WebFinger-based discovery, and RFC 9560 notes it is not widely implemented. Catalog-only; vendor it only if the project decides to model OIDC issuer discovery.

### Findings (0 high · 0 medium · 1 low)

1. **[LOW] Incorrect: lines 609-615: paths./.well-known/openid-configuration.get.description (same text in oauth-openapi-modular/spec/paths/well-known.yaml:12)**  
   *Reference:* RFC 7033 §4, §10.1; OIDC Discovery 1.0 §2, §4; OIDC Core 1.0 §15.2  
   The description says /.well-known/openid-configuration is 'the only path that is truly standardized across OIDC providers — all other endpoint URLs are vendor-defined'. But RFC 7033 §4 and §10.1 standardize /.well-known/webfinger, which OIDC Discovery 1.0 §2 uses (optionally) to locate the OP's issuer. The YAML itself also models two more standardized well-known paths: /.well-known/oauth-authorization-server (RFC 8414 §3, line 630) and /.well-known/oauth-protected-resource (RFC 9728 §3, line 653). In addition, the phrase 'published by every OpenID Connect provider' (line 609) overstates OIDC Core §15.2, which makes Discovery mandatory only for dynamic OPs.  
   *Suggested change:* Reword to: 'OpenID Provider metadata endpoint (OIDC Discovery 1.0 §4), REQUIRED for OPs that support Discovery and mandatory for dynamic OPs (OIDC Core §15.2). An RP that knows only the user's identifier can first find the issuer with WebFinger (RFC 7033: GET /.well-known/webfinger?resource=acct:user@host&rel=http://openid.net/specs/connect/1.0/issuer; OIDC Discovery §2), which is served by the identifier's domain. Apart from these and the RFC 8414 and RFC 9728 well-known documents also modeled here, endpoint URLs are deployment-defined and must be read from the metadata.' Then regenerate oauth-openapi-modular (python3 split-oauth-openapi.py).  
   *Verifier: partially correct —* The YAML description is inaccurate. The strongest counterexample is RFC 8414 §3's /.well-known/oauth-authorization-server, which OPs commonly serve as well. /.well-known/webfinger is standardized (RFC 7033 §4, §10.1) but lives on the identifier's domain. /.well-known/oauth-protected-resource is a resource-server path and should not be cited as an OIDC-provider path. The 'every OpenID Connect provider' overstatement is correctly identified (OIDC Core §15.2, Discovery §4). The fix must also reach dist/oauth-openapi.bundled.yaml:576.

## RFC7165 Use Cases and Requirements for JSON Object Signing and Encryption (JOSE)

*April 2014 · Informational (IETF JOSE WG) · YAML coverage: **not-applicable** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** The JOSE working group's requirements document. It explains why the Web needed a JSON-based alternative to CMS/ASN.1 and XML Signature for object-level security, and walks through use cases: security tokens and JWT, OAuth, OpenID Connect, XMPP, ALTO, emergency alerting, WebCrypto and constrained devices. It lists the functional requirements (signature, MAC and authenticated encryption; JSON key formats; a compact, URL-safe serialization) and the security requirements that JWS, JWE, JWK and JWA (RFC 7515-7518) were designed to meet.

**Why it was created.** Applications that pass tokens through untrusted intermediaries, such as the browser or client in OAuth, needed integrity, origin authentication and optional confidentiality at the object level, in a format web developers could implement easily. CMS/ASN.1 and XML security were seen as too complex.

<details><summary>Already modeled in the YAML (4)</summary>

- F5, a compact URL-safe serialization: components.schemas.JWT pattern (lines 2434-2441)
- F2/F3, key formats with attributes: components.schemas.JWKS and JWK (lines 1813-1902)
- F1, signature, MAC and authenticated encryption choices: the *_signing_alg_values_supported and *_encryption_alg/enc_values_supported metadata arrays (lines 2050-2113)
- §5.2, the RS identifying the AS's signing key: jwks_uri (line 1961) and JWK.kid (line 1859)

</details>

**Follow-up on the May-2026 validation notes.** None: no references/rfc-validation note exists for RFC 7165.

**Notes.** Read it to see why JWT, the foundation of ID tokens, JWT access tokens, JAR and DPoP, looks the way it does. Two assumptions have since been reversed. §5.2 assumed OAuth tokens often travel in URI query parameters, which RFC 9700 and OAuth 2.1 now forbid (the YAML says query MUST NOT be used, lines 2299-2304). §5.3 wished for an unprotected JOSE object for OIDC; that became alg none, which RFC 8725 §3.2 now confines to JWTs protected by other means. The YAML's JWT pattern requires a non-empty signature segment, so unsecured JWTs never validate; see the cluster notes for the related JWE empty-segment issue. Catalog-only.

_No open findings._

## Verifier corrections to the summaries above

- RFC8471 and RFC8473 status 'never deployed by browsers' is false. The Chromium blink-dev 'Intent to Remove: Token Binding' thread (1 Aug 2018) says 'Edge is the only other browser that supports Token Binding' ('Edge: Supported, negative to removal'). Microsoft's AllowTokenBindingForUrls page lists 'Windows: 83-129' and says Token Binding is 'no longer supported, starting with Microsoft Edge 130'. Correct wording: never enabled by default in Chrome (flag-only, removed in 2018) and never implemented in Firefox or Safari; only Microsoft Edge shipped it, and Edge dropped it in version 130. The assessment's own RFC 8471 notes already say this, so the status fields contradict them.
- RFC7628 notes: errata 8564 and 8637 do not 'only fix base64'. 8564 (Reported, Technical, §4.4) changes the GS2 header authzid from 'user=' to 'a=' (RFC 5801), which changes the example's base64. 8637 (Reported, Technical, §4.1) removes an IMAP-style 't1' tag from the SMTP example and only re-wraps the base64. Both affect examples only, and neither affects the YAML.
- RFC7628 summary wording: auth=Bearer &lt;token> is not 'inside a GS2 header'. It is a %x01-terminated key/value pair that follows the GS2 header (client-resp = gs2-header kvsep *kvpair kvsep, §3.1). host and port are optional for OAUTHBEARER; the client MUST send them only for keyed-message-digest token types such as OAuth 1.0a (§3.1).
- RFC7635 notes: not all four errata are 'STUN-level'. 4923 (Held for Document Update) concerns the OAuth PoP 'key' token-response parameter in Appendix B. 4826 (Held) asks to move access-token renewal out of the STUN client to the application and to limit the OAuth parameters passed to STUN (§8). 5059 and 5060 (Reported) concern HMAC key length (§6.2, Appendix B). The conclusion that none affects the YAML still holds.
- cluster_notes grouping: RFC 7635 is not a consumer-side profile that 'needs nothing new from the AS'. The AS hosts /.well-known/stun-key, where mutual TLS is a MUST and implementations SHOULD support this REST interface (§4.1.1-§4.1.2); §4.1.1 makes support for A256GCM mandatory; §3 defines the 'stun' scope and uses the Implicit grant; and §6.2 defines an AS-minted AEAD self-contained token carrying mac_key, whose lifetime 'MUST be greater than or equal to the expires_in parameter'. The assessment's own RFC 7635 notes say this. RFC 8898 §2.1.2 also needs AS-issued encrypted JWT access tokens, and RFC 9560 §3.1.5 defines OP-issued scope and claims.
- RFC9560 notes: there is no text saying 'an OP SHOULD support' the rdap claims. §3.1.5.1 says 'Use of the "rdap_allowed_purposes" claim is OPTIONAL' and §3.1.5.2 says 'Client use of the "rdap_dnt_allowed" claim is OPTIONAL'. §3.1.5.1 also places an IdP-side MUST: 'Identity providers MUST ensure that appropriate purpose values are only assigned to end user identities that are authorized to use them.' The summary's 'requires the authorization code flow' overstates §3.1.4.2, which only assumes the code flow for the steps it describes and also describes the Hybrid Flow; only the Implicit Flow is banned (§10, 'It MUST NOT be used'). §3.1.4.1 says '[OIDCD] ... is not widely implemented' without naming WebFinger, so the RFC7033 note that RFC 9560 'mentions WebFinger-based discovery' is loose.
- RFC8898 modeled_elements and notes: components.schemas.JWT (2440) is referenced only by the application/token-introspection+jwt and application/jwt bodies (348, 505, 555). TokenResponse.access_token (1411) is an unconstrained string, so the JWT pattern neither carries nor blocks encrypted JWT access tokens. The note 'An AS that issues encrypted JWT access tokens with alg dir or ECDH-ES would hit the JWT-pattern limitation' is therefore wrong. The relevant element is JWTAccessTokenClaims (2517), which documents only a signed wire form.
- Regeneration instructions are incomplete. Running 'python3 split-oauth-openapi.py' after adding LogoutTokenClaims stops with 'AssertionError: Unmapped schemas: [LogoutTokenClaims]' until SCHEMA_GROUP['claims'] is extended. Once it is extended, the script silently drops any top-level 'webhooks' block yet still prints 'VERIFY: PASS', because its root (lines 194-197) and verifier (337-340) handle only openapi, info, externalDocs, servers, tags, paths and components. Both were reproduced on a scratch copy. The affected text also lives in oauth-openapi-modular/dist/oauth-openapi.bundled.yaml (576, 642, 2535), which needs ./bundle.sh. The '.spectral.yaml keeps lint at 0 errors / 0 warnings' prediction is correct: Spectral 6.15.0 reported 5 hints only.
- Vendoring recommendation: the Logout Token contract comes from OIDC Back-Channel Logout 1.0 (errata set 1, 15 Dec 2023). Neither it nor Front-Channel Logout 1.0, the source of the frontchannel_* fields and of the sid-in-ID-Token rule, was vendored in references/oidf-sources when this was written. The CLAUDE.md workflow is 'read the relevant RFC (text vendored under references/rfc-sources/) → encode', so vendoring RFC 8417 alone is not enough for the proposed fix; BCL 1.0, and preferably FCL 1.0, should be vendored with it. *(Update 2026-10-11: Back-Channel Logout 1.0 and Front-Channel Logout 1.0 are now vendored. RFC 8417 is not, because it is outside the scope rule.)*
- RFC8417 notes: '§4.1 asks ID-token-confusable SET profiles to omit it [exp]' understates the requirement level. §4.1 says such a SET profile 'MUST require that the "exp" claim not be present'. The Back-Channel Logout Token (exp REQUIRED) therefore departs from an RFC 8417 MUST and relies instead on the prohibited nonce (BCL §2.4), the events claim and typ logout+jwt.
- RFC9711 notes, minor: of the 7 Verified errata, 5 fix examples or CDDL (8528, 8771 and 8782 examples; 8776 and 8783 CDDL), and 2 are editorial prose fixes (8777 in §4.3.1 'precession'→'precision'; 9152 in §4.2.15 grammar). Five more errata were Reported in Sep-Oct 2026 (9193, 9195, 9196, 9199, 9200), all about Appendix A examples. None affects the YAML.
- Cross-cluster, adjacent to note (d), forwardable: in the same logout block, http_logout_supported (2232-2235) is neither defined by Front-Channel Logout 1.0 (which uses 'HTTP-based logout' only as prose for frontchannel_logout_supported) nor registered in the IANA OAuth Authorization Server Metadata registry (oauth-parameters.xml, 2026-10-10).
- Cross-cluster notes (a)-(e) all verified against the source texts. (a) RFC 7519 §10.3.1 and RFC 8417 §7.2.1 allow empty segments, OIDC Discovery says 'The value none MAY be included' for userinfo_signing_alg_values_supported, and a regex test confirms the rejections. (b) OIDC Core §3.2.2.1 lists 'id_token token or id_token' for Implicit and §3.3.2.1 lists 'code id_token, code token, or code id_token token' for Hybrid. (c) BCL §2.1 and FCL both say 'If supported, the sid Claim is also included in ID Tokens issued by the OP'. (d) No 'OIDC Logout 1.0' spec exists. (e) OIDC Core §15.2 makes Discovery mandatory only for dynamic OPs. All other per-doc facts checked out against the RFC text, rfc-index, IANA XML, datatracker and RFC Editor errata: dates, statuses, WGs, update relations, section citations, IANA values, SSF 1.0 (29 Aug 2025, urn:ietf:rfc:8935, §7.1.1 polling-endpoint SHOULD), the attestation draft-11 §14 RATS mapping, the expired Token Binding drafts (-08, -03) and the concluded TOKBIND WG.
- Label consistency, no formal correction: docs with no AS-side surface are labelled inconsistently. RFC 9711, 9967, 9635 and 9767 are 'none', while RFC 7165, 7628 and 8898 are 'not-applicable', even though the assessment's own notes say RFC 9967 'is the surface of a SCIM service provider, not of an OAuth AS' and RFC 9711's 'link to OAuth is conceptual only'.
