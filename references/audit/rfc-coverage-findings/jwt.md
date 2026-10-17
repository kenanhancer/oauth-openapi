# JWT & JWT best practices — RFC 7519, 7797, 8725, rfc8725bis

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 7519](#rfc-7519-json-web-token-jwt) | May 2015 | Proposed Standard (OAuth WG); updated by RFC 7797 and RFC 8725; 2 verified errata (8060 technical §7.2 step 5; 8388 editorial) | mostly | 0 | 3 | 7 |
| [RFC 7797](#rfc-7797-json-web-signature-jws-unencoded-payload-option) | February 2016 | Proposed Standard (JOSE WG); Updates RFC 7519; no errata | none (verifier corrected from not-applicable) | 0 | 0 | 1 |
| [RFC 8725](#rfc-8725-json-web-token-best-current-practices) | February 2020 | Best Current Practice (BCP 225); Updates RFC 7519; no errata; will be obsoleted by draft-ietf-oauth-rfc8725bis when that is published | partial | 0 | 4 | 8 |
| [draft-ietf-oauth-rfc8725bis-10](#draft-ietf-oauth-rfc8725bis-10-json-web-token-best-current-practices-draft-ietf-oauth-rfc8725bis) | August 2026 | Internet-Draft -10 dated 21 Aug 2026; intended BCP; obsoletes RFC 8725 and updates RFC 7519 if approved. IESG-approved and in the RFC Editor queue since 2026-08-25, but 'Blocked' on its normative reference draft-ietf-jose-deprecate-none-rsa15 (at -06, IESG 'Waiting for AD Go-Ahead' as of 2026-10-09). | partial | 0 | 4 | 6 |

**Cluster notes.** Scope covered: RFC 7519 (vendored), RFC 7797 (not vendored at the time, now vendored; Updates 7519), RFC 8725 (vendored, BCP 225, Updates 7519) and draft-ietf-oauth-rfc8725bis-10. I read all four in full, checked them against oauth-openapi.yaml (2,704 lines), checked RFC 9068/9101/9449/9701/7523/7662/8414/9700 and OIDC Core where the YAML borrows their JWT rules, and verified status with today's RFC index, the RFC Editor queue XML, datatracker and the rfc-editor errata pages.

Headline: since the May-2026 audit the JWT surface has improved a lot. The YAML now has JWT, StringOrURI, NumericDate, IDTokenClaims, JWTAccessTokenClaims, JWTIntrospectionResponse and UserInfoSignedResponse schemas, all registered claims are typed correctly, aud is REQUIRED in every JWT kind the AS issues, and the JWT pattern already meets rfc8725bis §3.14.

Main remaining problems:
(1) The JWT.pattern at line 2440 rejects valid JWE compact serializations that have an empty Encrypted Key (alg dir or ECDH-ES). I tested this with a regex script and propose a fix that I verified.
(2) Nested JWTs and cty:'JWT' are never mentioned, although encrypted responses are advertised.
(3) RFC 8725 is cited nowhere. None of its algorithm, explicit-typing or audience/issuer rules are encoded: no 'none' exclusion on alg arrays except line 2308, no per-key alg binding, no typ catalogue, no HMAC-secret entropy rule.
(4) The JWT schema is applied to emitted response bodies but not to JWTs the AS receives: client_assertion, assertion, request, id_token_hint, DPoP.

Findings for other cluster owners:
(a) RFC 7662 §2.2 defines exp/iat/nbf in the introspection JSON as 'Integer timestamp'. IntrospectionResponse (1722-1729) now uses NumericDate, which is type number. The old 7519 audit's integer→number fix was over-applied here; use allOf [NumericDate, {type: integer}].
(b) RFC 9068 has three issues:
   - The JWT example for TokenResponse.access_token (line 1419) decodes to {iss, exp, aud, sub, client_id}, missing the REQUIRED iat and jti (§2.2).
   - The JWTAccessTokenClaims description (2517-2519) says JWT access tokens are 'advertised via signing alg arrays in discovery'. No AS metadata does this, and §4 says no mechanism identifies the access-token signing key.
   - JWTAccessTokenClaims.sub (2538-2540) says it 'MUST equal client_id'. §2.2 only says SHOULD (an identifier for the client). Filed under rfc8725bis.
(c) RFC 8414 §2 says 'none' MUST NOT be used in token/revocation/introspection *_auth_signing_alg_values_supported (2050-2068). This is not encoded.
(d) RFC 7523: the assertion description (1342) narrows aud to 'the AS token endpoint URL', which §3 item 3 offers only as a MAY. draft-ietf-oauth-rfc7523bis-11 (in the RFC Editor queue) moves aud to the AS issuer identifier and adds typ client-authentication+jwt.
(e) OIDC Discovery says the jwks_uri JWK Set 'MUST NOT contain private or symmetric key values'. The JWK schema served by /jwks (1822-1902) documents k and lists HS256 as an example with no such caveat.
(f) RFC 9728 §1.2: ProtectedResourceMetadata.resource (2281-2285) uses $ref StringOrURI, which accepts any string without ':'. The resource identifier must be an https URL with no fragment.
(g) Every schema fix must be regenerated into oauth-openapi-modular/spec/components/schemas/jose.yaml (lines 112-135 mirror JWT/StringOrURI/NumericDate) with split-oauth-openapi.py.

Vendoring: add RFC 7797, which formally updates the vendored RFC 7519. Add a -10 snapshot of rfc8725bis; it will obsolete the vendored RFC 8725 once published. It is IESG-approved and in the RFC Editor queue since 2026-08-25, blocked on draft-ietf-jose-deprecate-none-rsa15, which was at -06 with IESG state 'Waiting for AD Go-Ahead' on 2026-10-09. RFC 7519 and RFC 8725 are already vendored and byte-identical to rfc-editor.org.

Errata: RFC 7519 has verified technical erratum 8060 (2025), which rewrites §7.2 step 5 so unknown header parameters are ignored unless listed in crit, plus editorial erratum 8388. RFC 7797 and RFC 8725 have no errata.

## RFC 7519 JSON Web Token (JWT)

*May 2015 · Proposed Standard (OAuth WG); updated by RFC 7797 and RFC 8725; 2 verified errata (8060 technical §7.2 step 5; 8388 editorial) · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 7519 defines the JSON Web Token. A JWT is a compact, URL-safe string whose JSON 'claims set' is signed or MACed (JWS) and/or encrypted (JWE), and it is always sent in Compact Serialization as dot-separated base64url parts. The RFC registers the seven standard claims (iss, sub, aud, exp, nbf, iat, jti) and the StringOrURI and NumericDate value types, explains the typ and cty headers (cty:'JWT' marks a Nested, signed-then-encrypted JWT), and gives step-by-step creation and validation rules plus the application/jwt media type and the urn:ietf:params:oauth:token-type:jwt URN. Every 'JWT' in OAuth/OIDC is built on it: ID Tokens, RFC 9068 access tokens, client assertions, request objects, DPoP proofs and JWT introspection responses.

**Why it was created.** OAuth 2.0 (RFC 6749, 2012) left token formats opaque on purpose, but deployments needed an interoperable, self-contained security token small enough for HTTP headers and URL query parameters. SAML assertions were XML-heavy and complex. Simple Web Tokens (SWT) allowed only string claims and HMAC. Building on the JOSE WG's JWS/JWE, the OAuth WG standardized JWT in 2015 for identity tokens (OpenID Connect) and authorization tokens. Its appendices and acknowledgements credit SWT, JSON Simple Sign, Magic Signatures and Facebook Canvas signed requests as influences.

<details><summary>Already modeled in the YAML (17)</summary>

- §1/§3 compact-serialization JWT string: components.schemas.JWT (2434-2441). Its pattern (2440) allows only base64url characters and '.'. It is the body schema for application/token-introspection+jwt (346-348) and application/jwt (503-505, 553-555).
- §2 StringOrURI: components.schemas.StringOrURI (2443-2448)
- §2 NumericDate: components.schemas.NumericDate (2450-2456), type number, with a fractional example
- §4.1.1 iss as StringOrURI: IntrospectionResponse.iss (1738-1739), JWTIntrospectionResponse.iss (1774-1776), UserInfoSignedResponse.iss (2421-2422), IDTokenClaims.iss (2470-2472), JWTAccessTokenClaims.iss (2524-2526)
- §4.1.2 sub: IntrospectionResponse.sub (1730-1731), IDTokenClaims.sub (2473-2475), JWTAccessTokenClaims.sub (2536-2540), UserInfoResponse.sub (2350-2351). All are type string, not StringOrURI.
- §4.1.3 aud as a single StringOrURI or an array of StringOrURI (oneOf): IntrospectionResponse.aud (1732-1737), JWTIntrospectionResponse.aud (1777-1783), UserInfoSignedResponse.aud (2423-2428), IDTokenClaims.aud (2476-2482), JWTAccessTokenClaims.aud (2529-2535)
- §4.1.4 exp as NumericDate: IntrospectionResponse.exp (1722-1724), IDTokenClaims.exp (2483-2485), JWTAccessTokenClaims.exp (2527-2528)
- §4.1.5 nbf as NumericDate: IntrospectionResponse.nbf (1728-1729)
- §4.1.6 iat as NumericDate: IntrospectionResponse.iat (1725-1727), JWTIntrospectionResponse.iat (1784-1786), IDTokenClaims.iat (2486-2488), JWTAccessTokenClaims.iat (2544-2545)
- §4.1.7 jti as string: IntrospectionResponse.jti (1740-1741), JWTAccessTokenClaims.jti (2546-2548, 'replay protection')
- §4/§4.2/§4.3 extensible claim sets (claims not understood are ignored): additionalProperties: true on IntrospectionResponse (1706), JWTIntrospectionResponse (1772), IDTokenClaims (2468), JWTAccessTokenClaims (2522)
- §5.1 typ: the JWT example header is {alg:RS256, typ:JWT} (2441). Explicit typ values: at+jwt (2517, 2644), dpop+jwt (980, 2655), token-introspection+jwt (352-353, 1766-1767).
- §9/§10.2 URN urn:ietf:params:oauth:token-type:jwt in the TokenTypeURI enum (1395)
- §10.3 application/jwt media type on the /userinfo GET 200 (503-511) and POST 200 (553-561) responses
- JWT-valued fields described in prose: TokenResponse.id_token (1443-1448), ClientAuthFields.client_assertion (1191-1196), JWTBearerTokenRequest.assertion (1338-1345, lists the RFC 7523 §3 claims), parameters.Request (950-960), parameters.DPoPHeader (972-984, 'single compact-serialized JWT'), OAuthServerMetadata.signed_metadata (2262-2267), ProtectedResourceMetadata.signed_metadata (2333-2338)
- §2/§7.3 exact iss comparison: OAuthServerMetadata.issuer 'MUST be byte-identical to the value in tokens' iss claim' (1947-1950)
- RFC 7519 is listed in the info.description 'Covered specifications' table (line 24)

</details>

**Follow-up on the May-2026 validation notes.** references/rfc-validation/7519-jwt.md (2026-05-10) has 15 bullets: 6 MISSING, 3 WRONG and 6 NICE-TO-HAVE. The duplicate-claim-name item appears twice.

FIXED (7):
- IDTokenClaims (2461)
- JWTAccessTokenClaims (2514)
- NumericDate as type number (2450)
- reusable JWT schema (2434)
- reusable StringOrURI (2443), used for iss and aud
- exp/iat/nbf now $ref NumericDate
- bearerFormat: JWT removed (2645-2646)

PARTIAL (2):
- StringOrURI is not applied to sub, and is mislabeled for jti.
- The JWT schema is wired only to the three response bodies, not to id_token, assertion, client_assertion, request, id_token_hint or DPoP.

OPEN (5 distinct):
- RFC 7519 §4.1.x citations on IntrospectionResponse claims (WRONG #3)
- the §4 duplicate-claim-name rule
- typ/cty/Nested-JWT documentation
- a 'none' note on id_token_signing_alg_values_supported (2082-2085)
- the §7.3 comparison rules

OVER-CORRECTION: WRONG #1 (integer → number) is right for JWT payload schemas. On IntrospectionResponse (1722-1729), though, it now contradicts RFC 7662 §2.2, which defines exp/iat/nbf in the JSON introspection response as 'Integer timestamp'.

NEW (not in the old audit): the JWE empty-segment pattern defect at line 2440.

**Notes.** Relevance: OAuth 2.1-16 cites RFC 7519 only informatively (§12.2). An OAuth 2.1 + OIDC AS still cannot avoid JWTs: ID Tokens, private_key_jwt and client_secret_jwt, DPoP, JAR, RFC 9068 and RFC 9701 all use them. Hence 'recommended'.

Errata: verified technical erratum 8060 (2025-04-03) replaces §7.2 step 5 with 'validate the header according to RFC 7515/7516'. Unknown header parameters are therefore ignored unless listed in crit. Reported erratum 5906 (unverified) asks for MUST-reject of unacceptable algorithms, which RFC 8725 §3.2 effectively provides.

RFC 7519 §8 still makes 'none' and RSA1_5 mandatory to implement; the BCPs (RFC 8725 §3.2, rfc8725bis §3.2) supersede that in practice.

IANA: every RFC 7519 registration (7 claims, the 3 JWE header copies, the URN and application/jwt) appears in the YAML as a token. In this cluster only cty (registered by RFC 7515/7516, used by RFC 7519 §5.2) is absent.

### Findings (0 high · 3 medium · 7 low)

1. **[MEDIUM] Gap: Nested JWT: cty 'JWT' on the outer JWE and sign-then-encrypt order**  
   *Reference:* RFC 7519 §2 (Nested JWT), §5.2, §7.1 step 5, §7.2 step 8, §11.2  
   The YAML repeatedly advertises 'signed (optionally encrypted)' JWTs: /introspect application/token-introspection+jwt (349-355), /userinfo application/jwt (489-490, 506-511, 556-561), parameters.Request (960) and JWTIntrospectionResponse (1765-1767). It also exposes encryption metadata (introspection_/id_token_/userinfo_/request_object_encryption_* at 2074-2113). But it never says that a signed-and-encrypted JWT is a Nested JWT whose outer JWE header MUST carry cty:'JWT' (§5.2), or that producers sign first and then encrypt (§11.2). RFC 9101 §4, RFC 9701 §5 and OIDC Core §2/§5.3.2 restate both as MUSTs. The token 'cty' appears nowhere in the YAML; the IANA diff also lists it as absent. IDTokenClaims.description (2462-2465) calls the wire form only 'a signed JWT'.  
   *Suggested change:* Append to components.schemas.JWT.description: 'Nested JWT (RFC 7519 §2, §5.2): a JWT that is both signed and encrypted MUST be signed first and then encrypted (§11.2). The outer JWE JOSE header MUST contain cty: JWT, and its plaintext is the inner JWS compact serialization. Recipients validate both layers (RFC 8725 §3.3), and an explicit typ belongs on the inner JWS (RFC 8725 §3.11).' Then add 'if encrypted, a Nested JWT — see JWT' to the two /userinfo application/jwt descriptions, the /introspect application/token-introspection+jwt description, TokenResponse.id_token, IDTokenClaims.description and parameters.Request.schema.description.  
   *Verifier: partially correct —* The YAML never mentions Nested JWTs or the RFC 7519 §5.2 MUST that the outer header carry cty 'JWT'. Sign-then-encrypt is a MUST in OIDC Core §2/§5.3.2/§6.1 and RFC 9101 §4; RFC 9701 §5 requires 'a Nested JWT'. In RFC 7519 §11.2 it is only 'normally ... should'. The proposed description must not say 'MUST be signed first and then encrypted (§11.2)'. Suggested wording: 'when both are applied, sign then encrypt (RFC 7519 §11.2; MUST per OIDC Core §2 and RFC 9101 §4) and set cty JWT on the outer JWE (RFC 7519 §5.2)'. Also note that OIDC allows encrypt-only UserInfo responses and Request Objects.

2. **[MEDIUM] Gap: Recipient processing rules: aud rejection, exp/nbf with leeway, duplicate claim names, ignoring unknown claims, exact string comparison**  
   *Reference:* RFC 7519 §4, §4.1.3, §4.1.4, §4.1.5, §7.2, §7.3 (made binding on the AS by RFC 7523 §3 item 10)  
   The AS is itself a JWT recipient. It receives client_assertion (1191-1196), the JWT-bearer assertion (1338-1345), request objects (950-960, 1642-1644), id_token_hint (929-937) and DPoP proofs (972-984). The YAML never states RFC 7519's MUST-level recipient rules: reject if aud is present but does not identify the processor (§4.1.3); reject on or after exp and before nbf, allowing only a small skew leeway (§4.1.4-§4.1.5); claim names MUST be unique, and parsers MUST reject duplicates or keep only the lexically last (§4); claims not understood MUST be ignored (§4); StringOrURI values are compared case-sensitively with no canonicalization, and only typ/cty are exceptions (§2, §7.3). RFC 7523 §3 item 10 requires the AS to reject any JWT 'not valid in all other respects per' RFC 7519. Today only the assertion description (1343-1345) mentions rejection, and only issuer (1949) mentions exact comparison. This was prior-audit MISSING/NICE items, still open.  
   *Suggested change:* Add a 'Validating a JWT (RFC 7519 §7.2)' paragraph to components.schemas.JWT.description, or to the info.description 'Modeling notes': accept the compact form only; reject duplicate member names (§4); ignore unknown claims (§4); reject if aud is present and does not identify the recipient (§4.1.3); reject if now >= exp or now < nbf, with at most a few minutes of skew (§4.1.4-§4.1.5); compare StringOrURI values exactly (§7.3). Reference this paragraph from the client_assertion, assertion, Request, PARRequest.request and DPoPHeader descriptions. Extend NumericDate.description with the exp/nbf comparison semantics.  
   *Verifier: confirmed.*

3. **[MEDIUM] Incorrect: 2440 components.schemas.JWT.pattern (mirrored at oauth-openapi-modular/spec/components/schemas/jose.yaml:118)**  
   *Reference:* RFC 7519 §3, §6, §10.3.1; RFC 7516 §7.1; RFC 7518 §4.5, §4.6  
   The pattern requires all 3 JWS segments or all 5 JWE segments to be non-empty. RFC 7519 §10.3.1 says JWT values are base64url parts 'some of which may be the empty string'. In JWE Compact Serialization (RFC 7516 §7.1) the Encrypted Key segment is empty for alg dir (RFC 7518 §4.5) and for ECDH-ES direct key agreement (RFC 7518 §4.6, the mode OIDC Core §10.2 describes for EC keys). I tested it: the current regex rejects 'eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4R0NNIn0..&lt;iv>.&lt;ciphertext>.&lt;tag>'. Generated validators would therefore reject valid encrypted application/jwt and application/token-introspection+jwt bodies (348, 505, 555), which the YAML itself calls 'optionally encrypted'. The pattern also silently rejects Unsecured JWTs (§6, whose third segment is empty). That is defensible under RFC 8725 §3.2, but it is not stated anywhere.  
   *Suggested change:* Use pattern: '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$|^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*$'. A JWS must have a non-empty signature; a JWE may have empty encrypted-key, IV and tag segments. I verified that it accepts the RFC 7519 §3.1 and A.1 examples and dir/ECDH-ES JWEs, and rejects Unsecured JWTs, JSON serialization and the RFC 7797 detached form. Then add to the description: 'Unsecured JWTs (alg none, RFC 7519 §6) are intentionally rejected (RFC 8725 §3.2).'  
   *Verifier: confirmed.*

4. **[LOW] Gap: Use of components.schemas.JWT for every JWT-valued field**  
   *Reference:* RFC 7519 §1, §3, §7.2 step 1  
   Under §1, a JWT is always a JWS or JWE Compact Serialization. The JWT schema is wired only into three response bodies (348, 505, 555). These JWT-valued fields remain bare strings: TokenResponse.id_token (1443-1448), ClientAuthFields.client_assertion (1191-1196), JWTBearerTokenRequest.assertion (1338-1345), parameters.Request (958-960), PARRequest.request (1642-1644), parameters.IDTokenHint (929-937), PARRequest.id_token_hint (1627-1628), parameters.DPoPHeader (983-984), OAuthServerMetadata.signed_metadata (2262-2267) and ProtectedResourceMetadata.signed_metadata (2333-2338). This is the prior audit's compact-serialization MISSING item, only partly fixed.  
   *Suggested change:* After the pattern fix (see incorrect), replace `type: string` with `$ref: '#/components/schemas/JWT'` at these ten locations, keeping each description. For the DPoP header and both signed_metadata fields, use a JWS-only variant with three segments (see the rfc8725bis entry). Leave subject_token/actor_token (1361-1368) as plain strings, because they may be opaque or SAML tokens.  
   *Verifier: partially correct —* Use $ref JWT (non-empty signature) only where a signature is mandatory: client_assertion and assertion (RFC 7523 §3 item 9), DPoP (JWS-only, RFC 9449 §4.2) and both signed_metadata fields (JWS-only, RFC 8414 §2.1). For TokenResponse.id_token, the id_token_hint fields and the request fields there are two options. Option 1: use a compact-form schema that admits an empty signature but not an empty payload, e.g. '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*$|^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*$' (tested). Option 2: state explicitly that this OAuth 2.1 profile forbids alg none, as a documented deviation from OIDC Core §2/§6.1 and OIDC Discovery.

5. **[LOW] Gap: sub typed as StringOrURI**  
   *Reference:* RFC 7519 §4.1.2, §2  
   §4.1.2 says the sub value is 'a case-sensitive string containing a StringOrURI value', and StringOrURI.description (2446-2448) claims it is 'Used for ... sub'. Yet every sub is `type: string`: IntrospectionResponse.sub (1730-1731), IDTokenClaims.sub (2473-2475), JWTAccessTokenClaims.sub (2536-2540) and UserInfoResponse.sub (2350-2351).  
   *Suggested change:* Change those four to `$ref: '#/components/schemas/StringOrURI'` and keep their descriptions. On IDTokenClaims.sub and UserInfoResponse.sub, also add OIDC Core §2's 255-ASCII-character limit (`maxLength: 255`) as an OIDC-specific constraint.  
   *Verifier: confirmed.*

6. **[LOW] Gap: StringOrURI is prose-only and incomplete**  
   *Reference:* RFC 7519 §2, §7.3  
   components.schemas.StringOrURI (2443-2448) is a bare `type: string` with prose. Nothing enforces 'any value containing a : character MUST be a URI'. It also omits the second sentence of §2: 'StringOrURI values are compared as case-sensitive strings with no transformations or canonicalizations applied.'  
   *Suggested change:* Add `anyOf: [{pattern: '^[^:]*$'}, {format: uri}]` to StringOrURI. Append to its description: 'Compared as case-sensitive strings with no transformation or canonicalization (RFC 7519 §2, §7.3).'  
   *Verifier: partially correct —* Use a pattern that does not rely on format assertion, e.g. pattern '^([^:]*|[A-Za-z][A-Za-z0-9+.-]*:\S*)$'. Any value containing ':' must then begin with an RFC 3986 scheme. Tested: 'joe', 'https://as.example.com', 'urn:ietf:params:oauth' and 'mailto:...' pass; 'a b:c' and '1abc:def' fail. Also add the §2/§7.3 sentence on case-sensitive comparison with no canonicalization.

7. **[LOW] Gap: Descriptions and section references for registered claims in the claim schemas**  
   *Reference:* RFC 7519 §4.1.1-§4.1.7 (referenced by RFC 7662 §2.2 and RFC 9068 §2.2)  
   The IntrospectionResponse claims (1722-1741) cite no RFC 7519 §4.1.x sections, and nbf, sub, aud, iss and jti have no description at all. This was prior-audit WRONG #3 and is still open. IDTokenClaims (2469-2509) does not declare the optional nbf and jti claims, and JWTAccessTokenClaims (2523-2573) does not declare nbf. JWTAccessTokenClaims.exp (2527-2528) lacks the 'REQUIRED.' description that the other required members have. This is harmless on the wire because additionalProperties is true, but weak as documentation.  
   *Suggested change:* Give each registered-claim property a one-line description that cites its section, e.g. IntrospectionResponse.nbf: 'Not-before time (RFC 7519 §4.1.5; RFC 7662 §2.2)' and jti: 'Unique token identifier (RFC 7519 §4.1.7)'. Add optional nbf (NumericDate) and jti (string) to IDTokenClaims and nbf to JWTAccessTokenClaims. Set JWTAccessTokenClaims.exp.description to 'REQUIRED. Expiration time (RFC 9068 §2.2; RFC 7519 §4.1.4).'  
   *Verifier: partially correct —* Add RFC 7519 §4.1.x descriptions to the IntrospectionResponse claims. Add 'REQUIRED.' descriptions to JWTAccessTokenClaims.exp and JWTAccessTokenClaims.iat. Declaring nbf/jti on IDTokenClaims, or nbf on JWTAccessTokenClaims, is optional documentation and not a gap against OIDC Core §2 or RFC 9068 §2.2.

8. **[LOW] Gap: iss/sub/aud copied into JWE headers**  
   *Reference:* RFC 7519 §5.3, §10.4.1  
   RFC 7519 registers iss, sub and aud as JWE header parameters so recipients can route encrypted JWTs before decrypting them. Recipients SHOULD check that these header copies match the encrypted claims. The YAML never mentions this, even though it advertises encrypted ID Tokens, UserInfo and introspection responses and request objects. OIDC Back-Channel Logout §2.4, implied by backchannel_logout_supported (2226-2228), says an encrypted Logout Token SHOULD copy iss into its header.  
   *Suggested change:* Add one sentence to components.schemas.JWT.description: 'An encrypted JWT MAY copy iss/sub/aud into JWE header parameters (RFC 7519 §5.3). Recipients SHOULD check that the copies equal the decrypted claims and must not trust them before decryption and validation.'  
   *Verifier: confirmed.*

9. **[LOW] Incorrect: 2446-2448 components.schemas.StringOrURI.description**  
   *Reference:* RFC 7519 §4.1.7, §4.1.2  
   The description says StringOrURI is 'Used for iss, aud, sub, jti JWT claims'. RFC 7519 §4.1.7 defines jti only as 'a case-sensitive string', with no StringOrURI or URI rule, so listing jti is wrong. The claim about sub is also inaccurate in practice, because no sub property uses $ref StringOrURI (see gaps).  
   *Suggested change:* Change the sentence to 'Used for the iss, sub and aud claims (RFC 7519 §4.1.1-§4.1.3); jti is a plain case-sensitive string (§4.1.7).' Apply the sub $ref change from the gaps.  
   *Verifier: confirmed.*

10. **[LOW] Gap: The YAML gives no privacy guidance for JWT contents** — *found by the verifier*  
   *Reference:* RFC 7519 §12 (with RFC 9101 §11.2.1, RFC 9068 §6)  
   The YAML gives no privacy guidance for JWT contents. ID Tokens (id_token_hint) and Request Objects travel as /authorize query parameters, and JWT access tokens are readable by clients, but JWE and data minimisation are never mentioned. RFC 7519 §12 requires disclosure protections when a JWT carries privacy-sensitive data.  
   *Suggested change:* Add to parameters.Request and parameters.IDTokenHint: 'May carry personal data; prefer PAR or JWE (RFC 7519 §12; RFC 9101 §11.2.1).' Add to JWTAccessTokenClaims.description: 'Visible to the client; encrypt or omit personal data (RFC 7519 §12; RFC 9068 §6).'

## RFC 7797 JSON Web Signature (JWS) Unencoded Payload Option

*February 2016 · Proposed Standard (JOSE WG); Updates RFC 7519; no errata · YAML coverage: **none (verifier corrected from not-applicable)** · relevance to an AS: informational · vendoring: vendor*

**What it is.** RFC 7797 adds the JWS header parameter 'b64'. When b64 is false, the payload is signed and carried as raw bytes instead of base64url, which avoids copying large or detached payloads. The header must sit in the protected header and must be listed in 'crit', so implementations that do not understand it reject the JWS rather than misread it. Its only change to RFC 7519 is a ban: JWTs MUST NOT use b64:false. For an OAuth server, this simply means every JWT it issues or accepts uses the normal base64url-encoded payload.

**Why it was created.** Some JWS use cases, such as signing large documents or detached-content signatures (for example HTTP message or payment signing), found base64url-encoding the payload wasteful or awkward. The JOSE WG added an opt-in unencoded mode. To protect JWT interoperability it excluded JWTs from that mode, so a b64:false object can never be parsed as an ordinary JWT.

**Follow-up on the May-2026 validation notes.** No prior validation notes: the RFC was not vendored before this audit and had never been audited.

**Notes.** I recommend vendoring this small (about 25 KB) text because it formally 'Updates: 7519', a vendored RFC. Without it the vendored RFC 7519 text is incomplete as amended; *(Update 2026-10-11: now vendored.)* 'catalog-only' is the fallback if the repo keeps vendoring limited to OAuth-WG and modeled RFCs.

Incidental behavior (not modeling): the JWT.pattern at 2440 accepts only base64url characters and needs a non-empty payload segment. It therefore rejects the RFC 7797 §4.2 detached example (tested), but it does not express the rule.

Relation to RFC 7519 erratum 8060: unknown JWS header parameters are ignored unless listed in crit. That is exactly why RFC 7797 §6 requires crit:['b64'].

### Findings (0 high · 0 medium · 1 low)

1. **[LOW] Gap: JWT restriction 'JWTs MUST NOT use b64:false' and crit handling**  
   *Reference:* RFC 7797 §6, §7 (with RFC 7515 §4.1.11)  
   RFC 7797, 'b64' and 'crit' appear nowhere in the YAML; the IANA diff also lists b64 as absent. That is acceptable, because the parameter lives inside the JWS and has no HTTP surface. However, components.schemas.JWT.description (2436-2439) is the YAML's only definition of what a JWT is, and it does not mention this formal update to RFC 7519.  
   *Suggested change:* Append to components.schemas.JWT.description: 'JWTs MUST NOT use the RFC 7797 unencoded-payload option (b64:false); a JWS whose crit lists an extension the recipient does not support, such as b64, MUST be rejected (RFC 7515 §4.1.11; RFC 7797 §6-§7).' Optionally list RFC 7797 in the info.description 'Covered specifications' table as an updater of RFC 7519.  
   *Verifier: confirmed.*

## RFC 8725 JSON Web Token Best Current Practices

*February 2020 · Best Current Practice (BCP 225); Updates RFC 7519; no errata; will be obsoleted by draft-ietf-oauth-rfc8725bis when that is published · YAML coverage: **partial** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 8725 is the security playbook for JWTs and formally updates RFC 7519. It catalogs real attacks: accepting alg 'none', RS256→HS256 key confusion, weak HMAC secrets, unchecked inner signatures in nested JWTs, compression leaks, invalid-curve ECDH-ES, non-UTF-8 encodings, token substitution and cross-JWT confusion, and kid/jku/x5u injection and SSRF. Its countermeasures include algorithm allowlists with exactly one algorithm per key, validating every cryptographic layer, high-entropy keys, and no compression before encryption. It also requires UTF-8 only, checking that keys belong to iss and that sub is valid, requiring and validating aud, explicit typing with typ, and mutually exclusive validation rules for each kind of JWT.

**Why it was created.** Within five years of RFC 7519, widely published library and deployment attacks showed that the JWT spec under-specified security processing. Examples include Tim McLean's 2015 disclosure of alg 'none' and RSA/HMAC confusion (CVE-2015-9235), Antonio Sanso's 2017 invalid-curve ECDH-ES attack, and offline brute-forcing of password-like HS256 keys. The OAuth WG wrote a BCP with actionable minimum rules for JWT library implementers, application developers and authors of JWT-based specs, calling it 'a floor, not a ceiling'.

<details><summary>Already modeled in the YAML (6)</summary>

- §3.9 aud is REQUIRED in every JWT payload schema the AS issues: IDTokenClaims.required (2467), JWTAccessTokenClaims.required (2521), JWTIntrospectionResponse.required (1771), UserInfoSignedResponse.required (2419)
- §3.11 explicit typing, with the 'application/' prefix omitted as recommended: at+jwt for JWT access tokens (2517-2518, 2644), dpop+jwt for DPoP proofs (980, 2655), token-introspection+jwt for JWT introspection (352-353, 1766-1767)
- §3.12 distinct claim sets per kind: JWTIntrospectionResponse nests the RFC 7662 members under token_introspection (1768-1769, 1787-1789); JWTAccessTokenClaims requires client_id and jti, which IDTokenClaims does not (2521 vs 2467)
- §3.8 issuer-to-key binding: OAuthServerMetadata.issuer is 'byte-identical to the value in tokens' iss claim' (1947-1950); jwks_uri is the issuer's key source (1961-1964); IDTokenClaims.iss 'MUST equal the OP's issuer' (2472); bearerAuth says JWT access tokens are 'validated locally against jwks_uri' (2644-2645)
- §3.1/§3.2 per-kind algorithm allowlist metadata: *_endpoint_auth_signing_alg_values_supported (2050-2068), introspection_signing/encryption (2071-2079), id_token_* (2082-2091), userinfo_* (2094-2102), request_object_* (2105-2113), dpop_signing_alg_values_supported (2188-2190, 2326-2328), backchannel_authentication_request_signing_alg_values_supported (2246-2248), and resource_signing_alg_values_supported with 'none MUST NOT be used' (2305-2308)
- §3.2 'none' (implicit only): the JWT.pattern (2440) requires a non-empty signature segment, so Unsecured JWTs never pass as JWT-typed bodies

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes. RFC 8725 was vendored on 2026-06-06 without a references/rfc-validation file (see references/rfc-sources/README.md), and the May-2026 audit synthesis never mentions it.

**Notes.** OAuth 2.1-16 does not cite RFC 8725. It is, however, a normative reference of RFC 9068 and RFC 9701, both modeled here, and of RFC 9901. RFC 9101 §6.2 and RFC 9449 §4.2 apply it informatively. No errata.

Treat it as the current JWT BCP until draft-ietf-oauth-rfc8725bis is published. That draft keeps everything in RFC 8725 and tightens several points (see its entry).

RFC 8725's MUSTs describe implementation behavior that OpenAPI cannot enforce. I rated gaps medium when a schema constraint (such as not: none) or an AS-specific MUST is involved, and low when they are documentation only.

### Findings (0 high · 4 medium · 8 low)

1. **[MEDIUM] Gap: Algorithm allowlists and exclusion of 'none' in the *_signing_alg_values_supported metadata**  
   *Reference:* RFC 8725 §2.1, §3.1, §3.2  
   Every algorithm array is a free `items: {type: string}` with no constraint and no guidance. Only resource_signing_alg_values_supported (2308) says 'none' MUST NOT be used. The specs that build on RFC 8725 forbid 'none' in several other places: RFC 8414 §2 for token_endpoint_auth_signing_alg_values_supported (2050-2056), revocation_endpoint_auth_signing_alg_values_supported (2060-2062) and introspection_endpoint_auth_signing_alg_values_supported (2066-2068); RFC 9449 §4.2 forbids 'none' and MAC algorithms for DPoP (2188-2190, 2326-2328); RFC 9068 §2.1 forbids 'none' for JWT access tokens. Nothing tells implementers that these arrays are the per-kind allowlists §3.1 asks for, i.e. verify alg against them and never trust the header's alg, which is the RS256→HS256 attack of §2.1. A server built from the YAML could advertise and accept 'none'.  
   *Suggested change:* Add components.schemas.JWSAlgorithm: type string, described as 'JWS alg value from the IANA JOSE registry; an allowlist entry compared case-sensitively (RFC 8725 §3.1-§3.2)', with examples [RS256, PS256, ES256, Ed25519]. Add JWSAlgorithmNotNone: allOf [$ref JWSAlgorithm, {not: {const: none}}]. Use JWSAlgorithmNotNone as items for the three *_endpoint_auth_signing_alg_values_supported arrays, introspection_signing_alg_values_supported, resource_signing_alg_values_supported and backchannel_authentication_request_signing_alg_values_supported. On both dpop_signing_alg_values_supported arrays, also add not: {enum: [none, HS256, HS384, HS512]}. Keep the id_token_, userinfo_ and request_object_ signing arrays as JWSAlgorithm, with a note that 'none' is allowed only where OIDC or RFC 9101 permit it and only after explicit client opt-in.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Catalogue of JWT kinds the AS issues and accepts, with explicit typ and mutually exclusive validation rules**  
   *Reference:* RFC 8725 §2.8, §3.11, §3.12 (applied by RFC 9068 §4-§5, RFC 9101 §10.8, RFC 9701 §8.1)  
   One issuer, the AS, mints several JWT kinds with overlapping claims: ID Tokens (IDTokenClaims 2461), signed UserInfo responses (UserInfoSignedResponse 2409), JWT access tokens (2514), JWT introspection responses (1763) and Logout Tokens (implied by backchannel_logout_supported at 2226-2228). It also consumes client assertions (1191), JWT-bearer assertions (1338), request objects (950, 1642) and DPoP proofs (972). §3.12 says that when one issuer issues several kinds, the validation rules MUST be mutually exclusive. In the YAML, ID Tokens and signed UserInfo JWTs are both untyped with iss=OP, aud=client_id and sub, and their schemas overlap: a UserInfo JWT that also carries exp and iat satisfies IDTokenClaims. Request objects never mention their registered type oauth-authz-req+jwt (RFC 9101 §4, §10.8). The resource-server MUST checks of typ are missing from bearerAuth (2637-2646) and JWTAccessTokenClaims (2515-2519): typ must be at+jwt or application/at+jwt (RFC 9068 §4), and a token-introspection+jwt must never be accepted as an access token (RFC 9701 §8.1). The rule that typ goes on the inner JWT of a Nested JWT (§3.11) is also missing.  
   *Suggested change:* Add a 'JWT kinds' table to components.schemas.JWT.description, or to info.description, with columns kind → typ → distinguishing claims/aud: - ID Token: typ JWT or absent; aud=client_id; exp+iat+nonce - signed UserInfo: accepted only as the /userinfo response body - JWT access token: at+jwt; aud=resource; client_id+jti - JWT introspection: token-introspection+jwt; token_introspection claim - DPoP proof: dpop+jwt; htm/htu/jti/iat - Request Object: oauth-authz-req+jwt RECOMMENDED; aud=AS issuer; never sub=client_id (RFC 9101 §10.8) - client assertion: iss=sub=client_id; aud=AS; client-authentication+jwt per draft-ietf-oauth-rfc7523bis - Logout Token: logout+jwt RECOMMENDED by OIDC Back-Channel Logout §2.4; no nonce Add 'RS MUST reject JWT access tokens whose typ is not at+jwt or application/at+jwt (RFC 9068 §4)' to bearerAuth.description, and add the oauth-authz-req+jwt note to parameters.Request and PARRequest.request.  
   *Verifier: partially correct —* Keep the catalogue gap and extend it. Add JARM response JWTs, signed metadata and CIBA signed requests. Describe Request Object typing as optional per RFC 9101 §10.8 (advisable for new profiles), not RECOMMENDED. Add the RFC 9701 §5 rule (no top-level sub/exp) and the RFC 9068 §5 rule (distinct aud per resource) as distinguishing rules.

3. **[MEDIUM] Gap: Issuer-key binding and audience validation for JWTs the AS receives**  
   *Reference:* RFC 8725 §3.8, §3.9 (with RFC 7523 §3 items 3-4, 7, 9 and RFC 9101 §4, §6.2)  
   §3.8: the keys used on a JWT MUST belong to its iss. §3.9: the recipient MUST reject the JWT if aud is missing or not associated with it. The YAML gives the AS no such rules for the JWTs it consumes. ClientAuthFields.client_assertion (1191-1196) does not say which keys verify it (the client's registered jwks/jwks_uri, or the client_secret for client_secret_jwt), nor that aud and exp must be checked. JWTBearerTokenRequest.assertion (1340-1345) gives aud only as 'the AS token endpoint URL', whereas RFC 7523 §3 item 3 offers that URL merely as a MAY-value; the rule is 'MUST reject any JWT that does not contain its own identity as the intended audience'. For request objects (950-960, 1642-1644) the YAML omits RFC 9101 §4 ('aud should be the value of the AS issuer') and §6.2 ('MUST be a key associated with the client'). Also, where aud is REQUIRED the array branches allow an empty array: no minItems at 1781-1783, 2426-2428, 2480-2482 or 2533-2535.  
   *Suggested change:* Append to the client_assertion, assertion and Request/PARRequest.request descriptions: 'The AS MUST verify the signature only with keys bound to the iss: for client assertions, the client's registered jwks/jwks_uri, or its client_secret for client_secret_jwt. It MUST reject the JWT unless aud identifies this AS, preferably by its issuer identifier (RFC 7523 §3 item 3; RFC 8725 §3.9). It MUST reject expired JWTs (item 4) and SHOULD track jti to stop replay (item 7).' Add `minItems: 1` to the array branch of aud wherever aud is required.  
   *Verifier: partially correct —* The gap stands; correct the suggested text. Client assertions: aud MUST be exactly the AS issuer identifier (rfc7523bis-11; the token endpoint URL is not allowed; reconcile with OIDC Core §9). Also iss = sub = client_id, keys come from the client's registered jwks/jwks_uri (or client_secret for client_secret_jwt), expired JWTs are rejected, and jti is single-use (OIDC Core §9 MUST). jwt-bearer grant: aud may be the issuer identifier or the token endpoint URL, and jti replay tracking is MAY (RFC 7523 §3 item 7). Change 'RECOMMENDED: nbf, iat, jti' at 1343 to OPTIONAL. Add minItems: 1 wherever aud is required.

4. **[MEDIUM] Gap: Entropy of HMAC keys (client_secret used for client_secret_jwt and for OIDC symmetric encryption)**  
   *Reference:* RFC 8725 §2.2, §3.5 (with RFC 7518 §3.2, §8.8)  
   client_secret_jwt is advertised (token_endpoint_auth_methods_supported, 2045), and ClientAuthFields.client_secret (1185-1190) exists. With client_secret_jwt the client_secret is the HMAC key for the client_assertion, and OIDC Core §10.2 also derives symmetric encryption keys from it. The YAML sets no strength requirement. §3.5 says human-memorizable passwords MUST NOT be used directly as HS256 keys, and RFC 7518 §3.2 requires an HMAC key at least as long as the hash output, i.e. at least 256 bits for HS256. An AS that issues short or human-chosen secrets enables the offline brute-force attack of §2.2.  
   *Suggested change:* Add to ClientAuthFields.client_secret.description: 'When used with client_secret_jwt (HS256/384/512) or for OIDC symmetric encryption, the AS-issued secret MUST be a random value with at least the hash size of entropy (at least 256 bits for HS256, RFC 7518 §3.2) and never a human-memorizable password (RFC 8725 §3.5).' Add a short pointer to this note in token_endpoint_auth_methods_supported.description next to client_secret_jwt.  
   *Verifier: confirmed.*

5. **[LOW] Gap: One algorithm per key in the published JWK Set (JWK.alg, JWK.kid)**  
   *Reference:* RFC 8725 §3.1, §2.1  
   §3.1 says 'each key MUST be used with exactly one algorithm, and this MUST be checked when the cryptographic operation is performed.' The JWK schema used for /jwks (1822-1902) has an optional alg ('Algorithm intended for use with the key', 1855-1858) and an optional kid (1859-1861), with no guidance. If the AS does not publish an alg for each key, verifiers of its ID Tokens, JWT access tokens and JWT introspection/UserInfo responses cannot enforce the binding, which leaves them open to the key-confusion attack in §2.1.  
   *Suggested change:* Extend JWK.alg.description with 'Keys published by the AS SHOULD carry alg; verifiers MUST use each key with exactly that one algorithm (RFC 8725 §3.1).' Extend JWK.kid.description with 'Unique within the set; a kid received in a JWS header is untrusted input (RFC 8725 §3.10).' Optionally make alg required in a JWKS-response subschema.  
   *Verifier: partially correct —* Recommend, without claiming a spec requirement, that AS-published JWKs carry alg so that verifiers can apply the key-to-algorithm binding in RFC 8725 §3.1 and rfc8725bis §3.1. Also document OIDC Discovery's rule that 'use' is REQUIRED on every key when the set mixes signing and encryption keys. Severity: low.

6. **[LOW] Gap: Guidance on encryption algorithms and compression for the *_encryption_alg/enc_values_supported arrays**  
   *Reference:* RFC 8725 §2.4, §3.2 (first bullet), §3.4, §3.6  
   The encryption metadata arrays give no guidance: introspection (2074-2079), id_token (2086-2091), userinfo (2097-2102) and request_object (2108-2113). The BCP says applications SHOULD avoid all RSA-PKCS1 v1.5 encryption (RSA1_5) and prefer RSAES-OAEP (§3.2), SHOULD NOT compress (JWE zip) before encrypting (§3.6), and must validate ECDH-ES epk inputs when they decrypt, e.g. ECDH-ES-encrypted request objects (§3.4). This BCP updates RFC 7519 §8, which still lists RSA1_5 as mandatory to implement.  
   *Suggested change:* Add to every *_encryption_alg_values_supported description: 'SHOULD NOT include RSA1_5 (RFC 8725 §3.2); prefer RSA-OAEP-256 or ECDH-ES(+A128KW/A256KW). Recipients MUST validate ECDH-ES epk points (§3.4).' Add to components.schemas.JWT.description: 'Producers SHOULD NOT set the JWE zip header (RFC 8725 §3.6).'  
   *Verifier: confirmed.*

7. **[LOW] Gap: Treating kid/jku/x5u and fetched key URLs as untrusted input**  
   *Reference:* RFC 8725 §2.9, §3.10  
   The YAML has key-related URL fields an AS might dereference. JWK.x5u (1862-1865) is one. Client jwks_uri is another: it is implied by registration_endpoint (1965-1968), even though client metadata is not modeled. There is no note that kid must be sanitized before database or LDAP lookups, or that jku/x5u/jwks_uri fetches SHOULD be restricted to an allowlist to prevent SSRF.  
   *Suggested change:* Add to the JWK.kid, JWK.x5u and registration_endpoint descriptions: 'Values received in JWS headers (kid, jku, x5u) or in client metadata (jwks_uri) are attacker-controllable. Sanitize kid before lookups, and only fetch allowlisted HTTPS URLs without cookies (RFC 8725 §3.10).'  
   *Verifier: confirmed.*

8. **[LOW] Gap: Citation of RFC 8725 in the spec**  
   *Reference:* RFC 8725 (whole document; Updates RFC 7519)  
   RFC 8725 is vendored but oauth-openapi.yaml mentions it nowhere: zero occurrences, and it is missing from the info.description 'Covered specifications' table (18-45). Yet the YAML models RFC 9068 and RFC 9701, which both cite it normatively. RFC 9101 §6.2 also says 'Algorithm verification MUST be performed, as specified in Sections 3.1 and 3.2 of [RFC8725]'. There is no references/rfc-validation file for it either.  
   *Suggested change:* Add '| RFC 8725 | 2020 | JWT Best Current Practices (BCP 225; updates RFC 7519) |' to the table after RFC 8707. Cite 'RFC 8725 §3.x' from components.schemas.JWT, the alg-array descriptions and bearerAuth. Create references/rfc-validation/8725-jwt-bcp.md.  
   *Verifier: confirmed.*

9. **[LOW] Gap: Description of local JWT validation**  
   *Reference:* RFC 8725 §3.1, §3.3, §3.8, §3.9, §3.11 (with RFC 9068 §4)  
   /introspect.description (323-324) says 'JWT tokens can usually be validated locally by verifying the signature against the JWKS', and bearerAuth (2643-2645) says JWT access tokens are 'validated locally against jwks_uri'. A learner will read both as 'a valid signature means a valid token'. The BCP and RFC 9068 §4 also require the alg to be on the allowlist, typ to be at+jwt, iss to match exactly with keys from that issuer's jwks_uri, aud to name this RS, exp to be checked, and every cryptographic layer to be validated.  
   *Suggested change:* Reword /introspect.description to '... JWT access tokens can instead be validated locally per RFC 9068 §4 and RFC 8725: typ at+jwt, an allowlisted alg, a signature checked with keys from the issuer's jwks_uri, an exact iss match, aud naming this resource, and exp/nbf.' Add the same checklist to bearerAuth.description.  
   *Verifier: confirmed.*

10. **[LOW] Gap: The YAML never says that JOSE headers and JWT Claims Sets must be UTF-8 JSON, or that other Unicode encodings must be refused** — *found by the verifier*  
   *Reference:* RFC 8725 §2.6, §3.7; draft-ietf-oauth-rfc8725bis-10 §3.7  
   The YAML never says that JOSE headers and JWT Claims Sets must be UTF-8 JSON, or that other Unicode encodings must be refused. This matters for every client-supplied JWT the AS parses: client_assertion, assertion, request, id_token_hint and DPoP. Neither RFC 8725 §3.7 nor rfc8725bis §3.7 is mentioned in the assessment.  
   *Suggested change:* Append to components.schemas.JWT.description: 'The JOSE Header and Claims Set are UTF-8 JSON; reject any other encoding (RFC 8725 §3.7).'

11. **[LOW] Gap: The YAML half-advertises a JWT kind the AS issues: JWT-secured authorization responses (JARM)** — *found by the verifier*  
   *Reference:* RFC 8725 §3.9, §3.12; draft-ietf-oauth-rfc8725bis-10 §3.12  
   The YAML half-advertises a JWT kind the AS issues: JWT-secured authorization responses (JARM). response_modes_supported lists the .jwt modes, but there is no payload schema and no authorization_signing_alg_values_supported or authorization_encryption_alg/enc_values_supported metadata. The ResponseMode parameter enum also excludes the .jwt modes. JARM JWTs carry iss=AS, aud=client_id and exp, which overlap ID Tokens, so the RFC 8725 §3.12 mutual-exclusivity and §3.9 audience rules apply. The assessment's JWT-kind catalogue omits this kind. The issue should go to the JARM/metadata owner.  
   *Suggested change:* Choose one option. (a) Remove the .jwt values from response_modes_supported. (b) Model JARM: add the three authorization_* metadata arrays (excluding 'none'), a JARM payload schema and the .jwt ResponseMode values, and list JARM responses in the JWT-kind catalogue.

12. **[LOW] Gap: The YAML does not mention the BCP's ECDSA nonce guidance for ES* signatures** — *found by the verifier*  
   *Reference:* RFC 8725 §3.2; draft-ietf-oauth-rfc8725bis-10 §3.2  
   The YAML does not mention the BCP's ECDSA nonce guidance for ES* signatures. This is implementation-level, but it matters for an AS that signs ID Tokens, JWT access tokens and introspection/UserInfo JWTs with ES256/384/512.  
   *Suggested change:* Add to the id_token_/introspection_/userinfo_ signing-alg descriptions or to JWK.alg: 'ES* signatures produced by the AS SHOULD use deterministic ECDSA (RFC 6979) or a library that guarantees unique nonces (RFC 8725 §3.2).'

## draft-ietf-oauth-rfc8725bis-10 JSON Web Token Best Current Practices (draft-ietf-oauth-rfc8725bis)

*August 2026 · Internet-Draft -10 dated 21 Aug 2026; intended BCP; obsoletes RFC 8725 and updates RFC 7519 if approved. IESG-approved and in the RFC Editor queue since 2026-08-25, but 'Blocked' on its normative reference draft-ietf-jose-deprecate-none-rsa15 (at -06, IESG 'Waiting for AD Go-Ahead' as of 2026-10-09). · YAML coverage: **partial** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** This draft is the second edition of the JWT BCP. Once published it will obsolete RFC 8725 and again update RFC 7519, keeping all of RFC 8725's guidance. It adds attacks found since 2020, each with a mitigation: case-insensitive 'noNE' blocklist bypasses (use case-sensitive allowlists), JWEs accepted as if they were signed (CVE-2023-51774), PBES2 iteration-count and JWE decompression-bomb denial of service, and JWS JSON-vs-Compact confusion (new MUST: a JWT may contain only base64url characters and '.'). It also hardens existing rules. 'none' becomes MUST NOT unless the caller explicitly opts in; 'none' and RSA1_5 are deprecated; fully specified algorithm names (RFC 9864) are preferred. kid sanitization becomes a MUST, and an AS without an allowlist MUST refuse to fetch URLs such as jwks_uri that resolve to loopback or local addresses. Explicit typing gets precise rules: typ 'JWT' is not explicit typing, and a typ without '/' is read as if 'application/' were prepended.

**Why it was created.** Between 2020 and 2026 new JWT attacks and CVEs appeared that RFC 8725 did not cover: JWE/JWS confusion (CVE-2023-51774), 'noNE' case-folding bypasses, PBES2 p2c and zip-bomb denial of service, and JSON-serialization confusion. In parallel, the JOSE WG moved to deprecate 'none' and RSA1_5 (draft-ietf-jose-deprecate-none-rsa15) and to fully specify algorithms (RFC 9864). The original authors (Yaron Sheffer, Dick Hardt, Michael B. Jones) started draft-sheffer-oauth-rfc8725bis-00 as a verbatim copy of RFC 8725 and added these mitigations. The OAuth WG then adopted it.

<details><summary>Already modeled in the YAML (5)</summary>

- §3.14 JWT format check: components.schemas.JWT.pattern (2440) allows only letters, digits, '-', '_' and '.' in 3 or 5 segments, so JSON-serialized JWS/JWE bodies are rejected. This applies only to the three JWT response bodies (348, 505, 555).
- §3.9 (aud required even if the issuer 'may' serve several RPs in future): aud is required in IDTokenClaims (2467), JWTAccessTokenClaims (2521), JWTIntrospectionResponse (1771) and UserInfoSignedResponse (2419)
- §3.11 typ values without the 'application/' prefix: at+jwt (2517, 2644), dpop+jwt (980, 2655), token-introspection+jwt (352-353, 1766-1767)
- §3.2 'none': resource_signing_alg_values_supported says 'none MUST NOT be used' (2308); the JWT.pattern requires a non-empty signature (2440)
- §3.8 issuer: OAuthServerMetadata.issuer must be byte-identical to iss (1947-1950); IDTokenClaims.iss (2472)

</details>

**Follow-up on the May-2026 validation notes.** No prior validation notes: the draft is not vendored and has never been audited.

**Notes.** Changes from RFC 8725 (Appendix A of the draft):
1. defensive, case-sensitive alg checks
2. encryption-vs-signature confusion
3. limits on p2c
4. JWT format confusion
5. compression denial of service
6. expanded explicit typing
7. kid/jku/x5u SSRF, with a DNS-resolution check
8. normative deprecation of 'none' and RSA1_5

Other tightenings: aud is required if an issuer 'may' serve several RPs 'in the future', and kid sanitization moves from should to MUST. §1 says the draft updates RFC 7519 by 'restricting how Unsecured JWTs (alg value "none") are used'.

The YAML already meets the new §3.14 for its own JWT responses.

Status was checked on 2026-10-10. The RFC Editor queue XML shows the entry received 2026-08-25, assignment 'blocked', and normRef draft-ietf-jose-deprecate-none-rsa15 as NOT-RECEIVED. The datatracker API shows that draft at rev 06 (2026-10-09) with IESG state 'Waiting for AD Go-Ahead' and IANA state 'Not OK'.

### Findings (0 high · 4 medium · 6 low)

1. **[MEDIUM] Gap: Telling Unsecured, JWS, JWE and Nested JWTs apart by context**  
   *Reference:* draft-ietf-oauth-rfc8725bis-10 §2.3, §3.3  
   The new text in §3.3 says libraries MUST let recipients distinguish Unsecured JWTs, JWSs, JWEs and Nested JWTs, because authentication requires signed JWTs. §2.3 cites CVE-2023-51774, where a successfully decrypted JWE was accepted as if its signature had been verified. The YAML's single JWT schema treats 3-segment and 5-segment forms as interchangeable. Nothing says that a 5-segment client_assertion, assertion or request object is acceptable only as a Nested JWT whose inner JWS validates, or that successful decryption is not authentication.  
   *Suggested change:* Add to components.schemas.JWT.description and to the client_assertion, assertion and request descriptions: 'A JWE is acceptable only as a Nested JWT whose inner JWS signature is validated with the sender's key. Successful decryption alone MUST NOT be treated as authentication (rfc8725bis §3.3).' Use the JWS-only schema where the profile allows no encryption (DPoP proofs, signed_metadata).  
   *Verifier: partially correct —* Require a validated JWS (the inner JWS when nested) for client_assertion, assertion and RFC 9101 Request Objects. Note that OIDC Core §6.1 also permits encrypt-only and unsigned Request Objects, which an AS can refuse via require_signed_request_object (RFC 9101 §10.5). Cite bis §3.3 as 'libraries MUST let recipients distinguish the four forms', not as a MUST NOT on decryption.

2. **[MEDIUM] Gap: 'none' is MUST NOT unless explicitly allowed; RSA1_5 deprecated; allowlists compared case-sensitively**  
   *Reference:* draft-ietf-oauth-rfc8725bis-10 §2.11, §3.1, §3.2 (normative reference draft-ietf-jose-deprecate-none-rsa15)  
   The draft makes five changes here. RFC 8725's SHOULD NOT on generating or consuming 'none' becomes MUST NOT unless the caller explicitly allows it. 'none' and RSA-PKCS1 v1.5 encryption are declared deprecated. Allowlists are required instead of blocklists, because of case-folding bypasses such as 'noNE' (§2.11). The alg/enc header must match the algorithm bound to the key found through kid. Recipients MUST check per-issuer allowed algorithms. None of this is reflected on the YAML's algorithm metadata arrays (2050-2113, 2188-2190, 2246-2248, 2326-2328) or on JWK.alg (1855-1858).  
   *Suggested change:* Implement the JWSAlgorithm and JWSAlgorithmNotNone schemas proposed in the RFC 8725 entry, described as 'case-sensitive allowlist entries'. Add 'RSA1_5 is deprecated (rfc8725bis §3.2); do not advertise it' to the descriptions at 2074, 2086, 2097 and 2108. Add to JWK.alg: 'verifiers MUST check that the JWS alg equals the alg bound to the key selected by kid (rfc8725bis §3.1).'  
   *Verifier: partially correct —* This is the same gap as RFC 8725 gap 1, plus the new bis MUSTs on per-issuer algorithm sets and kid/alg consistency. Describe allowlists as recommended (lowercase 'should'), RSA1_5 avoidance as a SHOULD, and 'none' as refused unless the AS explicitly opts in.

3. **[MEDIUM] Gap: SSRF and kid-injection protections for URLs the AS fetches (jwks_uri, jku, x5u)**  
   *Reference:* draft-ietf-oauth-rfc8725bis-10 §3.10  
   New normative text: kid lookups MUST be protected against SQL and LDAP injection, and applications SHOULD allowlist jku/x5u URLs. 'When such an allowlist is not available, the authorization server MUST check what a hostname resolves to and avoid making a request if it resolves to a loopback or local IP address.' The draft's own example is an attacker-supplied jwks_uri. The YAML advertises registration_endpoint (1965-1968), which implies accepting a client jwks_uri. It also models JWK.x5u (1862-1865) and client_assertion/request inputs whose JOSE headers may carry jku, x5u or kid. None of these carries such guidance. RFC 9101 client-hosted request_uri fetching is deliberately not modeled (864-865).  
   *Suggested change:* Add to the registration_endpoint, JWK.x5u and JWK.kid descriptions, or as a security bullet in info.description: 'kid, jku, x5u and client-supplied jwks_uri values are attacker-controlled. Sanitize kid. Fetch only allowlisted HTTPS URLs; if there is no allowlist, resolve the host first and refuse loopback, link-local and private addresses. Send no cookies (rfc8725bis §3.10).'  
   *Verifier: confirmed.*

4. **[MEDIUM] Incorrect: 2538-2540 components.schemas.JWTAccessTokenClaims.properties.sub.description**  
   *Reference:* draft-ietf-oauth-rfc8725bis-10 §3.8 (via RFC 9700 §4.15-§4.15.1); RFC 9068 §2.2, §5  
   The description says that for the client_credentials grant, sub 'MUST equal client_id'. RFC 9068 §2.2 only says that sub SHOULD correspond to an identifier the AS uses for the client application. That is a SHOULD, and the identifier need not be the client_id. rfc8725bis §3.8 (subject validation) points to RFC 9700 §4.15: if client IDs and user sub values share a namespace, a client that can choose its client_id can impersonate a resource owner. RFC 9700 §4.15.1 says the AS SHOULD NOT let clients influence such values, and where that cannot be avoided it MUST give resource servers another way to tell the two token types apart. Requiring sub=client_id builds in exactly that collision risk and overstates RFC 9068.  
   *Suggested change:* Replace the description with: 'REQUIRED. For grants that involve a resource owner, the resource owner's subject identifier. For grants without one (e.g. client_credentials), an identifier the AS uses for the client application (RFC 9068 §2.2), which SHOULD NOT collide with any user subject. If client IDs and user identifiers share a namespace, the AS MUST give resource servers another way to recognize client-only tokens (RFC 9700 §4.15.1; rfc8725bis §3.8).'  
   *Verifier: confirmed.*

5. **[LOW] Gap: Compact-format check (and JWS-only where required) on JWTs the AS receives**  
   *Reference:* draft-ietf-oauth-rfc8725bis-10 §2.13, §3.14  
   §3.14 says: 'Implementations MUST confirm the JWT is in a legal format while parsing it ... Content with any other characters ... MUST be rejected.' The YAML applies its compliant pattern only to JWT responses the AS emits. The JWT inputs the AS parses are unconstrained strings: client_assertion (1191-1196), assertion (1338-1345), Request and PARRequest.request (950-960, 1642-1644), IDTokenHint and PARRequest.id_token_hint (929-937, 1627-1628), and the DPoP header (972-984). A validator generated from the YAML would therefore pass a JSON-serialized JWS straight to the JWT library, which is the §2.13 attack.  
   *Suggested change:* After the RFC 7519 pattern fix, change those inputs to `$ref: '#/components/schemas/JWT'`. For the DPoP header, add components.schemas.JWS with `pattern: '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$'`, because DPoP proofs are always JWS (RFC 9449 §4.2), and use it there.  
   *Verifier: partially correct —* Use $ref JWT (signature required) for client_assertion and assertion, and a JWS-only schema for DPoP. For request and id_token_hint, use a bis §3.14 character-set check that also admits Unsecured JWTs (the tested pattern in the RFC 7519 verdict), or document a profile without 'none'. Severity: low, because this is defense in depth; §3.14 binds parsers.

6. **[LOW] Gap: Explicit-typing processing rules (typ prefix handling; typ 'JWT' is not explicit typing)**  
   *Reference:* draft-ietf-oauth-rfc8725bis-10 §3.11  
   The draft says recipients 'MUST treat a typ value with no "/" as if "application/" were prepended'. So 'at+jwt' and 'application/at+jwt' are equivalent, which matches RFC 9068 §4. It also says typ 'JWT', as in the components.schemas.JWT example header at 2441, is not effective explicit typing, and that new JWT kinds SHOULD register an application/&lt;kind>+jwt media type. The YAML states each typ as a single literal (2517, 2644, 980, 2655, 352, 1766) and mentions neither the equivalence nor that media types compare case-insensitively.  
   *Suggested change:* In bearerAuth, DPoPHeader and the /introspect description, state the expected typ as 'at+jwt (equivalently application/at+jwt; compared case-insensitively as a media type)', and likewise for the others. Add to components.schemas.JWT.description: 'typ JWT does not provide explicit typing (rfc8725bis §3.11).'  
   *Verifier: partially correct —* Document the prefix equivalence for recipients (RFC 7515 §4.1.9; bis §3.11) and RFC 9068 §4's two accepted at+jwt values. Tell producers to emit the short typ values exactly as RFC 9449 §4.2 and RFC 9701 §5 specify, because RFC 9449 §4.3 checks the literal 'dpop+jwt'.

7. **[LOW] Gap: PBES2 p2c cap, JWE decompression limit and no compression**  
   *Reference:* draft-ietf-oauth-rfc8725bis-10 §2.10, §2.12, §3.6, §3.13, §3.15  
   If the AS accepts encrypted request objects (request_object_encryption_alg/enc_values_supported, 2108-2113), it decrypts JWEs chosen by an attacker. The draft RECOMMENDS rejecting a PBES2 p2c above 1,200,000 and capping decompressed size (deployed libraries use about 250 KB). It also says compression SHOULD NOT be used when creating a JWE. The YAML says nothing about any of this.  
   *Suggested change:* Add to request_object_encryption_alg_values_supported.description: 'Avoid PBES2-* algorithms. If they are accepted, reject p2c > 1,200,000 (rfc8725bis §3.13) and cap the decompressed size of a JWE (§3.15).'  
   *Verifier: confirmed.*

8. **[LOW] Gap: Fully specified algorithm identifiers (RFC 9864)**  
   *Reference:* draft-ietf-oauth-rfc8725bis-10 §3.2  
   New deployments SHOULD prefer fully specified identifiers such as 'Ed25519' over the polymorphic 'EdDSA', which RFC 9864 (Oct 2025) deprecates. The YAML examples still use EdDSA: in the JWK.alg examples (1858) and in the WWWAuthenticateBearerDPoP example 'DPoP algs="ES256 EdDSA"' (1023).  
   *Suggested change:* Replace EdDSA with Ed25519 in both examples. If EdDSA is kept as a legacy example, mark it '(polymorphic; deprecated by RFC 9864)'.  
   *Verifier: confirmed.*

9. **[LOW] Gap: Tracking the pending BCP in the repo**  
   *Reference:* draft-ietf-oauth-rfc8725bis-10 §1, Appendix A  
   The repo neither vendors nor references this draft. Once published it will obsolete the vendored RFC 8725, and Appendix A lists eight substantive changes that a new AS implementation should follow now.  
   *Suggested change:* Vendor references/rfc-sources/draft-ietf-oauth-rfc8725bis.txt (revision -10), handled like draft-ietf-oauth-v2-1.txt. List it in the README index as 'pending RFC; obsoletes 8725', and replace it with the RFC text once published.  
   *Verifier: confirmed.*

10. **[LOW] Gap: The new rule that recipients MUST check that the algorithms used by encrypted JWTs are among those they support is not reflected anywhere** — *found by the verifier*  
   *Reference:* draft-ietf-oauth-rfc8725bis-10 §3.1  
   The new rule that recipients MUST check that the algorithms used by encrypted JWTs are among those they support is not reflected anywhere. The AS advertises request_object_encryption_alg/enc_values_supported but never says it rejects Request Objects encrypted with any other alg/enc. The assessment's bis 'none'/allowlist gap covers only signing algorithms.  
   *Suggested change:* Add to request_object_encryption_alg_values_supported and request_object_encryption_enc_values_supported: 'The AS MUST reject encrypted Request Objects whose alg/enc are not listed here (rfc8725bis §3.1).'

## Verifier corrections to the summaries above

- RFC 7519 summary: 'cty:"JWT" marks a Nested, signed-then-encrypted JWT' is inaccurate. Under §5.2, cty 'JWT' marks any Nested JWT, whatever the nesting order. Sign-then-encrypt is only the normal practice in RFC 7519 §11.2 ('normally producers should sign ... and then encrypt'). It is a MUST only in profiles such as OIDC Core §2/§5.3.2/§6.1 and RFC 9101 §4.
- RFC 7519 summary: RFC 7519 does not 'register' the StringOrURI and NumericDate value types; it defines them in §2 (Terminology). Its IANA registrations are the seven claims (§10.1), urn:ietf:params:oauth:token-type:jwt (§10.2), application/jwt (§10.3) and the iss/sub/aud header parameters (§10.4).
- RFC 7519 status/notes, errata completeness (rfc-editor.org/errata/rfc7519 re-fetched today): besides verified 8060 (Technical, reported 2024-07-31, verified 2025-04-03) and 8388 (Editorial, verified 2025-06-27), and the reported 5906, two more Technical errata remain in 'Reported' state. 7720 (2023-12-01, §4.1.6) asks that JWTs whose iat is in the future MUST NOT be rejected; this is relevant when the AS validates iat on client assertions and DPoP proofs. 8225 (2024-12-31) concerns §7.2. Errata 5648, 6622 and 9212 were rejected.
- RFC 7519 notes: 'In this cluster only cty ... is absent' from the YAML contradicts the RFC 7797 entry. b64 (RFC 7797; on the IANA absence list) and crit (RFC 7515/7516, required with b64 by RFC 7797 §6) are also absent.
- RFC 7797 why_created: the examples '(for example HTTP message or payment signing)' do not appear in RFC 7797. §1 motivates the option only by payloads that are 'large and/or detached'. The phrase 'so a b64:false object can never be parsed as an ordinary JWT' conflates two rules. The JWT exclusion is §7 ('For interoperability reasons'). Rejection by implementations that do not support b64 comes from the crit requirement in §6.
- RFC 8725 notes: 'RFC 9101 §6.2 ... apply it informatively' needs nuance. RFC 9101 lists RFC 8725 under Informative References (§12.2), yet §6.2 states normatively that 'Algorithm verification MUST be performed, as specified in Sections 3.1 and 3.2 of [RFC8725]'. RFC 9449 cites it informatively in §4.2, which is correct.
- RFC 8725 gap 1 detail: RFC 8414 (June 2018) is not one of 'the specs that build on RFC 8725'; it predates RFC 8725 and does not cite it.
- Cluster note (d) conflates two rfc7523bis-11 changes. For the jwt-bearer authorization grant (JWTBearerTokenRequest.assertion, line 1342), rfc7523bis-11 §4 still allows either the issuer identifier or the token endpoint URL. The 'issuer identifier as sole aud, token endpoint URL MUST NOT be used' rule and the typ client-authentication+jwt (SHOULD; servers are NOT RECOMMENDED to reject untyped JWTs) apply to client-authentication JWTs (ClientAuthFields.client_assertion, 1191-1196). That field currently has no aud guidance, and OIDC Core §9 still says the audience 'SHOULD be the URL of the Authorization Server's Token Endpoint'. rfc7523bis-11 also updates RFC 9126 (header: 'Updates: 7521, 7522, 7523, 9126').
- Cluster headline 'aud is REQUIRED in every JWT kind the AS issues' is overstated. It holds for the four payload schemas (IDTokenClaims, JWTAccessTokenClaims, JWTIntrospectionResponse, UserInfoSignedResponse). However, JARM response JWTs (advertised via response_modes_supported at 2031) have no schema, and signed_metadata JWTs (2262-2267; RFC 8414 §2.1) carry no aud requirement.
- The assessment is internally inconsistent on 'none'. RFC 7519 gap 3 and rfc8725bis gap 1 propose $ref JWT (which rejects Unsecured JWTs) for TokenResponse.id_token, id_token_hint and request. RFC 8725 gap 1, however, keeps 'none' allowed where OIDC or RFC 9101 permit it (OIDC Core §2 and §6.1; OIDC Discovery 'Servers SHOULD support none and RS256' for request objects; OIDC Registration request_object_signing_alg 'The value none MAY be used'). The repo needs one explicit 'none' policy for its OAuth 2.1 profile, documented as a deviation where it is stricter than OIDC.
