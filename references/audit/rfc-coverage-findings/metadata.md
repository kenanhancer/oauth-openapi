# Metadata & discovery — RFC 8414, 9728, 6755, 8615, 3986

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC8414](#rfc8414-oauth-20-authorization-server-metadata) | June 2018 | Proposed Standard | mostly | 0 | 4 | 14 |
| [RFC9728](#rfc9728-oauth-20-protected-resource-metadata) | April 2025 | Proposed Standard | mostly | 0 | 1 | 11 |
| [RFC6755](#rfc6755-an-ietf-urn-sub-namespace-for-oauth) | October 2012 | Informational | mostly | 0 | 0 | 3 |
| [RFC8615](#rfc8615-well-known-uniform-resource-identifiers-uris) | May 2019 | Proposed Standard (obsoletes RFC 5785; updates RFC 7230, RFC 7595) | mostly | 0 | 0 | 5 |
| [RFC3986](#rfc3986-uniform-resource-identifier-uri-generic-syntax) | January 2005 | Internet Standard (STD 66); updated by RFC 8820 (BCP 190, formerly RFC 7320) | partial (verifier corrected from referenced-only) | 0 | 0 | 4 |

**Cluster notes.** Scope: RFC 8414, RFC 9728, RFC 6755, RFC 8615 and RFC 3986, compared against the snapshot oauth-openapi.yaml (2704 lines). The single biggest finding is item (3).
(1) IANA 'OAuth Authorization Server Metadata' registry (82 names; oauth-parameters.xml updated 2026-08-24). I compared it against the parsed property names of components.schemas.OAuthServerMetadata (lines 1941-2267), not a token search. Result: 65/82 present. All 36 names defined by published IETF RFCs are present (RFC 8414 x23, 8628, 8705 x2, 9101, 9126 x2, 9701 x3, 9207, 9396, 9449, 9728). All 29 OIDF names from OIDC Discovery, Session, Front/Back-Channel, RP-Initiated Logout and CIBA are also present. The 17 absent names break down as follows:
- 2 IETF drafts in the RFC Editor queue: status_list_aggregation_endpoint (draft-ietf-oauth-status-list-21 §9.1) and identity_chaining_requested_token_types_supported (draft-ietf-oauth-identity-chaining-16/-17 §3). Add them as optional members once they publish, if Token Status List or cross-domain token exchange is in scope.
- 12 from OpenID Federation 1.0 (Final, 17 Feb 2026): client_registration_types_supported, federation_registration_endpoint, signed_jwks_uri, jwks, organization_name, display_name, description, keywords, contacts, logo_uri, information_uri, organization_uri. Catalog-only unless Federation is implemented.
- 3 from ETSI NFV-SEC 022 (nfv_token_*). Exclude.
The IANA absence list says only 15 are absent (and 6 for PRM) because 'jwks' and 'description' match unrelated YAML tokens. The precise counts are 17 and 8.
Two YAML members are not in the IANA registry: frontchannel_logout_session_supported (defined by OIDF Front-Channel Logout 1.0 but never registered) and http_logout_supported (a legacy name that no final spec defines).
(2) IANA 'OAuth Protected Resource Metadata' registry (23 names): 15/23 present, which is every RFC 9728 name. The 8 absent names all come from OpenID Federation 1.0 (registered 2026-02-04).
(3) Path-component construction. This is the main gap.
- RFC 8414 §3.1 inserts '/.well-known/oauth-authorization-server' between the host and the issuer path: https://example.com/issuer1 becomes https://example.com/.well-known/oauth-authorization-server/issuer1.
- RFC 9728 §3.1 does the same for resource identifiers and keeps any query.
- OIDC Discovery §4.1 appends instead (/issuer1/.well-known/openid-configuration). RFC 8414 §5 tells clients to try the inserted form first.
The YAML models only the path-less forms, all under one server 'https://{issuer}' whose variable is described as a hostname. It also describes the issuer as the 'base of the discovery URL'. And it hangs the protected resource metadata (PRM) endpoint on the AS origin, although RFC 9728 derives the PRM URL from the resource identifier, so it belongs on the resource server's origin.
(4) signed_metadata exists in both schemas but is a plain 'type: string'. The AS version cites §3.1 instead of §2.1 for the precedence rule and omits the REQUIRED iss claim and the fact that precedence is conditional.
(5) I ran Ajv 6 (draft-07 mode) against the YAML's schemas.
- It accepted: issuer 'http://as.example.com/t1?x=1#f' with response_types_supported: []; an OAuth 2.1 document with no token_endpoint; alg 'none'; signed_metadata 'not-a-jwt'; and a PRM with resource 'my-api' and empty arrays.
- It rejected ['plain','S256'] and 'attest_jwt_client_auth', because those enums are closed.
(6) The RFC 9728 §5.1 resource_metadata auth-param is documented in components.headers.WWWAuthenticateBearerDPoP (lines 1014-1016, example at 1024). It reaches /userinfo 401/403 through ProtectedResourceError.
(7) URNs: all 11 urn:ietf:params:oauth values the YAML uses are IANA-registered and well-formed. 4 registered URIs are unused: the RFC 7522 saml2-bearer pair, the RFC 9278 jwk-thumbprint URI and the RFC 9679 ckt URI.
(8) Well-known URIs: the 3 suffixes used are all registered, but neither RFC 8615 nor RFC 5785 is ever cited.
Pointers for other clusters:
- JARM AS metadata (authorization_signing/encryption_* in JARM §4) is absent from both the IANA AS registry and the YAML. Yet response_modes_supported (line 2031) lists the JARM modes, and the /authorize ResponseMode parameter (lines 846-855) does not accept them.
- registration_endpoint, end_session_endpoint, check_session_iframe and backchannel_authentication_endpoint are advertised in metadata but have no paths.
- Metadata names in pending drafts, not yet registered: client_attestation_* and the PRM name challenge_endpoint (attestation-based-client-auth-11), client_id_metadata_document_supported, authorization_challenge_endpoint, deferred_token_response_supported, authorization_grant_profiles_supported, refresh_token_expiration_types_supported, authorization_details_types_metadata_endpoint.
Errata: RFC 8414 has 2 reported errata (7793: response_types_supported should be conditional; 9178: example issuer mismatch). RFC 9728, 6755 and 8615 have none.
oauth-openapi-modular/dist is data-identical for these schemas and paths, so fix the single file and re-split.
Vendoring: RFC 8414, 9728 and 6755 are already vendored. RFC 8615 should be vendored. RFC 3986 should be catalog-only. *(Update 2026-10-11: RFC 3986 is now vendored, because the scope rule vendors every RFC the YAML cites. RFC 8615 is not vendored, because the YAML does not cite it.)*

## RFC8414 OAuth 2.0 Authorization Server Metadata

*June 2018 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 8414 lets an OAuth 2.0 authorization server publish a JSON 'capabilities document' at a predictable https well-known URL derived from its issuer identifier. The document lists the server's endpoints (authorization, token, revocation, introspection, registration, JWK Set) and what it supports: response types/modes, grant types, client-authentication methods and their JWS algorithms, PKCE methods, UI locales and policy/ToS links. A client fetches it with GET, checks that the returned 'issuer' is exactly the identifier it started from, and configures itself; the values may also be delivered as a signed JWT (signed_metadata). It generalizes OpenID Connect Discovery 1.0 to any OAuth server and founds the IANA registry that later RFCs (PAR, mTLS, DPoP, RAR, RFC 9207, RFC 9728) extend.

**Why it was created.** RFC 6749 left endpoint discovery and server capabilities out of scope, so every AS documented its URLs ad hoc and clients hard-coded them. That was brittle and easy to misconfigure (including pasting an attacker's endpoint), and it blocked automatic roll-out of new security features. OpenID Connect Discovery 1.0 (2014) had solved this only for OpenID Providers. RFC 8414 standardizes that de facto format for all OAuth servers (Introduction, Acknowledgements) and binds it to an https issuer identifier so clients can detect impersonation and AS mix-up (§2 issuer, §3.3, §6.2). RFC 9700 §2.6 now RECOMMENDS publishing it so libraries can enable security features and rotate keys automatically.

<details><summary>Already modeled in the YAML (21)</summary>

- GET /.well-known/oauth-authorization-server -> 200 application/json, schema OAuthServerMetadata (paths, lines 630-648; externalDocs RFC 8414 §3)
- 'openid-configuration' suffix (RFC 8414 §3, §5) -> GET /.well-known/openid-configuration -> OpenIDProviderMetadata (603-625)
- https metadata URL via servers[0].url 'https://{issuer}' (77-86)
- components.schemas.OAuthServerMetadata: additionalProperties: true (1936; §3.2 'Other claims MAY'); required [issuer, response_types_supported] (1937-1940)
- components.schemas.OpenIDProviderMetadata = allOf(OAuthServerMetadata + OIDC-required members) (1907-1921)
- issuer (1944-1950)
- authorization_endpoint (1951-1953), token_endpoint (1954-1956)
- jwks_uri (1961-1964), registration_endpoint (1965-1968)
- introspection_endpoint (1969-1972), revocation_endpoint (1973-1976)
- scopes_supported (2016-2018), response_types_supported (2019-2026)
- response_modes_supported with documented default [query, fragment] (2027-2032)
- grant_types_supported with documented default [authorization_code, implicit] (2033-2036)
- token_endpoint_auth_methods_supported: enum of all 7 IANA methods, default client_secret_basic (2037-2049)
- token_endpoint_auth_signing_alg_values_supported incl. conditional-presence prose (2050-2056)
- revocation_endpoint_auth_methods_supported (2057-2059), revocation_endpoint_auth_signing_alg_values_supported (2060-2062)
- introspection_endpoint_auth_methods_supported (2063-2065), introspection_endpoint_auth_signing_alg_values_supported (2066-2068)
- ui_locales_supported (2146-2148)
- code_challenge_methods_supported, profiled to [S256] (2176-2185)
- service_documentation (2251-2253), op_policy_uri (2254-2256), op_tos_uri (2257-2259)
- signed_metadata (2261-2267)
- Registry extension members from other RFCs: device_authorization_endpoint 1977, pushed_authorization_request_endpoint 1981, mtls_endpoint_aliases 1997, introspection_signing/encryption_*_values_supported 2071-2079, require_pushed_authorization_requests 2166, require_signed_request_object 2170, dpop_signing_alg_values_supported 2188, tls_client_certificate_bound_access_tokens 2193, authorization_details_types_supported 2201, authorization_response_iss_parameter_supported 2206, protected_resources 2214 (65/82 IANA names overall)

</details>

**Follow-up on the May-2026 validation notes.** The May-2026 notes were written against the former shared DiscoveryDocument, so their line numbers no longer apply. They raised 23 items: 10 MISSING, 7 WRONG, 6 NICE-TO-HAVE.
15 fixed:
- All 10 missing members now exist (2050-2068, 2146, 2251-2267).
- The schema is split into OAuthServerMetadata + OpenIDProviderMetadata, with OIDC members documented as omittable (1907-1934).
- Defaults are documented for response_modes_supported (2032), grant_types_supported (2036) and token_endpoint_auth_methods_supported (2049).
- RFC 8414 and OIDC members are grouped with section comments.
1 partial: jwks_uri https is stated in prose (1964) but not enforced.
7 open, most important first:
- §3 multi-tenant path insertion.
- code_challenge_methods_supported omission semantics (§2); more important now that the profile requires PKCE.
- §3.3 issuer-validation consequence; the issuer text still says 'base of the discovery URL'.
- §6.1 TLS note.
- Example response.
- IANA-registry cross-reference.
- Cosmetic mixed-origin note on the auth-method enum.
Residuals inside the 'fixed' items:
- signed_metadata cites §3.1 instead of §2.1 and omits iss.
- The conditional-MUST and 'none' rules that motivated adding the *_auth_signing_alg arrays are still not encoded for revocation and introspection.
- code_challenge_methods_supported deliberately changed from [S256, plain] to a [S256] profile.

**Notes.** Precise IANA comparison: 65/82 present, including all 36 names from published IETF RFCs. The IANA absence list under-counts the absences by 2 ('jwks' and 'description' token false positives).
YAML-only members:
- frontchannel_logout_session_supported: defined in OIDF Front-Channel Logout 1.0 but never IANA-registered.
- http_logout_supported: a legacy pre-final name used by older Microsoft endpoints, defined by no final spec. Consider marking it legacy or dropping it, given the repo's no-vendor-extension rule.
JARM: its three AS metadata members (JARM §4, authorization_signing/encryption_*) are neither IANA-registered nor in the YAML, although response_modes_supported (2031) advertises jwt modes. The /authorize ResponseMode parameter (846-855) accepts only query, fragment and form_post. This belongs to the JARM/OIDF cluster.
Advertised endpoints with no path in the YAML: registration_endpoint, end_session_endpoint, check_session_iframe, backchannel_authentication_endpoint.
Errata (rfc-editor.org): 7793 (Reported, Technical) says response_types_supported should be REQUIRED only when the authorization endpoint is used. 9178 (Reported) says the §3.2 example issuer does not match §3.1, and notes that many deployments violate the issuer-match rule.
Ajv check against the YAML schemas confirmed the empty-array, missing token_endpoint, 'none' alg, http/query/fragment issuer and non-JWT signed_metadata cases. It also showed that the deliberate S256-only and closed auth-method enums reject valid third-party documents.
The modular bundle is data-identical for these schemas.

### Findings (0 high · 4 medium · 14 low)

1. **[MEDIUM] Gap: Well-known URL construction for issuers that contain a path component (multi-tenant issuers)**  
   *Reference:* RFC 8414 §3, §3.1, §5  
   Only the path-less form GET /.well-known/oauth-authorization-server (line 630) exists. servers[0] (77-86) documents {issuer} as a hostname whose 'path layout ... is vendor-specific'. RFC 8414 §3 MUST: the document lives at the URL formed by inserting the well-known string between the host and the issuer's path, after removing any terminating '/' (§3.1). For example, https://example.com/issuer1 becomes https://example.com/.well-known/oauth-authorization-server/issuer1. OIDC Discovery 1.0 §4.1 instead appends (https://example.com/issuer1/.well-known/openid-configuration). RFC 8414 §5 says new deployments should use insertion. For the 'openid-configuration' suffix only, a server may publish at both locations during a transition, and clients should try the inserted form first. None of this is in the YAML. A multi-tenant AS whose issuer carries a tenant path, built from this contract, would most naturally serve the appended URL and violate §3.  
   *Suggested change:* Add a templated path and document both rules, e.g.

   ```yaml
   /.well-known/oauth-authorization-server/{issuerPath}:
     get:
       tags: [Discovery]
       operationId: authorizationServerMetadataForPathIssuer
       description: |
         Issuer https://as.example.com/tenant1 -> GET https://as.example.com/.well-known/oauth-authorization-server/tenant1
         (well-known string INSERTED between host and path; strip a terminating '/' first - RFC 8414 §3.1).
         The returned issuer MUST equal https://as.example.com/tenant1 (§3.3).
       parameters:
         - {name: issuerPath, in: path, required: true, schema: {type: string}, description: 'issuer path without the leading /; multi-segment paths cannot be expressed by an OAS path template - document them in prose'}
       responses: {'200': {description: AS metadata, content: {application/json: {schema: {$ref: '#/components/schemas/OAuthServerMetadata'}}}}}
   ```

   Also reword servers[0].variables.issuer.description to 'authority (host[:port]) of the issuer; issuers with a path use the {issuerPath} variants'. Add to /.well-known/openid-configuration that OIDC Discovery §4.1 appends, while RFC 8414 §5 recommends the inserted form /.well-known/openid-configuration/{issuerPath}; publish both during a transition.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Zero-element arrays MUST be omitted**  
   *Reference:* RFC 8414 §3.2  
   None of the 35 array-valued members of OAuthServerMetadata carries minItems (examples: scopes_supported 2016, response_types_supported 2019, grant_types_supported 2033, the *_alg_values_supported arrays 2050-2112, protected_resources 2214). An Ajv run accepted response_types_supported: []. Code generators that initialise optional lists to empty collections will therefore emit [], which violates the §3.2 MUST. Related: RFC 8414 Errata 7793 (Reported, Technical) points out that a client_credentials-only AS cannot satisfy both the REQUIRED response_types_supported and the no-empty-array rule.  
   *Suggested change:* Add 'minItems: 1' to every array member of OAuthServerMetadata (and 'minProperties: 1' to mtls_endpoint_aliases). Add to the schema description: 'Members whose value would be an empty array MUST be omitted (RFC 8414 §3.2).' Mention Errata 7793 in the response_types_supported description.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: code_challenge_methods_supported: omission means 'no PKCE'; OAuth 2.1 detection requirement**  
   *Reference:* RFC 8414 §2 (code_challenge_methods_supported); RFC 9700 §2.1.1; draft-ietf-oauth-v2-1-16 §7.10  
   RFC 8414 §2 says: 'If omitted, the authorization server does not support PKCE.' The YAML description (2181-2185) explains only the S256 profile, and the member is optional. RFC 9700 §2.1.1 says ASes MUST provide a way to detect PKCE support and RECOMMENDS publishing this member. OAuth 2.1-16 §7.10 says the AS MUST provide a way to detect its supported code challenge methods, via RFC 8414 metadata or a deployment-specific way. This YAML's profile makes PKCE mandatory, yet a server generated from it that simply omits the member tells RFC 8414 clients it has no PKCE. This was already an open item in the May-2026 audit.  
   *Suggested change:* code_challenge_methods_supported: add 'minItems: 1' and the description 'If omitted, clients MUST assume the AS does not support PKCE (RFC 8414 §2). OAuth 2.1 servers publish [S256] (RFC 9700 §2.1.1 RECOMMENDED; OAuth 2.1 §7.10).' Add it to OAuthServerMetadata.required, or define a profile schema OAuth21AuthorizationServerMetadata: allOf [OAuthServerMetadata, {required: [token_endpoint, grant_types_supported, code_challenge_methods_supported]}].  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: Conditional MUSTs for *_auth_signing_alg_values_supported and the 'none' prohibition**  
   *Reference:* RFC 8414 §2 (token_/revocation_/introspection_endpoint_auth_signing_alg_values_supported)  
   Each of the three lists MUST be present when private_key_jwt or client_secret_jwt appears in the matching *_auth_methods_supported, and 'none' MUST NOT be used. For the token endpoint, 'Servers SHOULD support RS256'. Only the token-endpoint presence rule is stated, and only in prose (2053-2056). The revocation (2060-2062) and introspection (2066-2068) lists have no description, and nothing excludes 'none'. An Ajv run accepted ['none'], and accepted revocation private_key_jwt without its alg list. These conditions are why the May-2026 audit asked for these fields, and they are still not encoded.  
   *Suggested change:* For all three arrays: 'items: {type: string, not: {const: none}}', 'minItems: 1', and descriptions quoting §2 (for the token endpoint: 'Servers SHOULD support RS256'). At schema level add three if/then blocks, e.g.

   ```yaml
   - if: {required: [revocation_endpoint_auth_methods_supported], properties: {revocation_endpoint_auth_methods_supported: {contains: {enum: [private_key_jwt, client_secret_jwt]}}}}
     then: {required: [revocation_endpoint_auth_signing_alg_values_supported]}
   ```

   and the same for the token_ and introspection_ pairs.  
   *Verifier: confirmed.*

5. **[LOW] Gap: token_endpoint / authorization_endpoint conditional REQUIRED not encoded for the OAuth 2.1 profile**  
   *Reference:* RFC 8414 §2 (authorization_endpoint, token_endpoint)  
   token_endpoint is 'REQUIRED unless only the implicit grant type is supported'. authorization_endpoint is 'REQUIRED unless no grant types are supported that use the authorization endpoint'. This profile excludes implicit, so every conforming AS has a token endpoint. Yet OAuthServerMetadata.required (1937-1940) lists only issuer and response_types_supported, and the description (1926-1930) says a plain-OAuth AS 'may omit them'. An Ajv run accepted an OAuth 2.1 document with grant_types_supported ['client_credentials'] and no token_endpoint. Neither member has a description (1951-1956).  
   *Suggested change:* Add token_endpoint to OAuthServerMetadata.required (profile rule: implicit is excluded) and encode the authorization-endpoint condition:

   ```yaml
   allOf:
     - if: {properties: {grant_types_supported: {contains: {const: authorization_code}}}}
       then: {required: [authorization_endpoint]}
   ```

   When grant_types_supported is absent, the 'if' holds vacuously, which matches the RFC 8414 default that includes authorization_code. Add descriptions quoting §2 to both members.  
   *Verifier: confirmed.*

6. **[LOW] Gap: grant_types_supported default re-introduces implicit**  
   *Reference:* RFC 8414 §2 (grant_types_supported, response_modes_supported)  
   When grant_types_supported is omitted, the default is ['authorization_code','implicit'] (correctly documented at 2036). So an OAuth 2.1 AS that omits the member advertises a grant this profile excludes. Similarly, response_modes_supported defaults to ['query','fragment']. Nothing in the profile requires publishing either member.  
   *Suggested change:* Require grant_types_supported in the OAuth 2.1 profile (in OAuthServerMetadata.required or the profile schema), add 'minItems: 1', and optionally 'items: {type: string, not: {enum: [implicit, password]}}' so the profile's exclusions are machine-checkable. State in the description that OAuth 2.1 servers always publish it.  
   *Verifier: partially correct —* Only the grant_types_supported default conflicts with the profile. If omitted it means ['authorization_code','implicit'] (RFC 8414 §2, documented at line 2036), so an OAuth 2.1 AS should always publish it. The response_modes_supported default ['query','fragment'] (line 2032) does not conflict with this YAML. 'fragment' is in its own ResponseMode enum (line 855), and it is the default mode for the OIDC 'id_token' and 'code id_token' response types the YAML keeps (704-706, 166-167).

7. **[LOW] Gap: signed_metadata typing and content rules**  
   *Reference:* RFC 8414 §1.1, §2.1  
   signed_metadata (2262-2267) is a bare string with no $ref to the JWT schema (2434). It does not state that the JWT MUST be JWS-signed or MACed in compact serialization (§1.1), that it MUST contain an iss naming the attesting party, or that it SHOULD NOT contain a signed_metadata claim. There is no decoded-claims schema. An Ajv run accepted 'not-a-jwt'.  
   *Suggested change:* signed_metadata:

   ```yaml
   allOf: [{$ref: '#/components/schemas/JWT'}]
   description: |
     JWS-signed (or MACed) JWT, compact serialization, whose claims are RFC 8414 §2 metadata values.
     MUST contain iss (the attesting party - may differ from the AS); SHOULD NOT contain signed_metadata.
     Consumers MAY ignore it; consumers that support it MUST let its values take precedence
     over the plain JSON members (RFC 8414 §2.1).
   ```

   Optionally add a documentation-only SignedAuthorizationServerMetadataClaims schema (type: object, required: [iss], additionalProperties: true) in the style of IDTokenClaims.  
   *Verifier: confirmed.*

8. **[LOW] Gap: https / no-query / no-fragment constraints on issuer and jwks_uri; the JWK 'use' rule**  
   *Reference:* RFC 8414 §2 (issuer, jwks_uri), §3  
   issuer (1944-1950) and jwks_uri (1961-1964) rely on 'format: uri', which permits http, query and fragment; an Ajv run accepted issuer 'http://as.example.com/t1?x=1#f'. Under the OAS 3.1 default dialect, 'format' is only an annotation, so many validators check nothing at all. The jwks_uri rule that every key MUST carry 'use' when the set mixes signing and encryption keys is stated neither here nor on the JWKS schema (1813-1821).  
   *Suggested change:* issuer: add pattern '^https://[^?#]+$'. jwks_uri: add pattern '^https://' and the sentence 'If the JWK Set contains both signing and encryption keys, every key MUST include use (RFC 8414 §2).' Mirror that sentence on components.schemas.JWKS.  
   *Verifier: confirmed.*

9. **[LOW] Gap: Per-member semantics and value spaces missing (34 of 67 members have no description)**  
   *Reference:* RFC 8414 §2, §5, §7.2  
   Undocumented RFC 8414 members include: - authorization_endpoint and token_endpoint. - scopes_supported: RECOMMENDED; servers MAY leave some scopes out. - revocation_endpoint_auth_methods_supported: defaults to client_secret_basic when omitted. - introspection_endpoint_auth_methods_supported: values may come from the Token Endpoint Authentication Methods registry OR the Access Token Types registry (e.g. Bearer, DPoP); if omitted, the methods 'MUST be determined by other means'; the two registries are kept disjoint per §7.2. - ui_locales_supported: BCP 47 tags. - service_documentation: should explain client registration when Dynamic Client Registration is unsupported. - op_policy_uri and op_tos_uri: general OAuth features despite the 'op_' prefix (§5). In addition, token_endpoint_auth_methods_supported (2040-2048) and response_modes_supported (2031) are closed enums over open value spaces, so future registered values (e.g. attest_jwt_client_auth from draft-ietf-oauth-attestation-based-client-auth-11) are rejected.  
   *Suggested change:* Give each RFC 8414 member a description quoting its §2 requirement level and default (e.g. revocation_endpoint_auth_methods_supported: 'Default if omitted: [client_secret_basic] (RFC 8414 §2).'). Point the schema description at the IANA 'OAuth Authorization Server Metadata' registry (§7.1). Either document the closed enums as a deliberate profile or change them to 'anyOf: [{enum: [...]}, {type: string}]'.  
   *Verifier: confirmed.*

10. **[LOW] Gap: Client-side validation and transport-security rules not documented**  
   *Reference:* RFC 8414 §3.3, §4, §6.1, §6.2  
   Neither well-known operation says that: - the returned issuer MUST be identical to the issuer the client inserted the well-known string into, and otherwise the data MUST NOT be used (§3.3, §6.2); - comparison is code-point equality without Unicode or URI normalization (§4); - the AS MUST support TLS 1.2 and clients MUST check the server certificate (§6.1). These are the rules that make metadata an anti-impersonation and anti-mix-up control rather than plain configuration.  
   *Suggested change:* Append to /.well-known/oauth-authorization-server.get.description: 'Clients MUST verify that issuer equals the issuer identifier used to build this URL (code-point comparison, no normalization; RFC 8414 §4) and MUST NOT use the document otherwise (§3.3, §6.2). TLS is mandatory: servers MUST support TLS 1.2 and clients MUST validate the certificate for the issuer host (§6.1).'  
   *Verifier: partially correct —* The issuer-identity rule is documented, but in the schema rather than the operations: OAuthServerMetadata.properties.issuer (1947-1950) says it 'MUST be byte-identical ... to the base of the discovery URL'. Three things are missing. First, the §3.3 consequence: 'the data contained in the response MUST NOT be used'. Second, the §4 comparison procedure: remove JSON escaping, apply no Unicode normalization, compare code point by code point. Third, §6.1: the AS MUST support TLS 1.2, and the client MUST check the certificate per RFC 6125. The two operations (603-648) say nothing about validation, and grep finds no TLS-version text.

11. **[LOW] Gap: Error responses and example response for the metadata endpoint**  
   *Reference:* RFC 8414 §3.2  
   Only '200' is declared (642-648). §3.2 says errors use the applicable HTTP status code (e.g. 404 for an unknown issuer path on a multi-tenant host). There is no example document mirroring the §3.2 non-normative example, which the May-2026 audit also requested.  
   *Suggested change:* Add responses '404': {description: 'No metadata for this issuer (RFC 8414 §3.2)'}. Add a 200 example such as {issuer: 'https://as.example.com', authorization_endpoint: 'https://as.example.com/authorize', token_endpoint: 'https://as.example.com/token', jwks_uri: 'https://as.example.com/jwks', response_types_supported: ['code'], grant_types_supported: ['authorization_code','refresh_token','client_credentials'], code_challenge_methods_supported: ['S256'], token_endpoint_auth_methods_supported: ['private_key_jwt','client_secret_basic'], token_endpoint_auth_signing_alg_values_supported: ['ES256','PS256'], authorization_response_iss_parameter_supported: true}.  
   *Verifier: confirmed.*

12. **[LOW] Gap: IANA 'OAuth Authorization Server Metadata' names not modeled (17 of 82)**  
   *Reference:* RFC 8414 §7.1 (registry)  
   None of the absent values is defined by a published IETF RFC. They fall into three groups. - IETF drafts in the RFC Editor queue (2): status_list_aggregation_endpoint (draft-ietf-oauth-status-list-21 §9.1; RECOMMENDED for an AS that issues Token Status Lists) and identity_chaining_requested_token_types_supported (draft-ietf-oauth-identity-chaining-16 §3; -17 is current). The second is relevant because the YAML models RFC 8693 token exchange. - OIDF OpenID Federation 1.0 (Final, 17 Feb 2026; registered 2024-08-26 and 2026-02-03) (12): client_registration_types_supported, federation_registration_endpoint, signed_jwks_uri, jwks, organization_name, display_name, description, keywords, contacts, logo_uri, information_uri, organization_uri. Needed only in a Federation deployment, inside entity statements. - ETSI NFV-SEC 022 (3): nfv_token_signing_alg_values_supported, nfv_token_encryption_alg_values_supported, nfv_token_encryption_enc_values_supported. Domain-specific.  
   *Suggested change:* Add the two IETF members as optional properties once their RFCs publish, each marked with a 'draft-ietf-...' note until then, e.g. identity_chaining_requested_token_types_supported: {type: array, minItems: 1, items: {$ref: '#/components/schemas/TokenTypeURI'}} and status_list_aggregation_endpoint: {type: string, format: uri}. List the OpenID Federation names in a catalog note and adopt them only with Federation support. Exclude the ETSI nfv_token_* names.  
   *Verifier: confirmed.*

13. **[LOW] Incorrect: lines 2261-2267, components.schemas.OAuthServerMetadata.properties.signed_metadata**  
   *Reference:* RFC 8414 §1, §2.1  
   The description has four problems. - It cites 'RFC 8414 §3.1' for the precedence rule, but that rule is in §2.1 (§3.1 is the metadata request). The YAML comment on line 2261 itself says §2.1. - 'JWT containing all of the above metadata': §2.1 describes a bundle of any subset of the §2 values, and signed_metadata SHOULD NOT itself appear as a claim. - 'signed by the AS': the signer is whoever the REQUIRED iss claim names. Per §1 that issuer vouches for the AS and may be a third party. - 'takes precedence' is stated unconditionally, but consumers MAY ignore signed metadata, and precedence applies only if they support it.  
   *Suggested change:* Replace the description with: 'JWT (JWS-signed or MACed, compact serialization) asserting RFC 8414 §2 metadata values as claims; MUST contain iss identifying the attesting party; SHOULD NOT contain signed_metadata. Consumers MAY ignore it; if they support it, its values MUST take precedence over the plain JSON members (RFC 8414 §2.1).'  
   *Verifier: confirmed.*

14. **[LOW] Incorrect: lines 635-638, paths./.well-known/oauth-authorization-server.get.description**  
   *Reference:* RFC 8414 §1, §3, §3.2  
   Two statements are wrong. - 'The response shape is a strict subset of the OIDC discovery document.' RFC 8414 defines members that OIDC Discovery 1.0 §3 does not (revocation_endpoint, introspection_endpoint, their auth-method and alg arrays, code_challenge_methods_supported, signed_metadata), and §3.2 allows other claims. The YAML itself models the opposite relation: OpenIDProviderMetadata = allOf(OAuthServerMetadata, ...) is the more constrained schema. - 'for plain OAuth 2.0 servers that do not implement OpenID Connect' understates §3: an OpenID Provider MAY also publish at this location.  
   *Suggested change:* Reword to: 'RFC 8414 generalizes OIDC Discovery 1.0 for any OAuth AS. Members overlap heavily but neither document is a subset of the other. An OP MAY publish at both locations (RFC 8414 §3).'  
   *Verifier: confirmed.*

15. **[LOW] Incorrect: lines 1947-1950, components.schemas.OAuthServerMetadata.properties.issuer.description**  
   *Reference:* RFC 8414 §3.1, §3.3, §4  
   'MUST be byte-identical ... to the base of the discovery URL' encodes the OIDC Discovery append model. For /.well-known/oauth-authorization-server, the issuer is not the base or prefix of the URL when it has a path: https://example.com/issuer1 maps to https://example.com/.well-known/oauth-authorization-server/issuer1 (§3.1). §3.3 requires identity with 'the issuer identifier value into which the well-known URI string was inserted' and says the data MUST NOT be used otherwise. Comparison is code-point equality after removing JSON escaping (§4), not raw bytes.  
   *Suggested change:* Replace with: 'https URL with no query or fragment. MUST be identical (code-point comparison, no normalization) to the issuer identifier into which the well-known string was inserted (RFC 8414 §3.3), or to which /.well-known/openid-configuration was appended (OIDC Discovery §4.3); otherwise clients MUST NOT use the document. Also equals the iss of JWTs this AS issues.'  
   *Verifier: partially correct —* The wording is correct for the shared schema's OIDC use and for issuers without a path. It is wrong only for path-bearing issuers at the RFC 8414 location. OIDC Discovery §4.3 says the issuer 'MUST be identical to the Issuer URL that was used as the prefix to /.well-known/openid-configuration', and RFC 8414 §6.2 itself says 'the issuer identifier URL it is using as the prefix for the metadata request'. Only §3.3 ('into which the well-known URI string was inserted') differs, and only when the issuer has a path, which the hostname-only {issuer} variable (line 84) cannot express. 'Byte-identical' equals the §4 code-point equality when applied after JSON unescaping. What is really missing is that unescaping step and the 'MUST NOT be used' consequence.

16. **[LOW] Incorrect: lines 77-86, servers[0] (url 'https://{issuer}', description, variables.issuer.description)**  
   *Reference:* RFC 8414 §3, §3.1  
   The server is described as 'identified by its issuer URL' (line 79), while the variable is documented as a 'Hostname' with a 'vendor-specific' path layout (84-86). If a path-bearing issuer is plugged in, OpenAPI resolves the well-known paths after that path, giving https://as.example.com/tenant1/.well-known/oauth-authorization-server. That is the appended form, which RFC 8414 §3/§3.1 does not define, and RFC 8615 §3 says it is not a well-known URI. The well-known location is standardized, not vendor-specific.  
   *Suggested change:* Describe the variable as 'authority (host[:port]) of the issuer'. Say explicitly that issuers with a path keep their metadata at https://{issuer-host}/.well-known/oauth-authorization-server/{issuer-path}, and link to the path-variant operation.  
   *Verifier: partially correct —* Line 79 ('identified by its issuer URL') does conflict with the 'Hostname' variable (line 84). Path-bearing issuers cannot be expressed: substituting one gives the appended form, because OpenAPI appends paths to the server URL. That form does not comply with RFC 8414 §3 and is not a well-known URI under RFC 8615 §3. But the YAML never says the well-known location is vendor-specific. 'path layout under this host is vendor-specific' refers to the other endpoints, and the same sentence says to 'use the discovery endpoints to obtain canonical URLs'. This item duplicates RFC 8414 gap 1.

17. **[LOW] Incorrect: lines 2140 and 2250 (YAML comments inside components.schemas.OAuthServerMetadata)**  
   *Reference:* RFC 8414 §2, §5  
   The comments '# ---- UI / locales (OIDC Discovery §3) ----' and '# ---- Documentation links (OIDC Discovery §3) ----' label ui_locales_supported, service_documentation, op_policy_uri and op_tos_uri as OIDC fields. All four are RFC 8414 §2 members (IANA reference: RFC 8414 §2), and §5 explicitly says op_policy_uri and op_tos_uri are general OAuth features despite the 'op_' prefix.  
   *Suggested change:* Relabel the comments as '(RFC 8414 §2; also OIDC Discovery §3)'. Since the modular split drops comments, also put the citation into each member's description.  
   *Verifier: partially correct —* The comments are incomplete, not false. The vendored OIDC Discovery 1.0 §3 does define ui_locales_supported, service_documentation, op_policy_uri and op_tos_uri. IANA, however, registers all four with RFC 8414 §2 as the reference (ui_locales_supported also cites RFC 5646). The 2140 group also holds OIDC-only members (display_values_supported, acr_values_supported). Citing 'RFC 8414 §2; also OIDC Discovery §3' is the accurate fix. This is cosmetic.

18. **[LOW] Gap: /.well-known/openid-configuration is modeled only as an OIDC endpoint** — *found by the verifier*  
   *Reference:* RFC 8414 §3, §5  
   /.well-known/openid-configuration is modeled only as an OIDC endpoint. RFC 8414 §3 lets OAuth applications use the 'openid-configuration' suffix ('Some OAuth applications will choose to use the well-known URI suffix openid-configuration'). §5 says that this use 'is actually referring to general OAuth 2.0 features that are not specific to OpenID Connect'. The YAML binds this path to OpenIDProviderMetadata, which requires subject_types_supported and id_token_signing_alg_values_supported (1915-1921). As a result, an RFC 8414-conformant document from a non-OIDC AS served there is rejected. The operation text has two further problems. It says the endpoint is 'published by every OpenID Connect provider', but OIDC Discovery §4 binds only 'OpenID Providers supporting Discovery'. It calls this 'the only path that is truly standardized', although the same file models /.well-known/oauth-authorization-server, which an OP MAY also use (RFC 8414 §3). The first agent's modeled_elements entry for the 'openid-configuration' suffix (RFC 8414 §3, §5) therefore overstates coverage.  
   *Suggested change:* Document both uses in the operation description: an OP's document must satisfy OpenIDProviderMetadata (OIDC Discovery §3/§4), and a non-OIDC AS MAY publish OAuthServerMetadata at this suffix (RFC 8414 §3, §5). For example, use OAuthServerMetadata as the 200 schema and describe the extra OP requirements, or keep OpenIDProviderMetadata and add the RFC 8414 alternative in prose. Replace 'the only path that is truly standardized' with a pointer to /.well-known/oauth-authorization-server and the IANA Well-Known URIs registry.

## RFC9728 OAuth 2.0 Protected Resource Metadata

*April 2025 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 9728 is the resource-server counterpart of RFC 8414. A protected resource (an API) publishes JSON metadata at /.well-known/oauth-protected-resource, inserted into its own resource identifier URL. The document names the authorization servers that can issue tokens for it, the scopes it uses, how bearer tokens may be presented, its response-signing algorithms, and whether DPoP- or mTLS-bound tokens are required. It also adds a 'resource_metadata' parameter to WWW-Authenticate, so a 401 can point a client straight at that document, letting a client with no prior configuration find the right AS (§5, Figure 1). It defines the AS-side 'protected_resources' member and the IANA 'OAuth Protected Resource Metadata' registry.

**Why it was created.** Before RFC 9728, a client meeting an unfamiliar API had no standard way to learn which AS protects it, which scopes to request, or how tokens must be presented or bound. That information was configured out of band, which does not scale to dynamically discovered resources (JMAP mail servers found via WebFinger, generic API clients, AI agents). Deriving the metadata URL from the resource identifier (§1, §3.3) stops third parties from publishing authoritative-looking metadata for someone else's resource. §7.4 pairs it with audience-restricted tokens (RFC 8707) so a malicious RS cannot harvest tokens meant for another RS. The Model Context Protocol authorization spec (2025-06-18) requires MCP servers to implement RFC 9728 and MCP clients to use it for AS discovery.

<details><summary>Already modeled in the YAML (14)</summary>

- GET /.well-known/oauth-protected-resource -> 200 application/json ProtectedResourceMetadata (paths, lines 653-675; externalDocs RFC 9728 §3)
- components.schemas.ProtectedResourceMetadata: required [resource], additionalProperties: true (2272-2280)
- resource (2281-2285)
- authorization_servers (2286-2289)
- jwks_uri (2290-2292), scopes_supported (2293-2295)
- bearer_methods_supported enum [header, body, query] with the OAuth 2.1 / RFC 9700 query caveat (2296-2304)
- resource_signing_alg_values_supported with 'none MUST NOT' prose (2305-2308)
- resource_name (2309-2310), resource_documentation (2311-2313), resource_policy_uri (2314-2316), resource_tos_uri (2317-2319)
- tls_client_certificate_bound_access_tokens default false (2320-2322)
- authorization_details_types_supported (2323-2325), dpop_signing_alg_values_supported (2326-2328)
- dpop_bound_access_tokens_required default false (2329-2332)
- signed_metadata (2333-2338)
- AS-metadata member protected_resources (§4) in OAuthServerMetadata (2213-2217)
- WWW-Authenticate resource_metadata auth-param (§5.1): components.headers.WWWAuthenticateBearerDPoP description 1014-1016 + example 1024; emitted via components.responses.ProtectedResourceError (1091-1107) on /userinfo GET/POST 401/403 (512-515, 562-565)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist. references/rfc-validation has no RFC 9728 file; rfc-sources/README notes that the 17 RFCs vendored on 2026-06-06 lack audit files. RFC 9728 support entered the YAML in the 2026-06-07 update (audit/rfc-audit-synthesis.md update log).

**Notes.** There is no references/rfc-validation file for RFC 9728; support was added in the 2026-06-07 update. Precise IANA comparison: 15/23 present. RFC 9728 has no errata. MCP authorization (2025-06-18) mandates RFC 9728 and the resource_metadata challenge, so it has high practical importance for modern clients. The YAML's /userinfo is itself a protected resource: with resource identifier https://{issuer}/userinfo, its PRM would live at https://{issuer}/.well-known/oauth-protected-resource/userinfo, and its 401 challenge should point there.

### Findings (0 high · 1 medium · 11 low)

1. **[MEDIUM] Gap: Metadata URL construction from the resource identifier (path/query insertion) and binding to the resource's own origin**  
   *Reference:* RFC 9728 §1, §3, §3.1, §3.3  
   Only GET /.well-known/oauth-protected-resource (line 653) is modeled, under the single AS server 'https://{issuer}' (77-86). RFC 9728 §3 MUST: the document lives at the URL formed by inserting '/.well-known/oauth-protected-resource' between the host and the path and/or query of the resource identifier, after removing a terminating '/' that follows the host (§3.1). For example, https://resource.example.com/resource1 becomes https://resource.example.com/.well-known/oauth-protected-resource/resource1. Because the URL derives from the resource identifier, it is served on the resource's origin, usually not the AS origin; the YAML's own example (1024) uses https://rs.example. §1 explains that this deterministic derivation stops third parties from publishing authoritative-looking metadata. For the AS's own protected resource /userinfo, a resource identifier of https://{issuer}/userinfo would need https://{issuer}/.well-known/oauth-protected-resource/userinfo, which the YAML cannot express.  
   *Suggested change:* Give the PRM path items their own servers and add the path variant:

   ```yaml
   /.well-known/oauth-protected-resource:
     servers:
       - url: 'https://{resourceHost}'
         description: Origin of the protected resource (RFC 9728 §3) - not necessarily the AS
         variables: {resourceHost: {default: rs.example.com, description: 'host[:port] of the resource identifier'}}
   /.well-known/oauth-protected-resource/{resourcePath}:
     servers: (same as above)
     get:
       description: 'resource https://rs.example.com/resource1 -> /.well-known/oauth-protected-resource/resource1; a query component of the identifier is kept after the path (RFC 9728 §3.1); the response resource MUST equal the identifier (§3.3)'
       parameters: [{name: resourcePath, in: path, required: true, schema: {type: string}}]
       responses: {'200': (as today)}
   ```

   Document the /userinfo case in the userinfo description.  
   *Verifier: confirmed.*

2. **[LOW] Gap: Zero-value parameters MUST be omitted; bearer_methods_supported [] semantics**  
   *Reference:* RFC 9728 §3.2, §2 (bearer_methods_supported)  
   §3.2 says parameters with zero values MUST be omitted, but no array member of ProtectedResourceMetadata has minItems. An Ajv run accepted authorization_servers: [] and scopes_supported: []. The one deliberate exception is bearer_methods_supported: [] means 'no bearer methods supported', and omission implies nothing either way (§2). The YAML (2296-2304) documents neither.  
   *Suggested change:* Add 'minItems: 1' to authorization_servers, scopes_supported, resource_signing_alg_values_supported, authorization_details_types_supported and dpop_signing_alg_values_supported. Leave bearer_methods_supported without minItems and add: '[] = no bearer methods supported; omitted = nothing implied (RFC 9728 §2).'  
   *Verifier: confirmed.*

3. **[LOW] Gap: Language-tagged human-readable members**  
   *Reference:* RFC 9728 §2.1  
   resource_name, resource_documentation, resource_policy_uri and resource_tos_uri MAY be sent as 'member#lang' (e.g. resource_name#it). An untagged value MUST be used as-is, and including an untagged instance is RECOMMENDED. additionalProperties: true (2279) tolerates these members, but nothing documents or types them.  
   *Suggested change:* patternProperties:

   ```
   '^(resource_name|resource_documentation|resource_policy_uri|resource_tos_uri)#[A-Za-z0-9-]+$': {type: string}
   ```

   Also add a sentence in the schema description citing §2.1.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Member-level requirement levels and constraints**  
   *Reference:* RFC 9728 §2, §7.2  
   Undescribed or unenforced rules: - jwks_uri (2290-2292) MUST be https, and every key needs 'use' when signing and encryption keys are mixed. - scopes_supported (2293-2295) is RECOMMENDED and is not a list the client should request wholesale (§7.2). - resource_name (2309-2310) is RECOMMENDED. - resource_signing_alg_values_supported (2305-2308) says 'none MUST NOT be used' but does not enforce it. - authorization_servers items (2288) should be RFC 8414 issuer identifiers (https, no query or fragment). Also, the bearer_methods_supported text says RFC 9728 §2 'registers' query; §2 only defines the values and there is no registry.  
   *Suggested change:* - jwks_uri: pattern '^https://' plus the use-rule sentence. - resource_signing_alg_values_supported.items: {type: string, not: {const: none}}. - authorization_servers.items: {type: string, format: uri, pattern: '^https://[^?#]+$'}. - Add RECOMMENDED notes to scopes_supported (with the §7.2 least-privilege caveat) and to resource_name. - Change 'registers' to 'defines'.  
   *Verifier: confirmed.*

5. **[LOW] Gap: signed_metadata typing and verification**  
   *Reference:* RFC 9728 §2.2, §3.3, §7.9  
   signed_metadata (2333-2338) is a bare string, and precedence is stated unconditionally, although consumers MAY ignore signed metadata and precedence applies only when they support it. Two rules are missing: rejecting metadata whose JWT contains a signed_metadata claim is RECOMMENDED, and recipients MUST verify the signature with a key belonging to the issuer (§3.3).  
   *Suggested change:* allOf: [{$ref: '#/components/schemas/JWT'}], with the description: 'JWS-signed or MACed JWT; MUST contain iss; signed_metadata SHOULD NOT appear as a claim (rejecting such metadata is RECOMMENDED); consumers MAY ignore it, but if supported its values take precedence; recipients MUST verify the signature with a key belonging to iss (RFC 9728 §2.2, §3.3).'  
   *Verifier: confirmed.*

6. **[LOW] Gap: resource_metadata challenge: canonical and DPoP forms, change signalling**  
   *Reference:* RFC 9728 §5.1, §5.2  
   resource_metadata is documented (1014-1016) with a single Bearer example that also carries error=invalid_token (1024). Missing: - the §5.1 canonical 401 for a request without a token (Bearer with only resource_metadata); - an example on the DPoP scheme, which §5.1 explicitly allows; - the note that it may be combined with other parameters such as max_age (RFC 9470); - §5.2: an RS MAY re-challenge with resource_metadata at any time to signal changed metadata, and clients SHOULD re-fetch and re-validate.  
   *Suggested change:* Add these examples to components.headers.WWWAuthenticateBearerDPoP: 'Bearer resource_metadata="https://rs.example/.well-known/oauth-protected-resource"' and 'DPoP algs="ES256", resource_metadata="https://rs.example/.well-known/oauth-protected-resource"'. Add a sentence citing §5.2.  
   *Verifier: partially correct —* Three things are missing. First, a §5.1-style 401 for a request without a token (a Bearer challenge carrying only resource_metadata). Second, an example on the DPoP scheme (§5.1: 'MAY also be used ... such as the DPoP scheme'). Third, the §5.2 rule: the RS MAY re-challenge, and the client SHOULD re-fetch the metadata and re-validate it per §3.3. The 'may be combined with max_age' point is already implied: lines 1014-1018 list resource_metadata and acr_values/max_age together as optional auth-params of the same challenge.

7. **[LOW] Gap: Caching, error responses and example for the metadata endpoint**  
   *Reference:* RFC 9728 §3.2, §7.10  
   Only '200' is declared (670-675). §3.2 says errors use the applicable status code. §7.10 says implementations should use HTTP caching directives such as Cache-Control max-age. The §3.2 example document is not reproduced.  
   *Suggested change:* On the 200 response add headers: {Cache-Control: {schema: {type: string}, description: 'e.g. max-age=3600 (RFC 9728 §7.10)'}}. Add a '404' response, and an example mirroring §3.2: resource, authorization_servers, bearer_methods_supported ['header'], scopes_supported, resource_documentation.  
   *Verifier: confirmed.*

8. **[LOW] Gap: IANA 'OAuth Protected Resource Metadata' names not modeled (8 of 23)**  
   *Reference:* RFC 9728 §8.1 (registry)  
   All 15 RFC 9728 names are present. Every absent name was registered on 2026-02-04 by OpenID Federation 1.0 (Final, 17 Feb 2026): signed_jwks_uri, jwks, organization_name, description, keywords, contacts, logo_uri, organization_uri. One pending IETF registration, challenge_endpoint (draft-ietf-oauth-attestation-based-client-auth-11 §15.3, in WG Last Call), is not yet in the registry. The IANA absence list has only 6 absences because 'jwks' and 'description' match unrelated YAML tokens.  
   *Suggested change:* Leave the Federation names to additionalProperties, with a catalog note listing them, unless OpenID Federation is implemented. Track challenge_endpoint alongside the attestation-based client authentication work.  
   *Verifier: confirmed.*

9. **[LOW] Incorrect: lines 2281-2285, components.schemas.ProtectedResourceMetadata.properties.resource ($ref StringOrURI)**  
   *Reference:* RFC 9728 §1.2, §2  
   resource is typed as the JWT StringOrURI type, which accepts any string and requires a URI only if the value contains ':'. So 'my-api' validates (confirmed with Ajv). RFC 9728 §1.2/§2 define the resource identifier as a URL using https with no fragment, which SHOULD NOT contain a query.  
   *Suggested change:* Replace the $ref with: type: string, format: uri, pattern: '^https://[^#]+$'.  
   *Verifier: confirmed.*

10. **[LOW] Incorrect: lines 2283-2285, components.schemas.ProtectedResourceMetadata.properties.resource.description**  
   *Reference:* RFC 9728 §3.3, §6  
   'MUST match the aud/resource value clients use' is not RFC 9728's rule. §3.3 requires resource to be identical to the resource identifier from which the well-known URL was built. When that URL came from a WWW-Authenticate resource_metadata parameter, resource must be identical to the URL the client used to make the request to the RS. Otherwise the document MUST NOT be used, and comparison is code-point equality (§6).  
   *Suggested change:* Reword to: 'REQUIRED. https resource identifier, no fragment. MUST be identical (code-point comparison) to the identifier the metadata URL was derived from, or, when discovered via WWW-Authenticate resource_metadata, to the URL the client requested; otherwise the client MUST NOT use the document (RFC 9728 §3.3). Clients use this value as the RFC 8707 resource parameter.'  
   *Verifier: confirmed.*

11. **[LOW] Incorrect: lines 2213-2217, components.schemas.OAuthServerMetadata.properties.protected_resources**  
   *Reference:* RFC 9728 §4, §7.6  
   'Resource identifiers whose metadata this AS oversees' misstates §4. The member lists resource identifiers of protected resources that can be used with this AS; the AS does not oversee RS metadata. The list MAY be partial and is omitted when the set is not enumerable, and §4/§7.6 advise cross-checking it against the RS's authorization_servers.  
   *Suggested change:* Reword to: 'Resource identifiers of protected resources that can be used with this AS (RFC 9728 §4). MAY be incomplete; omit when not enumerable; cross-check with each resource's authorization_servers.' Add items pattern '^https://[^#]+$'.  
   *Verifier: confirmed.*

12. **[LOW] Gap: The rules for consumers of protected resource metadata are not documented** — *found by the verifier*  
   *Reference:* RFC 9728 §3.2, §7.1, §7.3, §7.7  
   The rules for consumers of protected resource metadata are not documented. §3.2: 'any metadata parameters that are not understood MUST be ignored'. §7.1: 'Implementations MUST support TLS. They MUST follow the guidance in [BCP195]'. §7.3: 'TLS certificate checking MUST be performed by the client as described in [RFC9525]'. §7.7: 'Clients SHOULD take appropriate precautions against SSRF attacks, such as blocking requests to internal IP address ranges'. The YAML says 'A client or AS reads this' (661-662), so an AS that fetches PRM is also exposed to the §7.7 SSRF risk. The first agent covered the RFC 8414 §6.1 TLS counterpart but none of these RFC 9728 rules.  
   *Suggested change:* Append to the /.well-known/oauth-protected-resource description: 'Consumers MUST ignore unknown members (RFC 9728 §3.2) and MUST validate the server certificate per RFC 9525 (§7.3); servers MUST follow BCP 195 (§7.1). Clients and authorization servers that fetch resource-supplied URLs SHOULD guard against SSRF, e.g. by blocking internal address ranges (§7.7).'

## RFC6755 An IETF URN Sub-Namespace for OAuth

*October 2012 · Informational · YAML coverage: **mostly** · relevance to an AS: informational · vendoring: already-vendored*

**What it is.** RFC 6755 reserves the URN prefix urn:ietf:params:oauth, under the IETF 'params' namespace of RFC 3553. It creates the IANA 'OAuth URI' registry for identifiers minted beneath it, conventionally of the form urn:ietf:params:oauth:&lt;class>:&lt;identifier>. Every URN-shaped value an OAuth AS sees on the wire lives in this namespace: extension grant types (device_code, jwt-bearer, token-exchange), client assertion types, RFC 8693 token-type identifiers and PAR request_uri references. The document defines no protocol messages itself.

**Why it was created.** OAuth 2.0 extension points (grant_type, client_assertion_type, later token types) take absolute-URI values so that independently developed extensions cannot collide. The IETF wanted a stable, centrally registered naming space for IETF-defined values instead of ad hoc HTTP URLs. RFC 6755 therefore registered a URN sub-namespace per RFC 3553, backed by a Specification Required registry.

<details><summary>Already modeled in the YAML (6)</summary>

- urn:ietf:params:oauth:grant-type:device_code: /token prose 222, 378; discriminator mapping 1169; DeviceCodeTokenRequest const 1319
- urn:ietf:params:oauth:grant-type:jwt-bearer: 223, 1170; JWTBearerTokenRequest const 1337
- urn:ietf:params:oauth:grant-type:token-exchange: 224, 1171; TokenExchangeRequest const 1360
- urn:ietf:params:oauth:client-assertion-type:jwt-bearer: ClientAuthFields.client_assertion_type const (1197-1200)
- urn:ietf:params:oauth:token-type:{access_token, refresh_token, id_token, saml1, saml2, jwt}: TokenTypeURI enum (1387-1395)
- urn:ietf:params:oauth:request_uri:&lt;reference-value> sub-namespace: PARResponse.request_uri description and example (1656-1667)

</details>

**Follow-up on the May-2026 validation notes.** None. There is no rfc-validation file; RFC 6755 was vendored on 2026-06-06 but is never cited by the YAML.

**Notes.** The OAuth URI registry has 15 entries; the YAML uses 11, each spelled exactly as registered. The YAML never mentions RFC 6755. There are no errata. For the jwt-bearer and saml2-bearer URNs, IANA now lists draft-ietf-oauth-rfc7523bis-11 (in the RFC Editor queue) alongside RFC 7522/7523.

### Findings (0 high · 0 medium · 3 low)

1. **[LOW] Gap: urn:ietf:params:oauth namespace and IANA 'OAuth URI' registry not cited**  
   *Reference:* RFC 6755 §2, §4, §4.1  
   The YAML uses 11 URNs from this namespace: grant types (1169-1171), the client assertion type (1199), token types (1390-1395) and request_uri (1664-1667). It never names RFC 6755 or the registry. A learner therefore cannot see why these values share a prefix, that they follow urn:ietf:params:oauth:&lt;class>:&lt;identifier>, or that new ones are added by Specification Required registration.  
   *Suggested change:* Add to the info.description 'Modeling notes': 'URN-valued parameters (grant_type, client_assertion_type, *_token_type, PAR request_uri) come from the urn:ietf:params:oauth sub-namespace (RFC 6755) and are listed in the IANA OAuth URI registry (https://www.iana.org/assignments/oauth-parameters/oauth-parameters.xhtml#uri).' Add an externalDocs link to TokenTypeURI.  
   *Verifier: confirmed.*

2. **[LOW] Gap: Registered OAuth URIs not used by the YAML (4 of 15)**  
   *Reference:* RFC 6755 §4 (OAuth URI registry)  
   Absent URIs, all defined by IETF RFCs: - urn:ietf:params:oauth:grant-type:saml2-bearer and urn:ietf:params:oauth:client-assertion-type:saml2-bearer (RFC 7522, vendored; IANA now also cites draft-ietf-oauth-rfc7523bis-11). - urn:ietf:params:oauth:jwk-thumbprint (RFC 9278, vendored). - urn:ietf:params:oauth:ckt (RFC 9679, the COSE key thumbprint URI; not vendored). None of them is required by OAuth 2.1.  
   *Suggested change:* - SAML 2.0 bearer: decide in the assertion cluster whether a SAML2BearerTokenRequest belongs in scope (an optional legacy-enterprise grant). - JWK Thumbprint URI (RFC 9278): optionally mention it where the YAML discusses jkt and DPoP keys. - ckt: exclude (CBOR/COSE/ACE).  
   *Verifier: confirmed.*

3. **[LOW] Gap: Closed enums and consts over an open URN registry**  
   *Reference:* RFC 6755 §2, §4; RFC 8693 §3 ('Other URIs MAY be used')  
   TokenTypeURI (1387-1395) is a closed enum, although RFC 8693 §3 allows other token-type URIs. client_assertion_type is a const (1197-1200), and the /token discriminator (1163-1171) lists fixed grant URNs. URNs already in flight will need YAML edits: - urn:ietf:params:oauth:token-type:txn_token (draft-ietf-oauth-transaction-tokens-11) - urn:ietf:params:oauth:token-type:id-jag (draft-ietf-oauth-identity-assertion-authz-grant-04) - urn:ietf:params:oauth:client-assertion-type:jwt-spiffe (draft-ietf-oauth-spiffe-client-auth-02)  
   *Suggested change:* TokenTypeURI: 'anyOf: [{enum: [the six current values]}, {type: string, format: uri}]', keeping the registered values as examples. Keep the grant-type discriminator closed, since it is this server's profile, but say so in its description.  
   *Verifier: confirmed.*

## RFC8615 Well-Known Uniform Resource Identifiers (URIs)

*May 2019 · Proposed Standard (obsoletes RFC 5785; updates RFC 7230, RFC 7595) · YAML coverage: **mostly** · relevance to an AS: informational · vendoring: vendor*

**What it is.** RFC 8615 reserves the path prefix /.well-known/ for site-wide metadata in http and https URIs (and other schemes that opt in, such as ws/wss and CoAP). Every suffix used under it must be registered in the IANA 'Well-Known URIs' registry. It obsoleted RFC 5785, the version RFC 8414 cites, adding a provisional/permanent status column and tracking which URI schemes support well-known URIs. The three discovery endpoints in this YAML (openid-configuration, oauth-authorization-server, oauth-protected-resource) are registered suffixes under this mechanism.

**Why it was created.** Protocols increasingly needed to find metadata about an origin before interacting with it (robots.txt, P3P, later OAuth discovery). Hard-coding arbitrary paths collides with sites' own URLs and takes away the origin's control of its URI space (RFC 7320 / BCP 190). A single reserved, registry-controlled prefix avoids those collisions. RFC 8615 refreshed RFC 5785 to allow non-Web schemes, update the IANA procedures, and add security guidance about writable or hidden well-known locations.

<details><summary>Already modeled in the YAML (4)</summary>

- Paths rooted at the top of the hierarchy with the reserved '/.well-known/' prefix: /.well-known/openid-configuration (603), /.well-known/oauth-authorization-server (630), /.well-known/oauth-protected-resource (653)
- Only IANA-registered suffixes are used: openid-configuration (OIDF, 2013), oauth-authorization-server (RFC 8414 §7.3), oauth-protected-resource (RFC 9728 §8.3)
- https scheme (well-known-capable per RFC 8615 §3, §5.2) via servers[0].url 'https://{issuer}' (77-86)
- Each well-known resource is a GET returning application/json with a defined schema (604-625, 631-648, 654-675)

</details>

**Follow-up on the May-2026 validation notes.** None. RFC 8615 is not vendored, not cited, and has no rfc-validation notes.

**Notes.** RFC 8615 is neither vendored nor cited. It obsoletes RFC 5785, which RFC 8414 §2/§3 and OIDC Discovery §4 cite, and RFC 9728 cites RFC 8615 normatively. It is small (about 27 KB) and has no errata. Its §3 rooted-path rule is the clearest explanation of why RFC 8414 and RFC 9728 insert the suffix after the host. Vendoring is recommended because it governs three YAML paths.

### Findings (0 high · 0 medium · 5 low)

1. **[LOW] Gap: RFC 8615 (and the obsoleted RFC 5785 that RFC 8414 cites) and the IANA Well-Known URIs registry are never cited**  
   *Reference:* RFC 8615 §3, §3.1, §5.1  
   The three discovery operations (603, 630, 653) and the Discovery tag (99-100) never explain that '/.well-known/' is a reserved, registry-controlled prefix, or which spec registered each suffix. The tag also omits RFC 9728, although the PRM operation is tagged Discovery. RFC 8414 §2/§3 still reference RFC 5785, which RFC 8615 obsoleted in May 2019.  
   *Suggested change:* Change the Discovery tag description to: 'RFC 8414 + RFC 9728 + OIDC Discovery: well-known URIs (RFC 8615; RFC 8414 cites the obsoleted RFC 5785). Suffixes are registered in the IANA Well-Known URIs registry: oauth-authorization-server (RFC 8414 §7.3), oauth-protected-resource (RFC 9728 §8.3), openid-configuration (OIDF).' Add externalDocs pointing at RFC 8615 §3 on each operation.  
   *Verifier: confirmed.*

2. **[LOW] Gap: 'Rooted at the top of the path' rule and why OAuth inserts rather than appends**  
   *Reference:* RFC 8615 §3, Appendix A  
   RFC 8615 §3 says well-known URIs are rooted at the top of the path hierarchy: '/foo/.well-known/example' is not one. Appendix A explains that per-directory well-known locations were rejected. That is why RFC 8414 §3.1 and RFC 9728 §3.1 keep '/.well-known/&lt;suffix>' directly after the host and move the issuer or resource path after it. OIDC Discovery 1.0 §4.1's appended form (/issuer1/.well-known/openid-configuration) sits outside RFC 8615, and RFC 8414 §5 treats it as legacy. The YAML documents none of this. With a path-bearing value in the {issuer} server variable, OpenAPI resolution would produce exactly the non-well-known appended form.  
   *Suggested change:* Add one paragraph to the Discovery tag (or the info.description 'Modeling notes') explaining the insertion rule with the RFC 8615 §3 rationale. Reference the {issuerPath}/{resourcePath} path variants proposed under RFC 8414 and RFC 9728.  
   *Verifier: confirmed.*

3. **[LOW] Gap: Scoping: well-known metadata must describe its own origin**  
   *Reference:* RFC 8615 §4.3  
   RFC 8615 §4.3 warns that applying metadata found at one origin's well-known URI to resources on other origins 'assumes a relationship between hosts where there might be none'. The YAML publishes /.well-known/oauth-protected-resource on the AS origin (77-86, 653) while describing it as metadata 'published by a protected resource (resource server)' (658-665). That is appropriate only for resources hosted on the AS origin, such as /userinfo.  
   *Suggested change:* Use a path-level servers override for the PRM path items (see the RFC 9728 gap) and state that PRM is served from the origin of the resource identifier.  
   *Verifier: partially correct —* RFC 8615 §4.3 says that applying well-known metadata to resources on other origins 'risks administrative as well as security issues'. That is a caution, not a MUST. The YAML's PRM on the AS origin is correct under RFC 9728 only for a resource identifier equal to https://{issuer} itself. The real defect is RFC 9728 §3 (RFC 9728 gap 1), and this item duplicates it.

4. **[LOW] Gap: Security considerations for well-known resources**  
   *Reference:* RFC 8615 §4.1, §4.2, §4.4  
   Write access to /.well-known must be tightly controlled: the metadata documents carry endpoint URLs and jwks_uri, so anyone who can write them can redirect clients to attacker endpoints and keys (compare RFC 8414 §6.2). RFC 8615 §4.2 suggests hardening such as 'X-Content-Type-Options: nosniff', and §4.4 notes that dot-directories may be hidden from administrators. The YAML has no operator note and no response headers for these operations.  
   *Suggested change:* Add an operator note to the Discovery tag: serve metadata from code or config, not a writable directory, and restrict write access. Optionally document 'X-Content-Type-Options: nosniff' on the three 200 responses.  
   *Verifier: confirmed.*

5. **[LOW] Gap: Other OAuth-adjacent registered well-known suffixes**  
   *Reference:* RFC 8615 §3.1, §5.1 (Well-Known URIs registry)  
   The YAML uses 3 of the 106 registered suffixes. OAuth- and identity-adjacent suffixes that are not modeled: - webfinger (RFC 7033): OIDC Discovery §2 issuer discovery; mentioned in RFC 8414 §1 and RFC 9728 §1. - openid-federation (OpenID Federation 1.0). - uma2-configuration (Kantara UMA 2.0). - ssf-configuration (OpenID Shared Signals). - nfv-oauth-server-configuration (ETSI NFV-SEC 022).  
   *Suggested change:* Catalog only. Consider /.well-known/webfinger only if OIDC issuer discovery from user identifiers is in scope; exclude the others.  
   *Verifier: confirmed.*

## RFC3986 Uniform Resource Identifier (URI): Generic Syntax

*January 2005 · Internet Standard (STD 66); updated by RFC 8820 (BCP 190, formerly RFC 7320) · YAML coverage: **partial (verifier corrected from referenced-only)** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** RFC 3986 defines the generic syntax of URIs: scheme, authority (userinfo, host, port), path, query and fragment. It also defines reference resolution, normalization and comparison. Everything URL-shaped in OAuth is defined in its terms: issuer identifiers ('https, no query or fragment'), redirect URIs ('absolute URI, no fragment'), resource indicators, the well-known URL construction ('between the host and path component'), and the unreserved character set used for PKCE code verifiers.

**Why it was created.** Earlier URI specifications (RFC 1738, 1808, 2396, 2732) were fragmented and ambiguous, so parsers disagreed about components and equivalence, which caused interoperability and security problems. RFC 3986 consolidated them into one grammar with clear resolution, normalization and comparison rules.

<details><summary>Already modeled in the YAML (4)</summary>

- StringOrURI cites RFC 3986: values containing ':' MUST be URIs (2443-2448)
- format: uri (RFC 3986 URI) on 47 URI-valued members, e.g. issuer 1946, jwks_uri 1963, protected_resources items 2216, authorization_servers items 2288, redirect_uri 730/1254, resource 895/1218, request_uri 868/1658
- RFC 3986 §2.3 unreserved character set for PKCE code_challenge/code_verifier: pattern '^[A-Za-z0-9._~-]+$' (778, 1263, 1611; prose 766, 1266)
- Absolute-URI / no-fragment prose for resource indicators (886, 1210-1211)

</details>

**Follow-up on the May-2026 validation notes.** None. RFC 3986 was not vendored before this audit (it is now), is cited once, and has no rfc-validation notes.

**Notes.** RFC 3986 is cited once (line 2447, StringOrURI). That description also lists jti among StringOrURI claims, but RFC 7519 §4.1.7 defines jti as a case-sensitive string; that belongs to the JWT cluster. In JSON Schema 2020-12, the OAS 3.1 default dialect, 'format' is only an annotation unless the validator enables format assertion. So 'format: uri' alone may reject nothing, and patterns are needed for the https and no-fragment rules. RFC 3986 is foundational and large (about 142 KB); vendor it only if the repo adopts a 'vendor every RFC the YAML cites' policy. *(Update 2026-10-11: that policy was adopted, and RFC 3986 is now vendored.)*

### Findings (0 high · 0 medium · 4 low)

1. **[LOW] Gap: Component-level URI constraints that 'format: uri' cannot express**  
   *Reference:* RFC 3986 §3 (components), §4.3 (absolute-URI), as used by RFC 8414 §2, RFC 9728 §1.2, RFC 6749 §3.1.2, RFC 8707 §2  
   OAuth constrains URIs component by component: - issuer: https, no query, no fragment; - resource identifier: https, no fragment, SHOULD NOT have a query; - redirect URI and resource indicator: absolute URI, no fragment; - jwks_uri: https. The YAML uses plain 'format: uri' for all of them (e.g. 1946, 1963, 2288; the PRM resource uses StringOrURI at 2282). Even when 'format' is asserted, it accepts http, query and fragment.  
   *Suggested change:* Add patterns: - issuer and authorization_servers items: '^https://[^?#]+$' - PRM resource: '^https://[^#]+$' - jwks_uri: '^https://' - redirect_uri and resource indicators: '^[A-Za-z][A-Za-z0-9+.-]*:[^#]*$' (absolute, no fragment)  
   *Verifier: confirmed.*

2. **[LOW] Gap: No-normalization comparison of identifiers**  
   *Reference:* RFC 3986 §6 (normalization and comparison) vs RFC 8414 §3.3/§4, RFC 9728 §3.3/§6, RFC 7519 §2  
   RFC 3986 §6 allows URIs to be treated as equivalent after case, percent-encoding, dot-segment or scheme-based normalization. OAuth identifiers, by contrast, must be compared code point by code point with no normalization: issuer, resource, and StringOrURI ('no transformations or canonicalizations'). Only issuer mentions 'byte-identical' (1949). StringOrURI (2443-2448) and resource say nothing, so implementers may 'helpfully' normalize, for example by lower-casing the host or stripping a default port or trailing '/'.  
   *Suggested change:* Add to the StringOrURI, issuer and PRM resource descriptions: 'Compared as exact strings (code-point equality, no RFC 3986 §6 normalization): RFC 8414 §4, RFC 9728 §6, RFC 7519 §2.'  
   *Verifier: confirmed.*

3. **[LOW] Gap: Which RFC 3986 components the well-known insertion operates on**  
   *Reference:* RFC 3986 §3.2 (authority, host, port), §3.3 (path), §3.4 (query)  
   RFC 8414 §3 inserts 'between the host component and the path component'; RFC 9728 §3 inserts 'between the host component and the path and/or query components'. In RFC 3986 terms, the insertion point follows the whole authority (host plus optional :port), and RFC 9728 keeps the query. The servers variable is described only as a 'Hostname' (line 84), so port-bearing issuers and query-bearing resource identifiers are unexplained.  
   *Suggested change:* Describe servers[0].variables.issuer as 'authority (host[:port]) of the issuer'. Include a port and a query example in the {issuerPath}/{resourcePath} descriptions, e.g. https://rs.example.com:8443/api?v=1 -> https://rs.example.com:8443/.well-known/oauth-protected-resource/api?v=1.  
   *Verifier: confirmed.*

4. **[LOW] Incorrect: ErrorResponse.error_uri (1525-1528) is typed 'format: uri', which is the RFC 3986 URI production and requires a scheme** — *found by the verifier*  
   *Reference:* RFC 3986 §4.1 (URI-reference) vs §3 (URI); RFC 6749 §1.9, §4.1.2.1, §5.2  
   ErrorResponse.error_uri (1525-1528) is typed 'format: uri', which is the RFC 3986 URI production and requires a scheme. RFC 6749 says 'Values for the error_uri parameter MUST conform to the URI-reference syntax' (RFC 3986 §4.1), and that syntax also admits relative references. A validator that asserts format would reject a legal value such as '/docs/errors#invalid_request'. The RFC 6749 character set %x21 / %x23-5B / %x5D-7E is not encoded either, although error_description has the analogous pattern (1524). This is the opposite of the first agent's RFC 3986 item: here 'format: uri' is too strict, not too loose. It also touches the core RFC 6749 cluster.  
   *Suggested change:* error_uri: {type: string, format: uri-reference, pattern: '^[\x21\x23-\x5B\x5D-\x7E]+$', description: 'URI-reference per RFC 3986 §4.1 (RFC 6749 §5.2)'}

## Verifier corrections to the summaries above

- RFC9728 summary: 'whether DPoP- or mTLS-bound tokens are required' is inaccurate for mTLS. tls_client_certificate_bound_access_tokens indicates 'protected resource support for mutual-TLS client certificate-bound access tokens' (RFC 9728 §2). Only dpop_bound_access_tokens_required states a requirement.
- RFC6755 summary: 'Every URN-shaped value an OAuth AS sees on the wire lives in this namespace' overclaims. Counterexamples include the CIBA grant type urn:openid:params:grant-type:ciba, SAML URNs (urn:oasis:names:tc:SAML:...), ACR values such as urn:mace:incommon:iap:silver (used in the YAML's own example at line 1025), and token types allowed by RFC 8693 §3 ('Other URIs MAY be used'). Accurate wording: the IETF-registered OAuth URNs live there.
- RFC8414 errata note: the rfc-editor.org errata page also lists Rejected erratum 8696 (Editorial), which asked to replace the [MIX-UP] draft reference with RFC 9207. '2 reported errata' is still accurate, and 9178 is typed Technical.
- RFC8414 modeled_elements: the entry for the 'openid-configuration' suffix (RFC 8414 §3, §5) mapping to OpenIDProviderMetadata overstates coverage. Only the OIDC use is modeled; an RFC 8414 document from a non-OIDC AS at that suffix fails validation (see missed item).
- RFC8414 prior_validation_followup: counting 'RFC 8414 and OIDC members are grouped with section comments' as fixed is generous. The comments at 2140 and 2250 cite only OIDC Discovery for four RFC 8414 §2 members, and the modular split drops comments, so the prior 'distinguish RFC 8414 fields from OIDC extensions' item is only partly fixed.
- cluster_notes pointers: challenge_endpoint is requested for both the AS metadata registry (draft-ietf-oauth-attestation-based-client-auth-11 §15.2) and the PRM registry (§15.3), not only for PRM. draft-ietf-oauth-deferred-token-response-00 also defines deferred_client_notification_endpoint and revocation_endpoint_token_type_values_supported, which the list omits.
