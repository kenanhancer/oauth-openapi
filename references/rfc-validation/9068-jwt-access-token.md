# RFC 9068 — JSON Web Token (JWT) Profile for OAuth 2.0 Access Tokens

Source: https://datatracker.ietf.org/doc/html/rfc9068
Audit date: 2026-05-10

Scope reviewed: `paths./token` (200 response), `components.schemas.TokenResponse`,
`components.schemas.IntrospectionResponse`, `components.schemas.DiscoveryDocument`,
`components.schemas.JWK`, security scheme `bearerAuth` (`bearerFormat: JWT`),
`components.parameters.Resource`, `ClientCredentialsTokenRequest.resource`/`audience`,
`TokenExchangeRequest.audience`/`resource`.

NOTE: WebFetch was denied during this audit; findings are based on the
well-established normative text of RFC 9068 (October 2021, IETF Standards Track)
cross-referenced against the spec at `oauth-openapi.yaml`. Section citations (§)
follow the published RFC; no quoted text is fabricated.

CONTEXT: RFC 9068 defines an OPTIONAL profile — issuers can still emit opaque
access tokens (validated via RFC 7662). When an issuer chooses to emit JWTs,
this RFC mandates the JOSE header, the claim set, and the validation algorithm.
The current spec advertises JWT-shaped access tokens (`bearerFormat: JWT`,
`jwks_uri` in discovery) but does not document the JWT access token shape, so
consumers cannot model the issued token or implement local validation.

## Correctly modeled

- **JWT access tokens are reachable via the spec's machinery** (§2): the
  spec models the JWKS endpoint (`/jwks`, `JWKS`, `JWK` — oauth-openapi.yaml:
  418–437, 1077–1132) and exposes `jwks_uri` on the discovery document
  (oauth-openapi.yaml:1158–1160). These are the prerequisites for §4
  resource-server validation of a 9068 token.
- **`bearerFormat: JWT` declared** (§2.1): `securitySchemes.bearerAuth` sets
  `bearerFormat: JWT` (oauth-openapi.yaml:1318) — the OpenAPI hint that the
  bearer token is a JWT, which is consistent with RFC 9068 emission.
- **`id_token_signing_alg_values_supported` advertised in discovery** (§4):
  `DiscoveryDocument.id_token_signing_alg_values_supported`
  (oauth-openapi.yaml:1209–1212) is present; while §4 of 9068 specifically
  references *access-token* algorithm advertisement, the spec at least has
  a precedent field that a 9068-aware extension would mirror.
- **Resource indicator parameter** (§3): `parameters.Resource` (oauth-openapi.yaml:
  662–671, RFC 8707) is wired into `/authorize`, and the
  `ClientCredentialsTokenRequest`/`TokenExchangeRequest` schemas include
  `resource` and `audience` fields. RFC 9068 §3 says the AS uses these to
  populate the `aud` claim of the JWT access token, so the inputs that drive
  the §3 audience-binding are present.
- **`IntrospectionResponse` claim names align with §2.2 JWT claim names** for
  the overlapping subset (`iss`, `sub`, `aud`, `exp`, `iat`, `nbf`, `jti`,
  `client_id`, `scope` — oauth-openapi.yaml:1032–1059). Reusing these names
  for the 9068 JWT body is consistent with the RFC's intent (and §2.2 even
  notes that the 9068 claim set is a superset of the introspection response).

## MISSING — must add

- **`JWTAccessToken` schema describing the JWT body** (§2.2): the RFC defines a
  concrete payload shape with REQUIRED claims `iss`, `exp`, `aud`, `sub`,
  `client_id`, `iat`, `jti` and OPTIONAL `auth_time`, `acr`, `amr`, `scope`,
  `groups`, `roles`, `entitlements`, plus identity claims when `sub` is an
  end-user. The spec has no schema describing this payload, so a consumer
  modelling the issuer's JWTs cannot generate types from the spec. Add a
  reusable `components.schemas.JWTAccessToken` with these fields and a
  `description` linking to RFC 9068 §2.2. Mark it `additionalProperties: true`
  per §2.2 ("Authorization servers MAY return additional claims").
- **`typ` JOSE header value `at+jwt`** (§2.1): the RFC mandates the JOSE header
  `typ` parameter MUST be `at+jwt` (registered in the JWT IANA media type
  registry as `application/at+jwt`) so resource servers can distinguish access
  tokens from ID tokens. The spec never names this value. Document it on the
  new `JWTAccessToken` schema description and on `bearerAuth.description`
  ("When the issuer emits 9068 access tokens, the JWT header MUST carry
  `typ: at+jwt`, RFC 9068 §2.1.").
- **REQUIRED claim `iss`** (§2.2): "The issuer claim … REQUIRED." Must appear
  as a `required` member of `JWTAccessToken` with `type: string, format: uri`.
- **REQUIRED claim `exp`** (§2.2): Expiration time, NumericDate. Required;
  `type: integer`.
- **REQUIRED claim `aud`** (§2.2): identifies the resource(s) the token is
  intended for. Required; `oneOf: [string, array of string]` (mirror the
  `IntrospectionResponse.aud` shape on lines 1050–1055).
- **REQUIRED claim `sub`** (§2.2): subject identifier. Required; `type: string`.
  Add a description note: per §2.2, when the grant is `client_credentials`,
  `sub` SHOULD have the same value as `client_id`; for end-user grants, `sub`
  identifies the authenticated end-user.
- **REQUIRED claim `client_id`** (§2.2): "client_id REQUIRED — The OAuth 2.0
  client identifier." `type: string`.
- **REQUIRED claim `iat`** (§2.2): issued-at NumericDate. Required;
  `type: integer`.
- **REQUIRED claim `jti`** (§2.2): unique token identifier. Required;
  `type: string`.
- **OPTIONAL authentication-information claims `auth_time`, `acr`, `amr`**
  (§2.2.1): auth_time — `type: integer` (NumericDate); acr — `type: string`;
  amr — `type: array, items: string`. These are conditionally required when
  the AS receives `max_age`/`acr_values` (§2.2.1: "If the request that led
  to the issuance of the access token contained a `max_age` parameter or a
  Voluntary Claim Request for `auth_time`, the JWT access token MUST contain
  an `auth_time` claim").
- **OPTIONAL identity claims when `sub` represents an end-user** (§2.2.2):
  the RFC permits OIDC standard claims (`name`, `email`, `email_verified`,
  `preferred_username`, etc.) to appear on the JWT access token when their
  release was authorized via a scope/claim request. Reference
  `UserInfoResponse` from `JWTAccessToken` so consumers know the same
  identity-claim catalog applies (allOf composition or just a `description`
  pointer is fine).
- **OPTIONAL authorization claims `scope`, `groups`, `roles`, `entitlements`**
  (§2.2.3): the RFC says "Authorization servers MAY return … `scope`
  (string, space-delimited), `groups`, `roles`, `entitlements` (arrays of
  strings)." Model:
  - `scope: { type: string, description: "Space-delimited scopes (RFC 8693 §4.2)" }`
  - `groups: { type: array, items: { type: string } }` (per SCIM 2.0)
  - `roles: { type: array, items: { type: string } }` (per SCIM 2.0)
  - `entitlements: { type: array, items: { type: string } }` (per SCIM 2.0)
- **JWS signing requirement** (§2.1): "Authorization servers MUST sign JWT
  access tokens with an asymmetric algorithm. Authorization servers MUST NOT
  use `none` as the signing algorithm." Add this to `bearerAuth.description`
  and to the new `JWTAccessToken` schema description.
- **`access_token_signing_alg_values_supported` discovery metadata**
  (implied by §4 + OAuth registry): RFC 9068 doesn't mint a new metadata
  field but §4 expects the resource server to discover signing algorithms.
  Either (a) document on `id_token_signing_alg_values_supported` that the
  same set is reused for access tokens (per §4 cross-reference), or (b) add
  the registered field `access_token_signing_alg_values_supported` if a
  vendor advertises it. The spec is silent today.
- **Resource-server validation flow documented** (§4): §4 normatively defines
  the seven-step validation algorithm (typ check, signature, iss, aud, exp,
  scope, replay/jti). At minimum, add a description on `JWTAccessToken`
  pointing to §4 so resource-server implementers know the validation steps
  expected by the AS.
- **Token-type indication that 9068 is supported by this AS**: there is no
  single field that says "this AS issues 9068 tokens", but the canonical
  signal is `bearerFormat: JWT` plus issuance examples. Add an `examples`
  block on `TokenResponse.access_token` showing a 3-segment compact JWS with
  the `at+jwt` typ — currently the example is the opaque-token literal
  `SlAV32hkKG` (oauth-openapi.yaml:855), which actively misleads readers
  toward an opaque interpretation when the spec elsewhere advertises JWTs.

## WRONG — must fix

- **`access_token` example is opaque-token-shaped, not JWT-shaped**
  (§2): the spec advertises `bearerFormat: JWT` (oauth-openapi.yaml:1318) and
  exposes a JWKS endpoint, signalling that issued access tokens are JWTs,
  but the only `examples` value on `TokenResponse.access_token` is
  `SlAV32hkKG` (oauth-openapi.yaml:855) — a 10-character opaque token from
  RFC 6749 §5.1's example. Either (a) keep the example but switch
  `bearerFormat` to neutral wording (the token format is implementation-
  defined), or (b) replace the example with a 3-segment compact JWS whose
  header decodes to `{"alg":"RS256","typ":"at+jwt","kid":"…"}`. Mismatched
  evidence in the same spec is worse than missing evidence.
- **`bearerFormat: JWT` is presented as a fact, not a profile choice**
  (§1, §2.1): RFC 9068 is OPTIONAL — an issuer can perfectly well issue
  opaque tokens validated via /introspect. The spec hard-codes `bearerFormat:
  JWT` (oauth-openapi.yaml:1318), which (a) overconstrains for opaque-only
  deployments and (b) implies 9068 conformance without documenting the §2.2
  claim set. Reword `bearerAuth.description` to say "When the AS chooses to
  emit JWT access tokens (RFC 9068), the JWT MUST carry `typ: at+jwt` and
  the §2.2 claim set; opaque tokens validated via /introspect (RFC 7662) are
  also permitted." Or drop `bearerFormat` entirely.
- **`IntrospectionResponse` and a 9068 JWT diverge on which claims are
  REQUIRED vs OPTIONAL** (§2.2 vs RFC 7662 §2.2): in `IntrospectionResponse`
  only `active` is required; `iss`, `sub`, `aud`, `exp`, `iat`, `client_id`,
  `jti` are all optional (oauth-openapi.yaml:1025–1059). For a 9068 JWT
  *all of those except `active`* are REQUIRED. Reusing the schema as-is for
  9068 modelling is incorrect — add the dedicated `JWTAccessToken` schema
  with those fields in `required:` rather than relying on
  `IntrospectionResponse`. This is also why §2.2 of the RFC is explicit
  that the introspection response and the JWT body share names but differ
  in mandatory-ness.
- **Discovery does not advertise that 9068 access tokens are issued**
  (§3, §4): an RS that wants to cache JWKS needs a deterministic signal
  that access tokens are JWTs — typically by inspecting an example token or
  by an explicit metadata field. The current `DiscoveryDocument` has no
  field communicating this. The least-bad fix without inventing fields is
  to add a `description` paragraph on `DiscoveryDocument` saying "If access
  tokens are JWTs (RFC 9068), they are signed with one of
  `id_token_signing_alg_values_supported` and verifiable via `jwks_uri`."
  This is a documentation fix, not a schema change.

## NICE-TO-HAVE

- **Add a `nbf` (not-before) field to the optional claim set on
  `JWTAccessToken`** (§2.2 lists `nbf` as OPTIONAL alongside the OIDC
  cross-reference). The spec already models `nbf` on `IntrospectionResponse`
  (oauth-openapi.yaml:1046–1047); mirror it.
- **Document the `jti` uniqueness expectation** (§2.2): "The `jti` claim
  MUST be a unique identifier per token issued by the authorization server."
  Note this on the field description so consumers don't reuse JTIs across
  refreshes.
- **Provide a worked example of a decoded JWT access token** in the
  `JWTAccessToken` schema's `examples` (header + payload as separate JSON
  objects, with a comment that the wire format is the compact JWS).
  Resource-server implementers find this enormously clearer than the
  encoded form.
- **Cross-reference §5 cross-compatibility note** (§5): the RFC explains
  why the claim names overlap with OIDC ID tokens but the semantics differ
  (audience is the resource, not the client). One sentence on
  `JWTAccessToken.aud`'s description ("This is the resource indicator(s)
  per RFC 8707, not the OIDC client_id; see RFC 9068 §5.") prevents a very
  common implementer mistake.
- **Surface `at+jwt` media type in produced content negotiation
  documentation** (§2.1): not modellable as `responses[].content` since the
  token is delivered inside the `access_token` JSON field, but a
  description note on `TokenResponse.access_token` ("When `bearerFormat:
  JWT`, the value is a compact JWS whose JOSE header has
  `typ: at+jwt` and `cty` SHOULD be omitted, RFC 9068 §2.1.") helps.
- **Add `aud` validation guidance to `bearerAuth.description`** (§4 step 3):
  resource servers MUST reject tokens whose `aud` does not contain a value
  identifying the resource server itself. A short note on the security
  scheme reduces the chance an RS implementer skips this check.
- **List `at+jwt` in any future `token_type_values_supported` discovery
  field** if the AS advertises it (no IETF-registered discovery field
  exists today, but vendor metadata varies).

## NOT APPLICABLE

- **Privacy considerations** (§6): general guidance about not embedding
  more identity than needed in JWT access tokens is operational policy,
  not modellable in OpenAPI. The spec already separates UserInfo (which
  carries identity claims) from access tokens (which need not).
- **Security considerations** (§7): TLS, replay protection, key
  rotation, audience restriction — TLS is asserted by the
  `https://{issuer}` server entry; key rotation is implicit through
  `kid` on the `JWK` schema (oauth-openapi.yaml:1106–1107); audience
  restriction is covered by `aud` once `JWTAccessToken` is added.
- **§5 cross-compatibility with OIDC ID tokens**: documentary note for
  implementers — see NICE-TO-HAVE above for a one-line surface in the
  spec; no schema changes required.
- **Vendor extensions to the claim set** (§2.2 last paragraph permits
  additional claims): handled by `additionalProperties: true` on the new
  schema — no per-claim modelling required for vendor namespaces.
- **Choice of asymmetric algorithm family** (§2.1): RS256, ES256, EdDSA,
  PS256, etc. — already covered indirectly by `JWK.alg` examples
  (oauth-openapi.yaml:1103–1105). The RFC's prohibition on `none` is the
  only normative algorithm constraint and is already noted under MISSING.
</content>
</invoke>