# Sender-constrained tokens — RFC 8705, 9449, 7800, 9278, 9440, 9421

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 8705](#rfc-8705-oauth-20-mutual-tls-client-authentication-and-certificate-bound-access-tokens) | February 2020 | Proposed Standard | mostly | 1 | 3 | 7 |
| [RFC 9449](#rfc-9449-oauth-20-demonstrating-proof-of-possession-dpop) | September 2023 | Proposed Standard | mostly | 1 | 5 | 14 |
| [RFC 7800](#rfc-7800-proof-of-possession-key-semantics-for-json-web-tokens-jwts) | April 2016 | Proposed Standard | partial (verifier corrected from mostly) | 0 | 0 | 6 |
| [RFC 9278](#rfc-9278-jwk-thumbprint-uri) | August 2022 | Proposed Standard | none | 0 | 0 | 1 |
| [RFC 9440](#rfc-9440-client-cert-http-header-field) | July 2023 | Informational | none | 0 | 0 | 2 |
| [RFC 9421](#rfc-9421-http-message-signatures) | February 2024 | Proposed Standard | not-applicable | 0 | 0 | 0 |

**Cluster notes.** Cluster "pop" (proof-of-possession).

Vendoring: RFC 8705, RFC 9449, RFC 7800 and RFC 9278 are vendored and byte-identical to rfc-editor.org. RFC 9440 and RFC 9421 come from the httpbis WG and are not vendored.

What the YAML already models well (the AS-side PoP surface):
- the mTLS client-auth methods and the mutualTLS security scheme
- both RFC 8705 AS metadata fields
- cnf.x5t#S256 and cnf.jkt, in both JWT access tokens and introspection responses
- the DPoP header on /token, /par and /userinfo
- DPoP-Nonce on the right 2xx and 4xx responses
- the use_dpop_nonce and invalid_dpop_proof error codes
- the Authorization: DPoP scheme
- a combined Bearer+DPoP WWW-Authenticate challenge with algs
- dpop_jkt at /authorize and in PAR
- dpop_signing_alg_values_supported

Remaining problems:
1. HIGH. /userinfo is the only protected resource in the spec, and it does not enforce PoP:
   - no RFC 9449 §7.2 downgrade rule (a DPoP-bound token sent as Bearer MUST be rejected)
   - no RFC 8705 §3 certificate check, and no mTLS security alternative
2. MEDIUM. All PoP client-registration metadata is missing because the YAML has no RFC 7591 ClientMetadata schema and no /register surface. Missing fields: tls_client_auth_subject_dn, _san_dns, _san_uri, _san_ip, _san_email; the client-side tls_client_certificate_bound_access_tokens; dpop_bound_access_tokens. Fix this together with the DCR cluster.
3. MEDIUM. Server-side DPoP and mTLS rules are undocumented:
   - DPoP proof JWT structure and §4.3 checks
   - dpop_jkt verification and the PAR dual mechanism (§10, §10.1)
   - binding public clients' refresh tokens to the DPoP key (§5)
   - introspection token_type MUST be DPoP (§6.2)
   - client_id REQUIRED with mTLS (RFC 8705 §2)
4. Prose errors:
   - TokenResponse.token_type implies Bearer means unbound, but mTLS-bound tokens use Bearer
   - DPoPHeader is called required on /par, where it is optional
   - DPoP-Nonce is said to be absent on other errors
   - the refresh-token text implies DPoP-binding confidential clients' refresh tokens
   - several RFC 9449 section citations are wrong

Prior RFC 9449 audit (May 2026, 15 findings): 9 fixed, 5 open, 1 withdrawn. M8 was wrong: DPoP is not client authentication (§3), so the dpop security scheme does not belong on /token or /par.

IANA cross-check: 9 registered values from this cluster are absent:
- 5 tls_client_auth_* client metadata fields (RFC 8705)
- dpop_bound_access_tokens (RFC 9449)
- the cnf methods jwe and jku (RFC 7800)
- urn:ietf:params:oauth:jwk-thumbprint (RFC 9278)

Two more are also absent:
- the client-metadata tls_client_certificate_bound_access_tokens (RFC 8705 §3.4). The whole-token diff missed it because the same name exists as AS metadata.
- FAPI 2.0's client metadata use_mtls_endpoint_aliases.

Recommend vendoring RFC 7638 (JWK Thumbprint). It is the basis of jkt, dpop_jkt and RFC 9278, the YAML cites it at L2582, and it is not vendored. *(Update 2026-10-11: now vendored.)*

Errata, all checked 2026-10-10:
- RFC 9449 #7646: Verified, editorial ("authentication server" → "authorization server" in §4.2).
- RFC 7800 #6187: Verified, editorial (DOI typo).
- RFC 9421 #8103: Verified, technical (§7.5.3 @signature-input → @signature-params). #8102: Verified, editorial.
- None for RFC 8705, 9278 or 9440. None of the errata changes the YAML.

Drafts: no OAuth RFC or OAuth WG draft profiles RFC 9421. draft-richer-oauth-httpsig-03 is an individual draft. draft-ietf-oauth-attestation-based-client-auth-11 (in WG Last Call) uses cnf.jwk and has a DPoP "combined mode".

OAuth 2.1-16:
- §1.4.3: AS and RS SHOULD sender-constrain tokens with DPoP or mTLS.
- §4.3.1: the AS MUST detect refresh-token replay for public clients, by sender-constraining or by rotation.
- §2.4: asymmetric client authentication such as mTLS is RECOMMENDED.

## RFC 8705 OAuth 2.0 Mutual-TLS Client Authentication and Certificate-Bound Access Tokens

*February 2020 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** Defines two ways for a client to authenticate to the AS with an X.509 client certificate over mutual TLS. With tls_client_auth (PKI), the AS validates the certificate chain and matches exactly one registered subject DN or SAN. With self_signed_tls_client_auth, the certificate must match one registered in the client's jwks or jwks_uri. Separately, the AS can certificate-bind access tokens by putting the certificate's SHA-256 thumbprint in cnf.x5t#S256, either in a JWT access token or in the introspection response. A resource server then honors the token only over mTLS with that same certificate. The RFC also adds AS metadata (tls_client_certificate_bound_access_tokens, mtls_endpoint_aliases) and client metadata (the tls_client_auth_* subject fields and tls_client_certificate_bound_access_tokens).

**Why it was created.** Shared client secrets are weak credentials, and bearer tokens can be replayed by anyone who steals them. High-security deployments (for example open banking and FAPI) already used TLS client certificates. The OAuth WG standardized certificate-based client authentication and holder-of-key access tokens at the transport layer because, at the time, Token Binding had no practical platform support (Appendix B).

<details><summary>Already modeled in the YAML (9)</summary>

- Token-endpoint auth method values tls_client_auth and self_signed_tls_client_auth (§2.1.1, §2.2.1): OAuthServerMetadata.token_endpoint_auth_methods_supported enum, L2037-2049 (values at L2047-2048)
- mTLS client authentication (§2): components.securitySchemes.mtls (type: mutualTLS), L2676-2681. Offered on /token L267, /revoke L309, /introspect L362, /device_authorization L416 and /par L475
- AS metadata tls_client_certificate_bound_access_tokens, boolean, default false (§3.3): OAuthServerMetadata, L2192-2198
- AS metadata mtls_endpoint_aliases (§5): OAuthServerMetadata.mtls_endpoint_aliases, L1997-2013. Lists the token, revocation, introspection, device_authorization, PAR, userinfo and registration endpoints, plus additionalProperties of format uri
- cnf member x5t#S256 in JWT access tokens (§3.1): components.schemas.Confirmation['x5t#S256'] L2584-2586, used by JWTAccessTokenClaims.cnf L2568-2573
- cnf as a top-level introspection member (§3.2, §9.4): IntrospectionResponse.cnf → Confirmation, L1748-1753
- Error codes used by RFC 8705: invalid_client for failed mTLS client authentication (§2) and invalid_token for a certificate mismatch at the resource (§3). ErrorResponse.error enum L1480 and L1490
- Resource-side counterpart defined by RFC 9728 §2: ProtectedResourceMetadata.tls_client_certificate_bound_access_tokens L2320-2322
- Covered-specifications table row (L31) and the mTLS mention in the /token client-authentication text (L229-230)

</details>

**Follow-up on the May-2026 validation notes.** There is no references/rfc-validation file for RFC 8705. The May-2026 audit synthesis (references/audit/rfc-audit-synthesis.md L116-118) asked only for the AS metadata fields mtls_endpoint_aliases and tls_client_certificate_bound_access_tokens. Both are now present (L1997-2013, L2192-2198). Client-registration metadata, the client_id MUST and the resource-side certificate check were never audited and are still open (gaps 1-4).

**Notes.** - The vendored text is byte-identical to rfc-editor.org.
- No errata exist (rfc-editor.org/errata/rfc8705, checked 2026-10-10).
- The IANA absence list attributes 5 missing values to this RFC: tls_client_auth_subject_dn, _san_dns, _san_uri, _san_ip, _san_email. The client-metadata variant of tls_client_certificate_bound_access_tokens is also missing; the name collision hides it.
- FAPI 2.0's client metadata use_mtls_endpoint_aliases (IANA-registered; it extends §5) is absent too, but it is not part of this RFC.
- §6.5 puts TLS termination out of scope; see the RFC 9440 entry and RFC 9700 §4.13.
- OAuth 2.1-16 §1.4.3 says AS and RS SHOULD sender-constrain tokens (DPoP or mTLS). §2.4 RECOMMENDS asymmetric client authentication such as mTLS.

### Findings (1 high · 3 medium · 7 low)

1. **[HIGH] Gap: Certificate-bound access tokens at the AS-hosted protected resource /userinfo (mTLS with the same certificate, checked against cnf.x5t#S256)**  
   *Reference:* RFC 8705 §3  
   §3 says requests that present a certificate-bound token MUST use mTLS with the same certificate that was used at the token endpoint. The protected resource MUST get the client certificate from its TLS layer and MUST verify it matches the token's binding, rejecting a mismatch with 401 invalid_token. In the YAML, /userinfo GET (L516-518) and POST (L566-568) offer only bearerAuth or dpop, and ProtectedResourceError (L1091-1107) describes only Bearer and DPoP. An AS generated from the YAML that advertises tls_client_certificate_bound_access_tokens: true (L2193) would accept a certificate-bound token at /userinfo as a plain bearer token, without checking the certificate. This applies only when the AS issues certificate-bound tokens.  
   *Suggested change:* Add an AND-combined alternative to both /userinfo operations: `security: [{bearerAuth: []}, {dpop: []}, {bearerAuth: [], mtls: []}]`. Extend ProtectedResourceError.description (or bearerAuth.description) with: 'If the access token is certificate-bound (cnf.x5t#S256), the request MUST arrive over mTLS. The resource compares the base64url SHA-256 of the DER client certificate with cnf.x5t#S256 and rejects a mismatch with 401 `WWW-Authenticate: Bearer error="invalid_token"` (RFC 8705 §3).' Also note that clients use mtls_endpoint_aliases.userinfo_endpoint when it is present.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: PKI-method client metadata: tls_client_auth_subject_dn, tls_client_auth_san_dns, tls_client_auth_san_uri, tls_client_auth_san_ip, tls_client_auth_san_email**  
   *Reference:* RFC 8705 §2.1.2, §9.5  
   None of these five IANA-registered names appears in the YAML (the IANA absence list confirms it). The YAML has no client-metadata schema and no /register operation; AS metadata has only the registration_endpoint URL (L1965-1968). A tls_client_auth client MUST register exactly one of these subject values (§2.1.2), yet a server built from the YAML has no data model for that expected subject, even though the YAML advertises tls_client_auth (L2047). Comparison rules: the subject DN is an RFC 4514 string compared with a predictable rule such as distinguishedNameMatch (§2.1), and san_ip is compared in binary form (RFC 5952 §8).  
   *Suggested change:* Add components.schemas.ClientMetadata, shared with the RFC 7591/7592 work, with these string properties, each citing RFC 8705 §2.1.2: tls_client_auth_subject_dn, tls_client_auth_san_dns, tls_client_auth_san_uri (format: uri), tls_client_auth_san_ip, tls_client_auth_san_email (format: email). Add the exactly-one rule: `if: {required: [token_endpoint_auth_method], properties: {token_endpoint_auth_method: {const: tls_client_auth}}}` with `then: {oneOf: [{required: [tls_client_auth_subject_dn]}, {required: [tls_client_auth_san_dns]}, {required: [tls_client_auth_san_uri]}, {required: [tls_client_auth_san_ip]}, {required: [tls_client_auth_san_email]}]}`.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: client_id REQUIRED on every mTLS-authenticated request; invalid_client when the certificate is missing or does not match**  
   *Reference:* RFC 8705 §2  
   §2 says that on every request to the AS that uses mTLS client authentication, the client MUST include client_id. If no certificate is presented, or it does not match the client, the AS returns invalid_client (RFC 6749 §5.2). In the YAML, ClientAuthFields.client_id (L1178-1184) is REQUIRED only for public clients and OPTIONAL with client_assertion, and securitySchemes.mtls (L2678-2681) says nothing about it. The token, revocation, introspection and device-authorization request schemas do not require client_id, so a generated server would accept mTLS requests without it.  
   *Suggested change:* Append to ClientAuthFields.client_id.description: 'REQUIRED when the client authenticates with mutual TLS (tls_client_auth or self_signed_tls_client_auth), RFC 8705 §2.' Add the same rule to components.securitySchemes.mtls.description, plus: 'If the certificate is missing or does not match the client registered for client_id, return invalid_client (RFC 6749 §5.2). mTLS failures carry no WWW-Authenticate challenge.'  
   *Verifier: confirmed.*

4. **[MEDIUM] Incorrect: L1420-1427 components.schemas.TokenResponse.properties.token_type.description**  
   *Reference:* RFC 8705 §3 (§9 registers no access token type); RFC 9449 §5  
   The text says "`Bearer` (RFC 6750) for unbound tokens, `DPoP` (RFC 9449) for sender-constrained tokens". RFC 8705 certificate-bound tokens are sender-constrained but are still presented with the RFC 6750 Bearer scheme over mTLS; RFC 8705 registers no new access-token type, so their token_type is Bearer. An implementer following the text could return token_type=DPoP for mTLS-bound tokens, and clients would then send `Authorization: DPoP` without a proof. Or they could assume every Bearer token is unbound.  
   *Suggested change:* Reword to: "`Bearer` (RFC 6750): bearer tokens, including mTLS certificate-bound tokens, which are presented with the Bearer scheme over mutual TLS (RFC 8705 §3). `DPoP` (RFC 9449 §5): DPoP-bound tokens. `N_A`: token exchange (RFC 8693 §2.2.1)."  
   *Verifier: confirmed.*

5. **[LOW] Gap: Client metadata tls_client_certificate_bound_access_tokens (the client intends to use certificate-bound tokens)**  
   *Reference:* RFC 8705 §3.4, §9.5  
   This name is modeled only as AS metadata (L2193) and protected-resource metadata (L2320). The client-registration boolean (default false) is missing, and the IANA whole-token diff does not flag it because of the name collision. §3.4 also says that if such a client calls /token without mTLS, the AS may either return an error or issue an unbound token. The YAML does not document that choice.  
   *Suggested change:* In ClientMetadata add `tls_client_certificate_bound_access_tokens: {type: boolean, default: false, description: 'Client intends to use mTLS certificate-bound access tokens (RFC 8705 §3.4). If such a client calls /token without mTLS, the AS may return an error or issue an unbound token.'}`.  
   *Verifier: confirmed.*

6. **[LOW] Gap: mtls_endpoint_aliases usage rules and the alias host**  
   *Reference:* RFC 8705 §5  
   The description (L1999-2002) leaves out the §5 rules. A client that intends to do mTLS MUST use the alias URL in preference to the top-level endpoint of the same name. Endpoints missing from the aliases fall back to the top-level ones, and alias members that are not endpoints the client calls directly SHOULD be ignored. The only server entry is https://{issuer} (L77-86), so the separate mTLS host that aliases usually point to cannot be expressed. backchannel_authentication_endpoint (CIBA, which RFC 8705 §1 names as an endpoint that uses client authentication) is allowed only through additionalProperties.  
   *Suggested change:* Rewrite mtls_endpoint_aliases.description to quote the §5 MUST and SHOULD rules, and add `backchannel_authentication_endpoint: {type: string, format: uri}` to its properties. Optionally add a path-level `servers` entry, for example `- url: 'https://{mtls_host}'` with description 'mTLS endpoint alias host (RFC 8705 §5)', on /token, /revoke, /introspect, /par, /device_authorization and /userinfo.  
   *Verifier: confirmed.*

7. **[LOW] Gap: Syntax of the x5t#S256 value**  
   *Reference:* RFC 8705 §3.1  
   The value is the base64url SHA-256 of the DER certificate. It MUST omit '=' padding and MUST NOT contain line breaks or whitespace, so it is always 43 characters. Confirmation['x5t#S256'] (L2584-2586) is an unconstrained string.  
   *Suggested change:* Add `pattern: '^[A-Za-z0-9_-]{43}$'` and the description 'base64url (unpadded) SHA-256 of the DER-encoded client certificate (RFC 8705 §3.1)'.  
   *Verifier: confirmed.*

8. **[LOW] Gap: Binding public clients' refresh tokens to the certificate**  
   *Reference:* RFC 8705 §4 (also §7.1)  
   §4: when the AS issues certificate-bound tokens to a public client together with a refresh token, it SHOULD bind the refresh token to that certificate and check the binding on refresh. RefreshTokenRequest (L1285-1289) and TokenResponse.refresh_token (L1433-1439) name only '(DPoP)' as the sender-constraining option. OAuth 2.1-16 §4.3.1 and RFC 9700 §4.14.2 list both DPoP and mTLS. See RFC 9449 incorrect item I5 for the confidential-client part of the same text.  
   *Suggested change:* In both descriptions replace '(DPoP)' with '(DPoP per RFC 9449 §5, or mTLS certificate binding per RFC 8705 §4)'.  
   *Verifier: confirmed.*

9. **[LOW] Gap: Binding rules and trust model of the two mTLS methods (securitySchemes.mtls description)**  
   *Reference:* RFC 8705 §2.1, §2.2, §2.2.2, §4, §7.4  
   The mtls description (L2678-2681) names the two methods but not how the AS binds a certificate to a client. PKI method: a validated chain plus exactly one registered subject DN or SAN, accepting only a limited set of trust anchors (SHOULD, §7.4). Self-signed method: the presented certificate must match one registered through the client's jwks (x5c member) or jwks_uri (§2.2.2). The description also does not say that mTLS can be used only to bind tokens, without authenticating the client, for example by public clients (§1, §4).  
   *Suggested change:* Expand components.securitySchemes.mtls.description with those three points. Reference JWK.x5c (L1866-1873), and the client jwks/jwks_uri metadata once ClientMetadata exists.  
   *Verifier: confirmed.*

10. **[LOW] Gap: Once /userinfo (the AS-hosted resource) accepts certificate-bound tokens, its TLS stack should request client certificates without validating the CA chain** — *found by the verifier*  
   *Reference:* RFC 8705 §6.2 (also §4)  
   Once /userinfo (the AS-hosted resource) accepts certificate-bound tokens, its TLS stack should request client certificates without validating the CA chain. mTLS is purely proof of possession there, and public clients use self-signed certificates. Nothing in the YAML says this, so an implementer reusing the token endpoint's PKI trust store would reject valid public clients.  
   *Suggested change:* When adding the mTLS alternative to /userinfo (see RFC 8705 gap G4), note in its description that the resource requests a client certificate but does not validate its chain. It only compares the SHA-256 thumbprint with cnf.x5t#S256 (RFC 8705 §6.2).

11. **[LOW] Gap: /introspect is a second OAuth-protected endpoint: it accepts the resource server's own access token through bearerAuth** — *found by the verifier*  
   *Reference:* RFC 8705 §3 (cf. RFC 9449 §7.2)  
   /introspect is a second OAuth-protected endpoint: it accepts the resource server's own access token through bearerAuth. If that caller token is certificate-bound, §3 requires the AS to verify it over mTLS with the same certificate. The security alternatives are OR-only (clientSecretBasic | mtls | bearerAuth), so they cannot express 'bearer AND mtls', and the YAML does not document the check. This also makes the cluster note '/userinfo is the only protected resource in the spec' slightly inaccurate.  
   *Suggested change:* Either add an AND-combined alternative {bearerAuth: [], mtls: []} on /introspect, or state in the /introspect description that certificate-bound or DPoP-bound access tokens are not accepted as the caller credential there and that callers must use client authentication instead.

## RFC 9449 OAuth 2.0 Demonstrating Proof of Possession (DPoP)

*September 2023 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** DPoP is proof-of-possession at the application layer. The client holds a key pair and attaches a fresh signed JWT, the DPoP proof, in a DPoP header on each request. The proof has typ dpop+jwt and an asymmetric alg, carries the public jwk, and contains jti, htm, htu and iat, plus ath and nonce when required. The AS binds the access token it issues (token_type=DPoP), and a public client's refresh token, to the key's JWK thumbprint (cnf.jkt). A resource server accepts such a token only as `Authorization: DPoP <token>` together with a matching proof. The RFC also defines server-supplied nonces (DPoP-Nonce header, use_dpop_nonce error), the invalid_dpop_proof error, authorization-code binding (dpop_jkt), dpop_signing_alg_values_supported AS metadata and dpop_bound_access_tokens client metadata.

**Why it was created.** Anyone who obtains a bearer token can use it, whether it leaked through logs, was stolen by XSS, or was replayed by a malicious or compromised resource server. mTLS binding works poorly for browser-based apps (SPAs) and many native apps, because user agents handle client certificates badly, and HTTP Token Binding never shipped. DPoP provides sender-constraining at the application layer that works from JavaScript and mobile apps, ideally with non-extractable keys, and needs no TLS changes.

<details><summary>Already modeled in the YAML (13)</summary>

- DPoP request header (§4.1, §12.8): components.parameters.DPoPHeader L972-984. Used on /token L240, /par L442, /userinfo GET L495 and POST L531. The description (L976-982) lists typ=dpop+jwt, alg, jwk, jti, htm, htu, iat, ath and nonce
- DPoP-Nonce response header (§8, §9, §12.8): components.headers.DPoPNonce L1051-1057. Present on /token 200 L255-256, /par 201 L457-458, OAuthErrorWithDPoPNonce (/token 400 L262, /par 400 L464) and ProtectedResourceError (/userinfo 401/403 L512-515, L562-565)
- Error codes invalid_dpop_proof and use_dpop_nonce (§5, §7.1, §8, §12.2): ErrorResponse.error enum L1507-1509
- The AS's HTTP 400 use_dpop_nonce response with a DPoP-Nonce header (§8): components.responses.OAuthErrorWithDPoPNonce L1074-1090
- token_type DPoP (§5, §12.1): example value in TokenResponse.token_type L1420-1427; mentioned in IntrospectionResponse.token_type L1719-1721
- DPoP authentication scheme, `Authorization: DPoP <token>` plus a second DPoP proof header (§7.1, §12.4): securitySchemes.dpop (apiKey, header Authorization) L2648-2660. Offered next to bearerAuth on /userinfo GET L518 and POST L568, the §7.2 dual-scheme pattern
- WWW-Authenticate DPoP challenge with the algs parameter and the §7.2 rules for placing errors in a combined Bearer+DPoP challenge: components.headers.WWWAuthenticateBearerDPoP L1000-1025
- dpop_jkt authorization request parameter (§10, §12.3): components.parameters.DPoPJKT L962-970, used on /authorize L157-158; PARRequest.dpop_jkt L1645-1647 (§10.1)
- AS metadata dpop_signing_alg_values_supported (§5.1, §12.9): OAuthServerMetadata L2187-2190
- cnf.jkt confirmation method (§6.1, §6.2, §12.6): Confirmation.jkt L2579-2583, used by JWTAccessTokenClaims.cnf L2568-2573 and IntrospectionResponse.cnf L1748-1753
- Resource-side counterparts defined by RFC 9728 §2: ProtectedResourceMetadata.dpop_signing_alg_values_supported L2326-2328 and dpop_bound_access_tokens_required L2329-2332
- Sender-constrained refresh tokens for public clients, in OAuth 2.1 / RFC 9700 wording: RefreshTokenRequest L1285-1289 and TokenResponse.refresh_token L1433-1439
- Modeling note that the proof JWT is not modeled as a schema (L63-64); covered-specifications table row (L38)

</details>

**Follow-up on the May-2026 validation notes.** The May-2026 audit (references/rfc-validation/9449-dpop.md) reported 11 MISSING and 4 WRONG, 15 findings in total.

Fixed (9):
- M2: cnf.jkt in introspection (L1748-1753).
- M3: dpop_jkt at /authorize (L158) and in PARRequest (L1645).
- M4: DPoPNonce header (L1051) on /token, /par, error and resource-server responses.
- M6 and M7: WWWAuthenticateBearerDPoP with algs (L1000-1025).
- M11: OAuthErrorWithDPoPNonce (L1074).
- W1: the dpop scheme is now apiKey (L2648).
- W2: DPoP-Nonce sits beside Cache-Control on /token 200 (L251-256).
- W3: conditional wording added (L977). It overreaches for /par; see incorrect item I1.

Still open (5):
- M1: no proof JWT schema; only prose at L976-982.
- M5: dpop_bound_access_tokens client metadata.
- M9: the §5 refresh-token binding rule is only partly covered by the OAuth 2.1 wording.
- M10: application/dpop+jwt is not mentioned.
- W4: DPoPHeader has no pattern. M4's suggested nonce pattern was also never added.

Withdrawn (1): M8 was mistaken. DPoP is not client authentication (§3), and the dpop scheme models `Authorization: DPoP <AT>`, which is never sent to /token or /par. The DPoPHeader parameter used there is correct.

Also, W1's premise was overstated: OpenAPI 3.1 allows `type: http, scheme: DPoP`, because DPoP is registered at IANA (§12.4). The apiKey workaround is acceptable.

**Notes.** - Verified Erratum 7646 (editorial) fixes 'authentication server' to 'authorization server' in §4.2. No other errata.
- The YAML correctly keeps DPoP out of client authentication (§3) and out of /introspect, /revoke and /device_authorization.
- Related WG work: draft-ietf-oauth-attestation-based-client-auth-11 (in WG Last Call) defines a DPoP 'combined mode' with the token-endpoint auth method attest_jwt_client_auth_dpop. draft-ietf-oauth-first-party-apps-04 and draft-ietf-oauth-identity-assertion-authz-grant-04 also profile DPoP.
- RFC 7638 (JWK Thumbprint), the basis of jkt and dpop_jkt, is cited in the YAML (L2582) but not vendored. *(Update 2026-10-11: now vendored.)*

### Findings (1 high · 5 medium · 14 low)

1. **[HIGH] Gap: Downgrade protection: a DPoP-bound access token presented with the Bearer scheme MUST be rejected**  
   *Reference:* RFC 9449 §7.2 (with §7.1, §6)  
   /userinfo accepts bearerAuth or dpop (L516-518, L566-568), and ProtectedResourceError says it accepts both (L1092-1094). The YAML never states that a resource supporting both schemes MUST reject a DPoP-bound token received as a Bearer token. The POST form-body access_token (L539-545) is also a Bearer channel. A server generated from the YAML would therefore accept a stolen DPoP-bound token sent as `Authorization: Bearer` with no proof, which defeats DPoP.  
   *Suggested change:* Add to securitySchemes.bearerAuth.description and ProtectedResourceError.description: 'A resource that supports both schemes MUST reject a DPoP-bound access token (cnf.jkt present, or introspection token_type=DPoP) presented with the Bearer scheme or in the form body (RFC 9449 §7.2). With the DPoP scheme it MUST check the proof per §4.3 and the key binding per §6 (§7.1). Respond 401 with `WWW-Authenticate: Bearer error="invalid_token", DPoP algs="..."`.'  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Client metadata dpop_bound_access_tokens**  
   *Reference:* RFC 9449 §5.2, §12.10  
   This field appears nowhere in the YAML (the IANA absence list confirms it), and there is no client-metadata schema to hold it. §5.2: when it is true, the AS MUST reject that client's token requests that lack a DPoP header, so a generated server cannot enforce the rule. This was prior finding M5 and is still open.  
   *Suggested change:* Add `dpop_bound_access_tokens: {type: boolean, default: false, description: 'The client always uses DPoP for token requests. When true, the AS MUST reject token requests from this client that have no DPoP header (RFC 9449 §5.2).'}` to the ClientMetadata schema created for RFC 7591. Repeat the rule in the /token and DPoPHeader descriptions. RFC 9449 does not specify which error code to use.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: Structure of the DPoP proof JWT (decoded header and claims) and the rules for checking it**  
   *Reference:* RFC 9449 §4.1, §4.2, §4.3, §11.1, §11.5, §11.6  
   Only prose exists (DPoPHeader L976-982; L63-64 says the proof is deliberately not modeled), and DPoPHeader.schema is a bare string (L983-984). These rules that decide whether a proof is valid are missing: - typ MUST be dpop+jwt. - alg MUST be an asymmetric algorithm, never none or a MAC. - jwk MUST NOT contain a private key. - jti MUST be unique (for example, at least 96 random bits or a UUIDv4). - htu has no query or fragment and SHOULD be compared after RFC 3986 normalization. - ath is the base64url SHA-256 of the access token. - At most one DPoP header may be sent. - Proofs are accepted only for a limited time, with jti replay tracking (§11.1 MUST). - An invalid proof gets invalid_dpop_proof: HTTP 400 at the AS (§5), a 401 challenge at the RS (§7.1). The proof is a JWS, so the generic JWT schema (L2434-2441), which also accepts 5-segment JWEs, cannot be reused as is. Prior findings M1 and W4 are still open.  
   *Suggested change:* Add two documentation-only schemas, following the project's decoded-payload convention (IDTokenClaims, JWTAccessTokenClaims). - DPoPProofHeader: {required: [typ, alg, jwk]; typ: {const: 'dpop+jwt'}; alg: {type: string, not: {enum: [none, HS256, HS384, HS512]}}; jwk: {$ref: '#/components/schemas/JWK'} (public members only)}. - DPoPProofClaims: {required: [jti, htm, htu, iat]; jti: string; htm: string; htu: {type: string, format: uri} (no query or fragment); iat: {$ref: NumericDate}; ath: {type: string, pattern: '^[A-Za-z0-9_-]{43}$'} (REQUIRED at resource servers); nonce: {type: string, pattern: '^[\x21\x23-\x5B\x5D-\x7E]+$'} (REQUIRED once a DPoP-Nonce was supplied)}. Set DPoPHeader.schema to `{type: string, pattern: '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$'}`. In its description, reference both schemas and list the §4.3 checks.  
   *Verifier: partially correct —* Missing structure and checks (§4.2, §4.3, §11.5, §11.6) as listed. One correction: proofs MUST be accepted only within a limited time window (§11.1 MUST), but per-URI jti replay tracking is optional ('servers can store the jti value'), not a MUST.

4. **[MEDIUM] Gap: token_type in introspection responses for DPoP-bound tokens**  
   *Reference:* RFC 9449 §6.2  
   §6.2: if the introspection response for a DPoP-bound token includes token_type, it MUST be DPoP. Also, the resource server sends no DPoP proof to /introspect and the AS does not validate the binding there; the RS checks cnf.jkt itself. IntrospectionResponse.token_type (L1719-1721) says only 'Typically Bearer or DPoP', so an implementation following it could return Bearer for a DPoP-bound token.  
   *Suggested change:* Change the description to: 'For a DPoP-bound token, this MUST be `DPoP` when present (RFC 9449 §6.2). The binding is conveyed in cnf.jkt and verified by the resource server; no DPoP proof is sent to /introspect.'  
   *Verifier: confirmed.*

5. **[MEDIUM] Gap: dpop_jkt processing rules and value format**  
   *Reference:* RFC 9449 §10, §10.1, §11.9  
   The YAML defines dpop_jkt (L962-970, L1645-1647) but none of its server rules: - At the token request, the AS MUST compute the JWK thumbprint of the DPoP proof key and reject the request if it does not match dpop_jkt (§10). - An AS that supports PAR and DPoP MUST support both binding mechanisms: dpop_jkt in the PAR body, or a DPoP header on the PAR request (§10.1). - A DPoP header on the PAR request binds the code as if dpop_jkt had been sent (§10.1). - If both are present and do not match, the AS MUST reject the PAR request (§10.1). AuthorizationCodeTokenRequest (L1235-1266) and the /par description (L427-437) are silent; the audit synthesis also asked for a 'dpop_jkt reflection note' on AuthorizationCodeTokenRequest. The value is the bare base64url SHA-256 thumbprint from RFC 7638 (43 characters), but the schema is an unconstrained string.  
   *Suggested change:* In DPoPJKT.schema add `pattern: '^[A-Za-z0-9_-]{43}$'`. In its description add the §10 rule (the token request MUST carry a DPoP proof whose key thumbprint equals dpop_jkt, otherwise reject) and note that the value is the bare thumbprint, not an RFC 9278 URN. In PARRequest.dpop_jkt and the /par description add the §10.1 rules: both mechanisms MUST be supported, a DPoP header counts as dpop_jkt, and a mismatch MUST be rejected. In AuthorizationCodeTokenRequest.description note that the code-to-key binding is checked at the token request.  
   *Verifier: confirmed.*

6. **[MEDIUM] Gap: Binding public clients' refresh tokens to the DPoP key; Bearer access token with a DPoP-bound refresh token**  
   *Reference:* RFC 9449 §5  
   §5: when an AS that supports DPoP issues a refresh token to a public client that presented a valid DPoP proof, the refresh token MUST be bound to that key. The binding MUST be checked on every refresh, so the client MUST present a proof for the same key. The AS MAY still issue an access token that is not DPoP-bound (token_type Bearer); then only the refresh token is bound. The YAML (L1285-1289, L1433-1439) offers OAuth 2.1's 'sender-constrained or rotated' choice. That would let a DPoP-capable AS rotate refresh tokens without binding them, which violates the RFC 9449 MUST. The Bearer-access-token with bound-refresh-token pattern is not mentioned. Prior finding M9 is only partly addressed.  
   *Suggested change:* Add to RefreshTokenRequest.description: 'If the AS supports DPoP and the public client presented a valid DPoP proof when this refresh token was issued, the refresh token MUST be bound to that key. Every refresh request MUST then carry a DPoP proof for the same key, otherwise the AS rejects it (RFC 9449 §5). Refresh tokens issued to confidential clients are not bound to the key.' Add to TokenResponse.token_type: 'The AS may return Bearer even when a DPoP proof was sent (RFC 9449 §5).'  
   *Verifier: confirmed.*

7. **[LOW] Gap: DPoP-Nonce syntax and server rules; nonce and cacheability on resource-server responses**  
   *Reference:* RFC 9449 §8, §8.1, §8.2, §9, §11.3  
   DPoPNonce.schema (L1056-1057) does not apply the nonce syntax 1*NQCHAR (§8.1). Its description omits three rules: - nonce values MUST be unpredictable; - a response MUST NOT carry more than one DPoP-Nonce header; - once a nonce has been provided, the server MUST NOT accept proofs without one (§11.3). Responses that carry DPoP-Nonce should be uncacheable (§8.2), but ProtectedResourceError (L1099-1103) has no Cache-Control. /userinfo 200 (L497-511, L547-561) can neither supply a fresh resource-server nonce (§9 reuses the §8.2 mechanism) nor send Cache-Control: no-store. The pattern the prior audit suggested under M4 was never added.  
   *Suggested change:* DPoPNonce.schema: add `pattern: '^[\x21\x23-\x5B\x5D-\x7E]+$'` and put the three MUST rules in its description. Add `DPoP-Nonce: {$ref: '#/components/headers/DPoPNonce'}` and `Cache-Control: {$ref: '#/components/headers/CacheControlNoStore'}` to the /userinfo GET and POST 200 responses. Add Cache-Control to ProtectedResourceError.  
   *Verifier: confirmed.*

8. **[LOW] Gap: DPoP-scheme challenge examples and the 400 for ambiguous credentials**  
   *Reference:* RFC 9449 §7.1 (Figs 15-16), §7.2 (Fig 19), §9 (Fig 24)  
   The WWWAuthenticateBearerDPoP examples (L1021-1025) put error information only on the Bearer scheme. There is no example of a DPoP-scheme error: invalid_token for a key-binding failure, use_dpop_nonce from the resource server, or invalid_dpop_proof. The realm and scope parameters are not mentioned, and neither is the rule that the DPoP scheme MUST NOT be used with Proxy-Authenticate or Proxy-Authorization. /userinfo has no 400 response for a request that uses several token-presentation methods at once (Fig 19).  
   *Suggested change:* Add these examples: 'Bearer, DPoP error="invalid_token", error_description="Invalid DPoP key binding", algs="ES256"', 'Bearer, DPoP error="use_dpop_nonce", error_description="Resource server requires nonce in DPoP proof", algs="ES256"' and 'Bearer, DPoP error="invalid_dpop_proof", algs="ES256 PS256"'. Add a 400 response to /userinfo, shaped like ProtectedResourceError, for ambiguous credentials. Add the Proxy-* prohibition to securitySchemes.dpop.description.  
   *Verifier: confirmed.*

9. **[LOW] Gap: CORS: browser clients must be able to read WWW-Authenticate and DPoP-Nonce**  
   *Reference:* RFC 9449 §7.1, §8  
   Browser-based clients, DPoP's main audience, can read these response headers only if the server lists them in Access-Control-Expose-Headers. The YAML models no CORS headers on /token, /par or /userinfo, and no description mentions this.  
   *Suggested change:* Add a note to the DPoPNonce and WWWAuthenticateBearerDPoP descriptions. Optionally define components.headers.AccessControlExposeHeaders (example 'DPoP-Nonce, WWW-Authenticate') and reference it on /token 200/400, /par 201/400 and /userinfo 200/401.  
   *Verifier: confirmed.*

10. **[LOW] Gap: dpop_signing_alg_values_supported: description and constraints**  
   *Reference:* RFC 9449 §5.1, §4.2, §11.6  
   OAuthServerMetadata.dpop_signing_alg_values_supported (L2188-2190) has no description. It does not say that the field's presence signals DPoP support, or that only asymmetric JWS algorithms are allowed (none and MAC algorithms MUST NOT be used).  
   *Suggested change:* Add a description citing §5.1, `items: {type: string, not: {enum: [none, HS256, HS384, HS512]}}` and `examples: [[ES256, PS256, EdDSA]]`.  
   *Verifier: confirmed.*

11. **[LOW] Gap: Media type application/dpop+jwt**  
   *Reference:* RFC 9449 §12.5  
   The YAML never mentions the registered media type of a DPoP proof. This was prior finding M10 and is still open.  
   *Suggested change:* Mention 'media type application/dpop+jwt (RFC 9449 §12.5)' in DPoPHeader.description and in the proposed DPoPProofHeader schema.  
   *Verifier: confirmed.*

12. **[LOW] Incorrect: L977-979 components.parameters.DPoPHeader.description**  
   *Reference:* RFC 9449 §10, §10.1 (also §5, §7)  
   The text says the header is 'Required on `/token`, `/par`, protected resources, and `/userinfo` whenever DPoP-bound access tokens are in use.' For /par this is wrong. §10.1 lists two ways for a client to bind the code at PAR, the DPoP header or dpop_jkt in the body, and §10 makes dpop_jkt OPTIONAL. A client can obtain DPoP-bound tokens with neither. An AS that enforced this text would reject valid PAR requests, even though it MUST support both mechanisms.  
   *Suggested change:* Reword to: 'REQUIRED on /token when the client wants a DPoP-bound access token (§5), and on every request to a protected resource, including /userinfo, that presents a DPoP-bound token (§7). OPTIONAL on /par, where it is one of two code-binding mechanisms the AS MUST support; the other is the dpop_jkt body parameter (§10.1).'  
   *Verifier: confirmed.*

13. **[LOW] Incorrect: L981-982 components.parameters.DPoPHeader.description**  
   *Reference:* RFC 9449 §4.2 (Erratum 7646), §8.2, §9  
   The text says nonce is included only 'when the AS issues a DPoP-Nonce challenge'. §4.2, as corrected by verified Erratum 7646, requires the nonce claim whenever the authorization server or the resource server has provided a DPoP-Nonce header in any response. That includes the 200 OK path (§8.2) and nonces supplied by the resource server (§9).  
   *Suggested change:* Reword to: '`nonce` is REQUIRED whenever the authorization server or resource server has supplied a DPoP-Nonce header, in an error or in a 2xx response.'  
   *Verifier: confirmed.*

14. **[LOW] Incorrect: L1075-1079 components.responses.OAuthErrorWithDPoPNonce.description**  
   *Reference:* RFC 9449 §8  
   'The header is absent on other 400 errors.' contradicts §8. The server can send a fresh nonce with any rejection message, and a nonce-mismatch rejection MAY include a new DPoP-Nonce. A client built from this text might ignore a nonce sent with, for example, invalid_dpop_proof.  
   *Suggested change:* Replace with: 'The header MUST accompany use_dpop_nonce, and MAY accompany other error responses such as invalid_dpop_proof to supply a fresh nonce (RFC 9449 §8).'  
   *Verifier: confirmed.*

15. **[LOW] Incorrect: L1010-1011 components.headers.WWWAuthenticateBearerDPoP.description; L1507 ErrorResponse.error enum comment; L966-968 components.parameters.DPoPJKT.description; L1750-1753 IntrospectionResponse.cnf.description**  
   *Reference:* RFC 9449 §5.1, §6.2, §7.1, §8, §10, §12.2  
   Four citations point to the wrong section: - The algs parameter is cited as 'RFC 9449 §5'. It is defined in §7.1; §5.1 defines dpop_signing_alg_values_supported. - The DPoP errors are commented as 'DPoP §10'. They are defined in §5, §7.1 and §8 and registered in §12.2; §10 is code binding. - dpop_jkt at /authorize cites §10.1. It is defined in §10; §10.1 is the PAR variant. - The introspection cnf.jkt cites §6.1. Introspection is covered by §6.2.  
   *Suggested change:* Correct the citations: algs → §7.1; error comment → '§5, §7.1, §8 (registered in §12.2)'; DPoPJKT → §10 (keep §10.1 on PARRequest.dpop_jkt); IntrospectionResponse.cnf → 'RFC 9449 §6.2'.  
   *Verifier: partially correct —* Three citations are wrong: algs §5 → §7.1; the error comment §10 → §5, §7.1, §8 (registered in §12.2); DPoPJKT §10.1 → §10. The IntrospectionResponse.cnf citation of §6.1 is incomplete rather than wrong: add §6.2 and keep §6.1.

16. **[LOW] Incorrect: L1285-1289 components.schemas.RefreshTokenRequest.description; L1433-1439 TokenResponse.properties.refresh_token.description**  
   *Reference:* RFC 9449 §5; RFC 9700 §2.2.2, §4.14.2  
   The text says refresh tokens 'MUST be sender-constrained (DPoP) or rotated ... for confidential clients this is RECOMMENDED'. That suggests binding confidential clients' refresh tokens to a DPoP key is recommended. RFC 9449 §5 says the opposite: refresh tokens issued to confidential clients are not bound to the DPoP key, because client authentication already constrains them and this allows credential rotation. The cited RFC 9700 §2.2.2 makes no RECOMMENDED statement for confidential clients.  
   *Suggested change:* Reword to: 'Public clients: the refresh token MUST be sender-constrained (DPoP per RFC 9449 §5, or mTLS per RFC 8705 §4) or rotated on every use (OAuth 2.1 §4.3.1, RFC 9700 §4.14.2). Confidential clients: the refresh token is bound to the authenticated client (RFC 6749) and is not DPoP-key-bound (RFC 9449 §5).'  
   *Verifier: confirmed.*

17. **[LOW] Incorrect: L1044-1045 components.headers.WWWAuthenticateBasicBearer.description**  
   *Reference:* RFC 9449 §6.2  
   'The introspection endpoint does not accept DPoP-bound tokens' can be read as saying DPoP-bound tokens cannot be introspected. RFC 9449 §6.2 shows them being introspected through the `token` parameter, with the response returning cnf.jkt. The YAML's actual design choice is narrower: DPoP is not offered as the caller's credential at /introspect. RFC 9449 does not define that case.  
   *Suggested change:* Reword to: 'This spec does not model a DPoP-bound access token as the caller's credential at /introspect. DPoP-bound tokens can still be introspected through the `token` parameter. The response carries cnf.jkt; the RS sends no DPoP proof for the introspected token, and the AS does not validate the binding (RFC 9449 §6.2).'  
   *Verifier: partially correct —* The wording is ambiguous rather than wrong. Clarify that DPoP is not accepted as the caller's credential at /introspect, while DPoP-bound tokens can still be introspected through the token parameter (RFC 9449 §6.2).

18. **[LOW] Gap: Confirmation.jkt has no value-format constraint** — *found by the verifier*  
   *Reference:* RFC 9449 §6.1 (also §11.10)  
   Confirmation.jkt has no value-format constraint. The assessment proposes 43-character base64url patterns for x5t#S256 and dpop_jkt but not for cnf.jkt itself.  
   *Suggested change:* Add pattern '^[A-Za-z0-9_-]{43}$' to Confirmation.jkt and state 'base64url (unpadded) SHA-256 JWK Thumbprint (RFC 7638), not the RFC 9278 URN form' in its description.

19. **[LOW] Gap: The AS-side rule on token lifetime when no nonce is used is missing** — *found by the verifier*  
   *Reference:* RFC 9449 §11.2  
   The AS-side rule on token lifetime when no nonce is used is missing. Deployments that don't use DPoP nonces SHOULD NOT issue long-lived DPoP-bound access tokens.  
   *Suggested change:* Add to the TokenResponse.expires_in or DPoPNonce description: 'If the AS does not use DPoP nonces, DPoP-bound access tokens SHOULD be short-lived (RFC 9449 §11.2).'

20. **[LOW] Gap: Nonces from the AS and from the RS are separate, but this is undocumented** — *found by the verifier*  
   *Reference:* RFC 9449 §9  
   Nonces from the AS and from the RS are separate, but this is undocumented. The single DPoPNonce header component serves both AS responses and RS responses without saying that each nonce is accepted only by the server that issued it.  
   *Suggested change:* Add to DPoPNonce.description: 'A nonce is valid only at the server that issued it. AS and RS nonces are independent (RFC 9449 §9), and the client sends the most recent one from that server.'

## RFC 7800 Proof-of-Possession Key Semantics for JSON Web Tokens (JWTs)

*April 2016 · Proposed Standard · YAML coverage: **partial (verifier corrected from mostly)** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** Defines the cnf (confirmation) JWT claim: a JSON object that identifies the key the presenter of the JWT must prove it holds. It defines four members: jwk (a public key by value), jwe (an encrypted symmetric key), kid (a key ID the recipient can resolve) and jku (the URL of a JWK Set). It also creates the IANA 'JWT Confirmation Methods' registry, which later received x5t#S256 (RFC 8705) and jkt (RFC 9449). A cnf value represents exactly one key, so at most one of jwk, jwe and jku may appear, and members a recipient does not understand MUST be ignored.

**Why it was created.** A JWT on its own is a bearer artifact. To build holder-of-key tokens, similar to SAML SubjectConfirmation or Kerberos tickets, issuers needed a standard place inside the token to say that only the party holding a given key may use it.

<details><summary>Already modeled in the YAML (6)</summary>

- cnf claim (§3.1, §6.1) as a reusable object: components.schemas.Confirmation L2575-2591. Used in JWTAccessTokenClaims.cnf L2568-2573 and IntrospectionResponse.cnf L1748-1753 (cnf is registered for introspection by RFC 8705 §9.4)
- jwk confirmation member (§3.2): Confirmation.jwk L2587-2589, a bare object
- kid confirmation member (§3.4): Confirmation.kid L2590-2591
- Registry extensions: x5t#S256 (RFC 8705) L2584-2586 and jkt (RFC 9449) L2579-2583
- Unknown confirmation members are tolerated, as §3.1 requires ('MUST be ignored'): Confirmation does not set additionalProperties: false (L2575-2578)
- §3 (at least one of iss/sub present) and §4 (audience restriction): JWTAccessTokenClaims.required includes iss, sub and aud (L2521)

</details>

**Follow-up on the May-2026 validation notes.** There is no references/rfc-validation file for RFC 7800. The audit synthesis asked for cnf in IntrospectionResponse ('IntrospectionResponse — fixes'); that is done (L1748-1753, using the shared Confirmation schema at L2575-2591).

**Notes.** - Verified Erratum 6187 (editorial) fixes a DOI typo in the [JWK] reference. It has no wire impact.
- The IANA 'JWT Confirmation Methods' registry currently lists: jwk, jwe, kid and jku (RFC 7800); x5t#S256 (RFC 8705); osc (RFC 9203, ACE/OSCORE, not relevant to this AS); jkt (RFC 9449).
- The YAML has 4 of these 7. All OAuth-relevant members are present except jwe and jku.

### Findings (0 high · 0 medium · 6 low)

1. **[LOW] Gap: jwe confirmation member (encrypted symmetric PoP key)**  
   *Reference:* RFC 7800 §3.3, §6.2.2  
   Confirmation has no jwe member (the IANA absence list confirms it). Its value is a JWK encrypted to the recipient, in JWE Compact Serialization (5 segments).  
   *Suggested change:* Add `jwe: {type: string, pattern: '^[A-Za-z0-9_-]+(\.[A-Za-z0-9_-]*){4}$', description: 'Encrypted symmetric PoP key: a JWK in JWE Compact Serialization (RFC 7800 §3.3).'}`.  
   *Verifier: confirmed.*

2. **[LOW] Gap: jku confirmation member (JWK Set URL) and its kid requirement**  
   *Reference:* RFC 7800 §3.5  
   Confirmation has no jku member (the IANA absence list confirms it). Its value is the URI of a JWK Set. If that set contains more than one key, kid MUST also be present. The set MUST be fetched over TLS with the server identity validated.  
   *Suggested change:* Add `jku: {type: string, format: uri, description: 'URL of a JWK Set containing the PoP key (RFC 7800 §3.5). If the set holds more than one key, kid MUST also be present. Fetch only over validated TLS.'}`.  
   *Verifier: confirmed.*

3. **[LOW] Gap: Only one PoP key per cnf**  
   *Reference:* RFC 7800 §3.1  
   §3.1 allows at most one of jwk, jwe and jku in a cnf object. The schema does not enforce this.  
   *Suggested change:* Add to Confirmation: `not: {anyOf: [{required: [jwk, jwe]}, {required: [jwk, jku]}, {required: [jwe, jku]}]}`.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Definitions of the jwk and kid members, and the ignore-unknown rule**  
   *Reference:* RFC 7800 §3.1, §3.2, §3.4  
   Confirmation.jwk is a bare `type: object` described as 'Embedded JWK; rarely used.' (L2587-2589). §3.2 makes jwk the standard way to carry an asymmetric PoP public key. It MUST contain the required members for its kty, and may hold a symmetric key only inside an encrypted JWT. Current WG drafts rely on it, for example the cnf.jwk of the Client Attestation JWT in draft-ietf-oauth-attestation-based-client-auth-11. Confirmation.kid (L2590-2591) has no description. The Confirmation description does not say that members a recipient does not understand MUST be ignored.  
   *Suggested change:* Use `jwk: {$ref: '#/components/schemas/JWK', description: 'PoP public key (RFC 7800 §3.2). A symmetric key is allowed only if the JWT is encrypted.'}`. Describe kid as 'Key ID of the PoP key, resolvable by the recipient (RFC 7800 §3.4); MAY be a JWK Thumbprint'. Add 'Members not understood MUST be ignored (RFC 7800 §3.1)' to Confirmation.description.  
   *Verifier: confirmed.*

5. **[LOW] Gap: RFC 7800 missing from the covered-specifications table**  
   *Reference:* RFC 7800 §3.1  
   The table in info.description (L16-45) lists RFC 8705 and RFC 9449 but not RFC 7800, although the YAML cites RFC 7800 at L1702, L1751, L2571 and L2577.  
   *Suggested change:* Add the row '| RFC 7800 | 2016 | Proof-of-Possession Key Semantics for JWTs (`cnf`) |'.  
   *Verifier: confirmed.*

6. **[LOW] Incorrect: The Confirmation schema description calls the members 'Token-binding confirmation methods'** — *found by the verifier*  
   *Reference:* RFC 7800 §3.1, §6.1.1, §6.2  
   The Confirmation schema description calls the members 'Token-binding confirmation methods'. RFC 7800 calls cnf the confirmation claim for proof-of-possession keys. 'Token Binding' is a different IETF mechanism (RFC 8471/8473, tokbind WG), which RFC 8705 Appendix B and RFC 9449 §1 explicitly contrast with mTLS and DPoP. For someone learning OAuth this conflation is misleading.  
   *Suggested change:* Reword to: 'Proof-of-possession confirmation (cnf) members per RFC 7800 §3.1. Values come from the IANA JWT Confirmation Methods registry: jwk, jwe, kid and jku (RFC 7800), x5t#S256 (RFC 8705), jkt (RFC 9449).'

## RFC 9278 JWK Thumbprint URI

*August 2022 · Proposed Standard · YAML coverage: **none** · relevance to an AS: informational · vendoring: already-vendored*

**What it is.** Registers the URN prefix urn:ietf:params:oauth:jwk-thumbprint, so that an RFC 7638 JWK Thumbprint can be written as a URI. The URI is the prefix, then a hash-algorithm name from the IANA Named Information Hash Algorithm Registry, then the thumbprint, for example urn:ietf:params:oauth:jwk-thumbprint:sha-256:NzbLsXh8uDCcd-6MNwXF4W_7noWXFZAfHkxZsRGC9Xs. SHA-256 is mandatory to implement. The RFC defines no endpoint or parameter of its own; it only gives a URI form for key identifiers.

**Why it was created.** Self-Issued OpenID Provider v2 (SIOPv2) needed subject identifiers derived from a public key. They had to go in fields that require URIs and be distinguishable from other URI identifiers such as DIDs, and a bare thumbprint is not a URI.

**Follow-up on the May-2026 validation notes.** There are no prior validation notes for RFC 9278.

**Notes.** - No errata.
- The hash identifier MUST come from the IANA Named Information Hash Algorithm Registry, and sha-256 is mandatory to implement (§4-§5).
- None of the 17 drafts downloaded today (16 OAuth WG plus JOSE HPKE) references it.
- The RFC it extends, RFC 7638, is cited in the YAML (L2582) but not vendored. *(Update 2026-10-11: now vendored.)*

### Findings (0 high · 0 medium · 1 low)

1. **[LOW] Gap: The urn:ietf:params:oauth:jwk-thumbprint URI form, and how it differs from jkt and dpop_jkt**  
   *Reference:* RFC 9278 §3-§6, §8.1  
   The URN does not appear in the YAML (IANA absence list, OAuth URI registry). No OAuth AS endpoint or parameter requires it; it is used for key-derived identifiers such as a SIOPv2 `sub`, or as a `kid`. What matters most for this YAML is to state the distinction clearly: jkt (RFC 9449 §6.1) and dpop_jkt (§10) carry the bare base64url thumbprint, never this URI form. Mixing the two up is a common mistake.  
   *Suggested change:* Add to the Confirmation.jkt (L2579-2583) and DPoPJKT (L962-970) descriptions: 'bare RFC 7638 thumbprint (base64url), NOT the RFC 9278 URI form'. Optionally note in the JWK.kid (L1859-1861) and Confirmation.kid descriptions that a kid MAY be a JWK Thumbprint URI, e.g. urn:ietf:params:oauth:jwk-thumbprint:sha-256:NzbLsXh8uDCcd-6MNwXF4W_7noWXFZAfHkxZsRGC9Xs (RFC 9278 §6).  
   *Verifier: confirmed.*

## RFC 9440 Client-Cert HTTP Header Field

*July 2023 · Informational · YAML coverage: **none** · relevance to an AS: optional · vendoring: vendor*

**What it is.** Standardizes two request header fields that a TLS-terminating reverse proxy adds when it forwards a request to the origin server. Client-Cert carries the client's end-entity certificate: the DER bytes as a Structured Field Byte Sequence, that is, base64 between colons. Client-Cert-Chain optionally carries the validation chain. The proxy MUST remove any copies sent by clients, the origin MUST accept the fields only from a trusted proxy, and clients MUST NOT send them.

**Why it was created.** Many deployments terminate TLS at a load balancer or ingress. The application server then never sees the mTLS client certificate it needs, for example for RFC 8705 client authentication or to compute cnf.x5t#S256. Vendors each used their own non-standard headers, which hurt interoperability and led to header-injection bugs; RFC 8705 §6.5 had left this out of scope.

<details><summary>Already modeled in the YAML (1)</summary>

- None of this RFC's own elements is modeled (no Client-Cert or Client-Cert-Chain). One related constraint is already met: token-family responses send Cache-Control: no-store (/token L251-252, /revoke L299-300, /introspect L338-339, /device_authorization L402-403, /par L453-454), which satisfies §2.4 for responses chosen based on Client-Cert

</details>

**Follow-up on the May-2026 validation notes.** There are no prior validation notes for RFC 9440.

**Notes.** - Not vendored (outside the scope rule).
- No errata. httpbis WG, Informational.
- Cited by the vendored RFC 9700 §4.13. OAuth 2.1-16 §1.4.3 sends readers to RFC 9700 §4.13 for TLS termination.
- RFC 8705 §6.5 leaves proxy-to-origin certificate passing out of scope, so this RFC is the practical complement for anyone building an mTLS-capable AS behind a load balancer.
- RFC 9421 Appendix B.3 shows a proxy signing Client-Cert with HTTP Message Signatures.
- Datatracker's 'referenced by' list (2026-10-10) includes RFC 9700 and RFC 9635 (GNAP).

### Findings (0 high · 0 medium · 2 low)

1. **[LOW] Gap: Getting the mTLS client certificate from a TLS-terminating proxy (Client-Cert, Client-Cert-Chain), for mTLS client authentication and certificate-bound tokens**  
   *Reference:* RFC 9440 §2.1-§2.4, §4; RFC 8705 §6.5; RFC 9700 §4.13  
   Behind a TLS-terminating load balancer, the AS or RS sees the client certificate only through Client-Cert. The AS then computes cnf.x5t#S256 over those DER bytes and checks the tls_client_auth subject. Rules that matter: - the origin MUST accept these fields only from a trusted proxy; - the proxy MUST strip or overwrite copies sent by clients, and MAY reject such requests with 400; - Client-Cert-Chain MUST NOT appear without Client-Cert; - clients MUST NOT send either field; - using the fields SHOULD be an explicit opt-in setting. RFC 9700 §4.13 adds that the proxy MUST sanitize security-relevant headers and that the proxy-to-origin link MUST be protected. None of this appears in securitySchemes.mtls (L2676-2681) or in the modeling notes (L47-64).  
   *Suggested change:* Add a modeling note, and a paragraph in securitySchemes.mtls.description: 'Behind a TLS-terminating proxy, the client certificate reaches the AS/RS in the Client-Cert request field, optionally with Client-Cert-Chain (RFC 9440). Accept it only from a trusted proxy that strips client-supplied copies (RFC 9440 §4, RFC 9700 §4.13). Compute x5t#S256 over the decoded DER bytes.' Do NOT add Client-Cert as a public operation parameter, because clients MUST NOT send it (§2.4). If an internal proxy-to-origin version of the spec is ever produced, model it there as `{name: Client-Cert, in: header, schema: {type: string, pattern: '^:[A-Za-z0-9+/]+={0,2}:$'}}`.  
   *Verifier: confirmed.*

2. **[LOW] Gap: Cacheability of responses chosen based on Client-Cert**  
   *Reference:* RFC 9440 §2.4  
   If a response's content depends on Client-Cert, it MUST be uncacheable (Cache-Control: no-store) or carry Vary: Client-Cert. The token-family responses already send no-store. /userinfo 200 (L497-511, L547-561) does not, yet behind a proxy it would be served based on a certificate-bound token.  
   *Suggested change:* Add `Cache-Control: {$ref: '#/components/headers/CacheControlNoStore'}` to the /userinfo GET and POST 200 responses. This is the same change as RFC 9449 gap G7 (§8.2).  
   *Verifier: confirmed.*

## RFC 9421 HTTP Message Signatures

*February 2024 · Proposed Standard · YAML coverage: **not-applicable** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** Defines a general way to sign, or MAC, chosen parts of an HTTP message. A signer picks derived components (such as @method, @target-uri, @authority, @path, @query and @status) and header fields, and builds a canonical 'signature base' from them. The signature and its metadata travel in two fields: Signature-Input, keyed by a label, with the parameters created, expires, nonce, alg, keyid and tag; and Signature. A party can ask for a signature with Accept-Signature. Each application must write a profile that fixes the covered components, how keys are resolved, the allowed algorithms and the error codes (§1.4).

**Why it was created.** TLS protects only one hop, so integrity is lost across TLS-terminating gateways and proxies. Object-signing formats such as JWS force HTTP data to be copied into the payload. Earlier ad-hoc 'Signature' header drafts were incompatible with each other. HTTP Message Signatures give end-to-end signing of requests and responses that survives normal HTTP transformations.

**Follow-up on the May-2026 validation notes.** There are no prior validation notes for RFC 9421.

**Notes.** - No published OAuth RFC profiles RFC 9421, and none of today's 16 OAuth WG drafts cites it. §1.4 requires every application to write a profile first, so this AS spec has nothing to model yet; that is why coverage is not-applicable even though the RFC has an HTTP surface.
- Watch list: draft-richer-oauth-httpsig-03, an individual draft not adopted by the WG (28 July 2026, expires 29 January 2027), would add token_type 'httpsig', a cnf member 'htsk' (cnf.jwk for pre-registered keys) and client metadata 'httpsig_key_binding_method'.
- GNAP (RFC 9635) uses RFC 9421 normatively for key proofing. The WIMSE WG draft draft-ietf-wimse-http-signature-07 profiles it for workload-to-workload authentication.
- Conceptually it covers what DPoP leaves out on purpose: DPoP signs only the method, the URI and the token hash, not the body or headers (RFC 9449 §11.7).
- Errata: 8103 (Verified, Technical: '@signature-input' → '@signature-params' in §7.5.3) and 8102 (Verified, Editorial). Neither affects OAuth.
- Initial HTTP Signature Algorithms registry: rsa-pss-sha512, rsa-v1_5-sha256, hmac-sha256, ecdsa-p256-sha256, ecdsa-p384-sha384, ed25519. JWS algorithms may also be used (§3.3.7).

_No open findings._

## Verifier corrections to the summaries above

- RFC 9449 prior_validation_followup: '9 fixed' overstates progress. M4 is only partly fixed: its own fix list included DPoP-Nonce on /userinfo 200 and a nonce pattern, and both are still missing (L497-511, L547-561, L1056-1057). M6 is only partly fixed: it asked the challenge description to list realm, scope, error, error_description and algs and to cite §7.1, but realm and scope are absent and algs is cited to §5 (L1011). W2 asked for a §8.2 note on the /token 200 response, which was never added (L249). A more accurate tally is 6 fixed, 3 partly fixed, 5 open, and 1 (M8) correctly not applied.
- RFC 9449 summary: 'binds ... a public client's refresh token, to the key's JWK thumbprint (cnf.jkt)' is imprecise. cnf.jkt is the access-token representation (§6). For refresh tokens, §5 says 'The implementation details of the binding of the refresh token are at the discretion of the authorization server.'
- RFC 9449 why_created: 'mTLS binding works poorly for ... many native apps' goes beyond the RFC. §1 makes the user-agent and TLS-client-auth argument only for browser single-page apps. Native apps are described as 'well positioned to benefit from DPoP-bound tokens' (dedicated key storage, protection against a compromised resource), not as unable to use mTLS.
- Cluster notes: '/userinfo is the only protected resource in the spec' is slightly inaccurate. /introspect also accepts an access token as the caller credential (bearerAuth, L363), so the RFC 8705 §3 binding question applies there too (see missed items).
- RFC 9278 category 'jose': RFC 9278 is an OAuth WG RFC (RFC index wg=oauth) and registers an OAuth URN (§8.1). It is related to JOSE only by topic.
- RFC 9278 notes: they omit the COSE counterpart, RFC 9679 'COSE Key Thumbprint' (Proposed Standard, Dec 2024, COSE WG). It registers urn:ietf:params:oauth:ckt in the same IANA OAuth URI registry and is also absent from the YAML (it is on the IANA absence list) and from the 89-RFC candidate catalog. It is worth cataloguing next to RFC 9278 for the user's 'all RFCs' completeness goal.
- RFC 9440 why_created: 'led to header-injection bugs' is not stated by RFC 9440. §1 cites only interoperability problems with non-standard fields. Field injection appears in §4 as a risk to prevent, not as a documented result of vendor practice.
- All published dates and statuses were verified against today's RFC index and are correct: RFC 8705 Feb 2020 PS; RFC 9449 Sep 2023 PS; RFC 7800 Apr 2016 PS; RFC 9278 Aug 2022 PS; RFC 9440 Jul 2023 Informational (httpbis); RFC 9421 Feb 2024 PS (httpbis). The errata claims also match the rfc-editor errata pages: RFC 9449 #7646, RFC 7800 #6187, RFC 9421 #8103 and #8102, and none for RFC 8705, 9278 or 9440. The draft claims check out against the downloaded texts: attestation-based-client-auth-11 is in WG Last Call, requires cnf jwk, and has a DPoP combined mode with attest_jwt_client_auth_dpop. draft-richer-oauth-httpsig-03 (28 Jul 2026, expires 29 Jan 2027) defines token_type httpsig, the htsk cnf member and httpsig_key_binding_method. No OAuth WG draft or vendored OAuth RFC cites RFC 9421 or RFC 9278; the '9421' matches in the status-list draft are hex false positives.
