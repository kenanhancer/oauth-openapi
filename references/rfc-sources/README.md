# RFC source snapshots

Local copies of the IETF RFCs and Internet-Drafts this project is built on and
audited against. OpenID Foundation specifications (which are **not** RFCs) live
separately in [`../oidf-sources/`](../oidf-sources/). Vendoring keeps the spec
auditable against the **same source text** used to write it, even if upstream
documents are revised, moved, or temporarily unreachable.

The authoritative list is [`manifest.txt`](manifest.txt): **51 documents
(50 RFCs + the OAuth 2.1 draft), about 4.0 MB.** Every file was verified
byte-for-byte against its upstream on 2026-10-11.

## What is vendored — the scope rule

A document belongs here when it meets at least one of these criteria:

1. **Published by the IETF OAuth working group** — all 36 of them, from RFC 6749
   (2012) to RFC 10027 (August 2026).
2. **OAuth's origin** — RFC 5849, *The OAuth 1.0 Protocol*, which RFC 6749
   obsoletes. It was an individual submission (`draft-hammer-oauth`), not an
   OAuth WG document, so a working-group filter alone misses it.
3. **A formal update of an OAuth WG RFC** from another working group — RFC 7797
   (updates RFC 7519) and RFC 8996 (updates RFC 6749 and RFC 6750) — so every
   "Updated by" chain in the index below resolves locally.
4. **The JOSE core** that JWTs, ID Tokens, JWT access tokens, request objects,
   DPoP proofs and JWK Sets are built on (JWS, JWE, JWK, JWA, JWK Thumbprint,
   the CFRG curves, and RFC 9864, which updates JWA).
5. **Cited by `oauth-openapi.yaml`** — RFC 3986, BCP 47 (RFC 5646), RFC 7617
   and RFC 9110, beyond the documents above.

Plus the **OAuth 2.1** Internet-Draft, tracked at its latest revision.

Everything else OAuth-related — OAuth profiles from other working groups (ACE,
SECEVENT, SASL, GNAP, Token Binding, …), application protocols that merely
consume OAuth, and the active drafts — is catalogued with reasons in
[`../audit/rfc-coverage-audit.md`](../audit/rfc-coverage-audit.md) but
deliberately **not** vendored. Adding any of them is a one-line change to
`manifest.txt`.

> **BCP numbers name sets, not single RFCs.** BCP 212 is now RFC 8252 (native
> apps) **plus** RFC 10017 (browser-based apps); BCP 195 (TLS guidance) is
> RFC 8996 + RFC 9325 + RFC 9852 (July 2026); BCP 47 is RFC 5646 (tag syntax,
> vendored because the YAML relies on it) + RFC 4647 (tag matching). Cite the
> RFC number when you mean one document.

## Index

All RFC files come from `https://www.rfc-editor.org/rfc/rfcNNNN.txt`; the draft
from `https://www.ietf.org/archive/id/draft-ietf-oauth-v2-1-NN.txt`.

### Origin

| File | RFC — title | Published | Status | Formal relationships | Validation notes |
|---|---|---|---|---|---|
| `rfc5849.txt` (79K) | RFC 5849 — The OAuth 1.0 Protocol | Apr 2010 | Informational | Obsoleted by RFC 6749 | — |

### OAuth WG RFCs

| File | RFC — title | Published | Status | Formal relationships | Validation notes |
|---|---|---|---|---|---|
| `rfc6749.txt` (160K) | RFC 6749 — The OAuth 2.0 Authorization Framework | Oct 2012 | Proposed Standard | Obsoletes RFC 5849; Updated by RFC 8252, RFC 8996, RFC 9700 | [6749-oauth-2.0-core.md](../rfc-validation/6749-oauth-2.0-core.md) |
| `rfc6750.txt` (38K) | RFC 6750 — The OAuth 2.0 Authorization Framework: Bearer Token Usage | Oct 2012 | Proposed Standard | Updated by RFC 8996, RFC 9700 | [6750-bearer-token.md](../rfc-validation/6750-bearer-token.md) |
| `rfc6755.txt` (8K) | RFC 6755 — An IETF URN Sub-Namespace for OAuth | Oct 2012 | Informational | — | — |
| `rfc6819.txt` (155K) | RFC 6819 — OAuth 2.0 Threat Model and Security Considerations | Jan 2013 | Informational | Updated by RFC 9700 | — |
| `rfc7009.txt` (23K) | RFC 7009 — OAuth 2.0 Token Revocation | Aug 2013 | Proposed Standard | — | [7009-token-revocation.md](../rfc-validation/7009-token-revocation.md) |
| `rfc7519.txt` (62K) | RFC 7519 — JSON Web Token (JWT) | May 2015 | Proposed Standard | Updated by RFC 7797, RFC 8725 | [7519-jwt.md](../rfc-validation/7519-jwt.md) |
| `rfc7521.txt` (43K) | RFC 7521 — Assertion Framework for OAuth 2.0 Client Authentication and Authorization Grants | May 2015 | Proposed Standard | — | — |
| `rfc7522.txt` (33K) | RFC 7522 — Security Assertion Markup Language (SAML) 2.0 Profile for OAuth 2.0 Client Authentication and Authorization Grants | May 2015 | Proposed Standard | — | — |
| `rfc7523.txt` (26K) | RFC 7523 — JSON Web Token (JWT) Profile for OAuth 2.0 Client Authentication and Authorization Grants | May 2015 | Proposed Standard | — | [7523-jwt-bearer.md](../rfc-validation/7523-jwt-bearer.md) |
| `rfc7591.txt` (86K) | RFC 7591 — OAuth 2.0 Dynamic Client Registration Protocol | Jul 2015 | Proposed Standard | — | — |
| `rfc7592.txt` (37K) | RFC 7592 — OAuth 2.0 Dynamic Client Registration Management Protocol | Jul 2015 | Experimental | — | — |
| `rfc7636.txt` (39K) | RFC 7636 — Proof Key for Code Exchange by OAuth Public Clients | Sep 2015 | Proposed Standard | — | [7636-pkce.md](../rfc-validation/7636-pkce.md) |
| `rfc7662.txt` (36K) | RFC 7662 — OAuth 2.0 Token Introspection | Oct 2015 | Proposed Standard | — | [7662-introspection.md](../rfc-validation/7662-introspection.md) |
| `rfc7800.txt` (33K) | RFC 7800 — Proof-of-Possession Key Semantics for JSON Web Tokens (JWTs) | Apr 2016 | Proposed Standard | — | — |
| `rfc8176.txt` (30K) | RFC 8176 — Authentication Method Reference Values | Jun 2017 | Proposed Standard | — | — |
| `rfc8252.txt` (49K) | RFC 8252 — OAuth 2.0 for Native Apps | Oct 2017 | BCP 212 | Updates RFC 6749 | — |
| `rfc8414.txt` (53K) | RFC 8414 — OAuth 2.0 Authorization Server Metadata | Jun 2018 | Proposed Standard | — | [8414-as-metadata.md](../rfc-validation/8414-as-metadata.md) |
| `rfc8628.txt` (46K) | RFC 8628 — OAuth 2.0 Device Authorization Grant | Aug 2019 | Proposed Standard | — | [8628-device-grant.md](../rfc-validation/8628-device-grant.md) |
| `rfc8693.txt` (62K) | RFC 8693 — OAuth 2.0 Token Exchange | Jan 2020 | Proposed Standard | — | [8693-token-exchange.md](../rfc-validation/8693-token-exchange.md) |
| `rfc8705.txt` (59K) | RFC 8705 — OAuth 2.0 Mutual-TLS Client Authentication and Certificate-Bound Access Tokens | Feb 2020 | Proposed Standard | — | — |
| `rfc8707.txt` (25K) | RFC 8707 — Resource Indicators for OAuth 2.0 | Feb 2020 | Proposed Standard | — | [8707-resource-indicators.md](../rfc-validation/8707-resource-indicators.md) |
| `rfc8725.txt` (30K) | RFC 8725 — JSON Web Token Best Current Practices | Feb 2020 | BCP 225 | Updates RFC 7519 | — |
| `rfc9068.txt` (34K) | RFC 9068 — JSON Web Token (JWT) Profile for OAuth 2.0 Access Tokens | Oct 2021 | Proposed Standard | — | [9068-jwt-access-token.md](../rfc-validation/9068-jwt-access-token.md) |
| `rfc9101.txt` (56K) | RFC 9101 — The OAuth 2.0 Authorization Framework: JWT-Secured Authorization Request (JAR) | Aug 2021 | Proposed Standard | — | — |
| `rfc9126.txt` (43K) | RFC 9126 — OAuth 2.0 Pushed Authorization Requests | Sep 2021 | Proposed Standard | — | [9126-par.md](../rfc-validation/9126-par.md) |
| `rfc9207.txt` (20K) | RFC 9207 — OAuth 2.0 Authorization Server Issuer Identification | Mar 2022 | Proposed Standard | — | — |
| `rfc9278.txt` (9K) | RFC 9278 — JWK Thumbprint URI | Aug 2022 | Proposed Standard | — | — |
| `rfc9396.txt` (64K) | RFC 9396 — OAuth 2.0 Rich Authorization Requests | May 2023 | Proposed Standard | — | [9396-rar.md](../rfc-validation/9396-rar.md) |
| `rfc9449.txt` (90K) | RFC 9449 — OAuth 2.0 Demonstrating Proof of Possession (DPoP) | Sep 2023 | Proposed Standard | — | [9449-dpop.md](../rfc-validation/9449-dpop.md) |
| `rfc9470.txt` (33K) | RFC 9470 — OAuth 2.0 Step Up Authentication Challenge Protocol | Sep 2023 | Proposed Standard | — | — |
| `rfc9700.txt` (122K) | RFC 9700 — Best Current Practice for OAuth 2.0 Security | Jan 2025 | BCP 240 | Updates RFC 6749, RFC 6750, RFC 6819 | [9700-security-bcp.md](../rfc-validation/9700-security-bcp.md) |
| `rfc9701.txt` (28K) | RFC 9701 — JSON Web Token (JWT) Response for OAuth Token Introspection | Jan 2025 | Proposed Standard | — | — |
| `rfc9728.txt` (59K) | RFC 9728 — OAuth 2.0 Protected Resource Metadata | Apr 2025 | Proposed Standard | — | — |
| `rfc9901.txt` (173K) | RFC 9901 — Selective Disclosure for JSON Web Tokens | Nov 2025 | Proposed Standard | — | — |
| `rfc10017.txt` (134K) | RFC 10017 — OAuth 2.0 for Browser-Based Applications | Aug 2026 | BCP 212 | — | — |
| `rfc10027.txt` (142K) | RFC 10027 — Best Current Practice for Security of Cross-Device Flows | Aug 2026 | BCP 247 | — | — |

### Formal updates to OAuth WG RFCs from other WGs

| File | RFC — title | Published | Status | Formal relationships | Validation notes |
|---|---|---|---|---|---|
| `rfc7797.txt` (23K) | RFC 7797 — JSON Web Signature (JWS) Unencoded Payload Option | Feb 2016 | Proposed Standard | Updates RFC 7519 | — |
| `rfc8996.txt` (49K) | RFC 8996 — Deprecating TLS 1.0 and TLS 1.1 | Mar 2021 | BCP 195 | Obsoletes RFC 5469, RFC 7507; Updates RFC 3261, RFC 3329, RFC 3436, RFC 3470, RFC 3501, RFC 3552, RFC 3568, RFC 3656, RFC 3749, RFC 3767, RFC 3856, RFC 3871, RFC 3887, RFC 3903, RFC 3943, RFC 3983, RFC 4097, RFC 4111, RFC 4162, RFC 4168, RFC 4217, RFC 4235, RFC 4261, RFC 4279, RFC 4497, RFC 4513, RFC 4531, RFC 4540, RFC 4582, RFC 4616, RFC 4642, RFC 4680, RFC 4681, RFC 4712, RFC 4732, RFC 4743, RFC 4744, RFC 4785, RFC 4791, RFC 4823, RFC 4851, RFC 4964, RFC 4975, RFC 4976, RFC 4992, RFC 5018, RFC 5019, RFC 5023, RFC 5024, RFC 5049, RFC 5054, RFC 5091, RFC 5158, RFC 5216, RFC 5238, RFC 5263, RFC 5281, RFC 5364, RFC 5415, RFC 5422, RFC 5456, RFC 5734, RFC 5878, RFC 5953, RFC 6012, RFC 6042, RFC 6083, RFC 6084, RFC 6176, RFC 6347, RFC 6353, RFC 6367, RFC 6460, RFC 6614, RFC 6739, RFC 6749, RFC 6750, RFC 7030, RFC 7465, RFC 7525, RFC 7562, RFC 7568, RFC 8261, RFC 8422 | — |

### JOSE core

| File | RFC — title | Published | Status | Formal relationships | Validation notes |
|---|---|---|---|---|---|
| `rfc7515.txt` (128K) | RFC 7515 — JSON Web Signature (JWS) | May 2015 | Proposed Standard | — | — |
| `rfc7516.txt` (106K) | RFC 7516 — JSON Web Encryption (JWE) | May 2015 | Proposed Standard | — | — |
| `rfc7517.txt` (92K) | RFC 7517 — JSON Web Key (JWK) | May 2015 | Proposed Standard | — | [7517-jwk.md](../rfc-validation/7517-jwk.md) |
| `rfc7518.txt` (152K) | RFC 7518 — JSON Web Algorithms (JWA) | May 2015 | Proposed Standard | Updated by RFC 9864 | — |
| `rfc7638.txt` (27K) | RFC 7638 — JSON Web Key (JWK) Thumbprint | Sep 2015 | Proposed Standard | — | — |
| `rfc8037.txt` (24K) | RFC 8037 — CFRG Elliptic Curve Diffie-Hellman (ECDH) and Signatures in JSON Object Signing and Encryption (JOSE) | Jan 2017 | Proposed Standard | Updated by RFC 9864 | — |
| `rfc9864.txt` (34K) | RFC 9864 — Fully-Specified Algorithms for JSON Object Signing and Encryption (JOSE) and CBOR Object Signing and Encryption (COSE) | Oct 2025 | Proposed Standard | Updates RFC 7518, RFC 8037, RFC 9053 | — |

### Infrastructure RFCs cited by oauth-openapi.yaml

| File | RFC — title | Published | Status | Formal relationships | Validation notes |
|---|---|---|---|---|---|
| `rfc3986.txt` (138K) | RFC 3986 — Uniform Resource Identifier (URI): Generic Syntax | Jan 2005 | Internet Standard (STD 66) | Obsoletes RFC 1808, RFC 2396, RFC 2732; Updates RFC 1738; Updated by RFC 7320, RFC 8820 | — |
| `rfc5646.txt` (204K) | RFC 5646 — Tags for Identifying Languages | Sep 2009 | BCP 47 | Obsoletes RFC 4646 | — |
| `rfc7617.txt` (29K) | RFC 7617 — The 'Basic' HTTP Authentication Scheme | Sep 2015 | Proposed Standard | Obsoletes RFC 2617 | — |
| `rfc9110.txt` (491K) | RFC 9110 — HTTP Semantics | Jun 2022 | Internet Standard (STD 97) | Obsoletes RFC 2818, RFC 7230, RFC 7231, RFC 7232, RFC 7233, RFC 7235, RFC 7538, RFC 7615, RFC 7694; Updates RFC 3864 | — |

### Internet-Drafts (tracked at the latest revision)

| File | Document | Revision | Dated | Validation notes |
|---|---|---|---|---|
| `draft-ietf-oauth-v2-1.txt` (231K) | The OAuth 2.1 Authorization Framework (Internet-Draft, WG document) | -16 | 3 September 2026 | [oauth-2.1-draft.md](../rfc-validation/oauth-2.1-draft.md) (written against -13) |


## Watch list — documents expected to join

As of 2026-10-10 these are in the RFC Editor queue (or, for the last, at the
IESG). When one is published, add its RFC number to `manifest.txt`, run the
refresh command below, and add an index row.

| Draft | What it is | Why it will be vendored |
|---|---|---|
| [`draft-ietf-oauth-rfc7523bis`](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc7523bis/) | Updates RFC 7521, 7522, 7523 and 9126: a JWT used for client authentication must carry the AS **issuer identifier** as its sole audience | OAuth WG; updates vendored RFCs |
| [`draft-ietf-oauth-rfc8725bis`](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc8725bis/) | Revised JWT Best Current Practices (BCP 225) | OAuth WG; replaces RFC 8725 |
| [`draft-ietf-oauth-status-list`](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/) | Token Status List — compact revocation/suspension status for JWT/CWT-based tokens | OAuth WG |
| [`draft-ietf-oauth-identity-chaining`](https://datatracker.ietf.org/doc/draft-ietf-oauth-identity-chaining/) | Identity and authorization chaining across trust domains (token exchange + JWT grant) | OAuth WG |
| [`draft-ietf-jose-hpke-encrypt`](https://datatracker.ietf.org/doc/draft-ietf-jose-hpke-encrypt/) | HPKE for JWE | JOSE core extension — vendor once the YAML cites HPKE algorithms |
| [`draft-ietf-oauth-sd-jwt-vc`](https://datatracker.ietf.org/doc/draft-ietf-oauth-sd-jwt-vc/) | SD-JWT-based Verifiable Digital Credentials | OAuth WG (at the IESG, not yet in the queue) |

## Refreshing and auditing

Use [`tools/fetch-specs.sh`](../../tools/fetch-specs.sh) with the manifest
(runbook: [`tools/README.md`](../../tools/README.md#fetch-specssh)):

```bash
# Refresh in place — adds missing files, updates the draft to its latest revision
./tools/fetch-specs.sh --dir references/rfc-sources --file references/rfc-sources/manifest.txt

# Read-only audit — exit code 6 if anything is missing, differs from upstream,
# or a newer draft revision exists
./tools/fetch-specs.sh --check --dir references/rfc-sources --file references/rfc-sources/manifest.txt
```

Published RFC bytes never change, so `DIFFERENT` on an RFC means the local copy
was edited or corrupted. `OUTDATED` on the draft means the working group posted
a new revision: refresh it, then re-check every `OAuth 2.1 §x.y` citation in
`oauth-openapi.yaml` — section numbers shift between revisions.

## Snapshot history

| Date | Change |
|---|---|
| 2026-05-10 | Initial snapshot: 17 RFCs, the OAuth 2.1 draft (-13), and OIDC Core/Discovery (moved to `../oidf-sources/` on 2026-06-06). |
| 2026-05-30 | RFC 8705 added; OAuth 2.1 draft -13 → -15. |
| 2026-06-06 | The 17 remaining OAuth WG RFCs of the time added (6755, 6819, 7521, 7522, 7591, 7592, 7800, 8176, 8252, 8725, 9101, 9207, 9278, 9470, 9701, 9728, 9901). |
| 2026-10-11 | [RFC landscape audit](../audit/rfc-coverage-audit.md): 15 RFCs added — 10017 and 10027 (OAuth WG BCPs published August 2026), 5849 (origin), 7797 and 8996 (formal updates), 7515, 7516, 7518, 7638, 8037 and 9864 (JOSE core), 3986, 5646, 7617 and 9110 (cited by the YAML); OAuth 2.1 draft -15 → -16. `manifest.txt` and `tools/fetch-specs.sh` replace the hand-run `curl` loop. The 35 previously vendored RFCs were verified byte-identical to rfc-editor.org. |

## Validation notes

The [`../rfc-validation/`](../rfc-validation/) reports (Validation column) were
written in May 2026 against the spec as it was then — the OAuth 2.1 report
against draft-13 — and their YAML line numbers have since drifted. The
2026-10 audit re-assessed every vendored document against the current spec,
with independently verified findings:
[`../audit/rfc-coverage-audit.md`](../audit/rfc-coverage-audit.md).

## Why these are committed

The first audit (commit `7816b0c`) ran 20 parallel agents to compare the spec
against each RFC. Most agents had `WebFetch` denied in their sandbox and worked
from training-data knowledge of the (stable) specs. Committing these snapshots:

- Provides a **canonical source text** so anyone re-running an audit measures
  against the same bytes.
- Survives upstream availability problems (Datatracker maintenance windows,
  RFC reformatting, site reorganizations).
- Lets audits cite specific section numbers with confidence that the reader can
  resolve them locally without an internet round-trip.
- Makes staleness **detectable**: `--check` shows at once when a new revision
  or a missing document needs attention.

## Licensing

Each IETF document states in its Copyright Notice that it is subject to BCP 78
and the IETF Trust's Legal Provisions Relating to IETF Documents
(<https://trustee.ietf.org/license-info>). The files here are the complete,
unmodified documents as published; see the Trust Legal Provisions for the exact
terms (Code Components extracted from RFCs carry the Revised BSD License).
