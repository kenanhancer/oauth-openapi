# JOSE core — RFC 7515, 7516, 7517, 7518, 7638, 8037, 9864, 9964, 8812, 7520

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC7515](#rfc7515-json-web-signature-jws) | May 2015 | Proposed Standard | partial | 0 | 2 | 5 |
| [RFC7516](#rfc7516-json-web-encryption-jwe) | May 2015 | Proposed Standard | partial | 0 | 1 | 4 |
| [RFC7517](#rfc7517-json-web-key-jwk) | May 2015 | Proposed Standard | mostly | 1 | 2 | 10 |
| [RFC7518](#rfc7518-json-web-algorithms-jwa) | May 2015 | Proposed Standard (updated by RFC 9864) | partial | 1 | 4 | 4 |
| [RFC7638](#rfc7638-json-web-key-jwk-thumbprint) | September 2015 | Proposed Standard | partial (verifier corrected from mostly) | 0 | 0 | 2 |
| [RFC8037](#rfc8037-cfrg-elliptic-curve-diffie-hellman-ecdh-and-signatures-in-json-object-signing-and-encryption-jose) | January 2017 | Proposed Standard (updated by RFC 9864) | mostly | 0 | 0 | 1 |
| [RFC9864](#rfc9864-fully-specified-algorithms-for-json-object-signing-and-encryption-jose-and-cbor-object-signing-and-encryption-cose) | October 2025 | Proposed Standard (updates RFC 7518, RFC 8037, RFC 9053) | none | 0 | 0 | 3 |
| [RFC9964](#rfc9964-ml-dsa-for-json-object-signing-and-encryption-jose-and-cbor-object-signing-and-encryption-cose) | May 2026 | Proposed Standard | none | 0 | 0 | 2 |
| [RFC8812](#rfc8812-cbor-object-signing-and-encryption-cose-and-json-object-signing-and-encryption-jose-registrations-for-web-authentication-webauthn-algorithms) | August 2020 | Proposed Standard | partial | 0 | 0 | 1 |
| [RFC7520](#rfc7520-examples-of-protecting-content-using-json-object-signing-and-encryption-jose) | May 2015 | Informational | not-applicable | 0 | 0 | 1 |

**Cluster notes.** JOSE is the cryptographic layer under every JWT this authorization server issues or accepts. The YAML models it in five places: GET /jwks (application/jwk-set+json), components.schemas.JWKS and JWK, the components.schemas.JWT compact-serialization pattern, DPoP thumbprints (cnf.jkt and dpop_jkt), and about 16 *_alg_values_supported arrays. RFC 7517 is the only JOSE RFC that is vendored or listed in the 'Covered specifications' table (lines 17-45). RFC 7515 and RFC 7516 are never cited. RFC 7518, 7638 and 8037 are cited but not vendored. *(Update 2026-10-11: RFC 7515, 7516, 7518, 7638, 8037 and 9864 are now vendored.)*

Top findings, verified against the RFC text and the IANA registries downloaded on 2026-10-10:
(1) HIGH: the schema for the public, unauthenticated JWK Set documents the symmetric-key member k (1899-1902) and lists HS256 among the alg examples (1858). Because additionalProperties is true (1825), it also accepts private-key members. This contradicts RFC 7517 §9.2 and OIDC Discovery §3 ('The JWK Set MUST NOT contain private or symmetric key values').
(2) HIGH: only resource_signing_alg_values_supported (2308) forbids 'none'. Client-authentication, introspection, DPoP and JWT access-token algorithms carry no none/MAC prohibition, although RFC 7518 §3.6, RFC 8414 §2, RFC 9449 §4.2 and RFC 9068 §2.1 require one.
(3) MEDIUM: the components.schemas.JWT pattern (2440) rejects valid compact JWEs whose Encrypted Key part is empty (alg=dir or ECDH-ES). I tested this against RFC 7520 Figures 128 and 136.
(4) MEDIUM: the examples use the deprecated polymorphic identifier EdDSA (1858, 1023), and the RFC 9864 identifiers Ed25519/Ed448 never appear as alg values.
(5) MEDIUM: there is no JOSE header documentation (alg/kid/typ/crit), no kid, rotation or 'use REQUIRED' guidance for /jwks, and the members each key type requires are not enforced.
(6) MEDIUM: the JARM *.jwt response modes are advertised (2031), but the JARM signing and encryption metadata is missing, and the /authorize ResponseMode enum (855) does not include those modes.
(7) LOW: JWK.use and JWK.key_ops use closed enums, but RFC 7517 §4.2 and §4.3 say 'Other values MAY be used'.

Follow-up on the May-2026 RFC 7517 audit: of its 18 MISSING/WRONG items, 11 are fixed, 1 is partly fixed and 6 are still open. Two of the fixes went too far: adding k to the public schema, and closing the enums.

Status of related work on 2026-10-10:
- draft-ietf-jose-deprecate-none-rsa15-06 (IESG, 'Waiting for AD Go-Ahead') would update RFC 7518 to mark 'none' and 'RSA1_5' Deprecated, and says new specifications MUST NOT allow either.
- draft-ietf-jose-hpke-encrypt-22 is in the RFC Editor queue. IANA already lists the HPKE-0..7 and HPKE-*-KE algorithms and the ek/psk_id header parameters (registered 2026-09-29).
- draft-ietf-oauth-rfc8725bis-10 (RFC Editor queue, 'Blocked') tells new deployments to prefer Ed25519 over EdDSA and deprecates RSA1_5 encryption.
- Other active JOSE drafts: pq-composite-sigs-05, pqc-kem-06 and the JSON Web Proof family.
- JOSE-WG RFCs outside this cluster: RFC 7165 (use cases, Informational, no wire surface) and RFC 7797 (JWS b64 option, updates RFC 7519, not used by OAuth endpoints).

False positives in the IANA diff:
- alg values Ed25519 and Ed448 appear only as crv names (1892).
- The JWK member 'd' matched only the word "MAC'd" (1344).
- 'none' matched only prompt=none and the auth-method value none.

Small citation errors that belong to other clusters:
- WWWAuthenticateBearerDPoP cites RFC 9449 §5 for the DPoP 'algs' parameter (1011). It is defined in §7.1.
- DPoPJKT cites RFC 9449 §10.1 (968). The dpop_jkt parameter is defined in §10; §10.1 covers its use with PAR.
- IANA's AS-metadata registry has no entries for JARM's authorization_*_values_supported. Only the JARM client metadata was registered (Aug 2026, citing oauth-v2-jarm-errata1).

## RFC7515 JSON Web Signature (JWS)

*May 2015 · Proposed Standard · YAML coverage: **partial** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** JWS defines how to protect arbitrary content with a digital signature or MAC, using a JSON header and base64url encoding. Its Compact Serialization (header.payload.signature) is the wire format of every signed JWT an OAuth/OIDC server issues or consumes: ID tokens, JWT access tokens, client assertions, request objects, DPoP proofs, and signed UserInfo or introspection responses. It also defines the JOSE Header parameters (alg, kid, typ, cty, crit, jwk, jku, x5u/x5c/x5t/x5t#S256) and the validation rules, for example that alg MUST be present and crit MUST be understood.

**Why it was created.** Web protocols needed an integrity format that is compact, URL-safe and JSON-native, unlike XML DSig or CMS, so that signed objects can travel through untrusted browsers in headers, query strings and form posts without being tampered with or forged. The JOSE WG standardized it in 2011-2015 as the base for JWT, which OAuth assertions and OpenID Connect ID tokens rely on.

<details><summary>Already modeled in the YAML (8)</summary>

- JWS Compact Serialization header.payload.signature (§3.1, §7.1): components.schemas.JWT pattern/description, lines 2434-2441 (base64url without padding, consistent with §2)
- Signed-JWT HTTP bodies via $ref JWT: /introspect application/token-introspection+jwt (346-355); /userinfo GET/POST application/jwt (503-511, 553-561)
- 'typ' explicit typing per §4.1.9 (application/ prefix omitted): at+jwt (2517, 2644), dpop+jwt (980, 2655), token-introspection+jwt (352-353, 1766-1767)
- 'alg' and 'jwk' header parameters named as required in DPoP proofs: components.parameters.DPoPHeader (972-984)
- JWS alg negotiation arrays: token/revocation/introspection endpoint auth (2050-2068), introspection_signing (2071-2073), id_token_signing (2082-2085), userinfo_signing (2094-2096), request_object_signing (2105-2107), dpop_signing (2188-2190, 2326-2328), backchannel_authentication_request_signing (2246-2248), resource_signing (2305-2308)
- DPoP WWW-Authenticate 'algs' list of JWS alg values: components.headers.WWWAuthenticateBearerDPoP (1010-1011, examples 1022-1023)
- JWS-carrying string fields: id_token (1443-1448), client_assertion (1191-1196), assertion (1338-1345), request (950-960, 1642-1644), signed_metadata (2262-2267, 2333-2338)
- x5t#S256 name (§4.1.8 semantics) reused in JWK (1877-1879) and cnf (2584-2586)

</details>

**Follow-up on the May-2026 validation notes.** There is no per-RFC validation note for RFC 7515. The May-2026 audit did not cover it.

**Notes.** The JWS JSON Serialization (§7.2), the application/jose and application/jose+json media types (§9.2) and detached content (Appendix F) are not used by OAuth/OIDC endpoints, so their absence is correct. The IANA-absent header parameters attributed to RFC 7515 (jku, cty, crit) are expected, because no JOSE-header schema exists. If one is added, document that jku and x5u in incoming JWTs must not be dereferenced to obtain trust keys: use only the registered jwks/jwks_uri (RFC 8725 §3.10). The 'algs' auth-param holds RFC 7515 §4.1.1 alg values and is defined in RFC 9449 §7.1, not §5 as cited at line 1011.

### Findings (0 high · 2 medium · 5 low)

1. **[MEDIUM] Gap: JOSE Header documentation (alg, kid, typ, cty, crit, jwk/jku/x5*) and key identification**  
   *Reference:* RFC 7515 §4.1.1, §4.1.4, §4.1.9, §4.1.11, §6 (+ OIDC Core §10.1)  
   The YAML documents decoded payloads (IDTokenClaims 2461, JWTAccessTokenClaims 2514, JWTIntrospectionResponse 1763, UserInfoSignedResponse 2409) but never the header that every JWS carries. Missing points: 'alg' MUST be present and understood (§4.1.1); 'crit' MUST be understood, and a JWS listing an unknown extension is invalid (§4.1.11); the producer SHOULD identify the signing key (§6), and OIDC Core §10.1 makes 'kid' a MUST when the JWK Set holds more than one key. The /jwks description (577-582) never says that tokens carry a kid matching a JWK. typ values are given only for at+jwt, dpop+jwt and token-introspection+jwt. None are given for ID tokens, client assertions, request objects (oauth-authz-req+jwt, RFC 9101 §10.8) or JARM responses.  
   *Suggested change:* Add a documentation-only components.schemas.JOSEHeader with required: [alg] and these properties: alg ('MUST be one of the matching *_alg_values_supported; never none for tokens the AS issues or accepts'), kid ('matches a JWK kid in /jwks; MUST be present when /jwks holds more than one key'), typ (examples [JWT, at+jwt, dpop+jwt, token-introspection+jwt, oauth-authz-req+jwt]), cty (examples [JWT] for Nested JWTs), crit (array, minItems: 1), jwk ($ref public JWK), enc ('JWE only'). Reference it from the descriptions of IDTokenClaims, JWTAccessTokenClaims, JWTIntrospectionResponse, UserInfoSignedResponse, DPoPHeader and GET /jwks.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: JARM signed authorization responses: authorization_signing_alg_values_supported and the 'response' JWT parameter**  
   *Reference:* RFC 7515 §7.1 as profiled by OIDF JARM §4.1-§4.3 and §6 (2018 draft vendored; §4 in the final spec)  
   response_modes_supported (2027-2032) advertises jwt, query.jwt, fragment.jwt and form_post.jwt. However, OAuthServerMetadata has no authorization_signing_alg_values_supported (JARM: AS SHOULD publish; client-registered alg 'none' is not allowed), and the /authorize 302/303 descriptions (159-191) never mention the 'response' parameter that carries the JWS. In addition, the /authorize ResponseMode parameter enum (846-855) is limited to [query, fragment, form_post], so clients cannot request the modes the AS advertises.  
   *Suggested change:* Add authorization_signing_alg_values_supported: {type: array, items: {type: string, not: {const: none}}, description: 'JWS algs used to sign JARM responses (JARM §6/final §4)'}. Extend the ResponseMode enum with jwt, query.jwt, fragment.jwt and form_post.jwt. Document 'response=&lt;JWT>' in the authorization-response descriptions.  
   *Verifier: confirmed.*

3. **[LOW] Gap: JWS-carrying parameters typed as bare strings**  
   *Reference:* RFC 7515 §7.1  
   id_token (1443-1448), client_assertion (1191-1196), assertion (1338-1345), request (950-960, 1642-1644), the DPoP header (972-984) and signed_metadata (2262-2267, 2333-2338) are plain 'type: string' without the compact-serialization pattern, so malformed values validate. Only the /introspect and /userinfo JWT bodies use $ref JWT (348, 505, 555).  
   *Suggested change:* Add a JWS-only schema SignedJWT with pattern '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$' and use it for client_assertion, assertion, DPoP and signed_metadata. Use $ref JWT (JWS or JWE) for id_token and request.  
   *Verifier: partially correct —* Bare-string typing is a real low-severity gap, and it also covers id_token_hint. Only DPoP proofs (RFC 9449 §4.2, JWS-signed) and signed_metadata (RFC 8414 §2.1 / RFC 9728 §2.2, signed or MACed with JWS) should get a JWS-only pattern. assertion, client_assertion, id_token, id_token_hint and request should use a corrected JWS-or-JWE JWT schema.

4. **[LOW] Gap: Normative JOSE references missing from the spec**  
   *Reference:* RFC 7515 (whole document)  
   The info.description 'Covered specifications' table (17-45) lists only RFC 7517 among the JOSE RFCs. components.schemas.JWT (2437) attributes the compact serialization only to RFC 7519 §3. Learners are never pointed to the normative JWS, JWE and JWA rules.  
   *Suggested change:* Add table rows for RFC 7515 (JWS), RFC 7516 (JWE), RFC 7518 (JWA, updated by RFC 9864), RFC 7638, RFC 8037 and RFC 9864. Cite RFC 7515 §7.1 and RFC 7516 §7.1 in components.schemas.JWT.description.  
   *Verifier: confirmed.*

5. **[LOW] Incorrect: The AS signed_metadata description says the JWT is 'signed by the AS' and cites RFC 8414 §3.1 for precedence** — *found by the verifier*  
   *Reference:* RFC 7515 §7.1 as profiled by RFC 8414 §2.1  
   The AS signed_metadata description says the JWT is 'signed by the AS' and cites RFC 8414 §3.1 for precedence. RFC 8414 §2.1 allows a JWS signature or MAC by the attesting party named in a REQUIRED iss claim, which may differ from the AS. The precedence rule is in §2.1; §3.1 is the metadata request. The mandatory iss claim is omitted here, although the PRM variant (2336-2338) states it.  
   *Suggested change:* Reword as: 'JWT signed or MACed with JWS (RFC 8414 §2.1). It MUST contain iss naming the attesting party. When the consumer supports signed metadata, its values MUST take precedence (RFC 8414 §2.1).' Apply the SignedJWT pattern.

6. **[LOW] Incorrect: JWTAccessTokenClaims says JWT access tokens are 'advertised via signing alg arrays in discovery'** — *found by the verifier*  
   *Reference:* RFC 7515 §4.1.1 as profiled by RFC 9068 §2.1, §4  
   JWTAccessTokenClaims says JWT access tokens are 'advertised via signing alg arrays in discovery'. No registered AS metadata advertises JWT access-token signing algorithms; RFC 9068 publishes only the keys (jwks_uri) and the issuer.  
   *Suggested change:* Replace with: 'JWT access tokens are verified with keys from jwks_uri (RFC 9068 §4). RS256 MUST be supported and none MUST NOT be used (RFC 9068 §2.1). No metadata member advertises the access-token alg.'

7. **[LOW] Gap: DPoPHeader documents the alg and jwk header parameters but not that jwk must be a public key, nor that alg must be an asymmetric algorithm (not none, not MAC)** — *found by the verifier*  
   *Reference:* RFC 7515 §4.1.1, §4.1.3 as profiled by RFC 9449 §4.2, §4.3  
   DPoPHeader documents the alg and jwk header parameters but not that jwk must be a public key, nor that alg must be an asymmetric algorithm (not none, not MAC). The agent covers cnf.jwk and the dpop_signing_alg arrays, not the proof-header documentation itself.  
   *Suggested change:* Extend the DPoPHeader description: alg is an asymmetric JWS alg listed in dpop_signing_alg_values_supported, never none or HS*; jwk is a public JWK with no d, p, q, dp, dq, qi, oth, k or priv. Use the JWS-only compact pattern.

## RFC7516 JSON Web Encryption (JWE)

*May 2015 · Proposed Standard · YAML coverage: **partial** · relevance to an AS: optional · vendoring: vendor*

**What it is.** JWE defines authenticated encryption of content with a JSON header. It has a five-part compact form (header.encryptedKey.iv.ciphertext.tag) and a JSON form. The 'alg' header selects how the content-encryption key is obtained: RSA-OAEP, AES key wrap, ECDH-ES, or 'dir' for a shared key. With 'dir' and direct ECDH-ES the encrypted-key part is empty. The 'enc' header selects the AEAD cipher. OAuth/OIDC use JWE for encrypted ID tokens, UserInfo and introspection responses, request objects and JARM responses, normally as Nested JWTs (signed, then encrypted).

**Why it was created.** A signed token can still be read by anyone who sees it, yet tokens and request objects pass through browsers and logs and can contain personal data. JWE adds JSON-native confidentiality with integrity, comparable to XML Encryption but compact enough for URLs and headers.

<details><summary>Already modeled in the YAML (5)</summary>

- Five-segment JWE Compact Serialization (§7.1) accepted by components.schemas.JWT (2439-2440); see the incorrect entry about the empty Encrypted Key
- Distinguishing JWS from JWE by segment count (§9), stated in the JWT description (2437-2439)
- alg/enc metadata pairs for encrypted objects: introspection_encryption_alg/enc_values_supported (2074-2079), id_token_encryption_* (2086-2091), userinfo_encryption_* (2097-2102), request_object_encryption_* (2108-2113)
- 'signed (optionally encrypted)' wording: /introspect (350-355), /userinfo (508-511, 558-561), Request parameter (960), JWTIntrospectionResponse (1765-1769)
- Server encryption keys published for clients to encrypt requests: /jwks description (579-580); JWK.use enc (1836-1843)

</details>

**Follow-up on the May-2026 validation notes.** There is no per-RFC validation note for RFC 7516. The May-2026 audit did not cover it.

**Notes.** The 'zip' (DEF) header is not modeled, which is correct for an HTTP-surface spec. RFC 8725 §3.6 advises against compressing before encryption. The IANA-absent entries attributed to RFC 7516 (zip, jku, cty, crit and the DEF compression value) are JOSE-header internals with no HTTP role beyond the opaque JWE string. The JWE JSON Serialization (§7.2) is not used by OAuth/OIDC.

### Findings (0 high · 1 medium · 4 low)

1. **[MEDIUM] Incorrect: oauth-openapi.yaml:2440 components.schemas.JWT.pattern (used by /introspect 346-348 and /userinfo 503-505, 553-555)**  
   *Reference:* RFC 7516 §5.1 step 5, §7.1; RFC 7518 §4.1 ('All but "dir" and "ECDH-ES" also produce a JWE Encrypted Key value')  
   The pattern '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+(\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+)?$' requires every segment to be non-empty. A compact JWE whose alg is 'dir' or 'ECDH-ES' has an EMPTY JWE Encrypted Key segment ('header..iv.ciphertext.tag'). I checked this: the RFC 7520 test vectors in Figure 128 (ECDH-ES) and Figure 136 (dir) fail the pattern, while Figure 81 (RSA1_5) passes. ECDH-ES is 'Recommended+' in RFC 7518 §4.1, so a server that validates its own responses would reject a valid encrypted UserInfo or introspection JWT. The pattern also rejects Unsecured JWS ('header.payload.'). That is probably intended, but it is not stated.  
   *Suggested change:* Use pattern: '^[A-Za-z0-9_-]+(\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+|\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+)$'. It requires three non-empty parts for a JWS and allows an empty encrypted-key part for a JWE; I checked it against both vectors and against malformed inputs. Also add to the description: 'The encrypted-key part is empty for alg=dir/ECDH-ES; Unsecured (alg=none) JWS are deliberately not accepted.'  
   *Verifier: confirmed.*

2. **[LOW] Gap: JARM encryption metadata: authorization_encryption_alg_values_supported and authorization_encryption_enc_values_supported**  
   *Reference:* RFC 7516 §4.1.1-§4.1.2 as profiled by OIDF JARM §4.2 and §6 (final §4)  
   The AS advertises JWT-secured response modes (2031), and JARM allows those responses to be signed and then encrypted. The AS metadata has no arrays for announcing JWE alg/enc support on the authorization endpoint, so clients cannot negotiate encryption of the authorization response.  
   *Suggested change:* Add authorization_encryption_alg_values_supported and authorization_encryption_enc_values_supported (type: array, items: string). Describe them as 'JWE alg (CEK management) / enc (content encryption) values for JARM responses; encrypted responses are Nested JWTs (signed, then encrypted)'.  
   *Verifier: confirmed.*

3. **[LOW] Gap: alg/enc semantics and Nested JWT (sign-then-encrypt) rule undocumented**  
   *Reference:* RFC 7516 §4.1.1, §4.1.2 (+ RFC 7519 §11.2, RFC 9101 §4, RFC 9701 §5)  
   None of the encryption arrays (2074-2079, 2086-2091, 2097-2102, 2108-2113) has a description. Nothing says that 'alg' selects key management, that 'enc' (which MUST be present in a JWE) selects the AEAD, that the arrays must be read in pairs, or that encrypted ID tokens, request objects, UserInfo and introspection responses are Nested JWTs (signed first, typically with cty 'JWT'). TokenResponse.id_token (1445-1448) says only 'signed JWT'.  
   *Suggested change:* Add descriptions such as 'JWE alg values (RFC 7518 §4.1) used to encrypt the CEK; pair with *_encryption_enc_values_supported (RFC 7518 §5.1)'. State once that encrypted forms are Nested JWTs. Change the id_token description to 'signed JWT, or a Nested JWT (signed then encrypted) when the client registered id_token_encrypted_response_alg'.  
   *Verifier: partially correct —* Encrypted ID Tokens, JAR Request Objects, JWT introspection responses and JARM responses are Nested JWTs (signed then encrypted). OIDC UserInfo responses and OIDC Request Objects may be plain JWEs (encrypted without signing). The description should say 'Nested JWT when both signed and encrypted'.

4. **[LOW] Gap: The AS advertises encrypted Request Objects and publishes encryption keys at /jwks, but the YAML gives no guidance against JWE decryption oracles** — *found by the verifier*  
   *Reference:* RFC 7516 §11.4, §11.5  
   The AS advertises encrypted Request Objects and publishes encryption keys at /jwks, but the YAML gives no guidance against JWE decryption oracles. It does not say that decryption failures must produce one undifferentiated error, or that each encryption key should be pinned to a single alg. The only error surface is invalid_request_object with a free-text error_description.  
   *Suggested change:* Document on request_object_encryption_alg_values_supported and invalid_request_object: every JWE decryption or validation failure returns the same invalid_request_object error with a constant error_description; each encryption JWK carries a single alg; RSA1_5 is not offered.

5. **[LOW] Incorrect: The /userinfo application/jwt descriptions cover only the signed case: the body is returned 'when the client registered a userinfo_signed_response_alg' and is '** — *found by the verifier*  
   *Reference:* RFC 7516 §7.1 as profiled by OIDC Core 1.0 §5.3.2 and OIDC Discovery 1.0 §3  
   The /userinfo application/jwt descriptions cover only the signed case: the body is returned 'when the client registered a userinfo_signed_response_alg' and is 'signed (optionally encrypted)', and the GET description says such JWTs always carry iss and aud. OIDC also allows encrypt-only JWE responses, in which iss and aud are not mandatory. OIDC Discovery also lets userinfo_signing_alg_values_supported include none, which the JWT pattern rejects; that profile restriction is not stated.  
   *Suggested change:* State that application/jwt is returned when userinfo_signed_response_alg and/or userinfo_encrypted_response_alg is registered, and the body is a JWS, a JWE (encrypt-only) or a Nested JWT. iss and aud are REQUIRED when the response is signed. This profile never emits alg=none.

## RFC7517 JSON Web Key (JWK)

*May 2015 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** JWK defines a JSON representation of a cryptographic key and of a key set ({"keys":[...]}). The common members are kty, use, key_ops, alg, kid, x5u, x5c, x5t and x5t#S256, and the media types are application/jwk+json and application/jwk-set+json. An authorization server publishes its public signing keys, and optionally its encryption keys, as a JWK Set at jwks_uri. Clients and resource servers pick the key by kid to verify tokens. JWKs also appear inside JWTs, for example the DPoP 'jwk' header and cnf.jwk.

**Why it was created.** Distributing keys with X.509, PEM or ASN.1 was heavyweight for web developers. A JSON key format lets keys be discovered and rotated over HTTP (publish the new key, start signing with a new kid, retire the old key) for JWS/JWE, without PKI tooling.

<details><summary>Already modeled in the YAML (14)</summary>

- GET /jwks (573-598) with externalDocs RFC 7517 §5 (583-585) and tag JWKS (101-102)
- Registered media type application/jwk-set+json (§8.5.2) listed first (590-592), with an application/json fallback (596-598)
- JWK Set with REQUIRED 'keys' array (§5, §5.1): components.schemas.JWKS (1813-1820)
- JWK with REQUIRED kty and extension members allowed (§4): components.schemas.JWK (1822-1830)
- kty as an open string with examples RSA, EC, OKP, oct (§4.1): 1832-1835
- use sig/enc plus the use/key_ops consistency rule (§4.2, §4.3): 1836-1843
- key_ops listing the eight registered values (§4.3, §8.3): 1844-1854
- alg (§4.4): 1855-1858
- kid (§4.5): 1859-1861
- x5u (§4.6): 1862-1865
- x5c as base64 (NOT base64url) DER chain with the first certificate holding the key (§4.7): 1866-1873
- x5t and x5t#S256 base64url thumbprints (§4.8, §4.9): 1874-1879
- jwks_uri metadata: AS (1961-1964) and protected resource (2290-2292)
- JWK embedded in cnf (Confirmation.jwk 2587-2589, untyped) and in the DPoP proof header (980)

</details>

**Follow-up on the May-2026 validation notes.** references/rfc-validation/7517-jwk.md (May 2026) listed 14 MISSING, 4 WRONG and 6 NICE-TO-HAVE items (the synthesis table says 12/4).

MISSING: 8 fixed (OKP cited to RFC 8037 at 1828/1892; key_ops values at 1847-1854; use/key_ops consistency at 1841-1843 and 1850-1851; x5t at 1876; x5t#S256 at 1879; x5c base64-not-base64url at 1869-1870; application/jwk-set+json at 590; oct k at 1900-1902). 1 partial (x5c: the first certificate is noted, but chain order and the key-match MUST are missing). 5 open (x5u integrity/TLS/PEM; application/jwk+json; case-sensitive comparison; kid uniqueness within a set; private-key members).

WRONG: 3 fixed (kty is now open via examples at 1835; /jwks lists application/jwk-set+json first at 590-598; x5c encoding is documented). 1 open (case-sensitivity reminder).

NICE-TO-HAVE: alg examples were extended (1858) but now include the deprecated EdDSA and HS256. RFC 7638 is cross-referenced on cnf.jkt (2582) but not on JWK.kid. Per-kty oneOf, JWKS examples and Cache-Control/ETag on /jwks are still open.

Two earlier recommendations went too far: adding 'k' to the public schema now conflicts with §9.2 and OIDC Discovery §3, and the advice to add private-key members should be reversed (prohibit them instead). Closing the use/key_ops enums also contradicts §4.2 and §4.3.

**Notes.** Correctly modeled: the media type, the REQUIRED keys and kty members, the open kty, extension members (additionalProperties), and the base64-vs-base64url warning on x5c. RFC 7517 §5's 'SHOULD ignore JWKs with unknown kty' is guidance for consumers. It matters when the AS fetches client jwks_uri documents (private_key_jwt, JAR), which this YAML does not model.

### Findings (1 high · 2 medium · 10 low)

1. **[HIGH] Incorrect: oauth-openapi.yaml:1899-1902 components.schemas.JWK.properties.k (also JWK.alg examples incl. HS256 at 1858 and additionalProperties: true at 1825). The schema is used only via JWKS.keys (1817-1820), which is returned by the public, unauthenticated GET /jwks (573-598).**  
   *Reference:* RFC 7517 §9.2, §7 (+ OIDC Discovery 1.0 §3 jwks_uri; RFC 7518 §6.4)  
   The schema of the public JWK Set documents the symmetric-key member 'k' and suggests HS256 keys. With additionalProperties: true it also accepts private members (d, p, q, dp, dq, qi, oth). A server generated from this model that serializes its key store would publish its HMAC or private keys to everyone. RFC 7517 §9.2 says private and symmetric keys MUST be protected from disclosure, and OIDC Discovery 1.0 §3 (jwks_uri) says 'The JWK Set MUST NOT contain private or symmetric key values'. The operation's own description (579) says 'public keys'.  
   *Suggested change:* Remove 'k' from the schema served at /jwks. If a symmetric-key schema is needed elsewhere, keep it in a separate, non-published SymmetricJWK. Drop HS256 from the JWK.alg examples. Wrap JWKS.keys.items in a PublicJWK: allOf [$ref JWK, {not: {anyOf: [{required: [d]}, {required: [p]}, {required: [q]}, {required: [dp]}, {required: [dq]}, {required: [qi]}, {required: [oth]}, {required: [k]}, {required: [priv]}]}}]. Add 'public keys only; MUST NOT contain private or symmetric key values' to the JWKS description.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: 'use' REQUIRED on every key when signing and encryption keys are published together**  
   *Reference:* RFC 7517 §4.2 ('OPTIONAL, unless the application requires its presence') + RFC 8414 §2 jwks_uri, OIDC Discovery 1.0 §3, RFC 9728 §2  
   The /jwks description (578-582) says the set may also hold encryption keys. Neither it, the JWKS schema (1813-1820) nor jwks_uri (1961-1964, 2290-2292) says that a 'use' value is then REQUIRED for all keys, or that using one key for both signing and encryption is NOT RECOMMENDED.  
   *Suggested change:* Add a description to components.schemas.JWKS: 'When the set contains both signing and encryption keys, every key MUST include use (RFC 8414 §2; OIDC Discovery §3); do not use one key for both purposes.' Optionally enforce it with if: {properties: {keys: {contains: {required: [use], properties: {use: {const: enc}}}}}} then: {properties: {keys: {items: {required: [use]}}}}. Repeat the sentence on both jwks_uri fields.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: kid uniqueness, matching and rotation guidance**  
   *Reference:* RFC 7517 §4.5, §5.1 (+ RFC 7515 §4.1.4; OIDC Core §10.1, §10.1.1)  
   JWK.kid (1859-1861) says only 'Key ID for selection in a JWKS', and JWKS has no description. Missing points: different keys in a set SHOULD use distinct kid values; kid is case-sensitive and is matched against the JWS/JWE kid header; array order implies no preference; the rotation pattern is to publish a new key before using it and to re-fetch /jwks when an unknown kid appears.  
   *Suggested change:* Expand the JWK.kid and JWKS descriptions with these rules. Mention the RFC 7638 SHA-256 thumbprint as a convenient collision-free kid.  
   *Verifier: confirmed.*

4. **[LOW] Gap: x5u acquisition and consistency requirements**  
   *Reference:* RFC 7517 §4.6 (+ RFC 7515 §8)  
   x5u (1862-1865) lacks these requirements: the resource is a PEM chain (RFC 4945 §6.1); the key in the first certificate MUST match the JWK; the HTTP GET MUST use TLS with server-identity validation; any other members present MUST be consistent with the certificate.  
   *Suggested change:* Add these rules to the description and add pattern: '^https://'.  
   *Verifier: confirmed.*

5. **[LOW] Gap: x5c chain order, key match and bare key members; thumbprint formats**  
   *Reference:* RFC 7517 §4.7-§4.9 (+ OIDC Discovery 1.0 §3)  
   x5c (1866-1873) notes only that the first certificate holds the key. It does not say that each later certificate certifies the previous one, that the key in the first certificate MUST match the JWK members, or (OIDC Discovery §3) that the bare key values MUST still be present when x5c is used. x5t and x5t#S256 have no length or alphabet constraint.  
   *Suggested change:* Add these rules to the description. Add items.pattern '^[A-Za-z0-9+/]+={0,2}$' and minItems: 1 to x5c; pattern '^[A-Za-z0-9_-]{27}$' to x5t; and '^[A-Za-z0-9_-]{43}$' to x5t#S256.  
   *Verifier: confirmed.*

6. **[LOW] Gap: key_ops duplicates and allowed combinations**  
   *Reference:* RFC 7517 §4.3  
   Nothing enforces 'Duplicate key operation values MUST NOT be present', because uniqueItems is absent (1844-1854). The description also does not say that only the pairs sign+verify, encrypt+decrypt and wrapKey+unwrapKey are permitted; other combinations SHOULD NOT be used.  
   *Suggested change:* Add uniqueItems: true and one sentence on the permitted combinations.  
   *Verifier: confirmed.*

7. **[LOW] Gap: Case-sensitive comparison of JWK member values**  
   *Reference:* RFC 7517 §6 (refers to RFC 7515 §5.3)  
   No statement that kty, use, key_ops, alg, kid and crv values are case-sensitive (for example, 'rsa' is not 'RSA'). This item from the prior audit is still open.  
   *Suggested change:* Add to JWK.description: 'All member names and values are case-sensitive and compared code point by code point (RFC 7517 §6, RFC 7515 §5.3).'  
   *Verifier: confirmed.*

8. **[LOW] Gap: application/jwk+json media type and encrypted-JWK cty values**  
   *Reference:* RFC 7517 §8.5.1, §7  
   The single-JWK media type is never mentioned, although JWKs appear standalone in cnf.jwk and the DPoP jwk header. The encrypted-JWK cty values (jwk+json, jwk-set+json) matter only for private-key transport, which this API should never perform.  
   *Suggested change:* Add a note to JWK.description: 'A standalone JWK uses application/jwk+json; private/symmetric JWKs, if ever transported, MUST be JWE-encrypted (cty jwk+json).'  
   *Verifier: partially correct —* The missing media-type note is a valid low-severity gap. The note should say that private or symmetric JWKs MUST be protected from disclosure (RFC 7517 §7, §9.2), that JWE encryption is the recommended means, and that cty jwk+json applies unless the type is known by other means.

9. **[LOW] Gap: Embedded JWKs not typed with the JWK schema**  
   *Reference:* RFC 7517 §4 (+ RFC 7800 §3.2; RFC 9449 §4.2 'MUST NOT contain a private key')  
   Confirmation.jwk (2587-2589) is 'type: object' with the description 'Embedded JWK; rarely used', so it gets no validation and no public-only constraint.  
   *Suggested change:* Change it to jwk: {$ref: '#/components/schemas/PublicJWK'}, the same public-only schema proposed for JWKS.keys.  
   *Verifier: confirmed.*

10. **[LOW] Gap: No JWK Set example**  
   *Reference:* RFC 7517 Appendix A.1  
   Neither JWKS nor JWK has an example, so codegen previews and learners have no concrete shape to look at.  
   *Suggested change:* Add examples to JWKS using the two public keys of RFC 7517 Appendix A.1 (EC P-256 kid '1' and RSA kid '2011-04-29').  
   *Verifier: partially correct —* Add a JWKS example, but give the Appendix A.1 RSA key 'use':'sig' (or use signing keys only) so the example obeys RFC 8414 §2 and OIDC Discovery §3.

11. **[LOW] Incorrect: oauth-openapi.yaml:1836-1838 components.schemas.JWK.properties.use.enum [sig, enc]**  
   *Reference:* RFC 7517 §4.2, §8.2  
   The enum is closed, but RFC 7517 §4.2 says 'Other values MAY be used' and the IANA JSON Web Key Use registry (§8.2) can grow. A validator generated from the YAML would reject a conforming JWK that uses a newly registered or closed-environment use value.  
   *Suggested change:* Replace enum with examples: [sig, enc] (or anyOf: [{enum: [sig, enc]}, {type: string}]) and add 'values from the IANA JSON Web Key Use registry; case-sensitive'.  
   *Verifier: confirmed.*

12. **[LOW] Incorrect: oauth-openapi.yaml:1852-1854 components.schemas.JWK.properties.key_ops.items.enum**  
   *Reference:* RFC 7517 §4.3, §8.3  
   The closed enum contradicts RFC 7517 §4.3 'Other values MAY be used', and the IANA JSON Web Key Operations registry (§8.3) can grow. This change came from the prior audit's recommendation, which had itself noted that the enum 'must permit extension'.  
   *Suggested change:* Use items: {type: string, examples: [sign, verify, encrypt, decrypt, wrapKey, unwrapKey, deriveKey, deriveBits]} and add uniqueItems: true.  
   *Verifier: confirmed.*

13. **[LOW] Gap: ProtectedResourceMetadata.jwks_uri has no description, so it omits the requirement that the JWK Set be fetched over https, which underpins key provenance** — *found by the verifier*  
   *Reference:* RFC 7517 §9.1 as profiled by RFC 9728 §2  
   ProtectedResourceMetadata.jwks_uri has no description, so it omits the requirement that the JWK Set be fetched over https, which underpins key provenance. The agent cites 2290-2292 only for the 'use' rule.  
   *Suggested change:* Add the description 'HTTPS URL of the resource's public JWK Set (RFC 9728 §2); use REQUIRED on all keys when signing and encryption keys coexist' and pattern '^https://'.

## RFC7518 JSON Web Algorithms (JWA)

*May 2015 · Proposed Standard (updated by RFC 9864) · YAML coverage: **partial** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** JWA is the algorithm catalogue for JOSE. It defines the identifiers and exact processing for JWS algorithms (HS*, RS*, ES*, PS*, and 'none'), JWE key-management algorithms (RSA1_5, RSA-OAEP(-256), A*KW, dir, ECDH-ES(+A*KW), A*GCMKW, PBES2) and content-encryption algorithms (A*CBC-HS*, A*GCM). It also defines the type-specific JWK members for EC (crv, x, y, d), RSA (n, e, d, p, q, dp, dq, qi, oth) and oct (k). It creates the IANA registries that every *_alg_values_supported metadata field draws from, and it says Unsecured JWS ('none') MUST NOT be accepted by default.

**Why it was created.** Keeping algorithms separate from the JWS/JWE/JWK formats gives cryptographic agility: algorithms can be added, strengthened or deprecated in an IANA registry with implementation-requirement levels, without revising the formats. Exact encodings such as ECDSA R||S and Base64urlUInt prevent interop failures.

<details><summary>Already modeled in the YAML (9)</summary>

- kty values RSA, EC, oct (§6.1) as examples (1835)
- EC public members crv, x, y (§6.2.1) with P-256, P-384, P-521 (1888-1898)
- RSA public members n, e (§6.3.1) (1881-1886)
- oct member k (§6.4.1) (1900-1902); it is modeled, but on the public JWKS where it must not appear (see the RFC 7517 incorrect entry)
- §3.1 JWS alg identifiers in JWK.alg examples: RS256, RS384, RS512, ES256, ES384, ES512, PS256, HS256 (1858)
- RS256 mandatory for ID tokens (2085)
- 'none' prohibited for resource_signing_alg_values_supported (2308)
- client_secret_jwt (HMAC) and private_key_jwt auth methods (2045-2046) with token_endpoint_auth_signing_alg_values_supported (2050-2056)
- JWE alg/enc metadata arrays exist (2074-2113) but name no RFC 7518 values

</details>

**Follow-up on the May-2026 validation notes.** There is no per-RFC validation note for RFC 7518. The May-2026 audit touched it only through the RFC 7517 note's comments on n, e, crv and k.

**Notes.** RFC 9864 (Oct 2025) formally updates RFC 7518: future registrations must be fully specified, and it defines 'Deprecated' and 'Prohibited'. The pending draft-ietf-jose-deprecate-none-rsa15-06 (IESG, Sep 2026) would also update RFC 7518, marking 'none' and 'RSA1_5' Deprecated and saying new specifications MUST NOT allow either. IANA-absent JWS values HS384, HS512, PS384 and PS512 are fine to leave as examples only. The JWE header parameters epk, apu, apv, iv, tag, p2s and p2c are JOSE-internal and do not need HTTP modeling.

### Findings (1 high · 4 medium · 4 low)

1. **[HIGH] Gap: 'none' and MAC prohibitions on alg metadata and token profiles**  
   *Reference:* RFC 7518 §3.6, §8.5 (+ RFC 8414 §2; RFC 9449 §4.2, §11.6; RFC 9068 §2.1; JARM §5; OIDC Discovery 1.0 §3)  
   Only resource_signing_alg_values_supported (2308) says 'none MUST NOT be used'. The other places that need such a rule: - token_endpoint_auth_signing_alg_values_supported (2050-2056) omits RFC 8414's 'The value "none" MUST NOT be used' and 'Servers SHOULD support RS256'. - revocation_ and introspection_endpoint_auth_signing_alg_values_supported (2060-2068) and introspection_signing_alg_values_supported (2071-2073) have no description at all. - dpop_signing_alg_values_supported (2188-2190, 2326-2328) does not say that DPoP algorithms MUST be asymmetric and never 'none'. - id_token_signing_alg_values_supported (2085) omits that 'none' MUST NOT be used when an ID Token comes from the authorization endpoint, and response_type 'id_token' and 'code id_token' are enabled at 703-706. - JWTAccessTokenClaims (2515-2519) omits RFC 9068's 'MUST NOT use none' and 'MUST include RS256'. With bare items: {type: string}, nothing tells an implementer to reject alg=none or to verify only against the advertised algorithm list. Accepting alg=none is the classic JWT authentication bypass.  
   *Suggested change:* For the client-auth, introspection and JARM arrays, use items: {type: string, not: {const: none}}. For both DPoP arrays, use items: {type: string, not: {enum: [none, HS256, HS384, HS512]}}. Add descriptions with examples, e.g. [ES256, PS256, RS256, Ed25519]. Add to id_token_signing_alg_values_supported: 'none MUST NOT be used for ID Tokens returned from the authorization endpoint'. Add to JWTAccessTokenClaims: 'JWT access tokens MUST NOT use alg none; RS256 MUST be supported (RFC 9068 §2.1)'.  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: Members each key type requires are not enforced**  
   *Reference:* RFC 7518 §6.2.1 (EC: crv, x, y MUST), §6.3.1 (RSA: n, e MUST), §6.4 (oct: k); RFC 8037 §2 (OKP: crv, x MUST); RFC 9964 §3 (AKP: alg, pub REQUIRED)  
   JWK has only 'required: [kty]' (1824). The members are grouped by type only in comments (1880, 1887, 1899), so for example {"kty":"EC","x":"..."} validates.  
   *Suggested change:* Model JWK as a oneOf on kty: RSA → required [kty, n, e]; EC → [kty, crv, x, y]; OKP → [kty, crv, x]; AKP → [kty, alg, pub]. Add a fallback branch for unknown kty, which consumers SHOULD ignore per RFC 7517 §5.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: Private-key members neither modeled nor prohibited**  
   *Reference:* RFC 7518 §6.2.2 (d), §6.3.2 (d, p, q, dp, dq, qi, oth); RFC 8037 §2 (OKP d MUST NOT be present in public keys)  
   The IANA-absent list confirms that p, q, dp, dq, qi and oth are absent. 'd' is absent too: the IANA diff's 'present' flag comes from the word "MAC'd" at 1344. These members must never appear in this API's public JWK Set or in DPoP/cnf JWKs, but with additionalProperties: true (1825) they currently validate.  
   *Suggested change:* Do not add them as properties. Use the PublicJWK 'not: anyOf required [d],[p],[q],[dp],[dq],[qi],[oth],[k],[priv]' guard (see the RFC 7517 finding) and one sentence explaining why.  
   *Verifier: confirmed.*

4. **[MEDIUM] Gap: RSA keys must be 2048 bits or larger**  
   *Reference:* RFC 7518 §3.3, §3.5, §4.2, §4.3  
   For RS*, PS*, RSA1_5 and RSA-OAEP(-256), 'A key of size 2048 bits or larger MUST be used'. JWK.n (1881-1883) says only 'RSA modulus, base64url-encoded'.  
   *Suggested change:* Add to the n description: 'Base64urlUInt modulus; RSA keys MUST be ≥2048 bits (RFC 7518 §3.3/§3.5/§4.2/§4.3)'. Optionally add minLength: 342, the length of a 256-octet modulus in base64url.  
   *Verifier: confirmed.*

5. **[MEDIUM] Gap: HMAC key length for client_secret_jwt (and HS*-signed ID tokens)**  
   *Reference:* RFC 7518 §3.2 (+ OIDC Core §16.19)  
   client_secret_jwt is advertised (2045), and with it the client_secret's octets become the HMAC key. That key MUST be at least the hash size (256 bits for HS256, 384 bits for HS384, 512 bits for HS512). ClientAuthFields.client_secret (1185-1190) does not mention this, so an AS could issue short secrets that are invalid HS256 keys.  
   *Suggested change:* Add to the client_secret description: 'When used with client_secret_jwt (or HS*-signed responses) the secret's UTF-8 octets are the HMAC key and MUST be at least as long as the hash output (≥32 octets for HS256) — RFC 7518 §3.2.'  
   *Verifier: confirmed.*

6. **[LOW] Gap: Base64urlUInt and fixed-length coordinate encodings**  
   *Reference:* RFC 7518 §2 (Base64urlUInt), §6.3.1.1-§6.3.1.2, §6.2.1.2-§6.2.1.3  
   n and e (1881-1886) are described as plain base64url. The RFC requires the minimal big-endian octet string with no leading zero octet (65537 encodes as 'AQAB'), and x and y must be full coordinate length (32 octets, i.e. 43 characters, for P-256). RFC 7638 §7 notes that thumbprints are unique only if these canonical encodings are enforced.  
   *Suggested change:* State the encodings in the n, e, x and y descriptions. Add example 'AQAB' to e.  
   *Verifier: confirmed.*

7. **[LOW] Gap: JWE alg/enc identifiers undocumented**  
   *Reference:* RFC 7518 §4.1, §5.1  
   None of the 27 JWE alg/enc identifiers defined by RFC 7518 appears in the YAML (per the IANA-absent list). The encryption arrays have no examples. Learners cannot tell that A128CBC-HS256 and A256CBC-HS512 are 'Required' enc values, or that RSA1_5 ('Recommended-') is about to be deprecated by draft-ietf-jose-deprecate-none-rsa15-06.  
   *Suggested change:* Add examples: [RSA-OAEP-256, ECDH-ES, ECDH-ES+A256KW] to every *_encryption_alg_values_supported and [A128CBC-HS256, A256GCM] to every *_encryption_enc_values_supported. Note that RSA1_5 should not be offered.  
   *Verifier: partially correct —* None of the 23 JWE identifiers defined by RFC 7518 (17 alg plus 6 enc) appears in the YAML. Counting the 4 absent JWS identifiers as well, 27 RFC 7518 algorithm values are absent.

8. **[LOW] Gap: backchannel_authentication_request_signing_alg_values_supported is a bare string array with no asymmetric-only or no-'none' constraint, although CIBA requires s** — *found by the verifier*  
   *Reference:* RFC 7518 §3.2, §3.6 as profiled by OpenID CIBA Core 1.0 §7.1.1 (+ OIDC Core §10.1)  
   backchannel_authentication_request_signing_alg_values_supported is a bare string array with no asymmetric-only or no-'none' constraint, although CIBA requires signed authentication requests to use an asymmetric signature. The agent's none/MAC finding covers the DPoP arrays but omits this array, which has the same requirement.  
   *Suggested change:* Use items: {type: string, not: {enum: [none, HS256, HS384, HS512]}} and add a description: 'Asymmetric JWS algs only for CIBA signed authentication requests (CIBA §7.1.1).'

9. **[LOW] Gap: The YAML never says that symmetric algorithms derived from client_secret (HS* signatures; dir or A*KW encryption with a client_secret-derived key) MUST NOT be u** — *found by the verifier*  
   *Reference:* RFC 7518 §3.2, §4.4, §4.5 as profiled by OIDC Core 1.0 §10.1, §10.2  
   The YAML never says that symmetric algorithms derived from client_secret (HS* signatures; dir or A*KW encryption with a client_secret-derived key) MUST NOT be used with public clients. Yet it shows HS256 as a JWK alg example and leaves the id_token, userinfo and request_object signing/encryption arrays without descriptions. This matters because OAuth 2.1 centres on public clients.  
   *Suggested change:* Add to the id_token, userinfo and request_object signing/encryption arrays: 'HS* and client_secret-derived dir/A*KW are only for confidential clients (OIDC Core §10.1-§10.2); never for public clients.'

## RFC7638 JSON Web Key (JWK) Thumbprint

*September 2015 · Proposed Standard · YAML coverage: **partial (verifier corrected from mostly)** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** A JWK Thumbprint is a hash (usually SHA-256) of a canonical JSON object that holds only the key type's required public members, sorted lexicographically with no whitespace, and then base64url-encoded. Optional members such as kid, alg and use are excluded, so the same key always yields the same thumbprint, and a private key's thumbprint equals its public key's. DPoP uses the SHA-256 thumbprint as cnf.jkt and dpop_jkt to bind tokens and authorization codes to the client's key, and many servers use it as the kid.

**Why it was created.** Applications needed a stable, deterministic identifier for a key, for kid values and for binding tokens to keys. JSON has no canonical form, so the RFC fixes exactly which members are hashed and how they are serialized.

<details><summary>Already modeled in the YAML (4)</summary>

- Confirmation.jkt = 'JWK SHA-256 thumbprint per RFC 7638' (2579-2583)
- cnf on JWTAccessTokenClaims (2568-2573) and IntrospectionResponse (1748-1753)
- dpop_jkt at /authorize: components.parameters.DPoPJKT (962-970), referenced at 158
- dpop_jkt in PARRequest (1645-1647)

</details>

**Follow-up on the May-2026 validation notes.** There is no per-RFC validation note for RFC 7638. The RFC 7517 note's NICE-TO-HAVE item 'cross-reference RFC 7638' is fixed on cnf.jkt (2582) but still open on JWK.kid.

**Notes.** RFC 9278 (vendored) wraps thumbprints as URIs (urn:ietf:params:oauth:jwk-thumbprint:sha-256:...). Per RFC 7638 §7, a symmetric key's thumbprint can leak information about the key, which is another reason symmetric keys never belong in /jwks.

### Findings (0 high · 0 medium · 2 low)

1. **[LOW] Gap: dpop_jkt / jkt value format and provenance**  
   *Reference:* RFC 7638 §3, §3.4 (as profiled by RFC 9449 §6.1 and §10)  
   DPoPJKT (962-970) and PARRequest.dpop_jkt (1645-1647) do not say that the value is the base64url-encoded SHA-256 JWK Thumbprint of the DPoP public key, i.e. the same value as cnf.jkt. None of the three fields, Confirmation.jkt (2579-2583) included, constrains the format.  
   *Suggested change:* Add the description 'base64url SHA-256 JWK Thumbprint (RFC 7638) of the DPoP public key; equals cnf.jkt' and pattern: '^[A-Za-z0-9_-]{43}$' to all three fields. Use the example 'NzbLsXh8uDCcd-6MNwXF4W_7noWXFZAfHkxZsRGC9Xs' (RFC 7638 §3.1).  
   *Verifier: confirmed.*

2. **[LOW] Gap: Thumbprint input rules (required members per kty, ordering, no whitespace or escapes)**  
   *Reference:* RFC 7638 §3, §3.2, §3.3, §7 (+ RFC 8037 §2 for OKP, RFC 9964 §6 for AKP)  
   Nothing tells an implementer which members to hash: EC {crv, kty, x, y}, RSA {e, kty, n}, oct {k, kty}, OKP {crv, kty, x}, AKP {alg, kty, pub}. Nor does it say that kid, alg and use are excluded, or that thumbprints are unique only when the key's canonical encoding (e.g. e='AQAB') is validated. This is a common source of DPoP interop bugs.  
   *Suggested change:* Extend the Confirmation.jkt description with this member table and the canonical-JSON example from RFC 7638 §3.1.  
   *Verifier: confirmed.*

## RFC8037 CFRG Elliptic Curve Diffie-Hellman (ECDH) and Signatures in JSON Object Signing and Encryption (JOSE)

*January 2017 · Proposed Standard (updated by RFC 9864) · YAML coverage: **mostly** · relevance to an AS: optional · vendoring: vendor*

**What it is.** RFC 8037 brings the CFRG curves to JOSE. It defines a new key type 'OKP' (Octet Key Pair) with members crv, x (public key) and d (private key), the JWS algorithm 'EdDSA' for Ed25519/Ed448 keys, and ECDH-ES key agreement with X25519/X448. It also fixes the OKP thumbprint members (crv, kty, x) and forbids cross-use: Ed* keys only sign, X* keys only do key agreement.

**Why it was created.** The IRTF CFRG selected the Curve25519/Curve448 algorithms (RFC 7748, RFC 8032) as faster, simpler and more misuse-resistant alternatives to the NIST P-curves. Their keys are octet strings rather than (x, y) points, so JOSE needed a new key type and new identifiers.

<details><summary>Already modeled in the YAML (4)</summary>

- kty 'OKP' example (1835) and JWK description citing RFC 8037 (1827-1828)
- OKP crv values Ed25519, Ed448, X25519, X448 (1890-1892)
- OKP 'x' = public key (1893-1895); 'y' not used for OKP (1896-1898)
- 'EdDSA' JWS alg (§3.1) in JWK.alg examples (1858) and the DPoP algs example (1023); now deprecated, see RFC 9864

</details>

**Follow-up on the May-2026 validation notes.** There is no per-RFC validation note for RFC 8037. The RFC 7517 note's item 'OKP must reference RFC 8037' is fixed (1828, 1887, 1892).

**Notes.** The 'EdDSA' identifier defined here is now Deprecated (RFC 9864 §4.1.2, IANA updated 2025-05-12). The OKP key representation itself is unchanged (RFC 9864 §5), so the JWK members at 1888-1898 stay correct. The rule that OKP public keys MUST NOT carry 'd' is covered by the public-JWK guard proposed under RFC 7517 and RFC 7518.

### Findings (0 high · 0 medium · 1 low)

1. **[LOW] Gap: Curve-to-purpose restrictions for OKP keys and X25519/X448 key agreement**  
   *Reference:* RFC 8037 §3.1, §3.2  
   The crv description (1888-1892) lists Ed25519/Ed448 and X25519/X448 together. It does not say that Ed* MUST NOT be used for ECDH-ES and X* MUST NOT be used for signing, which in practice means use 'sig' for Ed* and 'enc' for X*. ECDH-ES with X25519/X448 never appears as an encryption option.  
   *Suggested change:* Add to the crv description: 'Ed25519/Ed448: signatures only (JWS alg Ed25519/Ed448 per RFC 9864; legacy EdDSA); X25519/X448: ECDH-ES key agreement only (use enc); OKP public keys MUST NOT contain d.'  
   *Verifier: confirmed.*

## RFC9864 Fully-Specified Algorithms for JSON Object Signing and Encryption (JOSE) and CBOR Object Signing and Encryption (COSE)

*October 2025 · Proposed Standard (updates RFC 7518, RFC 8037, RFC 9053) · YAML coverage: **none** · relevance to an AS: recommended · vendoring: vendor*

**What it is.** RFC 9864 introduces 'fully-specified' algorithm identifiers, which fix every parameter (curve, hash, KDF). For JOSE it registers 'Ed25519' and 'Ed448' as JWS algorithms and marks the polymorphic 'EdDSA' as Deprecated. It requires all future JOSE/COSE registrations to be fully specified, defines 'Deprecated' and 'Prohibited', and RECOMMENDS that JWKs carry 'alg', because a key MUST be used with only one algorithm unless proven safe. Key representations do not change (still kty OKP, crv Ed25519).

**Why it was created.** Metadata such as RFC 8414's *_alg_values_supported negotiates by algorithm identifier alone. With 'EdDSA' a party cannot say whether it supports Ed25519, Ed448 or both, which caused real interop problems; WebAuthn, for example, had to redefine EdDSA to mean Ed25519. Fully-specified identifiers make negotiation and allow-lists unambiguous.

**Follow-up on the May-2026 validation notes.** There is no prior validation note; RFC 9864 was published after the May-2026 audit baseline was drafted. The RFC 7517 note had itself suggested 'EdDSA' as an example value, which is now outdated.

**Notes.** JOSE's ECDSA identifiers (ES256, ES384, ES512) were already fully specified. RFC 9864's ESP256 and ESB* identifiers are COSE-only, so JOSE has no ECDSA change. RFC 9864 deliberately leaves RSA (RS*/PS*) and ECDH-ES (§6) polymorphic; no replacements exist. The modeled_elements list is empty because the YAML contains none of RFC 9864's identifiers or rules. The OKP key shape at 1888-1898 is still valid per §5.

### Findings (0 high · 0 medium · 3 low)

1. **[LOW] Gap: Fully-specified EdDSA identifiers Ed25519 / Ed448 as JWS alg values**  
   *Reference:* RFC 9864 §2.2, §4.1.1  
   Ed25519 and Ed448 never appear as alg values; they appear only as crv names (1892), so the IANA diff's 'present' flag is a false positive. The alg metadata arrays (2050-2113, 2188, 2246, 2305, 2326) and the DPoP algs examples (1022-1023) therefore give no fully-specified guidance. draft-ietf-oauth-rfc8725bis-10 §3.2 (RFC Editor queue) also says new deployments SHOULD prefer Ed25519 over EdDSA.  
   *Suggested change:* Add Ed25519 (and Ed448) to the JWK.alg examples and to the examples/descriptions of the id_token, userinfo, request_object, token_endpoint_auth and dpop signing arrays. Note: 'EdDSA is Deprecated (RFC 9864 §4.1.2); accept it only for backward compatibility.'  
   *Verifier: confirmed.*

2. **[LOW] Gap: JWK 'alg' RECOMMENDED; one key, one algorithm**  
   *Reference:* RFC 9864 §7 (+ §5)  
   RFC 9864 §7 says a key MUST be used with only a single algorithm unless that use is proven secure, and therefore RECOMMENDS that the JWK 'alg' member be present. JWK.alg (1855-1858) presents alg only as optional per RFC 7517 §4.4.  
   *Suggested change:* Set the JWK.alg description to: 'RECOMMENDED for keys published at /jwks (RFC 9864 §7): pins each key to one fully-specified algorithm and prevents cross-algorithm key reuse.'  
   *Verifier: confirmed.*

3. **[LOW] Incorrect: oauth-openapi.yaml:1858 components.schemas.JWK.properties.alg.examples ('EdDSA'); oauth-openapi.yaml:1023 components.headers.WWWAuthenticateBearerDPoP.schema.examples ('DPoP algs="ES256 EdDSA"')**  
   *Reference:* RFC 9864 §2.2, §4.1.2, §4.4  
   The examples promote the polymorphic identifier 'EdDSA', which RFC 9864 deprecated; the IANA JOSE implementation requirement has read 'Deprecated' since 2025-05-12. Under RFC 9864 §4.4, Deprecated means the replacement SHOULD be used in new deployments. A spec that sets OAuth 2.1 defaults gives no hint that Ed25519/Ed448 exist.  
   *Suggested change:* Replace EdDSA with Ed25519 in both examples (e.g. 'DPoP algs="ES256 Ed25519"' and alg examples [RS256, PS256, ES256, Ed25519, ...]). Keep 'EdDSA' only with a '(deprecated — RFC 9864)' note.  
   *Verifier: confirmed.*

## RFC9964 ML-DSA for JSON Object Signing and Encryption (JOSE) and CBOR Object Signing and Encryption (COSE)

*May 2026 · Proposed Standard · YAML coverage: **none** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** RFC 9964 specifies how to use the post-quantum signature scheme ML-DSA (NIST FIPS 204) in JOSE and COSE. It registers the JWS algorithms ML-DSA-44, ML-DSA-65 and ML-DSA-87, plus a new generic key type 'AKP' (Algorithm Key Pair). An AKP JWK carries 'alg' (REQUIRED), 'pub' (REQUIRED) and 'priv' (a 32-byte seed that MUST NOT appear in public keys). It defines AKP thumbprints over {alg, kty, pub} and warns that ML-DSA keys and signatures are kilobytes in size.

**Why it was created.** A cryptographically relevant quantum computer would break RSA, ECDSA and EdDSA signatures. NIST standardized ML-DSA in 2024, and JOSE/COSE ecosystems, including OAuth/OIDC token signing, need registered identifiers and key formats to begin migrating.

**Follow-up on the May-2026 validation notes.** There is no prior validation note; RFC 9964 was published in May 2026, after the audit.

**Notes.** RFC 9964 comes from the COSE WG. IANA registered ML-DSA-44/65/87, the kty AKP and the JWK parameters pub and priv (Optional). The modeled_elements list is empty: the open kty and additionalProperties: true in the JWK schema mean an AKP key is not rejected, but nothing in the YAML models it. Related JOSE work in progress: draft-ietf-jose-pq-composite-sigs-05 and draft-ietf-jose-pqc-kem-06. Vendor this RFC once AKP is modeled.

### Findings (0 high · 0 medium · 2 low)

1. **[LOW] Gap: AKP key type members 'pub'/'priv' and the alg-REQUIRED rule**  
   *Reference:* RFC 9964 §3, §6, §8.1.5-§8.1.6  
   Because kty is open (1832-1835) and additionalProperties is true (1825), an AKP JWK already validates. However, there is no 'pub' property, no rule that AKP keys require 'alg' and 'pub', no rule that 'priv' MUST NOT appear in public keys, and the AKP thumbprint members are not documented. The only hint is 'e.g. post-quantum' in JWK.description (1829-1830).  
   *Suggested change:* Add pub: {type: string, description: 'AKP public key, base64url (RFC 9964 §3)'}. Add an AKP branch with required [kty, alg, pub] to the per-kty oneOf, include 'priv' in the public-JWK prohibition guard, and list {alg, kty, pub} in the thumbprint documentation.  
   *Verifier: confirmed.*

2. **[LOW] Gap: ML-DSA JWS algorithm identifiers and size implications**  
   *Reference:* RFC 9964 §5, §8.1.4  
   ML-DSA-44, ML-DSA-65 and ML-DSA-87 are absent from the JWK.alg examples and the signing-alg guidance. The YAML also gives no warning that ML-DSA public keys (1312-2592 bytes) and signatures (2420-4627 bytes) make DPoP proofs, which embed the jwk, and signed JWTs much larger, possibly beyond typical HTTP header-size limits.  
   *Suggested change:* Add 'ML-DSA-44', 'ML-DSA-65' and 'ML-DSA-87' to the JWK.alg examples with a 'post-quantum, RFC 9964' note. Add a size caveat to the DPoPHeader description.  
   *Verifier: confirmed.*

## RFC8812 CBOR Object Signing and Encryption (COSE) and JSON Object Signing and Encryption (JOSE) Registrations for Web Authentication (WebAuthn) Algorithms

*August 2020 · Proposed Standard · YAML coverage: **partial** · relevance to an AS: optional · vendoring: catalog-only*

**What it is.** RFC 8812 registers in COSE the RSASSA-PKCS1-v1_5 algorithms (RS256/384/512 and RS1) that WebAuthn/FIDO2 use. It also defines secp256k1 support for both JOSE and COSE. For JOSE that means the JWK curve name 'secp256k1' (kty EC, uncompressed x/y of exactly 256 bits) and the JWS algorithm 'ES256K' (ECDSA with secp256k1 and SHA-256), which MUST be the only algorithm used with that curve.

**Why it was created.** WebAuthn/CTAP implementations were already using algorithms with no IANA COSE registration. The secp256k1 curve, popular in blockchain and DID ecosystems, could not be expressed in JOSE because ES256 is defined only for P-256.

<details><summary>Already modeled in the YAML (1)</summary>

- secp256k1 listed as an EC crv value (1890-1892)

</details>

**Follow-up on the May-2026 validation notes.** There is no prior validation note for RFC 8812.

**Notes.** The COSE-side registrations (RS256/RS384/RS512/RS1 for WebAuthn) have no JOSE or OAuth HTTP impact. ES256K matters only for an AS serving wallet/DID ecosystems.

### Findings (0 high · 0 medium · 1 low)

1. **[LOW] Gap: ES256K algorithm identifier and secp256k1 attribution and rules**  
   *Reference:* RFC 8812 §3.1, §3.2, §3.3, §4.3, §4.4  
   secp256k1 appears under the comment 'EC + OKP (RFC 7518 §6.2 + RFC 8037)' (1887), but it is registered by RFC 8812, not RFC 7518. 'ES256K' is absent. RFC 8812 also says secp256k1 MUST be used only with ES256K (not ES256), x and y must each be exactly 256 bits, and a JWK with 'use' must have use 'sig'.  
   *Suggested change:* Cite RFC 8812 §3.1 in the crv description and add the pairing rule ('secp256k1 → alg ES256K only'). Optionally add 'ES256K' to the JWK.alg examples.  
   *Verifier: confirmed.*

## RFC7520 Examples of Protecting Content Using JSON Object Signing and Encryption (JOSE)

*May 2015 · Informational · YAML coverage: **not-applicable** · relevance to an AS: informational · vendoring: catalog-only*

**What it is.** RFC 7520 is an informational cookbook of worked JOSE examples with complete inputs and outputs. It includes sample EC, RSA and symmetric JWKs; JWS with RS256, PS384, ES512 and HS256, including detached content and multiple signatures; JWE with RSA1_5, RSA-OAEP, PBES2, ECDH-ES(+A128KW), dir and AES-GCM key wrap, with compression, AAD and multiple recipients; and a nested sign-then-encrypt example (§6). It defines no protocol elements.

**Why it was created.** The space of algorithm and serialization permutations is huge, so implementers needed known-answer test vectors to check that JOSE libraries interoperate.

**Follow-up on the May-2026 validation notes.** There is no prior validation note for RFC 7520 (Informational examples).

**Notes.** RFC 7520 §3.1 and §3.3 reuse the same kid for an EC key and an RSA key, which RFC 7517 §4.5 allows when kty differs. For a JWKS example with distinct kids, prefer RFC 7517 Appendix A.1.

### Findings (0 high · 0 medium · 1 low)

1. **[LOW] Gap: Known-answer vectors not used as YAML examples or regression fixtures**  
   *Reference:* RFC 7520 §3.1, §3.3, §5.5, §5.6, §6  
   The YAML has no JWK or JWKS examples and only a placeholder JWT example (2441). RFC 7520's vectors would have exposed the components.schemas.JWT pattern defect: the compact JWEs in Figure 128 (ECDH-ES) and Figure 136 (dir) fail it. Machine-readable versions are at github.com/ietf-jose/cookbook.  
   *Suggested change:* Once the pattern is fixed, add the §5.6 dir JWE (Figure 136) as an example on components.schemas.JWT. Use the cookbook vectors as validation fixtures in the spec's lint/test tooling and in the planned reference server's test suite.  
   *Verifier: confirmed.*

## Verifier corrections to the summaries above

- Cluster notes: 'about 16 *_alg_values_supported arrays' is inexact. There are 15 *_alg_values_supported properties (lines 2050, 2060, 2066, 2071, 2074, 2082, 2086, 2094, 2097, 2105, 2108, 2188, 2246, 2305, 2326) plus 4 *_enc_values_supported (2077, 2089, 2100, 2111), so 19 alg/enc arrays in total.
- Cluster notes say 'Two of the fixes went too far: adding k ... and closing the enums'. Only the key_ops enum came from an audit-driven change. The use enum [sig, enc] predates the May-2026 audit, which wrongly listed it under 'Correctly modeled' (7517-jwk.md lines 28-30). The follow-up should say the prior audit erred there.
- RFC 7517 prior_validation_followup tally: the 'use/key_ops consistency' item is counted as fixed, but the same audit item (7517-jwk.md lines 77-81) also asked to document 'Multiple unrelated key operations SHOULD NOT be specified'. That is still missing, and the agent itself lists it as open gap 'key_ops duplicates and allowed combinations'. The item is therefore partly fixed. The 18 MISSING/WRONG items come to 10 fixed, 2 partly fixed and 6 open (not 11/1/6).
- Cluster notes ('False positives in the IANA diff'): 'none' matches not only prompt=none (816) and the auth-method value none (2042). It also appears at 2308 as a genuine, prohibited JWS alg value ('none MUST NOT be used').
- Cluster notes on JARM at IANA: the AS-metadata registry indeed has no authorization_signing_alg_values_supported or authorization_encryption_alg/enc_values_supported. However, these exact names are registered (2026-08-03) in the OAuth Dynamic Client Registration Metadata registry by OpenID Connect RP Metadata Choices 1.0, as client capability lists. The JARM client metadata itself was registered on 2026-08-03 (authorization_signed_response_alg) and 2026-08-24 (authorization_encrypted_response_alg/enc), citing oauth-v2-jarm-errata1 §3.
- Cluster notes item (2): only RFC 9449 bans MAC algorithms. RFC 8414 §2 and RFC 9068 §2.1 ban only 'none' (client_secret_jwt needs HMAC, and RFC 9068 only RECOMMENDS asymmetric signing). RFC 7518 §3.6 forbids accepting Unsecured JWSs by default rather than requiring metadata prohibitions. The doc-level detail is accurate; the summary phrase 'none/MAC prohibition ... require one' overgeneralizes.
- RFC 9964 notes: IANA's JSON Web Key Parameters registry has no 'Optional' requirement column. It lists pub with Parameter Information Class 'Public' and priv with 'Private'. 'Optional' is the JOSE implementation requirement of the AKP key type and of ML-DSA-44/65/87.
- RFC 7515 notes: RFC 8725 §3.10 does not say that jku/x5u 'must not be dereferenced'. It says 'Applications SHOULD protect against such attacks, e.g., by matching the URL to a whitelist of allowed locations and ensuring no cookies are sent in the GET request.' Trusting only the registered jwks/jwks_uri is a stricter profile choice, not the RFC text.
- RFC 7518 gap 'JWE alg/enc identifiers undocumented': RFC 7518 defines 23 JWE identifiers (17 alg in §4.1, 6 enc in §5.1), not 27. The 27 in the IANA absence list includes the absent JWS values HS384, HS512, PS384 and PS512.
- RFC 8812 summary: 'ES256K ..., which MUST be the only algorithm used with that curve' drops the RFC's qualifier. §3.3 says 'When used for ECDSA, the secp256k1 curve MUST be used only with the ES256K algorithm identifier', and explicitly leaves ECDH-ES use of secp256k1 undecided.
- RFC 9864 summary: the JWK 'alg' RECOMMENDATION (§7) carries the caveat 'unless there exists some other mechanism for ensuring that the key is used as intended'. 'A key MUST be used with only one algorithm unless proven safe' is quoted correctly.
- Status precision: draft-ietf-jose-hpke-encrypt-22 is in the RFC Editor queue with RFC Editor state 'Blocked'. draft-ietf-jose-deprecate-none-rsa15-06 (dated 25 September 2026) is in IESG state 'Waiting for AD Go-Ahead' with IANA review state 'IANA - Not OK'. The list of other active JOSE WG drafts also omits draft-ietf-jose-hpke-pq-pqt-01.
