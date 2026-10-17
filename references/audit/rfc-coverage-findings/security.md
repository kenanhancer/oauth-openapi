# Security guidance — RFC 6819, RFC 9700, security-topics-update

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 6819](#rfc-6819-oauth-20-threat-model-and-security-considerations) | January 2013 | Informational (updated by RFC 9700) | mostly | 0 | 3 | 6 |
| [RFC 9700](#rfc-9700-best-current-practice-for-oauth-20-security) | January 2025 | Best Current Practice (BCP 240); updates RFC 6749, RFC 6750, RFC 6819 | partial (verifier corrected from mostly) | 4 | 8 | 11 |
| [draft-ietf-oauth-security-topics-update-03](#draft-ietf-oauth-security-topics-update-03-updates-to-oauth-20-security-best-current-practice) | July 2026 | Internet-Draft -03 (OAuth WG document, intended BCP; would update RFC 6749, 6750, 7521, 7522, 7523, 9700; expires 7 January 2027) | none | 0 | 1 | 3 |

**Cluster notes.** Cluster = RFC 6819 (threat model, 2013), RFC 9700 (BCP 240, Jan 2025) and draft-ietf-oauth-security-topics-update-03 (Jul 2026). Both RFCs are vendored byte-identical. The draft is not vendored, which is right for a -03 WG document (catalog-only). The YAML already carries RFC 9700's main rules: exact redirect matching, PKCE limited to S256, no implicit/ROPC/token-bearing hybrid response types, iss (RFC 9207) for mix-up defense, 303 recommended and 307 never used, DPoP and mTLS sender-constraint, refresh tokens either sender-constrained or rotated, audience restriction via resource/aud/RAR, AS metadata, and 401 challenges. Still missing are four RFC 9700 MUSTs that touch modeled elements: (1) no http redirect URIs except loopback (§2.6), (2) the PKCE-downgrade iff-rule at /token (§2.1.1, §4.8.2), (3) single-use codes (§4.2.4), (4) clickjacking protection on AS HTML pages (§4.16). Three YAML statements are wrong: exact matching is stated with no loopback-port exception (720-727); §4.8 is blamed on `plain` (791-792); and `sub` is required to equal client_id for client_credentials (2539-2540), which contradicts §4.15. The May-2026 RFC 9700 audit was written without the RFC text (its own disclaimer). From §4.10 onward its §4.x numbers are one too low, and three of its quoted MUSTs do not exist in RFC 9700. Most of its findings were still applied. Related security documents outside this cluster that are NOT vendored: RFC 10017 (BCP 212, browser-based apps; CORS/BFF), RFC 10027 (BCP 247, cross-device flows), BCP 195 = RFC 8996 + RFC 9325 (TLS; TLS 1.3 is now RFC 9846), and RFC 9440 (Client-Cert header, cited by RFC 9700 §4.13). *(Update 2026-10-11: RFC 10017, RFC 10027 and RFC 8996 are now vendored; RFC 9325, RFC 9852 and RFC 9440 remain catalogue-only.)* Cross-cluster drift found while checking: CodeChallengeMethod (785-788) says OAuth 2.1 makes code_challenge_method OPTIONAL with default plain, but -16 §4.1.1 makes it REQUIRED (S256) and §7.5.2 forbids plain. The YAML's 'OAuth 2.1 §7.5.3' for 307 is §7.5.4 in -16. PARRequest.code_challenge_method `default: S256` (1615) contradicts RFC 7636 §4.3, where the default is plain. PARRequest (1594) and AuthorizationCodeTokenRequest (1244) require PKCE unconditionally, while the /authorize prose (120-123) allows the OIDC-nonce exception. For the security-topics-update draft, the concrete YAML impact is the client_assertion audience. draft-ietf-oauth-rfc7523bis-11 (already in the RFC Editor queue) turns that into a server MUST: the AS must reject any client-authentication JWT whose sole aud is not its issuer.

## RFC 6819 OAuth 2.0 Threat Model and Security Considerations

*January 2013 · Informational (updated by RFC 9700) · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 6819 is OAuth 2.0's original threat model. It first lists what each party stores. It then walks through threats per component and per flow: stolen client secrets and refresh tokens, counterfeit-server phishing, open redirectors, leaked or guessed authorization codes, CSRF against the redirect URI, clickjacking, code and token substitution in 'OAuth login', and eavesdropping or token phishing at resource servers. Each threat maps to §5 countermeasures: TLS everywhere, full pre-registered redirect URIs, state bound to the user-agent session, short-lived one-time codes bound to client_id and redirect_uri, high-entropy handles, audience- and client-bound tokens, refresh-token rotation and revocation, strong client authentication, and X-Frame-Options. It is Informational ('should' in lower case) and defines no wire elements of its own. RFC 9700 updates and extends it.

**Why it was created.** RFC 6749's own Security Considerations (§10) were short. The OAuth WG wanted a full, structured threat analysis that implementers and deployers could use as the base for deployment-specific risk analysis. It was written for the static, single-deployment setups of 2012-2013, where client registration and discovery were out of scope.

<details><summary>Already modeled in the YAML (16)</summary>

- TLS for every request (§4.3.1, §4.6.1, §5.1.1): servers https://{issuer} (77-86)
- Pre-registered redirect URI, no redirect on mismatch (§4.1.5, §4.2.4, §5.2.3.5): components.parameters.RedirectUri (716-730); paths./authorize.get.responses.400 (196-205)
- Code bound to redirect_uri (§5.2.4.5): AuthorizationCodeTokenRequest.redirect_uri (1252-1258). Optional under OAuth 2.1 §10.2 because PKCE binds the code instead
- state for CSRF (§3.6, §4.4.1.8, §5.3.5): components.parameters.State (750-758); ErrorResponse.state (1529-1533)
- Limited lifetimes (§3.1.2, §5.1.5.3): TokenResponse.expires_in (1428-1432); DeviceAuthorizationResponse.expires_in (1572-1574); PARResponse.expires_in (1668-1675)
- Limited scope (§3.1.1, §5.1.5.1): components.parameters.Scope (732-748); TokenResponse.scope (1440-1442); RefreshTokenRequest.scope narrowing (1302-1307)
- Audience-bound tokens (§4.6.4, §4.6.5, §5.1.5.5-§5.1.5.7): Resource (880-895); ResourceIndicators mixin (1203-1218); JWTAccessTokenClaims.aud (2529-2535); invalid_target (1499)
- Token bound to client_id (§5.1.5.8, §5.2.2.2): JWTAccessTokenClaims.client_id (2541-2543); IntrospectionResponse.client_id (1715-1716); RefreshTokenRequest prose (1286-1289)
- Signed, standard-format self-contained tokens (§5.1.5.9, §5.1.5.11): JWT (2434-2441); JWTAccessTokenClaims (2514-2573); /jwks + JWKS (573-598, 1813-1820)
- Encrypted token content as an option (§5.1.5.10): id_token_encryption_* (2086-2091); introspection_encryption_* (2074-2079)
- Restricted refresh-token issuance, rotation and revocation (§5.2.2.1, §5.2.2.3, §5.2.2.4): TokenResponse.refresh_token is optional (1433-1439); offline_access scope (2700); RefreshTokenRequest (1284-1307); /revoke + RevocationRequest (273-310, 1794-1808)
- Strong client authentication, no plaintext secrets on the wire (§4.3.3, §5.2.3.7): ClientAuthFields.client_assertion/_type (1191-1200); private_key_jwt, client_secret_jwt, tls_client_auth in token_endpoint_auth_methods_supported (2037-2049); securitySchemes.mtls (2676-2681)
- Tokens in the Authorization header, never in URIs (§4.6.7, §5.4.1): bearerAuth (2637-2646); dpop (2648-2660); bearer_methods_supported prose (2296-2304)
- Authenticated (PoP) requests to the RS and replay defense (§4.6.2, §4.6.4, §5.4.2): DPoPHeader with jti/htm/htu/iat/ath (972-984); Confirmation cnf.jkt / x5t#S256 (2575-2591)
- Non-cacheable token responses (§4.4.2.2, §4.6.6): CacheControlNoStore/PragmaNoCache (990-999) on /token 200 (250-254), /par, /introspect, /revoke, /device_authorization and on error responses
- User consent step (§5.1.3, §5.2.4.2-3): /authorize 200 text/html (190-195); prompt=consent (807-819)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation file exists. rfc6819.txt was vendored on 2026-06-06 without an audit (references/rfc-sources/README.md, note after the file table).

**Notes.** The YAML never cites RFC 6819. Its constraints arrive mostly indirectly, through RFC 6749 §10, RFC 9700 and OAuth 2.1, which restate most of them. Two pieces of advice are superseded and should not be adopted: §4.4.1.7 suggests implicit/password grants as alternatives (both intentionally excluded), and the token-endpoint redirect_uri check in §3.5/§5.2.4.5 is replaced by PKCE binding (OAuth 2.1 §10.2; RFC 9700 §4.5.2-4.5.3), which the YAML follows (1236-1239, 1252-1258). Operational-only countermeasures have no wire surface: credential storage and hashing (§5.1.4.1), SQL injection, device lock, secure storage, device identification, user education, and signed RS requests (§5.4.3; no OAuth-standard mechanism, DPoP covers PoP). Errata (rfc-editor.org, checked 2026-10-10): 5965 (Verified, editorial) — §4.4.1.2 should read 'Store authorization code hashes only'. 4267 (Held for Document Update) — §4.4.1.11 should read 'trivial amount of entropy'. RFC 9700 §3 restates RFC 6819's attacker assumptions as the formal A1-A5 model.

### Findings (0 high · 3 medium · 6 low)

1. **[MEDIUM] Gap: Anti-framing header (X-FRAME-OPTIONS) on end-user authorization pages**  
   *Reference:* RFC 6819 §4.4.1.9, §5.2.2.6  
   The clickjacking countermeasure is to stop the authorization UI from being framed, using X-FRAME-OPTIONS (DENY / SAMEORIGIN) plus frame-busting for old browsers. The /authorize 200 text/html (190-195) and 400 text/html (196-205) responses declare no headers, and nothing in the YAML mentions framing. RFC 9700 §4.16 raises this to an AS MUST, reported as high under RFC 9700.  
   *Suggested change:* Add a components.headers.XFrameOptions entry (enum [DENY, SAMEORIGIN]; note that ALLOW-FROM is not honored by current browsers). Reference it, together with a CSP frame-ancestors header, on /authorize 200 and 400.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Authorization code handling: one-time use, short expiry, binding to client_id, revocation of derived tokens on abuse**  
   *Reference:* RFC 6819 §4.4.1.1, §4.4.1.13, §5.1.5.3, §5.1.5.4, §5.2.1.1, §5.2.4.4  
   RFC 6819's main defenses against leaked or substituted codes are: (a) short expiry, (b) one-time use, (c) revoking all tokens issued from a code that is redeemed more than once, and (d) checking at /token that the code was issued to the requesting client. AuthorizationCodeTokenRequest.code (1249-1251) only says 'The authorization code received from /authorize'. Searching the YAML for once/one-time/reuse/invalidat/lifetime finds nothing about codes. RFC 6749 §4.1.2/§4.1.3 make these MUSTs; the RFC 9700 entry reports this as high.  
   *Suggested change:* Extend AuthorizationCodeTokenRequest.code.description with these rules: single use; expires shortly (at most 10 min RECOMMENDED); bound to client_id and redirect_uri; a reused code gets invalid_grant, and the AS SHOULD revoke tokens derived from it (RFC 6819 §5.2.1.1; RFC 6749 §4.1.2, §4.1.3).  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: High-entropy, unguessable credentials (codes, token handles, device_code, client secrets)**  
   *Reference:* RFC 6819 §5.1.4.2.2 (also §4.4.1.3, §4.5.3, §4.6.3)  
   Handles and secrets should have at least 128 bits from a CSPRNG (RFC 6749 §10.10 makes a guessing probability of at most 2^-128 a MUST). Only PARResponse.request_uri says this (1659-1665). TokenResponse.access_token / refresh_token (1411-1439), the authorization code, DeviceAuthorizationResponse.device_code (1557-1559) and client_secret (1185-1190) give no entropy requirement.  
   *Suggested change:* Add to the descriptions of opaque access_token, refresh_token, code, device_code and client_secret: 'Opaque values MUST be unguessable: at least 128 bits from a cryptographically strong RNG (RFC 6749 §10.10; RFC 6819 §5.1.4.2.2).'  
   *Verifier: confirmed.*

4. **[LOW] Gap: Throttling of online guessing and DoS on token-family endpoints**  
   *Reference:* RFC 6819 §4.3.5, §4.4.1.12, §5.1.4.2.3, §5.1.4.2.4  
   The AS should rate-limit or lock out clients that send repeated invalid codes or client secrets. Only /par models 429 (471-472). /token, /revoke, /introspect and /device_authorization do not.  
   *Suggested change:* Add an optional 429 response with a Retry-After header to /token, /revoke, /introspect and /device_authorization, described as throttling per RFC 6819 §5.1.4.2.  
   *Verifier: confirmed.*

5. **[LOW] Gap: No automatic re-approval for public or unvalidated clients**  
   *Reference:* RFC 6819 §4.2.3, §5.2.3.2, §5.2.4.1  
   The AS should not silently re-authorize public clients that it cannot validate through a pre-registered redirect URI or other client authentication. The /authorize description (114-128) and Prompt (807-819) say nothing about when consent may be skipped.  
   *Suggested change:* Add one sentence to the /authorize description about when a prior consent may be reused (only for clients validated by authentication or an exact registered redirect URI).  
   *Verifier: confirmed.*

6. **[LOW] Gap: Refresh-token rotation must detect reuse**  
   *Reference:* RFC 6819 §5.2.2.3  
   Rotation exists to detect parallel use of the same refresh token. When an old token is presented, both the valid refresh token and the grant behind it are revoked. RefreshTokenRequest (1284-1289) only says 'rotated on every use'. This is covered in more detail as a medium gap under RFC 9700 §4.14.2.  
   *Suggested change:* See the RFC 9700 entry: document the reuse→revoke behavior in RefreshTokenRequest.description.  
   *Verifier: confirmed.*

7. **[LOW] Gap: Cache-Control: private on RS responses when the token is not sent in an Authorization header**  
   *Reference:* RFC 6819 §4.6.6  
   POST /userinfo accepts access_token in the form body (539-545). Its 200 response (547-561) declares no Cache-Control, so authenticated content could be cached by proxies.  
   *Suggested change:* Add a Cache-Control header (e.g., 'no-store' or 'private') to the /userinfo 200 responses.  
   *Verifier: confirmed.*

8. **[LOW] Gap: RFC 6819 is not referenced anywhere in the YAML**  
   *Reference:* RFC 6819 §1  
   There are no mentions at all. The covered-spec table (lines 16-45) lists RFC 9700 but not the threat model it updates, although many descriptions apply RFC 6819 countermeasures.  
   *Suggested change:* Add a row to info.description: 'RFC 6819 | 2013 | Threat Model and Security Considerations (updated by RFC 9700)'. Cite RFC 6819 sections where its countermeasures are applied (State, RedirectUri, refresh-token rotation, anti-framing headers).  
   *Verifier: confirmed.*

9. **[LOW] Gap: RFC 6819's own countermeasure for code phishing and session impersonation is an HTTPS-protected redirect URI** — *found by the verifier*  
   *Reference:* RFC 6819 §4.4.1.5, §4.4.1.6 (with §5.1.2)  
   RFC 6819's own countermeasure for code phishing and session impersonation is an HTTPS-protected redirect URI. The YAML does not state it, and the RFC 6819 entry does not list it (it appears only as the RFC 9700 §2.6 gap).  
   *Suggested change:* Cite RFC 6819 §4.4.1.5 next to RFC 9700 §2.6 in the redirect-URI scheme rule proposed in the RFC 9700 gap.

## RFC 9700 Best Current Practice for OAuth 2.0 Security

*January 2025 · Best Current Practice (BCP 240); updates RFC 6749, RFC 6750, RFC 6819 · YAML coverage: **partial (verifier corrected from mostly)** · relevance to an AS: required-oauth21 · vendoring: already-vendored*

**What it is.** RFC 9700 is the IETF's current security baseline for OAuth 2.0 and the main input to OAuth 2.1, which cites it normatively. §2 condenses the rules: exact-string redirect URI matching, PKCE (S256) for every client, no implicit, password or token-bearing response types, an iss-based mix-up defense, sender-constrained (DPoP/mTLS) access tokens, refresh tokens that are sender-constrained or rotated for public clients, least-privilege audience-restricted access tokens, asymmetric client authentication, published AS metadata, TLS with no plain-http redirect URIs, and no CORS at the authorization endpoint. §4 explains the attack behind each rule and its countermeasure: redirect-URI bypasses, Referer and history leakage, mix-up, code and token injection, CSRF, PKCE downgrade, stolen tokens, open redirectors, 307 credential forwarding, TLS-terminating proxies, refresh-token replay, client/user sub confusion, clickjacking, and postMessage flaws.

**Why it was created.** Between 2013 and 2024, real deployments and formal analyses exposed attacks that RFC 6819 missed or under-weighted: redirect-URI pattern-matching bypasses, mix-up in multi-AS clients, code and token injection, PKCE downgrade, credential leakage via Referer and 307 redirects. Over the same period OAuth spread into high-security settings (open banking, eHealth) and dynamic ones (discovery plus dynamic registration), and browsers changed the fragment handling the implicit grant relied on. The BCP, developed as draft-ietf-oauth-security-topics from 2016, updates the attacker model (A1-A5), deprecates the implicit and password grants, and makes PKCE and exact redirect matching universal.

<details><summary>Already modeled in the YAML (19)</summary>

- §2.1/§4.1.3 exact-string redirect URI matching: components.parameters.RedirectUri (716-730, text 720-727)
- §4.11.2 (via RFC 6749 §4.1.2.1) no redirect on invalid client_id/redirect_uri: paths./authorize.get.responses.400 (196-205)
- §2.1/§4.12 303 recommended, 307 prohibited: /authorize 302 (160-181, note 171-172) and 303 (182-189); no 307 response is modeled
- §2.1/§4.4.2.1 mix-up defense via RFC 9207 iss: 302 prose (164-169); Location examples with iss (180-181); OAuthServerMetadata.authorization_response_iss_parameter_supported (2206-2211); issuer must equal the iss claim and discovery base (1944-1950)
- §2.1/§4.7 CSRF inputs: State echoed unchanged (750-758); ErrorResponse.state (1529-1533); Nonce (797-805); IDTokenClaims.nonce (2492-2494)
- §2.1.1/§4.5.3.1 PKCE for all clients: /authorize description (120-123); CodeChallenge (760-778); AuthorizationCodeTokenRequest requires code_verifier (1244, 1259-1266); PARRequest requires code_challenge and _method (1594, 1607-1615)
- §2.1.1 verifier-hiding method only: CodeChallengeMethod enum [S256] (780-795); code_challenge_methods_supported enum [S256] (2176-2185)
- §2.1.2 implicit and token-bearing response types excluded: ResponseType enum code | id_token | 'code id_token' (686-706); info modeling notes (59-61); /token description (226-227)
- §2.4 ROPC excluded: TokenRequest oneOf/discriminator has no password (1152-1171)
- §2.2.1/§4.10.1 sender-constrained access tokens: DPoPHeader (972-984); DPoPJKT (962-970); dpop scheme (2648-2660); mtls scheme (2676-2681); token_type DPoP (1420-1427); Confirmation cnf.jkt / x5t#S256 (2575-2591); dpop_signing_alg_values_supported (2188-2190); tls_client_certificate_bound_access_tokens (2193-2198); mtls_endpoint_aliases (1997-2013); dpop_bound_access_tokens_required (2329-2332); WWWAuthenticateBearerDPoP (1000-1025)
- §2.2.2/§4.14 refresh tokens of public clients sender-constrained or rotated: RefreshTokenRequest description (1284-1289); TokenResponse.refresh_token (1433-1439); /revoke (273-310)
- §2.3/§4.10.2 audience-restricted, least-privilege access tokens: Resource (880-895); ResourceIndicators mixin on every grant, PAR and device request (1203-1218, used at 1242/1272/1292/1313/1331/1353/1545/1592); invalid_target (1498-1499); JWTAccessTokenClaims.aud required (2521, 2529-2535); IntrospectionResponse.aud (1732-1737); authorization_details (870-878, 1224-1233, 1454-1460); ProtectedResourceMetadata.resource (2281-2285)
- §2.5 client authentication incl. asymmetric methods: /token security clientSecretBasic | mtls | {} (265-268); ClientAuthFields (1175-1200); private_key_jwt, tls_client_auth, self_signed_tls_client_auth in token_endpoint_auth_methods_supported (2037-2049); token_endpoint_auth_signing_alg_values_supported (2050-2056)
- §2.6 AS metadata published: /.well-known/oauth-authorization-server (630-648); /.well-known/openid-configuration (603-625); OAuthServerMetadata (1922-2267)
- §2.6 TLS: servers https://{issuer} (77-86); https issuer and jwks_uri (1944-1964)
- §4.3.2 no access tokens in URI query: ProtectedResourceMetadata.bearer_methods_supported prose (2296-2304); bearerAuth uses the header (2637-2646)
- §4.2.4/§4.3 form_post and PAR as leakage countermeasures: ResponseMode (846-855); response_modes_supported (2027-2032); /par (422-476); RequestUri (857-868); require_pushed_authorization_requests (2166-2169)
- Cache-Control: no-store on token-bearing responses (§4.10.3 examples; RFC 6749 §5.1): CacheControlNoStore/PragmaNoCache (990-999) on /token, /par, /introspect, /revoke, /device_authorization
- §4.10.3 non-recommended leakage-by-metadata parameters (resource_servers, access_token_resource_server) are correctly NOT modeled

</details>

**Follow-up on the May-2026 validation notes.** The prior notes (2026-05-10) were written without access to the RFC text, as the file itself says. They raised 7 MISSING, 4 WRONG and 5 NICE-TO-HAVE items. MISSING: 5 fixed — M1 iss (164-169, 180-181, 2206-2211), M2 refresh-token rotation/sender-constraint (1286-1289, 1435-1439), M4 303 (182-189), M5 resource on all grants (ResourceIndicators 1203-1218), M6 WWW-Authenticate (1000-1050, 1091-1142). M3 mostly fixed: exact match is stated at 720-727, but without the loopback-port exception and not on PARRequest.redirect_uri. M7 still open: the asymmetric-auth recommendation of RFC 9700 §2.5 is still not stated, although the client_secret_post caveat now exists at 1185-1190. WRONG: 3 fixed — W1 S256 only (795, 2180), W2 hybrid token types removed (703-706), W4 client_secret NOT RECOMMENDED (1185-1190). W3 is partly open: code_challenge_methods_supported is still optional and its PKCE-detection role is not explained. NICE-TO-HAVE: 2 fixed — request_object_signing_alg_values_supported (2105-2107) and no-store on /introspect and /par (338-341, 453-456). 3 open: TLS/BCP 195, AS open-redirector precautions, refresh-token reuse detection. Reliability caveats: from §4.10 onward the audit's §4.x numbers are off by one (open redirection is §4.11, 307 is §4.12, proxies §4.13, refresh tokens §4.14, client impersonation §4.15, clickjacking §4.16), and the '§4.17 Phishing via AS' section it cites does not exist. These quoted MUSTs are not in RFC 9700: W1 'AS MUST NOT allow plain', M4 'It MUST use HTTP status code 303', M7 'client_secret_basic SHOULD be preferred'. The W1 misreading carried over into YAML lines 791-792. Its NOT-APPLICABLE list wrongly treats clickjacking (§4.16) and Referer leakage (§4.2) as impossible to model. Both map to response headers on /authorize and remain open (high and medium).

**Notes.** Out of the YAML's scope: client-side MUSTs (checking state, nonce and iss; distinct redirect URIs; clients not exposing open redirectors; postMessage receiver checks), resource-server secret handling (§4.9.3), and AS risk decisions such as whether to issue refresh tokens (§4.14.2). §4.17 (in-browser postMessage) does not apply today because no web_message response mode is modeled. If one is added, the AS MUST use exact-origin matching and never target '*'. RFC 9700 has no IANA actions, and the RFC Editor errata page lists no errata (checked 2026-10-10). The YAML is stricter than RFC 9700 in two places: it allows S256 only (RFC 9700 only says clients SHOULD use S256), and it requires PKCE for confidential clients. Both are valid profile choices. The metadata defaults (iss_parameter_supported=false, tls_client_certificate_bound_access_tokens=false, dpop_bound_access_tokens_required=false) are correct registry defaults, but a reference AS should advertise iss and offer DPoP/mTLS binding (§2.2.1, §4.10). The intentional exclusions (implicit, ROPC, token-bearing hybrids) satisfy §2.1.2/§2.4 and are not gaps.

### Findings (4 high · 8 medium · 11 low)

1. **[HIGH] Gap: redirect_uri scheme rule: no plain http except native-app loopback**  
   *Reference:* RFC 9700 §2.6 (with §2.1; RFC 8252 §7.3; OAuth 2.1-16 §1.5)  
   §2.6 says: 'Authorization responses MUST NOT be transmitted over unencrypted network connections. To this end, authorization servers MUST NOT allow redirection URIs that use the http scheme except for native clients that use loopback interface redirection.' RedirectUri (716-730), PARRequest.redirect_uri (1600-1602) and AuthorizationCodeTokenRequest.redirect_uri (1252-1258) are plain `format: uri` with no scheme rule. Nothing tells an implementer to reject http://client.example/cb at registration or at /authorize.  
   *Suggested change:* Add to RedirectUri.description, and reference it from PARRequest.redirect_uri: 'Absolute URI without a fragment. The AS MUST reject http redirect URIs except native-app loopback URIs http://127.0.0.1:{port}/… or http://[::1]:{port}/… (RFC 9700 §2.6, RFC 8252 §7.3). https URIs and reverse-DNS private-use schemes (RFC 8252 §7.1) are allowed.' Optionally add schema.pattern '^(https://[^#]+|http://(127[.]0[.]0[.]1|\[::1\])(:[0-9]{1,5})?(/[^#]*)?|[A-Za-z][A-Za-z0-9+-]*([.][A-Za-z0-9+-]+)+:[^#]+)$'.  
   *Verifier: confirmed.*

2. **[HIGH] Gap: PKCE downgrade protection at /token: code_verifier present if and only if a code_challenge was sent**  
   *Reference:* RFC 9700 §2.1.1, §4.8.1, §4.8.2  
   §2.1.1 requires the AS to 'enforce the correct usage of code_verifier' when a challenge was sent. §4.8.2 also requires it to 'ensure that if there was no code_challenge in the authorization request, a request to the token endpoint containing a code_verifier is rejected'. AuthorizationCodeTokenRequest (1235-1266) only lists code_verifier as required (1244) and gives its syntax. The YAML's only mention of 'downgrade' (791-792) points at plain instead. The profile still allows the OIDC-nonce exception (120-123, 768-771), so codes can be issued without a challenge, and nothing tells the AS to reject a verifier for such a code — exactly the §4.8.1 attack. The unconditional `required: code_verifier` also conflicts with that exception.  
   *Suggested change:* Add to AuthorizationCodeTokenRequest.code_verifier.description: 'MUST be present if and only if the authorization request carried code_challenge (RFC 9700 §2.1.1, §4.8.2; OAuth 2.1 §4.1.3). A verifier for a code issued without a challenge is rejected with invalid_request (OAuth 2.1 §3.2.4). A missing verifier, or BASE64URL(SHA256(verifier)) that differs from the stored challenge, gets invalid_grant (RFC 7636 §4.6).' Preferably drop the nonce exception so PKCE is mandatory for every client; under §4.8.2, mandating PKCE implements the mitigation implicitly, and code_verifier can then stay unconditionally required.  
   *Verifier: confirmed.*

3. **[HIGH] Gap: Single-use, short-lived authorization codes and handling of reuse**  
   *Reference:* RFC 9700 §4.2.4 (restating RFC 6749 §4.1.2); §4.5.2  
   §4.2.4 says: 'authorization codes MUST be invalidated by the authorization server after their first use at the token endpoint'. On a second redemption attempt, the AS SHOULD revoke all tokens issued from that code. AuthorizationCodeTokenRequest.code (1249-1251), the /token description (215-235) and ErrorResponse (1465-1533) never mention single use, expiry, or reuse leading to invalid_grant.  
   *Suggested change:* Extend AuthorizationCodeTokenRequest.code.description: 'Single use and short-lived (MUST expire shortly; at most 10 min RECOMMENDED, RFC 6749 §4.1.2). Bound to client_id and redirect_uri (RFC 6749 §4.1.3). A second redemption MUST be denied with invalid_grant, and the AS SHOULD revoke tokens already issued from the code (RFC 6749 §4.1.2; RFC 9700 §4.2.4) — but only when the replayed request is otherwise valid, to avoid a DoS (OAuth 2.1-16 §7.5.3).' Repeat this briefly in the /token description.  
   *Verifier: confirmed.*

4. **[HIGH] Gap: Clickjacking protection on AS-rendered pages (CSP frame-ancestors / X-Frame-Options)**  
   *Reference:* RFC 9700 §4.16 (with RFC 6819 §4.4.1.9, §5.2.2.6)  
   §4.16 says: 'Authorization servers MUST prevent clickjacking attacks … SHOULD also use Content Security Policy (CSP) level 2 or greater'. This applies on the authorization endpoint and on other user-facing pages (login, consent, error, device verification). The /authorize 200 text/html (190-195) and 400 text/html (196-205) responses declare no headers. The only framing-related item in the YAML is check_session_iframe (1993-1996). The prior audit's claim that this cannot be modeled in OpenAPI is wrong: response headers can be modeled.  
   *Suggested change:* Add components.headers.ContentSecurityPolicy (RFC 9700 §4.16; example `frame-ancestors 'none'; script-src 'self'`, or a per-client allow-list of framing origins). Add components.headers.XFrameOptions (enum [DENY, SAMEORIGIN] as the legacy fallback; ALLOW-FROM is not honored by current browsers). Reference both on /authorize 200 and 400, and state in DeviceAuthorizationResponse.verification_uri (1564-1567) that the verification page sends the same headers.  
   *Verifier: confirmed.*

5. **[MEDIUM] Gap: Precautions so the AS does not act as an open redirector (authenticate first; auto-redirect only to trusted URIs)**  
   *Reference:* RFC 9700 §2.1, §4.11.2  
   §4.11.2 shows phishing through correctly registered (e.g., dynamically registered) redirect URIs: erroneous requests, denied consent, and prompt=none. It requires that the AS 'MUST always authenticate the user first and, with the exception of the silent authentication use case, prompt the user for credentials when needed, before redirecting the user', and that it 'SHOULD only automatically redirect the user agent if it trusts the redirection URI'. The YAML only covers the RFC 6749 §4.1.2.1 non-redirect case (196-205). The narrative at 115-118 implies authenticate-then-redirect, but the 302 description (161-172) lists error redirects without that precondition, and Prompt (807-819) says nothing about prompt=none with untrusted redirect URIs.  
   *Suggested change:* Add to the /authorize 302/303 descriptions: 'Before redirecting to redirect_uri — including error redirects such as invalid_scope or access_denied — the AS MUST authenticate the user (except for prompt=none silent requests). It SHOULD auto-redirect only to redirect URIs it trusts and otherwise MAY show an interstitial (RFC 9700 §4.11.2). Any other AS-hosted redirect target (e.g., post_logout_redirect_uri at end_session_endpoint, 1989-1992) must be pre-registered and exactly matched.'  
   *Verifier: confirmed.*

6. **[MEDIUM] Gap: No CORS at the authorization endpoint; optional CORS elsewhere**  
   *Reference:* RFC 9700 §2.6  
   §2.6: 'CORS MUST NOT be supported at the authorization endpoint'. The token, AS-metadata, jwks_uri and registration endpoints MAY support CORS for browser-based clients. The YAML never mentions CORS or Access-Control-*. An implementer who adds a global CORS middleware (common when enabling SPAs on /token) would violate the MUST NOT.  
   *Suggested change:* /authorize description: 'MUST NOT support CORS; never emit Access-Control-Allow-Origin (RFC 9700 §2.6).' Add an optional components.headers.AccessControlAllowOrigin and reference it on /token, /.well-known/oauth-authorization-server, /.well-known/openid-configuration and /jwks responses as 'MAY (RFC 9700 §2.6; see RFC 10017)'.  
   *Verifier: confirmed.*

7. **[MEDIUM] Gap: Recommendation for asymmetric client authentication**  
   *Reference:* RFC 9700 §2.5  
   §2.5: 'It is RECOMMENDED to use asymmetric cryptography for client authentication, such as mutual TLS [RFC8705] or signed JWTs ("Private Key JWT")'. The AS SHOULD enforce client authentication where feasible. The methods are modeled (mtls 2676-2681; client_assertion 1191-1200; enum 2037-2049), but no text states the recommendation. The /token description (229-235) lists methods neutrally; clientSecretBasic (2662-2674) is called PREFERRED, though only in comparison with client_secret_post; and every security array lists clientSecretBasic first (265-268, 307-310, 360-363, 414-417, 473-476).  
   *Suggested change:* Add to the /token description, ClientAuthFields and token_endpoint_auth_methods_supported: 'RFC 9700 §2.5: asymmetric methods (private_key_jwt, tls_client_auth, self_signed_tls_client_auth) are RECOMMENDED. Shared-secret methods are acceptable but weaker. The AS SHOULD require client authentication whenever credentials can be issued.' Consider listing `mtls` before `clientSecretBasic` in the security arrays.  
   *Verifier: confirmed.*

8. **[MEDIUM] Gap: Refresh-token rotation semantics (reuse detection, revocation, integrity, binding, expiry)**  
   *Reference:* RFC 9700 §4.14.2  
   Rotation only protects anything if replay is detected. With rotation, the AS issues a new refresh token on every refresh and invalidates the previous one while keeping the lineage. When an invalidated refresh token is presented, it revokes the active one. If grant data is encoded in the refresh token, its integrity MUST be protected. Refresh tokens MUST stay bound to the consented scope and resource servers, SHOULD expire after client inactivity, and MAY be revoked on password change or logout. RefreshTokenRequest (1284-1307) and TokenResponse.refresh_token (1433-1439) only say 'rotated on every use'.  
   *Suggested change:* Extend RefreshTokenRequest.description: 'With rotation, every refresh response returns a new refresh_token, and the client MUST discard the old one (OAuth 2.1 §4.3.2). Presenting an already-rotated token gets invalid_grant AND revocation of the active refresh token / grant (RFC 9700 §4.14.2; OAuth 2.1 §4.3.1). Self-contained refresh tokens MUST be integrity-protected. Refresh tokens stay bound to the consented scope and resources and SHOULD expire after inactivity.'  
   *Verifier: confirmed.*

9. **[MEDIUM] Incorrect: lines 720-727 — components.parameters.RedirectUri.description**  
   *Reference:* RFC 9700 §2.1, §4.1.3  
   The text says the AS 'MUST compare against registered URIs using exact-string matching' with no exception. RFC 9700 §2.1 and §4.1.3, and the OAuth 2.1 §2.3.1 the YAML itself cites, require exact matching except that for native-app loopback redirect URIs the AS MUST allow a variable port (RFC 8252 §7.3). An AS that follows the text literally rejects the ephemeral-port loopback redirects used by CLI and desktop apps. The text also does not say that comparison is RFC 3986 §6.2.1 simple string comparison, with no normalization.  
   *Suggested change:* Change to: '…compare using simple string comparison (RFC 3986 §6.2.1; no normalization or pattern matching), except that for native-app loopback redirect URIs (http://127.0.0.1 or http://[::1]) the port component MUST be allowed to vary (RFC 9700 §2.1, §4.1.3; RFC 8252 §7.3; OAuth 2.1 §2.3.1).'  
   *Verifier: confirmed.*

10. **[MEDIUM] Incorrect: lines 789-792 — components.parameters.CodeChallengeMethod.description**  
   *Reference:* RFC 9700 §2.1.1, §4.8, §4.8.2  
   '(RFC 9700 §4.8 describes the downgrade attack that plain invites.)' is wrong. RFC 9700 §4.8 ('PKCE Downgrade Attack') is about an attacker removing code_challenge so the AS issues a code not bound to PKCE. Its countermeasure (§4.8.2) is a token-endpoint rule that has nothing to do with plain. The weakness of plain is covered by RFC 9700 §2.1.1 (attacker A4 reading the request) and OAuth 2.1-16 §7.5.2. The misattribution suggests the S256-only enum mitigates §4.8 and hides the real MUST, which the YAML does not model (see the gap).  
   *Suggested change:* Replace with: 'plain exposes the verifier to anyone who can read the authorization request (RFC 9700 §2.1.1); OAuth 2.1-16 §7.5.2 forbids it. The separate PKCE downgrade attack in RFC 9700 §4.8 (stripping code_challenge) is mitigated at /token — see AuthorizationCodeTokenRequest.code_verifier.'  
   *Verifier: confirmed.*

11. **[MEDIUM] Incorrect: lines 2536-2540 — components.schemas.JWTAccessTokenClaims.properties.sub.description**  
   *Reference:* RFC 9700 §4.15, §4.15.1 (RFC 9068 §2.2, §5)  
   'for client_credentials grant this MUST equal client_id' makes mandatory the pattern RFC 9700 §4.15 warns about. RFC 9068 §2.2 only says sub SHOULD correspond to an identifier the AS uses for the client. When client identifiers and user identifiers share the sub namespace, a client that can choose its client_id (e.g., through dynamic registration) can impersonate a resource owner. §4.15.1 says the AS SHOULD NOT let clients influence client_id or such claims and, where that cannot be avoided, MUST give resource servers another way to tell the two token types apart. The YAML gives no countermeasure.  
   *Suggested change:* Change to: 'For grants without a resource owner (e.g., client_credentials), SHOULD correspond to an identifier the AS uses for the client (RFC 9068 §2.2). The AS SHOULD NOT let clients choose client_id values that can collide with user sub values; otherwise it MUST give resource servers another way to tell client-only tokens from user tokens (RFC 9700 §4.15.1).'  
   *Verifier: confirmed.*

12. **[MEDIUM] Incorrect: lines 1285-1289 — components.schemas.RefreshTokenRequest.description; lines 1435-1439 — components.schemas.TokenResponse.properties.refresh_token.description**  
   *Reference:* RFC 9700 §2.2.2, §4.14.2  
   Sender-constraining is given as '(DPoP)' only, but RFC 9700 §4.14.2 names both RFC 8705 (mTLS) and RFC 9449 (DPoP); RFC 8705 §4 explicitly covers certificate-bound refresh tokens for public clients. Both places also say rotation or sender-constraint is 'RECOMMENDED for confidential clients'. Neither RFC 9700 §2.2.2/§4.14.2 nor OAuth 2.1 §4.3 says that: RFC 9700 only notes that RFC 6749 already binds a confidential client's refresh tokens to that client.  
   *Suggested change:* Change to '…MUST be sender-constrained (DPoP, RFC 9449, or mTLS, RFC 8705 §4) or rotated on every use (RFC 9700 §2.2.2, §4.14.2). For confidential clients the refresh token is bound to the authenticated client (RFC 6749 §6); rotation and sender-constraint are optional hardening.'  
   *Verifier: confirmed.*

13. **[LOW] Gap: Referer-leakage countermeasures on authorization endpoint pages (Referrer-Policy, no third-party content)**  
   *Reference:* RFC 9700 §4.2.2, §4.2.4  
   §4.2.4: 'The page rendered as a result of the OAuth authorization response and the authorization endpoint SHOULD NOT include third-party resources or links to external sites'. Suppressing Referer with 'Referrer-Policy: no-referrer' is the recommended reinforcement, because state and request parameters can leak from the AS page (§4.2.2). The /authorize 200/400 HTML responses (190-205) carry no headers and no such note.  
   *Suggested change:* Add components.headers.ReferrerPolicy (const no-referrer) on /authorize 200 and 400. Add one sentence to their descriptions forbidding third-party resources and external links on these pages (RFC 9700 §4.2.4).  
   *Verifier: partially correct —* RFC 9700 §4.2.4 makes one normative statement here: the authorization-endpoint page SHOULD NOT include third-party resources or links to external sites. Referrer-Policy: no-referrer is one of several optional mitigations, not a RECOMMENDED one. Adding a ReferrerPolicy header and a no-third-party-content note to /authorize 200 and 400 is a reasonable documentation fix, but the severity is low.

14. **[LOW] Gap: PKCE support must be discoverable (code_challenge_methods_supported)**  
   *Reference:* RFC 9700 §2.1.1, §4.7.1  
   §2.1.1: 'Authorization servers MUST provide a way to detect their support for PKCE. It is RECOMMENDED … to publish the element code_challenge_methods_supported'. Clients may rely on PKCE instead of state for CSRF only after confirming support (§4.7.1). OAuthServerMetadata.required (1937-1940) lists only issuer and response_types_supported. code_challenge_methods_supported (2176-2185) is optional, and its description does not explain this role, so a server could omit it and offer no other way to detect PKCE.  
   *Suggested change:* For this OAuth 2.1 profile, add code_challenge_methods_supported to OAuthServerMetadata.required (minItems: 1, contains: {const: S256}). At minimum add to its description: 'RECOMMENDED by RFC 9700 §2.1.1/§4.7.1 as how clients detect PKCE support; an OAuth 2.1 AS always publishes it with S256.'  
   *Verifier: confirmed.*

15. **[LOW] Gap: Statement of TLS requirements (BCP 195)**  
   *Reference:* RFC 9700 §2.6  
   §2.6 RECOMMENDS end-to-end TLS according to BCP 195 (RFC 8996, RFC 9325). The YAML implies TLS only through servers https://{issuer} (77-86) and https wording on issuer and jwks_uri (1944-1964). It never states a transport requirement or cites BCP 195.  
   *Suggested change:* servers[0].description: 'HTTPS only; TLS per BCP 195 (RFC 9325; TLS 1.0/1.1 deprecated by RFC 8996; TLS 1.3 is now RFC 9846). See RFC 6749 §3.1/§3.2 and RFC 9700 §2.6.'  
   *Verifier: partially correct —* The YAML never states its transport requirements. Cite RFC 6749 §3.1/§3.2 and OAuth 2.1-16 §1.5 for the AS (https only, with an exception only for loopback redirect URIs; TLS 1.3 is RFC 9846), and RFC 9700 §2.6 for end-to-end TLS between client and RS. BCP 195 is RFC 8996 + RFC 9325 + RFC 9852.

16. **[LOW] Gap: TLS-terminating reverse proxies and forwarded client-certificate headers (mTLS)**  
   *Reference:* RFC 9700 §4.13  
   When mTLS client authentication or certificate-bound tokens (2676-2681, 2193-2198, 1997-2013) run behind a TLS-terminating proxy, the certificate reaches the AS in a header such as Client-Cert / Client-Cert-Chain (RFC 9440). The proxy MUST sanitize inbound security-relevant headers, and the proxy-to-AS link MUST be protected. The mtls scheme description says nothing about this.  
   *Suggested change:* Append a deployment note to securitySchemes.mtls.description citing RFC 9700 §4.13 and RFC 9440.  
   *Verifier: confirmed.*

17. **[LOW] Gap: Detection of constant PKCE challenge or nonce values**  
   *Reference:* RFC 9700 §2.1.1 (also §2.1, §4.5.3.2)  
   The challenge or nonce MUST be transaction-specific, and 'Authorization servers are encouraged to make a reasonable effort at detecting and preventing the use of constant values for the PKCE challenge or OpenID Connect nonce'. CodeChallenge (760-778) and Nonce (797-805) do not mention this. Nonce also omits its CSRF and code-injection role, which the YAML's nonce exception depends on.  
   *Suggested change:* Add one sentence to the CodeChallenge and Nonce descriptions. Note in Nonce that it provides CSRF/code-injection protection only if the client validates it in the ID Token from /token (RFC 9700 §4.5.3.2).  
   *Verifier: confirmed.*

18. **[LOW] Gap: iss on authorization error responses; issuer identification always on**  
   *Reference:* RFC 9700 §2.1, §4.4.2.1 (RFC 9207 §2)  
   The mix-up defense needs iss on every authorization response, including errors. The 302 prose (161-169) says so. However, ErrorResponse (1465-1533), which the YAML also uses for authorization-endpoint redirect errors (state, 1529-1533), has no iss, and authorization_response_iss_parameter_supported defaults to false (2206-2211).  
   *Suggested change:* Add ErrorResponse.properties.iss (string, format uri, per RFC 9207 §2). Recommend that an OAuth 2.1 reference AS always sends iss and advertises authorization_response_iss_parameter_supported: true.  
   *Verifier: confirmed.*

19. **[LOW] Gap: PAR/JAR with client authentication may establish the redirect_uri**  
   *Reference:* RFC 9700 §4.1.3 (final paragraph)  
   If the origin and integrity of the request are verified (RFC 9101, or RFC 9126 with client authentication), the AS MAY trust the redirect URI without further checks. PARRequest.redirect_uri (1600-1602) has no description, and RedirectUri (720-727) states pre-registered exact matching without exception.  
   *Suggested change:* Describe PARRequest.redirect_uri: 'RedirectUri rules apply. An AS MAY accept per-request redirect URIs from authenticated PAR or signed JAR requests (RFC 9700 §4.1.3; RFC 9126 §2.4), but the https/loopback rule of RFC 9700 §2.6 still applies.'  
   *Verifier: confirmed.*

20. **[LOW] Gap: Resource server enforcement of audience**  
   *Reference:* RFC 9700 §2.3, §4.10.2  
   Every resource server MUST check that the token was meant for it and refuse it otherwise. ProtectedResourceError (1091-1107) does not say that an audience mismatch is answered with 401 invalid_token.  
   *Suggested change:* Add to ProtectedResourceError.description: 'including tokens whose aud/resource does not match this RS (RFC 9700 §2.3) → 401 invalid_token'.  
   *Verifier: confirmed.*

21. **[LOW] Incorrect: The 303 and 307 rule is attached without its condition to GET /authorize** — *found by the verifier*  
   *Reference:* RFC 9700 §4.12 (with §2.1); OAuth 2.1-16 §7.5.4  
   The 303 and 307 rule is attached without its condition to GET /authorize. RFC 9700 limits both the 307 ban and the 303 SHOULD to redirects of requests that may carry user credentials, that is, the AS's own login or consent form POST. The YAML does not model that POST.  
   *Suggested change:* Reword as: 'When the AS redirects to redirect_uri in response to a POST that may carry user credentials (login or consent form), it MUST NOT use 307 and SHOULD use 303 (RFC 9700 §4.12; OAuth 2.1-16 §7.5.4). For the GET authorization request itself, 302 and 303 are equivalent.' Add the same note to the 200 text/html description.

22. **[LOW] Gap: The YAML does not mention the optional dummy fragment ('#_') on Location URLs, which stops browsers from reattaching an inbound fragment to the redirect.** — *found by the verifier*  
   *Reference:* RFC 9700 §4.1.3  
   The YAML does not mention the optional dummy fragment ('#_') on Location URLs, which stops browsers from reattaching an inbound fragment to the redirect.  
   *Suggested change:* Add to the 302/303 description: 'For query-mode responses the AS MAY append a dummy fragment (e.g., #_) to the Location URL so that a fragment on the inbound request is not reattached (RFC 9700 §4.1.3).'

23. **[LOW] Gap: The YAML does not say what the AS does when code_challenge arrives without code_challenge_method** — *found by the verifier*  
   *Reference:* RFC 9700 §2.1.1 (with RFC 7636 §4.3; OAuth 2.1-16 §4.1.1, §4.1.2.1)  
   The YAML does not say what the AS does when code_challenge arrives without code_challenge_method. Under RFC 7636 §4.3 that means plain, which this S256-only profile forbids. As written, an RFC 7636-default implementation would silently accept plain.  
   *Suggested change:* State that code_challenge_method is REQUIRED whenever code_challenge is present (OAuth 2.1-16 §4.1.1), and that a request with code_challenge but no method, or with plain, is rejected with invalid_request (OAuth 2.1-16 §4.1.2.1).

## draft-ietf-oauth-security-topics-update-03 Updates to OAuth 2.0 Security Best Current Practice

*July 2026 · Internet-Draft -03 (OAuth WG document, intended BCP; would update RFC 6749, 6750, 7521, 7522, 7523, 9700; expires 7 January 2027) · YAML coverage: **none** · relevance to an AS: recommended · vendoring: catalog-only*

**What it is.** This is an in-progress addendum to RFC 9700 that documents four attack classes published after the BCP. They are: audience injection against private_key_jwt and other signed client assertions; Cross-toolkit OAuth Account Takeover (COAT, a generalized mix-up in clients that integrate many tools or AI connectors) with its CORF variant; cross-user OAuth session fixation, which PKCE cannot stop; and shared consent in brokered OAuth. Almost every countermeasure is client- or broker-side. Clients must use the AS issuer identifier as the sole client-assertion audience, use per-connection-context redirect URIs plus a session check (or issuer-based mix-up defense), and bind fixated sessions to the initiating user. Brokers must use per-downstream-client upstream registrations or show their own consent per client.

**Why it was created.** Research published in 2025-2026 showed attacks that RFC 9700 does not cover. The sources are: audience-injection research from the University of Stuttgart; CUHK studies of integration platforms and connector account linking (USENIX Security 2025, IEEE S&P 2026); and a brokered-SSO analysis (2025). The attacks arise in clients that talk to many authorization servers, in integration platforms and agentic-AI 'toolkits', in OAuth-as-a-Service / token vaults, and in SSO brokers. The WG adopted the individual draft (draft-wuertele-…) to extend the BCP instead of reopening RFC 9700.

<details><summary>Already modeled in the YAML (8)</summary>

- client_assertion / client_assertion_type form fields, the carrier whose aud the draft constrains (not constrained in the YAML): components.schemas.ClientAuthFields (1191-1200)
- Endpoints that accept client assertions, i.e. the audience-injection surface: /par (422-476; PARRequest allOf ClientAuthFields 1591); /revoke (273-310; RevocationRequest 1795-1796); /device_authorization (368-417; DeviceAuthorizationRequest 1544); /introspect (315-363; IntrospectionRequest 1682); CIBA backchannel_authentication_endpoint metadata (1985-1988)
- Issuer identifier the draft wants as the sole audience: OAuthServerMetadata.issuer (1944-1950)
- Affected authentication methods: private_key_jwt / client_secret_jwt in token_endpoint_auth_methods_supported (2037-2049); token_endpoint_auth_signing_alg_values_supported (2050-2056)
- JWT-bearer authorization grant, also exposed per §2.1.1.4: JWTBearerTokenRequest.assertion (1338-1345), which names the token endpoint URL as aud
- RFC 9207 iss, usable as the COAT replacement countermeasure (§2.2.2): /authorize 302 prose (164-169); authorization_response_iss_parameter_supported (2206-2211)
- state (the client-side session-fixation vector, §2.3): components.parameters.State (750-758)
- prompt=none silent re-consent, abused in COAT and shared-consent flows: components.parameters.Prompt (807-819)

</details>

**Follow-up on the May-2026 validation notes.** None. There is no prior validation file, because the draft is neither vendored nor covered by the May-2026 audit.

**Notes.** The four attacks: (1) Audience injection (§2.1). A malicious AS publishes an honest AS's token endpoint as its own. A client that uses the same client_id and key at both ASes and authenticates with private_key_jwt or other RFC 7521/7522/7523 assertions at a non-token endpoint (PAR, revocation, device authorization, CIBA; the draft says this list is not exhaustive) hands the attacker an assertion that is valid at the honest AS. DPoP cannot help, because the attacker fully impersonates the client. (2) COAT (§2.2). A generalized mix-up in clients that host many 'toolkits'/connectors (agentic AI, integration platforms, token vaults). Distinct redirect URIs alone do not prevent it. The CORF variant forces the attacker's code or token onto the victim. (3) Cross-user session fixation (§2.3). A client (often a BFF or native-app backend) that fixates a session through state or a pre-authorization URI lets the attacker's account receive the victim's tokens. PKCE is preserved and does not help; the client MUST bind the fixated session to the initiating user. (4) Shared consent in brokered OAuth (§2.4). Effect on the YAML: no new endpoints, parameters, error codes or metadata, and no IANA actions. Only descriptions change (client_assertion aud, jwt-bearer aud, consent scoping, iss always on). Most of the effect will actually come from draft-ietf-oauth-rfc7523bis, which is about to become an RFC. Stale references in -03: [CDFS] draft -15 is now RFC 10027 (BCP 247, Aug 2026), and [OAUTH-7523bis] is cited at -05 but is now -11 in the RFC Editor queue. Datatracker (2026-10-10): WG Document, -03 is the latest revision.

### Findings (0 high · 1 medium · 3 low)

1. **[MEDIUM] Gap: Audience of client assertions: client_assertion aud = AS issuer identifier, as a single value**  
   *Reference:* draft-ietf-oauth-security-topics-update-03 §2.1.1.3, §2.1.2, §2.1.2.1, §2.1.2.2, §2.1.2.3  
   Clients that use more than one AS and sign client assertions MUST put the issuer identifier (or the exact target endpoint URI) in aud as the only value, not an array, at every endpoint: token, PAR, revocation, device authorization, CIBA, and by the same logic introspection. For the AS the draft adds no new MUST (RFC 7519 §4.1.3 already requires accepting such assertions), and the AS MAY restrict accepted audiences. draft-ietf-oauth-rfc7523bis-11 §4 (RFC Editor queue) makes it an AS MUST: reject any client-authentication JWT whose sole aud is not its issuer, and never accept the token endpoint URL. ClientAuthFields.client_assertion (1191-1196) gives no audience rule.  
   *Suggested change:* Extend ClientAuthFields.client_assertion.description: 'JWT whose aud MUST be the AS issuer identifier (OAuthServerMetadata.issuer) as a single string, at every endpoint that accepts client assertions. The AS rejects other audiences, including the token endpoint URL (draft-ietf-oauth-rfc7523bis-11 §4; security-topics-update §2.1.2). typ client-authentication+jwt is RECOMMENDED but not enforced.' Optionally add a documentation schema ClientAssertionClaims (required iss, sub, aud, exp; jti per OIDC Core §9; aud of type string).  
   *Verifier: confirmed.*

2. **[LOW] Gap: Audience of JWT authorization-grant assertions**  
   *Reference:* draft-ietf-oauth-security-topics-update-03 §2.1.1.2, §2.1.1.4  
   The draft names token-endpoint-as-audience as the root cause and notes that jwt-bearer authorization grants are exposed in a similar way. JWTBearerTokenRequest.assertion (1340-1345) presents 'aud (the AS token endpoint URL)' as the definition. RFC 7523 §3 only says the token endpoint URL MAY be used, and 7523bis-11 §4(a) allows the issuer identifier or the token endpoint URL.  
   *Suggested change:* Change to 'aud: identifies this AS — its issuer identifier (preferred for clients that use several ASes) or its token endpoint URL (RFC 7523 §3; 7523bis §4)'.  
   *Verifier: confirmed.*

3. **[LOW] Gap: Per-client consent when the AS brokers to upstream authorization servers**  
   *Reference:* draft-ietf-oauth-security-topics-update-03 §2.4.2, §2.4.2.1, §2.4.2.2  
   If the AS federates to upstream ASes ('login with X') it is a broker. It MUST either use a separate upstream registration per downstream client, or show a broker-side consent that names the downstream client, remember that consent per client only, and never reuse it across clients. The YAML does not model upstream federation, and the /authorize consent page (190-195) and Prompt (807-819) say nothing about how consent is scoped.  
   *Suggested change:* Add a sentence to the /authorize description: consent decisions are kept per client_id and never reused across clients, prompt=none never skips consent for a client that has not yet received consent, and a brokering deployment must follow §2.4.2.  
   *Verifier: confirmed.*

4. **[LOW] Gap: Issuer identification so clients can use the mix-up defense as their COAT countermeasure**  
   *Reference:* draft-ietf-oauth-security-topics-update-03 §2.2.2  
   Clients may replace per-context redirect URIs with RFC 9700's issuer-based mix-up defense only when the AS is identified by an issuer that is resolved through metadata at runtime and the issuer is returned via RFC 9207 iss (or embedded in the redirect URI). The YAML supports iss, but only as an option (default false, 2206-2211; conditional prose at 164-169).  
   *Suggested change:* State that the reference profile always includes iss and advertises authorization_response_iss_parameter_supported: true (see the RFC 9700 low gap).  
   *Verifier: confirmed.*

## Verifier corrections to the summaries above

- cluster_notes: 'Still missing are four RFC 9700 MUSTs' is too low. Besides §2.6 (http redirect URIs), §2.1.1/§4.8.2 (downgrade), §4.2.4 (single-use codes) and §4.16 (clickjacking), the YAML also lacks three more AS MUSTs. §4.11.2: authenticate the user before any redirect, error redirects included. §2.6: CORS MUST NOT be supported at the authorization endpoint. §4.14.2: refresh tokens MUST stay bound to the consented scope and resource servers, and grant-encoding refresh tokens MUST be integrity-protected. The YAML also contradicts the §4.1.3 MUST to allow variable loopback ports. The entry's gap list carries these at medium, but the headline count should include them.
- cluster_notes: 'Three YAML statements are wrong'. The RFC 9700 incorrect array has four entries. The fourth (RefreshTokenRequest 1285-1289 and TokenResponse.refresh_token 1435-1439) also contradicts RFC 9449 §5, which says refresh tokens issued to confidential clients are not bound to the DPoP key.
- cluster_notes and the RFC 9700 prior_validation_followup undercount the May-2026 audit's invented quotes. 'Three of its quoted MUSTs' is too few. Besides W1, M4 and M7, these are not in RFC 9700 either. M1: 'The authorization server's issuer identifier ... MUST be sent in the authorization response'. M3's second sentence: 'Pattern matching (e.g., wildcards, regular expressions, partial path matches) MUST NOT be used'; the same quote also drops the localhost-port exception of §2.1. 'The implicit grant ... MUST NOT be used': §2.1.2 says clients SHOULD NOT. 'Pushed Authorization Requests [RFC9126] is RECOMMENDED'. 'TLS 1.2 or later' attributed to §2.6. The audit also cites subsections that do not exist (§2.1.1.1, §2.1.1.1.1, §2.1.1.4) and a '§4.1.1 Insufficient Client Identifier Validation'. The off-by-one numbering from §4.10 onward is reported correctly. The M3 misquote is the likely source of the missing loopback exception at YAML 720-727, just as W1 led to 791-792.
- cluster_notes, and the RFC 9700 gap 'Statement of TLS requirements (BCP 195)': per the RFC index downloaded 2026-10-10, BCP 195 now has three RFCs: RFC 8996, RFC 9325 and RFC 9852 ('New Protocols Using TLS Must Require TLS 1.3', BCP, July 2026, updates RFC 9325). 'TLS 1.3 is now RFC 9846' (July 2026, obsoletes RFC 8446) is correct. The RFC 9700 §2.6 TLS sentence is about the client-to-RS hop. The AS https MUSTs come from RFC 6749 §3.1/§3.2 and OAuth 2.1-16 §1.5.
- RFC 9700 summary ('PKCE (S256) for every client') and modeled_elements ('§2.1.1/§4.5.3.1 PKCE for all clients') overstate RFC 9700. §2.1.1 makes PKCE a MUST for public clients only. For confidential clients it is RECOMMENDED, and confidential OIDC clients MAY use nonce instead. S256 is a client SHOULD, and only AS support for PKCE is a MUST. The entry's own notes state this correctly.
- RFC 9700 why_created: 'developed as draft-ietf-oauth-security-topics from 2016' is slightly off. The work began as the individual draft-lodderstedt-oauth-security-topics-00 (12 November 2016). The WG document draft-ietf-oauth-security-topics-00 is dated 12 March 2017.
- RFC 9700 modeled_elements: '§4.2.4/§4.3 form_post and PAR as leakage countermeasures' is wrong about PAR. §4.2.4 and §4.3 list form_post but not PAR. PAR appears only in §4.1.3, where a verifiable request origin lets the AS trust the redirect URI.
- draft-ietf-oauth-security-topics-update-03 summary: 'Clients must use the AS issuer identifier as the sole client-assertion audience' simplifies §2.1.2. Multi-AS clients MUST use one of two countermeasures: the issuer identifier as sole audience (RECOMMENDED), or the exact target endpoint URI as sole audience (§2.1.2.2). The MUST does not apply if the attack is prevented by other means, such as separate keys per AS.
- cluster_notes: 'PARRequest.code_challenge_method default: S256 (1615) contradicts RFC 7636 §4.3' is true on paper but has no effect. PARRequest lists code_challenge_method as required (1594), and OAuth 2.1-16 §4.1.1 makes it REQUIRED. The plain-default risk is real only at /authorize, where the parameter is optional (780-795).
- cluster_notes: the CodeChallengeMethod text at 785-788 ('OPTIONAL ... defaulting to plain') matches the vendored draft-ietf-oauth-v2-1-15 §4.1.1 (line 1983). It is out of date against -16, not a misreading. The same applies to 'OAuth 2.1 §7.5.3' for 307 (§7.5.3 in -15, §7.5.4 in -16) and to the conditional iss wording (iss is REQUIRED in -16 §4.1.2).
