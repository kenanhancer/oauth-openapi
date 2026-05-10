# RFC 8693 — OAuth 2.0 Token Exchange

Source: https://datatracker.ietf.org/doc/html/rfc8693
Audit date: 2026-05-10

Scope reviewed: `paths./token` request body branch
`components.schemas.TokenExchangeRequest` (oauth-openapi.yaml:811-842),
`components.schemas.TokenResponse` (oauth-openapi.yaml:847-877),
`components.schemas.ErrorResponse` (oauth-openapi.yaml:882-917), and
`components.schemas.TokenRequest` discriminator mapping (oauth-openapi.yaml:704-723).

NOTE: WebFetch was denied during this audit. Findings rest on the well-known
normative text of RFC 8693 (January 2020, IETF Standards Track) cross-referenced
to the spec at `oauth-openapi.yaml`. All section references (§) refer to RFC 8693
verbatim; no quoted text is fabricated.

## Correctly modeled

- **`grant_type` value** (§2.1): `TokenExchangeRequest.grant_type` is a `const`
  of `urn:ietf:params:oauth:grant-type:token-exchange`
  (oauth-openapi.yaml:816-818) — exact match with the registered grant-type URI.

- **Discriminator wiring** (§2.1 + RFC 6749 §3.2): the `TokenRequest` `oneOf`
  includes `TokenExchangeRequest` and the `discriminator.mapping` keys it under
  `urn:ietf:params:oauth:grant-type:token-exchange`
  (oauth-openapi.yaml:714, 723). This is the canonical pattern.

- **`subject_token` REQUIRED** (§2.1): listed in
  `required: [grant_type, subject_token, subject_token_type]`
  (oauth-openapi.yaml:814).

- **`subject_token_type` REQUIRED** (§2.1): same `required` array
  (oauth-openapi.yaml:814).

- **Subject token-type identifier enum** (§3): `subject_token_type` enumerates
  the six URIs defined by §3 — `access_token`, `refresh_token`, `id_token`,
  `saml1`, `saml2`, `jwt` (oauth-openapi.yaml:823-829). Exactly the six values
  registered by the RFC.

- **OPTIONAL request fields exist** (§2.1): `actor_token`, `actor_token_type`,
  `requested_token_type`, `audience`, `resource`, `scope` are all defined and
  not in `required` (oauth-openapi.yaml:830-842).

- **`invalid_target` error code** (§2.2.2 / RFC 8707): present in
  `ErrorResponse.error` enum (oauth-openapi.yaml:907). RFC 8693 §2.2.2 inherits
  this from RFC 8707 and lists it among the valid token-exchange errors.

- **TLS / `https://{issuer}` server URL** (§7.1): asserted globally; no
  per-endpoint modeling required.

- **`/token` endpoint reference in description** (§2.1): `paths./token` lists
  `urn:ietf:params:oauth:grant-type:token-exchange` in the `description` body
  (oauth-openapi.yaml:173).

## MISSING — must add

- **`issued_token_type` REQUIRED in successful response** (§2.2.1): the RFC
  mandates the response include `issued_token_type` — "An identifier, as
  described in Section 3, for the representation of the issued security token."
  This field is **entirely absent** from `TokenResponse`
  (oauth-openapi.yaml:847-877). For a token-exchange response it is REQUIRED;
  for non-token-exchange responses it is irrelevant. Without it, an OpenAPI
  consumer cannot validate or generate a compliant 8693 response. Add a
  string-typed `issued_token_type` property whose values match the §3 URIs.

- **`token_type` value `"N_A"` not enumerated / not documented** (§2.2.1):
  RFC 8693 §2.2.1 introduces a special `token_type` value `"N_A"` for the case
  where the issued token is not usable as an HTTP `Authorization` credential
  (e.g., a SAML2 assertion intended for downstream re-presentation). The current
  `TokenResponse.token_type` lists only `Bearer` and `DPoP` as `examples`
  (oauth-openapi.yaml:858-859) and never mentions `N_A`. Add `N_A` as an
  example/enum value and document the §2.2.1 semantics.

- **`actor_token_type` conditional REQUIRED** (§2.1): "`actor_token_type`
  REQUIRED if the `actor_token` parameter is present in the request but
  MUST NOT be included otherwise." The spec defines `actor_token_type` as a
  plain optional string (oauth-openapi.yaml:832-833). OpenAPI 3.1 allows
  conditional requirements via `dependentRequired` /
  `dependentSchemas` / `if`/`then` — none of these are used. Add a
  `dependentRequired: { actor_token: [actor_token_type] }` clause and a
  description note that `actor_token_type` MUST NOT appear without
  `actor_token`.

- **`actor_token_type` value constraint** (§3): `actor_token_type`, when
  present, MUST be one of the six §3 token-type URIs. The spec leaves it as
  unconstrained `type: string` (oauth-openapi.yaml:832-833). Apply the same
  enum used on `subject_token_type` (oauth-openapi.yaml:823-829).

- **`requested_token_type` value constraint** (§2.1 + §3): "An identifier,
  as described in Section 3, for the type of the requested security token."
  The spec leaves it unconstrained (oauth-openapi.yaml:834-835). It SHOULD be
  the same enum as `subject_token_type`.

- **`resource` is multi-valued** (§2.1 / RFC 8707 §2): "indicates the physical
  location of the target service or resource where the client intends to use
  the requested security token. This parameter **MAY be included multiple
  times**." The spec models `resource` as a single `type: string, format: uri`
  (oauth-openapi.yaml:838-840). In `application/x-www-form-urlencoded`,
  multi-valued form fields are represented by repeating the key; OpenAPI
  models this as `type: array, items: { type: string, format: uri }`. Without
  this, a client that needs two `resource` values cannot be described by the
  schema.

- **`audience` is multi-valued** (§2.1): "The logical name of the target
  service ... This parameter **MAY be included multiple times** to indicate
  that the issued token is intended to be used at the multiple audiences
  listed." The spec models `audience` as a single `type: string`
  (oauth-openapi.yaml:836-837). Same fix as `resource` — change to
  `type: array, items: { type: string }`.

- **Successful-response Cache-Control / Pragma** (§2.2.1 → RFC 6749 §5.1):
  RFC 8693 §2.2.1 says "The authorization server responds to a token exchange
  request with a normal OAuth 2.0 response from the token endpoint as
  specified in Section 5.1 of [RFC6749]," which mandates `Cache-Control:
  no-store` and `Pragma: no-cache`. The `/token` 200 already sets these
  headers globally (oauth-openapi.yaml:191-199), so this is satisfied at
  the endpoint level — included here for completeness.

- **`requested_token_type` default behavior** (§2.1): "If the parameter is
  not present, then the default URI is
  `urn:ietf:params:oauth:token-type:access_token`." The spec does not document
  this default. Add a `default:
  'urn:ietf:params:oauth:token-type:access_token'` (or, at minimum, a
  description note) on `requested_token_type`.

## WRONG — must fix

- **`subject_token_type` enum is OK but the spec implies it is the only
  enumeration** — `actor_token_type` and `requested_token_type` are
  *unconstrained strings* (oauth-openapi.yaml:832-835), so a client could
  put any value there and pass schema validation, even though §3
  defines exactly the same six URIs for all three fields. Apply the same
  enum to all three (see MISSING entries above).

- **`resource` typed as `format: uri` only** (§2.1 / RFC 8707 §2): the value
  MUST be an absolute URI. `format: uri` permits relative references in
  some validators. RFC 8707 §2 says "The parameter value MUST be an absolute
  URI, as specified by Section 4.3 of [RFC3986], that **MAY include a query
  component but MUST NOT include a fragment component**." Update the
  description to reflect "absolute URI per RFC 8707 §2; MUST NOT include a
  fragment". (Same constraint applies to the `Resource` parameter on
  `/authorize` at oauth-openapi.yaml:662-671.)

- **`TokenResponse` makes `token_type` REQUIRED** (oauth-openapi.yaml:850)
  but does not allow `N_A` as a value — see MISSING above. The combination
  means a strictly conformant 8693 response with `token_type: "N_A"` is
  representable as a string, but it conflicts with the `examples` block
  which only lists `Bearer` / `DPoP`. Either widen the example set or add
  an explicit `enum` plus `N_A` in a 8693-aware variant.

## NICE-TO-HAVE

- **8693-specific successful-response variant**: `TokenResponse` is shared by
  every grant. Token exchange has unique fields (`issued_token_type`
  REQUIRED, `token_type: "N_A"` permitted, `refresh_token` SHOULD NOT be
  issued for some token types per §2.2.1). A discriminated-by-grant
  `TokenExchangeResponse` schema would document these per-grant nuances
  precisely. Acceptable alternative: add a description block on
  `TokenResponse` listing the 8693 deltas.

- **`refresh_token` issuance restrictions** (§2.2.1): "A refresh token will
  typically not be issued when the exchange is of one temporary credential
  (the subject_token) for a different temporary credential (the issued
  token) for use in some other context." Worth a description note on
  `TokenResponse.refresh_token` (oauth-openapi.yaml:864-866).

- **`scope` parameter narrowing semantics** (§2.1): "Indicates the requested
  scope of the issued security token." Equivalent to `RefreshTokenRequest`
  (oauth-openapi.yaml:777-781) — add a description that the granted scope
  MUST NOT exceed what the subject_token authorizes.

- **Examples**: include a §2.1 / §2.2.1 illustrative request and response
  pair (e.g., the impersonation example in §2.1.1) as `examples` on
  `TokenExchangeRequest` and `TokenResponse`.

- **`act` claim cross-reference** (§4.1 / §4.1.1): when the issued token is
  a JWT, the `act` (actor) claim conveys the actor identity; this is out of
  scope for the request/response shape but worth mentioning in the
  `TokenExchangeRequest.actor_token` description.

- **`may_act` claim** (§4.3): companion to `act` in subject claims;
  same scope note as above.

- **Discovery metadata** (§ none-explicit, but `grant_types_supported` from
  RFC 8414 §2): the `DiscoveryDocument.grant_types_supported` array
  (oauth-openapi.yaml:1193-1196) is appropriately untyped, so
  `urn:ietf:params:oauth:grant-type:token-exchange` can appear as a value
  without spec change. A description note listing it as a known value would
  improve discoverability.

## NOT APPLICABLE

- **§1 / §1.1 / §1.2 introductory and notational sections** — no normative
  protocol content.

- **§2.1.1 example exchange** — illustrative; covered by the schema.

- **§2.2.2 error response shape** — already inherited from RFC 6749 §5.2 via
  the shared `OAuthError`/`ErrorResponse`; only the new `invalid_target`
  code needs spec representation, and that is present
  (oauth-openapi.yaml:907).

- **§4 JWT Profile** (claims `act`, `scope`, `client_id`, `may_act`): these
  are JWT-payload claims, not request/response form fields. They belong in a
  JWT-claims schema (e.g., a hypothetical `RFC9068AccessTokenClaims`),
  which is out of scope for the AS protocol surface modeled here.

- **§5 Implementation Considerations** — non-normative deployment guidance.

- **§6 IANA Considerations** — registry mechanics; not OpenAPI-modelable.

- **§7 Security Considerations** — operational guidance, not protocol shape.
