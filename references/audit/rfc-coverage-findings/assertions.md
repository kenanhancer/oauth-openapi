# Assertion framework & profiles — RFC 7521, 7522, 7523, rfc7523bis

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 7521](#rfc-7521-assertion-framework-for-oauth-20-client-authentication-and-authorization-grants) | May 2015 | Proposed Standard (update pending: draft-ietf-oauth-rfc7523bis-11, in RFC Editor queue) | mostly | 0 | 3 | 7 |
| [RFC 7522](#rfc-7522-security-assertion-markup-language-saml-20-profile-for-oauth-20-client-authentication-and-authorization-grants) | May 2015 | Proposed Standard (update pending: draft-ietf-oauth-rfc7523bis-11 §3 deprecates its client-authentication part) | none | 0 | 1 | 1 |
| [RFC 7523](#rfc-7523-json-web-token-jwt-profile-for-oauth-20-client-authentication-and-authorization-grants) | May 2015 | Proposed Standard (update pending: draft-ietf-oauth-rfc7523bis-11, in RFC Editor queue) | mostly | 1 | 4 | 8 |
| [draft-ietf-oauth-rfc7523bis-11](#draft-ietf-oauth-rfc7523bis-11-updates-to-oauth-20-json-web-token-jwt-client-authentication-and-assertion-based-authorization-grants) | April 2026 | Internet-Draft -11 — IESG-approved 2026-04-30, in RFC Editor queue (intended Proposed Standard; updates RFC 7521, 7522, 7523, 9126) | none | 1 | 1 | 3 |

**Cluster notes.** Scope: RFC 7521, RFC 7522, RFC 7523 and draft-ietf-oauth-rfc7523bis-11, compared against the snapshot oauth-openapi.yaml (2,704 lines). Nothing under the repo or the snapshot was modified.

Overall picture:
- JWT profile: modeled at the parameter level. The IANA diff shows assertion, client_assertion, client_assertion_type, both jwt-bearer URNs, private_key_jwt and client_secret_jwt all present.
- SAML profile: entirely absent. The two saml2-bearer URNs, which are on the IANA absence list, are the only IANA entries from this cluster missing.
- rfc7523bis: not reflected at all. Yet the YAML's own OAuth 2.1 baseline (-15 §2.4, and the current -16 §2.4) says clients and authorization servers MUST follow its aud guidance whenever JWT client authentication is used, and the YAML does advertise private_key_jwt and client_secret_jwt.

Top fixes, in priority order:
1. [high] JWTBearerTokenRequest (L1326-1347) is the only token-request schema without ClientAuthFields, and its description wrongly says the JWT grant authenticates the client. This contradicts RFC 7521 §1/§6.2, RFC 7523 §3.1 ("if client credentials are present … MUST validate them") and the YAML's own /token and clientSecretBasic descriptions.
2. [high] No aud rule for client_assertion. rfc7523bis §4/§5 requires the AS issuer identifier as the sole value, never the token endpoint or PAR URL, and the AS must reject anything else. One edit to the shared ClientAuthFields covers /token, /par, /revoke, /introspect and /device_authorization.
3. The assertion description is wrong in two places: it says aud is "the AS token endpoint URL" (L1342), and it labels nbf/iat/jti "RECOMMENDED" (L1343) where RFC 7523 says MAY.
4. Enforce the client_assertion/client_assertion_type pairing and the one-method rule with dependentRequired and not.
5. Add {} to /introspect security (L360-363) so private_key_jwt can satisfy the declared security there.
6. Document the remaining rules:
   - typ client-authentication+jwt
   - error mapping: invalid_grant vs invalid_client
   - assertion-grant scope and lifetime rules
   - doc-only ClientAssertionClaims and JWTBearerGrantClaims schemas, following the existing convention of intentionally unused IDTokenClaims and JWTAccessTokenClaims
7. Decide on SAML: model the saml2-bearer grant, or document it as excluded.

Verification:
- With jsonschema 4.26 (Draft 2020-12), the current TokenRequest accepts three bad bodies:
  - jwt-bearer with client_assertion, but only as untyped extra properties
  - client_assertion without client_assertion_type
  - client_assertion together with client_secret
- The proposed patch rejects the last two and keeps jwt-bearer plus private_key_jwt valid.
- The JWT helper pattern (L2440) rejects a JWE with an empty encrypted-key segment (alg dir or ECDH-ES).
- The proposed metadata if/then rule and the SAML and ClientAssertionClaims snippets validate.

External checks today:
- Datatracker: rfc7523bis -11 posted 2026-04-28 (its header still says 26 March 2026), IESG-approved 2026-04-30, in the RFC Editor queue since 2026-05-04, "In Progress (Second Edit)" since 2026-09-30.
- IANA: application/client-authentication+jwt media type registered 2026-05-05. The four OAuth URI entries and the private_key_jwt/client_secret_jwt auth-method entries were updated 2026-05-05 to cite RFC-ietf-oauth-rfc7523bis-11.
- RFC Editor errata.json lists no errata for RFC 7521, 7522 or 7523.
- CVE-2025-27370 and CVE-2025-27371 confirmed via cveawg.mitre.org.

Prior May-2026 audit (7523-jwt-bearer.md), 16 items: 6 fixed, 1 no-op, 4 partial, 5 open. RFC 7521, RFC 7522 and rfc7523bis have no validation files.

Vendoring: RFC 7521, 7522 and 7523 are already vendored and byte-identical to rfc-editor.org. Vendor draft-ietf-oauth-rfc7523bis-11 now, and swap in the RFC once it is published.

## RFC 7521 Assertion Framework for OAuth 2.0 Client Authentication and Authorization Grants

*May 2015 · Proposed Standard (update pending: draft-ietf-oauth-rfc7523bis-11, in RFC Editor queue) · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 7521 is the abstract plumbing for using assertions at an OAuth token endpoint. An assertion is a signed package of identity and security claims, issued by a security token service or self-issued by the client. As an authorization grant, the client sends grant_type=&lt;absolute URI> plus assertion and an optional scope; for client authentication, it sends client_assertion_type plus client_assertion instead of a secret. It fixes the shared error codes (invalid_grant for a bad grant assertion; invalid_client for a bad client assertion or for using more than one auth method) and minimum content rules (Issuer, Subject, Audience, Expires At, signature or MAC), and needs a concrete profile such as SAML (RFC 7522) or JWT (RFC 7523) to be implementable.

**Why it was created.** OAuth 2.0 (RFC 6749) defined only password-style client secrets and left extension grants open. Enterprises already ran identity federations (SAML IdPs, WS-Trust security token services) that issue signed assertions, and wanted two things. First, to exchange an existing assertion for an access token in server-to-server and integration scenarios, with no browser redirect or interactive consent. Second, to let clients prove who they are with a signed, short-lived assertion instead of sending a reusable shared secret on every request. RFC 7521 standardizes the common parameter names, error codes and processing rules so format-specific profiles interoperate. It draws on the earlier OAuth WRAP work credited in its acknowledgements.

<details><summary>Already modeled in the YAML (12)</summary>

- assertion (token request, REQUIRED) — components.schemas.JWTBearerTokenRequest.assertion, L1333 + L1338-1345 (JWT profile only)
- grant_type as an absolute URI for an assertion grant — JWTBearerTokenRequest.grant_type const urn:ietf:params:oauth:grant-type:jwt-bearer L1335-1337; TokenRequest.oneOf L1161 + discriminator.mapping L1170
- scope (OPTIONAL) on the assertion grant — JWTBearerTokenRequest.scope L1346-1347 (no constraints)
- client_assertion — components.schemas.ClientAuthFields.client_assertion L1191-1196
- client_assertion_type (absolute URI) — ClientAuthFields.client_assertion_type L1197-1200 (const jwt-bearer URN at L1199)
- client_id OPTIONAL with client assertions, plus the same-client rule (§4.2) — ClientAuthFields.client_id L1178-1184
- Client assertion combinable with grants (§4.2, §6.1), including client_credentials (§6.2) — ClientAuthFields in AuthorizationCodeTokenRequest L1241, ClientCredentialsTokenRequest L1271, RefreshTokenRequest L1291, DeviceCodeTokenRequest L1312, TokenExchangeRequest L1352 (also DeviceAuthorizationRequest L1544, PARRequest L1591, IntrospectionRequest L1682, RevocationRequest L1796) — but NOT JWTBearerTokenRequest (L1330-1331)
- invalid_grant (§4.1.1) and invalid_client (§4.2.1) — components.schemas.ErrorResponse.error enum L1481 / L1480
- Error response with Cache-Control: no-store (as in the §4.1.1/§4.2.1 examples) — /token 400 → components.responses.OAuthErrorWithDPoPNonce L261-262 (CacheControlNoStore L990-994)
- Form-encoded token request — paths./token.post.requestBody application/x-www-form-urlencoded L241-246
- TLS for token-endpoint requests (§4) — servers[0].url 'https://{issuer}' L78
- IANA OAuth Parameters entries assertion / client_assertion / client_assertion_type (§9) — all present (none in the IANA absence list)

</details>

**Follow-up on the May-2026 validation notes.** No rfc-validation file exists for RFC 7521; it was vendored on 2026-06-06 without an audit. The May-2026 synthesis (references/audit/rfc-audit-synthesis.md) asked for client_assertion + client_assertion_type on every token request. That is done via ClientAuthFields on 5 of the 6 token-request schemas, plus the Revocation, Introspection, PAR and DeviceAuthorization requests. It is still missing on JWTBearerTokenRequest, where the synthesis itself hedged ('usually NOT used here since JWT is the assertion'), and that hedge became the incorrect description at L1327-1329.

**Notes.** Learner view: an assertion GRANT (grant_type + assertion) says 'this resource owner authorized access' (Subject = resource owner or delegate). A CLIENT assertion (client_assertion_type + client_assertion) says 'this is client X' (Subject = client_id). They are independent and can appear in the same request (RFC 7521 §1 Note, §6). RFC 7521 is format-agnostic; implementing it through the JWT profile is the expected route. The §4.2.1 example JSON is missing a comma after "invalid_client" (no erratum in rfc-editor.org errata.json), so don't copy it verbatim into YAML examples. rfc7523bis §2 replaces the §5.1 Audience description, making the issuer identifier the example audience instead of the token endpoint URL.

### Findings (0 high · 3 medium · 7 low)

1. **[MEDIUM] Gap: client_assertion + client_assertion_type pairing; one client-authentication method per request**  
   *Reference:* RFC 7521 §4.2, §4.2.1 (also RFC 6749 §2.3, OAuth 2.1 §2.4)  
   RFC 7521 §4.2 makes both parameters REQUIRED whenever an assertion is used for client authentication. §4.2.1 requires invalid_client when more than one client authentication mechanism is used. ClientAuthFields (L1175-1200) declares the four fields independently, with no dependency or exclusion. A Draft 2020-12 validator therefore accepts client_assertion without client_assertion_type, and client_assertion together with client_secret (both verified).  
   *Suggested change:* In components.schemas.ClientAuthFields add:

   ```yaml
   dependentRequired:
     client_assertion: [client_assertion_type]
     client_assertion_type: [client_assertion]
   not:
     required: [client_assertion, client_secret]
   ```

   Append to the client_assertion description: 'MUST NOT be combined with another client-authentication method (HTTP Basic, client_secret, mTLS); the AS answers invalid_client (RFC 7521 §4.2.1, RFC 6749 §2.3).' Combinations with the Authorization header or mTLS cannot be expressed in OpenAPI and stay as prose.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Error-code mapping for assertion failures**  
   *Reference:* RFC 7521 §4.1.1, §4.2.1  
   invalid_grant and invalid_client are in ErrorResponse.error (L1480-1481), but nothing says which one applies. An invalid or expired assertion grant MUST yield invalid_grant. An invalid client assertion, or more than one client-auth mechanism, MUST yield invalid_client. ClientAuthError (L1109-1114) only covers 401 for Authorization-header auth, so the RFC's own case (invalid_client returned with HTTP 400 for a body-borne client assertion) is not described.  
   *Suggested change:* Extend ErrorResponse.error.description (L1476) with a mapping: 'invalid_grant — the assertion grant is invalid, expired, or outside its validity window (RFC 7521 §4.1.1, RFC 7523 §3.1); invalid_client — the client_assertion is invalid, or more than one client-authentication method was used (RFC 7521 §4.2.1, RFC 7523 §3.2); usually HTTP 400 when no Authorization header was used (401 is permitted, RFC 6749 §5.2).' Add the same sentence to components.responses.ClientAuthError.description.  
   *Verifier: confirmed.*

3. **[MEDIUM] Incorrect: L1327-1329 components.schemas.JWTBearerTokenRequest.description**  
   *Reference:* RFC 7521 §1 (Note), §5.1, §6.2, §6.3; RFC 7523 §1  
   Says 'the JWT itself authenticates the client in most uses, so client_assertion_* is usually omitted'. RFC 7521 contradicts this. The assertion grant and client authentication are orthogonal and separable (§1 Note); the grant's Subject identifies the resource owner or an authorized delegate (§5.1, §6.3); and a client acting on its own behalf should use grant_type=client_credentials with a client assertion (§6.2). The jwt-bearer grant does not authenticate the client. Whether the client also authenticates is AS policy, and confidential clients must (RFC 6749 §3.2.1). This sentence is the stated reason ClientAuthFields was left out of the schema (structural defect reported under RFC 7523).  
   *Suggested change:* Replace with: 'RFC 7523 §2.1 / RFC 7521 §4.1. The assertion is an authorization grant whose sub identifies the resource owner or an authorized delegate; it is orthogonal to client authentication (RFC 7521 §1). The client MAY also authenticate (Basic, mTLS, client_secret_post, private_key_jwt or client_secret_jwt) and MUST if it is confidential; if client credentials are present, the AS MUST validate them (RFC 7523 §3.1). client_id is needed only when the chosen client-authentication method relies on it (RFC 7523 §2.1). A client acting on its own behalf should use client_credentials + client_assertion instead (RFC 7521 §6.2).'  
   *Verifier: confirmed.*

4. **[LOW] Gap: scope on assertion grants**  
   *Reference:* RFC 7521 §4.1  
   JWTBearerTokenRequest.scope (L1346-1347) is a bare string. RFC 7521 §4.1: the requested scope MUST be equal to or less than the scope originally granted to the authorized accessor, and the AS MUST limit the issued token's scope to that.  
   *Suggested change:* Describe JWTBearerTokenRequest.scope: 'OPTIONAL. Requested scope (RFC 6749 §3.3). MUST be equal to or less than the scope previously granted out of band to the authorized accessor; the AS MUST limit the issued token to it (RFC 7521 §4.1).' Reuse the RFC 6749 §3.3 pattern from components.parameters.Scope (L744).  
   *Verifier: confirmed.*

5. **[LOW] Gap: Access-token lifetime and refresh tokens for assertion grants**  
   *Reference:* RFC 7521 §4.1  
   RFC 7521 §4.1 says the AS SHOULD NOT issue access tokens that outlive the assertion's validity by a significant period. In practice refresh tokens are not issued for assertion grants; the client presents the still-valid or a new assertion again. Neither JWTBearerTokenRequest nor TokenResponse.refresh_token (L1433-1439) / expires_in (L1428-1432) says so.  
   *Suggested change:* Add to JWTBearerTokenRequest.description: 'The AS SHOULD NOT issue an access token that outlives the assertion's exp by a significant period, and typically omits refresh_token; the client gets a new token by presenting a valid assertion again (RFC 7521 §4.1).' Cross-reference this from TokenResponse.refresh_token.  
   *Verifier: confirmed.*

6. **[LOW] Gap: Assertion-grant extension point (other grant_type URIs)**  
   *Reference:* RFC 7521 §4.1, §7 (RFC 6749 §4.5; OAuth 2.1 §4.4)  
   RFC 7521 §4.1 lets grant_type be any absolute URI naming the assertion format. The closed oneOf/discriminator (L1152-1171) admits only the jwt-bearer URN. Neither TokenRequest.description (L1153-1155) nor the Modeling notes (L47-64) says that other assertion profiles (e.g. urn:ietf:params:oauth:grant-type:saml2-bearer) are deliberately out of scope.  
   *Suggested change:* Add a Modeling-notes bullet after L61: 'Assertion grants: only the JWT profile (RFC 7523) of the RFC 7521 framework is modeled. Other assertion grant URIs (e.g. RFC 7522 saml2-bearer) are not part of TokenRequest; an AS that does not support them answers unsupported_grant_type (RFC 6749 §5.2).'  
   *Verifier: confirmed.*

7. **[LOW] Gap: Issuer/Audience comparison and self-issued assertion rules (assertion metamodel)**  
   *Reference:* RFC 7521 §5.1, §5.2  
   None of these rules is documented: Issuer and Audience MUST be compared with RFC 3986 §6.2.1 Simple String Comparison; a self-issued assertion's Issuer MUST be the client_id; for client authentication the Subject MUST be the client_id; Expires At is mandatory, and unreasonably distant expiries may be rejected; an invalid signature or MAC MUST be rejected.  
   *Suggested change:* Carry these rules in ClientAuthFields.client_assertion.description and in the doc-only ClientAssertionClaims schema proposed under RFC 7523, citing RFC 7521 §5.2 alongside RFC 7523 §3.  
   *Verifier: partially correct —* For client_assertion, none of the RFC 7521 §5.2 rules is documented. For the grant assertion, the YAML documents exp REQUIRED and signed/MAC'd (L1341-1345), but not: - Simple String Comparison for iss and aud - iss = client_id when self-issued - rejection of unreasonably distant exp  Cite the client-authentication 'sub MUST be client_id' rule to RFC 7523 §3 item 2.B, not RFC 7521. Cite the audience Simple String Comparison to RFC 7523 §3 item 3 as replaced by rfc7523bis §4, because bis §2 rewrote RFC 7521 §5.1 Audience without it.

8. **[LOW] Gap: Citation of the framework that defines the parameters**  
   *Reference:* RFC 7521 §4.1, §4.2, §9  
   RFC 7521 defines and registers assertion, client_assertion and client_assertion_type. Yet the Covered specifications table (L18-45) lists only RFC 7523, and the ClientAuthFields comment (L1173) and field descriptions (L1196, L1200) cite only RFC 7523 §2.2.  
   *Suggested change:* Add the table row '| RFC 7521 | 2015 | Assertion framework — assertion, client_assertion, client_assertion_type |' after L24. Cite 'RFC 7521 §4.2 (parameters), RFC 7523 §2.2 (JWT values)' in the ClientAuthFields comment and field descriptions.  
   *Verifier: confirmed.*

9. **[LOW] Gap: The client-assertion-type extension point is closed and the restriction is undocumented** — *found by the verifier*  
   *Reference:* RFC 7521 §4.2  
   The client-assertion-type extension point is closed and the restriction is undocumented. RFC 7521 §4.2 lets client_assertion_type be any absolute URI defined by the AS, and suggests urn:ietf:params:oauth:client-assertion-type:*. The YAML fixes it to the JWT value (const, L1197-1200), and token_endpoint_auth_methods_supported is a closed enum (L2041-2048). Neither the Modeling notes (L47-64) nor the field description says that other client-assertion profiles are out of scope. The first agent covered only the grant_type extension point (RFC 7521 G5) and only the SAML client-auth exclusion (RFC 7522 G2).  
   *Suggested change:* Extend ClientAuthFields.client_assertion_type.description (L1200) to say that only the JWT profile value is modeled, and that other RFC 7521 client-assertion types (saml2-bearer, deprecated by rfc7523bis §3; jwt-spiffe, in draft) are out of scope. Add the same note to the Modeling notes bullet proposed for assertion grants.

10. **[LOW] Incorrect: The shared client_id description would be wrong for the assertion grant once the first agent's high-severity fix is applied** — *found by the verifier*  
   *Reference:* RFC 7521 §4.1; RFC 7523 §2.1; RFC 6749 §3.2.1; OAuth 2.1 -16 §3.2.2  
   The shared client_id description would be wrong for the assertion grant once the first agent's high-severity fix is applied. ClientAuthFields.client_id (L1180-1182) says 'REQUIRED for unauthenticated (public) clients per RFC 6749 §3.2.1'. RFC 6749 §3.2.1 limits that MUST to the authorization_code grant. For assertion grants, RFC 7521 §4.1 and RFC 7523 §2.1 say client_id is needed only when a client-authentication method that relies on it is used. Mixing ClientAuthFields into JWTBearerTokenRequest (the proposed fix for RFC 7523 L1330-1331) would bring in a description that wrongly makes client_id mandatory for unauthenticated jwt-bearer requests. The first agent's new JWTBearerTokenRequest description states the right rule but leaves the conflicting shared text in place.  
   *Suggested change:* Reword ClientAuthFields.client_id to follow OAuth 2.1 §3.2.2: 'OPTIONAL in general; needed when the client-authentication method relies on it or the grant requires identification of public clients (REQUIRED for unauthenticated clients on authorization_code per RFC 6749 §3.2.1 / OAuth 2.1 §4.1.3 and on device_code per RFC 8628 §3.4).' Do this together with adding ClientAuthFields to JWTBearerTokenRequest.

## RFC 7522 Security Assertion Markup Language (SAML) 2.0 Profile for OAuth 2.0 Client Authentication and Authorization Grants

*May 2015 · Proposed Standard (update pending: draft-ietf-oauth-rfc7523bis-11 §3 deprecates its client-authentication part) · YAML coverage: **none** · relevance to an AS: optional · vendoring: already-vendored*

**What it is.** RFC 7522 profiles RFC 7521 for SAML 2.0. The grant is grant_type=urn:ietf:params:oauth:grant-type:saml2-bearer with exactly one SAML Assertion in `assertion`, base64url-encoded without padding or line wraps. Client authentication uses client_assertion_type=urn:ietf:params:oauth:client-assertion-type:saml2-bearer. The AS validates the assertion much as a SAML service provider would: Issuer, an AudienceRestriction naming the AS, a Subject with a bearer SubjectConfirmation whose Recipient is the token endpoint, NotOnOrAfter, and an XML signature (RSA-SHA256 mandatory to implement).

**Why it was created.** Many organizations already had SAML 2.0 single sign-on and trusted SAML IdPs. RFC 7522 lets an assertion from that infrastructure be used directly at an OAuth token endpoint, either to get an access token for an already-established trust relationship with no user-approval step at the AS, or to authenticate the client. It reuses well-understood rules from the SAML Web Browser SSO profile (bearer subject confirmation, Recipient, NotOnOrAfter) to bridge SAML federations to OAuth-protected APIs.

<details><summary>Already modeled in the YAML (3)</summary>

- No RFC 7522-specific element is modeled, and the YAML never cites RFC 7522. Both saml2-bearer URNs are listed as absent in the IANA absence list.
- Reusable generic pieces only: invalid_grant (§3.1) / invalid_client (§3.2) — ErrorResponse.error enum L1481 / L1480
- RFC 7521 transport fields exist but are pinned to JWT: JWTBearerTokenRequest.grant_type const L1337; ClientAuthFields.client_assertion_type const L1199, which rejects the saml2-bearer value

</details>

**Follow-up on the May-2026 validation notes.** No rfc-validation file exists for RFC 7522 (vendored 2026-06-06), and the YAML never cites it.

**Notes.** TokenTypeURI's urn:ietf:params:oauth:token-type:saml2 (L1394) is the RFC 8693 token-exchange identifier, not this grant. A SAML assertion can already be exchanged through the modeled token exchange, which may be the simpler bridge for a new OAuth 2.1 AS. Encoding is stricter for grants than for client auth: grant assertions MUST NOT be wrapped or padded (§2.1), while client-auth assertions only SHOULD NOT be (§2.2). rfc7523bis §3 rewrites the §3 item 2 Audience rule and deprecates SAML client authentication.

### Findings (0 high · 1 medium · 1 low)

1. **[MEDIUM] Gap: SAML 2.0 Bearer Assertion grant — grant_type urn:ietf:params:oauth:grant-type:saml2-bearer**  
   *Reference:* RFC 7522 §2.1, §3, §3.1, §5, §8.1  
   Absent from the YAML; no 'saml2-bearer' token appears anywhere, and IANA lists it.  Wire format: - grant_type URN - assertion: exactly one SAML 2.0 Assertion, base64url-encoded with no line wraps and no '=' padding (MUST, §2.1) - optional scope - optional client authentication; if credentials are present the AS MUST validate them (§3.1) - an invalid assertion yields invalid_grant (§3.1)  Processing (§3): - Issuer - AudienceRestriction/Audience identifying the AS. As replaced by rfc7523bis §3, this is the issuer identifier, the token endpoint URL, or a SAML Entity ID; the AS MUST reject any other audience. - Subject - bearer SubjectConfirmation (Method urn:oasis:names:tc:SAML:2.0:cm:bearer), whose Recipient MUST match the token endpoint URL, with NotOnOrAfter - signature or MAC (RSA-SHA256 mandatory to implement, §5)  The grant is still offered by several enterprise IdPs.  
   *Suggested change:* Either (a) add a branch:

   ```yaml
   SAML2BearerTokenRequest:
     description: RFC 7522 §2.1 (audience per rfc7523bis §3); invalid assertion -> invalid_grant (§3.1)
     allOf:
       - $ref: '#/components/schemas/ClientAuthFields'
       - $ref: '#/components/schemas/ResourceIndicators'
       - type: object
         required: [grant_type, assertion]
         properties:
           grant_type: { type: string, const: 'urn:ietf:params:oauth:grant-type:saml2-bearer' }
           assertion:
             type: string
             pattern: '^[A-Za-z0-9_-]+$'
             description: Exactly one SAML 2.0 Assertion, base64url without line wraps or '=' padding; validated per RFC 7522 §3
           scope: { type: string }
   ```

   Then add it to TokenRequest.oneOf, add the discriminator mapping 'urn:ietf:params:oauth:grant-type:saml2-bearer' (L1156-1171), list it in the /token description (L219-224), and add it as a grant_types_supported example. The snippet was validated. Or (b) record it as intentionally excluded in the Modeling notes (L47-64), naming RFC 8693 token exchange with subject_token_type urn:ietf:params:oauth:token-type:saml2 (TokenExchangeRequest L1349-1385, TokenTypeURI L1394) as the modeled way to bring a SAML assertion in.  
   *Verifier: partially correct —* The gap stands. Restate the audience rule as rfc7523bis §3 gives it: the AS MUST reject an assertion whose AudienceRestriction does not contain the AS's own identity (issuer identifier, token endpoint URL or SAML Entity ID). Additional audience values are not forbidden. The replacement item 2 also drops the old Simple String Comparison sentence.

2. **[LOW] Gap: SAML client authentication — client_assertion_type urn:ietf:params:oauth:client-assertion-type:saml2-bearer**  
   *Reference:* RFC 7522 §2.2, §3.2, §8.2 (deprecated by draft-ietf-oauth-rfc7523bis-11 §3)  
   ClientAuthFields.client_assertion_type is const jwt-bearer (L1199), so a SAML client assertion is rejected at the schema level. That matches rfc7523bis §3 ('SAML Bearer Assertions MUST NOT be used for client authentication for any new applications'), but neither the exclusion nor its reason is documented.  
   *Suggested change:* Extend ClientAuthFields.client_assertion_type.description (L1200): 'Only the JWT value is accepted. urn:ietf:params:oauth:client-assertion-type:saml2-bearer (RFC 7522 §2.2) is intentionally not modeled: draft-ietf-oauth-rfc7523bis §3 forbids SAML client authentication for new applications.'  
   *Verifier: confirmed.*

## RFC 7523 JSON Web Token (JWT) Profile for OAuth 2.0 Client Authentication and Authorization Grants

*May 2015 · Proposed Standard (update pending: draft-ietf-oauth-rfc7523bis-11, in RFC Editor queue) · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 7523 profiles RFC 7521 for JSON Web Tokens. The grant is grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer with exactly one JWT in `assertion`; client authentication is client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer with exactly one JWT in `client_assertion` (OpenID Connect calls these private_key_jwt and client_secret_jwt). Every such JWT MUST carry iss, sub, aud (identifying the AS) and exp, MAY carry nbf/iat/jti, and MUST be signed or MAC'd; for a grant, sub is the user or delegate, while for client authentication sub is the client_id. Failures map to invalid_grant (grant) or invalid_client (client authentication), and RS256 is mandatory to implement.

**Why it was created.** SAML's XML signatures are heavy and awkward for modern web and mobile stacks, while JWTs (RFC 7519, published the same month) are compact, JSON-based and URL-safe. RFC 7523 gives the JWT equivalent of RFC 7522. A client or a trusted issuer can mint a signed JWT to get tokens without a redirect (service accounts, cross-domain trust, and later identity chaining and ID-JAG), and clients can authenticate with a signed JWT instead of sending a shared secret. That second use is the basis of OIDC's private_key_jwt, which OAuth 2.1 §2.4 and RFC 9700 §2.5 RECOMMEND.

<details><summary>Already modeled in the YAML (12)</summary>

- grant_type urn:ietf:params:oauth:grant-type:jwt-bearer (§2.1, §8.1) — JWTBearerTokenRequest.grant_type const L1335-1337; TokenRequest.oneOf L1161 + discriminator.mapping L1170; /token description L223
- assertion REQUIRED, documented as a signed or MAC'd JWT with iss/sub/aud/exp (§2.1, §3) — JWTBearerTokenRequest L1333, L1338-1345
- scope OPTIONAL (§2.1) — JWTBearerTokenRequest.scope L1346-1347
- client_assertion_type urn:ietf:params:oauth:client-assertion-type:jwt-bearer (§2.2, §8.2) — ClientAuthFields.client_assertion_type const L1197-1200
- client_assertion (§2.2) — ClientAuthFields.client_assertion L1191-1196, mixed into 9 request schemas
- private_key_jwt / client_secret_jwt advertised — OAuthServerMetadata.token_endpoint_auth_methods_supported enum L2045-2046
- token_endpoint_auth_signing_alg_values_supported (REQUIRED when JWT methods are advertised) — OAuthServerMetadata L2050-2056
- revocation_/introspection_endpoint_auth_methods_supported + *_signing_alg_values_supported — OAuthServerMetadata L2057-2068
- invalid_grant (§3.1) L1481, invalid_client (§3.2) L1480, unsupported_grant_type L1483 — ErrorResponse.error enum
- /token 400 → OAuthErrorWithDPoPNonce (L261-262); 401 → ClientAuthError (L263-264)
- Body-credential convention documented — paths./token description L229-235; securitySchemes.clientSecretBasic description L2665-2674 (the old fake X-OAuth-Client-Assertion header scheme is gone)
- Covered-specifications table row — info.description L25

</details>

**Follow-up on the May-2026 validation notes.** The prior file, references/rfc-validation/7523-jwt-bearer.md (audited 2026-05-10), had 16 items: 5 MISSING, 6 WRONG, 5 NICE-TO-HAVE.

FIXED (6):
- client_assertion_type modeled with the jwt-bearer URN (ClientAuthFields L1197-1200)
- client_assertion modeled (L1191-1196)
- token_endpoint_auth_signing_alg_values_supported added (L2050-2056)
- wrong 'RFC 7521' citation (moot: the scheme was removed)
- 'signed or MAC'd' wording (L1343-1344)
- resource on JWTBearerTokenRequest (L1331)

NO-OP (1): unsupported_grant_type was already present (L1483).

PARTIAL (4):
- The fake X-OAuth-Client-Assertion apiKey header scheme is gone and the body fields were added to every request schema EXCEPT JWTBearerTokenRequest.
- Claims are documented for `assertion` only, and with new errors: aud = 'the AS token endpoint URL', nbf/iat/jti 'RECOMMENDED'.
- The aud rule is surfaced for grants only, not for client assertions.
- private_key_jwt and client_secret_jwt are named, but the HMAC-vs-asymmetric distinction is not explained.

OPEN (5):
- jwt-bearer URN example in grant_types_supported (L2033-2036)
- iss/sub distinction between grant and client authentication
- doc-only assertion-claims schema
- examples for the URNs and assertion
- jti replay protection being OPTIONAL (now contradicted by 'RECOMMENDED')

NEW since that audit: rfc7523bis-11 (IESG-approved 2026-04-30) plus OAuth 2.1 §2.4 make the issuer the sole required aud for client JWTs, and the YAML doesn't reflect it.

**Notes.** Verified with jsonschema 4.26 (Draft 2020-12) against an in-memory patched copy of the snapshot. RFC 7521 §6.2: a client acting for itself should use client_credentials + client_assertion, not the jwt-bearer grant. Current consumers of the grant include draft-ietf-oauth-identity-chaining (in the RFC Editor queue) and ID-JAG (draft-ietf-oauth-identity-assertion-authz-grant-04, which says it SHOULD only be supported for confidential clients). Both pair the grant with client authentication, which is why the missing ClientAuthFields matters. The vendored OIDC Core (errata set 2) §9 still says the client-assertion aud SHOULD be the token endpoint URL; rfc7523bis and OAuth 2.1 §2.4 supersede that.

### Findings (1 high · 4 medium · 8 low)

1. **[HIGH] Incorrect: L1330-1331 components.schemas.JWTBearerTokenRequest.allOf (contains only ResourceIndicators)**  
   *Reference:* RFC 7523 §2.1, §3.1; RFC 7521 §4.1, §4.2; RFC 6749 §3.2.1  
   JWTBearerTokenRequest is the only token-request schema without ClientAuthFields, so client_id, client_secret, client_assertion and client_assertion_type are not modeled for the jwt-bearer grant.  RFC 7523 §2.1 says client_id is needed when the client uses an auth method that relies on it. §3.1 says JWT grants may be used with or without client authentication, but 'if client credentials are present in the request, the authorization server MUST validate them'. Confidential clients MUST authenticate (RFC 6749 §3.2.1).  Generated models drop these fields; the validator only passes them through as untyped extras (verified). A generated server therefore cannot validate them, and only Basic and mTLS remain usable for this grant. That blocks the private_key_jwt method that OAuth 2.1 §2.4 RECOMMENDS. It also contradicts the YAML's own /token description (L229-233) and clientSecretBasic description (L2668-2674), which say body methods are modeled by ClientAuthFields in each token request.  
   *Suggested change:* allOf:

   ```yaml
   - $ref: '#/components/schemas/ClientAuthFields'
   - $ref: '#/components/schemas/ResourceIndicators'
   - type: object   # unchanged grant_type / assertion / scope
   ```

   Replace the description as shown in the RFC 7521 entry. Validated: jwt-bearer + private_key_jwt bodies remain valid under TokenRequest's oneOf.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: client_assertion JWT content and validation rules**  
   *Reference:* RFC 7523 §2.2, §3 items 1, 2.B, 4–10, §3.2, §5; RFC 7521 §5.2  
   ClientAuthFields.client_assertion (L1191-1196) says only 'JWT bearing claims that authenticate the client'. It is missing: - exactly one JWT (§2.2) - iss: the issuer, which is the client_id when self-issued (RFC 7521 §5.2) and always for OIDC private_key_jwt/client_secret_jwt - sub MUST be the client_id (§3 item 2.B) - the aud rule (see the rfc7523bis entry) - exp REQUIRED, enforced with clock skew (§3 item 4) - nbf/iat/jti OPTIONAL, although OIDC Core §9 makes jti REQUIRED and single-use for private_key_jwt/client_secret_jwt - signed or MAC'd, and an invalid signature or MAC MUST be rejected (§3 item 9) - an otherwise-invalid JWT MUST be rejected (§3 item 10) - client_secret_jwt is an HMAC keyed with the client_secret, while private_key_jwt uses a registered key pair (OIDC Core §9) - RS256 is mandatory to implement (§5) There is also no decoded-claims schema, unlike IDTokenClaims (L2461) and JWTAccessTokenClaims (L2514).  
   *Suggested change:* Rewrite the client_assertion description with these rules and add a documentation-only schema beside IDTokenClaims (snippet validated):

   ```yaml
   ClientAssertionClaims:
     description: Decoded payload of ClientAuthFields.client_assertion (RFC 7523 §3 as updated by rfc7523bis §4); JOSE typ SHOULD be client-authentication+jwt.
     type: object
     required: [iss, sub, aud, exp]
     additionalProperties: true
     properties:
       iss: { $ref: '#/components/schemas/StringOrURI' }   # client_id when self-issued
       sub: { $ref: '#/components/schemas/StringOrURI' }   # MUST be the client_id
       aud:
         oneOf:
           - $ref: '#/components/schemas/StringOrURI'
           - { type: array, minItems: 1, maxItems: 1, items: { $ref: '#/components/schemas/StringOrURI' } }
       exp: { $ref: '#/components/schemas/NumericDate' }
       nbf: { $ref: '#/components/schemas/NumericDate' }
       iat: { $ref: '#/components/schemas/NumericDate' }
       jti: { type: string }   # OPTIONAL in RFC 7523; REQUIRED + single-use for OIDC private_key_jwt/client_secret_jwt
   ```

   Reference it from the client_assertion description (same convention as IDTokenClaims).  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: Error mapping for the JWT profile**  
   *Reference:* RFC 7523 §3.1, §3.2  
   Same gap as RFC 7521 §4.1.1/§4.2.1. An invalid grant JWT, or a current time outside its validity window, MUST give invalid_grant; an invalid client JWT MUST give invalid_client. Neither rule is written in ErrorResponse (L1474-1476) or ClientAuthError (L1109-1114).  
   *Suggested change:* Apply the ErrorResponse/ClientAuthError description change from the RFC 7521 entry, and cite RFC 7523 §3.1/§3.2 there.  
   *Verifier: confirmed.*

4. **[MEDIUM] Incorrect: L1341-1342 components.schemas.JWTBearerTokenRequest.allOf[1].properties.assertion.description**  
   *Reference:* RFC 7523 §3 item 3; draft-ietf-oauth-rfc7523bis-11 §4 (replacing item 3, case a)  
   Defines aud as 'the AS token endpoint URL'. RFC 7523 §3 item 3 only requires aud to contain 'a value that identifies the authorization server as an intended audience'; the token endpoint URL is merely something that MAY be used. rfc7523bis §4 item 3.a now names the issuer identifier or the token endpoint URL. A server built from this text could reject bis-conformant grants whose aud is the issuer identifier (the bis example uses aud https://authz.example.net).  
   *Suggested change:* 'aud — MUST identify this AS as the intended audience: its issuer identifier (OAuthServerMetadata.issuer; preferred) or its token endpoint URL (rfc7523bis §4 item 3.a), compared with RFC 3986 §6.2.1 simple string comparison. The AS MUST reject a JWT whose aud does not identify it (RFC 7521 §5.2).'  
   *Verifier: confirmed.*

5. **[MEDIUM] Incorrect: L360-363 paths./introspect.post.security**  
   *Reference:* RFC 7523 §2.2; RFC 7662 §2.1; RFC 8414 §2  
   The security list has only clientSecretBasic, mtls and bearerAuth, with no {}. IntrospectionRequest includes ClientAuthFields (L1682), and the metadata advertises introspection_endpoint_auth_methods_supported and _signing_alg_values_supported (L2063-2068), which RFC 8414 §2 defines for private_key_jwt and client_secret_jwt. Yet a caller authenticating only with the RFC 7523 §2.2 client_assertion satisfies none of the declared security requirements. This contradicts the YAML's own convention (clientSecretBasic description L2668-2674: '{}' covers the body methods), so generated gateways would return 401 to valid private_key_jwt introspection calls. RFC 7662 §2.1 accepts any OAuth client authentication.  
   *Suggested change:* Add '- {}' to paths./introspect.post.security. State in the operation description that {} stands only for body-borne client credentials (client_secret_post, private_key_jwt or client_secret_jwt via ClientAuthFields), and that unauthenticated calls MUST still be rejected (RFC 7662 §2.1).  
   *Verifier: confirmed.*

6. **[LOW] Gap: Grant-assertion claim semantics (JWT bearer grant)**  
   *Reference:* RFC 7523 §2.1, §3 items 2.A, 4–6, 10; RFC 7521 §6.3.1  
   The assertion description (L1341-1345) lists claim names but not: - exactly one JWT (§2.1) - sub identifies the resource owner or an authorized delegate, possibly a pseudonymous or anonymous value (§3 item 2.A; RFC 7521 §6.3.1) - exp is enforced with clock skew, and a far-future exp or far-past iat may be rejected (§3 items 4, 6) - the JWT must be otherwise valid per RFC 7519 (§3 item 10)  
   *Suggested change:* Expand JWTBearerTokenRequest.assertion.description with these points. Add a doc-only JWTBearerGrantClaims schema (required [iss, sub, aud, exp]) that mirrors ClientAssertionClaims but carries grant semantics for sub and aud.  
   *Verifier: confirmed.*

7. **[LOW] Gap: Single-JWT constraint on assertion and client_assertion**  
   *Reference:* RFC 7523 §2.1, §2.2, §7  
   Both fields are plain `type: string` (L1192, L1339), even though the YAML already defines a compact-serialization JWT schema (L2434-2441). Caveat, verified: that pattern (L2440) rejects a JWE whose encrypted-key segment is empty (alg dir or ECDH-ES), while RFC 7523 §7 suggests encrypting the JWT to the AS when privacy matters.  
   *Suggested change:* Give assertion and client_assertion allOf: [{ $ref: '#/components/schemas/JWT' }] (keeping their descriptions), and relax JWT.pattern to '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$|^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$' which allows an empty second segment only in the 5-part JWE form. Validated: JWS accepted, JWE alg=dir accepted, unsecured 'alg none' still rejected.  
   *Verifier: confirmed.*

8. **[LOW] Gap: RS256 mandatory-to-implement and token_endpoint_auth_signing_alg_values_supported constraints**  
   *Reference:* RFC 7523 §5; RFC 8414 §2  
   L2050-2056 states the conditional requirement in prose only. It does not say that RS256 is mandatory to implement for this profile (RFC 7523 §5; RFC 8414: 'Servers SHOULD support RS256'), or that 'none' MUST NOT be listed. The same 'none' rule applies to the revocation and introspection arrays at L2060-2068.  
   *Suggested change:* Change items to { type: string, not: { const: none } }, add examples: [[RS256, ES256, PS256]], and add to the description 'RS256 is mandatory to implement (RFC 7523 §5)'. On OAuthServerMetadata add (validated):

   ```yaml
   if:
     required: [token_endpoint_auth_methods_supported]
     properties:
       token_endpoint_auth_methods_supported:
         contains: { enum: [private_key_jwt, client_secret_jwt] }
   then:
     required: [token_endpoint_auth_signing_alg_values_supported]
   ```
   *Verifier: confirmed.*

9. **[LOW] Gap: jwt-bearer URN in grant_types_supported**  
   *Reference:* RFC 7523 §2.1, §8.1; RFC 8414 §2; RFC 7591 §2  
   Still open from the prior audit. grant_types_supported (L2033-2036) shows only the RFC 8414 default; nothing tells implementers that an AS supporting this profile lists 'urn:ietf:params:oauth:grant-type:jwt-bearer' (the values are those of RFC 7591 §2 grant_types).  
   *Suggested change:* Add examples: [['authorization_code', 'refresh_token', 'client_credentials', 'urn:ietf:params:oauth:grant-type:jwt-bearer']] and mention the URN in the description.  
   *Verifier: confirmed.*

10. **[LOW] Gap: Request examples for the JWT bearer grant and JWT client authentication**  
   *Reference:* RFC 7523 §2.1, §2.2, §4 (as updated by rfc7523bis §4, §4.1)  
   Still open from the prior audit. Neither use has an example body, so readers never see how the URNs and JWTs are form-encoded.  
   *Suggested change:* Add examples to JWTBearerTokenRequest, e.g. { grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: 'eyJhbGciOiJFUzI1NiIsImtpZCI6IjE2In0.eyJpc3Mi…' }. Add a private_key_jwt example to AuthorizationCodeTokenRequest or ClientCredentialsTokenRequest with client_assertion_type and a client_assertion whose decoded claims follow rfc7523bis §4.1 (aud = issuer, typ client-authentication+jwt).  
   *Verifier: confirmed.*

11. **[LOW] Incorrect: L1343 components.schemas.JWTBearerTokenRequest.allOf[1].properties.assertion.description**  
   *Reference:* RFC 7523 §3 items 5–7, §6  
   Labels nbf, iat and jti 'RECOMMENDED', which means SHOULD under RFC 2119. RFC 7523 §3 items 5–7 say the JWT MAY contain them, and §6 says replay protection is not mandated and is optional.  
   *Suggested change:* 'OPTIONAL (MAY): nbf, iat, jti. The AS MAY reject an iat unreasonably far in the past, and MAY remember used jti values until exp to stop replay; replay protection is optional (RFC 7523 §3 item 7, §6).'  
   *Verifier: confirmed.*

12. **[LOW] Gap: nbf, when present, must be enforced, and this is stated nowhere** — *found by the verifier*  
   *Reference:* RFC 7523 §3 item 5, §3.1 (and RFC 7519 §4.1.5)  
   nbf, when present, must be enforced, and this is stated nowhere. The YAML lists nbf only as 'RECOMMENDED' (L1343). The first agent's replacement wording ('OPTIONAL (MAY): nbf, iat, jti') and the proposed ClientAssertionClaims and JWTBearerGrantClaims schemas also never say that a JWT carrying nbf MUST NOT be accepted before that time. This applies to both grant JWTs and client-authentication JWTs.  
   *Suggested change:* In the assertion and client_assertion descriptions, and in the proposed doc-only claim schemas, add: 'nbf OPTIONAL; if present the AS MUST NOT accept the JWT before that time (allowing for clock skew); a grant JWT outside its validity window → invalid_grant, a client JWT → invalid_client (RFC 7523 §3 item 5, §3.1, §3.2).'

13. **[LOW] Gap: The JWT client-authentication signing-alg arrays for revocation and introspection have no conditional-presence or 'none' rule** — *found by the verifier*  
   *Reference:* RFC 7523 §2.2, §5; RFC 8414 §2  
   The JWT client-authentication signing-alg arrays for revocation and introspection have no conditional-presence or 'none' rule. revocation_endpoint_auth_signing_alg_values_supported (L2060-2062) and introspection_endpoint_auth_signing_alg_values_supported (L2066-2068) have no description. Their companion *_auth_methods_supported arrays (L2057-2059, L2063-2065) are unconstrained strings, whereas the token endpoint uses an enum. The first agent noted the 'none' rule for these arrays, but its if/then fix covers only the token endpoint.  
   *Suggested change:* Add descriptions mirroring L2053-2056 to the four arrays at L2057-2068. Give the alg arrays items {type: string, not: {const: none}}. Add two more if/then branches (inside allOf) like the token-endpoint rule: if revocation_ (or introspection_) endpoint_auth_methods_supported contains private_key_jwt or client_secret_jwt, then the matching *_auth_signing_alg_values_supported is required.

## draft-ietf-oauth-rfc7523bis-11 Updates to OAuth 2.0 JSON Web Token (JWT) Client Authentication and Assertion-Based Authorization Grants

*April 2026 · Internet-Draft -11 — IESG-approved 2026-04-30, in RFC Editor queue (intended Proposed Standard; updates RFC 7521, 7522, 7523, 9126) · YAML coverage: **none** · relevance to an AS: required-oauth21 · vendoring: vendor*

**What it is.** draft-ietf-oauth-rfc7523bis is a targeted security update to RFC 7521, 7522, 7523 and 9126, not a replacement. A JWT used for client authentication MUST have the AS's RFC 8414 issuer identifier as its only aud value — never the token endpoint URL — and the AS MUST reject anything else, at the PAR endpoint too. JWT authorization grants may use either the issuer identifier or the token endpoint URL. Client-authentication JWTs SHOULD be typed typ=client-authentication+jwt, though servers are NOT RECOMMENDED to reject untyped ones; SAML assertions MUST NOT be used for client authentication in new applications.

**Why it was created.** In January 2025, University of Stuttgart researchers Pedram Hosseyni, Ralf Küsters and Tim Würtele disclosed 'audience injection' attacks (OIDF notice 24 January 2025; CVE-2025-27370 and CVE-2025-27371; IACR ePrint 2025/629). RFC 7521/7522/7523/9126 and OIDC Core allowed several audience values (token endpoint URL, PAR endpoint URL, issuer, other identifiers). A malicious AS could list an honest AS's token endpoint in its own metadata and get the client to sign a private_key_jwt with that URL as aud, while the client sent it to one of the attacker's endpoints. The attacker could then replay it to impersonate the client at the honest AS. A client cannot validate endpoint URLs in metadata, but it can validate the issuer (RFC 8414 §3.3), so the update pins the client-auth audience to the issuer identifier and adds explicit typing to signal compliance.

<details><summary>Already modeled in the YAML (5)</summary>

- No rfc7523bis-specific text: 'client-authentication', 'rfc7523bis' and issuer-as-audience wording appear nowhere in the YAML
- Prerequisite present: OAuthServerMetadata.issuer REQUIRED (L1939, L1944-1950), satisfying 'the AS MUST have an issuer identifier' (bis §4)
- Affected parameter present: ClientAuthFields.client_assertion (L1191-1196), shared by /token, /par (PARRequest L1591), /revoke (L1796), /introspect (L1682) and /device_authorization (L1544)
- Consistent with the SAML client-auth deprecation (bis §3): client_assertion_type const jwt-bearer (L1199)
- IANA entries whose references bis updates (§8.2, §8.3): token_endpoint_auth_methods_supported values client_secret_jwt / private_key_jwt (L2045-2046); jwt-bearer URNs (L1199, L1337)

</details>

**Follow-up on the May-2026 validation notes.** Never audited; the draft was IESG-approved after the May-2026 audit. One related item from references/rfc-validation/9126-par.md is still open: documenting the issuer audience for JWT client auth at /par, which was a SHOULD in RFC 9126 §2. bis §5 has since made it a MUST: issuer as sole aud, with every other value rejected.

**Notes.** Datatracker:
- -11 was posted 2026-04-28, though the document header still says 26 March 2026 / expires 27 September 2026.
- IESG approved it 2026-04-30; it entered the RFC Editor queue 2026-05-04 and has been 'In Progress (Second Edit)' since 2026-09-30.

IANA (actions RFC-Ed-Ack 2026-05-07):
- application/client-authentication+jwt media type registered 2026-05-05.
- The four OAuth URI entries and the private_key_jwt / client_secret_jwt auth-method entries were updated 2026-05-05 to cite RFC-ietf-oauth-rfc7523bis-11.

OAuth 2.1 -15 (vendored, L1318-1320) and -16 §2.4 both say 'clients and authorization servers MUST follow the updated guidance around aud values in [I-D.ietf-oauth-rfc7523bis]'.

Server relevance is conditional: the MUST applies because the YAML offers private_key_jwt and client_secret_jwt.

The vendored OIDC Core (errata set 2) §9 still recommends the token endpoint URL as aud (CVE-2025-27370); follow bis and OAuth 2.1 instead.

The draft no longer updates RFC 9101 (dropped in -01).

Recommend vendoring -11 as references/rfc-sources/draft-ietf-oauth-rfc7523bis.txt, adding a references/rfc-validation file, and replacing both when the RFC is published. *(Update 2026-10-11: not adopted. The scope rule vendors only one draft, OAuth 2.1. rfc7523bis is on the watch list in [`../../rfc-sources/README.md`](../../rfc-sources/README.md) and will be vendored when it is published as an RFC.)*

### Findings (1 high · 1 medium · 3 low)

1. **[HIGH] Gap: aud of client-authentication JWTs = the AS issuer identifier as SOLE value (all endpoints, including PAR)**  
   *Reference:* draft-ietf-oauth-rfc7523bis-11 §4 (replaces RFC 7523 §3 item 3, case b), §5 (replaces RFC 9126 §2 last paragraph), §6; OAuth 2.1 §2.4 (-15 and -16)  
   The YAML never says what aud a client_assertion must carry.  Required by bis: - aud MUST be exactly the RFC 8414 issuer identifier, as a string or a one-element array. - The token endpoint URL MUST NOT be used, and per §5 neither may the PAR endpoint URL. - The AS MUST reject any client JWT whose aud is not its issuer as the sole value, compared by simple string comparison. - OAuth 2.1 §2.4 makes following this a MUST, and it is the fix for the audience-injection attacks (CVE-2025-27371).  Where it is missing: - ClientAuthFields (L1191-1196), which serves /token, /par (L1591), /revoke, /introspect and /device_authorization - the PAR descriptions (L427-437, L1584-1589) - the issuer description (L1947-1950)  The old RFC 9126 §2 told the AS to ACCEPT token-endpoint and PAR-endpoint URLs as audiences, so a server written from pre-bis material is exposed.  
   *Suggested change:* Append to ClientAuthFields.client_assertion.description: 'aud MUST be this AS's issuer identifier (OAuthServerMetadata.issuer) as its sole value, either a string or a one-element array. The token endpoint, PAR or any other endpoint URL MUST NOT be used. The AS MUST reject any client-authentication JWT whose aud is not exactly its issuer (RFC 3986 §6.2.1 simple string comparison), at every endpoint that accepts it (draft-ietf-oauth-rfc7523bis §4, §5; OAuth 2.1 §2.4). Clients built to older guidance may still send the token endpoint URL, so update clients before or together with enforcement (rfc7523bis §6).' Also: - Use the one-element aud oneOf in the doc-only ClientAssertionClaims schema (validated: 2-element arrays are rejected). - Add to OAuthServerMetadata.issuer.description: 'also the only accepted aud of JWT client assertions (rfc7523bis §4)'. - Add a sentence to the /par operation description and PARRequest.description saying rfc7523bis §5 replaces RFC 9126 §2's 'accept issuer, token endpoint or PAR endpoint URL' rule.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Audience of JWT authorization grants**  
   *Reference:* draft-ietf-oauth-rfc7523bis-11 §4 (replaces RFC 7523 §3 item 3, case a), §2 (replaces RFC 7521 §5.1 Audience)  
   For grants, the client is responsible for choosing an audience that suits the AS it sends to, and the AS MAY be identified by its issuer identifier or its token endpoint URL. The RFC 7521 metamodel's example audience moves from the token endpoint URL to the issuer identifier. The YAML (L1342) names only the token endpoint URL (see the RFC 7523 incorrect entry), and the rewritten RFC 7523 §4 example (aud https://authz.example.net) is not reflected.  
   *Suggested change:* Use the corrected assertion wording from the RFC 7523 entry. Base the example on bis §4 Figure 1: {aud: 'https://authz.example.net', iss: 'https://jwt-idp.example.com', sub: 'mailto:mike@example.com', iat: 1731721541, exp: 1731725141}.  
   *Verifier: confirmed.*

3. **[LOW] Gap: Explicit typing: JOSE typ client-authentication+jwt (media type application/client-authentication+jwt)**  
   *Reference:* draft-ietf-oauth-rfc7523bis-11 §4 (adds to RFC 7523 §3.2), §5, §8.1  
   Client-authentication JWTs SHOULD carry typ client-authentication+jwt, or a more specific type defined by a profile. Servers are NOT RECOMMENDED to reject untyped JWTs, because the protection comes from the audience rule. IANA registered the media type on 2026-05-05. The YAML documents other explicit types (dpop+jwt L980, at+jwt L2517, token-introspection+jwt L352-353) but never this one. Explicit typing also helps against cross-JWT confusion (RFC 8725 §3.11; RFC 9101 §10.8).  
   *Suggested change:* Add to ClientAuthFields.client_assertion.description and ClientAssertionClaims.description: 'The JOSE header typ SHOULD be client-authentication+jwt (media type application/client-authentication+jwt, rfc7523bis §8.1). The AS accepts it and is NOT RECOMMENDED to reject assertions without an explicit typ (rfc7523bis §4).'  
   *Verifier: confirmed.*

4. **[LOW] Gap: Deprecation of SAML client authentication**  
   *Reference:* draft-ietf-oauth-rfc7523bis-11 §3 (replaces RFC 7522 §2.2 and §3 item 2)  
   The const jwt-bearer on client_assertion_type (L1199) already matches the deprecation, but the reason is never stated. If the RFC 7522 grant is ever added, its Audience rule must follow bis §3: issuer identifier, token endpoint URL or SAML Entity ID, and the AS MUST reject any other audience.  
   *Suggested change:* Document the exclusion in ClientAuthFields.client_assertion_type.description, citing rfc7523bis §3 (wording in the RFC 7522 entry).  
   *Verifier: partially correct —* Document the SAML client-authentication exclusion, citing bis §3. If the RFC 7522 grant is ever added, its Audience rule follows bis §3: the audience MAY be the issuer identifier, the token endpoint URL or a SAML Entity ID, and the AS MUST reject assertions that do not contain its own identity. Other audiences are not prohibited.

5. **[LOW] Gap: Citations and covered-spec listing**  
   *Reference:* draft-ietf-oauth-rfc7523bis-11 §1, §8.2, §8.3  
   The YAML never cites the draft, even though OAuth 2.1 normatively depends on it. IANA's Token Endpoint Authentication Methods entries (private_key_jwt, client_secret_jwt) and the four OAuth URI entries (jwt-bearer and saml2-bearer, grant and client-assertion types) now reference it (updated 2026-05-05).  
   *Suggested change:* Add '| draft-ietf-oauth-rfc7523bis (RFC Ed. queue) | 2026 | Audience hardening for JWT client auth and assertion grants |' to the Covered specifications table (L18-45). Cite it in the token_endpoint_auth_methods_supported description (L2049): 'private_key_jwt / client_secret_jwt: OIDC Core §9 as updated by rfc7523bis'. Switch to the RFC number once it is published.  
   *Verifier: partially correct —* The YAML never cites rfc7523bis. OAuth 2.1 §2.4 requires following its aud guidance, but lists it as an informative reference (§12.2 in -15 and -16). Add the covered-spec row and the token_endpoint_auth_methods_supported citation as suggested.

## Verifier corrections to the summaries above

- draft-ietf-oauth-rfc7523bis-11, prior_validation_followup: 'the draft was IESG-approved after the May-2026 audit' is false. Datatracker records IESG approval on 2026-04-30 and RFC Editor queue entry on 2026-05-04. Every rfc-validation file and the synthesis are dated 'Audit date: 2026-05-10'. The approval came before the audit; the audit missed the draft. The synthesis itself discloses that its agents worked largely from training-data knowledge. OAuth 2.1 -15 (2 March 2026, vendored) §2.4 already contained the MUST that points to the draft.
- RFC 7523, prior_validation_followup: 'NEW since that audit: rfc7523bis-11 (IESG-approved 2026-04-30)...' has the same chronology error. The -11 revision (2026-04-28) and the IESG approval (2026-04-30) both predate the 2026-05-10 audit. The issuer-as-audience requirement was missed by the audit, not introduced after it.
- cluster_notes: 'The two saml2-bearer URNs, which are on the IANA absence list, are the only IANA entries from this cluster missing' is incomplete. The YAML also lacks application/client-authentication+jwt, which bis §8.1 registered in the IANA Media Types registry (record dated 2026-05-05). The IANA absence list only compared oauth-parameters, jwt, jose, well-known-uris and http-authschemes, not media types.
- cluster_notes (verification): 'the current TokenRequest accepts three bad bodies: jwt-bearer with client_assertion ...'. A jwt-bearer body with a client_assertion is RFC-valid, not bad. The defect is that it validates only as untyped extra properties, and on that branch client_assertion_type is not constrained at all: a saml2-bearer value is accepted for jwt-bearer but rejected for every other grant (re-verified with jsonschema 4.26).
- RFC 7522, summary: '...and an XML signature (RSA-SHA256 mandatory to implement)'. RFC 7522 §3 item 9 requires the Assertion to be 'digitally signed or have a Message Authentication Code (MAC) applied by the issuer'. RSA-SHA256 is only the mandatory-to-implement XML signature algorithm (§5).
- RFC 7521, notes: 'rfc7523bis §2 replaces the §5.1 Audience description, making the issuer identifier the example audience' is correct, but incomplete. The replacement text also drops §5.1's Simple String Comparison requirement for Audience; for JWTs the rule survives in RFC 7523 §3 item 3 as replaced by bis §4. bis §3's replacement of RFC 7522 §3 item 2 likewise drops it.
