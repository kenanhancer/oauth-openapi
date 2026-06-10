# Real-world discovery-metadata validation

**Analysis date:** 2026-05-10 (refreshed 2026-06-07)
**Spec under test:** `oauth-openapi.yaml`, `components.schemas.OAuthServerMetadata`
(surfaced on both discovery endpoints via `OpenIDProviderMetadata`).

> **2026-06-07 note:** at audit time this schema was named `DiscoveryDocument`;
> it was later split into `OAuthServerMetadata` (the RFC 8414 base) +
> `OpenIDProviderMetadata` (the OIDC wrapper). Field names below are unchanged.

This document compares our authorization-server metadata schema against the
**live** `.well-known/openid-configuration` responses of three real
authorization servers, to verify that the schema is neither under-specified
(missing standard fields) nor over-specified (modeling fields nobody
publishes).

## Sources fetched

| IdP | Discovery URL | Top-level fields |
|---|---|---|
| Google | `https://accounts.google.com/.well-known/openid-configuration` | 17 |
| Microsoft | `https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration` | 25 |
| Auth0 (sample tenant) | `https://samples.auth0.com/.well-known/openid-configuration` | 29 |

Our spec defined **23 fields**. After this comparison we'll bring it to **38**.
(As of 2026-06-07, after further RFC additions, `OAuthServerMetadata` carries
**67 fields**.)

## Universal core — published by all 3 + present in spec

These 13 fields are the de-facto baseline. Every OIDC-compliant deployment
publishes them. Already covered:

```
authorization_endpoint                 issuer
claims_supported                       jwks_uri
device_authorization_endpoint          response_modes_supported
id_token_signing_alg_values_supported  response_types_supported
scopes_supported                       subject_types_supported
token_endpoint                         token_endpoint_auth_methods_supported
userinfo_endpoint
```

## Standard fields published by ≥1 IdP but **missing** from the spec

These are real OIDC / RFC spec fields that we under-modeled. They will be
**added** to the schema (now `OAuthServerMetadata`):

| Field | Spec source | Published by |
|---|---|---|
| `request_parameter_supported` | OIDC Discovery §3 | Auth0 |
| `request_uri_parameter_supported` | OIDC Discovery §3 | Microsoft, Auth0 |
| `token_endpoint_auth_signing_alg_values_supported` | OIDC Discovery §3 | Auth0 |
| `frontchannel_logout_supported` | OIDC Front-Channel Logout 1.0 | Microsoft |
| `http_logout_supported` | OIDC HTTP-Based Logout (legacy) | Microsoft |
| `backchannel_logout_supported` | OIDC Back-Channel Logout 1.0 | Auth0 |
| `backchannel_logout_session_supported` | OIDC Back-Channel Logout 1.0 | Auth0 |
| `backchannel_authentication_endpoint` | OIDC CIBA | Auth0 |
| `backchannel_token_delivery_modes_supported` | OIDC CIBA | Auth0 |
| `authorization_response_iss_parameter_supported` | RFC 9207 | Google |
| `mtls_endpoint_aliases` | RFC 8705 §5 | Microsoft |
| `tls_client_certificate_bound_access_tokens` | RFC 8705 §3 | Microsoft |

In addition, the OIDC Discovery 1.0 §3 metadata definition lists several
other fields that none of the three IdPs publishes but are commonly seen in
self-hosted deployments (Keycloak, Hydra). The most useful of these will
also be added for completeness:

| Field | Spec source |
|---|---|
| `acr_values_supported` | OIDC Discovery §3 |
| `claim_types_supported` | OIDC Discovery §3 (enum: normal, aggregated, distributed) |
| `claims_parameter_supported` | OIDC Discovery §3 |
| `claims_locales_supported` | OIDC Discovery §3 |
| `ui_locales_supported` | OIDC Discovery §3 |
| `display_values_supported` | OIDC Discovery §3 (enum: page, popup, touch, wap) |
| `service_documentation` | OIDC Discovery §3 |
| `op_policy_uri` | OIDC Discovery §3 |
| `op_tos_uri` | OIDC Discovery §3 |
| `frontchannel_logout_session_supported` | OIDC Front-Channel Logout 1.0 |
| `request_object_signing_alg_values_supported` | OIDC Discovery §3 |
| `userinfo_signing_alg_values_supported` | OIDC Discovery §3 |
| `id_token_encryption_alg_values_supported` | OIDC Discovery §3 |
| `id_token_encryption_enc_values_supported` | OIDC Discovery §3 |

## Spec fields not published by any of the 3 — justified to keep

Four spec fields don't show up in any of the three sample documents but
remain valid because they belong to RFCs that this spec covers:

| Field | Spec | Why kept |
|---|---|---|
| `introspection_endpoint` | RFC 7662 | Most self-hosted IdPs publish this; Google/MS use opaque tokens differently. |
| `pushed_authorization_request_endpoint` | RFC 9126 | Modern security best practice; Microsoft v2.0 + FAPI deployments publish it. |
| `require_pushed_authorization_requests` | RFC 9126 | Co-required with PAR. |
| `authorization_details_types_supported` | RFC 9396 (RAR) | Newer, slow adoption; FAPI 2.0 mandates it. |

## Vendor-specific extensions — **NOT** added (out of scope for a canonical spec)

These are deployment-specific hints that don't belong in a vendor-agnostic
spec. They are documented here for awareness only.

### Microsoft-specific (`login.microsoftonline.com`)

| Field | Purpose |
|---|---|
| `cloud_graph_host_name` | Microsoft Graph host hint |
| `cloud_instance_name` | Azure cloud (e.g., AzurePublic) |
| `kerberos_endpoint` | Hybrid Azure AD Kerberos endpoint |
| `msgraph_host` | Microsoft Graph FQDN |
| `rbac_url` | Azure RBAC service |
| `tenant_region_scope` | Tenant region (e.g., NA, EU) |

### Auth0-specific (`*.auth0.com`)

| Field | Purpose |
|---|---|
| `mfa_challenge_endpoint` | Auth0 MFA challenge initiation |
| `global_token_revocation_endpoint` | Auth0 multi-tenant revocation |
| `global_token_revocation_endpoint_auth_methods_supported` | Auth methods for above |
| `client_id_metadata_document_supported` | Auth0 client-metadata-document feature (emerging spec) |

If you're targeting these specific IdPs, embed your own vendor-extended
spec on top of `oauth-openapi.yaml` (use `allOf` and add the extensions).

## Reproducing this analysis

```bash
curl -sf https://accounts.google.com/.well-known/openid-configuration > /tmp/g.json
curl -sf https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration > /tmp/m.json
curl -sf https://samples.auth0.com/.well-known/openid-configuration > /tmp/a.json

python3 - <<'PY'
import json, yaml
spec = yaml.safe_load(open('oauth-openapi.yaml'))
my = set(spec['components']['schemas']['OAuthServerMetadata']['properties'])
g = set(json.load(open('/tmp/g.json')))
m = set(json.load(open('/tmp/m.json')))
a = set(json.load(open('/tmp/a.json')))
print('missing :', sorted((g | m | a) - my))
print('orphans :', sorted(my - (g | m | a)))
print('all-3   :', sorted(g & m & a & my))
PY
```

## Outcome

`oauth-openapi.yaml` is updated in the same commit that merges this analysis
to add the 12 standard fields found in real IdPs plus 14 OIDC Discovery 1.0
fields commonly seen in self-hosted IdPs. The four "orphan" spec fields are
kept; the ~10 vendor-specific extensions are documented here but not added.
