# PKCE, native apps & browser-based apps — RFC 7636, 8252, 10017

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 7636](#rfc-7636-proof-key-for-code-exchange-by-oauth-public-clients) | September 2015 | Proposed Standard | mostly | 0 | 4 | 10 |
| [RFC 8252](#rfc-8252-oauth-20-for-native-apps) | October 2017 | Best Current Practice (BCP 212); updates RFC 6749 | partial | 1 | 1 | 6 |
| [RFC 10017](#rfc-10017-oauth-20-for-browser-based-applications) | August 2026 | Best Current Practice (BCP 212, alongside RFC 8252) | partial | 2 | 2 | 4 |

**Cluster notes.** Scope: RFC 7636 (PKCE) plus BCP 212, which is RFC 8252 (native apps, 2017) and RFC 10017 (browser-based apps, Aug 2026). Every claim below was checked against the vendored text (RFC 7636, RFC 8252, RFC 9700, RFC 8414, RFC 9449, RFC 6749, OIDC Discovery), RFC 10017 as downloaded today, and draft-ietf-oauth-v2-1-16. The YAML snapshot was checked with grep -n.

Top findings:
(1) HIGH incorrect: components.parameters.RedirectUri (lines 720-727) and the /authorize 400 text (197-201) require exact-string matching with no loopback-port exception. This contradicts RFC 8252 §7.3/§8.4. It also misstates the two sources it cites (OAuth 2.1 §2.3.1, RFC 9700 §4.1.3), which both contain the exception. A server built from it would reject desktop/CLI apps that use ephemeral loopback ports. The May-2026 OAuth 2.1 audit asked for both the exact-match rule and the exception; only the first was added.
(2) HIGH gaps from RFC 10017: there is no CORS surface anywhere (§6.3.3.4 MUST). Without it a SPA also can't read DPoP-Nonce (RFC 9449 §8). There are also no refresh-token lifetime caps and no 'don't extend on rotation' rule (§6.3.2.3 MUSTs).
(3) PKCE syntax is now correct (43-128 unreserved chars, S256-only, PAR parity), but the behavior is under-documented: the §4.4.1 invalid_request cases, the meaning of an absent code_challenge_method (RFC default is plain), §4.6 invalid_grant, and the RFC 9700 §4.8.2 downgrade check. The prose also still follows OAuth 2.1 -15: draft-16 (Sept 2026) makes code_challenge_method REQUIRED and forbids plain. RFC 9700 §4.8 is mis-cited as the plain downgrade.
(4) Internal inconsistency: the YAML documents the OIDC-nonce exception but makes code_verifier unconditionally required.

Provenance: RFC 7636 and RFC 8252 are vendored (byte-identical to rfc-editor.org). RFC 10017 is not vendored; recommend vendoring it. *(Update 2026-10-11: RFC 10017 is now vendored.)* Neither RFC 8252 nor RFC 10017 is cited anywhere in the YAML or its Covered-specifications table (lines 18-45). draft-16 §9 'Browser-Based Apps' is still a TODO to import RFC 10017.

IANA: no registry values attributable to this cluster are absent. RFC 7636's code_verifier, code_challenge, code_challenge_method, S256 and plain are all present (plain only in prose, by design). RFC 8252 and RFC 10017 have no IANA actions.

Errata at rfc-editor.org (2026-10-10): RFC 7636 has 1 verified (5687: §5 should say code_challenge, not code_verifier), 2 reported, 2 rejected. RFC 8252 has 1 reported (8080), 1 rejected. RFC 10017 has none.

All fixes must be mirrored in oauth-openapi-modular: spec/components/parameters.yaml:36 (RedirectUri), :100 (CodeChallengeMethod), and spec/components/schemas/par.yaml:38 (default: S256).

Intentional exclusions respected: Implicit/ROPC removal is recorded as modeled (RFC 8252 §8.2, RFC 10017 §7.2/§7.3), not as a gap.

## RFC 7636 Proof Key for Code Exchange by OAuth Public Clients

*September 2015 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: required-oauth21 · vendoring: already-vendored*

**What it is.** PKCE (pronounced 'pixy') adds a one-time secret to the authorization code flow. The client generates a random code_verifier. It sends only a transformed value, the code_challenge, in the authorization request; with method S256 that is the base64url SHA-256 hash. Later it sends the verifier itself in the token request. The authorization server stores the challenge with the code and redeems the code only if the transformed verifier matches, so an intercepted or injected code is useless without the verifier. PKCE was designed for public (native) clients; it is now mandatory for public clients (RFC 9700 §2.1.1) and the default for every client in OAuth 2.1.

**Why it was created.** Public clients, especially mobile apps, receive the authorization code through operating-system channels such as custom URI schemes, and several apps can register the same scheme. A malicious app could therefore catch the code and redeem it: the 'authorization code interception attack' (RFC 7636 §1, Figure 1), which had been observed in the wild. The mitigations in RFC 6819 §4.4.1 relied on per-instance client secrets or per-instance redirect URIs, which native apps don't have. PKCE replaces them with a per-request key held only by the legitimate client instance. The first draft came from the OpenID Foundation's AB/Connect WG before it moved to the IETF OAuth WG.

<details><summary>Already modeled in the YAML (9)</summary>

- code_challenge (authorization request, §4.3): components.parameters.CodeChallenge, lines 760-778, with minLength 43, maxLength 128 and pattern '^[A-Za-z0-9._~-]+$' (equivalent to the §4.2 ABNF 43*128unreserved); referenced by /authorize at line 138
- code_challenge_method (authorization request, §4.3): components.parameters.CodeChallengeMethod, lines 780-795, enum [S256] (S256-only profile; plain deliberately excluded); referenced by /authorize at line 139
- code_verifier (token request, §4.5): components.schemas.AuthorizationCodeTokenRequest.code_verifier, lines 1259-1266 (43-128 unreserved, matching the §4.1 ABNF), listed in required at line 1244; selected via the TokenRequest discriminator mapping authorization_code (line 1166)
- PKCE through PAR: components.schemas.PARRequest.code_challenge (lines 1607-1611) and code_challenge_method (lines 1612-1615), both in required (line 1594)
- PKCE-mandatory policy text: info modeling note (line 59), /authorize description (lines 120-123), CodeChallenge description (lines 768-771), /token description (lines 219, 233-235)
- PKCE Code Challenge Methods registry (§6.2.2): S256 in every enum (lines 795, 1614, 2180); plain appears only in prose (lines 786-792, 2185), by design
- code_challenge_methods_supported metadata (RFC 8414 §2; values come from the RFC 7636 §6.2 registry): components.schemas.OAuthServerMetadata.properties.code_challenge_methods_supported, lines 2176-2185 (enum [S256]); inherited by OpenIDProviderMetadata via allOf (line 1913)
- PKCE-relevant error codes in the vocabulary: ErrorResponse.error enum invalid_request (line 1479) and invalid_grant (line 1481); /token 400 uses components.responses.OAuthErrorWithDPoPNonce (line 262); /authorize error redirect parameters described at lines 168-169
- Public PKCE clients at the token endpoint: empty security alternative {} (line 268); ClientAuthFields.client_id 'REQUIRED for unauthenticated (public) clients' (lines 1178-1184)

</details>

**Follow-up on the May-2026 validation notes.** The May-2026 file references/rfc-validation/7636-pkce.md listed 8 MISSING and 6 WRONG items, plus 4 nice-to-haves.
- Fixed (7): code_verifier pattern; code_challenge length and pattern; the S256-mandatory note in metadata; code_challenge_method no longer required:true; the plain-case wording (obsolete under the S256-only profile); the PAR enum; the PAR length and pattern.
- Partly fixed (2): the paired 'default: S256 vs RFC default plain' items. The default was removed from the parameter but remains at PARRequest line 1615.
- Still open (5): documentation of invalid_request for a missing code_challenge (§4.4.1); invalid_request for an unsupported method (§4.4.1); invalid_grant for a verifier mismatch (§4.6); an invalid_request example on the /authorize 302 (only access_denied at line 181); and the require_pkce discovery flag. I don't recommend that flag: no such IANA metadata exists, and RFC 9700 §2.1.1 relies on code_challenge_methods_supported.
- All 4 nice-to-haves remain open: shared PKCE components, Appendix B examples, the §7 entropy note, and require_pkce.
Note that the May file was written without web access and has citation slips: it cites RFC 7636 §4.7 and §7.6, which don't exist; it presents an 'exactly 43 characters' sentence as quoted from §4.2, but it isn't there; and it places the worked example in §4.6 instead of Appendix B.

**Notes.** IANA diff: all RFC 7636 registrations are present in the YAML text. Errata: 5687 (verified) matters for the downgrade logic, because the compatibility fallback is keyed on a missing code_challenge. Reported errata 6179 (§7.3) and 6471 (§7.1 wording) have no YAML impact. The closed enum [S256] in code_challenge_methods_supported is fine as this server's own profile, but don't reuse the schema to validate other servers' discovery documents that list plain. The same text must be fixed in oauth-openapi-modular/spec/components/parameters.yaml:100 and spec/components/schemas/par.yaml:38.

### Findings (0 high · 4 medium · 10 low)

1. **[MEDIUM] Gap: Authorization-endpoint PKCE errors (missing code_challenge; unsupported method)**  
   *Reference:* RFC 7636 §4.4.1 (also RFC 8252 §8.1)  
   §4.4.1 has two MUSTs. If the server requires PKCE and code_challenge is missing, the authorization endpoint MUST answer error=invalid_request. If the requested transformation isn't supported, it MUST also answer invalid_request. error_description or error_uri SHOULD explain the cause (e.g. 'code challenge required', 'transform algorithm not supported'). RFC 8252 §8.1 says the AS SHOULD reject native-app requests without PKCE using this error. invalid_request is in ErrorResponse.error (line 1479), but nothing ties it to these cases: not CodeChallenge (760-778), not CodeChallengeMethod (780-795), not the /authorize 302 (160-181). The only error example in the Location header is access_denied (line 181). These errors are delivered in the redirect query, not in a JSON body, so the 302 response is where they have to be documented.  
   *Suggested change:* Add to parameters.CodeChallenge.description: 'If it is missing where PKCE is required, the AS redirects with error=invalid_request (RFC 7636 §4.4.1), e.g. error_description=code_challenge required.' Add the matching sentence to parameters.CodeChallengeMethod.description for unsupported methods ('transform algorithm not supported'). Add a third Location example under /authorize 302 (after line 181): 'https://client.example.com/cb?error=invalid_request&error_description=code_challenge%20required&state=xyz&iss=https%3A%2F%2Fas.example.com'.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Token-endpoint PKCE verification, invalid_grant, and the PKCE downgrade check**  
   *Reference:* RFC 7636 §4.5, §4.6, §5 (verified erratum 5687); RFC 9700 §2.1.1, §4.8.2  
   §4.5: the token endpoint MUST use the method that was bound to the code when it was issued. §4.6: if the transformed verifier doesn't equal the stored challenge, the AS MUST return invalid_grant (RFC 6749 §5.2). Verified erratum 5687 corrects §5: the fallback to plain OAuth 2.0 is triggered by a missing code_challenge, not a missing code_verifier. RFC 9700 §4.8.2 then adds: if the code was issued without a code_challenge, a token request carrying a code_verifier MUST be rejected. RFC 9700 §2.1.1 adds: if a challenge was sent, correct verifier use MUST be enforced. AuthorizationCodeTokenRequest (lines 1235-1266) gives only the syntax of code_verifier, never links invalid_grant (line 1481) to PKCE, and doesn't describe the downgrade check. That check matters here because the YAML documents the OIDC-nonce path (lines 120-123, 768-771), where codes are issued without a challenge.  
   *Suggested change:* Extend code_verifier.description (lines 1264-1266): 'The AS computes BASE64URL-ENCODE(SHA256(ASCII(code_verifier))) with the method bound to the code and compares it with the stored code_challenge; a mismatch returns 400 invalid_grant (RFC 7636 §4.6). If the code was issued with a code_challenge, code_verifier MUST be present; if it was issued without one, a request containing code_verifier MUST be rejected (RFC 9700 §4.8.2; OAuth 2.1 §4.1.3).' Add a /token 400 example body: {"error":"invalid_grant","error_description":"code_verifier does not match code_challenge"}.  
   *Verifier: confirmed.*

3. **[MEDIUM] Incorrect: lines 784-792 components.parameters.CodeChallengeMethod.description (also lines 2182-2183 OAuthServerMetadata.properties.code_challenge_methods_supported.description)**  
   *Reference:* RFC 7636 §4.2, §4.3, §7.2; draft-ietf-oauth-v2-1-16 §4.1.1, §7.5.2; RFC 9700 §4.8  
   The text pins PKCE to OAuth 2.1 draft -15 semantics: 'In OAuth 2.1 §4.1.1 the parameter is OPTIONAL (defaulting to plain), and plain is permitted only when the client cannot compute S256'. In the current draft-ietf-oauth-v2-1-16 (Sept 2026), §4.1.1 makes code_challenge_method REQUIRED ('the value S256 or a value defined by a future extension') and says plain 'is removed and explicitly prohibited'; §7.5.2 forbids it. The OPTIONAL / default-plain / plain-only-if-you-can't-hash rules now exist only in RFC 7636 §4.2-§4.3. The closing '(RFC 9700 §4.8 describes the downgrade attack that plain invites.)' is mis-attributed. RFC 9700 §4.8 describes stripping code_challenge so the code is issued unbound. The S256-to-plain downgrade is covered by RFC 7636 §7.2 and draft-16 §7.5.2. Lines 2182-2183 attribute 'mandatory to implement' to OAuth 2.1 §4.1.1, but that wording was removed in -16; the source is RFC 7636 §4.2.  
   *Suggested change:* Replace with: 'Only S256 is accepted. RFC 7636 §4.3 makes this OPTIONAL with default plain, but OAuth 2.1 (draft-16) §4.1.1 makes it REQUIRED and §7.5.2 forbids plain; an absent or plain value is rejected with error=invalid_request (RFC 7636 §4.4.1). Downgrade references: S256 to plain, RFC 7636 §7.2; stripping code_challenge, RFC 9700 §4.8.' At lines 2182-2183, cite RFC 7636 §4.2 for mandatory-to-implement. Update the vendored draft from -15 to -16.  
   *Verifier: confirmed.*

4. **[MEDIUM] Incorrect: lines 120-123 paths./authorize.get.description and lines 768-771 components.parameters.CodeChallenge.description, versus line 1244 components.schemas.AuthorizationCodeTokenRequest required and line 1594 components.schemas.PARRequest required**  
   *Reference:* RFC 7636 §4.5, §5; RFC 9700 §4.8.2; draft-ietf-oauth-v2-1-16 §4.1.3, §7.5.1.1  
   The YAML documents the OAuth 2.1 §7.5.1.1 exception: a confidential OIDC client relying on nonce may omit code_challenge. Its schemas make that path impossible. code_verifier is unconditionally required at the token endpoint, and code_challenge is required in PAR. A client following the documented exception can't send a schema-valid token request. If it adds a code_verifier anyway, the AS MUST reject it (RFC 9700 §4.8.2; draft-16 §4.1.3 says code_verifier 'MUST NOT be used otherwise'). RFC 7636 §4.5 requires code_verifier only within a PKCE flow, and §5 lets servers accept clients that don't use PKCE.  
   *Suggested change:* Pick one profile and make the text and schemas agree. (a) Recommended for a reference AS: 'PKCE always'. Delete the nonce-exception wording at lines 121-123 and 769-771 and keep the schemas as they are. (b) Keep the exception: remove code_verifier from required (line 1244) and code_challenge from PARRequest.required (line 1594), and document 'code_verifier is REQUIRED if and only if code_challenge was sent, and MUST be absent otherwise'.  
   *Verifier: confirmed.*

5. **[LOW] Gap: Meaning of an absent code_challenge_method under the S256-only profile**  
   *Reference:* RFC 7636 §4.3, §4.4.1; draft-ietf-oauth-v2-1-16 §4.1.1  
   RFC 7636 §4.3 makes code_challenge_method OPTIONAL and says it 'defaults to plain if not present'. The YAML parameter is optional (line 783) with enum [S256] and states no rule for the absent case. A generated server could therefore (a) silently assume S256, breaking the RFC default and §4.4.1's MUST to reject an unsupported transformation, or (b) treat absence as plain, breaking the profile. draft-16 §4.1.1 removes the ambiguity by making the parameter REQUIRED with value S256.  
   *Suggested change:* State in parameters.CodeChallengeMethod.description: 'REQUIRED whenever code_challenge is sent (draft-ietf-oauth-v2-1-16 §4.1.1). An absent value means plain under RFC 7636 §4.3, which this AS does not support, so the AS redirects with error=invalid_request (RFC 7636 §4.4.1); it MUST NOT assume S256.' Explain that required:false exists only because of PAR/JAR transport, as CodeChallenge already does at lines 772-773.  
   *Verifier: partially correct —* The YAML does give the default for an absent value (plain, citing OAuth 2.1 -15 §4.1.1), so a reader can infer that this S256-only AS rejects the request. What is missing is (1) an explicit rule that the AS answers error=invalid_request (RFC 7636 §4.4.1) and never assumes S256, and (2) the draft-16 §4.1.1 change that makes the parameter REQUIRED.

6. **[LOW] Gap: code_challenge_methods_supported must be published and non-empty**  
   *Reference:* RFC 7636 §4.2 (S256 mandatory to implement); RFC 8414 §2; RFC 9700 §2.1.1  
   RFC 8414 §2: 'If omitted, the authorization server does not support PKCE.' RFC 9700 §2.1.1: the AS MUST provide a way to detect PKCE support, and publishing code_challenge_methods_supported is RECOMMENDED. In OAuthServerMetadata (lines 2176-2185) the field is optional, absent from required (lines 1937-1940), and may be an empty array. A server generated from this YAML could therefore publish metadata saying 'no PKCE' while it actually requires PKCE.  
   *Suggested change:* For this server profile, add code_challenge_methods_supported to OAuthServerMetadata.required (or state 'MUST be published by this AS'), and add minItems: 1 and contains: {const: S256}.  
   *Verifier: partially correct —* No RFC makes publishing this field a MUST. RFC 8414 makes it OPTIONAL, and RFC 9700 §2.1.1 RECOMMENDS publishing it; the only MUST is to offer some way to detect PKCE support. The observation still holds: the YAML allows the field to be omitted or empty, and both read as 'no PKCE' under RFC 8414 §2, even though this AS mandates PKCE. Making it required with minItems: 1 is a sound profile choice, not an RFC requirement.

7. **[LOW] Gap: Confidentiality of the challenge bound to the authorization code**  
   *Reference:* RFC 7636 §4.4, §7.2  
   §4.4: the AS MUST associate code_challenge and code_challenge_method with the code, and MUST NOT carry the challenge in a form other entities can extract. §7.2: a stateless design that embeds the challenge in the code MUST encrypt it. The YAML's code description (lines 1249-1251) and the 302 description (lines 160-169) say nothing about this.  
   *Suggested change:* Add to AuthorizationCodeTokenRequest.code.description: 'Opaque to the client. If the AS encodes state such as code_challenge and code_challenge_method into the code, the code MUST be encrypted so that only the AS can read it (RFC 7636 §4.4, §7.2).'  
   *Verifier: partially correct —* The §7.2 encryption MUST applies only to the plain method, which this profile excludes. The rules that apply here are in §4.4: the AS MUST bind code_challenge and code_challenge_method to the code, and MUST NOT expose the challenge in a form others can extract. Encryption is the usual way to meet that, not a mandated one. The YAML documents neither rule.

8. **[LOW] Gap: Detection of reused or constant code_challenge values**  
   *Reference:* RFC 7636 §4.1 (a new verifier for each authorization request); RFC 9700 §2.1.1  
   A verifier is created for each authorization request (§4.1). RFC 9700 §2.1.1 says the challenge MUST be transaction-specific and encourages the AS to detect and prevent constant values. The YAML doesn't mention this.  
   *Suggested change:* Add to CodeChallenge.description: 'MUST be unique per authorization request; the AS SHOULD reject a client's reuse of a recently seen code_challenge.'  
   *Verifier: confirmed.*

9. **[LOW] Gap: Appendix B test vectors and §7.1 entropy guidance**  
   *Reference:* RFC 7636 Appendix B, §7.1  
   There are no examples on code_challenge, code_verifier or the authorization request. The §7.1 guidance (at least 256 bits of entropy: 32 random octets give a 43-character verifier) is also missing.  
   *Suggested change:* Add examples ['E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM'] to parameters.CodeChallenge.schema and PARRequest.code_challenge. Add examples ['dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'] to AuthorizationCodeTokenRequest.code_verifier. Add a one-line entropy note citing §7.1.  
   *Verifier: confirmed.*

10. **[LOW] Gap: Shared PKCE schema components**  
   *Reference:* RFC 7636 §4.1-§4.3  
   The constraints are copied by hand: parameters.CodeChallenge.schema (lines 774-778) duplicates PARRequest.code_challenge (1607-1611), and CodeChallengeMethod.schema (793-795) duplicates PARRequest.code_challenge_method (1612-1615). The copies have already drifted: default: S256 exists only in the PAR copy.  
   *Suggested change:* Create components.schemas.PKCECodeChallenge, PKCECodeChallengeMethod (enum [S256], no default) and PKCECodeVerifier, and $ref them from the parameters, PARRequest and AuthorizationCodeTokenRequest.  
   *Verifier: partially correct —* This is a valid maintainability refactor, and the drift is real, but it is not an RFC 7636 coverage gap. Every copy already implements the §4.1/§4.2 ABNF. The only RFC-relevant defect among the copies is the PAR default, which is already reported under 'incorrect'.

11. **[LOW] Gap: S256-specific shape of code_challenge**  
   *Reference:* RFC 7636 §4.2, Appendix A  
   With S256 the challenge is always base64url without padding of a 32-octet hash: exactly 43 characters from [A-Za-z0-9_-]. The 43-128 unreserved range in the §4.2 ABNF exists for plain. Under an S256-only profile it admits values that can never verify, so the error surfaces late as invalid_grant instead of early as invalid_request.  
   *Suggested change:* Optional: since only S256 is accepted, tighten to pattern '^[A-Za-z0-9_-]{43}$' (or say so in the description). Revisit if a future method is registered.  
   *Verifier: confirmed.*

12. **[LOW] Incorrect: line 1615 components.schemas.PARRequest.allOf[2].properties.code_challenge_method.default**  
   *Reference:* RFC 7636 §4.3  
   default: S256 contradicts RFC 7636 §4.3, where the default is plain. It also has no effect, because the property is required (line 1594), and it disagrees with components.parameters.CodeChallengeMethod, which has no default. The May-2026 fix that removed this default was applied to the parameter but not here; the modular copy (spec/components/schemas/par.yaml:38) still has it too.  
   *Suggested change:* Delete default: S256, or $ref a shared PKCECodeChallengeMethod schema that has no default.  
   *Verifier: confirmed.*

13. **[LOW] Gap: Neither the YAML nor the first agent's fix gives error codes for the token-endpoint PKCE presence checks** — *found by the verifier*  
   *Reference:* RFC 7636 §4.5, §4.6; RFC 9700 §4.8.2; RFC 6749 §5.2; draft-ietf-oauth-v2-1-16 §3.2.4, §4.1.3  
   Neither the YAML nor the first agent's fix gives error codes for the token-endpoint PKCE presence checks. RFC 7636 §4.6 assigns invalid_grant only to a value mismatch. OAuth 2.1 §3.2.4 assigns invalid_request to a token request that 'contains a code_verifier although no code_challenge was sent in the authorization request', which is the RFC 9700 §4.8.2 downgrade case. A code_verifier missing for a code that was bound to a challenge is a missing REQUIRED parameter (RFC 7636 §4.5), which RFC 6749 §5.2 defines as invalid_request. An implementer copying the suggested text could return invalid_grant for all three cases.  
   *Suggested change:* Add to code_verifier.description: 'value mismatch: invalid_grant (RFC 7636 §4.6); code_verifier sent for a code issued without code_challenge: invalid_request (OAuth 2.1 §3.2.4; RFC 9700 §4.8.2); code_verifier missing for a code issued with code_challenge: invalid_request (RFC 6749 §5.2).' Add matching /token 400 examples.

14. **[LOW] Gap: When the PKCE parameters are pushed via PAR, the §4.4.1 errors (missing code_challenge, unsupported method) come back from /par as a JSON 400 invalid_request (R** — *found by the verifier*  
   *Reference:* RFC 7636 §4.4.1; RFC 9126 §2.1, §2.3  
   When the PKCE parameters are pushed via PAR, the §4.4.1 errors (missing code_challenge, unsupported method) come back from /par as a JSON 400 invalid_request (RFC 9126 §2.3), not in a redirect. The YAML's /par 400 does not tie invalid_request to PKCE. The first agent's Gap 1 says these errors are 'delivered in the redirect query, not in a JSON body', which is true only for front-channel requests, and its fix touches only the /authorize 302.  
   *Suggested change:* Add to the /par 400 description or PARRequest.description: 'A missing code_challenge or an unsupported code_challenge_method is rejected with HTTP 400 and error=invalid_request (RFC 7636 §4.4.1 applied via RFC 9126 §2.3).'

## RFC 8252 OAuth 2.0 for Native Apps

*October 2017 · Best Current Practice (BCP 212); updates RFC 6749 · YAML coverage: **partial** · relevance to an AS: required-oauth21 · vendoring: already-vendored*

**What it is.** RFC 8252 (the 'AppAuth pattern') says mobile and desktop apps must send OAuth authorization requests through an external user-agent: the system browser or an in-app browser tab, never an embedded web-view. They act as public clients using the authorization code flow with PKCE. It defines three ways for the app to receive the redirect: a private-use URI scheme (com.example.app:/path), a claimed https URI (Universal Links / App Links), or a loopback IP redirect (http://127.0.0.1:{port}/path). It also says what the authorization server must support for each, notably accepting any port on loopback redirects. OAuth 2.1 §8 carries these rules forward.

**Why it was created.** Many native apps used embedded web-views for OAuth. In a web-view the host app can record keystrokes, capture passwords and session cookies, and auto-submit consent. Users also lose single sign-on and learn to type credentials into a UI with no address bar to check (RFC 8252 §8.12). Native apps also can't keep secrets (§8.5), and custom-scheme redirects can be hijacked by other apps (§8.1). The BCP standardizes the browser-based approach and tells AS operators what to support: native redirect types, PKCE, and public-client registration. It updates RFC 6749 §9, which had allowed embedded user-agents.

<details><summary>Already modeled in the YAML (8)</summary>

- PKCE for public native clients (§6, §8.1, Appendix A item 5): CodeChallenge (lines 760-778) and CodeChallengeMethod (780-795) on /authorize (lines 138-139); AuthorizationCodeTokenRequest.code_verifier (1259-1266, required at 1244); /authorize description says PKCE is mandatory for public clients (120-123); info note (59)
- Public, secret-less native clients (§8.4, §8.5, Appendix A item 4): /token security alternative {} (line 268) and its description (233-235); OAuthServerMetadata.token_endpoint_auth_methods_supported enum includes none (lines 2037-2042); ClientAuthFields.client_id required for public clients (1178-1184)
- redirect_uri parameter: components.parameters.RedirectUri (lines 716-730), type string, format uri. It accepts all three native forms syntactically (com.example.app:/oauth2redirect/..., https://app.example.com/..., http://127.0.0.1:51004/...)
- Exact redirect URI matching and a non-redirecting error (§8.4, §8.10): RedirectUri.description (lines 720-727) and /authorize 400 text/html (lines 196-205). The loopback port exception is missing; see incorrect
- Implicit grant not offered (§8.2 says NOT RECOMMENDED): ResponseType enum code, id_token, 'code id_token' (lines 701-706); /token description (226-227); info note (59-61)
- Complement to mix-up mitigation (§8.10): iss in the authorization response (lines 164-169) and authorization_response_iss_parameter_supported (lines 2206-2211), per RFC 9207
- state for cross-app request forgery (§8.9; a client-side rule): components.parameters.State (lines 750-758)
- Refresh tokens for public clients (the code-grant advantage named in §8.2): RefreshTokenRequest (lines 1284-1307) with the rotate-or-sender-constrain rule (1286-1289)

</details>

**Follow-up on the May-2026 validation notes.** There is no RFC 8252 file in references/rfc-validation. The related May-2026 OAuth 2.1 audit (oauth-2.1-draft.md) raised 2 points in this area. (1) State exact-string matching plus the loopback port exception: partly fixed. Exact matching was added at lines 720-724; the exception was not, so the text now contradicts RFC 8252 §7.3. (2) Describe the native redirect types (private-use, loopback, claimed https): still open.

**Notes.** Appendix A server checklist against the YAML: (1) private-use redirects: syntactically allowed, not described; (2) https redirects for public native clients: implicitly allowed; (3) loopback redirects: contradicted by the exact-match text; (4) don't assume native clients keep secrets: none and {} are modeled, the rule isn't stated; (5) PKCE: modeled. On §8.1, the YAML is stricter than RFC 8252 (it says MUST reject, where RFC 8252 says SHOULD), but the error code isn't documented; see the RFC 7636 §4.4.1 gap. Errata: 8080 reported (MUST vs SHOULD for the client's reverse-domain scheme); 5848 rejected. The same RedirectUri text is in oauth-openapi-modular/spec/components/parameters.yaml:36.

### Findings (1 high · 1 medium · 6 low)

1. **[HIGH] Incorrect: lines 720-727 components.parameters.RedirectUri.description (also lines 197-201 paths./authorize.get.responses.400.description)**  
   *Reference:* RFC 8252 §7.3, §8.4; draft-ietf-oauth-v2-1-16 §2.3.1, §4.1.1, §8.4.2; RFC 9700 §2.1, §4.1.3  
   The description says the AS 'MUST compare against registered URIs using exact-string matching', citing OAuth 2.1 §2.3.1 and RFC 9700 §4.1.3, with no exception. The 400 text treats any mismatch as fatal. RFC 8252 §7.3 says: 'The authorization server MUST allow any port to be specified at the time of the request for loopback IP redirect URIs'. §8.4 requires exact match 'except for the port URI component' for loopback redirects. Both cited sources contain the same exception: draft-16 §2.3.1, §4.1.1 and §8.4.2; RFC 9700 §2.1 and §4.1.3. A server built from this YAML would reject desktop and CLI apps that bind an ephemeral loopback port, breaking a MUST. The May-2026 OAuth 2.1 audit (references/rfc-validation/oauth-2.1-draft.md) asked for the exact-match rule and the loopback exception; only the first was added.  
   *Suggested change:* Rewrite as: 'The AS compares redirect_uri with the client's registered URIs by simple string comparison (RFC 3986 §6.2.1), with no wildcards, prefixes or patterns, and one exception. For loopback IP redirect URIs (http://127.0.0.1:{port}/{path}, http://[::1]:{port}/{path}) the port is ignored and any port MUST be accepted (RFC 8252 §7.3, §8.4; OAuth 2.1 §2.3.1, §8.4.2; RFC 9700 §4.1.3). Because the port changes on every request, such clients MUST send redirect_uri (RFC 6749 §3.1.2.3).' Recommend applying the exception only to http loopback-IP URIs registered for native (public) clients, and deciding explicitly whether to accept http://localhost (RFC 8252 §8.3 says NOT RECOMMENDED; RFC 9700 §2.1's wording covers localhost). Make the same change in the 400 description and in oauth-openapi-modular/spec/components/parameters.yaml:36.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Native redirect URI options and scheme rules**  
   *Reference:* RFC 8252 §7, §7.1, §7.2, §7.3, §8.3, Appendix A items 1-3; draft-ietf-oauth-v2-1-16 §1.5, §8.4  
   §7: 'authorization servers MUST offer at least the three redirect URI options'. These are: (1) private-use scheme (§7.1), with a single slash after the scheme, e.g. com.example.app:/oauth2redirect/example-provider; (2) claimed https (§7.2), which looks the same as a web redirect, so the client type must be recorded; (3) loopback (§7.3), http://127.0.0.1:{port}/{path} or http://[::1]:{port}/{path}. §8.3: plain http is acceptable for loopback because the request never leaves the device, and localhost is NOT RECOMMENDED. draft-16 §1.5: every OAuth URL MUST use https except loopback redirect URIs, which MAY use http. RedirectUri (lines 716-730) is a bare format: uri and mentions none of this, so an implementer might reject http loopback or private-use schemes.  
   *Suggested change:* Add a 'Native apps (RFC 8252 §7; OAuth 2.1 §8.4)' paragraph to parameters.RedirectUri.description listing the three forms and the https-except-loopback rule. Add examples ['https://client.example.com/cb', 'com.example.app:/oauth2redirect/example-provider', 'http://127.0.0.1:51004/oauth2redirect/example-provider', 'http://[::1]:61023/oauth2redirect/example-provider']. Optionally constrain with an anyOf of three patterns: https '^https://[^#]+$'; loopback '^http://(127\.0\.0\.1|\[::1\])(:[0-9]{1,5})?(/[^#]*)?$'; private-use '^[A-Za-z][A-Za-z0-9+.-]*\.[A-Za-z0-9+.-]*:/(?!/)[^#]*$'. The client's registered set stays authoritative.  
   *Verifier: confirmed.*

3. **[LOW] Gap: Validation of private-use URI schemes**  
   *Reference:* RFC 8252 §7.1, §8.4 (erratum 8080 reported); draft-ietf-oauth-v2-1-16 §2.3.1  
   §8.4: the AS SHOULD enforce schemes based on a reversed domain name, and at a minimum SHOULD reject any private-use scheme that doesn't contain a period. draft-16 §2.3.1 repeats this. Neither RedirectUri (lines 716-730) nor any client model in the YAML states it. Reported erratum 8080 proposes softening §7.1's client-side MUST to SHOULD; it doesn't touch the AS-side SHOULD in §8.4.  
   *Suggested change:* Add to RedirectUri.description, and to any future client-registration schema: 'For private-use schemes the AS SHOULD require a reverse-domain-name scheme, and rejects schemes that contain no "." (RFC 8252 §8.4).'  
   *Verifier: confirmed.*

4. **[LOW] Gap: Registration rules for native clients (client type, complete redirect URI)**  
   *Reference:* RFC 8252 §8.4, §7.2; draft-ietf-oauth-v2-1-16 §8.1.1, §2.3.1  
   §8.4: native apps MUST be registered as public clients. The AS MUST record the client type and MUST require the complete redirect URI, including the path. Because claimed-https redirects look like web redirects (§7.2), the recorded client type is the only way to tell them apart. The YAML has no client model: no /register path, and the IANA client-metadata names redirect_uris, token_endpoint_auth_method and application_type are absent per the IANA absence list. These rules have nowhere to live. Registration may happen out of band, so this is a documentation gap rather than a wire break.  
   *Suggested change:* When adding a client-registration or ClientMetadata schema (RFC 7591 cluster), include redirect_uris (complete URIs with path), token_endpoint_auth_method (none means public) and the OIDC application_type (native or web), and document the §8.4 rules there. Until then, add a short note to the /authorize description.  
   *Verifier: partially correct —* The 'MUST be registered as public clients' rule has an exception: native apps that receive per-instance secrets through Dynamic Client Registration (RFC 7591) need not be public (RFC 8252 §8.4; draft-16 §8.1.1). Everything else is accurate, and the missing client model is the real reason these rules have nowhere to go.

5. **[LOW] Gap: Shared secrets in native apps**  
   *Reference:* RFC 8252 §8.5; draft-ietf-oauth-v2-1-16 §8.1  
   §8.5: requiring public native apps to authenticate with a shared secret is NOT RECOMMENDED. An AS that still requires an embedded secret MUST treat the client as public and not accept the secret as proof of identity. draft-16 §8.1 hardens this to 'MUST NOT require'. The YAML allows none (line 2042) and {} (line 268) but never states the rule.  
   *Suggested change:* Add to the /token description after line 235: 'Native and browser-based apps are public clients (none). A secret shipped inside a distributed app is not a credential: the AS treats such clients as public and doesn't accept the secret as proof of identity (RFC 8252 §8.5; OAuth 2.1 §8.1).'  
   *Verifier: confirmed.*

6. **[LOW] Gap: Consent and client impersonation for native apps**  
   *Reference:* RFC 8252 §8.6  
   The AS SHOULD NOT process authorization requests automatically, even for a client_id the user approved before, unless the client's identity can be assured. Claimed-https redirects or platform attestation MAY count as that assurance. The /authorize description (lines 113-127) doesn't mention this.  
   *Suggested change:* Add to the /authorize description: 'For public native clients whose identity can't be verified (e.g. private-use or loopback redirects), the AS SHOULD NOT skip consent based on an earlier approval (RFC 8252 §8.6).'  
   *Verifier: confirmed.*

7. **[LOW] Gap: Embedded user-agents**  
   *Reference:* RFC 8252 §8.12, §8.7  
   Native apps MUST NOT use embedded user-agents. Authorization endpoints MAY detect and block them, and the AS MAY require an authentication factor that only a real external user-agent can provide. There is no wire element, and the YAML doesn't mention the rule.  
   *Suggested change:* Add an informative note to the /authorize description. Optionally state that a blocked embedded-user-agent request gets the 400 HTML page (lines 196-205) or an error redirect.  
   *Verifier: partially correct —* The only AS-side keyword is §8.12's MAY (detect and block). The MUST NOT binds the client, and §8.7's authentication-factor defence is non-normative ('can'), not a MAY. The YAML is silent on all of this, so an informative note is the right fix.

8. **[LOW] Gap: RFC 8252 is not referenced**  
   *Reference:* RFC 8252 (whole document; updates RFC 6749 §9)  
   The RFC is vendored (references/rfc-sources/rfc8252.txt) but missing from the Covered-specifications table (lines 18-45) and never cited in a description, even though OAuth 2.1 §8 depends on it.  
   *Suggested change:* Add '| RFC 8252 | 2017 | OAuth 2.0 for Native Apps (BCP 212) |' to the table. Cite RFC 8252 §7.3 and §8.4 from RedirectUri, and §6 and §8.1 from CodeChallenge.  
   *Verifier: confirmed.*

## RFC 10017 OAuth 2.0 for Browser-Based Applications

*August 2026 · Best Current Practice (BCP 212, alongside RFC 8252) · YAML coverage: **partial** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** RFC 10017 is the IETF best current practice for OAuth in JavaScript single-page apps (SPAs). It explains how malicious JavaScript (XSS or a compromised script) can steal tokens, or silently run a fresh authorization code flow in a hidden iframe. It then ranks three architectures from most to least secure. Backend-for-Frontend (BFF): a confidential server-side client keeps every token and proxies API calls behind an HttpOnly cookie session. Token-mediating backend: a confidential backend gets the tokens but hands access tokens to the browser. Browser-based public client: the SPA itself uses Authorization Code + PKCE, optionally with DPoP. It deprecates the Implicit grant, the password grant and service-worker OAuth. It also gives the authorization server concrete duties: enforce PKCE; rotate or sender-constrain refresh tokens and cap their lifetime; never require embedded secrets; require exact redirect URIs; send CORS headers on the endpoints the browser calls.

**Why it was created.** RFC 6749 (2012) pushed browser apps toward the Implicit grant because, before CORS was widespread, a page couldn't make the cross-origin POST to the token endpoint (RFC 10017 §4). That put access tokens in URL fragments, browser history and within reach of third-party scripts (§7.2). With CORS widely supported and PKCE proven, the OAuth WG's draft-ietf-oauth-browser-based-apps moved SPAs to Authorization Code + PKCE. Just as important, it gives an honest threat model: no in-browser storage trick stops an attacker who can start a new flow (§5.1.3), so sensitive apps should use backend patterns such as the BFF. It sits beside RFC 8252 in BCP 212 and tightens RFC 9700 for browsers.

<details><summary>Already modeled in the YAML (10)</summary>

- PKCE enforced for browser-based public clients (§6.3.2.1, §6.3.2.2): CodeChallenge description (lines 768-771), /authorize description (120-123), code_verifier required (lines 1244, 1259-1266)
- Authorization Code only, with no access tokens from the authorization endpoint (§7.2) and no password grant (§7.3): ResponseType enum code, id_token, 'code id_token' (lines 701-706); intentional exclusions (lines 59-61, 226-227)
- Refresh tokens for public clients are rotated or sender-constrained (§6.3.2.3, first bullet): RefreshTokenRequest.description (lines 1286-1289), TokenResponse.refresh_token.description (1435-1439)
- Exact redirect URI matching (§6.3.3.2.1): RedirectUri.description (lines 720-724)
- DPoP sender-constrained tokens for browser clients (§6.3.4.2.2, §9.2): DPoPHeader (lines 972-985), DPoPJKT (962-970), DPoP-Nonce header (1051-1057) on the /token 200 (lines 255-256) and in OAuthErrorWithDPoPNonce (1074-1090), token_type DPoP (1420-1427), dpop_signing_alg_values_supported (2188-2190)
- Confidential-client authentication for a BFF or token-mediating backend (§6.1.3.1, §6.1.3.7, §6.2.3.1, §6.2.3.4): /token security clientSecretBasic and mtls (lines 265-267); ClientAuthFields with client_assertion for private_key_jwt (1175-1200); token_endpoint_auth_methods_supported (2037-2049)
- Public clients without secrets (§6.3.3.1): none (line 2042), empty security alternative {} (line 268)
- Reducing token authority (§9.1) and token-mediating-backend downscoping (§6.2.2.3): RFC 8707 resource on /authorize (Resource, lines 880-892) and on token requests (ResourceIndicators, 1203-1218); narrowing scope on refresh (1302-1307); expires_in (1428-1432)
- Mix-up mitigation (§9.3): iss in the authorization response (lines 164-169) and authorization_response_iss_parameter_supported (2206-2211)
- Combining with OIDC (§6.1.2.4): id_token in TokenResponse (lines 1443-1448)

</details>

**Follow-up on the May-2026 validation notes.** There is no RFC 10017 file; it was still an Internet-Draft at the May-2026 audit. Four related CORS items from other May-2026 notes are all still open, since there is no CORS text anywhere in the YAML: oauth-2.1-draft.md asked for CORS on /token (§3.2) and for the 'CORS MUST NOT at /authorize' note (§3.1); 7009-token-revocation.md suggested a CORS note on /revoke; oidc-core-1.0.md suggested CORS on /userinfo.

**Notes.** The AS duties in RFC 10017 that overlap RFC 9700 and OAuth 2.1 are already modeled: PKCE, no implicit or password grant, exact redirect matching, refresh-token rotation, DPoP, RFC 8707 and RFC 9207. The browser-specific additions are not: CORS, refresh-token lifetime caps, the no-shared-secret rule, and session linkage. The BFF's own 'check session', 'login', 'logout' and API-proxy endpoints (§6.1.2.1) belong to the client's backend, not the AS, so they are out of scope here; they could go in a separate companion spec. The postMessage and in-browser communication rules (§6.3.3.3, RFC 9700 §4.17) don't apply, because the YAML models no web_message response mode (ResponseMode enum at lines 846-855). No errata at rfc-editor.org as of 2026-10-10.

### Findings (2 high · 2 medium · 4 low)

1. **[HIGH] Gap: CORS on the token endpoint and other AS endpoints the browser calls (and no CORS at /authorize)**  
   *Reference:* RFC 10017 §6.3.3.4 (also §4, §7.2.1); draft-ietf-oauth-v2-1-16 §3.1, §3.2; RFC 9449 §7.1, §8; OIDC Discovery 1.0 §3; RFC 7009 §2.3  
   §6.3.3.4: 'The authorization server and the resource server MUST send necessary CORS headers'. For the AS this means the token endpoint, plus metadata, JWKS, dynamic registration, revocation, introspection and UserInfo when the app calls them. The AS may approve a known origin at preflight and then reject the actual request after checking that client's registered origins. The YAML has no CORS surface at all: no options operations, and no Access-Control-* or Vary: Origin response headers on /token (lines 210-268), /revoke, /userinfo, /jwks, /par or the .well-known documents. For DPoP-using SPAs (§6.3.4.2.2) the DPoP request header forces a preflight. RFC 9449 §8 and §7.1 say DPoP-Nonce and WWW-Authenticate stay invisible to JavaScript unless they are listed in Access-Control-Expose-Headers. Without that, the use_dpop_nonce retry modeled at lines 1074-1090 can't work from a browser. In the other direction, draft-16 §3.1 says CORS MUST NOT be supported at /authorize, and OIDC Discovery §3 says it is NOT RECOMMENDED there.  
   *Suggested change:* Add components.headers AccessControlAllowOrigin ('*' or the request's origin), AccessControlExposeHeaders (example 'DPoP-Nonce, WWW-Authenticate') and Vary (example 'Origin'). Attach them to the 200, 400 and 401 responses of /token, /revoke, /userinfo, /jwks, /par and both .well-known documents. Add options operations, at least for /token, /userinfo and /par, returning 204 with Access-Control-Allow-Origin, Access-Control-Allow-Methods, Access-Control-Allow-Headers (DPoP, Authorization, Content-Type) and Access-Control-Max-Age. Note on /authorize: 'MUST NOT return CORS headers (OAuth 2.1 §3.1).' Describe the per-client allowed-origin check, e.g. derived from the origins of the client's registered redirect URIs.  
   *Verifier: confirmed.*

2. **[HIGH] Gap: Refresh-token lifetime limits for browser-based clients**  
   *Reference:* RFC 10017 §6.3.2.3 (motivated by §5.2.1)  
   If the AS issues refresh tokens to browser-based apps, it must do more than rotate or sender-constrain them (which the YAML already says). It MUST either set a maximum refresh-token lifetime or expire refresh tokens left unused for some time. It MUST NOT give a rotated refresh token a later expiry than the initial one when that one had a preset expiration. RFC 10017's example: rotation every 10 minutes still ends 8 hours after the original authorization. RefreshTokenRequest (lines 1286-1289) and TokenResponse.refresh_token (1435-1439) describe only rotation and sender-constraint. A server built from the YAML could issue rotated refresh tokens that renew forever, which is exactly the stolen-token risk described in §5.2.1.  
   *Suggested change:* Extend both descriptions: 'For browser-based public clients the AS MUST also bound refresh-token validity, by an absolute maximum lifetime or an idle timeout, and MUST NOT give a rotated refresh token a later expiry than the grant's original refresh token (RFC 10017 §6.3.2.3). These policies MAY differ from those for other public clients.'  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: Tie refresh-token lifetime to the user's AS session (logout invalidates)**  
   *Reference:* RFC 10017 §6.3.2.3  
   The AS SHOULD link the lifetime of refresh tokens issued to browser-based apps to the user's authenticated session at the AS. Logging out then invalidates them, 'mimicking a single-logout scenario'. The YAML lists end_session_endpoint (lines 1989-1992) and the front- and back-channel logout metadata (2219-2234) but has no logout path. No description connects refresh-token validity to the end of the session.  
   *Suggested change:* Add to TokenResponse.refresh_token.description: 'For browser-based clients, the refresh token SHOULD stop working when the user's AS session ends (RFC 10017 §6.3.2.3).' When a logout or end-session path is modeled, state that it revokes these refresh tokens.  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: Client authentication of browser-based applications**  
   *Reference:* RFC 10017 §6.3.3.1  
   The AS MUST NOT require browser-based apps to authenticate with a shared secret. An AS that still requires a statically embedded secret MUST treat the client as public and not accept the secret as proof of identity. The YAML allows none and {} but never states this rule (/token description lines 229-235; token_endpoint_auth_methods_supported line 2049).  
   *Suggested change:* Add to the /token description and token_endpoint_auth_methods_supported.description: 'Browser-based (SPA) and native apps are public clients (none). The AS MUST NOT require a shared secret from them, and an embedded secret is not proof of identity (RFC 10017 §6.3.3.1; RFC 8252 §8.5).'  
   *Verifier: confirmed.*

5. **[LOW] Gap: Automatic approval and client identity for SPAs**  
   *Reference:* RFC 10017 §6.3.3.2  
   The AS SHOULD NOT process authorization requests automatically, without consent, unless the client's identity is assured. If the client_id was approved before, exact matching against a fixed set of registered absolute https redirect URIs (no wildcard domains, paths or query strings) MAY count as proof of identity. The /authorize description (lines 113-127) doesn't mention this.  
   *Suggested change:* Add to the /authorize description: 'Earlier consent MAY be reused for a public browser-based client only when its redirect URIs are exact, absolute https URIs (RFC 10017 §6.3.3.2); otherwise ask for consent again.'  
   *Verifier: confirmed.*

6. **[LOW] Gap: Keep ID Token claims to what the client uses**  
   *Reference:* RFC 10017 §9.1  
   The AS SHOULD NOT include ID Token claims the client doesn't use. TokenResponse.id_token (lines 1443-1448) and IDTokenClaims (line 2461 onward) say nothing about this.  
   *Suggested change:* Add to TokenResponse.id_token.description: 'Include only the claims the client needs (RFC 10017 §9.1); others can come from UserInfo.'  
   *Verifier: confirmed.*

7. **[LOW] Gap: RFC 10017 is neither vendored nor cited**  
   *Reference:* RFC 10017 (whole document); draft-ietf-oauth-v2-1-16 §9, §10  
   references/rfc-sources had no rfc10017.txt; it and RFC 10027 were the only 2 of the 36 OAuth WG RFCs not vendored. *(Update 2026-10-11: both are now vendored.)* The Covered-specifications table (lines 18-45) and the descriptions never cite it; browser rules are attributed only to RFC 9700 and OAuth 2.1. draft-16 §9 'Browser-Based Apps' is still a TODO to import this BCP's normative text, and §10 still cites it as I-D.ietf-oauth-browser-based-apps.  
   *Suggested change:* Vendor rfc10017.txt. Add '| RFC 10017 | 2026 | OAuth 2.0 for Browser-Based Applications (BCP 212) |' to the table. Cite RFC 10017 §6.3.2.1 in CodeChallenge, §6.3.2.3 in RefreshTokenRequest and TokenResponse.refresh_token, and §6.3.3.4 in /token.  
   *Verifier: confirmed.*

8. **[LOW] Gap: Telling clients and BFFs when the refresh token expires (optional; Internet-Draft)**  
   *Reference:* RFC 10017 §6.1.2.2, §6.2.2.2 (context); draft-ietf-oauth-refresh-token-expiration-03 §6.1, §12  
   RFC 10017 suggests that a BFF or token-mediating backend set its cookie-session lifetime to the refresh token's maximum lifetime 'if such information is known upfront'. RFC 6749 has no token-response field for that. The OAuth WG draft draft-ietf-oauth-refresh-token-expiration-03 (July 2026; a WG document, not an RFC) defines token-response parameters refresh_token_timeout and authorization_expires_in, plus AS metadata refresh_token_expiration_types_supported. The YAML has none of them, though TokenResponse's additionalProperties: true would allow them.  
   *Suggested change:* Optionally add refresh_token_timeout and authorization_expires_in (integer seconds) to TokenResponse, labelled 'draft-ietf-oauth-refresh-token-expiration-03, Internet-Draft, may change'.  
   *Verifier: confirmed.*

## Verifier corrections to the summaries above

- RFC 10017 summary says 'It deprecates the Implicit grant, the password grant and service-worker OAuth'. Only Implicit and ROPC carry normative prohibitions: for Implicit, §7.2 says the AS 'MUST NOT issue access tokens in the authorization response'; for ROPC, §7.3 says it 'MUST NOT be used'. The service-worker pattern (§7.4) is only 'not recommended' (§7.4.1.1), i.e. discouraged. Section 7 is titled 'Discouraged and Deprecated Architecture Patterns'.
- cluster_notes says 'All fixes must be mirrored in oauth-openapi-modular: spec/components/parameters.yaml:36, :100, spec/components/schemas/par.yaml:38'. According to oauth-openapi-modular/README.md, the modular tree is generated mechanically from the single-file spec by split-oauth-openapi.py. dist/oauth-openapi.bundled.yaml repeats the same text (l.670 RedirectUri, l.729-734 CodeChallengeMethod, l.1521 default: S256). The fix is to edit oauth-openapi.yaml, re-run the split script and re-bundle, not to hand-edit files. Also, the stale draft -15 sentence starts at parameters.yaml:94; line 100 holds only the RFC 9700 §4.8 mis-citation.
