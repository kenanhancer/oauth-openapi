# OpenID Connect Discovery 1.0

Source: https://openid.net/specs/openid-connect-discovery-1_0.html
Audit date: 2026-05-10

Note on scope: this audit covers OIDC Discovery 1.0 §3 (OpenID Provider
Metadata) and §4 (Obtaining OpenID Provider Configuration Information).
Where OIDC Discovery 1.0 and RFC 8414 (OAuth 2.0 Authorization Server
Metadata) overlap, OIDC Discovery is the broader/older spec — most fields
in RFC 8414 §2 are explicitly inherited from OIDC Discovery 1.0 §3.

The audited spec uses a single `DiscoveryDocument` schema that is shared
between `/.well-known/openid-configuration` (OIDC Discovery 1.0) and
`/.well-known/oauth-authorization-server` (RFC 8414). Findings below
apply to that shared schema; OIDC-only fields are flagged.

WebFetch was unavailable in this run (sandbox denial); the audit relies on
RFC 8414 §2 (which transcribes the OIDC Discovery field definitions
verbatim and is present at `references/rfc-validation/.rfc8414-source.txt`)
together with the OIDC Discovery 1.0 §3 field list as it appears in the
OpenID Foundation specification.

---

## Correctly modeled

- **Discovery path** (`GET /.well-known/openid-configuration`) exists and
  responds with `application/json` (OIDC Discovery 1.0 §4.1 / §4.2).
- **`issuer`** (REQUIRED, URL): present, `format: uri`, marked required.
  Description correctly states it MUST equal the host the document was
  fetched from (OIDC Discovery 1.0 §4.3 — issuer validation).
- **`authorization_endpoint`** (REQUIRED, URL): present, `format: uri`,
  marked required (OIDC Discovery 1.0 §3).
- **`token_endpoint`** (REQUIRED unless only Implicit, URL): present,
  `format: uri`, marked required (OIDC Discovery 1.0 §3).
- **`userinfo_endpoint`** (RECOMMENDED, URL): present with description
  "OIDC: required if the provider supports it" (OIDC Discovery 1.0 §3 —
  the spec actually says RECOMMENDED, not REQUIRED-if-supported; see
  WRONG section).
- **`jwks_uri`** (REQUIRED in OIDC, OPTIONAL in 8414, URL): present,
  `format: uri`. Marked optional in the schema, which is correct for the
  RFC 8414 reuse but WRONG for OIDC Discovery (see WRONG section).
- **`registration_endpoint`** (RECOMMENDED in OIDC, OPTIONAL in 8414,
  URL): present, `format: uri`, references RFC 7591.
- **`scopes_supported`** (RECOMMENDED, array<string>): present, typed as
  `array` of `string`.
- **`response_types_supported`** (REQUIRED, array<string>): present and
  marked required.
- **`response_modes_supported`** (OPTIONAL, array<string>): present.
- **`grant_types_supported`** (OPTIONAL, array<string>): present.
- **`subject_types_supported`** (REQUIRED, array<string>): present, with
  enum `[public, pairwise]` matching OIDC Core §8.
- **`id_token_signing_alg_values_supported`** (REQUIRED, array<string>):
  present.
- **`token_endpoint_auth_methods_supported`** (OPTIONAL, array<string>):
  present, with enum that includes `none, client_secret_basic,
  client_secret_post, client_secret_jwt, private_key_jwt, tls_client_auth,
  self_signed_tls_client_auth` — slightly broader than OIDC Discovery 1.0
  (it lists only the first five) but valid per the IANA OAuth Token
  Endpoint Authentication Methods registry referenced from RFC 8414.
- **`claims_supported`** (RECOMMENDED, array<string>): present.
- **`code_challenge_methods_supported`** (defined in RFC 8414, often
  echoed in OIDC discovery in practice): present with enum `[S256, plain]`.
- **Modern extension fields not in OIDC Discovery 1.0 but valid additions**:
  `introspection_endpoint`, `revocation_endpoint`,
  `device_authorization_endpoint`, `pushed_authorization_request_endpoint`,
  `end_session_endpoint`, `require_pushed_authorization_requests`,
  `dpop_signing_alg_values_supported`,
  `authorization_details_types_supported`. These come from RFC 8414, RFC
  8628, RFC 9126, OIDC Session Management/RP-Initiated Logout, RFC 9449,
  RFC 9396 — all fine to advertise here.

---

## MISSING — must add to the schema

OIDC Discovery 1.0 §3 defines a much larger metadata set than what is in
the current `DiscoveryDocument`. The following fields are entirely absent.

### Encryption / signing algorithm advertisements (OIDC §3)

- **`id_token_encryption_alg_values_supported`** (OPTIONAL, array<string>):
  JWE `alg` values supported by the OP for the ID Token (OIDC Discovery
  1.0 §3).
- **`id_token_encryption_enc_values_supported`** (OPTIONAL, array<string>):
  JWE `enc` values supported for the ID Token (OIDC Discovery 1.0 §3).
- **`userinfo_signing_alg_values_supported`** (OPTIONAL, array<string>):
  JWS `alg` values for the UserInfo Endpoint to encode claims as a JWT.
  `none` MAY be included (OIDC Discovery 1.0 §3).
- **`userinfo_encryption_alg_values_supported`** (OPTIONAL, array<string>):
  JWE `alg` values for the UserInfo Endpoint (OIDC Discovery 1.0 §3).
- **`userinfo_encryption_enc_values_supported`** (OPTIONAL, array<string>):
  JWE `enc` values for the UserInfo Endpoint (OIDC Discovery 1.0 §3).
- **`request_object_signing_alg_values_supported`** (OPTIONAL,
  array<string>): JWS `alg` values for Request Objects (passed by value
  as `request` or by reference as `request_uri`). `none` and `RS256` MAY
  be included (OIDC Discovery 1.0 §3).
- **`request_object_encryption_alg_values_supported`** (OPTIONAL,
  array<string>): JWE `alg` values for Request Objects (OIDC Discovery
  1.0 §3).
- **`request_object_encryption_enc_values_supported`** (OPTIONAL,
  array<string>): JWE `enc` values for Request Objects (OIDC Discovery
  1.0 §3).

### Token endpoint auth signing (OIDC §3, also RFC 8414 §2)

- **`token_endpoint_auth_signing_alg_values_supported`** (OPTIONAL,
  array<string>): JWS `alg` values supported by the token endpoint for
  the JWT used to authenticate the client at the token endpoint for
  `private_key_jwt` and `client_secret_jwt`. **MUST be present if either
  of those authentication methods is advertised** (RFC 8414 §2; OIDC
  Discovery 1.0 §3 has the same wording). The value `none` MUST NOT be
  used.

### UI / display / locales (OIDC §3)

- **`display_values_supported`** (OPTIONAL, array<string>): values
  supported for the OIDC `display` request parameter (OIDC Core §3.1.2.1).
  Defined values are `page`, `popup`, `touch`, `wap` (OIDC Discovery 1.0
  §3).
- **`claim_types_supported`** (OPTIONAL, array<string>): claim types the
  OP supports. Values defined by OIDC Core: `normal`, `aggregated`,
  `distributed`. If omitted, the default is `["normal"]` (OIDC Discovery
  1.0 §3).
- **`claims_locales_supported`** (OPTIONAL, array<string>): BCP 47
  language tag values that the OP supports for representing claims in
  responses (OIDC Discovery 1.0 §3).
- **`ui_locales_supported`** (OPTIONAL, array<string>): BCP 47 language
  tag values supported for the user interface (OIDC Discovery 1.0 §3 —
  also defined in RFC 8414 §2).

### Capability flags (OIDC §3)

- **`claims_parameter_supported`** (OPTIONAL, boolean, default `false`):
  whether the OP supports use of the OIDC `claims` request parameter
  (OIDC Discovery 1.0 §3).
- **`request_parameter_supported`** (OPTIONAL, boolean, default `false`):
  whether the OP supports use of the `request` request parameter (Request
  Objects passed by value) (OIDC Discovery 1.0 §3).
- **`request_uri_parameter_supported`** (OPTIONAL, boolean, default
  `true`): whether the OP supports use of the `request_uri` request
  parameter (Request Objects passed by reference) (OIDC Discovery 1.0 §3).
- **`require_request_uri_registration`** (OPTIONAL, boolean, default
  `false`): whether the OP requires any `request_uri` values used to be
  pre-registered using the `request_uris` registration parameter (OIDC
  Discovery 1.0 §3).

### ACR

- **`acr_values_supported`** (OPTIONAL, array<string>): the Authentication
  Context Class References that this OP supports (OIDC Discovery 1.0 §3).
  Currently absent from the spec even though `acr_values` is supported as
  a request parameter on `/authorize`.

### Documentation / policy URLs (OIDC §3, also RFC 8414 §2)

- **`service_documentation`** (OPTIONAL, URL): URL of human-readable
  developer documentation for using the OP (OIDC Discovery 1.0 §3 — also
  RFC 8414 §2).
- **`op_policy_uri`** (OPTIONAL, URL): URL of OP's privacy/data-use policy
  for clients (OIDC Discovery 1.0 §3 — also RFC 8414 §2).
- **`op_tos_uri`** (OPTIONAL, URL): URL of OP's terms of service for
  clients (OIDC Discovery 1.0 §3 — also RFC 8414 §2).

### Revocation/introspection auth advertisements (RFC 8414 §2)

The schema lists `revocation_endpoint` and `introspection_endpoint` but
omits the corresponding auth-method/signing-alg advertisements that
RFC 8414 §2 defines:

- **`revocation_endpoint_auth_methods_supported`** (OPTIONAL,
  array<string>) (RFC 8414 §2).
- **`revocation_endpoint_auth_signing_alg_values_supported`** (OPTIONAL,
  array<string>) — MUST be present if `private_key_jwt` or
  `client_secret_jwt` is advertised in the revocation auth methods (RFC
  8414 §2).
- **`introspection_endpoint_auth_methods_supported`** (OPTIONAL,
  array<string>) (RFC 8414 §2).
- **`introspection_endpoint_auth_signing_alg_values_supported`**
  (OPTIONAL, array<string>) — same MUST-be-present rule as above (RFC
  8414 §2).

### Signed metadata (RFC 8414 §2.1)

- **`signed_metadata`** (OPTIONAL, string — JWS compact serialization):
  a JWT containing metadata claims about the authorization server,
  taking precedence over plain JSON values for consumers that support
  this feature (RFC 8414 §2.1).

### Path semantics for non-empty issuer paths (OIDC Discovery §4)

- The audited spec models only the path
  `/.well-known/openid-configuration` (no leading issuer path). OIDC
  Discovery 1.0 §4 specifies that for an issuer with a path component
  (e.g. `https://example.com/issuer1`), the discovery URL is
  `https://example.com/issuer1/.well-known/openid-configuration` (the
  well-known suffix is **appended** to the issuer URL — note that
  RFC 8414 §3 differs and **inserts** between host and path). OpenAPI 3.1
  cannot model both placements simultaneously, but a description note on
  the path operation explaining the OIDC append-rule (and the RFC 8414
  insert-rule for the sibling path) should be added.

### Cache / response headers (OIDC Discovery §4.2)

- The 200 response on `/.well-known/openid-configuration` is documented
  with no cache directives. OIDC Discovery 1.0 §4.2 says the response
  SHOULD be cacheable (and OPs commonly emit `Cache-Control: max-age=...`).
  Add a `Cache-Control` response header to the operation.

---

## WRONG — must fix

- **`required` list excludes `jwks_uri` and `subject_types_supported`
  and `id_token_signing_alg_values_supported`** (OIDC Discovery 1.0 §3).
  The schema's `required` list is
  `[issuer, authorization_endpoint, token_endpoint, response_types_supported]`.
  OIDC Discovery 1.0 §3 marks the following as REQUIRED for an OP:
  `issuer`, `authorization_endpoint`, `token_endpoint` (unless only
  Implicit), `jwks_uri`, `response_types_supported`,
  `subject_types_supported`, `id_token_signing_alg_values_supported`.
  Three of those are missing from `required`. Because the schema is
  shared with RFC 8414 (which has fewer required fields), this needs to
  be split — see also "NICE-TO-HAVE: split into two schemas" below.

- **`userinfo_endpoint` description "required if the provider supports
  it"** (OIDC Discovery 1.0 §3): the actual normative wording is
  RECOMMENDED, not REQUIRED. Replace the description with "RECOMMENDED.
  URL of the OP's UserInfo Endpoint (OIDC Core §5.3). MUST use the https
  scheme and MAY contain port, path, and query components."

- **`token_endpoint` requiredness comment** (OIDC Discovery 1.0 §3): the
  spec states "REQUIRED unless only the Implicit Flow is used." The
  audited spec marks it unconditionally `required`, which is fine
  operationally for OAuth 2.1 (Implicit excluded), but the description
  should call out the original conditional rule for accurate cross-spec
  documentation.

- **`response_types_supported` description missing OIDC requirement**
  (OIDC Discovery 1.0 §3): "Dynamic OpenID Providers MUST support the
  `code`, `id_token`, and `token id_token` Response Type values."
  Description currently empty — add this normative note.

- **`response_modes_supported` default value not documented** (OIDC
  Discovery 1.0 §3 / RFC 8414 §2): "If omitted, the default is
  `["query", "fragment"]`." Add to description.

- **`grant_types_supported` default value not documented** (OIDC
  Discovery 1.0 §3 / RFC 8414 §2): "If omitted, the default value is
  `["authorization_code", "implicit"]`." Add to description.

- **`token_endpoint_auth_methods_supported` default value not documented**
  (OIDC Discovery 1.0 §3 / RFC 8414 §2): "If omitted, the default is
  `client_secret_basic`." Add to description.

- **`subject_types_supported` cross-reference missing** (OIDC Core §8 /
  OIDC Discovery 1.0 §3): description is empty. Add the meanings of
  `public` (same `sub` to all clients) and `pairwise` (per-client
  pseudonymous `sub`).

- **`code_challenge_methods_supported` source mis-attributed**: the field
  itself is RFC 8414 §2 (introduced by RFC 8414, not OIDC Discovery 1.0).
  Acceptable in a shared schema, but the description should cite RFC 8414
  / RFC 7636 §4.3 explicitly. Currently no description at all.

- **`issuer` `https`-only rule not enforced/documented** (OIDC Discovery
  1.0 §3 / RFC 8414 §2): "REQUIRED. URL using the `https` scheme... no
  query or fragment components." `format: uri` does not constrain to
  https or forbid query/fragment. Either add a `pattern`
  (`^https://[^?#]+$`) or strengthen the description.

- **`jwks_uri` `https`-only rule not documented** (OIDC Discovery 1.0 §3
  / RFC 8414 §2): "This URL MUST use the `https` scheme." Same fix as
  `issuer`.

---

## NICE-TO-HAVE

- **Split `DiscoveryDocument` into two schemas**: `OIDCDiscoveryDocument`
  (with the seven OIDC-required fields and the OIDC-only `*_supported`
  values) `allOf`-extending an `OAuthAuthorizationServerMetadata` base
  (RFC 8414 fields). The current single shared schema cannot accurately
  capture the differing `required` lists between the two well-known
  endpoints.

- **Add a JSON example body** to the 200 response on
  `/.well-known/openid-configuration`. RFC 8414 §3.2 has a non-normative
  example response that could be reused.

- **Document the OIDC `claims` parameter** alongside
  `claims_parameter_supported`. The spec doesn't currently expose a
  `claims` query parameter on `/authorize` — adding the metadata flag
  invites the question of why the request parameter isn't modeled.

- **Clarify well-known path discovery in the operation description** to
  note that the actual endpoint URL on a multi-tenant OP may include a
  path between the well-known suffix and the issuer's path component
  (RFC 8414 §3) or after it (OIDC Discovery 1.0 §4) — these two
  algorithms differ.

- **Add `display_values_supported` enum** when the field is added:
  `[page, popup, touch, wap]` per OIDC Core §3.1.2.1.

- **Add `claim_types_supported` enum** when the field is added:
  `[normal, aggregated, distributed]` per OIDC Core §5.6.

---

## NOT APPLICABLE

- **OIDC Discovery 1.0 §2 (Provider Issuer Discovery via WebFinger)**:
  WebFinger-based OP discovery (RFC 7033) is not an HTTP surface of the
  authorization server itself — it lives on the user's e-mail/account
  domain. Not modelable as part of the AS OpenAPI.
- **OIDC Discovery 1.0 §5 (String Operations)**: equality semantics
  (no Unicode normalization) are a client implementation rule, not a
  schema concern.
- **OIDC Discovery 1.0 §6 (Implementation Considerations)** and §7
  (Security Considerations): operational guidance, not schema-level.
- **OIDC Discovery 1.0 §8 (IANA Considerations)**: registry
  housekeeping, not protocol surface.
