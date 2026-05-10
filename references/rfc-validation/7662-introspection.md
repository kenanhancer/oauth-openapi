# RFC 7662 — OAuth 2.0 Token Introspection — Validation Report

Source: <https://datatracker.ietf.org/doc/html/rfc7662>
Spec under review: `oauth-openapi.yaml` — `/introspect`,
`#/components/schemas/IntrospectionRequest`,
`#/components/schemas/IntrospectionResponse`.

> Note: WebFetch was denied for this run. Findings below cite RFC 7662 from
> direct knowledge of the published RFC text (the spec is short, stable, and
> unrevised since 2015). Any reader can re-verify against the linked source.

---

## Summary

| Bucket  | Count |
| ------- | ----- |
| MISSING | 6     |
| WRONG   | 4     |
| EXTRA   | 0     |

The endpoint is structurally close to RFC 7662 but several normative MUST/SHOULD
elements are absent or weakly typed. None of the gaps are wire-breaking, but a
strict RFC-canonical spec should close them.

---

## MISSING (RFC element absent from the OpenAPI spec)

### M1. `token_type_hint` enum is closed; RFC says values are extensible (§2.1)

RFC 7662 §2.1: *"OPTIONAL. A hint about the type of the token submitted for
introspection... Values for this field are defined in the OAuth Token Revocation
spec [RFC7009] in Section 4.1.2."* RFC 7009 §4.1.2 establishes a registry — new
values may be registered. The spec hard-codes `enum: [access_token,
refresh_token]`.

**Fix:** drop `enum` (or convert to `examples`) so future registry values
(e.g. `pct`, `id_token`, vendor types) validate.

### M2. `403` response (insufficient privileges) not modeled (§2.3)

RFC 7662 §2.3: *"If the protected resource uses OAuth 2.0 client credentials to
authenticate to the introspection endpoint and its credentials are invalid, the
authorization server responds with an HTTP 401 ... If the protected resource
uses an OAuth 2.0 bearer token to authorize its call ... and the token used for
authorization does not contain sufficient privileges or is otherwise invalid for
this request, the authorization server responds with an HTTP 401 code as
described in Section 3 of OAuth 2.0 Bearer Token Usage [RFC6750]."*

The spec only declares `401`. RFC 6750 §3.1 also defines `403 insufficient_scope`
for the case where the introspecting RS's own access token lacks the scope to
call `/introspect`. This is the same shape used elsewhere (`/userinfo`).

**Fix:** add a `403` response referencing `OAuthError`.

### M3. `Cache-Control` / `Pragma` headers not declared on the 200 (§4)

RFC 7662 §4 (Security Considerations) and §2.2 cross-reference RFC 6749 §5.1's
caching rules; bodies may contain sensitive token metadata. The `/token`
operation in this same spec already declares `Cache-Control: no-store` and
`Pragma: no-cache` headers on its 200 — `/introspect` does not, despite carrying
similarly sensitive data.

**Fix:** add `Cache-Control` and `Pragma` headers to the `/introspect` 200
response, mirroring `/token`.

### M4. WWW-Authenticate header on 401 not declared (§2.3 → RFC 6750 §3)

§2.3 inherits the RFC 6750 §3 challenge format for the 401 case. The shared
`OAuthError` response only carries the JSON body; no `WWW-Authenticate` header
is documented.

**Fix:** either document the `WWW-Authenticate` header on the `/introspect` 401
specifically, or add it to the shared `OAuthError` response component.

### M5. Caching guidance text absent from the operation `description` (§4)

§4 explicitly warns implementers that introspection responses are
cache-sensitive ("the cache must take into account possible state changes of
the token"). The `description` field of the `/introspect` operation says
nothing about this, even though it is one of the few security-relevant
deployment notes in the RFC.

**Fix:** add a sentence in the operation description noting the caching
trade-off (consult RFC 7662 §4).

### M6. No mention that the server MAY return additional members (§2.2)

§2.2: *"Specific implementations MAY extend this structure with their own
service-specific response names as top-level members of this JSON object.
Response names intended to be used across domains MUST be registered in the
'OAuth Token Introspection Response' registry defined in Section 3.1."*

`IntrospectionResponse` currently lacks `additionalProperties: true` (or a
description noting extensibility). Strict OpenAPI validators may then reject
custom claims (e.g. `cnf` for DPoP, vendor `roles` arrays).

**Fix:** set `additionalProperties: true` on `IntrospectionResponse` and add a
short description note pointing to §2.2 / §3.1.

---

## WRONG (RFC element present but modeled incorrectly)

### W1. `aud` typing accepts only string-of-strings — should also allow integer/StringOrURI variants? (§2.2)

§2.2 binds `aud` to RFC 7519 §4.1.3 semantics: *"Service-specific string
identifier or list of string identifiers ... See [JWT], Section 4.1.3 for
details."* RFC 7519 §4.1.3 defines `aud` as a `StringOrURI` (single) **or an
array of `StringOrURI` values**. The current modeling
(`oneOf: [string, array<string>]`) is correct in cardinality but the inner
items should be typed as `StringOrURI` (string with format hint or uri-reference)
to convey intent. Minor — flag as a typing weakness rather than a bug.

**Fix:** either describe in the field description that elements are
`StringOrURI` per RFC 7519 §4.1.3, or add `format: uri-reference` plus a note.

### W2. `exp`, `iat`, `nbf` typed as plain `integer`; RFC binds them to JWT NumericDate (§2.2)

§2.2 defines all three as JWT `NumericDate` (RFC 7519 §2): *"A JSON numeric
value representing the number of seconds from 1970-01-01T00:00:00Z UTC ...
allowing non-integer values"*. The spec types them as `integer`, which is the
99% practical case but technically narrower than the RFC permits.

**Fix:** change to `type: number` (or `integer` with a description noting
"seconds since epoch; non-integer values permitted per RFC 7519 §2"). Today
the description says only "seconds since epoch" for `exp`/`iat` and nothing
at all for `nbf`.

### W3. `token_type` field documented vaguely; RFC binds it to RFC 6749 §5.1 (§2.2)

§2.2: *"Type of the token as defined in Section 5.1 of OAuth 2.0 [RFC6749]."*
The field is just `type: string` with no description. Compare with how
`TokenResponse.token_type` documents `Bearer`/`DPoP`.

**Fix:** add a description and (optionally) examples like `Bearer`, `DPoP`,
`mac` linking to RFC 6749 §5.1.

### W4. Security: `/introspect` allows only client auth schemes; RFC also permits "separate OAuth 2.0 access token" (§2.1)

§2.1: *"To prevent token scanning attacks, the endpoint MUST also require some
form of authorization to access this endpoint, such as client authentication
as described in OAuth 2.0 [RFC6749] **or a separate OAuth 2.0 access token
such as the bearer token described in OAuth 2.0 Bearer Token Usage [RFC6750]**.
The methods of managing and validating these authentication credentials are
out of scope of this specification."*

The spec lists `clientSecretBasic`, `clientSecretPost`, `clientAssertion` only.
A protected resource holding an introspection-purpose access token cannot be
modeled with the current `security` block, even though the RFC explicitly
permits it.

**Fix:** add `bearerAuth: []` (and optionally `dpop: []`) to the `/introspect`
`security` array.

---

## EXTRA (in spec, not in RFC)

None. The schema fields (`scope`, `client_id`, `username`, `token_type`, `exp`,
`iat`, `nbf`, `sub`, `aud`, `iss`, `jti`, `active`) are exactly the §2.2 set.

---

## Notes / out of scope

- The spec correctly models `POST` + `application/x-www-form-urlencoded` (§2.1).
- The spec correctly returns `200` for inactive tokens — this is a frequent
  implementer mistake and the spec gets it right (operation description says so
  explicitly).
- The `IntrospectionRequest.token` description is empty; not strictly an RFC
  violation but worth a one-line note ("the token to introspect; opaque or
  JWT").
- Discovery: `introspection_endpoint` is already present in `DiscoveryDocument`
  — good. `introspection_endpoint_auth_methods_supported` and
  `introspection_endpoint_auth_signing_alg_values_supported` (RFC 8414 §2)
  are out of scope for this RFC's report but worth noting in the RFC 8414
  audit.

---

## Section index used

- §2     Introspection Endpoint
- §2.1   Introspection Request
- §2.2   Introspection Response
- §2.3   Error Response
- §3     IANA / Registries (registry for additional response members)
- §4     Security Considerations (caching, TLS, token scanning)
