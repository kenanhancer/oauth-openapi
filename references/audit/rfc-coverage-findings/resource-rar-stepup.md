# Resource indicators, RAR & step-up — RFC 8707, 9396, 9470

> Generated from the 2026-10 RFC landscape audit (see [`../rfc-coverage-audit.md`](../rfc-coverage-audit.md)).
> Each finding was produced by a coverage agent and then checked by an independent
> adversarial verifier that tried to refute it against the YAML and the RFC text.
> Severity is the verifier's re-assessment. YAML line numbers refer to
> `oauth-openapi.yaml` as of commit `3e712d7`.

| Document | Published | Status | YAML coverage | High | Medium | Low |
|---|---|---|---|---|---|---|
| [RFC 8707](#rfc-8707-resource-indicators-for-oauth-20) | February 2020 | Proposed Standard | mostly | 0 | 1 | 6 |
| [RFC 9396](#rfc-9396-oauth-20-rich-authorization-requests) | May 2023 | Proposed Standard | mostly | 0 | 5 | 11 |
| [RFC 9470](#rfc-9470-oauth-20-step-up-authentication-challenge-protocol) | September 2023 | Proposed Standard | mostly | 0 | 1 | 5 |

**Cluster notes.** Method: I read RFC 8707, RFC 9396 and RFC 9470 in full from references/rfc-sources (byte-identical to rfc-editor.org) and all 2,704 lines of oauth-openapi.yaml. I grepped every protocol element plus synonyms, $refs, allOf members and description prose. I then cross-checked against the IANA oauth-parameters registry (updated 2026-08-24) and the IANA JWT registry, RFC Editor errata, OAuth 2.1 draft-16, RFC 9700, RFC 9068, FAPI 2.0 Security Profile Final and the MCP authorization spec (2025-06-18 and 2025-11-25).

Overall: the YAML has the wire surface of all three RFCs.
- RFC 8707: `resource` (repeatable array) on /authorize, /par, /device_authorization and all six grants, plus `invalid_target`.
- RFC 9396: `authorization_details` on /authorize, /par, three of six grants, the token response and introspection; `authorization_details_types_supported` metadata; an AuthorizationDetail schema with `type` REQUIRED and all five common fields; `invalid_authorization_details`.
- RFC 9470: the `insufficient_user_authentication` error, `acr_values`/`max_age` challenge auth-params (prose plus an example), `acr`/`auth_time` in introspection and in the JWT access token, `acr_values`/`max_age` request parameters, and `acr_values_supported`.

Schema additions still needed:
1. `authorization_details` on AuthorizationCodeTokenRequest. A YAML comment even contradicts RFC 9396 §6 here.
2. `authorization_details` on DeviceAuthorizationRequest, and on the device_code and jwt-bearer token requests.
3. The `authorization_details` claim in JWTAccessTokenClaims.
4. `unmet_authentication_requirements` in ErrorResponse.error. It is missing from the IANA registry, so the IANA diff could not flag it.
5. Client metadata `authorization_details_types`. This is blocked until the YAML models RFC 7591 client metadata.

Several RAR section numbers in the YAML are wrong (§5 and §6 cited for the token request and token response). These look inherited from the May-2026 9396 notes, which mis-cite RFC 9396 throughout.

The modular bundle (oauth-openapi-modular/dist/oauth-openapi.bundled.yaml) matches the main file for every cluster component, so fixes must also go through the split.

Lint check: I applied all suggested YAML edits together (22 exact replacements) to a scratch copy and linted it with the repo's .spectral.yaml. Result: 0 errors, 0 warnings, and the same 4 expected oas3-unused-component hints.

Nothing under the live repo or the snapshot was modified.

## RFC 8707 Resource Indicators for OAuth 2.0

*February 2020 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: recommended · vendoring: already-vendored*

**What it is.** RFC 8707 defines the `resource` request parameter. With it, a client tells the authorization server which protected resource(s) it wants an access token for, by absolute URI, in both authorization requests and token requests. Knowing the target lets the AS audience-restrict the token (for example the JWT `aud` claim), encrypt or shape it for that resource, and narrow scope per resource. The parameter may repeat, though one resource per token is encouraged, and unacceptable values are rejected with the new `invalid_target` error.

**Why it was created.** Anyone holding a bearer token can use it. A token valid at many resource servers can be replayed by one RS, or by a counterfeit RS, against the others. Before RFC 8707, deployments overloaded `scope` or invented proprietary parameters (for example Auth0's `audience`) to say where a token would be used. RFC 8707 standardised an interoperable way to name the target, so the AS can bind tokens to their audience.

<details><summary>Already modeled in the YAML (10)</summary>

- `resource` authorization-request parameter: components.parameters.Resource L880-895 (type array; style form, explode true; items format uri), referenced from paths./authorize L148
- `resource` token-request parameter on all six grants: components.schemas.ResourceIndicators L1202-1218, allOf'd at L1242 (authorization_code), L1272 (client_credentials), L1292 (refresh_token), L1313 (device_code), L1331 (jwt-bearer), L1353 (token-exchange)
- `resource` in the PAR body: PARRequest allOf ResourceIndicators L1592
- `resource` in the device authorization request: DeviceAuthorizationRequest allOf ResourceIndicators L1545
- Value constraints (absolute URI, no fragment, SHOULD NOT include a query): prose at L885-888 and L1209-1213; `format: uri` at L895 and L1218 enforces the scheme but not the fragment ban
- Repeatability: array plus explode at L889-894 and L1207/L1216; form bodies use the OAS default style form, explode true
- `invalid_target` error: components.schemas.ErrorResponse.error enum L1498-1499, reachable via OAuthError/OAuthErrorWithDPoPNonce on /token, /par and /device_authorization
- Audience surfaces: IntrospectionResponse.aud L1732-1737; JWTAccessTokenClaims.aud L2529-2535
- Effective scope in the token response: TokenResponse.scope L1440-1442
- RFC 8693 `audience` kept distinct from `resource`: TokenExchangeRequest.audience L1375-1382; the vendor-`audience` note in ResourceIndicators L1213-1215

</details>

**Follow-up on the May-2026 validation notes.** The prior notes (May 2026) listed 7 MISSING, 3 WRONG and 5 NICE-TO-HAVE items.

Fixed (5 of 7 MISSING, 2 of 3 WRONG):
- `resource` on all six grants via the ResourceIndicators mixin (L1203).
- `resource` as a repeatable array with style form/explode (L889-895).
- `resource` on /device_authorization (L1545) and /par (L1592).
- Absolute-URI / no-fragment prose (L885-888, L1209-1213).
- The non-standard `audience` was removed from ClientCredentialsTokenRequest, and TokenExchangeRequest.audience is now documented as RFC 8693 (L1375-1382).
- `resource` is now an array everywhere.

Partly fixed but now incorrect: the refresh-time rule was added, but as an overstated MUST on `scope` (L1304-1307).

Still open:
- The audience-restriction SHOULD (no link from TokenResponse/aud to `resource`).
- Naming `invalid_target` among /authorize redirect errors. This is description-only and falls under the documented /authorize redirect caveat, so it is not reported as a gap.
- All 5 nice-to-haves: examples, tenant-specific URI guidance, network-addressable guidance, single-resource encouragement, and the JAR string/array encoding.

**Notes.** Errata: one Verified editorial erratum (ID 6810, a typo in §4); no effect on the wire.

RFC 8707 defines no metadata.

Why it matters for an OAuth 2.1 server:
- OAuth 2.1-16 §7.1.3.6, §7.1.4 and §7.3.2, and RFC 9700 §2.3 and §4.10.2, say tokens SHOULD be audience-restricted and name `resource` as the mechanism.
- The MCP Authorization spec (2025-06-18 and 2025-11-25, 'Resource Parameter Implementation') requires MCP clients to send `resource` in both authorization and token requests. It notes that RFC 8707 audience binding works 'when the Authorization Server supports the capability'. An AS meant to serve MCP clients should therefore accept `resource` and set `aud` from it.

The RFC's implicit-flow example (Figure 1) and its 'implicit grant error response' IANA usage location are moot because Implicit is intentionally excluded.

### Findings (0 high · 1 medium · 6 low)

1. **[MEDIUM] Gap: Audience restriction of issued tokens to the requested resource(s)**  
   *Reference:* RFC 8707 §2 (final paragraph), §3; reinforced by RFC 9068 §3, RFC 9700 §2.3 and OAuth 2.1-16 §7.1.4  
   RFC 8707 §2 says 'The authorization server SHOULD audience-restrict issued access tokens to the resource(s) indicated by the resource parameter'. The restriction is conveyed in the JWT `aud` claim and the introspection `aud` member, and the AS may use the exact value or map it to a more general identifier. The YAML models both `aud` (IntrospectionResponse.aud L1732-1737, JWTAccessTokenClaims.aud L2529-2535) and `resource` (L880-895, L1203-1218), but nothing links them. Resource, ResourceIndicators, TokenResponse.access_token (L1411-1419) and both `aud` descriptions say nothing about it. An implementer working from the YAML therefore gets no signal for the SHOULD that is RFC 8707's main purpose.  
   *Suggested change:* Append to components.parameters.Resource.description (L884-888) and to ResourceIndicators.resource.description (L1208-1215): 'The AS SHOULD audience-restrict the issued access token to the indicated resource(s), using the exact value or an identifier mapped from it, via `aud` (RFC 8707 §2).' Set JWTAccessTokenClaims.aud.description (L2530) to 'REQUIRED. Resource server identifier(s); when the request carried `resource`, SHOULD equal that value (RFC 9068 §3, RFC 8707 §2).' Give IntrospectionResponse.aud (L1732) a description citing RFC 8707 §2.  
   *Verifier: partially correct —* The YAML hints at the resource-to-audience relationship (Resource L887-888 'request audience'; the RFC 9728 aud/resource match at L2285). It never states the AS-side SHOULD to audience-restrict tokens to the indicated resource(s) (RFC 8707 §2), nor that JWT `aud` SHOULD equal `resource` (RFC 9068 §3), on ResourceIndicators, TokenResponse, IntrospectionResponse.aud or JWTAccessTokenClaims.aud. The gap is real; only the wording 'nothing links them' is too strong.

2. **[LOW] Gap: `resource` value constraints: machine-checked fragment ban and the query SHOULD NOT**  
   *Reference:* RFC 8707 §2  
   `format: uri` (L895, L1218) corresponds to the RFC 3986 'URI' production. That production requires a scheme, so the value must be absolute, but it allows a '#fragment'. The MUST NOT on fragments therefore exists only in prose. The /authorize Resource description (L884-888) also leaves out the 'SHOULD NOT include a query component' wording that the mixin has (L1210-1211), so the two definitions have drifted apart.  
   *Suggested change:* Add `pattern: '^[^#]+$'` under `items` in components.parameters.Resource.schema (after L895) and in ResourceIndicators.resource (after L1218). Add 'and SHOULD NOT include a query component' to L886. Add schema `examples: [['https://api.example.com/app/'], ['https://cal.example.com/', 'https://contacts.example.com/']]` (RFC 8707 Figures 1-2). Lint-verified.  
   *Verifier: confirmed.*

3. **[LOW] Gap: Policy for an omitted `resource`, and the full `invalid_target` semantics**  
   *Reference:* RFC 8707 §2, §2.1  
   Per §2.1, if `resource` is omitted the AS MAY proceed with no specific resource or a default one, or MAY require the parameter and fail with `invalid_target`. Per §2, `invalid_target` means the resource is 'invalid, missing, unknown, or malformed', and it also covers 'an invalid combination of resource and scope'. The YAML lists the code (L1498-1499) but never states these triggers. A server author therefore cannot tell that a missing resource or a resource/scope mismatch should map to `invalid_target` rather than invalid_request or invalid_scope.  
   *Suggested change:* Add to the Resource and ResourceIndicators descriptions: 'If omitted, the AS MAY apply a default resource or MAY reject the request with `invalid_target`. Unparseable, unknown or unacceptable values, including an invalid resource/scope combination, yield `invalid_target` (RFC 8707 §2, §2.1).' Optionally extend ErrorResponse.error.description (L1476) with a one-line gloss for each extension code.  
   *Verifier: partially correct —* The YAML documents none of the invalid_target triggers or the omitted-resource policy; that part is true. But RFC 8707 makes invalid_target for a resource/scope mismatch optional ('can also be used'). For JWT access tokens, RFC 9068 §3 requires a default resource indicator in `aud` when `resource` is omitted, and prescribes invalid_scope for ambiguous scope-derived defaults. The suggested prose should reflect both points rather than routing every mismatch to invalid_target.

4. **[LOW] Gap: Effective scope in the token response after per-resource downscoping**  
   *Reference:* RFC 8707 §2.2 (restating RFC 6749 §5.1)  
   §2.2 asks the AS to downscope to what each resource needs. It reminds implementers that the AS 'must indicate the access token's effective scope to the client in the scope response parameter value when it differs from the scope requested'; RFC 6749 §5.1 makes `scope` OPTIONAL if identical and otherwise REQUIRED. TokenResponse.scope (L1440-1442) says only 'Granted scope, if different from what was requested' and does not state the REQUIRED-when-different rule.  
   *Suggested change:* Set TokenResponse.scope.description to: 'OPTIONAL if identical to the requested scope; otherwise REQUIRED (RFC 6749 §5.1). When `resource` is used, the AS should downscope to what the indicated resource needs and report the effective scope here (RFC 8707 §2.2).'  
   *Verifier: partially correct —* The 'present when different' rule is already conveyed at L1442. Only the explicit REQUIRED keyword (an RFC 6749 §5.1 item) and RFC 8707 §2.2's non-normative downscoping advice are missing.

5. **[LOW] Gap: `resource` inside a JAR request object (string vs array)**  
   *Reference:* RFC 8707 §2.1  
   In a JWT-secured authorization request, a single `resource` is a JSON string and multiple values are a JSON array of strings. The YAML has no request-object claims schema: components.parameters.Request (L950-960) and PARRequest.request (L1642-1644) are opaque strings, so this rule is undocumented.  
   *Suggested change:* Add to components.parameters.Request.description: 'Inside the Request Object, `resource` is a JSON string (one value) or an array of strings (several values) per RFC 8707 §2.1, and `authorization_details` is a JSON array (RFC 9396 §2).' If a RequestObjectClaims documentation schema is added later, model `resource: oneOf: [{type: string, format: uri}, {type: array, items: {type: string, format: uri}}]`.  
   *Verifier: confirmed.*

6. **[LOW] Gap: Security guidance on choosing `resource` values**  
   *Reference:* RFC 8707 §2, §3  
   §3 encourages a single resource per token: a bearer token with several audiences can be replayed by any of them at the others, and the AS may refuse multiple resources. Multi-tenant servers should use tenant-specific URIs, and the value should be the resource's network-addressable location where feasible. §2 asks clients for the most specific URI, normally the API's base URI. None of this guidance appears in the YAML; the Resource description (L887-888) only says the parameter MAY repeat.  
   *Suggested change:* Append to ResourceIndicators.resource.description: 'Prefer one resource per token: a multi-audience bearer token is usable at every listed resource (RFC 8707 §3). Use the most specific URI: the API's base URI, including the tenant path on multi-tenant hosts. Where feasible, use the resource's network-addressable location (RFC 8707 §2, §3).'  
   *Verifier: confirmed.*

7. **[LOW] Incorrect: L1302-1307 components.schemas.RefreshTokenRequest (allOf[3]).properties.scope.description**  
   *Reference:* RFC 8707 §2.2  
   The description says 'RFC 8707: the `resource` parameter on a refresh request MUST be a subset of those originally granted.' RFC 8707 §2.2 sets no such MUST. Acceptable resource values are 'at its sole discretion based on local policy', and for refresh_token and authorization_code requests 'such policy may limit the acceptable resources to those that were originally granted by the resource owner or a subset thereof'. The sentence is also attached to `scope` rather than `resource`. It also leaves out the authorization_code case: requesting a subset yields a token for that subset, while the refresh token stays bound to the full original grant.  
   *Suggested change:* Replace the last two sentences of L1305-1307 with 'See `resource` for refresh-time resource rules (RFC 8707 §2.2).' Then add to ResourceIndicators.resource.description: 'Acceptable values are at the AS's discretion. For authorization_code and refresh_token requests, local policy may limit them to the originally granted resources or a subset. Requesting a subset on authorization_code yields an access token for that subset, while any refresh token stays bound to the full original grant (RFC 8707 §2.2).'  
   *Verifier: confirmed.*

## RFC 9396 OAuth 2.0 Rich Authorization Requests

*May 2023 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: optional · vendoring: already-vendored*

**What it is.** RFC 9396 introduces `authorization_details`, a JSON array of typed objects. A client uses it to request fine-grained permissions such as 'pay 123.50 EUR to Merchant A' or 'read directory A, write file X' instead of coarse scope strings. Each object has a REQUIRED `type`, optional common fields (locations, actions, datatypes, identifier, privileges) and type-specific fields. The parameter can be sent on authorization, PAR, device and token requests; the AS must return what was granted in the token response and expose it to resource servers via JWT access tokens or introspection. RFC 9396 also adds the `invalid_authorization_details` error, the `authorization_details_types_supported` AS metadata and the `authorization_details_types` client metadata.

**Why it was created.** OAuth `scope` is a flat list of strings. That suits static, coarse permissions, but it cannot express transaction-specific data such as amount, creditor, a specific account or a document hash. Open banking (PSD2), remote e-signing and e-health need that data for informed consent, and implementers were squeezing structured data into scope values. RAR gives a structured, typed, extensible container that the AS can show the user and the RS can enforce.

<details><summary>Already modeled in the YAML (8)</summary>

- `authorization_details` on /authorize: components.parameters.AuthorizationDetails L870-878 (type string, JSON-encoded), referenced from paths./authorize L147
- `authorization_details` on PAR: PARRequest.authorization_details L1639-1641
- `authorization_details` token-request field: components.schemas.AuthorizationDetailsField L1220-1233, allOf'd in ClientCredentialsTokenRequest L1273, RefreshTokenRequest L1293 and TokenExchangeRequest L1354
- Token response member: TokenResponse.authorization_details L1454-1460 (array of AuthorizationDetail); mentioned in TokenResponse.description L1404-1405
- Introspection member: IntrospectionResponse.authorization_details L1754-1758 (plus description L1702-1703), carried into JWTIntrospectionResponse.token_introspection L1787-1789
- AuthorizationDetail object L2596-2630: `type` REQUIRED (L2603, L2606-2610), locations L2611-2616, actions L2617-2620, datatypes L2621-2624, identifier L2625-2627, privileges L2628-2630, additionalProperties true (L2604) for type-specific fields
- `invalid_authorization_details` error: ErrorResponse.error enum L1505-1506
- `authorization_details_types_supported`: OAuthServerMetadata L2200-2203, inherited by OpenIDProviderMetadata via allOf L1912-1913; also reused by RFC 9728 in ProtectedResourceMetadata L2323-2325

</details>

**Follow-up on the May-2026 validation notes.** The prior notes listed 9 MISSING and 4 WRONG items.

Fixed (7 of 13):
- M1: AuthorizationDetail schema (L2596).
- M2: `type` required.
- M3: all five common fields.
- M4: PAR field (L1639).
- M6: introspection member (L1754).
- M8: `invalid_authorization_details` (L1506).
- W2: TokenResponse items now $ref AuthorizationDetail.

Partly fixed:
- M5: the token-request field exists only on client_credentials, refresh_token and token-exchange; authorization_code, device_code and jwt-bearer still lack it.
- W3: 'MAY be a subset' was added, but the description still cites §6 and leaves out the §7 MUST and the §7.1 enrichment.

Still open:
- M7: the JWT access-token claim (JWTAccessTokenClaims now exists but lacks it).
- M9: no description on the metadata field.
- W1: no contentSchema on the JSON-string parameter.
- W4: no 'single URL-encoded JSON value' wording.

Caution: the prior notes mis-cite RFC 9396 throughout. They place token requests in §4, the token response in §6 and PAR in §7, and cite a nonexistent §13.4 'type registry'. They quote unconditional introspection and type MUSTs that the RFC does not contain, and give the date as April 2023 (it is May 2023). The YAML's §5 and §6 mis-cites appear to come from these notes.

**Notes.** No errata.

CIBA backchannel authentication requests (§3) are not checked here because the YAML models no CIBA endpoint; that belongs to the OIDC cluster.

Watch item: draft-ietf-oauth-rar-metadata-remediation-00 (a WG document, 23 Aug 2026) would add the AS metadata `authorization_details_types_metadata_endpoint`, an `insufficient_authorization` error for resource servers, and an `authorization_remediation` WWW-Authenticate parameter. These are the RAR counterpart of RFC 9470's challenge.

Also, references/audit/live-idp-comparison.md L96 says 'FAPI 2.0 mandates it'. In fact the FAPI 2.0 Security Profile Final only recommends RAR (§5.3.2.2 NOTE 5).

OAuth 2.1-16 §7.1.4 and RFC 9700 §2.3 cite RAR as a MAY for restricting tokens to particular resources and actions.

### Findings (0 high · 5 medium · 11 low)

1. **[MEDIUM] Gap: `authorization_details` claim in JWT access tokens**  
   *Reference:* RFC 9396 §9, §9.1, §14.2  
   §9 says the AS MUST make the granted authorization details available to the RS. §9.1 adds that for JWT access tokens the AS is RECOMMENDED to include them, filtered to the token's audience, as a top-level `authorization_details` claim; the claim is in the IANA JWT Claims registry. components.schemas.JWTAccessTokenClaims (L2514-2573) lists iss through cnf but not this claim; it is only admitted through additionalProperties true. A server or RS built from the decoded-payload schema will not emit or read it, and introspection (L1754-1758) remains the only modeled channel.  
   *Suggested change:* Add to JWTAccessTokenClaims.properties, after `scope` (L2556-2558): `authorization_details: {type: array, items: {$ref: '#/components/schemas/AuthorizationDetail'}, description: 'RAR (RFC 9396 §9.1): RECOMMENDED top-level claim with the granted authorization details, filtered to this token's audience.'}`  
   *Verifier: confirmed.*

2. **[MEDIUM] Gap: `authorization_details` on the device authorization request**  
   *Reference:* RFC 9396 §3 (with RFC 8628 §3.1)  
   §3 says the parameter can be used 'in all places where the scope parameter is used for the same purpose' and explicitly names 'device authorization requests as specified in [RFC8628]'. DeviceAuthorizationRequest (L1538-1550) carries `scope` and `resource` but not `authorization_details`, so the YAML gives a device-flow client no way to request RAR permissions.  
   *Suggested change:* Add `- $ref: '#/components/schemas/AuthorizationDetailsField'` to DeviceAuthorizationRequest.allOf (after L1545). Generalise the mixin comment (L1220-1223) to 'authorization_details on token and authorization-style requests (RFC 9396 §3, §6)'.  
   *Verifier: confirmed.*

3. **[MEDIUM] Gap: AS duty to validate authorization details**  
   *Reference:* RFC 9396 §5, §8, §2.1  
   §5 says the AS MUST refuse unknown types. It MUST abort with `invalid_authorization_details` when an object has an unknown type, unknown fields for a known type, fields of the wrong type, invalid values, or missing required fields; §8 applies the same rules at the token endpoint. AuthorizationDetail (L2596-2630) has to stay open (any `type` string, additionalProperties true). Yet neither it, the /authorize parameter (L870-878), PARRequest nor AuthorizationDetailsField states these MUSTs. A server generated from the YAML would therefore accept arbitrary types and fields.  
   *Suggested change:* Add to AuthorizationDetail.description: 'additionalProperties is open only because type-specific fields are deployment-defined. The AS MUST reject unknown types, and unknown, wrongly typed, invalid or missing fields for a known type, with invalid_authorization_details (RFC 9396 §5, §8).' Document the deployment pattern: per-type schemas of the form `allOf: [{$ref: AuthorizationDetail}, {properties: {...}}]` with `unevaluatedProperties: false`, selected by `discriminator: {propertyName: type, mapping: {...}}`, and keep the type list in sync with authorization_details_types_supported.  
   *Verifier: confirmed.*

4. **[MEDIUM] Incorrect: L1220-1223, comment on components.schemas.AuthorizationDetailsField; L1235-1266, components.schemas.AuthorizationCodeTokenRequest (allOf L1240-1243 lacks the mixin)**  
   *Reference:* RFC 9396 §6, §6.1, §11.2  
   The comment limits the token-request parameter to client_credentials, refresh_token and token-exchange, and AuthorizationCodeTokenRequest does not include it. RFC 9396 §6 names authorization_code explicitly ('the underlying grant (in case of grant types authorization_code, refresh_token, etc.)'). Figure 10 shows a client narrowing an authorization-code grant to `list_accounts` at the token endpoint, and §11.2 says it 'should work with any grant type, especially authorization_code and refresh_token'. A server generated from the YAML has no field for the most common RAR token request.  
   *Suggested change:* Add `- $ref: '#/components/schemas/AuthorizationDetailsField'` to AuthorizationCodeTokenRequest.allOf (after L1242). Rewrite the comment as: 'RFC 9396 §6: optional on any grant. The AS checks the requested details against the underlying grant (authorization_code, refresh_token, ..., compared per the type's rules, §6.1) or, for client_credentials, the client's policy; otherwise it returns invalid_authorization_details.'  
   *Verifier: confirmed.*

5. **[MEDIUM] Incorrect: L1454-1460 components.schemas.TokenResponse.properties.authorization_details (description L1456-1458); L1404-1405 TokenResponse.description**  
   *Reference:* RFC 9396 §7, §7.1  
   Both places cite 'RFC 9396 §6' (Token Request) for the response member, which is defined in §7. The description 'granted authorization detail objects. MAY be a subset of those requested' leaves out §7's 'the AS MUST also return the authorization_details as granted by the resource owner and assigned to the respective access token'. Calling it a 'subset' also contradicts §7.1, under which the AS may enrich the granted details (for example by adding the account IDs the user selected).  
   *Suggested change:* Change both citations to §7 and set the description to: 'RAR (RFC 9396 §7): the authorization details granted by the resource owner and assigned to this access token. The AS MUST return them when the token carries authorization details. They MAY differ from the request: narrowed by the user, with values omitted (§7), or enriched by the AS where the type allows it (§7.1). If the token request carried no authorization_details, the AS chooses them (§7).'  
   *Verifier: partially correct —* The section mis-cite (§6 should be §7) and the missing §7 MUST are confirmed. 'MAY be a subset' does not contradict §7.1, because MAY does not exclude enrichment, but it is incomplete. It omits enrichment (§7.1) and the case where the token request carries no authorization_details and the AS chooses them (§7).

6. **[LOW] Gap: `authorization_details` on the device_code and jwt-bearer token requests**  
   *Reference:* RFC 9396 §6, §11.2  
   §6 makes the token-request parameter generic: the AS checks the underlying grant ('authorization_code, refresh_token, etc.') or, for client_credentials, the client's policy. §11.2 says default handling 'should work with any grant type'. DeviceCodeTokenRequest (L1309-1324) and JWTBearerTokenRequest (L1326-1347, which already carries `scope` at L1346) do not include AuthorizationDetailsField. The authorization_code omission is reported under incorrect.  
   *Suggested change:* Add `- $ref: '#/components/schemas/AuthorizationDetailsField'` to DeviceCodeTokenRequest.allOf (after L1313) and JWTBearerTokenRequest.allOf (after L1331).  
   *Verifier: confirmed.*

7. **[LOW] Gap: Meaning of `authorization_details_types_supported`**  
   *Reference:* RFC 9396 §10, §11.2  
   OAuthServerMetadata.authorization_details_types_supported (L2200-2203) has no description. §10 defines it as the JSON array of authorization details types the AS supports, i.e. the values accepted in AuthorizationDetail.type. §11.2 lists advertising it as part of minimal support.  
   *Suggested change:* Add `description: 'Authorization details type values the AS supports, i.e. the values accepted in AuthorizationDetail.type (RFC 9396 §10, §11.2).'`  
   *Verifier: confirmed.*

8. **[LOW] Gap: Client registration metadata `authorization_details_types`**  
   *Reference:* RFC 9396 §10, §14.5  
   Clients MAY declare the types they will use through `authorization_details_types`, which is registered in IANA Dynamic Client Registration Metadata. It is absent from the YAML and also appears on the IANA absence list. The reason is that the YAML models no client-metadata or registration schema at all; registration_endpoint (L1965-1968) is its only RFC 7591 element.  
   *Suggested change:* When the RFC 7591 client-metadata schema is added (DCR cluster), include `authorization_details_types: {type: array, items: {type: string}, description: 'Authorization details types the client will use (RFC 9396 §10).'}` and note that an AS may limit a client to these types (RFC 9396 §11.1).  
   *Verifier: confirmed.*

9. **[LOW] Gap: Machine-readable link from the JSON-string fields to AuthorizationDetail[], and the single-value encoding**  
   *Reference:* RFC 9396 §2, §3, §11.4  
   The /authorize parameter (L870-878), AuthorizationDetailsField (L1227-1233) and PARRequest.authorization_details (L1639-1641) are plain `type: string`. Only prose points at AuthorizationDetail, so validators and generators cannot check the decoded array. The parameter description also does not say that the array is serialised as one JSON value and then URL-encoded (§3, Figure 8) rather than sent as repeated parameters. Inside a JAR request object it is a native JSON array, not a string.  
   *Suggested change:* Add `contentMediaType: application/json` and `contentSchema: {type: array, items: {$ref: '#/components/schemas/AuthorizationDetail'}}` to all three fields; for the query parameter, the Parameter Object `content: {application/json: {schema: ...}}` form is an alternative. Add to L875-876: 'One JSON array serialised as a single value and URL-encoded, never repeated parameters (RFC 9396 §3); prefer PAR for large or sensitive values (§11.4).' Consider having PARRequest reuse the AuthorizationDetailsField mixin. Lint-verified.  
   *Verifier: partially correct —* The real gap is the missing contentMediaType/contentSchema (or Parameter `content`) link to AuthorizationDetail[]. The 'single value, not repeated parameters' point is a clarity nicety, since 'JSON-encoded array' already implies it. 'Native JSON array inside a request object' is a reasonable inference, not RFC 9396 text.

10. **[LOW] Gap: Processing, consent and security rules**  
   *Reference:* RFC 9396 §3.1, §3.2, §12, §13  
   None of these rules appear in the YAML: - §3.1: the AS MUST process `scope` and `authorization_details` together and MUST show the user the merged set at consent. - §3.2: `resource` does not change how `authorization_details` is processed. - §12: clients MUST protect integrity when it matters (signed request objects or PAR); the AS MUST sanitise the data against injection; string comparison follows RFC 8259 with no normalisation. - §13: details are shared with clients and RSs on a need-to-know basis.  
   *Suggested change:* Add a short 'Processing rules' paragraph to components.parameters.AuthorizationDetails.description covering the §3.1 MUSTs, §3.2, and the §12 sanitise and no-normalisation rules. Point to /par and the `request` parameter for integrity and confidentiality, and reference the paragraph from AuthorizationDetail.description.  
   *Verifier: confirmed.*

11. **[LOW] Incorrect: L1220 comment and L1230 description, components.schemas.AuthorizationDetailsField**  
   *Reference:* RFC 9396 §6  
   Cites 'RFC 9396 §5' for authorization_details on token requests. §5 is the Authorization Error Response; token requests are §6.  
   *Suggested change:* Replace '§5' with '§6' in both places.  
   *Verifier: confirmed.*

12. **[LOW] Incorrect: L2611-2616 components.schemas.AuthorizationDetail.properties.locations.items (format: uri)**  
   *Reference:* RFC 9396 §2.2  
   RFC 9396 §2.2 defines locations as 'An array of strings representing the location of the resource or RS. These strings are typically URIs'. `format: uri` makes URIs mandatory, so a validator that enforces formats would reject RFC-valid values such as abstract RS identifiers.  
   *Suggested change:* Drop `format: uri` from locations.items, describe the strings as 'typically URIs identifying the RS', and keep URIs in the examples.  
   *Verifier: confirmed.*

13. **[LOW] Incorrect: L2597-2601 components.schemas.AuthorizationDetail.description; L2606-2610 properties.type.description**  
   *Reference:* RFC 9396 §2, §2.1, §10  
   The YAML says types are 'defined by extending RFCs (e.g. `payment_initiation` for FAPI 2.0)' and that fields are 'added by each type's consuming RFC'. Per RFC 9396 §2.1, the AS controls how `type` is interpreted and which fields it allows; types are defined by the API or deployment. RECOMMENDED practice is easily copied values and, for APIs deployed across servers, a collision-resistant namespace such as a URI. §10 puts type registration out of scope, so there is no IANA registry. `payment_initiation` comes from RFC 9396's own examples. The FAPI 2.0 Security Profile defines no types; it only recommends RAR (§5.3.2.2 NOTE 5).  
   *Suggested change:* Set type.description to: 'REQUIRED. Authorization details type identifier, unique for the described API in the context of the AS, which controls its interpretation and allowed fields (RFC 9396 §2, §2.1). RECOMMENDED: easily copied values (e.g. ASCII) and, for APIs deployed across servers, a collision-resistant namespace such as a URI. Not IANA-registered (§10).' Add `examples: [payment_initiation, account_information, 'https://scheme.example.org/files']` and replace 'consuming RFC' with 'API/type definition' in the schema description.  
   *Verifier: confirmed.*

14. **[LOW] Incorrect: AuthorizationDetail.description says authorization details are 'echoed back in token and introspection responses'** — *found by the verifier*  
   *Reference:* RFC 9396 §7, §7.1, §9.1, §9.2  
   AuthorizationDetail.description says authorization details are 'echoed back in token and introspection responses'. RFC 9396 instead has the AS return the details granted by the resource owner and assigned to the token. These may be narrowed, have values omitted, or be enriched (§7, §7.1). Copies given to resource servers may be filtered to the audience (§9.1) and, for introspection, 'filtered and extended for the RS' (§9.2). 'Echoed back' misdescribes all of these.  
   *Suggested change:* Replace 'echoed back in token and introspection responses' with 'the granted (possibly narrowed or enriched) details are returned in the token response (§7, §7.1) and made available to resource servers, filtered per audience/RS, via the JWT claim or introspection (§9).'

15. **[LOW] Gap: The introspection member lacks RFC 9396 §9.2's rules** — *found by the verifier*  
   *Reference:* RFC 9396 §9.2, §13  
   The introspection member lacks RFC 9396 §9.2's rules. If present, it MUST be a top-level member. It MUST have the §2 structure, 'potentially filtered and extended for the RS making the introspection request'. The description gives no hint that the AS should filter per requesting RS rather than return the full grant to every RS (see also §13: share on a need-to-know basis). The structure is modeled correctly (top-level, items $ref AuthorizationDetail); only the semantics are missing.  
   *Suggested change:* Description: 'RAR (RFC 9396 §9.2): when present, the authorization details assigned to this token, in the §2 structure, potentially filtered and extended for the RS making the introspection request; share on a need-to-know basis (§13).'

16. **[LOW] Gap: The common-data-field semantics of RFC 9396 §2.2 are undocumented** — *found by the verifier*  
   *Reference:* RFC 9396 §2.2  
   The common-data-field semantics of RFC 9396 §2.2 are undocumented. Requested permissions are 'the product of all the values' when fields are combined. Allowable values are 'determined by the API being protected, as defined by a particular "type" value'. `privileges` (the 'types or levels of privilege being requested') has no description at all.  
   *Suggested change:* Add privileges.description 'Types or levels of privilege requested at the resource (RFC 9396 §2.2).' Add to AuthorizationDetail.description: 'Common fields are optional building blocks whose allowable values are defined per type. Within one object, the requested permissions are the product of all listed values; use separate objects for finer control (§2.2).'

## RFC 9470 OAuth 2.0 Step Up Authentication Challenge Protocol

*September 2023 · Proposed Standard · YAML coverage: **mostly** · relevance to an AS: optional · vendoring: already-vendored*

**What it is.** RFC 9470 lets a resource server tell a client that the user authentication behind the presented access token is too weak or too old. It does so with a new error, `insufficient_user_authentication`, plus `acr_values` and `max_age` auth-params in the WWW-Authenticate challenge (Bearer or DPoP). The client then sends a new authorization request carrying the OIDC `acr_values`/`max_age` parameters. The AS authenticates the user accordingly, reports the outcome as `acr` and `auth_time` in the access token or the introspection response, and should fail with `unmet_authentication_requirements` if the requested acr cannot be met.

**Why it was created.** Resource servers increasingly make risk-based decisions, such as a purchase above a threshold or a sensitive operation, that need stronger or more recent user authentication than the AS applied when it issued the token. There was no interoperable way for an RS to say 'step up' and specify what is required. There was also no standard place in access tokens or introspection responses to say how and when the user authenticated.

<details><summary>Already modeled in the YAML (7)</summary>

- `insufficient_user_authentication` error: ErrorResponse.error enum L1510-1511
- WWW-Authenticate `acr_values`/`max_age` auth-params: components.headers.WWWAuthenticateBearerDPoP L1000-1025 (prose L1014-1018, Bearer example L1025), used by components.responses.ProtectedResourceError L1091-1107 on /userinfo 401/403 (L512-515, L562-565)
- `acr_values`/`max_age` authorization request parameters: components.parameters.AcrValues L838-844 and MaxAge L829-836 (integer, minimum 0), referenced from paths./authorize L143-144; PARRequest.max_age L1622-1624 and acr_values L1629-1630
- Introspection `acr`/`auth_time`: IntrospectionResponse.acr L1742-1744 and auth_time L1745-1747 (NumericDate), both citing RFC 9470 §6.2
- JWT access token `acr`/`auth_time`: JWTAccessTokenClaims.auth_time L2549-2550 and acr L2551-2552
- ID Token `acr`/`auth_time` (the OIDC behaviour §5 builds on): IDTokenClaims.auth_time L2489-2491 and acr L2495-2497
- `acr_values_supported` AS metadata: OAuthServerMetadata L2149-2151

</details>

**Follow-up on the May-2026 validation notes.** There is no prior rfc-validation file for RFC 9470; it was added in the 2026-06-07 update (references/audit/rfc-audit-synthesis.md, 'Update log'). Everything that log claims is present: `insufficient_user_authentication` (L1511), introspection `acr`/`auth_time` (L1742-1747) and the `acr_values`/`max_age` challenge params (L1014-1018, L1025).

**Notes.** Errata: one Reported (not yet verified) technical erratum, ID 7951. It says Figure 7's `auth_time` should be no later than `iat`, so any introspection or JWT examples added to the YAML should keep auth_time <= iat.

The OIDF spec that defines `unmet_authentication_requirements` (June 2019) is neither vendored nor IANA-registered. If the code is added, consider vendoring https://openid.net/specs/openid-connect-unmet-authentication-requirements-1_0.html into references/oidf-sources.

The 'step-up authorization flow' in MCP 2025-11-25 is scope step-up via `insufficient_scope`, not RFC 9470.

OAuth 2.1-16 lists RFC 9470 only as an extension (Appendix D).

### Findings (0 high · 1 medium · 5 low)

1. **[MEDIUM] Gap: `unmet_authentication_requirements` authorization error**  
   *Reference:* RFC 9470 §5 (OIDCUAR §1)  
   Per §5, for access tokens the AS SHOULD treat the requested acr as necessary: include it in the token if it was met, 'otherwise, the authorization request fails and returns an unmet_authentication_requirements error as defined in [OIDCUAR]'. ErrorResponse.error (L1477-1517) has no such value, even though it already lists OIDC errors that only occur at the authorization endpoint (L1512-1517). The code is defined in 'OpenID Connect Core Error Code unmet_authentication_requirements 1.0' §1 (authorization endpoint). It is missing from the IANA OAuth Extensions Error Registry (checked 2026-10-10), so the IANA-vs-YAML diff cannot catch it.  
   *Suggested change:* Add to the OIDC group at L1512-1517: `# OpenID Connect Core Error Code unmet_authentication_requirements 1.0 §1 (authorization endpoint; RFC 9470 §5)` followed by `- unmet_authentication_requirements`. Mention it in the AcrValues description. Lint-verified.  
   *Verifier: confirmed.*

2. **[LOW] Gap: AS behaviour for `acr_values`/`max_age` in plain OAuth step-up requests**  
   *Reference:* RFC 9470 §4, §5  
   AcrValues (L838-844), MaxAge (L829-836) and their PAR equivalents (L1622-1630) are described only with the prefix 'OIDC:'. RFC 9470 §4 reuses them for plain OAuth step-up. §5 expects the AS to put the resulting `acr` and `auth_time` in the access token and to treat a requested acr as necessary (SHOULD). None of this is stated, so an OAuth-only AS built from the YAML may ignore these parameters for access tokens.  
   *Suggested change:* Extend the AcrValues description: '...in order of preference. Also used for OAuth step-up (RFC 9470 §4): the AS SHOULD treat the requested value as required, putting it in the access token's `acr` or failing with `unmet_authentication_requirements` (§5).' Extend MaxAge: '...Also used for step-up (RFC 9470 §4); the AS then includes `auth_time` in the access token and the introspection response (§5, §6).'  
   *Verifier: partially correct —* The claim is correct for components.parameters.AcrValues and MaxAge, which are described only as 'OIDC:'. Their PAR equivalents (L1622-1630) carry no description whatsoever, not an 'OIDC:' one, so they need the step-up wording too.

3. **[LOW] Gap: Meaning of `acr`/`auth_time` in JWT access tokens**  
   *Reference:* RFC 9470 §6.1 (RFC 9068 §2.2.1)  
   JWTAccessTokenClaims.auth_time (L2549-2550) and acr (L2551-2552) have no descriptions. RFC 9470 §6.1 uses them to tell the RS about the user-authentication event. Per RFC 9068 §2.2.1 their values are fixed when the user authenticates and do not change when tokens are renewed, which is a key rule for refresh-token flows.  
   *Suggested change:* auth_time.description: 'Time of the user-authentication event (RFC 9068 §2.2.1). Fixed at authentication time and unchanged on refresh or exchange. Present when max_age was requested (RFC 9470 §5, §6.1).' acr.description: 'ACR satisfied by that event (RFC 9068 §2.2.1). Reflects the requested acr_values for step-up (RFC 9470 §5, §6.1).'  
   *Verifier: confirmed.*

4. **[LOW] Gap: `acr_values_supported` as the step-up capability signal**  
   *Reference:* RFC 9470 §7  
   OAuthServerMetadata.acr_values_supported (L2149-2151) has no description. Under RFC 9470 §7, its presence signals that the AS understands and honours `acr_values` and `max_age` in authorization requests.  
   *Suggested change:* Add `description: 'ACR values supported (OIDC Discovery §3). Its presence signals that the AS honours the acr_values and max_age authorization request parameters (RFC 9470 §7).'`  
   *Verifier: confirmed.*

5. **[LOW] Gap: Challenge auth-param semantics, the DPoP variant and RS cautions**  
   *Reference:* RFC 9470 §3, §9  
   WWWAuthenticateBearerDPoP (L1014-1018, L1025) names the auth-params but not their meaning: - `acr_values` is a space-separated list in order of preference, and the RS requires one of the values. - `max_age` is the allowed seconds since the last active authentication; it must be a non-negative integer, sent as a token or quoted-string. - Both MAY appear together, and `scope` MAY be added (RFC 6750 §3.1). Only a Bearer example exists, although §3 also applies the error to DPoP (RFC 9449) challenges; RFC 9470's examples use HTTP 401. The §9 cautions are also missing: `acr_values` can reveal high-value users, and challenging before validating the token leaks the requirements.  
   *Suggested change:* Extend L1017-1018 with the semantics above. Add the example `DPoP algs="ES256", error="insufficient_user_authentication", error_description="More recent authentication is required", max_age="5"`. In ProtectedResourceError.description (L1092-1098), note that step-up challenges use HTTP 401 (RFC 9470 Figures 2-3) and add the §9 disclosure caution. Lint-verified.  
   *Verifier: confirmed.*

6. **[LOW] Gap: Nothing tells clients to treat the access token as opaque** — *found by the verifier*  
   *Reference:* RFC 9470 §2 (RFC 9068 §6)  
   Nothing tells clients to treat the access token as opaque. RFC 9470 §2 says a client 'must not attempt to inspect the content of the access token to determine the associated authentication information or other details', citing RFC 9068 §6 ('The client MUST NOT inspect the content of the access token'). The YAML points readers at the decoded JWT payload, which carries acr/auth_time, without this caveat. A step-up client should learn its requirements from the RS challenge, not by decoding its token.  
   *Suggested change:* Append to TokenResponse.access_token.description and JWTAccessTokenClaims.description: 'The decoded shape is for the AS and resource servers; clients MUST NOT inspect access-token contents (RFC 9068 §6), including acr/auth_time for step-up (RFC 9470 §2). Step-up requirements are learned from the RS challenge.'

## Verifier corrections to the summaries above

- RFC 8707 notes: OAuth 2.1-16 §7.1.3.6 does not mention `resource` at all ('Authorization servers SHOULD issue bearer tokens that contain an audience restriction'). §7.1.4 and §7.3.2 of OAuth 2.1-16, and RFC 9700 §2.3, say clients and ASes 'MAY utilize the parameters scope or resource'. RFC 9700 §4.10.2 says the RFC 8707 mechanism 'can be used for this or the information can be encoded in the scope value', and states no SHOULD of its own. So these documents name `resource` as one option alongside `scope`, not as 'the mechanism'.
- RFC 8707 notes: calling the IANA 'implicit grant error response' usage location moot is fine, but `invalid_target` itself is not moot at /authorize. RFC 8707 §2 ('in response to an authorization request or access token request') and §2.1 apply it to code-flow authorization error redirects as well; only modeling that redirect falls under the documented /authorize caveat.
- RFC 9396 prior_validation_followup: 'They quote ... type MUSTs that the RFC does not contain' is only half right. RFC 9396 §2 does make `type` mandatory ('This field is REQUIRED'). The prior notes present a paraphrase as a quote ('Each JSON object MUST contain a `type` field') and cite the wrong sections (§2.1/§3), but the requirement exists. The introspection quote is genuinely wrong: §9.2 is conditional ('If the AS includes authorization detail information ... MUST be conveyed with authorization_details as a top-level member').
- cluster_notes: the RAR mis-cites 'look inherited from the May-2026 9396 notes' only for the token-response §6 cite (notes W2/W3 also use §6). The notes place token requests in §4 (M5), so the YAML's '§5' for token requests (L1220, L1230) does not come from them.
- cluster_notes: 'the YAML has the wire surface of all three RFCs' is overstated for RFC 9396. Its IANA-registered 'token request' usage is missing on authorization_code, the main RAR grant. The §3 device-authorization usage and the §9.1/§14.2 JWT claim are also absent. That fits 'mostly', not full wire coverage.
- RFC 9396 incorrect #5 reasoning: §10's last sentence ('The registration of authorization details types with the AS is outside the scope of this specification') is about registering types with an AS. That no IANA type registry exists follows from §14, which creates none. The conclusion stands; the cited basis is off.
- RFC 9396 gap 4: §11.2's 'should work with any grant type' is about default behaviour for adding authorization details to access tokens and introspection responses, not about accepting the token-request parameter. RFC 9396 §6 ('authorization_code, refresh_token, etc.') is the correct basis.
- RFC 8707 gap 5 and RFC 9396 gap 7 suggestions: saying `authorization_details` inside a JAR request object is a native JSON array is an inference, not 'RFC 9396 §2' text. RFC 9396 §3 says only 'Parameter encoding is determined by the respective context', and RFC 9101 §4 fixes only string and number encodings.
- RFC 9470 gap 1 suggested_change: every value now in ErrorResponse.error is IANA-registered, including all five OIDC codes (verified against the 2026-08-24 registry). `unmet_authentication_requirements` would be the only unregistered value, even though its OIDF spec §2.1 requested registration. The fix must therefore also reword ErrorResponse.description L1467-1469 ('union of all registered values') and error.description L1476 ('from the IANA OAuth Extensions Error Registry'). Minor: the OIDF document is dated June 2019 on openid.net, while RFC 9470 [OIDCUAR] cites it as '8 May 2019'.
- Further watch items besides draft-ietf-oauth-rar-metadata-remediation-00 (all verified in the downloaded drafts): draft-ietf-oauth-first-party-apps-04 (WG 'Consensus-Waiting for Write-Up') reuses the RFC 9470 challenge to start a flow at its authorization challenge endpoint (§3.3, §7). draft-ietf-oauth-identity-assertion-authz-grant-04 carries RFC 8707 `resource` and RFC 9396 `authorization_details`. draft-ietf-oauth-identity-chaining (in the RFC Editor queue) uses RFC 8707 `resource` in token exchange.
