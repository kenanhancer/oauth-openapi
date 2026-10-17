# Device grant & cross-device security — RFC 8628, 10027

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 8628](#rfc-8628-oauth-20-device-authorization-grant) | August 2019 | Proposed Standard | mostly | 0 | 4 | 17 |
| [RFC 10027](#rfc-10027-best-current-practice-for-security-of-cross-device-flows) | August 2026 | Best Current Practice (BCP 247) | none | 0 | 2 | 7 |

**Cluster notes.** RFC 8628's IANA-registered surface is fully present in oauth-openapi.yaml: all 7 values (device_code parameter, grant-type URN, authorization_pending, slow_down, access_denied, expired_token, device_authorization_endpoint) are found in the YAML by the IANA comparison, and the IANA absence list has no entries for RFC 8628 or RFC 10027 (RFC 10027 §8 has no IANA actions). The key May-2026 fixes are in: no-store headers on /device_authorization, client_id made conditional, and client_assertion carried in ClientAuthFields. The remaining RFC 8628 gaps are mostly descriptive or security-related. (1) grant_types_supported never mentions the device URN. (2) The AS-hosted verification page is not documented at all, although RFC 8628 §3.3 makes it a MUST, and §3.3.1/§5.4 add anti-phishing SHOULDs. (3) user_code has no entropy or rate-limit guidance. (4) The polling contract appears only on /device_authorization. (5) authorization_details is missing from the device request, although RFC 9396 §3 names that request. RFC 10027 (BCP 247, Aug 2026, formerly draft-ietf-oauth-cross-device-security) is neither vendored nor mentioned anywhere in the repo: grep for cross-device, 10027, CDCP and phish returns nothing outside rfc-sources. It adds no wire elements. It does impose process MUSTs (risk assessment; choosing mitigations from §6.1) and SHOULD-level AS behaviour (proximity, a consent UX where decline is prominent, and protocol selection that ranks FIDO2/WebAuthn plus code+PKCE above CIBA, and CIBA above the device grant). None of this appears in the YAML descriptions. CIBA, which RFC 10027 normatively references as the preferred alternative, exists in the YAML only as metadata. The repo's own audit deliberately deferred CIBA operation modeling (references/audit/rfc-audit-synthesis.md, 'Application policy'). OpenAPI 3.2.0 adds a native deviceAuthorization OAuth flow, but the YAML is 3.1.0. The modular tree (oauth-openapi-modular/spec/components/schemas/device.yaml and spec/paths/device-authorization.yaml) has the same data as the single file for this surface. Primary sources used for verification: CIBA Core 1.0, OAS 3.2.0, and the RFC 8628 and RFC 10027 errata pages.

## RFC 8628 OAuth 2.0 Device Authorization Grant

*August 2019 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** Defines the 'device flow' for internet-connected devices that lack a browser or have awkward input (smart TVs, consoles, printers, CLI tools). The device POSTs its client_id (and optional scope) to a new device authorization endpoint and receives a secret device_code, a short user_code, a verification_uri (plus an optional verification_uri_complete for QR codes), expires_in and a polling interval. The user opens the URI on a second device, signs in, enters or confirms the code and approves; meanwhile the device polls the normal token endpoint with grant_type=urn:ietf:params:oauth:grant-type:device_code and gets authorization_pending/slow_down until it receives tokens, access_denied or expired_token. AS metadata gains device_authorization_endpoint, and the device URN is advertised in grant_types_supported.

**Why it was created.** Every RFC 6749 end-user grant assumes the client can open a browser on the same device and receive a redirect, which is impossible on a TV or printer; typing passwords with a remote control is impractical. A device profile existed in early OAuth 2.0 drafts but was removed before RFC 6749 for lack of deployment experience (RFC 8628 Acknowledgements; draft-recordon-oauth-v2-device). RFC 8628 standardized an interoperable flow that needs only an outbound HTTPS channel from the device. It moves the user interaction to a secondary device and uses polling instead of redirects.

<details><summary>Already modeled in the YAML (17)</summary>

- Device authorization endpoint: paths./device_authorization.post (368-417), operationId deviceAuthorization (371), tag Device Flow (93-94, 370); HTTPS-only server URL (78) satisfies the §3.1 TLS MUST
- Form-encoded request body -> components.schemas.DeviceAuthorizationRequest (392-397, 1538-1550)
- client_id, conditionally REQUIRED (§3.1): ClientAuthFields.client_id via allOf (1544, 1178-1184), with the conditional rule stated at 1539-1542
- scope (§3.1): DeviceAuthorizationRequest (1548-1550)
- Client authentication per RFC 6749 §3.2.1 (§3.1/§3.4): security clientSecretBasic/mtls/{} (414-417); client_secret, client_assertion, client_assertion_type in ClientAuthFields (1185-1200); 401 -> components.responses.ClientAuthError (412-413, 1108-1125)
- 200 application/json response with Cache-Control: no-store and Pragma: no-cache (399-409; headers 990-999)
- DeviceAuthorizationResponse required [device_code, user_code, verification_uri, expires_in] (1552-1555)
- device_code (1557-1559); user_code with examples (1560-1563); verification_uri format uri (1564-1567); verification_uri_complete (1568-1571); expires_in (1572-1574); interval with default 5 (1575-1578)
- Device endpoint errors answered like the token endpoint (§3.2): 400 -> components.responses.OAuthError (410-411, 1063-1073) -> ErrorResponse (1465-1533)
- Device access token request (§3.4): components.schemas.DeviceCodeTokenRequest (1309-1324); grant_type const 'urn:ietf:params:oauth:grant-type:device_code' (1317-1319); device_code required (1315, 1320-1324); client_id via ClientAuthFields (1312)
- Grant routing: TokenRequest.oneOf (1160) and discriminator mapping (1169); /token description bullet (222)
- Success response per RFC 6749 §5.1 (§3.5): /token 200 TokenResponse with no-store headers (248-260; schema 1400-1460)
- Polling error codes (§3.5/§7.3) in ErrorResponse.error enum: authorization_pending (1495), slow_down (1496), expired_token (1497), access_denied (1485); /token 400 -> OAuthErrorWithDPoPNonce (261-262)
- Polling rules prose (§3.5, partial) in /device_authorization description (381-384); device_code non-display (386, 1324); user_code normalization (387-388)
- AS metadata device_authorization_endpoint (§4): OAuthServerMetadata (1977-1980), served at /.well-known/oauth-authorization-server (630-648) and /.well-known/openid-configuration (603-625); also mtls_endpoint_aliases.device_authorization_endpoint (2007, RFC 8705 §5)
- grant_types_supported array (2033-2036): present, but the device URN is not documented (see gaps)
- Extension: RFC 8707 resource on the device request (1545) and on the device token request (1313)

</details>

**Follow-up on the May-2026 validation notes.** The May-2026 notes (references/rfc-validation/8628-device-grant.md) list 5 MISSING, 4 WRONG and 5 NICE-TO-HAVE items. Fixed (4 of 9 must-fix): (1) Cache-Control/Pragma on the /device_authorization 200 (401-405). (2) Response pinned to application/json (406-409). (3) device_code non-display note (386, 1324). (4) client_assertion support, resolved by design through ClientAuthFields in DeviceAuthorizationRequest (1544, 1191-1200) instead of a clientAssertion security scheme (rationale at 2665-2674). Partially fixed (2): polling rules are documented, but only on /device_authorization (381-384) and without the wait-at-least-interval, cumulative slow_down and timeout-backoff rules; user_code normalization was added to operation prose (387-388), but the field (1562) still lacks charset/entropy guidance and keeps the off-charset '26FB-FA97' example. Still open (3): device URN not documented in grant_types_supported (2033-2036); expires_in has no minimum/example (1572-1574); verification_uri lacks the 'short and easy to remember' guidance (1567). NICE-TO-HAVE: 0 of 5 done (worked example, §5.4 phishing note, timeout backoff, §6.1 charset citation, interval minimum/example). Correction to the May notes: they called client_id 'required' in both device schemas correct. The current YAML instead makes it conditional (1539-1542, 1180-1184), which matches §3.1/§3.4.

**Notes.** All 7 RFC 8628 IANA registrations are present (the IANA comparison finds all of them). The vendored text is byte-identical to rfc-editor.org. One erratum exists: Errata ID 5840 (Reported, Technical, §5.2 'authorization code' should read 'access token'); it does not affect the YAML. RFC 8628 is not formally updated or obsoleted; RFC 10027 adds security guidance without an Updates: header. OAuth 2.1 draft-16 uses the device grant as its §4.4 extension-grant example and lists RFC 8628 in Appendix D, but does not require it. RFC 8707 resource on the device token request is fine ('for all grant types', RFC 8707 §2.2); on the device authorization request it is a reasonable extension. CIBA Core §11 reuses authorization_pending, slow_down, expired_token and access_denied. draft-ietf-oauth-security-topics-update-03 §2.1.1.3 lists the Device Authorization Endpoint among endpoints exposed to client-assertion audience injection; this matters when private_key_jwt is used at /device_authorization and belongs to the assertion/rfc7523bis cluster. The modular split matches the single file for this surface.

### Findings (0 high · 4 medium · 17 low)

1. **[MEDIUM] Gap: OAuthServerMetadata.grant_types_supported: advertising the device_code URN**  
   *Reference:* RFC 8628 §4  
   §4 says the AS declares support by including 'urn:ietf:params:oauth:grant-type:device_code' in grant_types_supported. At 2033-2036 the property is a free string array. Its only guidance is the RFC 8414 default ['authorization_code','implicit']. Nothing tells an implementer to advertise the device URN, or that omitting the array advertises implicit (excluded by this profile) and not the device grant. This was a May-2026 finding and is still open.  
   *Suggested change:* At 2033-2036 add examples: [[authorization_code, refresh_token, client_credentials, 'urn:ietf:params:oauth:grant-type:device_code', 'urn:ietf:params:oauth:grant-type:jwt-bearer', 'urn:ietf:params:oauth:grant-type:token-exchange']]. Extend the description: 'Include urn:ietf:params:oauth:grant-type:device_code whenever device_authorization_endpoint is published (RFC 8628 §4). Under this OAuth 2.1 profile always publish the array explicitly, because the RFC 8414 default would advertise implicit.'  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: End-user verification page (the AS-hosted page at verification_uri / verification_uri_complete)**  
   *Reference:* RFC 8628 §3.3, §3.3.1, §5.1, §5.4; RFC 9700 §4.16  
   §3.3: the AS MUST implement a user interaction that starts at verification_uri and collects the user_code. §3.3.1: when the user arrives via verification_uri_complete, the server SHOULD display the user_code and ask the user to confirm it matches the device. §5.4: it is RECOMMENDED to tell the user they are authorizing a device and to confirm possession, and the AS SHOULD display device information. §5.1: the server should rate-limit user_code attempts. RFC 9700 §4.16 (OAuth 2.1-16 §7.11): CSP/anti-framing protection is needed on 'the device authorization endpoint' user pages. None of these obligations is modeled or described; by contrast, /authorize's HTML interaction is approximated at 109-205. These are MUST/SHOULD-level obligations. The RFC leaves the path and parameters to the AS, so this is a documentation/modeling gap rather than a fixed wire contract.  
   *Suggested change:* Add an illustrative operation: '/device': {get: {tags: [Device Flow], operationId: deviceVerification, summary: 'End-user verification page (illustrative path; the real URL is the advertised verification_uri)', parameters: [{name: user_code, in: query, required: false, description: 'Present when reached via verification_uri_complete; the name and encoding are AS-defined (RFC 8628 §3.2 example)', schema: {type: string}}], responses: {'200': {description: 'HTML page that collects or confirms user_code, authenticates the user and offers approve/deny', content: {text/html: {schema: {type: string}}}}}}}. Its description should state: §3.3 MUST; confirm the prefilled user_code (§3.3.1); show device information and confirm possession (§5.4); rate-limit code entry (§5.1); send Content-Security-Policy frame-ancestors / X-Frame-Options (RFC 9700 §4.16). If a new path is unwanted, put the same text in paths./device_authorization.post.description.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: DeviceAuthorizationResponse.user_code: entropy, rate limiting, uniqueness, charset**  
   *Reference:* RFC 8628 §5.1, §3.2, §6.1  
   §5.1: the user code SHOULD have enough entropy that, together with rate limiting, brute force is infeasible. For example, an 8-character base-20 code has about 34.5 bits, so only about 5 attempts can be allowed for a 2^-32 success chance. The server should also rate-limit attempts. §3.2: codes are unique and valid for a limited time. §6.1 (non-normative): use the case-insensitive base-20 set 'BCDFGHJKLMNPQRSTVWXZ' or digits, add dashes for readability, and avoid confusable characters. The field description at 1562 says only 'Short, human-typeable code shown to the user.' The May-2026 charset finding is only partly addressed, in operation prose at 387-388.  
   *Suggested change:* Set user_code.description (1562) to: 'End-user verification code (§3.2), unique among outstanding codes and valid for expires_in. SHOULD carry enough entropy that, combined with rate-limiting of code-entry attempts, brute force is infeasible (§5.1; e.g., 8 chars of base-20 BCDFGHJKLMNPQRSTVWXZ is about 34.5 bits). Suggested charsets (§6.1, non-normative): case-insensitive base-20 consonants or digits; dashes may be added for readability and are stripped on input.' Do not add a pattern: the format is AS-defined.  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: DeviceAuthorizationResponse.device_code: entropy**  
   *Reference:* RFC 8628 §5.2, §3.3  
   §5.2: device_code is never typed by users, so 'a very high entropy code SHOULD be used'; guessing it yields the tokens (Erratum 5840 notes that §5.2 should say 'access token', not 'authorization code'). The description at 1559, 'Long opaque device verification code (kept secret by the client).', implies length but not entropy.  
   *Suggested change:* device_code.description: 'Opaque device verification code (§3.2). SHOULD be very high entropy, e.g. at least 128 bits from a CSPRNG, because guessing it yields the tokens (§5.2). Not intended for display to the user (§3.3).' Add examples: ['GmRhmhcxhwAzkoEqiMEg_DnyEysNkuNhszIySk9eS'].  
   *Verifier: partially correct —* The gap is real, but its normative level is understated. device_code entropy is a MUST through RFC 6749 §10.10 / OAuth 2.1-16 §7.7: guessing probability at most 2^-128, and SHOULD be at most 2^-160. It is not only RFC 8628 §5.2's SHOULD. The suggested 'at least 128 bits from a CSPRNG' is therefore the normative minimum, not an example, and severity should be medium.

5. **[LOW] Gap: verification_uri / verification_uri_complete value constraints and descriptions**  
   *Reference:* RFC 8628 §3.2, §3.3, §3.3.1  
   §3.3: it is NOT RECOMMENDED for the AS to put the user_code in verification_uri. §3.2: verification_uri should be short and easy to remember because users type it. verification_uri_complete carries the user_code or 'other information with the same function' and is meant for non-textual transmission (QR, NFC). §3.3.1: clients MUST still display user_code and are RECOMMENDED to still show verification_uri. The YAML says only 'End-user verification URI on the authorization server.' (1567) and 'URI with user_code already embedded (for QR codes).' (1571). The verification_uri wording is a May-2026 finding that is still open.  
   *Suggested change:* verification_uri.description: '... Short and easy to remember; users type it manually (§3.2). It is NOT RECOMMENDED to embed user_code here (§3.3).' with examples: ['https://example.com/device']. verification_uri_complete.description: 'OPTIONAL. verification_uri plus the user_code (or an equivalent handle) for non-textual transmission such as QR or NFC (§3.2, §3.3.1). Clients MUST still display user_code; on arrival the AS SHOULD show the code and ask the user to confirm it matches the device (§3.3.1, §5.4).' with examples: ['https://example.com/device?user_code=WDJB-MJHT'].  
   *Verifier: confirmed.*

6. **[LOW] Gap: authorization_details (RAR) on the device authorization request**  
   *Reference:* RFC 9396 §3 (applied to RFC 8628 §3.1)  
   RFC 9396 §3 explicitly lists 'device authorization requests as specified in [RFC8628]' among the places where authorization_details can replace or augment scope. The YAML accepts it at /authorize (147), /par (1639) and several token requests (1273, 1293, 1354), but not in DeviceAuthorizationRequest (1543-1550). The AuthorizationDetail description (2599) also omits /device_authorization.  
   *Suggested change:* Add '- $ref: '#/components/schemas/AuthorizationDetailsField'' to DeviceAuthorizationRequest.allOf (1543-1550). Mention /device_authorization in the mixin comment (1220-1223) and in AuthorizationDetail.description (2598-2601).  
   *Verifier: confirmed.*

7. **[LOW] Gap: Device-code polling contract on /token**  
   *Reference:* RFC 8628 §3.5 (and §3.1 last paragraph)  
   The polling rules are only partly documented, and only on /device_authorization (381-384). Missing: the client MUST wait at least 'interval' seconds (default 5) between polls; slow_down adds 5 s 'for this and all subsequent requests'; on connection timeouts clients MUST reduce polling frequency (exponential backoff RECOMMENDED); after expired_token the client MAY restart but SHOULD wait for user interaction; clients SHOULD start a device authorization only when the user asks (§3.1). DeviceCodeTokenRequest (1309-1324), the /token description (215-235) and the error enum (1494-1497) carry none of this, so a generator that reads only /token sees no polling contract.  
   *Suggested change:* Put a 'Polling contract (RFC 8628 §3.5)' paragraph with all of the rules above into DeviceCodeTokenRequest.description. Add named examples (authorization_pending, slow_down, access_denied, expired_token) to the /token 400 response, e.g. in components.responses.OAuthErrorWithDPoPNonce or a dedicated DeviceTokenError response.  
   *Verifier: confirmed.*

8. **[LOW] Gap: expires_in / interval constraints and lifetime guidance**  
   *Reference:* RFC 8628 §3.2, §5.4  
   expires_in (1572-1574) and interval (1575-1578) have no minimum and no examples. §5.4 says the code lifetime should be long enough to be usable but short enough to limit phishing use. Still open from May 2026 (MISSING item plus a NICE-TO-HAVE).  
   *Suggested change:* expires_in: add minimum: 1, examples: [1800], and description text '... keep short: long enough to finish verification, short enough to limit phishing use (§5.4).' interval: add minimum: 1, examples: [5].  
   *Verifier: confirmed.*

9. **[LOW] Gap: Worked request and response examples**  
   *Reference:* RFC 8628 §3.1, §3.2  
   There are no examples on the /device_authorization request body or on DeviceAuthorizationResponse. Still open from the May-2026 NICE-TO-HAVE list.  
   *Suggested change:* Add the §3.2 JSON as an example on DeviceAuthorizationResponse (device_code 'GmRhmhcxhwAzkoEqiMEg_DnyEysNkuNhszIySk9eS', user_code 'WDJB-MJHT', verification_uri 'https://example.com/device', verification_uri_complete 'https://example.com/device?user_code=WDJB-MJHT', expires_in 1800, interval 5). Add {client_id: '1406020730', scope: 'example_scope'} as an example on the requestBody at 392-397.  
   *Verifier: confirmed.*

10. **[LOW] Gap: Request-parsing rules for the device authorization request**  
   *Reference:* RFC 8628 §3.1 (restating RFC 6749 §3.1/§3.2)  
   §3.1: parameters sent without a value MUST be treated as omitted; the AS MUST ignore unrecognized parameters; request and response parameters MUST NOT be repeated (RFC 8707 resource is an explicit exception). The open schema (no additionalProperties:false) is consistent with ignoring unknown parameters, but none of these rules is stated; grep finds no 'unrecognized' or 'without a value' text in the YAML.  
   *Suggested change:* Add to DeviceAuthorizationRequest.description (1539-1542): 'Empty-valued parameters are treated as omitted; unrecognized parameters MUST be ignored; parameters MUST NOT repeat, except RFC 8707 resource (§3.1).'  
   *Verifier: confirmed.*

11. **[LOW] Gap: Device clients as public clients; statically distributed credentials**  
   *Reference:* RFC 8628 §5.6, §3.4  
   §5.6: device clients generally cannot keep secrets and, unless additional measures are taken, should be treated as public clients. §3.4 warns about statically distributed client credentials. The {} security option (417) allows public clients, but nothing guides AS policy, e.g. not trusting client secrets baked into firmware and preferring per-device credentials.  
   *Suggested change:* Add to the /device_authorization description: 'Device clients are usually public (RFC 8628 §5.6); a client_secret embedded in shipped firmware does not authenticate a device. Prefer per-device credentials (mTLS or private_key_jwt with hardware-held keys) when the AS must trust specific devices.'  
   *Verifier: confirmed.*

12. **[LOW] Gap: OpenAPI oauth2 security scheme: device flow**  
   *Reference:* RFC 8628 §3.1, §3.4 (OpenAPI 3.2.0 OAuth Flows Object)  
   components.securitySchemes.oauth2.flows (2691-2704) declares only authorizationCode and clientCredentials, because OAS 3.1 has no device flow. OAS 3.2.0 adds flows.deviceAuthorization {deviceAuthorizationUrl (REQUIRED), tokenUrl (REQUIRED), scopes} and oauth2MetadataUrl.  
   *Suggested change:* Note in the oauth2 description that the device flow cannot be expressed in OAS 3.1. When the spec moves to OAS 3.2, add 'deviceAuthorization: {deviceAuthorizationUrl: /device_authorization, tokenUrl: /token, refreshUrl: /token, scopes: {...}}' and 'oauth2MetadataUrl: /.well-known/oauth-authorization-server'.  
   *Verifier: confirmed.*

13. **[LOW] Incorrect: 1563: components.schemas.DeviceAuthorizationResponse.properties.user_code.examples**  
   *Reference:* RFC 8628 §6.1 (non-normative)  
   The second example, '26FB-FA97', uses a mixed digit-and-letter (hex-like) alphabet that matches neither charset §6.1 recommends (case-insensitive base-20 consonants, or pure digits). It forces keyboard-mode switching on phones, contains a vowel, has slightly less entropy per character (16 vs 20 symbols), and mixes look-alike glyphs (B/8). As one of only two examples, it nudges implementers toward a weaker format.  
   *Suggested change:* Use the RFC's own examples: examples: ['WDJB-MJHT', '019-450-730'].  
   *Verifier: partially correct —* '26FB-FA97' departs from RFC 8628 §6.1's non-normative charset suggestions: it mixes digits and letters and contains a vowel. That is a usability nit, not an RFC violation, because §5.1 leaves the code format to the AS. Switching to the RFC's own '019-450-730' is still a reasonable improvement.

14. **[LOW] Incorrect: 386-388: paths./device_authorization.post.description; 1324: components.schemas.DeviceCodeTokenRequest...device_code.description**  
   *Reference:* RFC 8628 §3.3, §6.1  
   The normative level and citations drift from the RFC. (a) 'device_code MUST NOT be displayed': §3.3 says, in lowercase, it 'should not be displayed ... to avoid confusing the end user'. (b) 'servers SHOULD accept dashed and case-insensitive variants': §6.1 is explicitly non-normative, says the server 'should strip' punctuation it added, and limits case-folding to A-Z-only charsets (case-folding a mixed-case code would reduce its entropy). (c) 'user_code is per §6.1 displayed': display is covered by §3.3; §6.1 covers charsets.  
   *Suggested change:* Reword to: 'The device_code is not intended for the end user and should not be displayed (§3.3). The client displays the user_code (§3.3). Per non-normative §6.1, the AS should strip readability punctuation it added and, for A-Z-only charsets, uppercase input before comparing.' Apply the same device_code wording at 1324.  
   *Verifier: partially correct —* Points (a) and (b) are accurate. Point (c) is weak: §6.1 does govern how the code is presented (dashes 'for readability'), even though the obligation to display it is in §3.3.

15. **[LOW] Incorrect: 1478-1497: components.schemas.ErrorResponse.properties.error.enum (YAML comments)**  
   *Reference:* RFC 8628 §3.5, §7.3 (vs RFC 6749 §4.1.2.1, §5.2)  
   The '# RFC 6749 §5.2' comment groups access_denied (and unsupported_response_type, server_error, temporarily_unavailable), which RFC 6749 defines only for the authorization endpoint (§4.1.2.1). access_denied's token-endpoint meaning comes from RFC 8628 §3.5/§7.3, yet the '# RFC 8628 (Device Grant §3.5)' group lists only three codes. The comments are also dropped by the modular split, so nothing in the YAML states what the four device codes mean at /token.  
   *Suggested change:* Re-attribute: '# RFC 6749 §4.1.2.1 (token endpoint: RFC 8628 §7.3)' for access_denied, or list it under the RFC 8628 comment too. Document the four device-flow codes in a description (DeviceCodeTokenRequest) or as named examples on the /token 400 response.  
   *Verifier: partially correct —* The comment mis-attribution, the missing access_denied in the RFC 8628 group, and the loss of comments in the modular split are all accurate. The claim that 'nothing in the YAML states what the four device codes mean at /token' is wrong: 381-384 describes their polling semantics. What is missing is that text on /token or on DeviceCodeTokenRequest.

16. **[LOW] Incorrect: 233-235: paths./token.post.description**  
   *Reference:* RFC 8628 §3.4, §5.2, §5.6  
   'Public clients send no client credential (the empty security option) and rely on PKCE' is wrong for the device_code grant. RFC 8628 has no PKCE: a public device client is identified by client_id and protected only by possession of the high-entropy device_code.  
   *Suggested change:* 'Public clients send no client credential (the empty security option). For authorization_code they rely on PKCE; for the device_code grant they rely on the secret, high-entropy device_code (RFC 8628 §5.2).'  
   *Verifier: confirmed.*

17. **[LOW] Incorrect: The YAML's conditional client_id rule is wrong for mutual-TLS clients** — *found by the verifier*  
   *Reference:* RFC 8628 §3.1, §3.4 with RFC 8705 §2  
   The YAML's conditional client_id rule is wrong for mutual-TLS clients. DeviceAuthorizationRequest.description (1539-1542) says client_id is 'REQUIRED only when the client is not authenticating by other means (e.g. HTTP Basic)', and ClientAuthFields.client_id (1180-1184) covers only public clients and client_assertion. Yet /device_authorization (416) and /token (267) offer the mtls scheme, and RFC 8705 §2 requires client_id on every mTLS-authenticated request. The first agent's modeled-elements entry and prior_validation_followup ('matches §3.1/§3.4') miss this.  
   *Suggested change:* Add to ClientAuthFields.client_id (1180-1184) and DeviceAuthorizationRequest.description (1539-1542): 'REQUIRED when the client authenticates with mutual TLS (tls_client_auth or self_signed_tls_client_auth), per RFC 8705 §2.'

18. **[LOW] Gap: DeviceCodeTokenRequest does not accept authorization_details** — *found by the verifier*  
   *Reference:* RFC 9396 §6 (applied to RFC 8628 §3.4)  
   DeviceCodeTokenRequest does not accept authorization_details. RFC 9396 §6 allows it on token requests for any grant whose underlying grant carries authorization details. The first agent flagged only the device authorization request (RFC 9396 §3).  
   *Suggested change:* Add the AuthorizationDetailsField $ref to DeviceCodeTokenRequest.allOf, and to DeviceAuthorizationRequest per RFC 9396 §3. Correct the mixin citations to RFC 9396 §6 for token requests and §3 for the device authorization request.

19. **[LOW] Incorrect: The /token description presents the device grant as an OAuth 2.1 grant** — *found by the verifier*  
   *Reference:* RFC 8628 §3.4; OAuth 2.1-16 §4.4 and Appendix D  
   The /token description presents the device grant as an OAuth 2.1 grant. Lines 216-222 say 'All grants supported by OAuth 2.1 are modeled here:' and list urn:ietf:params:oauth:grant-type:device_code. RFC 8628 defines it as an extension grant, and OAuth 2.1-16 treats it as an extension, not a core grant. For a learner this blurs the line between core and extension grants.  
   *Suggested change:* Reword 216-217 to: 'Core OAuth 2.1 grants (authorization_code, client_credentials, refresh_token) and the following extension grants (RFC 6749 §4.5 / OAuth 2.1 §4.4) are modeled:'.

20. **[LOW] Gap: DeviceAuthorizationRequest.scope has no RFC 6749 §3.3 syntax constraint** — *found by the verifier*  
   *Reference:* RFC 8628 §3.1 (RFC 6749 §3.3)  
   DeviceAuthorizationRequest.scope has no RFC 6749 §3.3 syntax constraint. RFC 8628 §3.1 defines scope by reference to RFC 6749 §3.3, but the YAML applies the scope-token pattern only to /authorize's Scope parameter. The device request's scope (1548-1550) is a bare string, so malformed scope strings validate.  
   *Suggested change:* Move the pattern at 744 into a shared ScopeString schema and reference it from DeviceAuthorizationRequest.scope and the other token-request scope fields.

21. **[LOW] Incorrect: The repo's audit synthesis (not the YAML) cites the wrong standard for user_code formatting** — *found by the verifier*  
   *Reference:* RFC 8628 §6.1  
   The repo's audit synthesis (not the YAML) cites the wrong standard for user_code formatting. It says 'Document user_code charset (BCP 47, dash-stripping, case-insensitivity)'. BCP 47 is the language-tag standard, which the YAML uses correctly for ui_locales and claims_locales at 913 and 925. User-code charset guidance comes from RFC 8628 §6.1. The first agent relied on this audit and did not flag the error.  
   *Suggested change:* At rfc-audit-synthesis.md:215, replace 'BCP 47' with 'RFC 8628 §6.1 (non-normative)'.

## RFC 10027 Best Current Practice for Security of Cross-Device Flows

*August 2026 · Best Current Practice (BCP 247) · YAML coverage: **none** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** RFC 10027 (BCP 247) is the OAuth WG's security guide for cross-device flows. In these flows a user starts on one device (the Consumption Device: a TV, kiosk, whiteboard, or an attacker's laptop) and approves on another (the Authorization Device, usually a phone); examples are the RFC 8628 device grant, CIBA, OpenID4VP/VCI and SIOPv2. The QR code, typed user code or push notification that links the two devices travels over an unauthenticated channel. An attacker can therefore start a flow and talk a victim into approving it (Cross-Device Consent Phishing) or into forwarding a session-transfer code (Cross-Device Session Phishing), even when the victim uses MFA. The RFC defines no new protocol elements. It requires a risk assessment and a selection from 17 practical mitigations (proximity, short-lived/one-time/unique codes, rate limits, trusted devices or networks, limited scopes, short-lived and sender-constrained tokens, clearer consent UX, and others). It ranks protocols: FIDO2/WebAuthn cross-device authentication (with the authorization code grant + PKCE) first, CIBA second, and the device grant only when nothing else is viable and extra mitigations are in place.

**Why it was created.** From 2020 onward, published research showed the device code flow being weaponised at scale. The pattern: start a flow, send the user_code or QR code to victims with a pretext, and collect access and refresh tokens when someone approves on the genuine sign-in page. The RFC cites [NEWDCPHISH] 2020; [DCATTACK], [ARTDCPHISH], [DCFLOWPHISH] and [DEFCON29] 2021; and the SquarePhish QR tool [SQPHISH] 2022. Push-based flows suffer bulk-request and consent-overload attacks. RFC 8628 §5.4 had only a short remote-phishing note, so the WG produced a consolidated threat model, practical mitigations and protocol-selection guidance for all cross-device protocols. It was published from draft-ietf-oauth-cross-device-security.

<details><summary>Already modeled in the YAML (10)</summary>

- None of these building blocks references RFC 10027; they come from other RFCs.
- Short-lived codes (§6.1.2): DeviceAuthorizationResponse.expires_in (1572-1574)
- QR transport targeted by CDCP (§4.1.1, §4.3.1): verification_uri_complete (1568-1571)
- Server-driven polling throttle: ErrorResponse slow_down (1496)
- Limited scopes (§6.1.9): TokenResponse.scope (1440-1442)
- Short-lived tokens (§6.1.10): TokenResponse.expires_in (1428-1432); refresh-token protection for public clients (RefreshTokenRequest 1284-1289; TokenResponse.refresh_token 1433-1439)
- Sender-constrained tokens (§6.1.12): DPoP header on /token (240); token_type DPoP (1420-1427); dpop_signing_alg_values_supported (2188-2190); mtls on /token and /device_authorization (267, 416); tls_client_certificate_bound_access_tokens (2193-2198)
- Detect and remediate (§6.1.6): /introspect (315-363); IntrospectionResponse.active (1708-1712)
- Trusted devices (§6.1.7) and refusal: client authentication at /device_authorization (414-417; ClientAuthFields 1175-1200); unauthorized_client (1482); access_denied (1485)
- Protocol-selection alternatives (§6.2): authorization code + PKCE, which §6.2.3.5 pairs with FIDO cross-device authentication (/authorize 109-205; AuthorizationCodeTokenRequest 1235-1266; code_challenge_methods_supported [S256] 2176-2185); CIBA metadata only (backchannel_authentication_endpoint 1985-1988; CIBA fields 2237-2248)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes exist. RFC 10027 was published in August 2026, after the May-2026 audit, and neither it nor its predecessor draft-ietf-oauth-cross-device-security is mentioned anywhere in the repo.

**Notes.** RFC 10027 has no IANA actions (§8), so the IANA absence list has no entries for it. The RFC Editor errata page showed no errata on 2026-10-10. draft-ietf-oauth-security-topics-update-03 already cites it as [CDFS] (draft -15), and draft-ietf-oauth-first-party-apps-04 references it when the device grant is selected. To vendor it: add rfc10027.txt to references/rfc-sources and its README index, add it to the refresh loop, and create references/rfc-validation/10027-cross-device-security.md. The README's claim that the vendored set 'complete[s] the set of OAuth working group RFCs' is no longer true after RFC 10017 and RFC 10027. *(Update 2026-10-11: RFC 10017 and RFC 10027 are now vendored and listed in the manifest and the README index, and the README claim was corrected. This file takes the place of a separate rfc-validation note.)* Its normative references CIBA, CAEP, SSF, FIDO CTAP 2.2 and WebAuthn L3 are not vendored; CIBA is the one with direct AS-surface impact. yaml_coverage is 'none' because none of the BCP's constraints or warnings appear in the YAML, even though several mitigation mechanisms (DPoP/mTLS, introspection, short expires_in, scope in the token response) exist through other RFCs. has_http_surface is false: the RFC adds no endpoints or parameters and only constrains how /device_authorization, the device-code token request, the verification page and CIBA endpoints should behave.

### Findings (0 high · 2 medium · 7 low)

1. **[MEDIUM] Gap: BCP 247 reference and device-grant usage warning (risk assessment, protocol selection, same-device ban)**  
   *Reference:* RFC 10027 §2 (items 1-4), §5, §6.2.1.5, §6.2.4  
   §2 explicitly applies to RFC 8628. Implementers MUST perform a risk assessment and MUST select mitigations from §6.1; they SHOULD avoid the flow if the risk cannot be mitigated and SHOULD follow §6.2 protocol selection. §6.2.1.5 and §6.2.4: use the device grant only when FIDO2/WebAuthn cross-device auth or CIBA are not viable; avoid it for sensitive or high-value resources; always add mitigations such as proximity or pre-registered devices; and never use it for same-device scenarios. §5: cross-device protocols SHOULD NOT be used same-device, and the AS MAY detect and block that (beware NAT). The YAML never mentions RFC 10027 or cross-device phishing: not in the covered-specs table (info.description, 18-45), the Device Flow tag (93-94), or the /device_authorization description (373-388). These requirements have no wire shape, so a generated server carries no hint that they exist.  
   *Suggested change:* Add '| RFC 10027 (BCP 247) | 2026 | Security of cross-device flows |' to the table at 18-45. Set the tag description (94) to 'RFC 8628; security per RFC 10027 (BCP 247)'. Append to the /device_authorization description: 'Security (RFC 10027 / BCP 247, https://www.rfc-editor.org/rfc/rfc10027): this grant is susceptible to Cross-Device Consent Phishing, where an attacker starts the flow and lures a victim into entering the user_code or scanning the QR code. Deployers MUST perform a risk assessment and MUST apply mitigations from §6.1. Use the grant only when FIDO2/WebAuthn cross-device authentication with authorization_code + PKCE, or CIBA, is not viable. Avoid it for high-value resources. Never use it on the same device (use /authorize; RFC 8628 §1, RFC 8252).'  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Consent/verification-page UX requirements**  
   *Reference:* RFC 10027 §6.1.14 (with §6.1.13, §6.1.16)  
   §6.1.14 SHOULDs: preserve and show context (who started the flow, why, what will be granted); tell the user to decline unless they initiated or expected the request; give an obvious decline/cancel; make decline the default or equally prominent. Optional extras are user education (§6.1.13) and an out-of-band OTP/PIN confirmation (§6.1.16). These apply to the AS-hosted verification and consent page behind verification_uri(_complete). The YAML does not model that page (see the RFC 8628 §3.3 gap), and no description mentions these requirements.  
   *Suggested change:* In the verification-page operation proposed under RFC 8628 §3.3 (or in the /device_authorization description), add: 'Consent screen (RFC 10027 §6.1.14): show which device or client is asking, from roughly where, and what will be granted; say "If you did not start this on a device you are holding, deny"; make Deny the default or equally prominent; never auto-approve on arrival via verification_uri_complete (also RFC 8628 §3.3.1, §5.4).'  
   *Verifier: confirmed.*

3. **[LOW] Gap: Proximity signal between Consumption and Authorization Device**  
   *Reference:* RFC 10027 §2 (item 5), §6.1.1, §6.2.1.4  
   Implementers SHOULD include proximity among their mitigations where possible, and §6.2.1.4 singles it out for the device grant. AS-side options in §6.1.1: compare the network address or geolocation of the /device_authorization request with the verifying browser session (watch for Wi-Fi vs cellular, NAT and VPN); or put the Consumption Device's network address into a digitally signed QR payload that the wallet or app checks. Location- or device-identifying mechanisms SHOULD be evaluated for privacy. Nothing in the YAML mentions this; verification_uri_complete (1568-1571) is described only as a user_code carrier.  
   *Suggested change:* In the device-flow security paragraph: 'Where possible, bind the two devices by proximity (RFC 10027 §6.1.1). For example, record the client's IP or geolocation at /device_authorization and compare it with the verifying session; treat a mismatch as a risk signal (step-up, warning or denial). Evaluate the privacy impact.' Extend verification_uri_complete.description: 'MAY carry additional integrity-protected data, such as a signed network-address hint, for proximity checks (RFC 10027 §6.1.1, §6.1.17; RFC 8628 §3.2 allows other information with the same function as user_code).'  
   *Verifier: confirmed.*

4. **[LOW] Gap: Rate limiting of device authorization / user-code issuance (HTTP 429 + Retry-After)**  
   *Reference:* RFC 10027 §6.1.11 (with RFC 8628 §5.1; RFC 6585 §4)  
   A scaled CDCP attack (Example B1, §4.3.1) needs many user codes. §6.1.11 lets the AS rate-limit requests per client, and for CIBA the requests sent to a user. /device_authorization responses (398-413) define only 200/400/401, and /token (247-264) has no 429 or 503. Only /par models a 429 (471-472). Polling speed is already governed by slow_down (1496); the gap is throttling of code issuance and a documented Retry-After.  
   *Suggested change:* Add components.headers.RetryAfter {description: 'Delay before retrying (RFC 9110 §10.2.3)', schema: {type: string}}. Under /device_authorization responses add '429': {description: 'Too Many Requests (RFC 6585 §4): rate limit on device-authorization/user-code issuance per client, IP or network (RFC 10027 §6.1.11; RFC 8628 §5.1)', headers: {Retry-After: {$ref: '#/components/headers/RetryAfter'}}}. Reuse the header on /par's 429 (471-472). Keep polling throttling on /token via slow_down; optionally document 503 + Retry-After under load, as CIBA Core §10.1 does.  
   *Verifier: partially correct —* The YAML documents no 429/Retry-After for device-code issuance. This is a MAY-level option (RFC 10027 §6.1.11) with no RFC-defined wire form, so severity is low, not medium. RFC 8628 §5.1's rate-limit recommendation belongs to the verification-page gap.

5. **[LOW] Gap: Short-lived, one-time/limited-use and unique user codes and QR URIs**  
   *Reference:* RFC 10027 §6.1.2, §6.1.3, §6.1.4  
   These mitigations need only the AS. Keep code lifetimes short (§6.1.2). The AS can enforce one-time or limited use of a user_code or verification_uri_complete and MAY allow a few re-presentations (§6.1.3). It can issue unique codes, deny-list re-presented ones, and MAY decline to issue tokens when a code is presented repeatedly (§6.1.4). expires_in (1572-1574), user_code (1560-1563) and verification_uri_complete (1568-1571) carry no such guidance.  
   *Suggested change:* expires_in.description: '... keep as short as usability allows (RFC 8628 §5.4; RFC 10027 §6.1.2).' user_code.description: '... unique among outstanding codes. The AS can limit each code (or verification_uri_complete) to one or a few uses and MAY refuse token issuance, e.g. access_denied on the next poll, when a code is redeemed repeatedly (RFC 10027 §6.1.3-§6.1.4).'  
   *Verifier: confirmed.*

6. **[LOW] Gap: Detect and remediate: invalidate tokens from abused codes and expose that via introspection / CAEP**  
   *Reference:* RFC 10027 §6.1.6  
   If the AS decides a code was used in an attack, it MAY invalidate all tokens issued from it, make that visible through RFC 7662 introspection, and notify resource servers through CAEP/SSF. /introspect (315-363) and IntrospectionResponse.active (1708-1712) exist, but nothing links abuse of the device grant to them. SSF/CAEP are OIDF specs outside this YAML's AS-endpoint scope.  
   *Suggested change:* Add to IntrospectionResponse.active or the device-flow security paragraph: 'Tokens issued through a user code later found to be phished are invalidated and reported as {"active": false} (RFC 10027 §6.1.6). Resource servers that validate JWT access tokens locally need a push signal, such as CAEP over SSF.'  
   *Verifier: confirmed.*

7. **[LOW] Gap: Impact limiting for device-flow tokens: limited scopes, short-lived tokens, sender-constrained tokens**  
   *Reference:* RFC 10027 §6.1.9, §6.1.10, §6.1.12  
   The AS MAY narrow scopes for cross-device grants (§6.1.9); RFC 6749 §5.1 then requires the scope member in the response. It can shorten access- and refresh-token lifetimes (§6.1.10), and can bind tokens with DPoP or mTLS, ideally hardware-backed, so harvested tokens cannot be moved and sold (§6.1.12). The mechanisms exist (TokenResponse.scope 1440-1442, expires_in 1428-1432, DPoP header on /token 240, mtls 265-268), but DeviceCodeTokenRequest (1309-1324) recommends none of them.  
   *Suggested change:* Append to DeviceCodeTokenRequest.description: 'Per RFC 10027 §6.1.9-§6.1.12 the AS may narrow scope (and then returns scope, RFC 6749 §5.1), shorten token lifetimes, and bind tokens with DPoP (send a DPoP proof on this request, RFC 9449 §5) or mTLS (RFC 8705). Device clients are usually public, so refresh tokens MUST be sender-constrained or rotated (RFC 9700 §2.2.2).'  
   *Verifier: confirmed.*

8. **[LOW] Gap: Trusted-device / trusted-network gating of device-flow initiation**  
   *Reference:* RFC 10027 §6.1.7, §6.1.8, §6.1.15  
   The AS MAY restrict who can start a cross-device flow: specific device types, pre-registered devices, or MDM-managed devices with hardware-rooted identity (§6.1.7). It can also allow initiation only from trusted networks (§6.1.8). On the wire this appears as client authentication at /device_authorization (414-417; per-device mTLS or private_key_jwt credentials in ClientAuthFields 1175-1200) and as a refusal with unauthorized_client (1482) or invalid_client. None of this is explained. Device-identifying mechanisms SHOULD be evaluated for privacy.  
   *Suggested change:* Add to the /device_authorization 400/401 descriptions: 'AS policy MAY limit device-flow initiation to registered or attested devices and to trusted networks (RFC 10027 §6.1.7-§6.1.8); other callers are refused with unauthorized_client (400) or invalid_client (401).'  
   *Verifier: partially correct —* The gap is real, at MAY level and low severity, but the §6.1.15 citation should be dropped. That mitigation concerns user authentication on the Consumption Device and rarely applies to input-constrained device-grant clients.

9. **[LOW] Gap: CIBA endpoint, grant and errors (RFC 10027's preferred alternative to the device grant)**  
   *Reference:* RFC 10027 §6.2.2, §6.2.4 (CIBA Core 1.0 §7.1, §7.1.2, §7.3, §10.1, §11, §13)  
   RFC 10027 references CIBA normatively. It recommends CIBA over the device grant whenever the Consumption Device can supply a user identifier (§6.2.2.5), plus rate limits and proximity, because CIBA is still open to bulk 'push-bombing' (§4.3.4.1, §4.3.9, §6.2.2.2). The YAML only advertises CIBA metadata: backchannel_authentication_endpoint (1985-1988); backchannel_token_delivery_modes_supported, backchannel_user_code_parameter_supported and backchannel_authentication_request_signing_alg_values_supported (2237-2248). It has no backchannel authentication request (scope including openid; exactly one of login_hint_token, id_token_hint or login_hint; binding_message; user_code; requested_expiry; client_notification_token). It has no acknowledgement schema (auth_req_id, expires_in, interval) and no urn:openid:params:grant-type:ciba request in TokenRequest (1156-1171). It also lacks the CIBA errors expired_login_hint_token, unknown_user_id, missing_user_code, invalid_user_code and invalid_binding_message in ErrorResponse (1477-1517). The repo's audit deliberately deferred CIBA operation modeling (references/audit/rfc-audit-synthesis.md, 'Application policy'); RFC 10027 makes that deferral more costly.  
   *Suggested change:* Add POST /bc-authorize (tag CIBA; URL advertised by backchannel_authentication_endpoint) with: a BackchannelAuthenticationRequest (allOf ClientAuthFields, scope REQUIRED, plus the hint, binding_message, user_code, requested_expiry and client_notification_token fields); a 200 BackchannelAuthenticationResponse {auth_req_id: REQUIRED, at least 128-bit entropy, chars A-Za-z0-9._-; expires_in: REQUIRED; interval}; and 400/401 errors. Add CibaTokenRequest {grant_type const 'urn:openid:params:grant-type:ciba', auth_req_id} to TokenRequest.oneOf and the discriminator. Add the five CIBA error codes. Describe backchannel_user_code_parameter_supported as the control against unsolicited requests (CIBA §7.1.2) and document per-user request rate limits (RFC 10027 §6.1.11). Vendor CIBA Core 1.0 into references/oidf-sources.  
   *Verifier: partially correct —* This is a CIBA Core 1.0 (OIDF) coverage gap that RFC 10027 makes more relevant, not an RFC 10027 requirement. Rate it low within this RFC cluster and track it in an OIDF/CIBA cluster.

## Verifier corrections to the summaries above

- cluster_notes: 'grep for cross-device, 10027, CDCP and phish returns nothing outside rfc-sources' is false for 'phish'. There are 4 hits in references/rfc-validation: 8628-device-grant.md:178 and :204 (the §5.4 remote-phishing note), 9700-security-bcp.md:347 and oauth-2.1-draft.md:400. The conclusion still holds: 'cross-device', '10027' and 'CDCP' return nothing, so RFC 10027 is never mentioned.
- cluster_notes: 'CIBA, which RFC 10027 normatively references as the preferred alternative' needs a qualifier. RFC 10027 §6.2.4 ranks FIDO2/WebAuthn cross-device authentication first. CIBA is the fallback 'if FIDO2/WebAuthn support is not available' and is preferred only over the device grant (§6.2.2.5).
- cluster_notes: the 'key May-2026 fixes' include 'client_id made conditional', but the May notes never asked for this. They endorsed the unconditional required client_id; the change came later, as the first agent's own prior_validation_followup notes.
- RFC 8628 prior_validation_followup: '(2) Response pinned to application/json (406-409)' was not a fix. The 200 response was already application/json-only in May (8628-device-grant.md: 'this part is fine'), and the requested description note was never added. Three items were actually changed and one was already satisfied, so 'Fixed (4 of 9)' overstates it.
- RFC 8628 why_created: 'Every RFC 6749 end-user grant assumes the client can open a browser on the same device and receive a redirect' is too broad. The Resource Owner Password Credentials grant (RFC 6749 §4.3) needs no browser or redirect; RFC 8628 §1 contrasts only the authorization code and implicit grants. Also, the Acknowledgements give 'a then-lack of sufficient deployment expertise' as the reason, not 'experience'.
- RFC 10027 summary: the device roles are described only for cross-device authorization (start on the Consumption Device, approve on the Authorization Device). In cross-device session transfer (§1.2, §3.2.1) the user starts on the already-authenticated Authorization Device, and the session moves to the Consumption Device.
- RFC 10027 notes: the 'complete[s] the set of OAuth working group RFCs' claim is in references/rfc-sources/README.md (lines 4-5 'including every OAuth working group RFC', and lines 56-58), not in the top-level README.md.
- RFC 8628 notes: RFC 8707 resource on the device authorization request is more than 'a reasonable extension'. RFC 8707 §2 opens with 'In requests to the authorization server, a client MAY indicate the protected resource ... by including the following parameter in the request', which covers the device authorization request.
