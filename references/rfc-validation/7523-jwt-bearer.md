# RFC 7523 — JWT Profile for OAuth 2.0 Client Authentication and Authorization Grants

Source: https://datatracker.ietf.org/doc/html/rfc7523
Audit date: 2026-05-10

Scope reviewed: `components.schemas.JWTBearerTokenRequest`,
`components.schemas.TokenRequest` (discriminator mapping),
`components.securitySchemes.clientAssertion`,
`components.schemas.DiscoveryDocument.token_endpoint_auth_methods_supported`,
`components.schemas.ErrorResponse`, `paths./token` security requirements.

NOTE: WebFetch was denied; the audit was performed against the canonical RFC
text fetched directly via curl from `https://www.rfc-editor.org/rfc/rfc7523.txt`
(675 lines, retrieved 2026-05-10). All section (§) and quoted-text references
are verbatim from that document.

## Correctly modeled

- **JWT Bearer grant_type URN** (§2.1, §8.1): the spec sets
  `JWTBearerTokenRequest.grant_type` to
  `const: 'urn:ietf:params:oauth:grant-type:jwt-bearer'` — exactly the URN
  registered by §8.1.
- **Discriminator mapping** (§2.1): `TokenRequest.discriminator.mapping`
  contains the same URN keying `JWTBearerTokenRequest`, allowing `/token` to
  dispatch to this schema by `grant_type`.
- **`assertion` parameter is REQUIRED, contains a single JWT** (§2.1):
  the spec lists `assertion` in `required: [grant_type, assertion]` and
  describes it as "A signed JWT bearer assertion" — matches "The value of
  the 'assertion' parameter MUST contain a single JWT."
- **`scope` parameter is OPTIONAL** (§2.1): present on the schema without
  being required — matches "The 'scope' parameter may be used … to indicate
  the requested scope."
- **Form-encoded body on POST /token** (§2.1 example): `/token` declares
  `application/x-www-form-urlencoded` content for the `requestBody`, matching
  the RFC's `Content-Type: application/x-www-form-urlencoded` example.
- **Discovery advertises `private_key_jwt` and `client_secret_jwt`** (§2.2,
  via OIDC/RFC 8414 token-endpoint auth method names): both values are
  enumerated in
  `DiscoveryDocument.token_endpoint_auth_methods_supported`, which is the
  mechanism a server uses to declare RFC 7523 client-assertion support.
- **`invalid_grant` error code** (§3.1): `ErrorResponse.error` enum
  contains `invalid_grant`, matching "The value of the 'error' parameter
  MUST be the 'invalid_grant' error code."
- **`invalid_client` error code** (§3.2): `ErrorResponse.error` enum
  contains `invalid_client`, matching "The value of the 'error' parameter
  MUST be the 'invalid_client' error code."
- **`/token` exposes `clientAssertion` as a security option** (§2.2): the
  `/token` security array lists `clientAssertion: []` alongside
  `clientSecretBasic`, `clientSecretPost`, and `none`, signaling that
  callers may authenticate via JWT.

## MISSING — must add

- **`client_assertion_type` form parameter is not modeled anywhere** (§2.2,
  §8.2): the RFC says "The value of the 'client_assertion_type' is
  'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'." This value is
  REQUIRED in the form body whenever a JWT is used for client authentication,
  but the spec contains no field, parameter, or schema that names
  `client_assertion_type`, and the URN
  `urn:ietf:params:oauth:client-assertion-type:jwt-bearer` does not appear in
  the YAML at all. Without it, a generated client cannot construct a valid
  RFC 7523 §2.2 request.
- **`client_assertion` form parameter is not modeled** (§2.2): "The value of
  the 'client_assertion' parameter contains a single JWT. It MUST NOT contain
  more than one JWT." The spec models neither the field name nor the
  one-JWT constraint. The placeholder `clientAssertion` security scheme
  (see WRONG below) only flags that JWT-based client auth is permitted; it
  does not surface the actual body parameters to API consumers.
- **`unsupported_grant_type` for `urn:…:jwt-bearer`** (§3.1, indirect via
  RFC 6749 §5.2): already in the `ErrorResponse` enum, OK. *No add needed —
  noted here for completeness.*
- **`token_endpoint_auth_signing_alg_values_supported` discovery field**
  (§5, RFC 8414 §2 / OIDC Discovery): the RFC declares "The 'RS256'
  algorithm, from [JWA], is a mandatory-to-implement JSON Web Signature
  algorithm for this profile." Servers signal which `alg` values they accept
  for `client_assertion` JWTs via this discovery field. It is missing from
  `DiscoveryDocument` and should be added so clients can negotiate `alg`.
- **`grant_types_supported` should be able to advertise the JWT-bearer URN**
  (§2.1, RFC 8414 §2): `DiscoveryDocument.grant_types_supported` is typed
  as a free `array of string` (good, permissive), but no example or
  description ties it to `urn:ietf:params:oauth:grant-type:jwt-bearer`.
  Add the URN to a description/example so consumers know the expected value
  format.

## WRONG — must fix

- **`clientAssertion` security scheme misrepresents the wire format**
  (§2.2): the scheme is declared as
  `type: apiKey, in: header, name: X-OAuth-Client-Assertion`. **No such
  header exists in any RFC.** RFC 7523 §2.2 transports `client_assertion`
  and `client_assertion_type` as `application/x-www-form-urlencoded` body
  fields on the token request, not as an HTTP header. The current modeling
  will mislead any code generator. OpenAPI 3.1 cannot natively express
  body-form authentication, but the correct workaround is to (a) model
  `client_assertion` and `client_assertion_type` directly on the affected
  request schemas (e.g., as optional fields on `AuthorizationCodeTokenRequest`,
  `ClientCredentialsTokenRequest`, `RefreshTokenRequest`,
  `JWTBearerTokenRequest`, `DeviceCodeTokenRequest`,
  `TokenExchangeRequest`, `RevocationRequest`, `IntrospectionRequest`,
  `PARRequest`), and (b) keep the `clientAssertion` security scheme as a
  documentation-only marker whose `description` explicitly states it is a
  body-credential, not a header. The current spec does (b) for
  `clientSecretPost` (with the same caveat in the description) but the
  `clientAssertion` description omits the parameter names entirely.
- **`clientAssertion` description names the wrong RFC** (§1, §2.2): the
  description says "(RFC 7521)" but RFC 7521 is the abstract assertion
  framework. The concrete `client_assertion_type` URN
  `urn:ietf:params:oauth:client-assertion-type:jwt-bearer` and its semantics
  are defined by **RFC 7523 §2.2 and §8.2**. Update the citation to
  "RFC 7523 §2.2 (the JWT profile of RFC 7521)".
- **Spec calls the JWT in §2.1 only "A signed JWT bearer assertion"**
  (§3 rule 9): RFC 7523 §3 rule 9 states "The JWT MUST be digitally signed
  or have a Message Authentication Code (MAC) applied by the issuer."
  MAC-protected JWTs (e.g., HS256, used for `client_secret_jwt`) are
  expressly permitted. Reword the `assertion` description to "A signed or
  MAC-protected JWT bearer assertion (RFC 7523 §3)".
- **No documentation of required JWT claims** (§3, rules 1–4 + 9): the
  `assertion` field's `description` is a single line. RFC 7523 §3
  enumerates the validation rules the AS MUST apply: `iss`, `sub`, `aud`
  (containing the AS identity, typically the token endpoint URL), `exp`
  REQUIRED; `nbf`, `iat`, `jti` OPTIONAL; signature/MAC REQUIRED. A
  reference-grade spec should list these in the `description` (or via a
  linked `JWTBearerAssertionClaims` object schema purely for documentation)
  so generated docs surface the contract. Currently a reader of the spec
  has no way to know what the assertion JWT must contain.
- **No documentation of the `iss` vs `sub` distinction** (§3 rules 1–2):
  for the **authorization grant** path, `sub` identifies an authorized
  accessor (resource owner or delegate); for **client authentication**,
  `sub` MUST equal the `client_id` of the OAuth client. These are different
  contracts on the same JWT shape and should be called out — particularly
  because the same securitySchemes/schema names cover both modes.
- **`aud` audience requirement is not surfaced** (§3 rule 3): "The
  authorization server MUST reject any JWT that does not contain its own
  identity as the intended audience." This is the most commonly
  misimplemented rule in real deployments. The spec should mention it in
  the `assertion` description and ideally point at the discovery `issuer`
  field (or `token_endpoint`) as the canonical audience value.

## NICE-TO-HAVE

- **Define a documentation-only `JWTBearerAssertionClaims` schema** (§3):
  list `iss` (required, string), `sub` (required, string), `aud` (required,
  string-or-array), `exp` (required, integer seconds-since-epoch), `nbf`
  (optional, integer), `iat` (optional, integer), `jti` (optional, string).
  Mark it as not directly used in any request body but reference it from the
  `assertion` and (post-fix) `client_assertion` `description` fields. This
  gives generated documentation viewers a concrete object to display.
- **Extend `JWTBearerTokenRequest` with `resource` and `audience`**
  (RFC 8707, complementary): RFC 7523 itself does not define these, so this
  is purely a quality-of-life addition and not required for 7523 compliance.
- **Example values** on the URN constants and the `assertion` field. The
  RFC §2.1 example is reproduced verbatim in the spec's other discriminator
  branches but not for this one.
- **Cross-link `client_secret_jwt` vs `private_key_jwt`** in the
  `clientAssertion` description (§5, OIDC Core 9): both names appear in
  `token_endpoint_auth_methods_supported` but the link to RFC 7523 mechanics
  (HS256 → `client_secret_jwt`, RS256/ES256/PS256 → `private_key_jwt`) is
  not stated anywhere. A one-line note is helpful.
- **State that replay protection via `jti` is OPTIONAL** (§3 rule 7, §6):
  "The specification does not mandate replay protection for the JWT usage
  for either the authorization grant or for client authentication."
  Worth a note so implementors know `jti` is permitted but not required.

## NOT APPLICABLE

- **Out-of-band agreement on identifiers, keys, endpoints (§5)**: configured
  out of band between issuer and AS; not modelable in OpenAPI.
- **Privacy considerations (§7)**: TLS is asserted globally via the
  `https://{issuer}` server URL; encryption-of-JWT-to-AS (JWE) is an
  implementation choice not part of the wire schema.
- **JWT internal structure (header `alg`/`kid`, signature, base64url
  encoding)**: defined by RFC 7519/7515, out of scope for the JWT-as-a-
  string field on the request body.
- **Process by which the client obtains the JWT (§1)**: explicitly
  declared out of scope by the RFC itself.
- **Mandatory-to-implement RS256 (§5)**: an algorithm-support requirement
  on the AS; surfaced via `token_endpoint_auth_signing_alg_values_supported`
  (see MISSING) but no further OpenAPI modeling possible.
- **One-time-use / `jti` replay-cache TTL (§3 rule 7)**: server-side policy.
