# ACE — OAuth 2.0 for constrained (IoT) environments

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
| [RFC8392](#rfc8392-cbor-web-token-cwt) | May 2018 | Proposed Standard | none | 0 | 0 | 1 |
| [RFC8747](#rfc8747-proof-of-possession-key-semantics-for-cbor-web-tokens-cwts) | March 2020 | Proposed Standard | none | 0 | 0 | 1 |
| [RFC9200](#rfc9200-authentication-and-authorization-for-constrained-environments-using-the-oauth-20-framework-ace-oauth) | August 2022 | Proposed Standard | none | 0 | 0 | 14 |
| [RFC9201](#rfc9201-additional-oauth-parameters-for-authentication-and-authorization-for-constrained-environments-ace) | August 2022 | Proposed Standard | none | 0 | 0 | 4 |
| [RFC9202](#rfc9202-datagram-transport-layer-security-dtls-profile-for-authentication-and-authorization-for-constrained-environments-ace) | August 2022 | Proposed Standard (updated by RFC 9430) | none | 0 | 0 | 2 |
| [RFC9430](#rfc9430-extension-of-the-datagram-transport-layer-security-dtls-profile-for-authentication-and-authorization-for-constrained-environments-ace-to-transport-layer-security-tls) | July 2023 | Proposed Standard (updates RFC 9202) | not-applicable | 0 | 0 | 0 |
| [RFC9203](#rfc9203-the-object-security-for-constrained-restful-environments-oscore-profile-of-the-authentication-and-authorization-for-constrained-environments-ace-framework) | August 2022 | Proposed Standard | none | 0 | 0 | 3 |
| [RFC9237](#rfc9237-an-authorization-information-format-aif-for-authentication-and-authorization-for-constrained-environments-ace) | August 2022 | Proposed Standard | not-applicable | 0 | 0 | 0 |
| [RFC9431](#rfc9431-message-queuing-telemetry-transport-mqtt-and-transport-layer-security-tls-profile-of-authentication-and-authorization-for-constrained-environments-ace-framework) | July 2023 | Proposed Standard | none | 0 | 0 | 4 |
| [RFC9594](#rfc9594-key-provisioning-for-group-communication-using-authentication-and-authorization-for-constrained-environments-ace) | September 2024 | Proposed Standard | not-applicable | 0 | 0 | 0 |
| [RFC9770](#rfc9770-notification-of-revoked-access-tokens-in-the-authentication-and-authorization-for-constrained-environments-ace-framework) | June 2025 | Proposed Standard | not-applicable | 0 | 0 | 0 |
| [RFC7744](#rfc7744-use-cases-for-authentication-and-authorization-in-constrained-environments) | January 2016 | Informational | not-applicable | 0 | 0 | 0 |
| [RFC9148](#rfc9148-est-coaps-enrollment-over-secure-transport-with-the-secure-constrained-application-protocol) | April 2022 | Proposed Standard (updated by RFC 9908, January 2026) | not-applicable | 0 | 0 | 0 |
| [RFC9482](#rfc9482-constrained-application-protocol-coap-transfer-for-the-certificate-management-protocol) | November 2023 | Proposed Standard | not-applicable | 0 | 0 | 0 |
| [RFC9820](#rfc9820-authentication-service-based-on-the-extensible-authentication-protocol-eap-for-use-with-the-constrained-application-protocol-coap) | September 2025 | Proposed Standard | not-applicable | 0 | 0 | 0 |

**Cluster notes.** Scope: these 15 documents are exactly the RFCs the IETF ACE WG has published (datatracker, 2026-10-10). The YAML cites none of them, none is vendored, and no references/rfc-validation notes exist for any of them. Twelve are OAuth-derived or OAuth-adjacent: CWT 8392, CWT-PoP 8747, the framework 9200, its parameters 9201, the profiles 9202/9430/9203/9431, AIF 9237, group keys 9594, revocation notification 9770, and use cases 7744. The other three were picked up by the WG-based filter but have no OAuth wire elements, so they are excluded: 9148 (EST over CoAP), 9482 (CMP over CoAP) and 9820 (EAP over CoAP, which mentions ACE-OAuth only as an out-of-scope later phase).

Recommendation: catalog-only for all twelve. Most of ACE cannot be expressed in an HTTP-only OpenAPI description of an OAuth 2.1 AS: CoAP transport, CBOR maps with integer keys, COSE/CWT, proof of possession through DTLS/OSCORE/TLS exporters, and the RS-side /authz-info endpoint. Neither OAuth 2.1 (draft-16) nor RFC 9700 references ACE.

HTTP touchpoints are few:
- RFC 9200 §5.8/§5.9 keep RFC 6749/7662 JSON semantics over HTTPS.
- RFC 9201 and RFC 9203 define JSON forms of their key material.
- RFC 9431 (MQTT) runs every AS interaction over HTTPS with application/ace+json. It is the natural starting point if ACE support is ever added. In that case, vendor 9200, 9201 and 9431 (plus 9203 for 'osc') and model them in a separate overlay, not in the core OAuth 2.1 schemas.

IANA fingerprints: 20 values in the core OAuth/JWT registries are attributed to this cluster and are absent from the YAML.
- RFC 9200 (11): token type PoP; errors unsupported_pop_key and incompatible_ace_profiles; OAuth parameter ace_profile; introspection members ace_profile, cnonce, cti, exi; JWT claims ace_profile, cnonce, exi.
- RFC 9201 (2): req_cnf, rs_cnf. 'cnf' shows as present only because the RFC 7800 claim and RFC 8705 introspection member exist; it is not a TokenResponse member.
- RFC 9203 (5): nonce1, nonce2, ace_client_recipientid, ace_server_recipientid (client-RS only), and the JWT confirmation method osc.
- RFC 9594 (2): sign_info, kdcchallenge (client-RS only).
The six client-RS parameters belong to the RS's /authz-info exchange and must never be added to AS schemas. The ACE-only registries (ACE Profiles coap_dtls=1 / coap_oscore=2 / mqtt_tls=3, the CBOR-mapping registries, AS Request Creation Hints, OSCORE Security Context Parameters, ACE Groupcomm, TRL) and the CWT registries do not apply to an HTTP/JSON AS.

YAML findings: one concrete inaccuracy. ResourceIndicators.resource (lines 1213-1215) calls `audience` non-standard, but RFC 8693 §2.1 defines it, IANA registers it for token requests, and RFC 9200 §5.8.1 uses it on any ACE grant. Otherwise the YAML tolerates ACE extensions, because no schema sets additionalProperties:false. Only three things would block an ACE response or request:
- the closed ErrorResponse.error enum (lines 1477-1517);
- the required TokenResponse.token_type (line 1408);
- the grant_type discriminator required in every TokenRequest branch (lines 1163-1171).

Learner takeaway: an ACE 'PoP' token is not DPoP. 'PoP' is a registered token type with no HTTP auth scheme; the token is uploaded to the RS and possession is proven inside a DTLS, OSCORE or TLS channel. DPoP (RFC 9449) proves possession with a per-request JWT sent in an HTTP header.

Pipeline:
- In the RFC Editor queue: draft-ietf-ace-key-groupcomm-oscore-21 and draft-ietf-ace-oscore-gm-admin-17. IANA already lists their values, including the OAuth Parameters ecdh_info and kdc_dh_creds, which are also client-RS only.
- Active WG drafts: workflow-and-params-08 ('New OAuth Parameters for ACE'), edhoc-oscore-profile-11, group-oscore-profile-07, coap-pubsub-profile-05 (in WG Last Call), authcred-dtls-profile-04 and coap-est-oscore-11.
- Adjacent, non-ACE: RFC 9679 (COSE Key Thumbprint; registers urn:ietf:params:oauth:ckt and CWT cnf 'ckt'; flagged absent in the IANA absence list) and RFC 9597 (CWT claims in COSE headers).

## RFC8392 CBOR Web Token (CWT)

*May 2018 · Proposed Standard · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** CWT is the CBOR/COSE twin of JWT: the claims are a CBOR map with small integer keys (iss=1, sub=2, aud=3, exp=4, nbf=5, iat=6, cti=7 — cti being a byte string) protected by COSE signing, MACing or encryption instead of JOSE. It reuses JWT claim semantics (RFC 7519), creates the IANA CWT Claims registry, and registers the application/cwt media type (CoAP Content-Format 61) and CBOR tag 61. ACE-OAuth (RFC 9200 §5.10) makes CWT its RECOMMENDED access-token format.

**Why it was created.** JWT's JSON + base64url encoding is too large and costly to parse for constrained IoT devices on low-power radios; IoT needed a compact binary token with the same claim semantics and an object-security wrapper (COSE) usable over CoAP as well as HTTP.

<details><summary>Already modeled in the YAML (1)</summary>

- No CWT element is modeled. JSON/JWT counterparts only: components.schemas.TokenResponse.access_token (line 1411; type string, 'implementation-defined' format — a CWT can only travel here as the base64url string of its bytes, cf. RFC 9770 §4.2.2); components.schemas.StringOrURI / NumericDate (lines 2443 / 2450), whose RFC 7519 semantics CWT reuses with CBOR encodings (RFC 8392 §2); IntrospectionResponse.jti (line 1740), the JSON twin of the CWT cti claim (§3.1.7).

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 8392.

**Notes.** Catalog-only: an HTTP/JSON OAuth 2.1 AS never needs to parse CBOR; CWT matters only if the server issues tokens for CoAP resource servers. Errata 5710/5852 (Held for Document Update) and 7982/8617/8655 (Reported: example-key fixes; NumericDate must be finite) do not affect the YAML. Related later work outside this cluster: RFC 9597 (CWT Claims in COSE Headers, 2024) and RFC 9679 (COSE Key Thumbprint, 2024; registers urn:ietf:params:oauth:ckt and CWT cnf method 'ckt'). The CWT Claims registry now also carries OAuth-WG claims status_list/ttl/status (keys 65533-65535) from draft-ietf-oauth-status-list-21.

### Findings (0 high · 0 medium · 1 low)

1. **[LOW] Gap: CWT as an alternative self-contained access-token format (application/cwt)**  
   *Reference:* RFC 8392 §1, §6, §9.2; RFC 9200 §5.10; RFC 9770 §4.2.2  
   TokenResponse.access_token.description (lines 1413-1416) offers only 'an opaque string ... or a JWT (RFC 9068)'. An AS serving constrained resource servers may issue a CWT (COSE_Sign1/COSE_Mac0/COSE_Encrypt0, optionally wrapped in CBOR tag 61); in a JSON token response it is carried as the base64url (no padding) encoding of the CWT bytes. A reader who reuses components.schemas.JWT (pattern at line 2440) for access_token would wrongly reject such values. Documentation-only gap; nothing CBOR needs to be modeled.  
   *Suggested change:* Append to components.schemas.TokenResponse.properties.access_token.description: 'IoT/ACE deployments may instead issue a CBOR Web Token (CWT, RFC 8392, media type application/cwt); in JSON it appears as the base64url (unpadded) encoding of the CWT bytes (RFC 9770 §4.2.2). Do not validate access_token against the JWT schema.'  
   *Verifier: partially correct —* This is a documentation gap only. The YAML's 'implementation-defined' access_token already admits a CWT. Add an informative note citing RFC 8392 and RFC 9200 §5.10, plus RFC 9770 §4.1.1: in application/ace+json responses a CWT is the unpadded base64url of its bytes, and it carries tag 61 plus the COSE tag when the AS supports RFC 9770.

## RFC8747 Proof-of-Possession Key Semantics for CBOR Web Tokens (CWTs)

*March 2020 · Proposed Standard · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** The CBOR counterpart of RFC 7800: it registers the CWT 'cnf' claim (key 8), a map naming the single key the presenter must prove it holds — COSE_Key (1) for an asymmetric public key (or a symmetric key inside an encrypted CWT), Encrypted_COSE_Key (2) for a symmetric key encrypted to the recipient, or kid (3) as a byte-string key identifier. It creates the IANA 'CWT Confirmation Methods' registry and deliberately leaves the actual proof (nonce/challenge, handshake) to the protocol that uses the token.

**Why it was created.** Bearer CWTs can be replayed by anyone who obtains them; ACE wanted holder-of-key tokens by default, so CWTs needed the same key-binding mechanism that JWTs got in RFC 7800.

<details><summary>Already modeled in the YAML (1)</summary>

- No CWT cnf modeling (CBOR). JSON/RFC 7800 counterpart only: components.schemas.Confirmation (lines 2575-2591) — jwk (line 2587) ↔ COSE_Key (1), kid (line 2590) ↔ kid (3, a byte string in CWT); referenced from IntrospectionResponse.cnf (line 1748) and JWTAccessTokenClaims.cnf (line 2568). No counterpart for Encrypted_COSE_Key (2) ↔ jwe.

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 8747.

**Notes.** Rules an AS issuing CWTs must honour: cnf carries exactly one PoP key, with at most one of COSE_Key/Encrypted_COSE_Key (§3.1); a symmetric key in COSE_Key requires an encrypted CWT, otherwise use Encrypted_COSE_Key (§3.2); unknown cnf members MUST be ignored (§3.1); PoP SHOULD be combined with audience restriction (§4). No errata.

### Findings (0 high · 0 medium · 1 low)

1. **[LOW] Gap: jwe confirmation member / JWT↔CWT confirmation-method mapping**  
   *Reference:* RFC 8747 §3.1, §3.3, §7.2; RFC 7800 §3.3  
   Confirmation lists jkt, x5t#S256, jwk and kid but not jwe (RFC 7800 §3.3), the JSON twin of Encrypted_COSE_Key — the member used when a symmetric PoP key must travel inside an unencrypted token. The IANA CWT Confirmation Methods registry pairs COSE_Key/jwk, Encrypted_COSE_Key/jwe, kid/kid, osc/osc and ckt (RFC 9679); the YAML gives readers no pointer to the CWT side.  
   *Suggested change:* Add `jwe: {type: string, description: 'Encrypted JWK as JWE compact serialization (RFC 7800 §3.3); CWT twin: Encrypted_COSE_Key (RFC 8747 §3.3)'}` to components.schemas.Confirmation.properties and extend Confirmation.description with: 'CWT access tokens carry the same semantics in CBOR (RFC 8747; IANA CWT Confirmation Methods registry).'  
   *Verifier: confirmed.*

## RFC9200 Authentication and Authorization for Constrained Environments Using the OAuth 2.0 Framework (ACE-OAuth)

*August 2022 · Proposed Standard · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** ACE-OAuth adapts OAuth 2.0 for IoT. It keeps the token and introspection endpoints but usually runs them over CoAP with CBOR payloads (application/ace+cbor, integer-abbreviated parameter names), issues proof-of-possession access tokens by default (preferably CWTs bound to a key via cnf), and relies on pluggable profiles (DTLS, OSCORE, MQTT/TLS) for the security that TLS gives classic OAuth. It adds Access Information parameters (ace_profile; cnf/rs_cnf via RFC 9201), a client-nonce (cnonce) and 'exi' (lifetime counted from first receipt) for resource servers without synchronized clocks, the RS-side authz-info endpoint where clients upload tokens, and AS Request Creation Hints that tell a client which AS to ask. Over HTTPS, RFC 6749 JSON semantics still apply plus these additions.

**Why it was created.** Constrained devices (RFC 7228) often cannot afford HTTP, TLS and JSON, may lack a synchronized clock or connectivity to the AS, and need keys (not just bearer strings) to secure device-to-device traffic. The ACE WG reused OAuth's delegation model instead of inventing a new one, adapting it to CoAP/CBOR/COSE with proof of possession by default (requirements from RFC 7744).

<details><summary>Already modeled in the YAML (9)</summary>

- paths./token.post (lines 210-268): the HTTP token endpoint that §5.8 extends; path '/token' matches the §5.8 default name; form-encoded body (line 244) matches the §5.8.1 rule that HTTP requests use RFC 6749 Appendix B; 200 + application/json (lines 248-260) matches the HTTP practice shown in RFC 9770 Fig. 4
- paths./introspect.post (lines 315-363): the HTTP introspection endpoint that §5.9 maps to CoAP; path '/introspect' matches the §5.9 default name; the 401 (line 359 → components.responses.IntrospectionAuthError, line 1126) matches §5.9.3's 4.01 for invalid requester credentials
- components.schemas.ClientCredentialsTokenRequest (lines 1268-1282): the grant §4/§5.4 recommends for autonomous constrained clients (and ACE's default when grant_type is omitted)
- components.schemas.ClientAuthFields client_id / client_secret (lines 1178 / 1185): RFC 6749 credentials that §5.5 reuses (CBOR keys 24/25)
- components.schemas.TokenResponse access_token, token_type, expires_in, refresh_token, scope (lines 1411-1442): the RFC 6749 members of ACE 'Access Information' (Table 2)
- components.schemas.ErrorResponse.error RFC 6749 codes (lines 1479-1488), including unauthorized_client (line 1482), which §5.2 mandates for Unauthorized Resource Requests, and the six codes that Table 3 abbreviates
- components.schemas.IntrospectionRequest token / token_type_hint (lines 1686 / 1689) and IntrospectionResponse active, scope, client_id, username, token_type, exp, iat, nbf, sub, aud, iss, jti, cnf (lines 1708-1753): the RFC 7662 members that Table 6 abbreviates
- components.schemas.JWTAccessTokenClaims.scope (line 2556) and .cnf (line 2568): the scope (RFC 8693 §4.2) and cnf (RFC 7800) claims that §5.10 uses for JWT/CWT access tokens
- components.schemas.TokenExchangeRequest.audience (lines 1375-1382): the RFC 8693 audience parameter that §5.8.1 reuses — modeled only for token exchange

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9200. Cross-reference: finding M2 in references/rfc-validation/7662-introspection.md (no 403 on /introspect) is still open — /introspect responses (lines 334-359) list only 200/400/401 — and RFC 9200 §5.9.3 independently requires a 403-equivalent with no payload when the requester may not introspect the token.

**Notes.** Catalog-only because the YAML is an HTTP-only OAuth 2.1 profile and ACE's core (CoAP, CBOR abbreviations, COSE, DTLS/OSCORE, RS-side authz-info) cannot be expressed in OpenAPI; neither OAuth 2.1 draft-16 nor RFC 9700 references ACE. Eleven IANA values attributed to RFC 9200 are absent from the YAML (PoP, 2 error codes, ace_profile parameter, 4 introspection members, 3 JWT claims). Over HTTP, success is described as 'equivalent to 2.01 (Created)', but RFC 6749 §5.1 semantics apply and RFC 9770 Fig. 4 shows HTTP 200, which matches the YAML. The PoP token type is registered with 'HTTP Authentication Scheme(s): N/A': unlike DPoP (RFC 9449), ACE PoP tokens are uploaded to /authz-info and proven inside DTLS/OSCORE/TLS, so no securityScheme applies. Fig. 9 shows token_type_hint = 2 (PoP), although Table 6 types token_type_hint as text and 'PoP' is not a registered token-type hint. Reported errata (all filed 2025-01-03): 8232 (CBOR ace_profile must be an integer), 8233-8236 (Appendix F response codes should be 2.01), 8237 (ace_profile CBOR type should be 'Null or integer'), 8238 (ace_profile usage location). If ACE ever comes into scope, vendor RFC 9200 + RFC 9201 first and model them in a separate overlay.

### Findings (0 high · 0 medium · 14 low)

1. **[LOW] Gap: ace_profile (token request/response parameter, introspection member, JWT claim)**  
   *Reference:* RFC 9200 §5.8.1, §5.8.2, §5.8.4.3, §5.9.2, §5.10, §8.9, §8.11, §8.13 (Errata ID 8238)  
   Absent everywhere (IANA-absent in OAuth Parameters, Token Introspection Response and JWT Claims). The JSON value is the profile name ('coap_dtls', 'coap_oscore', 'mqtt_tls' from the IANA ACE Profiles registry; CBOR uses the integers 1/2/3). A client sends an empty string to ask the AS to return it, and the AS MUST then include it; it is also an OPTIONAL introspection member and token claim. TokenResponse, IntrospectionResponse and JWTAccessTokenClaims are open (additionalProperties: true at lines 1409, 1706, 2522), so it would validate but is undocumented. Reported erratum 8238: the IANA usage location should read 'token request, token response'.  
   *Suggested change:* Leave the core OAuth 2.1 schemas unchanged; in an optional ACE overlay add `ace_profile: {type: string, description: 'RFC 9200 §5.8.4.3 ACE profile identifier; request: empty string asks the AS to return it; response: REQUIRED when requested', examples: [coap_dtls, coap_oscore, mqtt_tls]}` to the ACE token request, TokenResponse, IntrospectionResponse and JWTAccessTokenClaims.  
   *Verifier: confirmed.*

2. **[LOW] Gap: cnonce (client-nonce) request parameter, introspection member and claim**  
   *Reference:* RFC 9200 §5.3.1, §5.8.1, §5.8.4.4, §5.9.2, §5.10, §8.11, §8.13  
   Freshness mechanism for resource servers without synchronized clocks. The RS puts a nonce in its AS Request Creation Hints; the client MUST copy it into the token request (JSON: base64url without padding); the AS MUST copy it into the token's cnonce claim when it grants the request, and MAY return it from introspection. The IANA OAuth Parameters registry does not list cnonce as a request parameter (only the ACE CBOR mapping key 39 does); it is registered as an introspection member and a JWT claim.  
   *Suggested change:* In an ACE overlay add `cnonce: {type: string, pattern: '^[A-Za-z0-9_-]+$', description: 'RFC 9200 §5.8.4.4 client-nonce (base64url, no padding); the AS MUST echo it in the cnonce claim (§5.10)'}` to the ACE token request, IntrospectionResponse and JWTAccessTokenClaims.  
   *Verifier: confirmed.*

3. **[LOW] Gap: cti and exi introspection members (and exi claim)**  
   *Reference:* RFC 9200 §5.9.2, §5.10.3, §8.11, §8.13  
   cti is the CWT ID (JSON: base64url without padding; same semantics as jti). exi is the token lifetime in seconds counted from when the RS first receives the token, for resource servers without clocks; when exi is used the AS MUST add a cti/jti built from the RS identifier plus a per-RS sequence number. Neither appears in IntrospectionResponse (lines 1698-1758) or JWTAccessTokenClaims (lines 2514-2573).  
   *Suggested change:* In an ACE overlay add to IntrospectionResponse `cti: {type: string, description: 'RFC 9200 §5.9.2 CWT ID, base64url (no padding); JSON twin of jti'}` and `exi: {type: number, minimum: 0, description: 'RFC 9200 §5.10.3 expires-in from first receipt at the RS'}`, and add `exi` to JWTAccessTokenClaims.  
   *Verifier: confirmed.*

4. **[LOW] Gap: token_type value 'PoP' (and ACE's optional token_type)**  
   *Reference:* RFC 9200 §5.8.2, §5.8.4.2, §8.6, §8.7  
   The IANA OAuth Access Token Types registry lists PoP (additional response parameters cnf, rs_cnf; HTTP authentication scheme N/A). ACE makes token_type OPTIONAL with PoP as the default. TokenResponse.token_type (lines 1420-1427) documents only Bearer, DPoP and N_A, and TokenResponse.required (line 1408) makes token_type mandatory. That is correct for OAuth 2.1, but an ACE response that omits token_type would not validate. IntrospectionResponse.token_type (line 1721) likewise mentions only Bearer and DPoP.  
   *Suggested change:* Append to components.schemas.TokenResponse.properties.token_type.description: '`PoP` (RFC 9200 §5.8.4.2) is also registered: an ACE proof-of-possession token bound via cnf and proven through a profile (DTLS/OSCORE/TLS), not through an HTTP Authorization scheme; ACE responses may omit token_type (default PoP).' Keep `required: [access_token, token_type]` in the core schema; an ACE overlay should use its own response schema.  
   *Verifier: confirmed.*

5. **[LOW] Gap: Error codes unsupported_pop_key and incompatible_ace_profiles**  
   *Reference:* RFC 9200 §5.8.3, §8.3, §8.4  
   Both are registered OAuth extension errors (usage: token error response). The AS MUST return unsupported_pop_key when the client's key cannot be used by the RS, and incompatible_ace_profiles when client and RS share no profile (both with the equivalent of HTTP 400). ErrorResponse.error (lines 1474-1517) is a closed enum, yet its property description (line 1476) says values come 'from the IANA OAuth Extensions Error Registry'. An ACE-capable server generated from the YAML therefore could not emit these codes.  
   *Suggested change:* Either add `# RFC 9200 (ACE §5.8.3)`, `- unsupported_pop_key`, `- incompatible_ace_profiles` to the enum, or change the enum to `examples` and state that any IANA-registered code may appear (the closed enum also omits other registered codes such as RFC 7591's).  
   *Verifier: confirmed.*

6. **[LOW] Gap: audience parameter on ACE token requests (non-token-exchange grants)**  
   *Reference:* RFC 9200 §5.8.1; RFC 8693 §2.1  
   ACE token requests (typically client_credentials, cf. RFC 9202 Fig. 3, RFC 9203 Fig. 2, RFC 9594 §3.1) carry the RFC 8693 audience parameter to bind the token to an RS. The YAML defines audience only on TokenExchangeRequest (lines 1375-1382); ClientCredentialsTokenRequest (lines 1268-1282) lacks it, so it is accepted as an unknown property but undocumented.  
   *Suggested change:* Optionally add `audience: {type: string, description: 'RFC 8693 §2.1 logical target name; used by ACE (RFC 9200 §5.8.1) on any grant. RFC 8707 resource remains the preferred OAuth 2.1 mechanism.'}` to ClientCredentialsTokenRequest or to a shared mixin.  
   *Verifier: confirmed.*

7. **[LOW] Gap: Introspection: 403 Forbidden (no payload) when the requester may not introspect the token**  
   *Reference:* RFC 9200 §5.9.3  
   ACE requires a response 'equivalent to the CoAP code 4.03 (Forbidden)' with no payload when the requesting entity lacks the right to introspect the token, and 4.01 for invalid credentials. paths./introspect.post.responses (lines 334-359) declares only 200, 400 and 401.  
   *Suggested change:* Add under paths./introspect.post.responses: `'403': {description: 'Caller authenticated but not authorized to introspect this token (RFC 9200 §5.9.3 — no payload; RFC 6750 §3.1 insufficient_scope when a bearer token was used)'}`.  
   *Verifier: confirmed.*

8. **[LOW] Gap: ACE encodings and defaults: application/ace+cbor, CBOR abbreviations, optional grant_type, byte-string scope**  
   *Reference:* RFC 9200 §5, §5.8.1, §5.8.4.1, §5.8.5, §5.9.4, §8.15, §8.16  
   ACE over CoAP sends CBOR maps with integer keys (Tables 5-6) under application/ace+cbor (CoAP Content-Format 19), lets grant_type be omitted (default client_credentials), and allows scope to be a byte string. The YAML's TokenRequest discriminator (lines 1163-1171) requires grant_type in every branch, and only form and JSON media types exist. These are intentional ACE deviations that should not be folded into the OAuth 2.1 schemas.  
   *Suggested change:* No schema change. Add a modeling note to info.description: 'ACE-OAuth (RFC 9200) CoAP/CBOR bindings (application/ace+cbor, integer parameter keys) and ACE defaults such as optional grant_type/token_type are out of scope.'  
   *Verifier: confirmed.*

9. **[LOW] Gap: RS-side ACE surface: /authz-info endpoint and AS Request Creation Hints**  
   *Reference:* RFC 9200 §5.2, §5.3, §5.10.1, §5.10.1.1, §5.10.2, §8.1, §8.2  
   The RS hosts /authz-info: the client POSTs the token with its media type (e.g. application/cwt); success is 2.01, errors are 4.00/4.01/4.03. The RS answers unauthorized requests with unauthorized_client plus AS Request Creation Hints {AS, kid, audience, scope, cnonce}. These are resource-server behaviours. The YAML's RS-facing analogues are ProtectedResourceMetadata (line 2272) and the WWW-Authenticate resource_metadata challenge (line 1000, RFC 9728 §5.1).  
   *Suggested change:* Out of scope for the AS spec; if a companion resource-server spec is ever produced, model /authz-info there.  
   *Verifier: confirmed.*

10. **[LOW] Incorrect: lines 1213-1215 — components.schemas.ResourceIndicators.properties.resource.description**  
   *Reference:* RFC 9200 §5.8.1; RFC 8693 §2.1  
   States that 'Some vendors use a non-standard `audience` parameter for the same purpose (e.g. Auth0)'. In fact `audience` is an IETF-standard token-request parameter: RFC 8693 §2.1 defines it, IANA registers it (OAuth Parameters, usage 'token request'), and RFC 9200 §5.8.1 makes it OPTIONAL on any ACE token request to bind the token to an RS. The sentence also contradicts the YAML's own TokenExchangeRequest.audience (lines 1375-1380), which calls it the 'RFC 8693-defined parameter'.  
   *Suggested change:* Reword to: 'RFC 8693 §2.1 defines a related `audience` parameter (a logical target name, IANA-registered for token requests), used by token exchange and, in ACE, on any token request (RFC 9200 §5.8.1); some vendors (e.g. Auth0) also accept it on other grants. This spec models `audience` only on TokenExchangeRequest; `resource` is the OAuth 2.1 way to name the target.'  
   *Verifier: confirmed.*

11. **[LOW] Gap: ACE requires client authentication for every token request, so it has no public clients** — *found by the verifier*  
   *Reference:* RFC 9200 §5.5, §5.8; RFC 9431 §2.1  
   ACE requires client authentication for every token request, so it has no public clients. The YAML /token offers an unauthenticated option, and ClientAuthFields documents public clients. An ACE overlay must not inherit this.  
   *Suggested change:* In any ACE overlay, drop `- {}` from /token security and state that RFC 9200 §5.5 requires client authentication for every grant. The core OAuth 2.1 schema stays unchanged.

12. **[LOW] Gap: The AS rules for protecting PoP access tokens are not captured** — *found by the verifier*  
   *Reference:* RFC 9200 §6.1, §6.9  
   The AS rules for protecting PoP access tokens are not captured. Only RFC 9431's PSK/JWE case was mentioned.  
   *Suggested change:* In an ACE overlay, note in the access-token description: symmetric PoP keys require an encrypted (nested) token; multi-audience tokens must be asymmetrically signed; a PoP secret must not be shared across resource servers.

13. **[LOW] Gap: Refresh-token requests for PoP tokens may not change the PoP key or the audience.** — *found by the verifier*  
   *Reference:* RFC 9200 §5.8.1  
   Refresh-token requests for PoP tokens may not change the PoP key or the audience.  
   *Suggested change:* If req_cnf or audience is ever added to RefreshTokenRequest, document that the AS must reject a refresh request that changes either value.

14. **[LOW] Gap: An ACE AS must tell the client how long the token and its PoP keys are valid: either through expires_in or through a default lifetime provisioned out of band** — *found by the verifier*  
   *Reference:* RFC 9200 §5.10.4  
   An ACE AS must tell the client how long the token and its PoP keys are valid: either through expires_in or through a default lifetime provisioned out of band. YAML expires_in is optional with no such note.  
   *Suggested change:* In an ACE overlay, document that expires_in should always be returned unless a default token lifetime has been provisioned to the client.

## RFC9201 Additional OAuth Parameters for Authentication and Authorization for Constrained Environments (ACE)

*August 2022 · Proposed Standard · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Defines the proof-of-possession key parameters ACE uses at the token endpoint. In the token request, req_cnf carries the client's raw public key or a kid referencing a key already shared with the RS. In the token response, cnf carries the PoP key the AS selected (REQUIRED for 'pop' tokens with a symmetric key) and rs_cnf carries the RS's public key when asymmetric keys are used. It also gives the CBOR mapping for the introspection 'cnf' member (RFC 8705 §9.4). Values reuse the cnf syntax of RFC 8747 (CBOR) or RFC 7800 (JSON), and JSON MAY be used over HTTP.

**Why it was created.** Classic OAuth had no standard way for a client to ask for a token bound to a specific key, or for the AS to hand the client the PoP key and the RS's authentication key. ACE needs both so that client and RS can mutually authenticate with AS-provisioned keys. The parameters were split out of RFC 9200 so other specifications can reuse them.

<details><summary>Already modeled in the YAML (3)</summary>

- components.schemas.IntrospectionResponse.cnf (lines 1748-1753): JSON form of the introspection 'cnf' member (RFC 8705 §9.4), whose CBOR mapping RFC 9201 §4 defines and which §5 makes REQUIRED for PoP tokens
- components.schemas.Confirmation (lines 2575-2591): the RFC 7800 cnf syntax that req_cnf/cnf/rs_cnf reuse for JSON-based interactions (§3.1, §3.2) — jwk (line 2587), kid (line 2590)
- components.schemas.JWK (lines 1822-1902), including the kty example 'oct' (line 1835) and k (line 1900): can express a symmetric PoP key inside cnf.jwk

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9201.

**Notes.** IANA: req_cnf (token request), and rs_cnf and cnf (token response), in OAuth Parameters; CBOR keys 4, 8 and 41. AS rules worth knowing even if not modeled: verify possession of any key sent in req_cnf; it is RECOMMENDED to reject raw symmetric keys in req_cnf; rs_cnf MUST NOT be used when the audience spans several resource servers (§5); an RS MUST NOT hold several asymmetric key pairs for the same algorithm (§7). In a form-encoded HTTP request (RFC 9200 §5.8.1), req_cnf would need to be JSON-serialized like authorization_details; RFC 9431 sidesteps this by using application/ace+json bodies. No errata.

### Findings (0 high · 0 medium · 4 low)

1. **[LOW] Gap: req_cnf token-request parameter**  
   *Reference:* RFC 9201 §3.1, §5, §10.1  
   Absent from every token-request schema (the TokenRequest oneOf at lines 1152-1171, e.g. ClientCredentialsTokenRequest at lines 1268-1282). It carries the key the client wants bound to the token; in JSON it is an RFC 7800 cnf object ({'jwk': {...}} or {'kid': '...'}). The AS MUST verify that the client possesses the key, and it is RECOMMENDED to reject raw symmetric keys. With form encoding (RFC 9200 §5.8.1) it would need JSON serialization, like authorization_details (lines 1224-1233).  
   *Suggested change:* Only if ACE is supported: add a mixin `PoPKeyRequestFields` {req_cnf: {type: string, description: 'RFC 9201 §3.1 — JSON-encoded RFC 7800 cnf object (decoded value conforms to Confirmation: jwk or kid). The AS MUST verify proof of possession and SHOULD reject symmetric key values.'}} and allOf it into ClientCredentialsTokenRequest and AuthorizationCodeTokenRequest; in an application/ace+json body type it as $ref Confirmation.  
   *Verifier: confirmed.*

2. **[LOW] Gap: cnf token-response parameter**  
   *Reference:* RFC 9201 §3.2, §5, §10.1; RFC 9200 §5.8.2 (Table 2)  
   TokenResponse (lines 1400-1461) has no cnf member; it validates only via additionalProperties: true (line 1409). RFC 9201 makes it REQUIRED when token_type is pop and a symmetric key is used (the AS-generated PoP key returned to the client) and OPTIONAL for asymmetric keys. The IANA-vs-YAML diff reports 'cnf' as present only because the RFC 7800 claim and RFC 8705 introspection member exist.  
   *Suggested change:* If ACE is supported, add to components.schemas.TokenResponse.properties: `cnf: {$ref: '#/components/schemas/Confirmation', description: 'RFC 9201 §3.2 — PoP key selected by the AS; REQUIRED for PoP tokens bound to a symmetric key (e.g. {jwk: {kty: oct, kid, k}}); the response MUST be confidentiality-protected (RFC 9200 §6.2).'}`.  
   *Verifier: partially correct —* TokenResponse lacks the cnf parameter of RFC 9201 §3.2. It is REQUIRED only when the AS generated the symmetric PoP key (no req_cnf). It is OPTIONAL for asymmetric keys or when the client referenced an existing key through req_cnf.kid (RFC 9201 §5). It MUST be omitted on an OSCORE-profile rights update (RFC 9203 §3.2).

3. **[LOW] Gap: rs_cnf token-response parameter**  
   *Reference:* RFC 9201 §3.2, §5, §10.1  
   Absent. It carries the RS's public key so the client can authenticate the RS (DTLS RPK, MQTT broker). It is OPTIONAL for pop tokens with asymmetric keys, MUST NOT be present otherwise, and MUST NOT be used when the audience includes several resource servers.  
   *Suggested change:* If ACE is supported, add `rs_cnf: {$ref: '#/components/schemas/Confirmation', description: 'RFC 9201 §3.2 — RS authentication key (asymmetric PoP only; MUST NOT be sent for multi-RS audiences).'}` to TokenResponse.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Confirmation.jwk and IntrospectionResponse.cnf documentation**  
   *Reference:* RFC 9201 §3, §5; RFC 7800 §3.2  
   Confirmation.jwk (lines 2587-2589) is an untyped object described as 'Embedded JWK; rarely used', and IntrospectionResponse.cnf (lines 1748-1753) mentions only DPoP jkt and mTLS x5t#S256. In ACE JSON interactions (RFC 9201 via RFC 7800 syntax; RFC 9431 §2.1), jwk is the primary carrier of the PoP key — a client RPK or an AS-generated symmetric key (kty oct) — and §5 makes cnf REQUIRED in introspection responses for PoP tokens.  
   *Suggested change:* Set Confirmation.properties.jwk to `$ref: '#/components/schemas/JWK'` with description 'Embedded JWK (RFC 7800 §3.2); the usual carrier for ACE PoP keys (RFC 9201, RFC 9431); a symmetric (oct) key may only appear in confidentiality-protected messages or encrypted tokens'; append to IntrospectionResponse.cnf.description: 'For ACE PoP tokens cnf is REQUIRED (RFC 9201 §5).'  
   *Verifier: confirmed.*

## RFC9202 Datagram Transport Layer Security (DTLS) Profile for Authentication and Authorization for Constrained Environments (ACE)

*August 2022 · Proposed Standard (updated by RFC 9430) · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** The 'coap_dtls' ACE profile (CBOR value 1): client and RS speak CoAP over DTLS 1.2+ using keys the AS provisions. In raw-public-key mode, the client sends its RPK in req_cnf, the AS binds that key in the token's cnf and returns the RS key in rs_cnf. In pre-shared-key mode, the AS returns a symmetric key in cnf and puts it (or a kid from which the RS derives it with HKDF) into an encrypted CWT. Tokens reach the RS via /authz-info or the DTLS psk_identity, and a new token for the same key can upgrade an existing DTLS session's permissions.

**Why it was created.** To give constrained servers a concrete, interoperable way to delegate client authentication and authorization to an AS using DTLS — the security protocol CoAP already mandates — with raw public keys or pre-shared keys instead of a full PKI.

<details><summary>Already modeled in the YAML (2)</summary>

- paths./token.post (lines 210-268) + components.schemas.ClientCredentialsTokenRequest (lines 1268-1282): the client_credentials token request of RFC 9202 Fig. 3, minus its audience and req_cnf
- components.schemas.ErrorResponse.error invalid_request (line 1479): the error shown in RFC 9202 Fig. 8

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9202.

**Notes.** The AS-side rules are transport-agnostic: §6 allows non-CoAP client-AS channels, and RFC 9431 reuses §3.2.1/§3.3.1 over HTTPS. Reported erratum 8231: in PSK mode the kid comes from the token response's cnf parameter, not rs_cnf (rs_cnf is only for asymmetric keys, RFC 9201 §3.2). Mandatory-to-implement cipher suites: TLS_ECDHE_ECDSA_WITH_AES_128_CCM_8 + curve25519 (RPK) and TLS_PSK_WITH_AES_128_CCM_8 (PSK). Updated by RFC 9430 (DTLS → DTLS or TLS).

### Findings (0 high · 0 medium · 2 low)

1. **[LOW] Gap: coap_dtls token-endpoint rules (RPK/PSK key provisioning)**  
   *Reference:* RFC 9202 §3.2.1, §3.3.1, §4, §9  
   AS duties under this profile: check that the client is associated with the RPK in req_cnf and bind it in the token's cnf; return rs_cnf unless certain the client already knows the RS key; for PSK, generate a new symmetric key when the req_cnf kid is unknown, return it in cnf, and encrypt any token that carries it; when a client asks to update an existing DTLS session's permissions with a kid, reject unknown kids with unsupported_pop_key; ace_profile value 'coap_dtls'. None of these parameters or values exist in the YAML (see the RFC 9200/9201 gaps).  
   *Suggested change:* No separate change to the core spec; in any ACE overlay, list 'coap_dtls' among the ace_profile examples and copy these rules into the ACE token request/response descriptions.  
   *Verifier: confirmed.*

2. **[LOW] Gap: When the AS issues a token that updates the authorization of an existing DTLS session, it must put the client-supplied kid into the new token** — *found by the verifier*  
   *Reference:* RFC 9202 §4  
   When the AS issues a token that updates the authorization of an existing DTLS session, it must put the client-supplied kid into the new token. This is not in the first agent's coap_dtls gap.  
   *Suggested change:* Add this rule to the coap_dtls rules listed for any ACE overlay.

## RFC9430 Extension of the Datagram Transport Layer Security (DTLS) Profile for Authentication and Authorization for Constrained Environments (ACE) to Transport Layer Security (TLS)

*July 2023 · Proposed Standard (updates RFC 9202) · YAML coverage: **not-applicable** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** A six-page update to RFC 9202: the coap_dtls profile applies to TLS (CoAP over TCP) as well as DTLS. 'coap_dtls' in ace_profile now means 'DTLS or TLS', and the same access token works over either. Clients and resource servers SHOULD support DTLS and MAY support TLS; non-constrained nodes SHOULD support both, and a client typically tries DTLS first.

**Why it was created.** UDP is often blocked by NATs and firewalls on Internet paths, forcing CoAP over TCP/TLS; the DTLS-only profile left those deployments without an ACE profile.

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9430.

**Notes.** No AS-visible change: the profile name and CBOR value (1) are unchanged, and the IANA ACE Profiles entry now cites both RFC 9202 and RFC 9430. Only the client-RS secure channel is affected. No errata.

_No open findings._

## RFC9203 The Object Security for Constrained RESTful Environments (OSCORE) Profile of the Authentication and Authorization for Constrained Environments (ACE) Framework

*August 2022 · Proposed Standard · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** The 'coap_oscore' profile (CBOR value 2). In the token response the AS returns OSCORE input material — master secret 'ms', identifier 'id', and optionally alg, hkdf, salt, contextId, version — in cnf under the new 'osc' confirmation method, and puts the same material in the encrypted access token. The client posts the token to the RS's /authz-info with a random nonce1 and its recipient ID; the RS answers 2.01 with nonce2 and its own ID, and both sides derive an OSCORE security context. Proof of possession therefore happens implicitly when the first OSCORE-protected exchange verifies, and OSCORE protects CoAP end to end, even through proxies.

**Why it was created.** Transport security (DTLS) terminates at proxies, while many constrained deployments need end-to-end application-layer protection. The AS therefore needed a way to provision OSCORE keys; the exchanged nonces prevent AEAD nonce/key reuse when a token is reposted, for example after a reboot.

<details><summary>Already modeled in the YAML (2)</summary>

- components.schemas.Confirmation (lines 2575-2591): an open object (no additionalProperties:false), so a JSON cnf.osc member would validate, but osc is not documented
- components.schemas.ErrorResponse.error invalid_request (line 1479): the code §3.1 requires when req_cnf.kid does not identify a previously issued OSCORE Input Material

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9203.

**Notes.** The client-AS leg may use HTTP or CoAP with TLS, DTLS or OSCORE (Appendix A), so the JSON OSCORE_Input_Material (Fig. 9: {'alg': 'AES-CCM-16-64-128', 'id': 'AQ', 'ms': '...'}) can appear in an HTTP token response. To update access rights, the client sends req_cnf {kid: &lt;OSCORE Input Material id>}; the AS MUST verify that it identifies a PoP key previously issued to that client, otherwise invalid_request (§3.1). The AS MUST send different input material to different clients. Reported erratum 8678: §4.2 should cite RFC 9200 §5.10.3. Creates the IANA 'OSCORE Security Context Parameters' registry, later extended by draft-ietf-ace-key-groupcomm-oscore.

### Findings (0 high · 0 medium · 3 low)

1. **[LOW] Gap: osc confirmation method (OSCORE_Input_Material)**  
   *Reference:* RFC 9203 §3.2, §3.2.1, §9.5, §9.6  
   components.schemas.Confirmation (lines 2575-2591) lists jkt, x5t#S256, jwk and kid; the IANA JWT Confirmation Methods registry also has osc (RFC 9203), which is absent from the YAML. In a JSON token response the AS returns cnf.osc = {id, ms (both REQUIRED by §3.2), and optional version, hkdf, alg, salt, contextId}, with byte strings base64url-encoded; the same object goes into the token's cnf claim.  
   *Suggested change:* If ACE is supported, add to Confirmation.properties: `osc: {type: object, description: 'OSCORE_Input_Material (RFC 9203 §3.2.1) — OSCORE profile of ACE', properties: {id: {type: string, description: 'base64url'}, version: {type: integer}, ms: {type: string, description: 'base64url master secret'}, hkdf: {type: [string, integer]}, alg: {type: [string, integer]}, salt: {type: string}, contextId: {type: string}}}`; otherwise mention osc in Confirmation.description as a registered but unsupported method.  
   *Verifier: partially correct —* osc is absent from Confirmation. In JSON, RFC 9203 §3.2.1 specifies id, ms, salt and contextId as 'base64-encoded' byte strings, while the Fig. 9 example uses unpadded base64url. Any schema should note this ambiguity rather than assert base64url.

2. **[LOW] Gap: Client-RS parameters nonce1, nonce2, ace_client_recipientid, ace_server_recipientid**  
   *Reference:* RFC 9203 §4.1.1, §4.1.2, §4.2.1, §4.2.2, §9.2  
   These are registered in the IANA OAuth Parameters registry with usage locations 'client-rs request' and 'rs-client response': they are exchanged with the RS's /authz-info endpoint, never with the AS. They are correctly absent from the AS schemas, but registry-driven completeness checks, such as the IANA absence list, flag them.  
   *Suggested change:* No schema change. Record them, together with RFC 9594's sign_info and kdcchallenge, as 'RS-side, out of scope' in the audit allow-list (e.g. a note in references/audit or a comment above components.schemas) so future IANA diffs do not re-flag them.  
   *Verifier: confirmed.*

3. **[LOW] Gap: On an OSCORE rights update the AS must omit cnf from the token response and carry the OSCORE Input Material id as cnf.kid in the token** — *found by the verifier*  
   *Reference:* RFC 9203 §3.1, §3.2  
   On an OSCORE rights update the AS must omit cnf from the token response and carry the OSCORE Input Material id as cnf.kid in the token. This contradicts the first agent's suggested TokenResponse.cnf text ('REQUIRED for PoP tokens bound to a symmetric key').  
   *Suggested change:* Any TokenResponse.cnf description in an ACE overlay should list this exception alongside RFC 9201 §5.

## RFC9237 An Authorization Information Format (AIF) for Authentication and Authorization for Constrained Environments (ACE)

*August 2022 · Proposed Standard · YAML coverage: **not-applicable** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Defines AIF, a compact allow-list model for authorization information: an array of [object-identifier, permission-set] pairs (AIF-Generic&lt;Toid, Tperm>). Its REST instance uses a URI local path plus a bitmask of methods (GET=1, POST=2, PUT=4, DELETE=8, …, with Dynamic-X bits for resources the subject itself created), e.g. [['/s/temp',1],['/a/led',5]]. It registers application/aif+cbor and application/aif+json (with Toid/Tperm media-type parameters) and is what ACE profiles carry as a structured scope.

**Why it was created.** Space-delimited OAuth scope strings are too coarse and not self-describing for device resources; constrained resource servers needed a compact, precise, machine-checkable statement of which methods are allowed on which resources.

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9237.

**Notes.** AIF is ACE's counterpart of Rich Authorization Requests. RAR (RFC 9396, modeled at components.parameters.AuthorizationDetails line 870, AuthorizationDetailsField line 1224 and AuthorizationDetail line 2596) sends typed JSON objects in requests; AIF is an array of [Toid, Tperm], normally placed in a (binary) scope or a token claim. AIF is not an OAuth parameter itself, so there is nothing to add to the HTTP AS spec. Instances: AIF-MQTT topic filters + 'pub'/'sub' (RFC 9431 §2.3, §7.4) and group name + roles (RFC 9594 §3.1). No errata.

_No open findings._

## RFC9431 Message Queuing Telemetry Transport (MQTT) and Transport Layer Security (TLS) Profile of Authentication and Authorization for Constrained Environments (ACE) Framework

*July 2023 · Proposed Standard · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** The 'mqtt_tls' profile (CBOR value 3) brings ACE proof-of-possession tokens to MQTT brokers; the Broker acts as the RS. Unlike the CoAP profiles, clients and the Broker reach the AS over HTTPS with JSON, using the RFC 9200 token and introspection endpoints and the media type application/ace+json (registered here); tokens are JWTs (CWTs optional) bound to keys via cnf. A client presents the token in the MQTT v5 CONNECT/AUTH packets (or publishes it to a public 'authz-info' topic) and proves possession over TLS (RPK/PSK) or by signing a TLS-exporter or broker challenge. The JWT scope is a base64url-encoded AIF-MQTT array of topic filters with 'pub'/'sub' permissions.

**Why it was created.** MQTT's native username/password authentication and lack of standardized per-topic authorization were inadequate for IoT publish/subscribe; ACE offered delegated, key-bound, topic-level authorization.

<details><summary>Already modeled in the YAML (4)</summary>

- paths./token.post (lines 210-268) and paths./introspect.post (lines 315-363): the HTTPS token and introspection endpoints the profile uses (§2, Appendix A)
- components.schemas.ErrorResponse (lines 1465-1533): JSON AS errors follow RFC 6749 §5.2 (§2.1)
- components.schemas.JWK (lines 1822-1902) with kty 'oct' / k: lets cnf carry the pre-shared key as a JWK (§2.1)
- IntrospectionResponse.cnf (line 1748), JWTAccessTokenClaims.cnf (line 2568) and Confirmation (line 2575): the cnf the Broker validates (§2.2.5)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9431.

**Notes.** This is the ACE document closest to the YAML's world (HTTPS + JSON AS endpoints), so it is the natural starting point if ACE support is ever added. Other AS-relevant points: RPK/PSK token issuance follows RFC 9202 §3.2.1/§3.3.1; ace_profile, if present, is 'mqtt_tls'; the AS MAY put the RS certificate thumbprint in rs_cnf (§2.2.1, RFC 9360); JSON AS errors follow RFC 6749 §5.2 and CBOR ones RFC 9200 §5.8.3. Broker side: mandatory-to-implement HS256 and Ed25519 (§2.2.5); AS discovery via the CONNACK User Property 'ace_as_hint' (§2.4.1). Registers the TLS exporter label EXPORTER-ACE-MQTT-Sign-Challenge. No errata.

### Findings (0 high · 0 medium · 4 low)

1. **[LOW] Gap: application/ace+json request and response bodies at /token and /introspect**  
   *Reference:* RFC 9431 §1, §2.1, §7.2, Appendix A  
   The profile's HTTPS AS interactions use the media type application/ace+json: a JSON object body (not form-encoded) and JSON responses (RFC 9770 Fig. 4 shows response Content-Type application/ace+json). The YAML's /token request body allows only application/x-www-form-urlencoded (line 244) and its 200 only application/json (line 258); /introspect is the same (lines 331, 343). A server generated from the YAML would answer 415 to an MQTT-TLS client. RFC 9200 §5.8.1 itself specifies form encoding over HTTP, so this is a profile-specific override.  
   *Suggested change:* If ACE/MQTT clients are in scope: add `application/ace+json: {schema: {$ref: '#/components/schemas/ACETokenRequest'}}` under paths./token.post.requestBody.content (a JSON object with optional grant_type, audience, scope, req_cnf ($ref Confirmation), ace_profile, cnonce, client_id), and list `application/ace+json` alongside application/json in the 200 response; do the same for /introspect. Otherwise state in the /token description that ACE encodings (application/ace+json, application/ace+cbor) are not supported.  
   *Verifier: confirmed.*

2. **[LOW] Gap: JWT scope claim as base64url-encoded AIF-MQTT**  
   *Reference:* RFC 9431 §2.3, §7.4; RFC 9237 §2-§3  
   For mqtt_tls JWTs the scope claim is a single base64url (unpadded) string whose decoded value is a JSON AIF-MQTT array, e.g. [['topic1',['pub','sub']],['topic2/#',['pub']]]. JWTAccessTokenClaims.scope (lines 2556-2558) is described as 'OAuth scopes granted (space-delimited)', which is right for RFC 9068 tokens but is not the only standardized shape.  
   *Suggested change:* Append to components.schemas.JWTAccessTokenClaims.properties.scope.description: 'RFC 9068 tokens use space-delimited scope tokens; ACE profiles may use structured scopes instead (e.g. RFC 9431 §2.3: a base64url-encoded AIF array of [topic-filter, [pub|sub]]).'  
   *Verifier: confirmed.*

3. **[LOW] Gap: PSK delivery: cnf with a symmetric JWK and an encrypted JWT access token**  
   *Reference:* RFC 9431 §2.1; RFC 9201 §3.2  
   In PSK mode the AS adds to the Access Information a cnf carrying a JWK that holds the symmetric key (or a kid), and the JWT access token MUST be encrypted (JWE) because it carries that key. The YAML has no TokenResponse.cnf, describes Confirmation.jwk as 'rarely used' (line 2589), and JWTAccessTokenClaims assumes a signed at+jwt.  
   *Suggested change:* Covered by the RFC 9201 cnf/jwk changes. Additionally note in components.schemas.JWTAccessTokenClaims.description that access tokens carrying symmetric PoP keys must be nested JWTs (signed, then encrypted; RFC 7519 §7); the components.schemas.JWT pattern (line 2440) already admits 5-segment JWE.  
   *Verifier: confirmed.*

4. **[LOW] Gap: The AIF-MQTT scope format of mqtt_tls (unpadded base64url of a JSON AIF array) also governs the introspection result, and implicitly the scope the AS authorizes** — *found by the verifier*  
   *Reference:* RFC 9431 §2.1, §2.3  
   The AIF-MQTT scope format of mqtt_tls (unpadded base64url of a JSON AIF array) also governs the introspection result, and implicitly the scope the AS authorizes in the token request. The first agent's suggestion only touches JWTAccessTokenClaims.scope.  
   *Suggested change:* If an ACE/MQTT overlay is built, apply the same structured-scope note to IntrospectionResponse.scope and to the token-request and token-response scope.

## RFC9594 Key Provisioning for Group Communication Using Authentication and Authorization for Constrained Environments (ACE)

*September 2024 · Proposed Standard · YAML coverage: **not-applicable** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Uses ACE to authorize a node to join a security group. A Key Distribution Center (KDC, acting as the RS) then hands out group keying material through a CoAP REST interface (/ace-group, /ace-group/GROUPNAME, …/creds, …/kdc-cred, …/policies, …/num, …/nodes/NODENAME) using application/ace-groupcomm+cbor, and manages rekeying and eviction. The AS's part is ordinary ACE: a token request whose scope is a CBOR byte string listing group names and roles (AIF by default) and whose audience names the KDC; the token upload to /authz-info may carry sign_info and returns a kdcchallenge. Concrete group-security protocols such as Group OSCORE are left to application profiles.

**Why it was created.** Group communication (multicast, publish/subscribe) cannot rely on pairwise DTLS/OSCORE keys. Members need shared group keys, controlled admission with roles, and rekeying for forward/backward security, with the admission decision delegated to an AS.

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9594.

**Notes.** sign_info (client-rs request, rs-client response) and kdcchallenge (rs-client response) are registered in the IANA OAuth Parameters registry, but they are KDC/RS-side parameters; the IANA absence list flags them, yet they must not be added to AS token-endpoint schemas. The AS-facing pieces are CBOR-only (byte-string scope; the extended scope format in §7 wraps the scope in a CBOR tag). Reported errata 8239 and 8864 concern KDC examples and CDDL only. Pipeline: draft-ietf-ace-key-groupcomm-oscore-21 and draft-ietf-ace-oscore-gm-admin-17 are both in the RFC Editor queue; IANA already lists their values, including the OAuth Parameters ecdh_info and kdc_dh_creds, which are also client-RS only.

_No open findings._

## RFC9770 Notification of Revoked Access Tokens in the Authentication and Authorization for Constrained Environments (ACE) Framework

*June 2025 · Proposed Standard · YAML coverage: **not-applicable** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** Lets an ACE AS tell registered clients and resource servers which of their access tokens were revoked before expiry. The AS exposes a Token Revocation List (TRL) endpoint (default path /revoke/trl) that devices query with CoAP GET, usually as a CoAP Observe subscription so updates are pushed. It returns SHA-256 token hashes (RFC 6920 format, computed over the exact access_token string or bytes the client received) as application/ace-trl+cbor, either the full set or diffs with an optional cursor. It also constrains token issuance: every JOSE/COSE header parameter must be integrity-protected (compact JWS/JWE for JWTs; empty unprotected maps and exact CBOR tagging for CWTs).

**Why it was created.** ACE tokens for intermittently connected devices are often long-lived, and OAuth had standardized only client-initiated revocation (RFC 7009). Resource servers and clients needed to learn about AS-side revocations without hosting extra endpoints, as a complement to introspection.

<details><summary>Already modeled in the YAML (3)</summary>

- paths./revoke.post (lines 273-310): RFC 7009 client-initiated revocation, the mechanism RFC 9770 §1 calls insufficient for long-lived ACE tokens and complements (the TRL itself is not modeled)
- components.schemas.JWT (lines 2434-2441): compact JWS/JWE only, consistent with §3's requirement that all JWT header parameters be integrity-protected
- components.schemas.TokenResponse.access_token (line 1411) with the Cache-Control/Pragma headers (components.headers, lines 990-999): matches the JSON AS-to-Client response of §4.2.2 Fig. 4, whose exact access_token string is the token-hash input

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9770.

**Notes.** CoAP-only today (§1: other protocols are not prohibited in the future), with no AS metadata or OAuth registry entries: the TRL path, hash function, MAX_N and MAX_DIFF_BATCH are provisioned at device registration (§10). Errors use Concise Problem Details (RFC 9290) with the 'ace-trl-error' entry. The default TRL path nests under '/revoke', the path name the YAML uses for RFC 7009; this is harmless because the TRL is a CoAP resource. HTTP-world analogues for propagating AS-side revocation: Token Status List (draft-ietf-oauth-status-list-21, in the RFC Editor queue) and SET push/poll delivery (RFC 8935/8936). No errata.

_No open findings._

## RFC7744 Use Cases for Authentication and Authorization in Constrained Environments

*January 2016 · Informational · YAML coverage: **not-applicable** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** An informational catalogue of IoT authorization scenarios — container monitoring, home automation (letting in a visitor, selling the house), personal health monitoring, building automation across the device life cycle, smart metering, connected sports equipment and industrial control. Each ends with an 'Authorization Problems Summary', for example U2.11/U2.13: transfer ownership and invalidate the previous owner's access rights. It defines no protocol and never mentions OAuth; it is the requirements input that shaped ACE-OAuth (cited in RFC 9200 §1 and §4).

**Why it was created.** Before choosing a solution, the ACE WG needed agreed requirements for devices with no UI and intermittent connectivity: offline authorization, dynamic and delegated access, ownership transfer, and proxies.

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 7744.

**Notes.** Useful background for a learner (why IoT authorization differs from web OAuth), but there is nothing to model or vendor. No errata.

_No open findings._

## RFC9148 EST-coaps: Enrollment over Secure Transport with the Secure Constrained Application Protocol

*April 2022 · Proposed Standard (updated by RFC 9908, January 2026) · YAML coverage: **not-applicable** · relevance to an AS: not-applicable · vendoring: exclude*

**What it is.** Carries Enrollment over Secure Transport (EST, RFC 7030) certificate-enrollment messages over CoAP secured with DTLS, using short resource paths (/crts, /sen, /sren, /att, /skg, /skc), CoAP Content-Formats, block-wise transfer and proxy guidance, so constrained devices can obtain and renew X.509 certificates.

**Why it was created.** EST runs over HTTPS, which is too heavy for constrained devices; they needed certificate provisioning over CoAP/DTLS.

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9148.

**Notes.** False positive of the WG-based filter: produced by the ACE WG but contains no OAuth element — the only 'ace' strings are CoRE resource types (ace.est.crts, …). Its IANA well-known URI 'est' (RFC 7030 / RFC 9148) is unrelated to OAuth. Updated by RFC 9908 (LAMPS WG, CSR attributes).

_No open findings._

## RFC9482 Constrained Application Protocol (CoAP) Transfer for the Certificate Management Protocol

*November 2023 · Proposed Standard · YAML coverage: **not-applicable** · relevance to an AS: not-applicable · vendoring: exclude*

**What it is.** Specifies CoAP as a transfer mechanism for the Certificate Management Protocol (CMP), following CMP's HTTP transfer. Requests go to coap(s)://host/.well-known/cmp (optionally with a profile label and an operation path), with block-wise transfer, CoAP-to-HTTP proxy guidance and security considerations, so constrained devices can request, renew and revoke certificates.

**Why it was created.** CMP had only an HTTP transfer (RFC 6712, since replaced by RFC 9811); constrained IoT devices needed a CoAP binding.

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9482.

**Notes.** False positive of the WG-based filter: an ACE WG product with no OAuth content (the text never mentions OAuth or access tokens). The IANA well-known URI 'cmp' (RFC 9811, RFC 9482) is PKI-related.

_No open findings._

## RFC9820 Authentication Service Based on the Extensible Authentication Protocol (EAP) for Use with the Constrained Application Protocol (CoAP)

*September 2025 · Proposed Standard · YAML coverage: **not-applicable** · relevance to an AS: not-applicable · vendoring: exclude*

**What it is.** Defines CoAP-EAP, an EAP lower layer over CoAP. An IoT device (EAP peer) authenticates to a Controller (EAP authenticator, optionally backed by a AAA server) when joining a security domain, starting from the device's /.well-known/coap-eap resource, and the resulting EAP MSK is used to derive an OSCORE security context between them.

**Why it was created.** IoT devices need a flexible, method-agnostic way to authenticate when onboarding into a security domain and to bootstrap keys for protecting CoAP traffic, without a separate link-layer EAP transport.

**Follow-up on the May-2026 validation notes.** No prior validation notes exist for RFC 9820.

**Notes.** False positive of the WG-based filter: this is network-access/bootstrapping authentication, not OAuth. ACE-OAuth (RFC 9200) appears only as an out-of-scope later phase (§8.2) and in Appendix C.1, where CoAP-EAP could provide the out-of-band client registration/credential provisioning that RFC 9200 leaves unspecified, with the EAP authenticator co-located with the AS. It defines no OAuth parameters, endpoints or tokens. The IANA well-known URI 'coap-eap' is unrelated to OAuth.

_No open findings._

## Verifier corrections to the summaries above

- RFC 9820 summary is wrong about who hosts the well-known resource. /.well-known/coap-eap belongs to the EAP authenticator (the Controller), not the device. §3.2 Step 0: 'The EAP peer MUST start the CoAP-EAP process by sending a "POST /.well-known/coap-eap" request (trigger message) ... This is the only message where the EAP authenticator acts as a CoAP server and the EAP peer acts as a CoAP client.' After that, the authenticator acts as CoAP client and POSTs EAP Requests to resources hosted on the device (§2).
- RFC 9770 summary: the token hash is not computed over 'the exact access_token string or bytes'. For CBOR (application/ace+cbor) AS responses, HASH_INPUT is the UTF-8 encoding of the base64url text of the access_token byte string (§4.2.1). Only for JSON (application/ace+json) responses is it the access_token string itself (§4.2.2). The hash function comes from the Named Information Hash Algorithm Registry and is communicated at registration; sha-256 is only mandatory to implement (§4.4, §10).
- RFC 9202 summary: deriving the PSK from a kid with HKDF is only an application-specific example (§3.3.1: 'the remainder of this section provides one example'). The COSE_Encrypt0 requirement applies when the token carries the symmetric key itself ('If the access token carries a symmetric key, the access token MUST be encrypted'), not to every PSK-mode token.
- RFC 9431 summary and cluster notes: the token 'MAY be an opaque reference to authorization information or a JSON Web Token', and CWTs MAY also be used (§1). HTTPS with application/ace+json is the described default, but Client-AS and Broker-AS exchanges 'MAY be implemented using protocols other than HTTPS, e.g., CoAP or MQTT' and MAY use application/ace+cbor (§1, §2, §2.1). So 'runs every AS interaction over HTTPS' is overstated. 'Unlike the CoAP profiles' is also misleading, because RFC 9202 §6 and RFC 9203 §5 and Appendix A also allow HTTP to the AS.
- Cluster notes, 'Only three things would block an ACE response or request': a fourth blocker is missing. /token and /introspect accept only application/x-www-form-urlencoded request bodies (lines 244, 331) and declare only application/json responses (plus token-introspection+jwt) (lines 258, 343). That rejects RFC 9431 application/ace+json bodies, which the first agent itself flags under RFC 9431.
- Cluster notes, pipeline: the active ACE WG documents also include draft-ietf-ace-oscore-gm-admin-coral-06 (WG Document, datatracker 2026-10-10). The full title of draft-ietf-ace-workflow-and-params-08 is 'Short Distribution Chain (SDC) Workflow and New OAuth Parameters for the Authentication and Authorization for Constrained Environments (ACE) Framework'. Confirmed correct: key-groupcomm-oscore-21 and oscore-gm-admin-17 are in the RFC Editor queue, and coap-pubsub-profile-05 is 'In WG Last Call'.
- RFC 8747 gap detail: the 'pairs' list is incomplete. The IANA CWT Confirmation Methods registry (updated 2026-07-20) also lists jkt (key 323, CTA-5007-B), and ckt (key 5, RFC 9679) has no JWT counterpart ('(none)').
- RFC 9201 why_created: certificate-bound access tokens already existed (RFC 8705, Feb 2020) as an implicit key-binding mechanism. What was missing was an explicit, transport-independent request parameter (req_cnf) and response parameters to deliver an AS-generated PoP key (cnf) and the RS's key (rs_cnf).
- Learner takeaway (PoP is not DPoP) is correct but incomplete. Besides upload to /authz-info and binding to a (D)TLS or OSCORE channel, ACE tokens can travel in a (D)TLS PSK identity (RFC 9202 §3.3.2) or the MQTT CONNECT packet. RFC 9431 §2.2.4.2 also allows proof of possession by a MAC or signature over TLS-exporter content or a Broker challenge in MQTT AUTH.
