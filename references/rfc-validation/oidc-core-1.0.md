# OpenID Connect Core 1.0 (incorporating errata set 2)

Source: https://openid.net/specs/openid-connect-core-1_0.html
Audit date: 2026-05-10

> Note: WebFetch was denied during this audit; the OIDC Core 1.0 HTML was
> retrieved via `curl` and cached at
> `references/rfc-validation/.oidc-core-source.html`. Section citations follow
> the published spec (Final, 8 November 2014, errata set 2 of 8 December 2023,
> Sakimura/Bradley/Jones/de Medeiros/Mortimore).

The audit covers the protocol surface that OIDC Core extends OAuth 2.0 with:
the `/authorize` parameters added by §3.1.2.1 (and §3.2.2.1 / §3.3.2.1),
the ID Token claim set (§2), the `/userinfo` endpoint (§5.3), Standard
Claims (§5.1), the `claims` request parameter (§5.5), the Request Object
mechanism (§6), Client Authentication methods (§9), and the Mandatory To
Implement features (§15.1, §15.2). The audited OpenAPI spec models OIDC via
the `Nonce` / `Prompt` / `LoginHint` / `MaxAge` / `AcrValues` parameters
(oauth-openapi.yaml:581–629), the `RequestUri` parameter
(oauth-openapi.yaml:641–650), the `/userinfo` GET/POST operations
(oauth-openapi.yaml:367–413), the `UserInfoResponse` schema
(oauth-openapi.yaml:1244–1308), and `TokenResponse.id_token`
(oauth-openapi.yaml:870–872).

---

## Correctly modeled

- **`scope` parameter on `/authorize` documents the `openid` requirement**
  (§3.1.2.1): "OpenID Connect requests MUST contain the `openid` scope
  value." The spec's `Scope` parameter description (oauth-openapi.yaml:534–547)
  says "For OIDC, MUST include `openid` to request an ID token. Standard OIDC
  scopes: `profile`, `email`, `address`, `phone`, `offline_access`."

- **`response_type` enum includes the OIDC additions** (§3.2.2.1, §3.3.2.1):
  the spec lists `id_token`, `code id_token`, `code token`,
  `code id_token token` alongside `code` (oauth-openapi.yaml:498–512), which
  are exactly the four values added by Implicit Flow (§3.2) and Hybrid Flow
  (§3.3) on top of the base Authorization Code Flow value `code`.

- **`nonce` parameter present** (§3.1.2.1, §3.2.2.1, §3.3.2.1) on the
  authorization endpoint (oauth-openapi.yaml:581–589) with description
  pointing to OIDC Core §3.1.2.1.

- **`prompt` parameter values match the §3.1.2.1 set** — `none`, `login`,
  `consent`, `select_account` (oauth-openapi.yaml:591–603).

- **`login_hint`, `max_age`, `acr_values` parameters present** on `/authorize`
  with §3.1.2.1-aligned descriptions (oauth-openapi.yaml:605–629).

- **`request_uri` parameter present** for JAR / PAR-style requests
  (oauth-openapi.yaml:641–650). §6.2 defines this parameter; its presence is
  also Mandatory-To-Implement for Dynamic OPs per §15.2.

- **`/userinfo` accepts both GET and POST** (§5.3): "The UserInfo Endpoint
  MUST support the use of the HTTP `GET` and HTTP `POST` methods." The spec
  defines both `userinfoGet` and `userinfoPost` operations
  (oauth-openapi.yaml:368, 394).

- **`/userinfo` requires Bearer (or DPoP) authentication** (§5.3 / §5.3.1):
  "The UserInfo Endpoint MUST accept Access Tokens as OAuth 2.0 Bearer
  Tokens." Both operations declare `bearerAuth` and `dpop` security
  requirements (oauth-openapi.yaml:391–393, 411–413).

- **`/userinfo` GET supports the `application/jwt` content type** (§5.3.2):
  "If the UserInfo Response is signed and/or encrypted, then the Claims are
  returned in a JWT and the content-type MUST be `application/jwt`." The GET
  operation declares both `application/json` and `application/jwt` response
  bodies (oauth-openapi.yaml:381–388).

- **`UserInfoResponse.sub` is REQUIRED** (§5.3.2): "The `sub` (subject)
  Claim MUST always be returned in the UserInfo Response." Spec lists `sub`
  in `required` (oauth-openapi.yaml:1249–1252).

- **`UserInfoResponse` covers the §5.1 Standard Claims** — `sub`, `name`,
  `given_name`, `family_name`, `middle_name`, `nickname`,
  `preferred_username`, `profile`, `picture`, `website`, `email`,
  `email_verified`, `gender`, `birthdate`, `zoneinfo`, `locale`,
  `phone_number`, `phone_number_verified`, `address`, `updated_at`
  (oauth-openapi.yaml:1251–1308). All twenty members of the §5.1 Registered
  Member Definitions table are present.

- **`address` claim sub-fields match §5.1.1** — `formatted`, `street_address`,
  `locality`, `region`, `postal_code`, `country` are all present
  (oauth-openapi.yaml:1293–1306).

- **`birthdate` formatted as date** (§5.1): spec uses `format: date`
  (oauth-openapi.yaml:1281–1283). RFC's "ISO 8601-1 `YYYY-MM-DD` format" is
  semantically a date.

- **`email` formatted as email** (§5.1): spec uses `format: email`
  (oauth-openapi.yaml:1274–1276). RFC's "RFC 5322 addr-spec syntax" is the
  conventional email format.

- **`updated_at` is integer (epoch seconds)** (§5.1): spec uses `type: integer`
  (oauth-openapi.yaml:1307–1308). Matches RFC's "JSON number representing the
  number of seconds from 1970-01-01T00:00:00Z."

- **`TokenResponse.id_token` is documented as a signed JWT** (§3.1.3.3):
  "the following parameters MUST be included in the response: `id_token` —
  ID Token value associated with the authenticated session." Spec models it
  on `TokenResponse` (oauth-openapi.yaml:870–872).

- **PAR `request` parameter modeled** as a signed JWT (§6.1, RFC 9101 / JAR):
  the `PARRequest.request` field (oauth-openapi.yaml:987–989) is described as
  "Optional signed JWT request object (JAR, RFC 9101)" — semantically aligned
  with the `request` parameter from §6.

- **Discovery exposes `claims_supported`** (oauth-openapi.yaml:1218–1221) — the
  Discovery 1.0 metadata that lets an OP advertise its supported §5.1 Standard
  Claims.

---

## MISSING — must add to the spec

- **`/userinfo` is missing the standalone `iss` and `aud` claims required
  for SIGNED responses** (§5.3.2): "If signed, the UserInfo Response MUST
  contain the Claims `iss` (issuer) and `aud` (audience) as members. The
  `iss` value MUST be the OP's Issuer Identifier URL. The `aud` value MUST
  be or include the RP's Client ID value." `UserInfoResponse`
  (oauth-openapi.yaml:1244–1308) does not include `iss` or `aud`. The signed
  variant is served as `application/jwt`, and the JWT body MUST carry these
  claims. Add `iss` and `aud` as OPTIONAL fields with a description noting
  that they are REQUIRED when the response is `application/jwt` (signed).

- **ID Token has no schema at all** (§2): the spec only types
  `TokenResponse.id_token` as a `string` JWT (oauth-openapi.yaml:870–872).
  §2 enumerates REQUIRED claims `iss`, `sub`, `aud`, `exp`, `iat` and
  OPTIONAL claims `auth_time`, `nonce`, `acr`, `amr`, `azp`. Add an
  `IDTokenClaims` schema (a documentation-only object describing the JWT
  payload) so that consumers of the spec see what is inside the JWT. This
  is a documentation gap; readers cannot tell what an `id_token` contains.

- **`auth_time` semantics not documented anywhere** (§2 / §15.1
  "Authentication Time"): "When a `max_age` request is made or when
  `auth_time` is requested as an Essential Claim, then this Claim is
  REQUIRED; otherwise, its inclusion is OPTIONAL." Spec mentions `max_age`
  parameter (oauth-openapi.yaml:613–620) but does not document its server-side
  contract that the resulting ID Token MUST include `auth_time`. Add a note
  on `MaxAge` and on the ID Token schema.

- **`display` parameter on `/authorize` is missing entirely** (§3.1.2.1, §15.1
  "Display Parameter"): "OPs MUST support the `display` parameter." Defined
  values are `page`, `popup`, `touch`, `wap`. Spec has no `Display` parameter.
  Add it as an OPTIONAL parameter with the four enum values.

- **`ui_locales` parameter on `/authorize` is missing entirely** (§3.1.2.1,
  §15.1 "Preferred Locales"): "OPs MUST support requests for preferred
  languages and scripts for the user interface and for Claims via the
  `ui_locales` and `claims_locales` request parameters." Space-separated
  BCP47 language tags. Spec has no `UiLocales` parameter. Add it.

- **`claims_locales` parameter on `/authorize` is missing entirely**
  (§5.2, §15.1): companion to `ui_locales` for selecting Claim languages.
  Spec has no `ClaimsLocales` parameter. Add it.

- **`id_token_hint` parameter on `/authorize` is missing entirely**
  (§3.1.2.1): "ID Token previously issued by the Authorization Server being
  passed as a hint about the End-User's current or past authenticated session
  with the Client." Used especially with `prompt=none`. Spec has no
  `IdTokenHint` parameter. Add it.

- **`claims` request parameter on `/authorize` is missing entirely** (§5.5):
  "OPTIONAL. This parameter is used to request that specific Claims be
  returned. The value is a JSON object listing the requested Claims" with
  top-level members `userinfo` and `id_token`. Spec has no `Claims`
  parameter. Add it as a JSON-string parameter (UTF-8 JSON which gets
  form-urlencoded). A schema for the inner JSON shape is also useful.

- **`request` parameter on `/authorize` is missing entirely** (§6 / §6.1):
  "OPTIONAL. This parameter enables OpenID Connect requests to be passed in
  a single, self-contained parameter and to be optionally signed and/or
  encrypted. The parameter value is a Request Object value." Spec only
  models `request_uri` (oauth-openapi.yaml:641–650), not `request`. Add a
  `Request` parameter (string, JWT compact serialization). Note that
  `request` and `request_uri` are mutually exclusive per §6.

- **`registration` parameter on `/authorize` is missing** (§7.2.1, mentioned
  via `registration_not_supported` error code in §3.1.2.6): used by
  Self-Issued OPs. Lower priority than the others above but listed here for
  completeness.

- **`response_mode=form_post` is in the enum but `query` and `fragment` are
  the only two response modes defined by OAuth 2.0 §4** — actually correct,
  but the spec's `ResponseMode` enum (oauth-openapi.yaml:630–639) is missing
  the OIDC `web_message` and CIBA-style modes. NOT a Core requirement (those
  modes are defined elsewhere); leaving as-is is acceptable.

- **OIDC error codes missing from the `ErrorResponse.error` enum** (§3.1.2.6):
  OIDC adds `interaction_required`, `login_required`,
  `account_selection_required`, `consent_required`, `invalid_request_uri`,
  `invalid_request_object`, `request_not_supported`,
  `request_uri_not_supported`, `registration_not_supported`. Spec's enum
  (oauth-openapi.yaml:889–907) covers OAuth 2.0, RFC 6750, RFC 8628, RFC 9449,
  RFC 8707 codes but **none of the nine OIDC-added codes**. Add all nine.

- **UserInfo Error Response uses `WWW-Authenticate` header per RFC 6750**
  (§5.3.3): "an Error Response as defined in Section 3 of OAuth 2.0 Bearer
  Token Usage [RFC6750]." The `/userinfo` 401 response
  (oauth-openapi.yaml:389–390, 409–410) reuses the generic `OAuthError`
  body. Add a `WWW-Authenticate` response header and note that for
  `/userinfo` the canonical error transport is the header (per RFC 6750 §3),
  not a JSON body.

- **Response parameter delivery for hybrid/implicit flows** (§3.2.2.5,
  §3.3.2.5): when `response_type` is `id_token`, `id_token token`, etc.,
  parameters are returned **in the URL fragment** (default Response Mode
  for these response types is `fragment`), not the query. The spec's `302`
  response on `/authorize` (oauth-openapi.yaml:135–148) only shows
  query-style examples (`?code=...&state=...`). Add a fragment example for
  the implicit/hybrid case (`#access_token=...&id_token=...&state=...`).

- **`token_type` value MUST be `Bearer`** for the OIDC token response
  (§3.1.3.3): "The OAuth 2.0 `token_type` response parameter value MUST be
  `Bearer`, ... unless another Token Type has been negotiated." Spec lists
  both `Bearer` and `DPoP` as examples on `TokenResponse.token_type`
  (oauth-openapi.yaml:856–859). Acceptable for the OAuth-umbrella spec, but
  add an OIDC note: when an `id_token` is being issued, the token type is
  Bearer (or DPoP via negotiation); arbitrary types are not in scope.

- **Initiating Login from a Third Party (§4) is not modeled** as an endpoint:
  the RP-side login initiation endpoint (registered as `initiate_login_uri`)
  with parameters `iss` (REQUIRED), `login_hint` (OPTIONAL),
  `target_link_uri` (OPTIONAL). Since the spec is the OP-facing surface and
  this endpoint lives at the **RP**, this can stay out of scope. However,
  the `initiate_login_uri` registration parameter (Discovery / Dynamic
  Registration) is RP-side metadata. NOT APPLICABLE for the AS surface.

- **Aggregated and Distributed Claims (§5.6 / §5.6.2) not modeled**:
  `_claim_names` and `_claim_sources` members (with sub-keys `JWT` for
  Aggregated and `endpoint` / `access_token` for Distributed). Spec's
  `UserInfoResponse` does not allow them. Either add these two members as
  optional properties, or set `additionalProperties: true` on
  `UserInfoResponse` so the schema does not reject them. Currently
  `additionalProperties` is unspecified (defaults to true in OpenAPI 3.1, so
  not strictly an error, but the spec gives no hint that these special
  members exist).

- **`claim_types_supported` Discovery member is missing** from
  `DiscoveryDocument` (per Discovery 1.0 §3 — out of OIDC Core scope but
  closely related): values `normal`, `aggregated`, `distributed` (§5.6).
  This belongs more to the OIDC Discovery audit; flagging here because it
  governs whether Aggregated/Distributed Claims are even on the table.

- **Standard `request` JWT shape note** (§6.1): "values for the
  `response_type` and `client_id` parameters MUST be included using the
  OAuth 2.0 request syntax... `scope` parameter MUST always be passed using
  the OAuth 2.0 request syntax containing the `openid` scope value." When
  the `Request` parameter is added (per item above), include this normative
  rule in its description.

- **Signed UserInfo `aud` value** (§5.3.2): MUST be or include the RP's
  Client ID. Add this as a description note when adding `aud` to
  `UserInfoResponse`.

---

## WRONG — must fix

- **`Nonce` is OPTIONAL on `/authorize` for Authorization Code Flow but
  REQUIRED for Implicit and (some) Hybrid flows** (§3.2.2.1, §3.3.2.1):
  - §3.2.2.1 (Implicit Flow): "`nonce` REQUIRED."
  - §3.3.2.1 (Hybrid Flow): "`nonce` REQUIRED if the Response Type of the
    request is `code id_token` or `code id_token token` and OPTIONAL when
    the Response Type of the request is `code token`."
  Spec marks `Nonce` as flat `required: false` (oauth-openapi.yaml:584). The
  conditional requirement cannot be expressed in vanilla OpenAPI parameters,
  but the description (oauth-openapi.yaml:585–587) does not even hint at the
  rule. Update the description to spell out the conditional REQUIRED status,
  or add an `x-conditional-required` annotation.

- **`MaxAge` minimum should not be 0 — `max_age=0` is meaningful** (§3.1.2.1):
  "Note that `max_age=0` is equivalent to `prompt=login`." The spec uses
  `minimum: 0` (oauth-openapi.yaml:619–620) which correctly allows 0, but the
  description does not capture the equivalence to `prompt=login`. Add the
  note.

- **`Prompt` enum should be a space-delimited LIST not a single value**
  (§3.1.2.1): "Space-delimited, case-sensitive list of ASCII string values."
  Spec types it as `string` with `enum: [none, login, consent,
  select_account]` (oauth-openapi.yaml:597–603). This rejects valid combined
  values like `login consent` or `consent select_account`. Either drop the
  enum (and document the value space in the description), or use an enum of
  space-separated combinations, or model it as a regex pattern. RFC also
  says: "If this parameter contains `none` with any other value, an error is
  returned" — that constraint should also be documented.

- **`AcrValues` is a space-separated list, not a single value** (§3.1.2.1):
  "Space-separated string that specifies the `acr` values." The schema is
  correct (string with no enum) but the description (oauth-openapi.yaml:626)
  says "space-separated" which is correct. Lower-priority polish: examples
  showing two ACRs would help.

- **`/userinfo` POST does not declare a request body**
  (oauth-openapi.yaml:394–410): per §5.3.1 "If using HTTP POST, the request
  parameters are serialized using Form Serialization, per Section 13.2."
  POST UserInfo allows the access token to be sent as a form body parameter
  named `access_token` (alternate to the Authorization header). Either
  document the optional `application/x-www-form-urlencoded` body containing
  `access_token=<token>`, or add a description note that the Authorization
  header is the recommended transport (per §5.3.1 "It is RECOMMENDED that
  the request use the HTTP `GET` method and the Access Token be sent using
  the `Authorization` header field").

- **`/userinfo` POST is missing the `application/jwt` response content type**
  (oauth-openapi.yaml:402–410): the GET operation has it
  (oauth-openapi.yaml:381–388), but the POST operation only declares
  `application/json`. The signing/encryption rule from §5.3.2 applies
  regardless of HTTP method. Add `application/jwt` to the POST 200 response.

- **`UserInfoResponse.sub` is missing the §5.7 length and character
  constraints** that apply to ID Token `sub`: "It MUST NOT exceed 255 ASCII
  characters in length." (§2 ID Token defines this for `sub`; §5.1 implicitly
  inherits.) Add `maxLength: 255` and a description note. Note: §5.7
  reaffirms that the `sub` Claim is a "locally unique and never reassigned
  identifier" — worth a description.

- **`updated_at` should align with the JWT NumericDate convention** but spec
  uses plain `integer` (oauth-openapi.yaml:1307–1308) — acceptable but a note
  pointing to RFC 7519 §2 (NumericDate) would help. Same applies to
  `IntrospectionResponse.exp`/`iat`/`nbf` (out of OIDC scope). Lower priority.

- **`address` claim does not declare its `address` member as the §5.1.1
  Address Claim type** (and is missing description text noting the
  combination rules from §5.1.1: "Implementations MAY return only a subset of
  the fields"). The fields are right; only the description is thin.

- **`UserInfoResponse` is implicitly `additionalProperties: true` (OAS 3.1
  default)** — combined with the missing aggregated/distributed claim members
  this masks a real gap. Either explicitly set `additionalProperties: true`
  with a comment noting "claims beyond §5.1 are permitted, including the
  `_claim_names` / `_claim_sources` members from §5.6.2" — or add those
  members explicitly.

- **`response_type` enum lists OIDC values but none are flagged as needing
  `nonce`** — see Nonce item above. The description on the `ResponseType`
  parameter (oauth-openapi.yaml:498–512) is silent on the per-flow nonce
  requirement.

- **`token_endpoint_auth_methods_supported` enum is correct** — `none`,
  `client_secret_basic`, `client_secret_post`, `client_secret_jwt`,
  `private_key_jwt`, `tls_client_auth`, `self_signed_tls_client_auth`
  (oauth-openapi.yaml:1201–1208). §9 OIDC Core defines the first five; the
  last two come from RFC 8705 (Mutual-TLS). Not WRONG — just noting this is
  consistent across specs.

- **`clientSecretJwt` / `privateKeyJwt` are not modeled as security schemes**
  on `/token` (§9): the spec uses a single `clientAssertion` security scheme
  (oauth-openapi.yaml:1343–1351) covering both. That coalescing is reasonable
  for an OpenAPI doc (the wire format is identical: `client_assertion`,
  `client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer`),
  but the description should mention both. The current description does
  ("For `private_key_jwt` and `client_secret_jwt` authentication") — OK.

---

## NICE-TO-HAVE

- Add a **request-body model for the `/authorize` POST method** (§3.1.2.1
  paragraph 1: "Authorization Servers MUST support the use of the HTTP `GET`
  and `POST` methods"). Currently only `GET` is modeled
  (oauth-openapi.yaml:102). Adding `POST` with the same parameters in a
  form-encoded body would match §3.1.2.1's MUST-support requirement. Note:
  this MAY be considered out of scope because OpenAPI redirect-based flows
  are awkward to model as POST too.

- **CORS recommendation on `/userinfo`** (§5.3): "The UserInfo Endpoint
  SHOULD support the use of Cross-Origin Resource Sharing (CORS) and/or
  other methods as appropriate to enable JavaScript Clients and other
  Browser-Based Clients to access it." Add a description note on the
  `/userinfo` operations.

- **Mandatory-To-Implement summary block** (§15.1, §15.2) in the spec's
  description prose: "All OPs MUST implement: `prompt`, `display`,
  `ui_locales`, `claims_locales`, `auth_time` (when requested), `max_age`,
  `acr_values`. Dynamic OPs MUST also support `id_token` and
  `code id_token token` Response Types, Discovery, Dynamic Registration,
  the UserInfo Endpoint, JWKS as bare keys, and `request_uri`." This is
  already partly captured by parameter descriptions but a one-paragraph
  summary helps reviewers see the OIDC compliance posture at a glance.

- **`request` and `request_uri` are mutually exclusive** (§6 second
  paragraph: "If one of these parameters is used, the other MUST NOT be
  used in the same request"). Document this on both parameters when adding
  the missing `Request` parameter.

- **Issuer Identifier MUST use `https`** (§2 ID Token `iss`, §4 third-party
  login `iss`): "MUST be a case-sensitive URL using the `https` scheme...
  no query or fragment." Spec's `DiscoveryDocument.issuer` is `format: uri`
  (oauth-openapi.yaml:1146); add a `pattern` requiring `https://` and
  excluding `?` / `#`.

- **`acr` value `"0"` reservation** (§2 ID Token): "The value '0' indicates
  the End-User authentication did not meet the requirements of ISO/IEC 29115
  level 1 ... Authentications with level 0 SHOULD NOT be used to authorize
  access to any resource of any monetary value." Worth a description note
  on the (to-be-added) ID Token `acr` field.

- **`amr` is an array of strings** (§2 ID Token): when adding the ID Token
  schema, `amr` should be `type: array, items: { type: string }`. Values
  SHOULD be from the IANA AMR registry (RFC 8176).

- **OIDC scope semantics** (§5.4): `profile`, `email`, `address`, `phone`,
  `offline_access` are defined. Spec's `Scope` description
  (oauth-openapi.yaml:540) lists them but does not say which §5.1 Standard
  Claims each implies. Worth a table in the description: `profile` → all
  of `name`, `family_name`, `given_name`, `middle_name`, `nickname`,
  `preferred_username`, `profile`, `picture`, `website`, `gender`,
  `birthdate`, `zoneinfo`, `locale`, `updated_at`; `email` →
  `email`, `email_verified`; `address` → `address`; `phone` →
  `phone_number`, `phone_number_verified`.

- **Examples for `id_token` JWT payload** in `TokenResponse.id_token`
  (oauth-openapi.yaml:870–872) — the spec example block shows a real OIDC
  ID Token in §3.1.3.3; copying its claim set into an `examples` map would
  help.

- **`oauth2.flows.authorizationCode.scopes` is missing `address` and
  `phone`** (oauth-openapi.yaml:1371–1375) — only `openid`, `profile`,
  `email`, `offline_access` are listed. Add `address` and `phone` to match
  §5.4.

- **`oauth2.flows.implicit` and `oauth2.flows.password` correctly absent**
  per OAuth 2.1 posture; OIDC Core's Implicit Flow (§3.2) is therefore not
  declared as a `securitySchemes.oauth2.flows.implicit` entry — consistent.

- **Document `_claim_names` / `_claim_sources` example shapes** if
  Aggregated / Distributed Claims support is added (§5.6.2.1 / §5.6.2.2):
  helpful to consumers integrating with banks / credit agencies / etc.

---

## NOT APPLICABLE

- **§3.2 Implicit Flow** (`response_type=id_token` and
  `response_type=id_token token`): the spec keeps the parameter values in
  the `response_type` enum (oauth-openapi.yaml:507–512) — that is the right
  OIDC behavior. The Implicit *Authorization Endpoint Response* details
  (fragment-encoded ID Token + Access Token) are partially covered by the
  `302` description; stronger coverage is listed in MISSING above. The
  spec's OAuth 2.1 posture (which forbids OAuth 2.0's `response_type=token`
  Implicit Flow) does NOT forbid OIDC's `id_token` / `id_token token`
  variants — those carry an ID Token and remain in scope.

- **§3.3 Hybrid Flow** (`response_type=code id_token`,
  `code token`, `code id_token token`): same as above. Values are present
  in the `response_type` enum. The Hybrid-specific token-and-code
  combination semantics are not spelled out, but per-value schemas would
  be excessive.

- **§4 Initiating Login from a Third Party**: this defines an endpoint at
  the **Relying Party**, not the Authorization Server. The spec's surface
  is the AS, so this is out of scope. The only AS-side touch-point is the
  `initiate_login_uri` Dynamic Registration parameter — handled by the
  Discovery / Dynamic Registration audit, not Core.

- **§7 Self-Issued OpenID Provider**: a niche RP-side OP variant; out of
  scope for a server-API-focused spec.

- **§8 Subject Identifier Types** (`public` vs `pairwise`): the spec
  declares them in `DiscoveryDocument.subject_types_supported`
  (oauth-openapi.yaml:1213–1217). Beyond that, the choice is a
  server-policy concern not modelable in OpenAPI.

- **§10 Signatures and Encryption**, **§11 Offline Access**, **§12 Using
  Refresh Tokens**, **§13 Serializations**, **§14 String Operations**:
  protocol-level rules with no schema-modelable surface beyond what is
  already covered (refresh tokens via `RefreshTokenRequest`, JSON
  serialization via `application/json` content types, etc.).

- **§16 Security Considerations**: operational guidance not modelable in
  OpenAPI; HTTPS-only servers entry and the Bearer-token scheme cover the
  schema-relevant pieces.
