# OpenID Foundation spec snapshots

Local copies of OpenID Foundation (OIDF) specifications that this project
models or cites but that are **not IETF RFCs**: they are published by the
OpenID Foundation as HTML, carry no RFC number, and fall under the OpenID
Foundation IPR Policy rather than the IETF Trust license. This folder is the
OIDF counterpart to [`../rfc-sources/`](../rfc-sources/) (IETF RFCs and drafts).

The authoritative list is [`manifest.txt`](manifest.txt): **12 documents, about
1.2 MB**, each verified byte-for-byte against openid.net on 2026-10-11.

## What is vendored — the scope rule

An OIDF document belongs here when **`oauth-openapi.yaml` models or advertises
its protocol elements** (endpoints, parameters, metadata fields, response
modes), or when it is the **exact edition an RFC in `../rfc-sources/` cites**
(RFC 9700 cites `[OpenID.Core]`, `[OpenID.Discovery]`, `[OAuth.Post]`,
`[OAuth.Responses]` and `[OpenID.JARM]`).

Other OIDF and related specs — FAPI 2.0, OpenID Federation, OpenID for
Verifiable Credentials, the Shared Signals Framework, `prompt=create`,
`unmet_authentication_requirements`, Ephemeral Subject Identifiers, Kantara
UMA 2.0, and more — are inventoried with status and recommendations in
[`../audit/rfc-coverage-audit.md`](../audit/rfc-coverage-audit.md). Vendor one
when the spec starts modeling it (one line in `manifest.txt`).

## Index

| File | Specification | Status | Dated | Why it is here |
|---|---|---|---|---|
| `oidc-core-1.0.html` (427K) | OpenID Connect Core 1.0 incorporating errata set 2 | Final | 2023-12-15 | `/authorize` OIDC parameters, ID Token, UserInfo, OIDC error codes; RFC 9700 `[OpenID.Core]` |
| `oidc-discovery-1.0.html` (106K) | OpenID Connect Discovery 1.0 incorporating errata set 2 | Final | 2023-12-15 | `/.well-known/openid-configuration`, `OpenIDProviderMetadata`; RFC 9700 `[OpenID.Discovery]` |
| `openid-connect-registration-1_0.html` (107K) | OpenID Connect Dynamic Client Registration 1.0 incorporating errata set 2 | Final | 2023-12-15 | `registration_endpoint`; the OIDC client metadata that a future `/register` (RFC 7591) must carry |
| `openid-connect-session-1_0.html` (49K) | OpenID Connect Session Management 1.0 | Final | 2022-09-12 | `check_session_iframe` metadata |
| `openid-connect-rpinitiated-1_0.html` (46K) | OpenID Connect RP-Initiated Logout 1.0 | Final | 2022-09-12 | `end_session_endpoint` metadata |
| `openid-connect-frontchannel-1_0.html` (42K) | OpenID Connect Front-Channel Logout 1.0 | Final | 2022-09-12 | `frontchannel_logout_supported`, `frontchannel_logout_session_supported` metadata |
| `openid-connect-backchannel-1_0.html` (63K) | OpenID Connect Back-Channel Logout 1.0 incorporating errata set 1 | Final | 2023-12-15 | `backchannel_logout_supported`, `backchannel_logout_session_supported` metadata |
| `openid-client-initiated-backchannel-authentication-core-1_0.html` (108K) | OpenID Connect Client-Initiated Backchannel Authentication Flow — Core 1.0 (CIBA) | Final (an errata draft is pending) | 2021-09-01 | `backchannel_authentication_endpoint` and three other `backchannel_*` metadata fields |
| `oauth-v2-multiple-response-types-1_0.html` (40K) | OAuth 2.0 Multiple Response Type Encoding Practices | Final | 2014-02-25 | `response_mode` (`query`, `fragment`), multi-value `response_type`; RFC 9700 `[OAuth.Responses]` |
| `oauth-v2-form-post-response-mode-1_0.html` (23K) | OAuth 2.0 Form Post Response Mode | Final | 2015-04-27 | `response_mode=form_post`; RFC 9700 `[OAuth.Post]` |
| `oauth-v2-jarm.html` (88K) | JWT Secured Authorization Response Mode for OAuth 2.0 (JARM) incorporating errata set 1 | Final (2022-11-09) | 2025-08-17 | `query.jwt`, `fragment.jwt`, `form_post.jwt`, `jwt` response modes — the **current, normative** JARM text |
| `openid-financial-api-jarm.html` (47K) | Financial-grade API: JWT Secured Authorization Response Mode for OAuth 2.0 (JARM), Draft-02 | Implementer's Draft (superseded) | 2018-10-17 | The edition RFC 9700 `[OpenID.JARM]` and RFC 9207 cite — kept so those citations resolve |

> **JARM has two files on purpose.** The 2018 FAPI draft is what RFC 9700 and
> RFC 9207 reference by URL; JARM became a standalone Final specification in
> November 2022 and gained errata set 1 in August 2025 (served at
> `oauth-v2-jarm.html`). The four response-mode values are the same in every
> edition; model against the Final.

## Refreshing and auditing

Use [`tools/fetch-specs.sh`](../../tools/fetch-specs.sh) with the manifest
(runbook: [`tools/README.md`](../../tools/README.md#fetch-specssh)):

```bash
# Refresh in place
./tools/fetch-specs.sh --dir references/oidf-sources --file references/oidf-sources/manifest.txt

# Read-only audit — exit code 6 if a file is missing or upstream has changed
./tools/fetch-specs.sh --check --dir references/oidf-sources --file references/oidf-sources/manifest.txt
```

Unlike published RFCs, OIDF specs can be **revised in place** (errata sets keep
the same URL), so `DIFFERENT` here usually means the publisher updated the
document: review what changed, refresh, and update the Status/Dated columns.

## Snapshot history

| Date | Change |
|---|---|
| 2026-05-10 | OIDC Core and Discovery vendored (originally under `../rfc-sources/`). |
| 2026-06-06 | Folder created: Core and Discovery moved here; Form Post, Multiple Response Types and the 2018 JARM draft added (the OIDF documents RFC 9700 cites). |
| 2026-10-11 | [RFC landscape audit](../audit/rfc-coverage-audit.md): 7 specs added whose fields the YAML already advertised — Dynamic Client Registration, Session Management, RP-Initiated Logout, Front-Channel Logout, Back-Channel Logout, CIBA Core — plus the Final JARM. `manifest.txt` and `tools/fetch-specs.sh` replace the hand-run `curl` block. The 5 existing files were verified byte-identical to openid.net. |

## Licensing

Each document carries an OpenID Foundation copyright notice granting "a
non-exclusive, royalty free, worldwide copyright license to reproduce, prepare
derivative works from, distribute, perform and display" the specification
"solely for the purposes of (i) developing specifications, and (ii)
implementing Implementers Drafts and Final Specifications based on such
documents", with attribution to the OIDF. They are kept here, unmodified, as
reference material for implementing them. See also the
[OpenID Foundation IPR Policy](https://openid.net/intellectual-property/).
