# OpenID Foundation spec snapshots

Local copies of OpenID Foundation (OIDF) specifications referenced by this
project but that are **not IETF RFCs**: they are published by the OpenID
Foundation as HTML, carry no RFC number, and fall under the OpenID Foundation
IPR Policy rather than the IETF Trust license. This folder is the OIDF
counterpart to [`../rfc-sources/`](../rfc-sources/) (IETF RFCs and drafts).

OpenID Connect Core 1.0 and Discovery 1.0 were originally vendored on
**2026-05-10** and moved here from [`../rfc-sources/`](../rfc-sources/) on
**2026-06-06**; the other three are OIDF documents cited in RFC 9700 (OAuth 2.0
Security BCP), snapshotted **2026-06-06**.

## Index

| File | Spec (status) | RFC 9700 ref | Source URL | Bytes |
|---|---|---|---|---|
| `oidc-core-1.0.html` | OpenID Connect Core 1.0 (Final) | `[OpenID.Core]` | https://openid.net/specs/openid-connect-core-1_0.html | 437K |
| `oidc-discovery-1.0.html` | OpenID Connect Discovery 1.0 (Final) | `[OpenID.Discovery]` | https://openid.net/specs/openid-connect-discovery-1_0.html | 109K |
| `oauth-v2-form-post-response-mode-1_0.html` | OAuth 2.0 Form Post Response Mode (Final) | `[OAuth.Post]` | https://openid.net/specs/oauth-v2-form-post-response-mode-1_0.html | 24K |
| `oauth-v2-multiple-response-types-1_0.html` | OAuth 2.0 Multiple Response Type Encoding Practices (Final) | `[OAuth.Responses]` | https://openid.net/specs/oauth-v2-multiple-response-types-1_0.html | 42K |
| `openid-financial-api-jarm.html` | Financial-grade API: JWT Secured Authorization Response Mode — JARM (Draft-02) | `[OpenID.JARM]` | https://openid.net/specs/openid-financial-api-jarm.html | 49K |

**Total: 5 documents, ~660 KB.**

## Refreshing the snapshots

```bash
cd references/oidf-sources

# OpenID Connect Core & Discovery (local filename differs from URL basename)
curl -sfL "https://openid.net/specs/openid-connect-core-1_0.html"      -o oidc-core-1.0.html
curl -sfL "https://openid.net/specs/openid-connect-discovery-1_0.html" -o oidc-discovery-1.0.html

# response-mode & JARM specs (local filename matches URL basename)
for u in \
  "https://openid.net/specs/oauth-v2-form-post-response-mode-1_0.html" \
  "https://openid.net/specs/oauth-v2-multiple-response-types-1_0.html" \
  "https://openid.net/specs/openid-financial-api-jarm.html"; do
  curl -sfL "$u" -o "$(basename "$u")"
done
```

Unlike published RFCs, OIDF specs can be revised in place (note JARM is still a
draft), so re-pull when auditing against a newer revision.

## Why these are committed

RFC 9700 references several OIDF specifications by short name (`[OAuth.Post]`,
`[OAuth.Responses]`, `[OpenID.JARM]`). Vendoring them gives the audit the same
stable source text used to write the spec, independent of openid.net
availability or reorganization.

## Licensing

OpenID Foundation specifications are published under the
[OpenID Foundation IPR Policy](https://openid.net/intellectual-property/),
which permits unrestricted reproduction for reference distribution.
