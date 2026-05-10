# RFC 8707 — Resource Indicators for OAuth 2.0

Source: https://datatracker.ietf.org/doc/html/rfc8707
Audit date: 2026-05-10

Scope reviewed: `paths./authorize` (`Resource` parameter), `paths./token`
(`TokenRequest` discriminated union and all six grant-type schemas),
`paths./device_authorization` (`DeviceAuthorizationRequest`), `paths./par`
(`PARRequest`), `components.schemas.ErrorResponse` (`error` enum),
`components.schemas.IntrospectionResponse` (`aud` claim), `components.schemas.DiscoveryDocument`.

> Note: WebFetch was denied at the start of this audit. The RFC text was
> retrieved via `curl https://www.rfc-editor.org/rfc/rfc8707.txt` and stored
> at `.rfc8707-source.txt` alongside this report; all section (§) citations
> are taken verbatim from that text.

## Correctly modeled

- **`resource` query parameter on `/authorize`** (§2, §2.1): the `Resource`
  reusable parameter is declared with `in: query`, `required: false`,
  `format: uri`, and a one-line description naming RFC 8707
  (oauth-openapi.yaml:662–671), and it is referenced from the `/authorize`
  parameter list (oauth-openapi.yaml:133). This satisfies the §2 statement
  "a client MAY indicate the protected resource ... by including the
  following parameter in the request" and §2.1's authorization-request
  binding.
- **`resource` form field on the client-credentials grant** (§2, §2.2):
  `ClientCredentialsTokenRequest.resource` is `type: string, format: uri`
  with a description tagging RFC 8707 (oauth-openapi.yaml:760–763).
- **`resource` form field on the token-exchange request** (§2, §2.2):
  `TokenExchangeRequest.resource` is `type: string, format: uri`
  (oauth-openapi.yaml:838–840). RFC 8693 §2.1 explicitly imports the RFC 8707
  semantics, so this is the correct place for it.
- **`invalid_target` error code** (§2, §5.2): the central `ErrorResponse.error`
  enum lists `invalid_target` with the comment `# RFC 8707`
  (oauth-openapi.yaml:907). This satisfies the §5.2 IANA OAuth Extensions
  Error Registry entry whose "Error usage location" is "implicit grant
  error response, token error response".
- **`aud` claim modeled on introspection** (§2 final paragraph): the §2 text
  says "Audience restrictions can be communicated ... [in] the top-level
  member of the same name [`aud`] [in] a Token Introspection [RFC7662]
  response." `IntrospectionResponse.aud` is modeled as
  `oneOf: [string, array<string>]` (oauth-openapi.yaml:1050–1055), matching
  RFC 7662 §2.2 / RFC 7519 §4.1.3 cardinality.
- **Resource value as a URI** (§2): `format: uri` is set on every place the
  spec exposes `resource` (the `/authorize` parameter, the
  `ClientCredentialsTokenRequest`, and the `TokenExchangeRequest`),
  reflecting "Its value MUST be an absolute URI, as specified by Section 4.3
  of [RFC3986]".

## MISSING — must add

- **`resource` MUST be allowed on every grant type at `/token`** (§2, §2.2):
  RFC 8707 §2.2 opens with "When the `resource` parameter is used on an
  access token request made to the token endpoint, **for all grant types**,
  it indicates the target service or protected resource ...". The spec
  currently puts `resource` on only two of the six grant-type schemas
  (`ClientCredentialsTokenRequest` line 760, `TokenExchangeRequest` line 838).
  It is missing from:
    - `AuthorizationCodeTokenRequest` (oauth-openapi.yaml:725–747) — yet
      §2.1 + §2.2 plus Figure 3 explicitly show `resource` on the
      `authorization_code` exchange.
    - `RefreshTokenRequest` (oauth-openapi.yaml:767–781) — yet Figure 5
      explicitly shows `resource` on `grant_type=refresh_token` and §2.2
      ¶2 specifies that on refresh "such policy may limit the acceptable
      resources to those that were originally granted by the resource owner
      or a subset thereof."
    - `JWTBearerTokenRequest` (oauth-openapi.yaml:797–809) — §2.2 covers
      "all grant types".
    - `DeviceCodeTokenRequest` (oauth-openapi.yaml:783–795) — same.
  Add `resource: { type: array, items: { type: string, format: uri }, description: "Resource indicator(s) per RFC 8707 §2.2." }`
  to each schema (see WRONG below for cardinality).
- **`resource` MUST be modeled as a repeatable parameter, not a single
  string** (§2): "Multiple `resource` parameters MAY be used to indicate
  that the requested token is intended to be used at multiple resources."
  Today the `Resource` parameter is `schema: { type: string, format: uri }`
  (oauth-openapi.yaml:669–671), which encodes a single value only. It
  should be `schema: { type: array, items: { type: string, format: uri } }`
  with `style: form, explode: true` so OpenAPI generators serialize
  `?resource=https://a&resource=https://b` (matching Figure 2). The two
  `resource` form fields on `ClientCredentialsTokenRequest` and
  `TokenExchangeRequest` are also single-valued and need the same array
  treatment.
- **`resource` on `/device_authorization`** (§2): RFC 8707 §2 binds the
  parameter to "requests to the authorization server"; the device
  authorization endpoint (RFC 8628 §3.1) is one such request, and the
  resource indication has to flow with the grant from the moment the user
  authorizes the device. Add `resource` to
  `DeviceAuthorizationRequest` (oauth-openapi.yaml:922–931).
- **`resource` on `/par`** (§2): RFC 9126 §2 says PAR mirrors the
  parameters of `/authorize`, so any parameter listed on `/authorize`
  (including RFC 8707 `resource`) MUST be acceptable at `/par`. The
  `PARRequest` schema (oauth-openapi.yaml:963–990) lists `response_type`,
  `client_id`, `scope`, ... but omits `resource`. The trailing
  `additionalProperties: true` makes the request *not technically rejected*
  by the schema, but the contract is undocumented and code generators
  won't emit a `resource` field. Add it explicitly.
- **`invalid_target` MUST be enumerated in the authorization-request error
  set, not just the token-error set** (§2.1, §5.2): §2.1 says "If the
  authorization server fails to parse the provided value(s) ... it should
  reject the request with an error response using the error code
  `invalid_target`." The §5.2 IANA registration explicitly lists "implicit
  grant error response, token error response" as the usage locations. The
  spec already includes `invalid_target` in the shared `ErrorResponse.error`
  enum (line 907), so the *value* is reachable, but the `/authorize`
  endpoint doesn't return an `OAuthError` JSON response — errors come back
  in the `Location` redirect query string. The `/authorize` endpoint
  description (oauth-openapi.yaml:106–113) and `302` `Location` examples
  (oauth-openapi.yaml:140–148) should explicitly mention that
  `invalid_target` is a valid value of the `error` query parameter on
  authorization-error redirects.
- **Audience-restriction note on `TokenResponse`** (§2 final paragraph):
  "The authorization server SHOULD audience-restrict issued access tokens
  to the resource(s) indicated by the `resource` parameter. Audience
  restrictions can be communicated in JSON Web Tokens [RFC7519] with the
  `aud` claim ...". `TokenResponse` has no field exposing this binding (it
  isn't returned in the JSON envelope, it's *inside* the JWT), but the
  schema description (oauth-openapi.yaml:847–878) should add a sentence
  pointing this out so spec consumers don't miss the §2 SHOULD.
- **Resource URI constraint statement** (§2): "The URI MUST NOT include a
  fragment component. It SHOULD NOT include a query component". Today
  the `Resource` parameter description (oauth-openapi.yaml:666–668) only
  says "Indicator of the protected resource for which authorization is
  being requested. RFC 8707." It should explicitly carry the MUST/SHOULD
  text so generated docs warn callers.

## WRONG — must fix

- **`audience` form fields are non-RFC-8707 and undocumented**
  (oauth-openapi.yaml:764, 836): the `ClientCredentialsTokenRequest` and
  `TokenExchangeRequest` schemas each define an `audience: { type: string }`
  field with no description and no `format`. RFC 8707 defines **`resource`**,
  not `audience`. The `audience` parameter is a Auth0 / Okta vendor
  convention that predates RFC 8707; it is not in the IANA OAuth Parameters
  registry, not referenced anywhere in this RFC, and not standardized.
  Either (a) delete both `audience` properties (preferred for a canonical
  RFC spec), or (b) keep them with an explicit description noting they are
  vendor-specific extensions and not part of RFC 8707; in that case also
  note that `audience` and `resource` are competing conventions and clients
  SHOULD prefer `resource`. Note: in `TokenExchangeRequest` (RFC 8693), the
  `audience` field is *itself* defined by RFC 8693 §2.1 as a logical name
  (not a URI) — that one is legitimate and should be documented as
  RFC 8693, not conflated with RFC 8707.
- **`resource` is `type: string` everywhere; should be repeatable** (§2):
  the schema cardinality contradicts RFC §2's "Multiple `resource`
  parameters MAY be used" and the §3 Security-Considerations text "If a
  bearer token has multiple intended recipients (audiences), then the
  token is valid at more than one protected resource ...". A
  `type: string` schema cannot represent the multi-valued case at all.
  Change to `type: array, items: { type: string, format: uri }, minItems: 1`
  (or oneOf<string, array<string>> if backward-compat is needed) and
  set `style: form, explode: true` on the query-parameter version so it
  serializes as `?resource=A&resource=B` per Figure 2.
- **No statement that the same `resource` value should be used on refresh**
  (§2.2 ¶2): the current `RefreshTokenRequest` schema description
  (oauth-openapi.yaml:767–781) only addresses the `scope` narrowing rule,
  silently omitting the equivalent rule for `resource`: "such policy may
  limit the acceptable resources to those that were originally granted by
  the resource owner or a subset thereof". Once `resource` is added to
  `RefreshTokenRequest` (see MISSING), include this constraint in the
  field description.

## NICE-TO-HAVE

- **Worked examples** in the spec (Figure 1, Figure 2, Figure 3, Figure 5
  of the RFC): add `examples:` entries on the `Resource` parameter and on
  the new `resource` properties showing both single
  (`https://api.example.com/app/`) and multiple (`["https://cal.example.com/", "https://contacts.example.com/"]`)
  values. Helps generated docs.
- **Tenant-aware URI guidance** (§3 ¶2): the §3 text
  "in order to avoid attacks where one tenant uses an access token to
  illegitimately access resources owned by a different tenant, it is
  important to use a specific resource URI including any portion of the URI
  that identifies the tenant" is operational guidance worth one sentence in
  the `Resource` parameter description.
- **Network-addressable URI guidance** (§3 ¶3): note that "Whenever
  feasible, the `resource` parameter should correspond to the
  network-addressable location of the protected resource."
- **Discouragement of multi-audience tokens** (§3 ¶3): the §3 text "using
  only a single `resource` parameter is encouraged" deserves a short note
  in the description so callers don't reflexively pass an array of every
  resource the client touches.
- **JAR encoding note** (§2.1 ¶2): "For an authorization request sent as a
  JSON Web Token (JWT), such as when using the JWT Secured Authorization
  Request [JWT-SAR], a single `resource` parameter value is represented as
  a JSON string while multiple values are represented as an array of
  strings." If/when the spec models the `request` JAR object explicitly,
  this serialization rule belongs there.

## NOT APPLICABLE

- **Privacy considerations** (§4): the §4 text on tracking granularity is
  operational, not OpenAPI-modelable.
- **Implicit-flow examples** (§2.1 Figure 1): the spec intentionally omits
  the implicit grant per OAuth 2.1 (per `CLAUDE.md` "deprecated OAuth 2.0
  grants ... are intentionally excluded"); the §2.1 implicit-flow example
  is informative only, and the §5.2 IANA usage location "implicit grant
  error response" maps onto the surviving `code` flow's redirect-error
  delivery.
- **No new discovery metadata is defined by RFC 8707** — the RFC adds no
  fields to RFC 8414's `DiscoveryDocument`, so nothing is missing there
  from *this* RFC. (RFC 9728 "Protected Resource Metadata" is a separate
  RFC and is out of scope here.)
- **Out-of-band identifier-vs-locator validation** (§3 ¶3): "If the
  `resource` parameter contains an abstract identifier, it is the client's
  responsibility to validate out of band that any network endpoint to
  which tokens are sent are the intended audience for that identifier."
  Pure client-side guidance, not server-API contract.
