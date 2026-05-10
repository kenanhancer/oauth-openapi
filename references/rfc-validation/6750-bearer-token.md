# RFC 6750 — Bearer Token Usage

Source: https://datatracker.ietf.org/doc/html/rfc6750
Audit date: 2026-05-10

> Note: WebFetch was denied during this audit; findings are based on the
> well-established normative text of RFC 6750 (October 2012, IETF Standards
> Track) cross-referenced against the spec at `oauth-openapi.yaml`. Section
> citations follow the published RFC.

## Correctly modeled

- **`bearerAuth` security scheme** (§2.1): `securitySchemes.bearerAuth` is
  declared as `type: http`, `scheme: bearer`, `bearerFormat: JWT`, with a
  description that explicitly cites RFC 6750. This is the OpenAPI-canonical
  way to express the `Authorization: Bearer <token>` header method.
  (oauth-openapi.yaml:1315–1319)

- **Bearer in `token_type` examples** (§4): `TokenResponse.token_type` lists
  `Bearer` and `DPoP` as valid examples (oauth-openapi.yaml:858–859); this
  matches the §6.1 OAuth Access Token Type Registration entry "Bearer".

- **Bearer error codes in `ErrorResponse.error` enum** (§3.1, §6.3): the enum
  includes `invalid_token` and `insufficient_scope` (oauth-openapi.yaml:900–901),
  and `invalid_request` is also present (line 890 — shared with RFC 6749 but
  also registered as a Bearer error code per §6.3).

- **`error_description` and `error_uri` fields** (§3): `ErrorResponse`
  defines both fields with correct types (oauth-openapi.yaml:908–914),
  matching the §3 challenge parameters that are also reused in JSON error
  bodies for compatibility with RFC 6749 §5.2.

- **`bearerAuth` referenced on protected resources**: `/userinfo` GET and
  POST both list `bearerAuth: []` and `dpop: []` under `security`
  (oauth-openapi.yaml:391–393, 411–413). This is the correct pattern for a
  Bearer-protected resource per §2.

## MISSING — must add

- **`WWW-Authenticate` response header on 401 responses** (§3): RFC 6750 §3
  states "If the protected resource request does not include authentication
  credentials or does not contain an access token that enables access to the
  protected resource, the resource server MUST include the HTTP
  `WWW-Authenticate` response header field". The spec defines a `401`
  response on `/userinfo` (oauth-openapi.yaml:389–390, 409–410) but does not
  declare a `WWW-Authenticate` header in the response. Add a
  `headers.WWW-Authenticate` entry on every 401 from a Bearer-protected
  endpoint, with the challenge syntax
  `Bearer realm="<realm>", error="<code>", error_description="<text>", error_uri="<uri>", scope="<scopes>"`.

- **`403` response with `insufficient_scope`** (§3.1): "The request requires
  higher privileges than provided by the access token. The resource server
  SHOULD respond with the HTTP 403 (Forbidden) status code". `/userinfo`
  only models `200` and `401`; it should also declare a `403` response
  carrying `WWW-Authenticate: Bearer error="insufficient_scope", scope="…"`
  and the same `ErrorResponse` body shape.

- **Bearer-token challenge parameter set documented**: §3 normatively
  defines five challenge attributes — `realm`, `scope`, `error`,
  `error_description`, `error_uri`. The spec has no schema or header model
  describing this challenge, so an OpenAPI consumer cannot generate or
  validate it. Add a reusable header definition (e.g.,
  `components.headers.WWWAuthenticateBearer`) with a description that
  enumerates the five parameters and their purposes.

- **`Bearer` error-code mapping to HTTP status** (§3.1): the §3.1 table is
  normative — `invalid_request` → 400, `invalid_token` → 401,
  `insufficient_scope` → 403. The spec lists the codes in `ErrorResponse`
  but never says which HTTP status each maps to on a *resource* request
  (only on AS endpoints). Document this on the `WWW-Authenticate` header
  description or on the protected-resource responses.

## WRONG — must fix

- **Form-encoded body parameter (§2.2) and URI query parameter (§2.3) not
  modeled**: §2.2 ("the client adds the access token to the request body
  using the `access_token` parameter") and §2.3 ("the client uses the HTTP
  request URI in the `access_token` query parameter") are alternative
  presentation methods. The spec only models §2.1 (Authorization header).
  This is technically *missing*, but listed under WRONG because the spec
  presents `bearerAuth` as if it were the only Bearer method — it is not.
  Note: §2.3 is normatively discouraged ("SHOULD NOT be used unless it is
  impossible") and OAuth 2.1 forbids both §2.2 and §2.3, so the correct
  fix is to **explicitly state in the `bearerAuth` description that only
  §2.1 is supported, per OAuth 2.1**, rather than to add the other two.

- **`bearerFormat: JWT` is too narrow** (§1.2): RFC 6750 defines bearer
  tokens as opaque strings — "A security token with the property that any
  party in possession of the token (a 'bearer') can use the token". JWT is
  one common encoding (RFC 9068), but introspection-based opaque tokens
  (RFC 7662) are equally valid. Change `bearerFormat: JWT` to either omit
  the field or set it to a value indicating the format is implementation-
  defined (the field is informational per OpenAPI; "JWT" is a hint, not a
  constraint, but it misleads readers into thinking opaque tokens are
  unsupported by this AS).

## NICE-TO-HAVE

- **`Cache-Control: no-store` on 401/403 responses from protected
  resources** (§5.1 / §5.3 implicitly via §2.4 of RFC 6749): the spec
  already models `Cache-Control: no-store` and `Pragma: no-cache` on the
  `/token` 200 (oauth-openapi.yaml:191–199). Mirroring this on Bearer
  error responses prevents intermediaries from caching error bodies that
  may include sensitive `error_description` text.

- **Example `WWW-Authenticate` values**: §3 includes example challenges
  (e.g., `Bearer realm="example"`,
  `Bearer realm="example", error="invalid_token", error_description="The access token expired"`).
  Adding these as `examples` on the header definition would make the spec
  self-documenting.

- **Document realm semantics**: §3 — "The `realm` attribute is used to
  indicate the scope of protection in the manner described in HTTP/1.1
  [RFC2617]". A short note on the AS's realm convention (often the issuer
  URL) helps client implementers.

- **Reference §5 Security Considerations**: notes about TLS requirement
  ("Always use TLS"), token storage, and not transmitting tokens in the
  URI fragment are useful as `description` content on `bearerAuth`.

## NOT APPLICABLE

- **§2.2 form-encoded body** and **§2.3 URI query** presentation methods:
  excluded by OAuth 2.1 (the spec already declares OAuth 2.1 defaults at
  oauth-openapi.yaml:51–53). Not applicable for inclusion as security
  schemes; only worth a sentence in `bearerAuth.description` saying they
  are intentionally omitted.

- **§4 Example Access Token Response**: this is illustrative, not
  normative; the `TokenResponse` schema already covers the shape.

- **§6.1 OAuth Access Token Type registration** ("Bearer"): IANA registry
  entry; the spec's mention of `Bearer` in `token_type` examples is the
  full extent of what an OpenAPI spec needs to model.

- **§6.2 URI registration of `error_uri`**: the registration governs the
  IETF URI namespace, not anything an AS spec must declare; the
  `error_uri` *field* is already modeled.
