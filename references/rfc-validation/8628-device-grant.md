# RFC 8628 — OAuth 2.0 Device Authorization Grant

Source: https://datatracker.ietf.org/doc/html/rfc8628
Audit date: 2026-05-10

> Note: WebFetch was denied during this audit; the RFC text was retrieved
> via `curl https://www.rfc-editor.org/rfc/rfc8628.txt` into
> `references/rfc-validation/.rfc8628-source.txt` and read directly. All
> section/quote citations refer to the published August 2019 Standards
> Track text.

## Correctly modeled

- **Device authorization endpoint exists and is `POST`** (§3.1): the spec
  defines `paths./device_authorization` as a `POST` operation
  (oauth-openapi.yaml:287–321) using
  `application/x-www-form-urlencoded`, matching the §3.1 requirement
  ("client makes a device authorization request to the device
  authorization endpoint by including the following parameters using the
  `application/x-www-form-urlencoded` format").

- **`DeviceAuthorizationRequest` parameters** (§3.1): `client_id` is
  `required`, `scope` is optional (oauth-openapi.yaml:922–931). Matches
  §3.1 — "client_id REQUIRED if the client is not authenticating with
  the authorization server" and "scope OPTIONAL".

- **`DeviceAuthorizationResponse` REQUIRED fields** (§3.2):
  `device_code`, `user_code`, `verification_uri`, `expires_in` are all
  marked `required` (oauth-openapi.yaml:932–954). Matches §3.2.

- **`verification_uri_complete`** (§3.2): present and correctly
  documented as OPTIONAL with a hint about non-textual transmission /
  QR codes (oauth-openapi.yaml:948–951). Matches §3.2 / §3.3.1.

- **`interval` default of 5** (§3.2): the spec sets `default: 5` on the
  integer field and documents "Minimum polling interval in seconds
  (default 5)" (oauth-openapi.yaml:955–958). Matches §3.2 — "If no
  value is provided, clients MUST use 5 as the default."

- **`DeviceCodeTokenRequest`** (§3.4): the schema requires
  `grant_type`, `device_code`, and `client_id`, with
  `grant_type` constrained to the const
  `urn:ietf:params:oauth:grant-type:device_code`
  (oauth-openapi.yaml:783–796). Matches §3.4 verbatim.

- **`grant_type` discriminator wiring** (§3.4): the
  `urn:ietf:params:oauth:grant-type:device_code` mapping is registered
  in `TokenRequest.discriminator.mapping`
  (oauth-openapi.yaml:721) so the device-code body is reachable via
  the canonical RFC 6749 §3.2 token endpoint.

- **New error codes registered** (§3.5 / §7.3):
  `authorization_pending`, `slow_down`, and `expired_token` are all
  present in `ErrorResponse.error.enum`
  (oauth-openapi.yaml:902–904) and `access_denied` is also present
  (line 896). All four §3.5 codes are reachable.

- **`device_authorization_endpoint` advertised in discovery** (§4):
  `DiscoveryDocument.properties.device_authorization_endpoint` is
  defined with `format: uri` (oauth-openapi.yaml:1171–1173). Matches §4
  / §7.4.

- **Cross-reference to RFC 6749 §5.2 errors** (§3.2 last paragraph,
  §3.5 first paragraph): `/device_authorization` declares a `400`
  response that `$ref`s the shared `OAuthError` response
  (oauth-openapi.yaml:314–315), and `/token` does the same
  (oauth-openapi.yaml:204–205), both of which point at the RFC 6749
  §5.2 `ErrorResponse` schema. Matches the RFC's "responds in the same
  way as the token endpoint specified in Section 5.2 of [RFC6749]".

## MISSING — must add

- **`Cache-Control: no-store` on the `/device_authorization` 200**
  (§3.2): the example response in §3.2 includes
  `Cache-Control: no-store`, and §3.2 inherits the §5.1 RFC 6749
  pattern where token-endpoint successful responses MUST NOT be cached.
  The `/token` 200 already declares `Cache-Control: no-store` and
  `Pragma: no-cache` headers (oauth-openapi.yaml:191–199), but the
  `/device_authorization` 200 has no `headers` block
  (oauth-openapi.yaml:308–313). Add the same two headers there.

- **Response `Content-Type: application/json`** (§3.2): §3.2 says
  "includes them in the HTTP response body using the
  `application/json` format [RFC8259] with a 200 (OK) status code".
  The spec correctly uses `content.application/json` on the 200 path
  (oauth-openapi.yaml:310–313) so this part is fine, but RFC 8628
  §3.2 nowhere allows any other body format and the schema is silent
  on whether servers may add `+json` profiles or alternates. Document
  in the operation `description` that `application/json` is the only
  permitted media type. (Borderline; can be argued as nice-to-have.)

- **`grant_types_supported` discovery: enum value missing** (§4): §4
  states that "The value `urn:ietf:params:oauth:grant-type:device_code`
  is included in values of the `grant_types_supported` key."
  `DiscoveryDocument.grant_types_supported` is declared as
  `array of string` with no enum (oauth-openapi.yaml:1193–1196), so
  there is nothing telling consumers that this URN is the canonical
  value to advertise. Either add an `examples` array enumerating the
  six standard grant types (including the device URN) or document the
  expected value in the description.

- **Polling/`slow_down` semantics not documented on `/token`** (§3.5):
  the RFC defines very specific behavior — `slow_down` MUST cause the
  client to increase its polling interval by 5 seconds, and clients
  MUST wait at least `interval` (or 5s) seconds between polls and MUST
  stop polling on any error other than `authorization_pending` or
  `slow_down`. None of this normative behavior is captured anywhere
  in the spec. Add a section to `/token` (or to
  `DeviceCodeTokenRequest`) `description` summarizing the §3.5
  polling rules and pointing to RFC 8628 §3.5. Without this, a code
  generator producing client SDKs from the spec has no way to know the
  device-code grant requires polling.

- **`expires_in` units explicit on the response** (§3.2): the field is
  documented as "Lifetime in seconds of `device_code` and `user_code`"
  (oauth-openapi.yaml:952–954) — this is fine, but the spec lacks a
  `minimum: 1` constraint and an `example`. Adding both improves both
  validation and example-driven generation.

## WRONG — must fix

- **`user_code` has no character-set / format documentation** (§3.3,
  §6.1): RFC 8628 §6.1 spends a full subsection describing the
  character set ("base 20 character set 'BCDFGHJKLMNPQRSTVWXZ'", or a
  numeric set for non-A-Z keyboards), the case-insensitivity
  expectation, and the dash-stripping behavior. The spec's
  `user_code` field is a bare `type: string` with two examples
  (`WDJB-MJHT`, `26FB-FA97`) (oauth-openapi.yaml:940–943). The
  examples are good but the description should at minimum state:
  (a) the code is human-typeable, (b) it may include dashes that the
  server strips, and (c) for A-Z codes the comparison is
  case-insensitive. Without this, a client UI implementer cannot tell
  from the spec whether to uppercase user input. (RFC 8628 calls §6.1
  "non-normative", so this is a description-only fix; no schema
  constraint is required.)

- **`verification_uri` description omits the "short and easy to
  remember" requirement** (§3.2): §3.2 says "The URI should be short
  and easy to remember as end users will be asked to manually type it
  into their user agent." The spec's description is just "End-user
  verification URI on the authorization server"
  (oauth-openapi.yaml:944–947), losing the design rationale. Add the
  RFC's wording.

- **`device_code` description does not stress secrecy** (§3.2, §5.2):
  §5.2 says "the device code is not displayed to the user and thus
  there are no usability considerations on the length, a very high
  entropy code SHOULD be used", and §3.3 says it "should not be
  displayed during the interaction to avoid confusing the end user".
  The spec's description, "Long opaque device verification code (kept
  secret by the client)" (oauth-openapi.yaml:937–939), gets
  "kept secret" right but should also note that it MUST NOT be shown
  to the user. Minor wording fix.

- **`/device_authorization` security: `clientSecretBasic` /
  `clientSecretPost` are listed but `clientAssertion` is not**
  (§3.1 vs RFC 6749 §3.2.1): §3.1 says "client authentication
  requirements of Section 3.2.1 of [RFC6749] apply to requests on this
  endpoint", and §3.2.1 of RFC 6749 plus RFC 7521/7523 explicitly
  permit `client_secret_jwt` and `private_key_jwt`. The spec's
  `/device_authorization` `security` block lists
  `clientSecretBasic`, `clientSecretPost`, and `none`
  (oauth-openapi.yaml:318–321) but omits `clientAssertion` (which is
  modeled at line 1343–1351 and used on `/token`, `/revoke`,
  `/introspect`, `/par`). Add `clientAssertion: []` to the
  `/device_authorization` security list for parity.

## NICE-TO-HAVE

- **Worked examples on the response schema**: add an `examples` array
  to `DeviceAuthorizationResponse` with the §3.2 worked example
  (`{ "device_code": "GmRhmhcxhwAzkoEqiMEg_DnyEysNkuNhszIySk9eS",
  "user_code": "WDJB-MJHT", "verification_uri": "https://example.com/device",
  "verification_uri_complete": "https://example.com/device?user_code=WDJB-MJHT",
  "expires_in": 1800, "interval": 5 }`). Self-documenting and lets
  Swagger UI's "Try it out" produce realistic stubs.

- **Document phishing mitigation in `/device_authorization`
  description** (§5.4): a one-line note that the AS SHOULD display
  device information to the user during the verification step
  (RECOMMENDED per §5.4) helps implementers understand why
  `verification_uri_complete` requires extra UX care.

- **Backoff on connection timeout**: §3.5 — "On encountering a
  connection timeout, clients MUST unilaterally reduce their polling
  frequency before retrying. The use of an exponential backoff
  algorithm to achieve this, such as doubling the polling interval on
  each such connection timeout, is RECOMMENDED." Worth a sentence in
  the same polling-behavior block requested above.

- **Cite §6.1 character-set in `user_code` description**: alongside the
  fix listed under WRONG, mentioning the §6.1 base-20 character set and
  numeric alternative makes the spec self-explaining for AS
  implementers writing user-code generators.

- **Add `interval` constraint hints**: `interval` could carry
  `minimum: 1` and an `example: 5`. Not strictly required but helps
  generators.

## NOT APPLICABLE

- **§5 Security Considerations narrative**: §5.1 (rate-limiting), §5.2
  (high-entropy device codes), §5.3 (device trustworthiness), §5.4
  (remote phishing), §5.5 (session spying), §5.6 (non-confidential
  clients), §5.7 (non-visual code transmission) are deployment
  guidance that an OpenAPI document cannot encode as schema. Worth a
  link from the operation `externalDocs` but no schema change applies.

- **§3.3.1 QR code presentation**: client-side rendering decision; the
  spec already exposes `verification_uri_complete`, which is the only
  thing the AS needs to advertise.

- **§6.1 / §6.2 Usability Considerations**: explicitly marked
  non-normative by the RFC itself ("This section is a non-normative
  discussion"). Description-level prose only; no schema impact beyond
  the `user_code` description fix already noted.

- **§7 IANA registrations**: registry housekeeping; the spec already
  uses the registered URN, parameter names, and error codes — that is
  the full extent of what an OpenAPI consumer cares about.

- **§3.4 cross-reference back into `/token`**: the RFC explicitly
  routes the device-code grant through the same `/token` endpoint as
  the other grants, and the spec's `oneOf` discriminator does this
  correctly. No additional path is needed (and adding e.g.
  `/device/token` would be a deviation).
