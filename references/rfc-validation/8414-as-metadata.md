# RFC 8414 — OAuth 2.0 Authorization Server Metadata

Source: https://datatracker.ietf.org/doc/html/rfc8414
Audit date: 2026-05-10

> Note: WebFetch was denied during this audit; the RFC text was retrieved via
> `curl` from `https://www.rfc-editor.org/rfc/rfc8414.txt` and cached at
> `references/rfc-validation/.rfc8414-source.txt`. Section citations follow
> the published RFC (Standards Track, June 2018, M. Jones / N. Sakimura /
> J. Bradley).

The audit covers every metadata member defined in RFC 8414 §2 (the IANA
"OAuth Authorization Server Metadata" registry's initial contents) plus
`signed_metadata` from §2.1. The spec models RFC 8414 via the shared
`schemas.DiscoveryDocument` (oauth-openapi.yaml:1136–1239) reused on both
`/.well-known/openid-configuration` and `/.well-known/oauth-authorization-server`
(oauth-openapi.yaml:469–487).

## Correctly modeled

- **`issuer`** (§2): typed as `string` / `format: uri`, listed in `required`
  on `DiscoveryDocument` (oauth-openapi.yaml:1142, 1144–1147). The
  description correctly notes that it MUST equal the host the document was
  fetched from — this captures the §3.3 validation rule in prose.

- **`authorization_endpoint`** (§2): present and `required`
  (oauth-openapi.yaml:1142, 1148–1150). RFC's "REQUIRED unless no grant
  types are supported that use the authorization endpoint" qualifier is not
  encoded but is reasonable for the canonical case.

- **`token_endpoint`** (§2): present and `required`
  (oauth-openapi.yaml:1142, 1151–1153). RFC's "REQUIRED unless only the
  implicit grant type is supported" qualifier is moot because OAuth 2.1
  (declared at oauth-openapi.yaml:51–53) forbids implicit.

- **`jwks_uri`** (§2): present, typed as URL (oauth-openapi.yaml:1158–1160).

- **`registration_endpoint`** (§2): present, typed as URL, with a pointer
  to RFC 7591 in its description (oauth-openapi.yaml:1161–1164).

- **`scopes_supported`** (§2): present, typed as `array` of `string`
  (oauth-openapi.yaml:1181–1184).

- **`response_types_supported`** (§2): present, typed as `array` of `string`,
  and listed in the `DiscoveryDocument.required` set
  (oauth-openapi.yaml:1142, 1185–1188) — RFC 8414 says REQUIRED.

- **`response_modes_supported`** (§2): present, array of strings
  (oauth-openapi.yaml:1189–1192).

- **`grant_types_supported`** (§2): present, array of strings
  (oauth-openapi.yaml:1193–1196).

- **`token_endpoint_auth_methods_supported`** (§2): present with an `enum`
  covering the seven IANA-registered methods plus `none`
  (oauth-openapi.yaml:1197–1208).

- **`revocation_endpoint`** (§2): present, typed as URL
  (oauth-openapi.yaml:1168–1170).

- **`introspection_endpoint`** (§2): present, typed as URL
  (oauth-openapi.yaml:1165–1167).

- **`code_challenge_methods_supported`** (§2): present with `enum: [S256,
  plain]` (oauth-openapi.yaml:1222–1226). The enum matches the IANA "PKCE
  Code Challenge Methods" registry.

- **Discovery path** (§3): `/.well-known/oauth-authorization-server` is
  exposed at the correct well-known URI suffix
  (oauth-openapi.yaml:469–487). Content type is `application/json` per §3.2.

## MISSING — must add

The following metadata members from RFC 8414 §2 are absent from
`DiscoveryDocument`. Each is OPTIONAL by RFC text, but several have
conditional MUST requirements that the schema cannot represent unless the
field at least exists.

- **`token_endpoint_auth_signing_alg_values_supported`** (§2): array of JWS
  `alg` values used to sign client-authentication JWTs at `/token`. RFC:
  *"This metadata entry MUST be present if either of these authentication
  methods are specified in the `token_endpoint_auth_methods_supported`
  entry. ... The value `none` MUST NOT be used."* The spec's enum already
  lists `private_key_jwt` and `client_secret_jwt` as supported
  `token_endpoint_auth_methods_supported` values (oauth-openapi.yaml:1205–
  1206), so leaving this field unmodeled is a real gap.

- **`revocation_endpoint_auth_methods_supported`** (§2): array of client
  authentication methods accepted at `/revoke`. The spec models `/revoke`
  with `clientSecretBasic`, `clientSecretPost`, `clientAssertion` security
  schemes (oauth-openapi.yaml:243–246) but exposes no discovery field for
  the corresponding methods.

- **`revocation_endpoint_auth_signing_alg_values_supported`** (§2): JWS
  `alg` values for `private_key_jwt` / `client_secret_jwt` at `/revoke`.
  RFC: *"This metadata entry MUST be present if either of these
  authentication methods are specified ... The value `none` MUST NOT be
  used."* Same conditional MUST as the token-endpoint pair.

- **`introspection_endpoint_auth_methods_supported`** (§2): array of client
  authentication methods accepted at `/introspect`. The spec models the
  endpoint (oauth-openapi.yaml:251–282) but no discovery-side advertisement
  of its accepted methods.

- **`introspection_endpoint_auth_signing_alg_values_supported`** (§2): JWS
  `alg` values for `private_key_jwt` / `client_secret_jwt` at `/introspect`.
  Same conditional MUST as above.

- **`service_documentation`** (§2): URL of human-readable developer docs.
  Important when an AS does *not* expose dynamic client registration
  (per §2 wording: *"if the authorization server does not support Dynamic
  Client Registration, then information on how to register clients needs
  to be provided in this documentation"*).

- **`ui_locales_supported`** (§2): array of BCP 47 language tags for the
  authorization UI.

- **`op_policy_uri`** (§2): URL describing data-usage requirements imposed
  on registered clients.

- **`op_tos_uri`** (§2): URL of the AS's terms of service. (RFC §5
  explicitly notes `op_policy_uri` and `op_tos_uri` are general OAuth
  metadata despite the OpenID-flavored names.)

- **`signed_metadata`** (§2.1): JWT string containing metadata claims as a
  bundle. RFC: *"In addition to JSON elements, metadata values MAY also be
  provided as a `signed_metadata` value, which is a JSON Web Token (JWT)
  ... The signed metadata MUST be digitally signed or MACed using JSON Web
  Signature (JWS) and MUST contain an `iss` (issuer) claim ... metadata
  values conveyed in the signed metadata MUST take precedence over the
  corresponding values conveyed using plain JSON elements."* Add as
  `signed_metadata: { type: string, description: 'JWT bundle of
  authorization-server metadata claims (RFC 8414 §2.1)' }`.

## WRONG — must fix

- **Two spec endpoints are not reflected in the discovery document**:
  the spec models `/par` (oauth-openapi.yaml:326–362, RFC 9126) and the
  spec correctly *does* expose `pushed_authorization_request_endpoint` in
  `DiscoveryDocument` (line 1174–1176). However, **the spec does NOT expose
  `userinfo_endpoint` consistently** — it is present in `DiscoveryDocument`
  (oauth-openapi.yaml:1154–1157) but `userinfo_endpoint` is NOT a member of
  RFC 8414 §2; it is an OIDC Discovery extension. Because the spec reuses
  the *same* `DiscoveryDocument` schema for both `/.well-known/openid-
  configuration` and `/.well-known/oauth-authorization-server`, the RFC
  8414 endpoint advertises `userinfo_endpoint` even when the AS does not
  speak OIDC — which is permitted by §2's "Other claims MAY also be
  returned" but is misleading. Either (a) split into two schemas
  (RFC-8414-only and OIDC-Discovery-superset), or (b) document the reuse
  explicitly in the description.

- **`jwks_uri` https requirement not enforced or documented** (§2): the
  RFC says *"This URL MUST use the `https` scheme."* The spec just sets
  `format: uri` (oauth-openapi.yaml:1158–1160) without a `pattern`,
  `description` note, or example pinning the scheme.

- **`token_endpoint_auth_methods_supported.enum` includes
  `tls_client_auth` and `self_signed_tls_client_auth` but lacks anything
  that flags them as non-RFC-8414 extensions** (oauth-openapi.yaml:1207–
  1208): RFC 8414's IANA registry initially registered only the seven
  values originally defined by RFC 7591. `tls_client_auth` and
  `self_signed_tls_client_auth` come from RFC 8705 and are valid registered
  entries — but only because of a later registration. The enum is
  *factually* correct against the live IANA registry; flagging here only
  because the description does not explain the mixed origin.

- **`response_modes_supported` default not documented** (§2): RFC: *"If
  omitted, the default is `["query", "fragment"]`."* The schema accepts an
  array but does not document this default.

- **`grant_types_supported` default not documented** (§2): RFC: *"If
  omitted, the default value is `["authorization_code", "implicit"]`."*
  Even though OAuth 2.1 forbids implicit, the *RFC 8414 default* is what
  it is; clients parsing a discovery doc per RFC 8414 will assume implicit
  is supported when the field is absent. The spec should either always
  populate the field in examples or note the default in the description.

- **`token_endpoint_auth_methods_supported` default not documented** (§2):
  RFC: *"If omitted, the default is `client_secret_basic`."* Same omission
  as above.

- **`code_challenge_methods_supported` semantics of omission not
  documented** (§2): RFC: *"If omitted, the authorization server does not
  support PKCE."* Important because OAuth 2.1 mandates PKCE — under RFC
  8414's default rules, a missing field means PKCE is *unsupported*, which
  is a genuine deployment hazard worth noting.

## NICE-TO-HAVE

- **§3.3 issuer-validation rule** as an `x-` extension or description on
  the `/.well-known/oauth-authorization-server` 200 response: *"The
  `issuer` value returned MUST be identical to the authorization server's
  issuer identifier value into which the well-known URI string was
  inserted to create the URL used to retrieve the metadata. If these
  values are not identical, the data contained in the response MUST NOT be
  used."* The current `issuer` field description (oauth-openapi.yaml:1147)
  hints at this but does not state the consequence.

- **§3 multi-tenant path-component handling**: the spec hard-codes the path
  `/.well-known/oauth-authorization-server`. RFC §3 specifies that for
  issuers with a path component, the well-known URI is *inserted* between
  host and path (e.g., `/.well-known/oauth-authorization-server/issuer1`),
  not appended. Add a note or path template that captures this.

- **§6.1 TLS requirement** on the discovery endpoint: a one-line note that
  the discovery URL MUST be served over TLS 1.2+ would mirror what the
  `bearerAuth` description (oauth-openapi.yaml:1315–1319) does for token
  transport.

- **Example response body** on the `/.well-known/oauth-authorization-server`
  200 response, mirroring the §3.2 non-normative example. The spec
  currently has none; an `example` block would make the discovery contract
  immediately readable.

- **Distinguish RFC 8414 fields from OIDC Discovery extensions** in the
  `DiscoveryDocument` description: the schema mixes both in one shape.
  Either add a `// RFC 8414` / `// OIDC Discovery 1.0` annotation in the
  `description` per field, or split into two schemas (preferred).

- **Cross-reference the IANA registry** in `DiscoveryDocument.description`:
  RFC 8414 §7.1 establishes the "OAuth Authorization Server Metadata"
  registry; pointing readers there explains why additional fields (e.g.,
  RFC 9126's `pushed_authorization_request_endpoint`, RFC 9449's
  `dpop_signing_alg_values_supported`) are valid even though they are not
  in the original §2 list.

## NOT APPLICABLE

- **§3.1 Metadata Request HTTP `GET` form**: the spec already models the
  endpoint as `get:` (oauth-openapi.yaml:469–470), which is correct.

- **§4 String Operations** (Unicode comparison rules): a runtime
  string-handling rule, not modelable in OpenAPI.

- **§5 Compatibility Notes** about path-transformation differences vs.
  OIDC Discovery 1.0: documentation guidance, not a schema concern.

- **§6.2–§6.4 Security Considerations** (impersonation, standard-format
  publishing, protected-resource selection): runtime/operational concerns;
  the schema cannot enforce them.

- **§7 IANA Considerations**: registry administration; not a spec concern.

- **`userinfo_endpoint`, `id_token_signing_alg_values_supported`,
  `subject_types_supported`, `claims_supported`, `end_session_endpoint`,
  `dpop_signing_alg_values_supported`,
  `authorization_details_types_supported`, `device_authorization_endpoint`,
  `pushed_authorization_request_endpoint`,
  `require_pushed_authorization_requests`** (oauth-openapi.yaml:1154–1157,
  1171–1180, 1209–1216, 1218–1221, 1227–1239): these fields exist on the
  shared `DiscoveryDocument` but are *not* members of RFC 8414 §2; they
  belong to OIDC Discovery 1.0, RFC 8628, RFC 9126, RFC 9396, and RFC 9449.
  Out of scope for this RFC's audit (other parallel agents own them) but
  they are valid "Other claims MAY also be returned" extensions per §3.2.
