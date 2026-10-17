# RFC coverage audit — every OAuth RFC vs. this repository (October 2026)

- **Data gathered:** 2026-10-10 — the RFC (Request for Comments) Editor index,
  the IETF (Internet Engineering Task Force) Datatracker, the RFC Editor queue,
  the IANA (Internet Assigned Numbers Authority) registries, community spec
  listings and openid.net.
- **Vendoring and this report:** 2026-10-11.
- **What was audited:** this repository — the OpenAPI 3.1 description
  [`oauth-openapi.yaml`](../../oauth-openapi.yaml) (commit `3e712d7`, 2,704
  lines; called "the YAML" below), its modular view, the vendored sources under
  `references/`, the audit documents and the tooling. The reference set was
  every OAuth-related RFC published up to 2026-10-10, the OAuth 2.1
  Internet-Draft, the active OAuth working-group drafts and the related OpenID
  Foundation (OIDF) specifications.
- **Repository changes:** the vendored files, manifests, script and README
  updates listed in [§4](#4-what-this-audit-changed) are in the **working tree
  and not yet committed**. The YAML itself was **not** changed;
  [§7](#7-priority-findings) and [§12](#12-recommended-next-steps) say what to
  change.
- **Companion documents:** [`oauth-rfc-timeline.md`](oauth-rfc-timeline.md)
  (the history of OAuth and a staged reading path through the vendored texts)
  and [`rfc-coverage-findings/`](rfc-coverage-findings/README.md) (all 724
  verified findings, one file per cluster of related documents).

## Contents

1. [Answer first: do we have all the RFCs?](#1-answer-first-do-we-have-all-the-rfcs)
2. [Method and sources](#2-method-and-sources)
3. [The OAuth RFC universe](#3-the-oauth-rfc-universe)
4. [What this audit changed](#4-what-this-audit-changed)
5. [OAuth 2.1 draft-16](#5-oauth-21-draft-16)
6. [Spec coverage by document](#6-spec-coverage-by-document)
7. [Priority findings](#7-priority-findings)
8. [IANA registry coverage](#8-iana-registry-coverage)
9. [Draft pipeline and watch list](#9-draft-pipeline-and-watch-list)
10. [OpenID Foundation specs](#10-openid-foundation-specs)
11. [Folder analysis](#11-folder-analysis)
12. [Recommended next steps](#12-recommended-next-steps)
13. [Appendix](#13-appendix)

---

## 1. Answer first: do we have all the RFCs?

**Yes, now.** After this audit the repository holds the text of every RFC
inside its scope rule: **50 RFCs plus the current OAuth 2.1 draft (-16)**. Each
file was checked byte for byte against its upstream copy on 2026-10-11. Before
the audit, **15 RFCs were missing**, including the two newest RFCs of the OAuth
working group (WG), and the OAuth 2.1 draft was one revision behind.

This answer is true for the RFC Editor index of 2026-10-10. Four OAuth WG
drafts were then in the RFC Editor queue, so the set will grow.
[§1.4](#14-keeping-the-answer-true) says what to watch and how to check again.

### 1.1 The scope rule

"All OAuth RFCs" needs a clear border. The catalogue in
[§3](#3-the-oauth-rfc-universe) found 182 RFCs with some link to OAuth. Most of
them only *use* OAuth, or only share a word such as "token". The audit therefore
uses five criteria. A document is vendored in
[`../rfc-sources/`](../rfc-sources/README.md) when it meets at least one:

| # | Criterion | RFCs | Why this criterion |
|---|---|---|---|
| 1 | Published by the IETF OAuth WG | 36 — from RFC 6749 (October 2012) to RFC 10027 (August 2026) | This is what "an OAuth RFC" means. |
| 2 | OAuth's origin | RFC 5849, *The OAuth 1.0 Protocol* (April 2010) | It came from an individual draft (`draft-hammer-oauth`), not from the WG, so a WG filter misses it. RFC 6749 obsoletes it. |
| 3 | Formally updates an OAuth WG RFC (from another WG) | RFC 7797 (updates RFC 7519); RFC 8996 (updates RFC 6749 and RFC 6750) | Every "Updated by" link in the RFC index then points to a local file. |
| 4 | The JOSE (JSON Object Signing and Encryption) core; JSON = JavaScript Object Notation | RFC 7515 JSON Web Signature (JWS), 7516 JSON Web Encryption (JWE), 7517 JSON Web Key (JWK), 7518 JSON Web Algorithms (JWA), 7638 JWK Thumbprint, 8037 (Ed25519/X25519 keys and signatures), 9864 (fully-specified algorithms) | JSON Web Tokens (JWTs), OpenID Connect ID Tokens, request objects, DPoP (Demonstrating Proof of Possession) proofs and JWK Sets are built on them. |
| 5 | Cited by the YAML (beyond criteria 1-4) | RFC 3986 (Uniform Resource Identifier syntax, URI), RFC 5646 (language tags; part of Best Current Practice 47, "BCP 47"), RFC 7617 (the Basic authentication scheme of the Hypertext Transfer Protocol, HTTP), RFC 9110 (HTTP semantics) | Every citation in the spec can be checked against local text. |
| + | The OAuth 2.1 Internet-Draft | `draft-ietf-oauth-v2-1`, tracked at its latest revision | OAuth 2.1 is the target profile, but it is not an RFC yet. |

### 1.2 Before and after

| | Before (2026-10-10) | After (2026-10-11) |
|---|---|---|
| RFC texts vendored | 35 (34 OAuth WG RFCs + RFC 7517) | **50** |
| OAuth WG RFCs | 34 of 36 | **36 of 36** |
| OAuth 2.1 draft | -15 (dated 2 March 2026; expired 3 September 2026) | **-16** (dated 3 September 2026) |
| OpenID Foundation specs | 5 | **12** (7 added — see [§10](#10-openid-foundation-specs)) |
| Drift check against the new manifests | RFCs: 35 OK, 15 MISSING, draft OUTDATED; OIDF: 5 OK, 7 MISSING | RFCs: 51 OK; OIDF: 12 OK (exit code 0) |
| Files that were already vendored | all 35 RFC files and 5 OIDF files byte-identical to upstream | unchanged |

**The 15 RFCs that were missing:**

| Criterion | Missing RFCs | Note |
|---|---|---|
| 1 — OAuth WG | RFC 10017 *OAuth 2.0 for Browser-Based Applications* (BCP 212); RFC 10027 *Best Current Practice for Security of Cross-Device Flows* (BCP 247) | The two OAuth WG RFCs published in August 2026. |
| 2 — origin | RFC 5849 *The OAuth 1.0 Protocol* | |
| 3 — formal updaters | RFC 7797, RFC 8996 | |
| 4 — JOSE core | RFC 7515, 7516, 7518, 7638, 8037, 9864 | The YAML already cited 7518, 7638 and 8037. |
| 5 — cited by the YAML | RFC 3986, 5646, 7617, 9110 | The YAML cites RFC 5646 as "BCP47". |

Six RFCs that the YAML cites were not vendored before: 3986, 7518, 7617, 7638,
8037 and 9110. All six are vendored now.

**Still not vendored, on purpose.** The catalogue holds 132 more RFCs. 84 of
them are unrelated to OAuth: they share a term or a registry, use JWT or JOSE
outside OAuth, or mention OAuth only in passing. The other 48 are
OAuth-adjacent but outside the scope rule. They are JOSE documents outside the
core, OAuth profiles from other WGs, application protocols that consume OAuth,
and infrastructure that the YAML does not cite.
[§3.4](#34-catalogued-not-vendored) lists all 48 with the reason.
Adding one is a one-line change in
[`../rfc-sources/manifest.txt`](../rfc-sources/manifest.txt).

### 1.3 How well does the spec model them?

- **107 documents assessed** in 21 clusters: 73 are in scope for an
  authorization server (AS); 34 are catalogue entries only (OAuth 1.0, security
  events, the Grant Negotiation and Authorization Protocol (GNAP), Token
  Binding, the Authentication and Authorization for Constrained Environments
  (ACE) framework and others).
- **In-scope coverage (73 documents):** 29 *mostly*, 17 *partial*, 10
  *referenced-only*, 14 *none*, 3 *not-applicable*. The levels are defined in
  [§13.2](#132-glossary).
- **The 36 OAuth WG RFCs:** 21 mostly, 8 partial, 2 referenced-only (RFC 7591,
  RFC 8176), 4 none (RFC 7522, 7592, 9278, 10027), 1 not applicable to an AS
  (RFC 9901).
- **The 10 documents an OAuth 2.1 AS must follow** ("required (2.1)" in
  [§6](#6-spec-coverage-by-document)): 6 mostly, 2 partial (RFC 8252,
  RFC 9700), 2 none (RFC 8996 and `draft-ietf-oauth-rfc7523bis`, called
  "rfc7523bis" below).
- **724 verified findings:** 29 high, 187 medium, 508 low. In-scope clusters
  only: 29 / 186 / 474.
- **Zero refuted claims.** Independent verifiers confirmed 535 of the 615
  original claims and partially confirmed 80. They refuted none, and they added
  109 findings of their own.
- **6 of the 29 high findings were re-checked by hand** against the YAML. All
  6 hold.

**Where the 29 high findings are** (details in [§7.1](#71-high-findings-29)):

| Theme | High |
|---|---|
| A. OAuth 2.1 draft-16 alignment — PKCE (Proof Key for Code Exchange) `plain` is now prohibited; `iss` is now REQUIRED | 2 |
| B. Client authentication with JWT assertions (rfc7523bis audience rule; jwt-bearer grant) | 3 |
| C. Redirect URIs and PKCE | 4 |
| D. Pushed Authorization Requests (PAR) with a JWT-Secured Authorization Request (JAR) object | 1 |
| E. JOSE and JWT safety | 3 |
| F. Dynamic Client Registration (DCR) is advertised but not modeled | 6 |
| G. OpenID Connect (OIDC) | 4 |
| H. Browser-based applications (RFC 10017) | 2 |
| I. Sender-constrained tokens at the userinfo endpoint (mutual Transport Layer Security, mTLS; DPoP) | 2 |
| J. Security BCP: authorization codes and AS-rendered pages | 2 |

### 1.4 Keeping the answer true

- **What the drift check proves.**
  [`../../tools/fetch-specs.sh`](../../tools/fetch-specs.sh) `--check`
  compares every document in the two manifests with its upstream copy. It
  reports a missing file, a changed file, and a newer revision of the OAuth 2.1
  draft (exit code 6).
- **What it cannot prove.** It does not discover new RFCs. A new OAuth RFC
  appears in the RFC Editor index, not in the manifest.
- **What to watch.** On 2026-10-10, four OAuth WG drafts were in the RFC Editor
  queue: rfc7523bis, rfc8725bis, status-list and identity-chaining. Each one
  meets criterion 1 when it is published. `draft-ietf-oauth-sd-jwt-vc` (at the
  IESG, the Internet Engineering Steering Group) will meet criterion 1 too.
  `draft-ietf-jose-hpke-encrypt` (also in the queue, from the JOSE WG) should
  be added once the YAML cites HPKE (Hybrid Public Key Encryption) algorithms.
  The watch list in [`../rfc-sources/README.md`](../rfc-sources/README.md)
  names all six; [§9.1](#91-active-drafts-on-2026-10-10) gives their states.
- **How to check again.** Compare the RFCs of the oauth WG (in the RFC Editor
  index, or on the
  [Datatracker documents page of the WG](https://datatracker.ietf.org/wg/oauth/documents/))
  with [`../rfc-sources/manifest.txt`](../rfc-sources/manifest.txt). Also look
  at the "Updated by" field of each OAuth WG RFC: a new updater from another WG
  meets criterion 3. Add each new RFC number to the manifest, then run the
  script without `--check` to fetch it.

---

## 2. Method and sources

### 2.1 Data sources

| Source | What it provided | Retrieved |
|---|---|---|
| RFC Editor index | All 9,847 RFCs, from RFC 1 to RFC 10065 (the highest number, published in October 2026): title, status, WG, date, obsoletes and updates, BCP membership | 2026-10-10 |
| IETF Datatracker (web pages and its application programming interface, API) | WG document lists, draft states, "referenced by" relations | 2026-10-10 |
| RFC Editor queue | Documents approved but not yet published | 2026-10-10 |
| IANA registries | OAuth Parameters (last updated 2026-08-24), JSON Web Token, JOSE, Well-Known URIs, HTTP Authentication Schemes | 2026-10-10 |
| Community listings (37 sources) | oauth.net, Wikipedia, the oauth.com spec map, the IETF OAuth wiki, `draft-chen-oauth-roadmap-01`, `danielfett/oauth-linklist`, the Kantara Initiative UMA (User-Managed Access) specs, IndieAuth and others | 2026-10-10 |
| openid.net | The OIDF specification list and texts; 40 OIDF and related specifications inventoried | 2026-10-10 |
| Upstream document bytes | rfc-editor.org, the ietf.org draft archive, openid.net | 2026-10-10 and 2026-10-11 |

### 2.2 Integrity check

Before any change, each of the 35 vendored RFC files was compared by its
SHA-256 hash with `https://www.rfc-editor.org/rfc/rfcNNNN.txt`, and each of the 5 vendored
OIDF HTML files with its openid.net URL. All 40 files were byte-identical.
After vendoring, [`../../tools/fetch-specs.sh`](../../tools/fetch-specs.sh)
`--check` reported 51 OK documents in `rfc-sources/` and 12 OK documents in
`oidf-sources/` (exit code 0). The full output is in
[§4.2](#42-drift-check-before-and-after).

### 2.3 Workflow

The work used parallel research and coverage agents with independent
adversarial verification:

- **Five research agents** built the RFC catalogue (from the RFC index plus ten
  completeness checks), cross-checked it against 37 community and OIDF sources,
  mapped the active drafts, inventoried the OIDF specifications, and wrote the
  history for the companion timeline.
- **Twenty-one coverage clusters** grouped related documents (for example
  "JAR, PAR and issuer identification"). In each cluster, one agent read the
  vendored text and compared every normative element with the YAML. A second,
  independent agent then tried to refute every claimed gap or error against the
  YAML and the source text, re-assessed its severity, and looked for misses.
  Twenty clusters went through this verification. The historical cluster
  (RFC 5849) made no claims about the YAML, so it had nothing to verify.
- **Two folder-analysis agents** checked documentation consistency (48 files)
  and build health (lint, modular view, bundle, code generator, tooling).
- **Outcome:** 615 claims — 535 confirmed, 80 partially confirmed (published
  with the verifier's correction), 0 refuted. The verifiers added 109 findings.
  Total: 724 findings.

Severity is the verifier's assessment. **High:** a server generated from the
YAML would violate a MUST or miss a core element. **Medium:** a SHOULD-level
rule or a commonly used optional element. **Low:** documentation or precision.

### 2.4 Manual spot-check

Six high findings were re-checked by hand against the YAML: the jwt-bearer
request without client authentication (H5), `code_challenge_method` described
with the -15 rule (H1), `iss` conditional on success (H2), exact redirect-URI
matching without the loopback-port exception (H6), `PARRequest` required fields
that block JAR-in-PAR (H10), and the missing `POST /authorize` (H20). All six
hold. For this report, every YAML line range cited in [§7](#7-priority-findings)
was also compared with the current file, which is unchanged since commit
`3e712d7`.

### 2.5 Limitations

- YAML line numbers refer to commit `3e712d7`. They will move when the YAML
  changes.
- Coverage levels are judgments. Verifiers changed the level of 12 documents
  (10 of them in scope); the matrix shows the corrected level.
- The IANA comparison is a whole-word search of the YAML text. It can match
  common words (for example the well-known names `dots` and `time`), so
  "present" can be too high. An "absent" value is certainly absent.
- The Datatracker "referenced by" web page for RFC 7519 stops at 250 of 251
  documents. The Datatracker API was used to complete the list.
- Drafts and OIDF specifications change. OAuth 2.1 -16 has not reached WG Last
  Call, and OIDF specifications can be revised at the same URL.
- The audit reviewed the API description, not a running server.
- Community listings are often out of date. [§3.7](#37-conflicts-in-public-sources)
  lists the conflicts found.

---

## 3. The OAuth RFC universe

### 3.1 Classification

The catalogue started from 89 candidate RFCs: the RFCs of the WGs oauth, jose,
secevent, ace, gnap and tokbind; the RFCs the YAML cites; the vendored RFCs;
and selected neighbours. Ten completeness checks ([§3.6](#36-how-the-catalogue-was-cross-checked))
added 93 more. Every RFC received one tier:

| Tier | Meaning | RFCs | Vendored |
|---|---|---|---|
| T1 | Published by the OAuth WG | 36 | 36 |
| T2 | OAuth's origin (RFC 5849) | 1 | 1 |
| T3 | Formal updater of an OAuth WG RFC from another WG | 2 | 2 |
| T4 | JOSE foundation | 11 | 7 |
| T5 | OAuth profile from another WG — for example SASL (Simple Authentication and Security Layer) mechanisms, ACE (Authentication and Authorization for Constrained Environments), Security Event Tokens (SETs), Token Binding, GNAP | 25 | 0 |
| T6 | Application protocol that consumes OAuth | 10 | 0 |
| T7 | Infrastructure: URIs, HTTP, language tags, registries | 13 | 4 |
| X | Unrelated: term collisions, passing mentions, or JWT and JOSE users outside OAuth | 84 | 0 |
| **Total** | | **182** | **50** |

### 3.2 T1 — the 36 OAuth WG RFCs

*H / M / L* = verified high / medium / low findings for that document.

| RFC | Title | Published | Status | Local text | YAML coverage | H / M / L | Findings |
|---|---|---|---|---|---|---|---|
| RFC 6749 | The OAuth 2.0 Authorization Framework | Oct 2012 | Proposed Standard | [rfc6749.txt](../rfc-sources/rfc6749.txt) | mostly | 1 / 11 / 28 | [core-6749](rfc-coverage-findings/core-6749.md#rfc-6749-the-oauth-20-authorization-framework) |
| RFC 6750 | The OAuth 2.0 Authorization Framework: Bearer Token Usage | Oct 2012 | Proposed Standard | [rfc6750.txt](../rfc-sources/rfc6750.txt) | mostly | 0 / 3 / 10 | [bearer-http](rfc-coverage-findings/bearer-http.md#rfc-6750-the-oauth-20-authorization-framework-bearer-token-usage) |
| RFC 6755 | An IETF URN Sub-Namespace for OAuth | Oct 2012 | Informational | [rfc6755.txt](../rfc-sources/rfc6755.txt) | mostly | 0 / 0 / 3 | [metadata](rfc-coverage-findings/metadata.md#rfc6755-an-ietf-urn-sub-namespace-for-oauth) |
| RFC 6819 | OAuth 2.0 Threat Model and Security Considerations | Jan 2013 | Informational | [rfc6819.txt](../rfc-sources/rfc6819.txt) | mostly | 0 / 3 / 6 | [security](rfc-coverage-findings/security.md#rfc-6819-oauth-20-threat-model-and-security-considerations) |
| RFC 7009 | OAuth 2.0 Token Revocation | Aug 2013 | Proposed Standard | [rfc7009.txt](../rfc-sources/rfc7009.txt) | mostly | 0 / 3 / 6 | [revocation-introspection](rfc-coverage-findings/revocation-introspection.md#rfc-7009-oauth-20-token-revocation) |
| RFC 7519 | JSON Web Token (JWT) | May 2015 | Proposed Standard | [rfc7519.txt](../rfc-sources/rfc7519.txt) | mostly | 0 / 3 / 7 | [jwt](rfc-coverage-findings/jwt.md#rfc-7519-json-web-token-jwt) |
| RFC 7521 | Assertion Framework for OAuth 2.0 Client Authentication and Authorization Grants | May 2015 | Proposed Standard | [rfc7521.txt](../rfc-sources/rfc7521.txt) | mostly | 0 / 3 / 7 | [assertions](rfc-coverage-findings/assertions.md#rfc-7521-assertion-framework-for-oauth-20-client-authentication-and-authorization-grants) |
| RFC 7522 | Security Assertion Markup Language (SAML) 2.0 Profile for OAuth 2.0 Client Authentication and Authorization Grants | May 2015 | Proposed Standard | [rfc7522.txt](../rfc-sources/rfc7522.txt) | none | 0 / 1 / 1 | [assertions](rfc-coverage-findings/assertions.md#rfc-7522-security-assertion-markup-language-saml-20-profile-for-oauth-20-client-authentication-and-authorization-grants) |
| RFC 7523 | JSON Web Token (JWT) Profile for OAuth 2.0 Client Authentication and Authorization Grants | May 2015 | Proposed Standard | [rfc7523.txt](../rfc-sources/rfc7523.txt) | mostly | 1 / 4 / 8 | [assertions](rfc-coverage-findings/assertions.md#rfc-7523-json-web-token-jwt-profile-for-oauth-20-client-authentication-and-authorization-grants) |
| RFC 7591 | OAuth 2.0 Dynamic Client Registration Protocol | Jul 2015 | Proposed Standard | [rfc7591.txt](../rfc-sources/rfc7591.txt) | referenced-only | 4 / 7 / 9 | [dcr](rfc-coverage-findings/dcr.md#rfc-7591-oauth-20-dynamic-client-registration-protocol) |
| RFC 7592 | OAuth 2.0 Dynamic Client Registration Management Protocol | Jul 2015 | Experimental | [rfc7592.txt](../rfc-sources/rfc7592.txt) | none | 0 / 5 / 3 | [dcr](rfc-coverage-findings/dcr.md#rfc-7592-oauth-20-dynamic-client-registration-management-protocol) |
| RFC 7636 | Proof Key for Code Exchange by OAuth Public Clients | Sep 2015 | Proposed Standard | [rfc7636.txt](../rfc-sources/rfc7636.txt) | mostly | 0 / 4 / 10 | [pkce-apps](rfc-coverage-findings/pkce-apps.md#rfc-7636-proof-key-for-code-exchange-by-oauth-public-clients) |
| RFC 7662 | OAuth 2.0 Token Introspection | Oct 2015 | Proposed Standard | [rfc7662.txt](../rfc-sources/rfc7662.txt) | mostly | 0 / 7 / 7 | [revocation-introspection](rfc-coverage-findings/revocation-introspection.md#rfc-7662-oauth-20-token-introspection) |
| RFC 7800 | Proof-of-Possession Key Semantics for JSON Web Tokens (JWTs) | Apr 2016 | Proposed Standard | [rfc7800.txt](../rfc-sources/rfc7800.txt) | partial (was mostly) | 0 / 0 / 6 | [pop](rfc-coverage-findings/pop.md#rfc-7800-proof-of-possession-key-semantics-for-json-web-tokens-jwts) |
| RFC 8176 | Authentication Method Reference Values | Jun 2017 | Proposed Standard | [rfc8176.txt](../rfc-sources/rfc8176.txt) | referenced-only | 0 / 0 / 2 | [token-exchange](rfc-coverage-findings/token-exchange.md#rfc-8176-authentication-method-reference-values) |
| RFC 8252 | OAuth 2.0 for Native Apps | Oct 2017 | BCP 212 | [rfc8252.txt](../rfc-sources/rfc8252.txt) | partial | 1 / 1 / 6 | [pkce-apps](rfc-coverage-findings/pkce-apps.md#rfc-8252-oauth-20-for-native-apps) |
| RFC 8414 | OAuth 2.0 Authorization Server Metadata | Jun 2018 | Proposed Standard | [rfc8414.txt](../rfc-sources/rfc8414.txt) | mostly | 0 / 4 / 14 | [metadata](rfc-coverage-findings/metadata.md#rfc8414-oauth-20-authorization-server-metadata) |
| RFC 8628 | OAuth 2.0 Device Authorization Grant | Aug 2019 | Proposed Standard | [rfc8628.txt](../rfc-sources/rfc8628.txt) | mostly | 0 / 4 / 17 | [device-crossdevice](rfc-coverage-findings/device-crossdevice.md#rfc-8628-oauth-20-device-authorization-grant) |
| RFC 8693 | OAuth 2.0 Token Exchange | Jan 2020 | Proposed Standard | [rfc8693.txt](../rfc-sources/rfc8693.txt) | mostly | 0 / 4 / 13 | [token-exchange](rfc-coverage-findings/token-exchange.md#rfc-8693-oauth-20-token-exchange) |
| RFC 8705 | OAuth 2.0 Mutual-TLS Client Authentication and Certificate-Bound Access Tokens | Feb 2020 | Proposed Standard | [rfc8705.txt](../rfc-sources/rfc8705.txt) | mostly | 1 / 3 / 7 | [pop](rfc-coverage-findings/pop.md#rfc-8705-oauth-20-mutual-tls-client-authentication-and-certificate-bound-access-tokens) |
| RFC 8707 | Resource Indicators for OAuth 2.0 | Feb 2020 | Proposed Standard | [rfc8707.txt](../rfc-sources/rfc8707.txt) | mostly | 0 / 1 / 6 | [resource-rar-stepup](rfc-coverage-findings/resource-rar-stepup.md#rfc-8707-resource-indicators-for-oauth-20) |
| RFC 8725 | JSON Web Token Best Current Practices | Feb 2020 | BCP 225 | [rfc8725.txt](../rfc-sources/rfc8725.txt) | partial | 0 / 4 / 8 | [jwt](rfc-coverage-findings/jwt.md#rfc-8725-json-web-token-best-current-practices) |
| RFC 9068 | JSON Web Token (JWT) Profile for OAuth 2.0 Access Tokens | Oct 2021 | Proposed Standard | [rfc9068.txt](../rfc-sources/rfc9068.txt) | partial (was mostly) | 1 / 4 / 9 | [jwt-at-sdjwt](rfc-coverage-findings/jwt-at-sdjwt.md#rfc-9068-json-web-token-jwt-profile-for-oauth-20-access-tokens) |
| RFC 9101 | The OAuth 2.0 Authorization Framework: JWT-Secured Authorization Request (JAR) | Aug 2021 | Proposed Standard | [rfc9101.txt](../rfc-sources/rfc9101.txt) | partial | 0 / 5 / 5 | [jar-par-iss](rfc-coverage-findings/jar-par-iss.md#rfc-9101-the-oauth-20-authorization-framework-jwt-secured-authorization-request-jar) |
| RFC 9126 | OAuth 2.0 Pushed Authorization Requests | Sep 2021 | Proposed Standard | [rfc9126.txt](../rfc-sources/rfc9126.txt) | mostly | 1 / 7 / 12 | [jar-par-iss](rfc-coverage-findings/jar-par-iss.md#rfc-9126-oauth-20-pushed-authorization-requests) |
| RFC 9207 | OAuth 2.0 Authorization Server Issuer Identification | Mar 2022 | Proposed Standard | [rfc9207.txt](../rfc-sources/rfc9207.txt) | mostly | 0 / 2 / 4 | [jar-par-iss](rfc-coverage-findings/jar-par-iss.md#rfc-9207-oauth-20-authorization-server-issuer-identification) |
| RFC 9278 | JWK Thumbprint URI | Aug 2022 | Proposed Standard | [rfc9278.txt](../rfc-sources/rfc9278.txt) | none | 0 / 0 / 1 | [pop](rfc-coverage-findings/pop.md#rfc-9278-jwk-thumbprint-uri) |
| RFC 9396 | OAuth 2.0 Rich Authorization Requests | May 2023 | Proposed Standard | [rfc9396.txt](../rfc-sources/rfc9396.txt) | mostly | 0 / 5 / 11 | [resource-rar-stepup](rfc-coverage-findings/resource-rar-stepup.md#rfc-9396-oauth-20-rich-authorization-requests) |
| RFC 9449 | OAuth 2.0 Demonstrating Proof of Possession (DPoP) | Sep 2023 | Proposed Standard | [rfc9449.txt](../rfc-sources/rfc9449.txt) | mostly | 1 / 5 / 14 | [pop](rfc-coverage-findings/pop.md#rfc-9449-oauth-20-demonstrating-proof-of-possession-dpop) |
| RFC 9470 | OAuth 2.0 Step Up Authentication Challenge Protocol | Sep 2023 | Proposed Standard | [rfc9470.txt](../rfc-sources/rfc9470.txt) | mostly | 0 / 1 / 5 | [resource-rar-stepup](rfc-coverage-findings/resource-rar-stepup.md#rfc-9470-oauth-20-step-up-authentication-challenge-protocol) |
| RFC 9700 | Best Current Practice for OAuth 2.0 Security | Jan 2025 | BCP 240 | [rfc9700.txt](../rfc-sources/rfc9700.txt) | partial (was mostly) | 4 / 8 / 11 | [security](rfc-coverage-findings/security.md#rfc-9700-best-current-practice-for-oauth-20-security) |
| RFC 9701 | JSON Web Token (JWT) Response for OAuth Token Introspection | Jan 2025 | Proposed Standard | [rfc9701.txt](../rfc-sources/rfc9701.txt) | partial | 0 / 6 / 6 | [revocation-introspection](rfc-coverage-findings/revocation-introspection.md#rfc-9701-json-web-token-jwt-response-for-oauth-token-introspection) |
| RFC 9728 | OAuth 2.0 Protected Resource Metadata | Apr 2025 | Proposed Standard | [rfc9728.txt](../rfc-sources/rfc9728.txt) | mostly | 0 / 1 / 11 | [metadata](rfc-coverage-findings/metadata.md#rfc9728-oauth-20-protected-resource-metadata) |
| RFC 9901 | Selective Disclosure for JSON Web Tokens | Nov 2025 | Proposed Standard | [rfc9901.txt](../rfc-sources/rfc9901.txt) | not-applicable | 0 / 0 / 3 | [jwt-at-sdjwt](rfc-coverage-findings/jwt-at-sdjwt.md#rfc-9901-selective-disclosure-for-json-web-tokens-sd-jwt) |
| RFC 10017 | OAuth 2.0 for Browser-Based Applications | Aug 2026 | BCP 212 | [rfc10017.txt](../rfc-sources/rfc10017.txt) | partial | 2 / 2 / 4 | [pkce-apps](rfc-coverage-findings/pkce-apps.md#rfc-10017-oauth-20-for-browser-based-applications) |
| RFC 10027 | Best Current Practice for Security of Cross-Device Flows | Aug 2026 | BCP 247 | [rfc10027.txt](../rfc-sources/rfc10027.txt) | none | 0 / 2 / 7 | [device-crossdevice](rfc-coverage-findings/device-crossdevice.md#rfc-10027-best-current-practice-for-security-of-cross-device-flows) |

URN = Uniform Resource Name. A status such as "BCP 212" means that the RFC is
part of that Best Current Practice.

### 3.3 T2-T4 and the vendored T7 RFCs

| RFC | Title | Criterion | Published | Status | Local text | YAML coverage | H / M / L | Findings |
|---|---|---|---|---|---|---|---|---|
| RFC 5849 | The OAuth 1.0 Protocol | 2 — origin | Apr 2010 | Informational | [rfc5849.txt](../rfc-sources/rfc5849.txt) | not-applicable | 0 / 0 / 0 | [oauth1-origin](rfc-coverage-findings/oauth1-origin.md#rfc-5849-the-oauth-10-protocol) |
| RFC 7797 | JSON Web Signature (JWS) Unencoded Payload Option | 3 — updates RFC 7519 | Feb 2016 | Proposed Standard | [rfc7797.txt](../rfc-sources/rfc7797.txt) | none (was not-applicable) | 0 / 0 / 1 | [jwt](rfc-coverage-findings/jwt.md#rfc-7797-json-web-signature-jws-unencoded-payload-option) |
| RFC 8996 | Deprecating TLS 1.0 and TLS 1.1 | 3 — updates RFC 6749, 6750 | Mar 2021 | BCP 195 | [rfc8996.txt](../rfc-sources/rfc8996.txt) | none | 0 / 0 / 2 | [bearer-http](rfc-coverage-findings/bearer-http.md#rfc-8996-deprecating-tls-10-and-tls-11) |
| RFC 7515 | JSON Web Signature (JWS) | 4 — JOSE core | May 2015 | Proposed Standard | [rfc7515.txt](../rfc-sources/rfc7515.txt) | partial | 0 / 2 / 5 | [jose](rfc-coverage-findings/jose.md#rfc7515-json-web-signature-jws) |
| RFC 7516 | JSON Web Encryption (JWE) | 4 — JOSE core | May 2015 | Proposed Standard | [rfc7516.txt](../rfc-sources/rfc7516.txt) | partial | 0 / 1 / 4 | [jose](rfc-coverage-findings/jose.md#rfc7516-json-web-encryption-jwe) |
| RFC 7517 | JSON Web Key (JWK) | 4 — JOSE core | May 2015 | Proposed Standard | [rfc7517.txt](../rfc-sources/rfc7517.txt) | mostly | 1 / 2 / 10 | [jose](rfc-coverage-findings/jose.md#rfc7517-json-web-key-jwk) |
| RFC 7518 | JSON Web Algorithms (JWA) | 4 — JOSE core | May 2015 | Proposed Standard | [rfc7518.txt](../rfc-sources/rfc7518.txt) | partial | 1 / 4 / 4 | [jose](rfc-coverage-findings/jose.md#rfc7518-json-web-algorithms-jwa) |
| RFC 7638 | JSON Web Key (JWK) Thumbprint | 4 — JOSE core | Sep 2015 | Proposed Standard | [rfc7638.txt](../rfc-sources/rfc7638.txt) | partial (was mostly) | 0 / 0 / 2 | [jose](rfc-coverage-findings/jose.md#rfc7638-json-web-key-jwk-thumbprint) |
| RFC 8037 | CFRG Elliptic Curve Diffie-Hellman (ECDH) and Signatures in JSON Object Signing and Encryption (JOSE) | 4 — JOSE core | Jan 2017 | Proposed Standard | [rfc8037.txt](../rfc-sources/rfc8037.txt) | mostly | 0 / 0 / 1 | [jose](rfc-coverage-findings/jose.md#rfc8037-cfrg-elliptic-curve-diffie-hellman-ecdh-and-signatures-in-json-object-signing-and-encryption-jose) |
| RFC 9864 | Fully-Specified Algorithms for JSON Object Signing and Encryption (JOSE) and CBOR Object Signing and Encryption (COSE) | 4 — JOSE core; updates RFC 7518, 8037 | Oct 2025 | Proposed Standard | [rfc9864.txt](../rfc-sources/rfc9864.txt) | none | 0 / 0 / 3 | [jose](rfc-coverage-findings/jose.md#rfc9864-fully-specified-algorithms-for-json-object-signing-and-encryption-jose-and-cbor-object-signing-and-encryption-cose) |
| RFC 3986 | Uniform Resource Identifier (URI): Generic Syntax | 5 — cited by the YAML | Jan 2005 | Internet Standard (STD 66) | [rfc3986.txt](../rfc-sources/rfc3986.txt) | partial (was referenced-only) | 0 / 0 / 4 | [metadata](rfc-coverage-findings/metadata.md#rfc3986-uniform-resource-identifier-uri-generic-syntax) |
| RFC 5646 | Tags for Identifying Languages | 5 — cited as "BCP47" | Sep 2009 | BCP 47 | [rfc5646.txt](../rfc-sources/rfc5646.txt) | not assessed separately (used by `ui_locales`, `claims_locales`) | — | — |
| RFC 7617 | The 'Basic' HTTP Authentication Scheme | 5 — cited by the YAML | Sep 2015 | Proposed Standard | [rfc7617.txt](../rfc-sources/rfc7617.txt) | mostly | 0 / 2 / 4 | [bearer-http](rfc-coverage-findings/bearer-http.md#rfc-7617-the-basic-http-authentication-scheme) |
| RFC 9110 | HTTP Semantics | 5 — cited by the YAML | Jun 2022 | Internet Standard (STD 97) | [rfc9110.txt](../rfc-sources/rfc9110.txt) | mostly | 0 / 1 / 7 | [bearer-http](rfc-coverage-findings/bearer-http.md#rfc-9110-http-semantics) |

CFRG = Crypto Forum Research Group; CBOR = Concise Binary Object
Representation; COSE = CBOR Object Signing and Encryption; STD = the number of
an Internet Standard.

### 3.4 Catalogued, not vendored

These 48 RFCs are OAuth-related but outside the scope rule. Families with the
same reason share one row. "Reason" is the catalogue's reason for not
vendoring.

| RFC | Title | Tier | Published | WG | Reason |
|---|---|---|---|---|---|
| [RFC 7165](https://www.rfc-editor.org/rfc/rfc7165.html) | Use Cases and Requirements for JSON Object Signing and Encryption (JOSE) | T4 | Apr 2014 | jose | Informational background; no normative content an AS implements. |
| [RFC 7520](https://www.rfc-editor.org/rfc/rfc7520.html) | Examples of Protecting Content Using JSON Object Signing and Encryption (JOSE) | T4 | May 2015 | jose | Useful test vectors; not normative for the AS surface. |
| [RFC 8812](https://www.rfc-editor.org/rfc/rfc8812.html) | CBOR Object Signing and Encryption (COSE) and JSON Object Signing and Encryption (JOSE) Registrations for Web Authentication (WebAuthn) Algorithms | T4 | Aug 2020 | cose | Rarely used in OAuth/OIDC; cite it where the YAML lists `secp256k1`. |
| [RFC 9964](https://www.rfc-editor.org/rfc/rfc9964.html) | ML-DSA for JSON Object Signing and Encryption (JOSE) and CBOR Object Signing and Encryption (COSE) | T4 | May 2026 | cose | Post-quantum algorithms for the future; the YAML's JWK description (lines 1828-1830) already anticipates new key types. |
| [RFC 7628](https://www.rfc-editor.org/rfc/rfc7628.html) | A Set of Simple Authentication and Security Layer (SASL) Mechanisms for OAuth | T5 | Aug 2015 | kitten | Profile for another protocol; not part of the AS HTTP surface. |
| [RFC 7635](https://www.rfc-editor.org/rfc/rfc7635.html) | Session Traversal Utilities for NAT (STUN) Extension for Third-Party Authorization | T5 | Aug 2015 | tram | Profile for another protocol (normatively cites RFC 6749). |
| [RFC 8392](https://www.rfc-editor.org/rfc/rfc8392.html), [RFC 8747](https://www.rfc-editor.org/rfc/rfc8747.html), [RFC 9200](https://www.rfc-editor.org/rfc/rfc9200.html), [RFC 9201](https://www.rfc-editor.org/rfc/rfc9201.html), [RFC 9202](https://www.rfc-editor.org/rfc/rfc9202.html), [RFC 9203](https://www.rfc-editor.org/rfc/rfc9203.html), [RFC 9237](https://www.rfc-editor.org/rfc/rfc9237.html), [RFC 9430](https://www.rfc-editor.org/rfc/rfc9430.html), [RFC 9431](https://www.rfc-editor.org/rfc/rfc9431.html), [RFC 9594](https://www.rfc-editor.org/rfc/rfc9594.html), [RFC 9770](https://www.rfc-editor.org/rfc/rfc9770.html) | The ACE framework (RFC 9200, ACE-OAuth) and its parts: CBOR Web Token (CWT), proof-of-possession for CWTs, extra OAuth parameters, the DTLS, OSCORE, TLS and MQTT profiles, the Authorization Information Format, group key provisioning, revocation notices | T5 | May 2018 - Jun 2025 | ace | A parallel profile of OAuth for constrained devices, built on the Constrained Application Protocol (CoAP) and CBOR. It registers OAuth parameters but is not used by an HTTP AS. |
| [RFC 8417](https://www.rfc-editor.org/rfc/rfc8417.html) | Security Event Token (SET) | T5 | Jul 2018 | secevent | The YAML only carries `backchannel_logout_*` flags (lines 2226-2229); vendor it if logout tokens are modeled. |
| [RFC 8471](https://www.rfc-editor.org/rfc/rfc8471.html), [RFC 8472](https://www.rfc-editor.org/rfc/rfc8472.html), [RFC 8473](https://www.rfc-editor.org/rfc/rfc8473.html) | The Token Binding Protocol Version 1.0; its TLS negotiation extension; Token Binding over HTTP | T5 | Oct 2018 | tokbind | Historical binding mechanism; it never gained browser support (Chrome removed its implementation in 2018). |
| [RFC 8485](https://www.rfc-editor.org/rfc/rfc8485.html) | Vectors of Trust | T5 | Oct 2018 | — (non-WG) | Optional extension, not modeled by the YAML. |
| [RFC 8898](https://www.rfc-editor.org/rfc/rfc8898.html) | Third-Party Token-Based Authentication and Authorization for Session Initiation Protocol (SIP) | T5 | Sep 2020 | sipcore | Profile for another protocol. |
| [RFC 8935](https://www.rfc-editor.org/rfc/rfc8935.html), [RFC 8936](https://www.rfc-editor.org/rfc/rfc8936.html), [RFC 9493](https://www.rfc-editor.org/rfc/rfc9493.html) | Push-Based and Poll-Based Security Event Token (SET) Delivery Using HTTP; Subject Identifiers for Security Event Tokens | T5 | Nov 2020 - Dec 2023 | secevent | Security-event transport and identifiers; not AS surface. |
| [RFC 9635](https://www.rfc-editor.org/rfc/rfc9635.html), [RFC 9767](https://www.rfc-editor.org/rfc/rfc9767.html) | Grant Negotiation and Authorization Protocol (GNAP); GNAP Resource Server Connections | T5 | Oct 2024 - Apr 2025 | gnap | An alternative protocol, not OAuth; useful as a contrast when you study design. |
| [RFC 9679](https://www.rfc-editor.org/rfc/rfc9679.html) | CBOR Object Signing and Encryption (COSE) Key Thumbprint | T5 | Dec 2024 | cose | Registers an OAuth URI (`urn:ietf:params:oauth:ckt`) but is CBOR/COSE-only. |
| [RFC 6616](https://www.rfc-editor.org/rfc/rfc6616.html) | A Simple Authentication and Security Layer (SASL) and Generic Security Service Application Program Interface (GSS-API) Mechanism for OpenID | T6 | May 2012 | kitten | OpenID 2.0, not OIDC; history only. |
| [RFC 7644](https://www.rfc-editor.org/rfc/rfc7644.html) | System for Cross-domain Identity Management: Protocol | T6 | Sep 2015 | scim | Consumer of AS-issued tokens. |
| [RFC 7846](https://www.rfc-editor.org/rfc/rfc7846.html) | Peer-to-Peer Streaming Tracker Protocol (PPSTP) | T6 | May 2016 | ppsp | Consumer; passing use. |
| [RFC 7853](https://www.rfc-editor.org/rfc/rfc7853.html) | A URN Namespace for Globus | T6 | May 2016 | — (non-WG) | Consumer; an example of URN-named scopes and extension grants. |
| [RFC 8620](https://www.rfc-editor.org/rfc/rfc8620.html) | The JSON Meta Application Protocol (JMAP) | T6 | Jul 2019 | jmap | Consumer. |
| [RFC 9509](https://www.rfc-editor.org/rfc/rfc9509.html) | X.509 Certificate Extended Key Usage (EKU) for 5G Network Functions | T6 | Mar 2024 | lamps | Consumer (5G network functions); shows a signing-key policy for access tokens. |
| [RFC 9560](https://www.rfc-editor.org/rfc/rfc9560.html) | Federated Authentication for the Registration Data Access Protocol (RDAP) Using OpenID Connect | T6 | Apr 2024 | regext | Consumer of OIDC. |
| [RFC 9725](https://www.rfc-editor.org/rfc/rfc9725.html) | WebRTC-HTTP Ingestion Protocol (WHIP) | T6 | Mar 2025 | wish | Consumer of bearer tokens. |
| [RFC 9967](https://www.rfc-editor.org/rfc/rfc9967.html) | System for Cross-Domain Identity Management (SCIM) Profile for Security Event Tokens (SETs) | T6 | May 2026 | scim | Consumer of SETs and JWTs; not AS surface. |
| [RFC 10006](https://www.rfc-editor.org/rfc/rfc10006.html) | Automatic SIP Trunking and Peering | T6 | Aug 2026 | asap | Consumer; a 2026 RFC that depends on RFC 6749. |
| [RFC 6711](https://www.rfc-editor.org/rfc/rfc6711.html) | An IANA Registry for Level of Assurance (LoA) Profiles | T7 | Aug 2012 | — (non-WG) | Supports `acr` / `acr_values` semantics; not cited by the YAML. |
| [RFC 7033](https://www.rfc-editor.org/rfc/rfc7033.html) | WebFinger | T7 | Sep 2013 | appsawg | Not modeled by the YAML. |
| [RFC 7236](https://www.rfc-editor.org/rfc/rfc7236.html) | Initial Hypertext Transfer Protocol (HTTP) Authentication Scheme Registrations | T7 | Jun 2014 | httpbis | Registry history only. |
| [RFC 7643](https://www.rfc-editor.org/rfc/rfc7643.html) | System for Cross-domain Identity Management: Core Schema | T7 | Sep 2015 | scim | Normative dependency of RFC 9068; the YAML cites only RFC 9068. |
| [RFC 8032](https://www.rfc-editor.org/rfc/rfc8032.html) | Edwards-Curve Digital Signature Algorithm (EdDSA) | T7 | Jan 2017 | — (IRTF stream) | Cryptographic primitive; use a library. |
| [RFC 8615](https://www.rfc-editor.org/rfc/rfc8615.html) | Well-Known Uniform Resource Identifiers (URIs) | T7 | May 2019 | — (non-WG) | Not cited by the YAML (RFC 8414 cites its predecessor, RFC 5785). |
| [RFC 8959](https://www.rfc-editor.org/rfc/rfc8959.html) | The "secret-token" URI Scheme | T7 | Jan 2021 | — (non-WG) | Optional token-format hint. |
| [RFC 9421](https://www.rfc-editor.org/rfc/rfc9421.html) | HTTP Message Signatures | T7 | Feb 2024 | httpbis | Not used by the current YAML. |
| [RFC 9440](https://www.rfc-editor.org/rfc/rfc9440.html) | Client-Cert HTTP Header Field | T7 | Jul 2023 | httpbis | Deployment aid for mTLS behind a proxy, not protocol surface. |

NAT = network address translation; DTLS = Datagram Transport Layer Security;
OSCORE = Object Security for Constrained RESTful Environments; MQTT = Message
Queuing Telemetry Transport; ML-DSA = Module-Lattice-Based Digital Signature
Standard, a post-quantum signature scheme; IRTF = Internet Research Task Force;
WebRTC = Web Real-Time Communication; `acr` = Authentication Context Class
Reference, the OIDC claim that names the level of authentication.

The 84 tier-X RFCs are not listed here. Some are term collisions (for example
"JWT" meaning "Joint Working Team"). Others are HTTP authentication schemes
that are not OAuth schemes, RFCs that mention OAuth only in passing, or ACE WG
documents without OAuth content. The rest use JWT and JOSE outside OAuth, for
example for signed caller identity in telephony (STIR/PASSporT), automatic
certificate issuance (ACME), content-delivery URI signing (CDNI) and remote
attestation (RATS).

### 3.5 The 14 RFCs the completeness checks newly found

The initial candidate list missed 14 OAuth-relevant RFCs. Only RFC 5646 needed
vendoring, because the YAML cites "BCP47".

| RFC | Title | Tier | Found by | Why it matters |
|---|---|---|---|---|
| [RFC 9679](https://www.rfc-editor.org/rfc/rfc9679.html) | CBOR Object Signing and Encryption (COSE) Key Thumbprint | T5 | IANA OAuth registry | Registers `urn:ietf:params:oauth:ckt`; the COSE counterpart of RFC 9278. |
| [RFC 5646](../rfc-sources/rfc5646.txt) | Tags for Identifying Languages | T7 | IANA OAuth registry | BCP 47 tag syntax for `ui_locales`, `claims_locales` and `*_locales_supported`. **Now vendored.** |
| [RFC 6711](https://www.rfc-editor.org/rfc/rfc6711.html) | An IANA Registry for Level of Assurance (LoA) Profiles | T7 | full-text search | OIDC Core §2 recommends its registered names for `acr` values. |
| [RFC 7236](https://www.rfc-editor.org/rfc/rfc7236.html) | Initial Hypertext Transfer Protocol (HTTP) Authentication Scheme Registrations | T7 | normatively cites RFC 6750 | Registered the `Bearer` and `OAuth` schemes. |
| [RFC 7643](https://www.rfc-editor.org/rfc/rfc7643.html) | System for Cross-domain Identity Management: Core Schema | T7 | informatively cites RFC 6749; IANA JWT registry | Source of the `roles`, `groups` and `entitlements` claims that RFC 9068 imports. |
| [RFC 8032](https://www.rfc-editor.org/rfc/rfc8032.html) | Edwards-Curve Digital Signature Algorithm (EdDSA) | T7 | IANA JOSE registry | The primitive behind Ed25519 and Ed448. |
| [RFC 6616](https://www.rfc-editor.org/rfc/rfc6616.html) | A Simple Authentication and Security Layer (SASL) and Generic Security Service Application Program Interface (GSS-API) Mechanism for OpenID | T6 | full-text search | OpenID 2.0; history only. |
| [RFC 7644](https://www.rfc-editor.org/rfc/rfc7644.html) | System for Cross-domain Identity Management: Protocol | T6 | normatively cites RFC 6749 and 6750 | May use OAuth bearer tokens. |
| [RFC 7846](https://www.rfc-editor.org/rfc/rfc7846.html) | Peer-to-Peer Streaming Tracker Protocol (PPSTP) | T6 | normatively cites RFC 6749 | Suggests OAuth 2.0 bearer tokens. |
| [RFC 7853](https://www.rfc-editor.org/rfc/rfc7853.html) | A URN Namespace for Globus | T6 | normatively cites RFC 6749 | Names OAuth scopes and extension grants with URNs. |
| [RFC 8620](https://www.rfc-editor.org/rfc/rfc8620.html) | The JSON Meta Application Protocol (JMAP) | T6 | normatively cites RFC 6749 | Ties push subscriptions to refresh-token validity. |
| [RFC 9509](https://www.rfc-editor.org/rfc/rfc9509.html) | X.509 Certificate Extended Key Usage (EKU) for 5G Network Functions | T6 | full-text search; cites RFC 7519 | Defines a key purpose for signing OAuth 2.0 access tokens. |
| [RFC 9725](https://www.rfc-editor.org/rfc/rfc9725.html) | WebRTC-HTTP Ingestion Protocol (WHIP) | T6 | normatively cites RFC 6750 | Requires bearer-token authentication. |
| [RFC 10006](https://www.rfc-editor.org/rfc/rfc10006.html) | Automatic SIP Trunking and Peering | T6 | normatively cites RFC 6749 | OAuth 2.0 MUST be used for client authentication (§4.3); it still discusses the password grant that OAuth 2.1 removes. |

### 3.6 How the catalogue was cross-checked

| Check | What was done | Result |
|---|---|---|
| a. Full-text search | Title, abstract and keywords of all 9,847 RFCs, 15 OAuth terms | 85 hits = 70 candidates + 15 new (3 relevant: RFC 6616, 6711, 9509; 12 term collisions or JWT users outside OAuth) |
| b. Datatracker "referenced by" | RFC 6749, 6750, 7519, 8414 | 114 published RFCs cite at least one; exactly 47 RFCs cite RFC 6749 normatively; new consumers RFC 7644, 7846, 7853, 8620, 10006 |
| c. IANA registries | OAuth Parameters, JWT, JOSE, HTTP Authentication Schemes | 83 distinct RFCs cited (29 new; relevant: 5646, 9679, 7643, 8032); 8 unpublished documents already cited |
| d. Extra "referenced by" sweep | 42 more targets (the other OAuth WG RFCs, RFC 5849, the JOSE core, RFC 7628, 8417, 9200) | 21 more RFCs, all tier X |
| e. WG membership | All RFCs of the WGs oauth (36), jose (10), secevent (4), ace (15), gnap (2), tokbind (3) | All in the catalogue; the newer WGs wimse and spice have no RFCs yet |
| f. Formal relationships | Obsoletes / Updates in the index and Datatracker | Only RFC 7797 and RFC 8996 update an OAuth WG RFC from outside the WG |
| g. Title scans | All RFCs 2007-2026 not yet classified, for token, identity, credential and federation terms | No OAuth RFC missed |
| h. YAML dependency check | Every `RFC NNNN` in the YAML, plus implicit dependencies | 33 RFCs cited; 6 not vendored; implicit: "BCP47" = RFC 5646, `secp256k1` = RFC 8812, deprecated `EdDSA` = RFC 9864, `roles`/`groups`/`entitlements` = RFC 7643 |
| i. Text verification | The 72 newly found RFC texts downloaded and read | Classifications confirmed |
| j. Metadata audit | Every candidate field against the RFC index | No field errors |
| Community cross-check | 37 sources (oauth.net, Datatracker, Wikipedia, OIDF, spec maps) | All 36 OAuth WG RFCs, titles and statuses match on oauth.net and Datatracker |

Two lessons for future audits. First, **an IANA-only check would miss
RFC 10017 and RFC 10027**: they have no IANA actions (RFC 10017 §10, RFC 10027
§8). Second, **a WG-only check would miss RFC 5849**: it came from an individual
draft.

The community check named 55 RFCs that OAuth-family or OIDF documents cite but
the initial candidate list lacked. 8 of them are now in the catalogue (for
example RFC 5646 and RFC 6711); most of the others are generic (JSON, UTF-8,
older HTTP RFCs, X.509) or superseded. Worth knowing: RFC 9325 and RFC 9852, which form BCP 195 (TLS
guidance) with RFC 8996, and RFC 9525 (TLS server identity). They are not
vendored because the YAML does not cite them, but an AS should follow BCP 195.

### 3.7 Conflicts in public sources

Many public lists of "OAuth specs" are out of date. The ones checked on
2026-10-10:

| Source | Problem | Current fact |
|---|---|---|
| Wikipedia, "OAuth" (edited 2026-09-24) | OAuth Core 1.0 released "October 3, 2007"; OAuth 2.1 status "as of November 2024" (draft -12); the Security BCP cited as draft -13 (2019) | oauth.net and the spec say 4 December 2007; OAuth 2.1 is at -16 (3 September 2026); the Security BCP is RFC 9700 (BCP 240, January 2025). |
| oauth.com "Map of OAuth 2.0 Specs" (modified 2021-12-16) | Security BCP and browser-based apps "still in draft"; RAR and DPoP "early drafts" | RFC 9700 (2025), RFC 10017 (2026), RFC 9396 (2023), RFC 9449 (2023). |
| oauth.net/core/1.0 banner | `draft-hammer-oauth` "pending IESG approval" | Published as RFC 5849 in April 2010. |
| `draft-chen-oauth-roadmap-01` (6 May 2026) | RFC 7592 marked Standards Track; RFC 9728 called the Security BCP; browser-apps and cross-device still drafts; omits RFC 6755, 7522, 7800, 8176, 9278, 9470, 9701; says "OAuth Working Group" | RFC 7592 is Experimental; the Security BCP is RFC 9700; RFC 10017 and 10027 are published; the draft is an individual submission. |
| oauth.net/fapi | FAPI 2.0 Message Signing labelled "Draft" | Final, 25 September 2025. |
| oauth.net OpenID4VC page | OID4VCI and OID4VP linked as editors' drafts | Both Final (16 September 2025 and 9 July 2025). |
| IETF OAuth wiki "OAuth Spec Clusters" | Omits RFC 6755; uses pre-publication titles | 36 OAuth WG RFCs; index titles differ. |
| `danielfett/oauth-linklist` (archived; last commit 2023-10-25) | SD-JWT, cross-device BCP, Security BCP shown as drafts | RFC 9901, RFC 10027, RFC 9700. |
| OAuth 2.1 -16 itself | Cites BCP 195 as the 2015 edition (RFC 7525) and RFC 2617 normatively | RFC 7525 was obsoleted by RFC 9325; RFC 2617 by RFC 7617 and others. |
| openid.net "current map for OpenID Connect" | Dated July 15, 2011 | Predates the Final OIDC specifications. |

IESG = Internet Engineering Steering Group; RAR = Rich Authorization Requests;
FAPI = Financial-grade API; OID4VCI and OID4VP = OpenID for Verifiable
Credential Issuance and for Verifiable Presentations; SD-JWT = Selective
Disclosure for JWTs.

The cross-check found more, smaller problems of the same kind.
`draft-chen-oauth-roadmap-01` also presents the mix-up-mitigation draft (last
revision -01, from 2016) as current work. It says that Token Binding was "not
finalized", although RFC 8471, 8472 and 8473 were published in October 2018.
Some sources use non-standard names. Wikipedia writes "oAuth". oauth.net
calls RFC 9530 "HTTP Digest Headers" (its title is "Digest Fields"). oauth.net
also labels IndieAuth as a W3C (World Wide Web Consortium) specification, but
the current IndieAuth text is an IndieWeb Living Standard (11 July 2024), and
the W3C version is a 2018 Working Group Note. So check every status and title
in the RFC Editor index or on the Datatracker.

### 3.8 BCP numbers name sets, not single RFCs

A BCP number can grow. Cite the RFC number when you mean one document.

| BCP | RFCs today |
|---|---|
| BCP 212 | RFC 8252 (native apps) + RFC 10017 (browser-based apps) |
| BCP 195 | RFC 8996 + RFC 9325 + RFC 9852 (July 2026) |
| BCP 47 | RFC 5646 (tag syntax, vendored) + RFC 4647 (tag matching) |
| BCP 225 | RFC 8725 (to be replaced by `draft-ietf-oauth-rfc8725bis`) |
| BCP 240 | RFC 9700 |
| BCP 247 | RFC 10027 |

---

## 4. What this audit changed

### 4.1 Files

State of the working tree on 2026-10-11 (`git status`), before this report and
[`oauth-rfc-timeline.md`](oauth-rfc-timeline.md) were added (both are new
files too):

| Change | Files |
|---|---|
| Modified (7) | `CLAUDE.md`, `README.md`, `references/audit/README.md`, `references/oidf-sources/README.md`, `references/rfc-sources/README.md`, `references/rfc-sources/draft-ietf-oauth-v2-1.txt` (-15 → -16), `tools/README.md` |
| New in `references/rfc-sources/` (16) | `manifest.txt`, `rfc3986.txt`, `rfc5646.txt`, `rfc5849.txt`, `rfc7515.txt`, `rfc7516.txt`, `rfc7518.txt`, `rfc7617.txt`, `rfc7638.txt`, `rfc7797.txt`, `rfc8037.txt`, `rfc8996.txt`, `rfc9110.txt`, `rfc9864.txt`, `rfc10017.txt`, `rfc10027.txt` |
| New in `references/oidf-sources/` (8) | `manifest.txt`, `oauth-v2-jarm.html`, `openid-client-initiated-backchannel-authentication-core-1_0.html`, `openid-connect-backchannel-1_0.html`, `openid-connect-frontchannel-1_0.html`, `openid-connect-registration-1_0.html`, `openid-connect-rpinitiated-1_0.html`, `openid-connect-session-1_0.html` |
| New elsewhere | `references/audit/rfc-coverage-findings/` (22 files), `tools/fetch-specs.sh` |

### 4.2 Drift check before and after

Before vendoring (`tools/fetch-specs.sh --check`, non-OK lines; 35 RFCs were
OK):

```text
# rfc-sources
MISSING    rfc5849.txt                          https://www.rfc-editor.org/rfc/rfc5849.txt
MISSING    rfc10017.txt                         https://www.rfc-editor.org/rfc/rfc10017.txt
MISSING    rfc10027.txt                         https://www.rfc-editor.org/rfc/rfc10027.txt
MISSING    rfc7797.txt                          https://www.rfc-editor.org/rfc/rfc7797.txt
MISSING    rfc8996.txt                          https://www.rfc-editor.org/rfc/rfc8996.txt
MISSING    rfc7515.txt                          https://www.rfc-editor.org/rfc/rfc7515.txt
MISSING    rfc7516.txt                          https://www.rfc-editor.org/rfc/rfc7516.txt
MISSING    rfc7518.txt                          https://www.rfc-editor.org/rfc/rfc7518.txt
MISSING    rfc7638.txt                          https://www.rfc-editor.org/rfc/rfc7638.txt
MISSING    rfc8037.txt                          https://www.rfc-editor.org/rfc/rfc8037.txt
MISSING    rfc9864.txt                          https://www.rfc-editor.org/rfc/rfc9864.txt
MISSING    rfc3986.txt                          https://www.rfc-editor.org/rfc/rfc3986.txt
MISSING    rfc5646.txt                          https://www.rfc-editor.org/rfc/rfc5646.txt
MISSING    rfc7617.txt                          https://www.rfc-editor.org/rfc/rfc7617.txt
MISSING    rfc9110.txt                          https://www.rfc-editor.org/rfc/rfc9110.txt
OUTDATED   draft-ietf-oauth-v2-1.txt            local -15, latest -16
# oidf-sources
OK         oidc-core-1.0.html                   https://openid.net/specs/openid-connect-core-1_0.html
OK         oidc-discovery-1.0.html              https://openid.net/specs/openid-connect-discovery-1_0.html
MISSING    openid-connect-registration-1_0.html https://openid.net/specs/openid-connect-registration-1_0.html
MISSING    openid-connect-session-1_0.html      https://openid.net/specs/openid-connect-session-1_0.html
MISSING    openid-connect-rpinitiated-1_0.html  https://openid.net/specs/openid-connect-rpinitiated-1_0.html
MISSING    openid-connect-frontchannel-1_0.html https://openid.net/specs/openid-connect-frontchannel-1_0.html
MISSING    openid-connect-backchannel-1_0.html  https://openid.net/specs/openid-connect-backchannel-1_0.html
MISSING    openid-client-initiated-backchannel-authentication-core-1_0.html https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html
OK         oauth-v2-multiple-response-types-1_0.html https://openid.net/specs/oauth-v2-multiple-response-types-1_0.html
OK         oauth-v2-form-post-response-mode-1_0.html https://openid.net/specs/oauth-v2-form-post-response-mode-1_0.html
OK         openid-financial-api-jarm.html       https://openid.net/specs/openid-financial-api-jarm.html
MISSING    oauth-v2-jarm.html                   https://openid.net/specs/oauth-v2-jarm.html
```

After vendoring:

```text
rfc-sources: 51 OK, 0 not OK (exit 0)
oidf-sources: 12 OK, 0 not OK (exit 0)
```

### 4.3 What was added or changed

| Path | Change |
|---|---|
| `references/rfc-sources/` | 15 RFCs added (5849; 10017, 10027; 7797, 8996; 7515, 7516, 7518, 7638, 8037, 9864; 3986, 5646, 7617, 9110). OAuth 2.1 draft refreshed from -15 to -16 (3 September 2026). Now 51 documents (50 RFCs + 1 draft), about 4.0 MB. |
| [`../rfc-sources/manifest.txt`](../rfc-sources/manifest.txt) (new) | The authoritative list, grouped by criterion. |
| [`../rfc-sources/README.md`](../rfc-sources/README.md) (rewritten) | Five-criteria scope rule; index with Published, Status and formal relationships; the BCP-set note; a watch list of six drafts; refresh and audit commands; history; corrected licensing text (BCP 78 and the IETF Trust Legal Provisions). |
| `references/oidf-sources/` | 7 specs added: Dynamic Client Registration, Session Management, RP-Initiated Logout (RP = relying party), Front-Channel Logout, Back-Channel Logout and Client-Initiated Backchannel Authentication (CIBA) Core — fields the YAML already advertised — plus the Final JWT Secured Authorization Response Mode (JARM) with errata set 1. The 2018 JARM draft stays because RFC 9700 and RFC 9207 cite it. Now 12 documents, about 1.2 MB. |
| [`../oidf-sources/manifest.txt`](../oidf-sources/manifest.txt) (new), [`../oidf-sources/README.md`](../oidf-sources/README.md) (rewritten) | Scope rule; index with status, dates and reasons; the two-file JARM note; refresh and audit; history; licensing that quotes the OIDF notice. |
| [`../../tools/fetch-specs.sh`](../../tools/fetch-specs.sh) (new, 518 lines) | Fetches or `--check`s RFCs, drafts (the latest revision through the Datatracker API, or an exact `-NN`) and any `<file>=<https-url>` document. Atomic writes, header and content checks, exit codes 0, 2, 3, 4, 5, 6 and 10, compatible with bash 3.2. It replaces the `curl` loops that were run by hand (the project's script-first rule). |
| [`../../tools/README.md`](../../tools/README.md) | A scripts table and a runbook for `fetch-specs.sh`. |
| `CLAUDE.md` (project conventions) | The `rfc-sources/` and `oidf-sources/` rules match the new scope and the script; the audit-document list includes the two new reports. |
| [`../../README.md`](../../README.md), [`README.md`](README.md) (this folder) | Point to this report, the timeline and the findings; the repository layout lists the new files. |
| [`rfc-coverage-findings/`](rfc-coverage-findings/README.md) (new) | The verified findings: an index and 21 cluster files (724 findings). |

**Not changed:** `oauth-openapi.yaml`, the modular view
(`oauth-openapi-modular/`), the May 2026 reports in `../rfc-validation/`, and
the two historical community specs.

---

## 5. OAuth 2.1 draft-16

### 5.1 Status

`draft-ietf-oauth-v2-1-16` was posted on 2026-09-03 and expires on 2027-03-07.
Its Datatracker state is "WG Document": it has not reached WG Last Call, and
the WG milestone is to submit it to the IESG in December 2026. It is **not an
RFC**. Once published it will obsolete RFC 6749 and RFC 6750. Section 9
(Browser-Based Apps) is still a placeholder, and the draft still cites the
browser-apps Internet-Draft (-27) although that became RFC 10017 in August
2026; both suggest that the text will change again. The vendored text is now
[`../rfc-sources/draft-ietf-oauth-v2-1.txt`](../rfc-sources/draft-ietf-oauth-v2-1.txt)
(-16).

### 5.2 What changed from -15 to -16

| Change in -16 | Section in -16 | Impact on the YAML |
|---|---|---|
| `iss` in the authorization response changed from OPTIONAL to **REQUIRED**, in both the success and the error response; §7.15.1 now says the issuer "is transported via the response parameter iss". | §4.1.2, §4.1.2.1, §7.15.1 | `/authorize` 302 (lines 161-170): `iss` is always sent. Publish `authorization_response_iss_parameter_supported: true` (lines 2206-2211; RFC 9207 §2.3). Add `iss` to `ErrorResponse` (1529-1533). Say in `issuer` (1944-1950) that it must equal the `iss` parameter. |
| PKCE `plain` removed: `code_challenge_method` changed from "OPTIONAL, defaults to plain" to **REQUIRED** (`S256` or a future extension value); clients MUST (was SHOULD) use methods that do not expose the verifier; the "S256 is Mandatory To Implement" sentence was deleted. | §4.1.1 | Rewrite `CodeChallengeMethod` (780-795). Delete `default: S256` in `PARRequest` (1612-1615). Update `code_challenge_methods_supported` (2176-2185). Mirror in the modular spec and bundle. |
| New subsection: PKCE `plain` is forbidden (the verifier travels in clear; it is a downgrade vector). Deployments with clients that cannot do S256 SHOULD issue extended-lifetime refresh tokens before they drop `plain`. | §7.5.2 (new), §10 | Cite §7.5.2 where the YAML explains why `plain` is omitted (785-792, 2181-2185). |
| Renumbering in §7.5: Reuse of Authorization Codes §7.5.2 → §7.5.3; HTTP 307 Redirect §7.5.3 → §7.5.4. | §7.5.3, §7.5.4 | Lines 171 and 183 must cite §7.5.4. |
| New §7.9 Consent Phishing: restrict scopes per client, verify developers before sensitive scopes, show client name, organization and scopes, let users review and revoke grants. §7.9-§7.14 become §7.10-§7.15. | §7.9-§7.15 | No wire change; the YAML cites none of the shifted numbers. Optionally describe the consent page and the client display metadata (once a client metadata schema exists). |
| New §1.7.1 Value Sizes: no maximum lengths; receivers MUST NOT assume a length; support values within an 8000-octet request line. | §1.7.1 | Keep the absence of `maxLength` on `client_id`, `code`, tokens and `state`; add notes. `maxLength: 128` on `code_challenge` and `code_verifier` is correct: it matches the draft's ABNF (Augmented Backus-Naur Form) grammar. |
| Authorization-endpoint errors: HTTP 400 SHOULD be used when the error is shown to the user; 401 does not apply; `client_id` and `redirect_uri` MUST be validated before any error is redirected. | §4.1.2.1 | `/authorize` 400 (196-205): cite OAuth 2.1 §4.1.2.1 and cover a missing, invalid or unknown `client_id`. |
| §3.1 now says that extensions such as PAR define their own parameter set. | §3.1 | Add the citation to the `/authorize` description (125-128). |
| The TLS 1.3 reference moved from RFC 8446 to RFC 9846. | §1.5, §7.6, §12.1 | None (the YAML does not cite RFC 8446). |
| Resource servers "MUST refuse" a token not meant for them (was lowercase "must"). | §7.1.4 | None for AS paths. |
| Editorial: the loopback-port exception now points to §8.4.2; cross-references and typos fixed. | several | `RedirectUri` (716-730) still lacks the loopback exception (see H6). |
| Reference updates: attestation-based-client-auth -10 (was -07), rfc7523bis -11 (was -05), browser-based-apps -27 (was -26; still cited as a draft), new `client-id-metadata-document-02`, RFC 9112. | §12, Appendix F | None in the YAML. Repository: -16 vendored (done); `../rfc-validation/oauth-2.1-draft.md` still describes -13. |

### 5.3 The 14 OAuth 2.1 citations in the YAML

| YAML line | Cited | Status in -16 | Correct citation in -16 |
|---|---|---|---|
| 123 | §7.5.1.1 (OIDC-nonce exception to mandatory PKCE) | still correct | §7.5.1.1 |
| 171 | §7.5.3 / RFC 9700 §4.12: prefer 303, prohibit 307 | **renumbered** | §7.5.4 (with RFC 9700 §4.12) |
| 183 | §7.5.3: 303 is RECOMMENDED | **renumbered** | §7.5.4 |
| 691 | §10.1 permits only `code` | still correct (loose) | §4.1.1 and §10.1 |
| 695 | OAuth 2.1 / RFC 9700 §2.1.2 (no front-channel access tokens) | still correct | §10.1; RFC 9700 §2.1.2 |
| 722 | §2.3.1 exact-string redirect matching | still correct | §2.3.1 (also §4.1.1) — but add the loopback exception (§8.4.2) |
| 768 | §4.1.1 / §7.5.1.1: reject requests without `code_challenge` | still correct | §4.1.2.1 (the reject rule), §4.1.1, §7.5.1.1 |
| 785 | §4.1.1: method OPTIONAL, defaults to `plain`; S256 mandatory to implement | **content changed** | §4.1.1 (REQUIRED; only S256) and §7.5.2 (`plain` prohibited) |
| 1237 | §10.2: no `redirect_uri` at the token endpoint | still correct | §10.2 |
| 1256 | `redirect_uri` OPTIONAL under §10.2 | still correct | §10.2 (RFC 6749 required it only when sent at `/authorize`) |
| 1286 | §4.3.1: public-client refresh tokens sender-constrained or rotated | still correct (wording) | §4.3.1; the "RECOMMENDED for confidential clients" clause is in neither source, and OAuth 2.1 names DPoP **or** mTLS |
| 1436 | §4.3.1 (same rule) | still correct (wording) | §4.3.1 (same fix as line 1286) |
| 2183 | S256 mandatory to implement (§4.1.1) | **content changed** | §4.1.1 (S256 is the only method) and §7.5.2 |
| 2304 | §5.1: no tokens in a URI query | still correct | §5.1 |

Two citations were renumbered (171, 183) and two have changed content (785,
2183).

### 5.4 What remains to change in the YAML

1. Rewrite `CodeChallengeMethod` (780-795) for -16; drop `default: S256` in
   `PARRequest` (1615); update `code_challenge_methods_supported` (2176-2185).
   This is high finding H1.
2. Make `iss` REQUIRED in the 302 and 303 descriptions (160-189); add `iss` to
   `ErrorResponse`; state that an OAuth 2.1 AS publishes
   `authorization_response_iss_parameter_supported: true`. High finding H2.
3. Fix the citations: §7.5.3 → §7.5.4 at lines 171 and 183, and sharpen the
   imprecise ones at lines 691, 768, 1256, 1286, 1436 and 2183 (§5.3).
4. `/authorize` 400 (196-205): cite §4.1.2.1; validate `client_id` and
   `redirect_uri` before any error redirect; never 401.
5. `RedirectUri` (716-730): add the loopback-port exception and §8.4.2 (high
   findings H6 and H7).
6. Add §1.7.1 notes (no fixed maximum length) to `ClientId` (708-714), `State`
   (750-758), `code` (1249-1251) and the token fields (1411-1439).
7. Client secrets: OAuth 2.1 §2.4.1 says the AS MUST support
   `client_secret_post` and makes HTTP Basic only MAY. The YAML still calls the
   body form "NOT RECOMMENDED" (`ClientAuthFields.client_secret`, 1185-1190)
   and Basic "PREFERRED" (`securitySchemes.clientSecretBasic`, 2662-2674).
8. Add the rfc7523bis audience rule that OAuth 2.1 §2.4 requires (high finding
   H3).
9. Pin the draft revision in the YAML's info table (line 43 says only
   "ongoing") and in the README; then regenerate `oauth-openapi-modular/`
   (split script and bundle) so that the modular view carries the same edits.

---

## 6. Spec coverage by document

### 6.1 Summary

*Relevance* says how much an OAuth 2.1 authorization server needs the
document. *YAML coverage* says how much of its AS-relevant surface the YAML
models. Both are defined in [§13.2](#132-glossary).

| Relevance to an AS | Documents | mostly | partial | referenced-only | none | not-applicable |
|---|---|---|---|---|---|---|
| required (2.1) | 10 | 6 | 2 | 0 | 2 | 0 |
| recommended | 35 | 18 | 10 | 4 | 3 | 0 |
| optional | 20 | 3 | 4 | 5 | 7 | 1 |
| informational | 8 | 2 | 1 | 1 | 2 | 2 |
| **In scope** | **73** | **29** | **17** | **10** | **14** | **3** |

### 6.2 In-scope documents (73)

"(was X)" marks a level that the verifier corrected. Document links point to
the local text when the document is vendored.

| Document | Year | Relevance to an AS | YAML coverage | High | Medium | Low | Findings |
|---|---|---|---|---|---|---|---|
| **Core framework** | | | | | | | |
| [RFC 6749](../rfc-sources/rfc6749.txt) The OAuth 2.0 Authorization Framework | 2012 | required (2.1) | mostly | 1 | 11 | 28 | [core-6749](rfc-coverage-findings/core-6749.md#rfc-6749-the-oauth-20-authorization-framework) |
| **OAuth 2.1** | | | | | | | |
| [draft-ietf-oauth-v2-1-16](../rfc-sources/draft-ietf-oauth-v2-1.txt) The OAuth 2.1 Authorization Framework | 2026 | required (2.1) | mostly | 3 | 8 | 36 | [oauth21](rfc-coverage-findings/oauth21.md#draft-ietf-oauth-v2-1-16-the-oauth-21-authorization-framework) |
| **Token usage and HTTP authentication** | | | | | | | |
| [RFC 6750](../rfc-sources/rfc6750.txt) The OAuth 2.0 Authorization Framework: Bearer Token Usage | 2012 | required (2.1) | mostly | 0 | 3 | 10 | [bearer-http](rfc-coverage-findings/bearer-http.md#rfc-6750-the-oauth-20-authorization-framework-bearer-token-usage) |
| [RFC 9470](../rfc-sources/rfc9470.txt) OAuth 2.0 Step Up Authentication Challenge Protocol | 2023 | optional | mostly | 0 | 1 | 5 | [resource-rar-stepup](rfc-coverage-findings/resource-rar-stepup.md#rfc-9470-oauth-20-step-up-authentication-challenge-protocol) |
| **PKCE and application BCPs** | | | | | | | |
| [RFC 7636](../rfc-sources/rfc7636.txt) Proof Key for Code Exchange by OAuth Public Clients | 2015 | required (2.1) | mostly | 0 | 4 | 10 | [pkce-apps](rfc-coverage-findings/pkce-apps.md#rfc-7636-proof-key-for-code-exchange-by-oauth-public-clients) |
| [RFC 8252](../rfc-sources/rfc8252.txt) OAuth 2.0 for Native Apps | 2017 | required (2.1) | partial | 1 | 1 | 6 | [pkce-apps](rfc-coverage-findings/pkce-apps.md#rfc-8252-oauth-20-for-native-apps) |
| [RFC 10017](../rfc-sources/rfc10017.txt) OAuth 2.0 for Browser-Based Applications | 2026 | recommended | partial | 2 | 2 | 4 | [pkce-apps](rfc-coverage-findings/pkce-apps.md#rfc-10017-oauth-20-for-browser-based-applications) |
| **Security guidance** | | | | | | | |
| [RFC 6819](../rfc-sources/rfc6819.txt) OAuth 2.0 Threat Model and Security Considerations | 2013 | recommended | mostly | 0 | 3 | 6 | [security](rfc-coverage-findings/security.md#rfc-6819-oauth-20-threat-model-and-security-considerations) |
| [RFC 9700](../rfc-sources/rfc9700.txt) Best Current Practice for OAuth 2.0 Security | 2025 | required (2.1) | partial (was mostly) | 4 | 8 | 11 | [security](rfc-coverage-findings/security.md#rfc-9700-best-current-practice-for-oauth-20-security) |
| [draft-ietf-oauth-security-topics-update-03](https://datatracker.ietf.org/doc/draft-ietf-oauth-security-topics-update/) Updates to OAuth 2.0 Security Best Current Practice | 2026 | recommended | none | 0 | 1 | 3 | [security](rfc-coverage-findings/security.md#draft-ietf-oauth-security-topics-update-03-updates-to-oauth-20-security-best-current-practice) |
| [RFC 9207](../rfc-sources/rfc9207.txt) OAuth 2.0 Authorization Server Issuer Identification | 2022 | required (2.1) | mostly | 0 | 2 | 4 | [jar-par-iss](rfc-coverage-findings/jar-par-iss.md#rfc-9207-oauth-20-authorization-server-issuer-identification) |
| [RFC 8725](../rfc-sources/rfc8725.txt) JSON Web Token Best Current Practices | 2020 | recommended | partial | 0 | 4 | 8 | [jwt](rfc-coverage-findings/jwt.md#rfc-8725-json-web-token-best-current-practices) |
| [draft-ietf-oauth-rfc8725bis-10](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc8725bis/) JSON Web Token Best Current Practices | 2026 | recommended | partial | 0 | 4 | 6 | [jwt](rfc-coverage-findings/jwt.md#draft-ietf-oauth-rfc8725bis-10-json-web-token-best-current-practices-draft-ietf-oauth-rfc8725bis) |
| **Client registration** | | | | | | | |
| [RFC 7591](../rfc-sources/rfc7591.txt) OAuth 2.0 Dynamic Client Registration Protocol | 2015 | recommended | referenced-only | 4 | 7 | 9 | [dcr](rfc-coverage-findings/dcr.md#rfc-7591-oauth-20-dynamic-client-registration-protocol) |
| [RFC 7592](../rfc-sources/rfc7592.txt) OAuth 2.0 Dynamic Client Registration Management Protocol | 2015 | optional | none | 0 | 5 | 3 | [dcr](rfc-coverage-findings/dcr.md#rfc-7592-oauth-20-dynamic-client-registration-management-protocol) |
| [OpenID Connect Dynamic Client Registration 1.0](../oidf-sources/openid-connect-registration-1_0.html) | 2014 | recommended | referenced-only | 2 | 7 | 7 | [dcr](rfc-coverage-findings/dcr.md#oidc-dynamic-client-registration-10-openid-connect-dynamic-client-registration-10-incorporating-errata-set-2) |
| **Metadata and discovery** | | | | | | | |
| [RFC 8414](../rfc-sources/rfc8414.txt) OAuth 2.0 Authorization Server Metadata | 2018 | recommended | mostly | 0 | 4 | 14 | [metadata](rfc-coverage-findings/metadata.md#rfc8414-oauth-20-authorization-server-metadata) |
| [RFC 9728](../rfc-sources/rfc9728.txt) OAuth 2.0 Protected Resource Metadata | 2025 | recommended | mostly | 0 | 1 | 11 | [metadata](rfc-coverage-findings/metadata.md#rfc9728-oauth-20-protected-resource-metadata) |
| **Request objects (JAR, PAR)** | | | | | | | |
| [RFC 9101](../rfc-sources/rfc9101.txt) JWT-Secured Authorization Request (JAR) | 2021 | optional | partial | 0 | 5 | 5 | [jar-par-iss](rfc-coverage-findings/jar-par-iss.md#rfc-9101-the-oauth-20-authorization-framework-jwt-secured-authorization-request-jar) |
| [RFC 9126](../rfc-sources/rfc9126.txt) OAuth 2.0 Pushed Authorization Requests | 2021 | recommended | mostly | 1 | 7 | 12 | [jar-par-iss](rfc-coverage-findings/jar-par-iss.md#rfc-9126-oauth-20-pushed-authorization-requests) |
| **Assertion grants and client assertions** | | | | | | | |
| [RFC 7521](../rfc-sources/rfc7521.txt) Assertion Framework for OAuth 2.0 Client Authentication and Authorization Grants | 2015 | recommended | mostly | 0 | 3 | 7 | [assertions](rfc-coverage-findings/assertions.md#rfc-7521-assertion-framework-for-oauth-20-client-authentication-and-authorization-grants) |
| [RFC 7522](../rfc-sources/rfc7522.txt) SAML 2.0 Profile for OAuth 2.0 Client Authentication and Authorization Grants | 2015 | optional | none | 0 | 1 | 1 | [assertions](rfc-coverage-findings/assertions.md#rfc-7522-security-assertion-markup-language-saml-20-profile-for-oauth-20-client-authentication-and-authorization-grants) |
| [RFC 7523](../rfc-sources/rfc7523.txt) JWT Profile for OAuth 2.0 Client Authentication and Authorization Grants | 2015 | recommended | mostly | 1 | 4 | 8 | [assertions](rfc-coverage-findings/assertions.md#rfc-7523-json-web-token-jwt-profile-for-oauth-20-client-authentication-and-authorization-grants) |
| [draft-ietf-oauth-rfc7523bis-11](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc7523bis/) Updates to OAuth 2.0 JWT Client Authentication and Assertion-Based Authorization Grants | 2026 | required (2.1) | none | 1 | 1 | 3 | [assertions](rfc-coverage-findings/assertions.md#draft-ietf-oauth-rfc7523bis-11-updates-to-oauth-20-json-web-token-jwt-client-authentication-and-assertion-based-authorization-grants) |
| **Token lifecycle (revocation, introspection, status)** | | | | | | | |
| [RFC 7009](../rfc-sources/rfc7009.txt) OAuth 2.0 Token Revocation | 2013 | recommended | mostly | 0 | 3 | 6 | [revocation-introspection](rfc-coverage-findings/revocation-introspection.md#rfc-7009-oauth-20-token-revocation) |
| [RFC 7662](../rfc-sources/rfc7662.txt) OAuth 2.0 Token Introspection | 2015 | recommended | mostly | 0 | 7 | 7 | [revocation-introspection](rfc-coverage-findings/revocation-introspection.md#rfc-7662-oauth-20-token-introspection) |
| [RFC 9701](../rfc-sources/rfc9701.txt) JWT Response for OAuth Token Introspection | 2025 | optional | partial | 0 | 6 | 6 | [revocation-introspection](rfc-coverage-findings/revocation-introspection.md#rfc-9701-json-web-token-jwt-response-for-oauth-token-introspection) |
| [draft-ietf-oauth-status-list-21](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/) Token Status List (TSL) | 2026 | optional | none | 0 | 0 | 6 | [jwt-at-sdjwt](rfc-coverage-findings/jwt-at-sdjwt.md#draft-ietf-oauth-status-list-21-token-status-list-tsl) |
| **Token formats** | | | | | | | |
| [RFC 7519](../rfc-sources/rfc7519.txt) JSON Web Token (JWT) | 2015 | recommended | mostly | 0 | 3 | 7 | [jwt](rfc-coverage-findings/jwt.md#rfc-7519-json-web-token-jwt) |
| [RFC 9068](../rfc-sources/rfc9068.txt) JWT Profile for OAuth 2.0 Access Tokens | 2021 | recommended | partial (was mostly) | 1 | 4 | 9 | [jwt-at-sdjwt](rfc-coverage-findings/jwt-at-sdjwt.md#rfc-9068-json-web-token-jwt-profile-for-oauth-20-access-tokens) |
| [RFC 9901](../rfc-sources/rfc9901.txt) Selective Disclosure for JSON Web Tokens (SD-JWT) | 2025 | optional | not-applicable | 0 | 0 | 3 | [jwt-at-sdjwt](rfc-coverage-findings/jwt-at-sdjwt.md#rfc-9901-selective-disclosure-for-json-web-tokens-sd-jwt) |
| [draft-ietf-oauth-sd-jwt-vc-19](https://datatracker.ietf.org/doc/draft-ietf-oauth-sd-jwt-vc/) SD-JWT-based Verifiable Digital Credentials (SD-JWT VC) | 2026 | optional | none | 0 | 0 | 4 | [jwt-at-sdjwt](rfc-coverage-findings/jwt-at-sdjwt.md#draft-ietf-oauth-sd-jwt-vc-19-sd-jwt-based-verifiable-digital-credentials-sd-jwt-vc) |
| **Sender-constrained tokens** | | | | | | | |
| [RFC 8705](../rfc-sources/rfc8705.txt) Mutual-TLS Client Authentication and Certificate-Bound Access Tokens | 2020 | recommended | mostly | 1 | 3 | 7 | [pop](rfc-coverage-findings/pop.md#rfc-8705-oauth-20-mutual-tls-client-authentication-and-certificate-bound-access-tokens) |
| [RFC 9449](../rfc-sources/rfc9449.txt) OAuth 2.0 Demonstrating Proof of Possession (DPoP) | 2023 | recommended | mostly | 1 | 5 | 14 | [pop](rfc-coverage-findings/pop.md#rfc-9449-oauth-20-demonstrating-proof-of-possession-dpop) |
| [RFC 7800](../rfc-sources/rfc7800.txt) Proof-of-Possession Key Semantics for JWTs | 2016 | recommended | partial (was mostly) | 0 | 0 | 6 | [pop](rfc-coverage-findings/pop.md#rfc-7800-proof-of-possession-key-semantics-for-json-web-tokens-jwts) |
| **Resource indicators and authorization details** | | | | | | | |
| [RFC 8707](../rfc-sources/rfc8707.txt) Resource Indicators for OAuth 2.0 | 2020 | recommended | mostly | 0 | 1 | 6 | [resource-rar-stepup](rfc-coverage-findings/resource-rar-stepup.md#rfc-8707-resource-indicators-for-oauth-20) |
| [RFC 9396](../rfc-sources/rfc9396.txt) OAuth 2.0 Rich Authorization Requests | 2023 | optional | mostly | 0 | 5 | 11 | [resource-rar-stepup](rfc-coverage-findings/resource-rar-stepup.md#rfc-9396-oauth-20-rich-authorization-requests) |
| **Token exchange** | | | | | | | |
| [RFC 8693](../rfc-sources/rfc8693.txt) OAuth 2.0 Token Exchange | 2020 | recommended | mostly | 0 | 4 | 13 | [token-exchange](rfc-coverage-findings/token-exchange.md#rfc-8693-oauth-20-token-exchange) |
| **Device and cross-device flows** | | | | | | | |
| [RFC 8628](../rfc-sources/rfc8628.txt) OAuth 2.0 Device Authorization Grant | 2019 | recommended | mostly | 0 | 4 | 17 | [device-crossdevice](rfc-coverage-findings/device-crossdevice.md#rfc-8628-oauth-20-device-authorization-grant) |
| [RFC 10027](../rfc-sources/rfc10027.txt) Best Current Practice for Security of Cross-Device Flows | 2026 | recommended | none | 0 | 2 | 7 | [device-crossdevice](rfc-coverage-findings/device-crossdevice.md#rfc-10027-best-current-practice-for-security-of-cross-device-flows) |
| **JOSE** | | | | | | | |
| [RFC 7515](../rfc-sources/rfc7515.txt) JSON Web Signature (JWS) | 2015 | recommended | partial | 0 | 2 | 5 | [jose](rfc-coverage-findings/jose.md#rfc7515-json-web-signature-jws) |
| [RFC 7516](../rfc-sources/rfc7516.txt) JSON Web Encryption (JWE) | 2015 | optional | partial | 0 | 1 | 4 | [jose](rfc-coverage-findings/jose.md#rfc7516-json-web-encryption-jwe) |
| [RFC 7517](../rfc-sources/rfc7517.txt) JSON Web Key (JWK) | 2015 | recommended | mostly | 1 | 2 | 10 | [jose](rfc-coverage-findings/jose.md#rfc7517-json-web-key-jwk) |
| [RFC 7518](../rfc-sources/rfc7518.txt) JSON Web Algorithms (JWA) | 2015 | recommended | partial | 1 | 4 | 4 | [jose](rfc-coverage-findings/jose.md#rfc7518-json-web-algorithms-jwa) |
| [RFC 7638](../rfc-sources/rfc7638.txt) JSON Web Key (JWK) Thumbprint | 2015 | recommended | partial (was mostly) | 0 | 0 | 2 | [jose](rfc-coverage-findings/jose.md#rfc7638-json-web-key-jwk-thumbprint) |
| [RFC 7797](../rfc-sources/rfc7797.txt) JWS Unencoded Payload Option | 2016 | informational | none (was not-applicable) | 0 | 0 | 1 | [jwt](rfc-coverage-findings/jwt.md#rfc-7797-json-web-signature-jws-unencoded-payload-option) |
| [RFC 8037](../rfc-sources/rfc8037.txt) CFRG ECDH and Signatures in JOSE | 2017 | optional | mostly | 0 | 0 | 1 | [jose](rfc-coverage-findings/jose.md#rfc8037-cfrg-elliptic-curve-diffie-hellman-ecdh-and-signatures-in-json-object-signing-and-encryption-jose) |
| [RFC 9864](../rfc-sources/rfc9864.txt) Fully-Specified Algorithms for JOSE and COSE | 2025 | recommended | none | 0 | 0 | 3 | [jose](rfc-coverage-findings/jose.md#rfc9864-fully-specified-algorithms-for-json-object-signing-and-encryption-jose-and-cbor-object-signing-and-encryption-cose) |
| [RFC 9278](../rfc-sources/rfc9278.txt) JWK Thumbprint URI | 2022 | informational | none | 0 | 0 | 1 | [pop](rfc-coverage-findings/pop.md#rfc-9278-jwk-thumbprint-uri) |
| [RFC 9964](https://www.rfc-editor.org/rfc/rfc9964.html) ML-DSA for JOSE and COSE | 2026 | optional | none | 0 | 0 | 2 | [jose](rfc-coverage-findings/jose.md#rfc9964-ml-dsa-for-json-object-signing-and-encryption-jose-and-cbor-object-signing-and-encryption-cose) |
| [RFC 8812](https://www.rfc-editor.org/rfc/rfc8812.html) COSE and JOSE Registrations for WebAuthn Algorithms | 2020 | optional | partial | 0 | 0 | 1 | [jose](rfc-coverage-findings/jose.md#rfc8812-cbor-object-signing-and-encryption-cose-and-json-object-signing-and-encryption-jose-registrations-for-web-authentication-webauthn-algorithms) |
| [RFC 7520](https://www.rfc-editor.org/rfc/rfc7520.html) Examples of Protecting Content Using JOSE | 2015 | informational | not-applicable | 0 | 0 | 1 | [jose](rfc-coverage-findings/jose.md#rfc7520-examples-of-protecting-content-using-json-object-signing-and-encryption-jose) |
| **OpenID Connect and other OIDF specs** | | | | | | | |
| [OpenID Connect Core 1.0](../oidf-sources/oidc-core-1.0.html) | 2014 | recommended | mostly | 3 | 10 | 21 | [oidc](rfc-coverage-findings/oidc.md#oidc-core-10-openid-connect-core-10-incorporating-errata-set-2) |
| [OpenID Connect Discovery 1.0](../oidf-sources/oidc-discovery-1.0.html) | 2014 | recommended | mostly | 0 | 3 | 10 | [oidc](rfc-coverage-findings/oidc.md#oidc-discovery-10-openid-connect-discovery-10-incorporating-errata-set-2) |
| [OAuth 2.0 Form Post Response Mode](../oidf-sources/oauth-v2-form-post-response-mode-1_0.html) | 2015 | recommended | partial | 0 | 1 | 2 | [oidc](rfc-coverage-findings/oidc.md#oauth-v2-form-post-response-mode-10-oauth-20-form-post-response-mode) |
| [OAuth 2.0 Multiple Response Type Encoding Practices](../oidf-sources/oauth-v2-multiple-response-types-1_0.html) | 2014 | recommended | partial | 1 | 1 | 4 | [oidc](rfc-coverage-findings/oidc.md#oauth-v2-multiple-response-types-10-oauth-20-multiple-response-type-encoding-practices) |
| [JARM, 2018 FAPI Draft-02](../oidf-sources/openid-financial-api-jarm.html) | 2018 | informational | referenced-only (was partial) | 0 | 3 | 1 | [oidc](rfc-coverage-findings/oidc.md#openid-financial-api-jarm-draft-02-financial-grade-api-jwt-secured-authorization-response-mode-for-oauth-20-jarm-draft-02) |
| [JARM Final (2022, errata set 1 2025)](../oidf-sources/oauth-v2-jarm.html) | 2022 | optional | referenced-only (was partial) | 0 | 4 | 4 | [oidc](rfc-coverage-findings/oidc.md#oauth-v2-jarm-final-jwt-secured-authorization-response-mode-for-oauth-20-jarm) |
| [OpenID Connect Session Management 1.0](../oidf-sources/openid-connect-session-1_0.html) | 2022 | optional | referenced-only | 0 | 1 | 3 | [oidc](rfc-coverage-findings/oidc.md#oidc-session-10-openid-connect-session-management-10) |
| [OpenID Connect Front-Channel Logout 1.0](../oidf-sources/openid-connect-frontchannel-1_0.html) | 2022 | optional | referenced-only (was partial) | 0 | 1 | 5 | [oidc](rfc-coverage-findings/oidc.md#oidc-frontchannel-logout-10-openid-connect-front-channel-logout-10) |
| [OpenID Connect Back-Channel Logout 1.0](../oidf-sources/openid-connect-backchannel-1_0.html) | 2022 | recommended | referenced-only (was partial) | 0 | 2 | 4 | [oidc](rfc-coverage-findings/oidc.md#oidc-backchannel-logout-10-openid-connect-back-channel-logout-10-incorporating-errata-set-1) |
| [OpenID Connect RP-Initiated Logout 1.0](../oidf-sources/openid-connect-rpinitiated-1_0.html) | 2022 | recommended | referenced-only | 0 | 1 | 2 | [oidc](rfc-coverage-findings/oidc.md#oidc-rpinitiated-logout-10-openid-connect-rp-initiated-logout-10) |
| [OpenID Connect CIBA Core 1.0](../oidf-sources/openid-client-initiated-backchannel-authentication-core-1_0.html) | 2021 | optional | referenced-only | 0 | 3 | 5 | [oidc](rfc-coverage-findings/oidc.md#oidc-ciba-core-10-openid-connect-client-initiated-backchannel-authentication-flow---core-10) |
| [RFC 8176](../rfc-sources/rfc8176.txt) Authentication Method Reference Values | 2017 | optional | referenced-only | 0 | 0 | 2 | [token-exchange](rfc-coverage-findings/token-exchange.md#rfc-8176-authentication-method-reference-values) |
| **Infrastructure (URI, HTTP, TLS)** | | | | | | | |
| [RFC 8996](../rfc-sources/rfc8996.txt) Deprecating TLS 1.0 and TLS 1.1 | 2021 | required (2.1) | none | 0 | 0 | 2 | [bearer-http](rfc-coverage-findings/bearer-http.md#rfc-8996-deprecating-tls-10-and-tls-11) |
| [RFC 9110](../rfc-sources/rfc9110.txt) HTTP Semantics | 2022 | required (2.1) | mostly | 0 | 1 | 7 | [bearer-http](rfc-coverage-findings/bearer-http.md#rfc-9110-http-semantics) |
| [RFC 7617](../rfc-sources/rfc7617.txt) The 'Basic' HTTP Authentication Scheme | 2015 | recommended | mostly | 0 | 2 | 4 | [bearer-http](rfc-coverage-findings/bearer-http.md#rfc-7617-the-basic-http-authentication-scheme) |
| [RFC 6755](../rfc-sources/rfc6755.txt) An IETF URN Sub-Namespace for OAuth | 2012 | informational | mostly | 0 | 0 | 3 | [metadata](rfc-coverage-findings/metadata.md#rfc6755-an-ietf-urn-sub-namespace-for-oauth) |
| [RFC 8615](https://www.rfc-editor.org/rfc/rfc8615.html) Well-Known Uniform Resource Identifiers (URIs) | 2019 | informational | mostly | 0 | 0 | 5 | [metadata](rfc-coverage-findings/metadata.md#rfc8615-well-known-uniform-resource-identifiers-uris) |
| [RFC 3986](../rfc-sources/rfc3986.txt) Uniform Resource Identifier (URI): Generic Syntax | 2005 | informational | partial (was referenced-only) | 0 | 0 | 4 | [metadata](rfc-coverage-findings/metadata.md#rfc3986-uniform-resource-identifier-uri-generic-syntax) |
| [RFC 9440](https://www.rfc-editor.org/rfc/rfc9440.html) Client-Cert HTTP Header Field | 2023 | optional | none | 0 | 0 | 2 | [pop](rfc-coverage-findings/pop.md#rfc-9440-client-cert-http-header-field) |
| **Adjacent specifications** | | | | | | | |
| [RFC 8485](https://www.rfc-editor.org/rfc/rfc8485.html) Vectors of Trust | 2018 | optional | none | 0 | 0 | 3 | [token-exchange](rfc-coverage-findings/token-exchange.md#rfc-8485-vectors-of-trust) |
| [RFC 9421](https://www.rfc-editor.org/rfc/rfc9421.html) HTTP Message Signatures | 2024 | informational | not-applicable | 0 | 0 | 0 | [pop](rfc-coverage-findings/pop.md#rfc-9421-http-message-signatures) |

### 6.3 Out-of-scope catalogue clusters (34 documents)

Three clusters assessed documents that are catalogued but are not part of an
OAuth 2.1 AS: [oauth1-origin](rfc-coverage-findings/oauth1-origin.md),
[adjacent-families](rfc-coverage-findings/adjacent-families.md) and
[adjacent-ace](rfc-coverage-findings/adjacent-ace.md). They hold 0 high, 1
medium and 34 low findings. The one medium finding (in the RFC 8417 entry)
repeats the JWT-pattern defect described in [§7.3](#73-recurring-medium-patterns).

| Family | Documents | Tier | Cluster | YAML coverage | Low |
|---|---|---|---|---|---|
| OAuth 1.0 | [RFC 5849](../rfc-sources/rfc5849.txt) The OAuth 1.0 Protocol (vendored) | T2 | oauth1-origin | not-applicable | 0 |
| Security events | [RFC 8417](https://www.rfc-editor.org/rfc/rfc8417.html) Security Event Token; [RFC 8935](https://www.rfc-editor.org/rfc/rfc8935.html) and [RFC 8936](https://www.rfc-editor.org/rfc/rfc8936.html) push and poll delivery; [RFC 9493](https://www.rfc-editor.org/rfc/rfc9493.html) subject identifiers | T5 | adjacent-families | none | 2 |
| SCIM | [RFC 9967](https://www.rfc-editor.org/rfc/rfc9967.html) SCIM profile for SETs | T6 | adjacent-families | none | 0 |
| SASL | [RFC 7628](https://www.rfc-editor.org/rfc/rfc7628.html) SASL mechanisms for OAuth | T5 | adjacent-families | not-applicable | 0 |
| GNAP | [RFC 9635](https://www.rfc-editor.org/rfc/rfc9635.html) GNAP; [RFC 9767](https://www.rfc-editor.org/rfc/rfc9767.html) GNAP resource server connections | T5 | adjacent-families | none | 0 |
| Token Binding | [RFC 8471](https://www.rfc-editor.org/rfc/rfc8471.html), [RFC 8472](https://www.rfc-editor.org/rfc/rfc8472.html), [RFC 8473](https://www.rfc-editor.org/rfc/rfc8473.html) | T5 | adjacent-families | not-applicable (8471, 8472); none (8473) | 1 |
| STUN and SIP | [RFC 7635](https://www.rfc-editor.org/rfc/rfc7635.html) STUN third-party authorization; [RFC 8898](https://www.rfc-editor.org/rfc/rfc8898.html) SIP third-party tokens | T5 | adjacent-families | none (7635); not-applicable (8898) | 1 |
| URI scheme | [RFC 8959](https://www.rfc-editor.org/rfc/rfc8959.html) the "secret-token" URI scheme | T7 | adjacent-families | none (was not-applicable) | 0 |
| RDAP | [RFC 9560](https://www.rfc-editor.org/rfc/rfc9560.html) federated authentication for RDAP using OIDC | T6 | adjacent-families | none (was partial) | 0 |
| Attestation | [RFC 9711](https://www.rfc-editor.org/rfc/rfc9711.html) Entity Attestation Token (EAT) | X | adjacent-families | none | 0 |
| Discovery | [RFC 7033](https://www.rfc-editor.org/rfc/rfc7033.html) WebFinger | T7 | adjacent-families | none | 1 |
| JOSE background | [RFC 7165](https://www.rfc-editor.org/rfc/rfc7165.html) JOSE use cases and requirements | T4 | adjacent-families | not-applicable | 0 |
| ACE framework and profiles | [RFC 8392](https://www.rfc-editor.org/rfc/rfc8392.html), [RFC 8747](https://www.rfc-editor.org/rfc/rfc8747.html), [RFC 9200](https://www.rfc-editor.org/rfc/rfc9200.html), [RFC 9201](https://www.rfc-editor.org/rfc/rfc9201.html), [RFC 9202](https://www.rfc-editor.org/rfc/rfc9202.html), [RFC 9203](https://www.rfc-editor.org/rfc/rfc9203.html), [RFC 9237](https://www.rfc-editor.org/rfc/rfc9237.html), [RFC 9430](https://www.rfc-editor.org/rfc/rfc9430.html), [RFC 9431](https://www.rfc-editor.org/rfc/rfc9431.html), [RFC 9594](https://www.rfc-editor.org/rfc/rfc9594.html), [RFC 9770](https://www.rfc-editor.org/rfc/rfc9770.html) (CWT, proof-of-possession for CWTs, ACE-OAuth, parameters, DTLS, OSCORE, AIF, TLS, MQTT, group keys, revocation) | T5 | adjacent-ace | none (7 documents); not-applicable (4) | 29 |
| ACE WG documents without OAuth content | [RFC 7744](https://www.rfc-editor.org/rfc/rfc7744.html), [RFC 9148](https://www.rfc-editor.org/rfc/rfc9148.html), [RFC 9482](https://www.rfc-editor.org/rfc/rfc9482.html), [RFC 9820](https://www.rfc-editor.org/rfc/rfc9820.html) | X | adjacent-ace | not-applicable | 0 |

---

## 7. Priority findings

### 7.1 High findings (29)

Every high finding is listed below, grouped by theme. "Rule" is the source
section; "YAML location" uses line numbers at commit `3e712d7`. Each finding
links to its cluster file, which has the full evidence. Six findings marked
*(re-checked by hand)* were also confirmed manually.

#### A. OAuth 2.1 draft-16 alignment (2)

| ID | Finding | Rule | YAML location | Fix |
|---|---|---|---|---|
| H1 | `code_challenge_method` is still described with the -15 rule, "OPTIONAL (defaulting to `plain`)", and is `required: false`. A server that follows the text accepts a request with no method and treats it as `plain` — the downgrade that -16 forbids. *(re-checked by hand)* [oauth21](rfc-coverage-findings/oauth21.md) | OAuth 2.1-16 §4.1.1, §4.1.2.1, §7.5.2, §10 | `components.parameters.CodeChallengeMethod`, lines 780-795 (`required: false` at 783); `PARRequest.code_challenge_method` `default: S256`, line 1615 | Rewrite: REQUIRED on a plain authorization request; `S256` or a future extension value; `plain` is removed and prohibited; a missing or unsupported method gives `invalid_request`; never default to `plain`. Keep `enum: [S256]`; explain that `required: false` stays only because PAR or JAR can carry the value inside the request object. Delete `default: S256` in `PARRequest`. |
| H2 | `iss` is conditional: on success only "when the AS advertises `authorization_response_iss_parameter_supported`", on error "per RFC 9207". -16 makes it REQUIRED in both. *(re-checked by hand)* [oauth21](rfc-coverage-findings/oauth21.md) | OAuth 2.1-16 §4.1.2, §4.1.2.1, §7.15.1; RFC 9207 §2, §2.3 | `paths./authorize.get.responses.302`, lines 160-172 (`iss` at 164-165 and 168-169); `303`, lines 182-189 | Success: `code`, `state` (if sent), and `iss` (REQUIRED). Error: `error`, optional `error_description` and `error_uri`, `state` (if sent), and `iss` (REQUIRED). `iss` equals the metadata `issuer` exactly. Mirror on 303. Related medium fixes: publish `authorization_response_iss_parameter_supported: true` (2206-2211); add `iss` to `ErrorResponse`. |

#### B. Client authentication and assertions (3)

| ID | Finding | Rule | YAML location | Fix |
|---|---|---|---|---|
| H3 | No audience rule for JWT client authentication. OAuth 2.1 §2.4 says clients and servers MUST follow rfc7523bis: `aud` is the AS issuer identifier as the only value. The YAML even says a jwt-bearer assertion's `aud` is "the AS token endpoint URL" — the pattern behind the audience-injection attack. [oauth21](rfc-coverage-findings/oauth21.md) | OAuth 2.1-16 §2.4, §2.4.2; `draft-ietf-oauth-rfc7523bis-11` §4 (item 3b) and the §3.2 addition | `ClientAuthFields.client_assertion`, lines 1191-1196; `JWTBearerTokenRequest.assertion`, lines 1341-1345 | Add to `client_assertion`: `aud` MUST be the issuer identifier (metadata `issuer`) as a single value; the token endpoint URL MUST NOT be used; the AS rejects any other value (simple string comparison); `iss` = `sub` = the client ID; `exp` REQUIRED; send `typ: client-authentication+jwt` (SHOULD), but do not reject untyped JWTs. For the grant assertion, write "issuer identifier or token endpoint URL". |
| H4 | The same issuer-only audience applies at every endpoint that accepts client assertions, including `/par`. rfc7523bis §5 replaces the RFC 9126 §2 rule that accepted the issuer, the token endpoint URL or the PAR endpoint URL. [assertions](rfc-coverage-findings/assertions.md) | rfc7523bis-11 §4, §5, §6 | `ClientAuthFields` 1191-1196; `/par` description 427-437; `PARRequest` 1583-1589; `OAuthServerMetadata.issuer` 1947-1950 | State the rule at `/par` and in `PARRequest`; add to `issuer`: "also the only accepted `aud` of JWT client assertions". Migration (rfc7523bis §6): update clients before, or together with, server enforcement. |
| H5 | `JWTBearerTokenRequest` cannot carry client authentication: its `allOf` holds only `ResourceIndicators`, while all 9 other request schemas include `ClientAuthFields`. *(re-checked by hand)* [assertions](rfc-coverage-findings/assertions.md) | RFC 7523 §2.1, §3.1; RFC 7521 §4.1, §4.2; RFC 6749 §3.2.1 | `components.schemas.JWTBearerTokenRequest`, lines 1326-1347 (`allOf` at 1330-1331) | Add `ClientAuthFields` to the `allOf`. Replace "the JWT itself authenticates the client in most uses": the grant assertion identifies the subject, and client authentication is a separate step. Identity chaining and the Identity Assertion JWT Authorization Grant (ID-JAG) draft ([§9](#9-draft-pipeline-and-watch-list)) need this. |

#### C. Redirect URIs and PKCE (4)

| ID | Finding | Rule | YAML location | Fix |
|---|---|---|---|---|
| H6 | Redirect URI matching is "exact-string" with no exception. Both sources the YAML cites (OAuth 2.1 §2.3.1, RFC 9700 §4.1.3) allow any port for loopback redirect URIs, so a server that follows the text rejects native apps that use an ephemeral port. *(re-checked by hand)* [core-6749](rfc-coverage-findings/core-6749.md) | RFC 6749 §3.1.2.3 as updated by RFC 8252 §7.3, §8.4 and RFC 9700 §2.1, §4.1.3; OAuth 2.1-16 §2.3.1, §8.4.2 | `components.parameters.RedirectUri`, lines 720-727 | Reword: simple string comparison (RFC 3986 §6.2.1), except that for loopback IP redirect URIs the port is ignored and any port MUST be accepted; prefer `127.0.0.1` or `[::1]` to `localhost` (RFC 8252 §8.3). |
| H7 | The same defect, found from RFC 8252; it also affects the `/authorize` 400 description. [pkce-apps](rfc-coverage-findings/pkce-apps.md) | RFC 8252 §7.3, §8.4; OAuth 2.1-16 §2.3.1, §4.1.1, §8.4.2; RFC 9700 §2.1, §4.1.3 | `RedirectUri` 720-727; `/authorize` 400, lines 197-201; modular copy `spec/components/parameters.yaml:36` | Same rewording in all places. Apply the exception only to `http` loopback-IP URIs of native (public) clients, and decide explicitly about `http://localhost` (RFC 8252 §8.3: NOT RECOMMENDED). |
| H8 | Nothing forbids `http` redirect URIs. [security](rfc-coverage-findings/security.md) | RFC 9700 §2.6 (with RFC 8252 §7.3; OAuth 2.1-16 §1.5) | `RedirectUri` 716-730; `PARRequest.redirect_uri` 1600-1602; `AuthorizationCodeTokenRequest.redirect_uri` 1252 | Add: absolute URI without a fragment; the AS MUST reject `http` except native loopback URIs (`http://127.0.0.1:{port}/…`, `http://[::1]:{port}/…`); `https` and reverse-DNS private-use schemes are allowed. Optionally add a schema `pattern`. |
| H9 | The PKCE downgrade check at the token endpoint is not stated: accept a `code_verifier` only if the authorization request had a `code_challenge`. [security](rfc-coverage-findings/security.md) | RFC 9700 §2.1.1, §4.8.1, §4.8.2; OAuth 2.1-16 §4.1.3 | `AuthorizationCodeTokenRequest.code_verifier` (required at line 1244); the nonce exception at 120-123 and 768-771 | Add to `code_verifier`: present if and only if a `code_challenge` was sent; a verifier for a code issued without a challenge gives `invalid_request`; a missing or wrong verifier gives `invalid_grant` (RFC 7636 §4.6). Better: make PKCE mandatory for every client; then the check is implicit (RFC 9700 §4.8.2). |

#### D. PAR and JAR (1)

| ID | Finding | Rule | YAML location | Fix |
|---|---|---|---|---|
| H10 | `PARRequest` requires `response_type`, `code_challenge` and `code_challenge_method` in the form body. When a client pushes a JAR request object, RFC 9126 §3 puts all authorization parameters inside the `request` JWT, so a valid request fails the schema. *(re-checked by hand)* [jar-par-iss](rfc-coverage-findings/jar-par-iss.md) | RFC 9126 §3, §2.1 | `components.schemas.PARRequest`, lines 1583-1647 (required list at 1594) | Keep `required: [client_id]`. Add a JSON Schema 2020-12 conditional: if `request` is present, the other authorization parameters must not appear in the body; otherwise require `response_type`, `code_challenge` and `code_challenge_method`. Or split the schema into a `oneOf` of two schemas. |

#### E. JOSE and JWT safety (3)

| ID | Finding | Rule | YAML location | Fix |
|---|---|---|---|---|
| H11 | The public JWK Set schema allows the symmetric key member `k` (with an `HS256` example and `additionalProperties: true`), and `GET /jwks` serves it without authentication. [jose](rfc-coverage-findings/jose.md) | RFC 7517 §9.2, §7; RFC 7518 §6.4; OIDC Discovery §3 (`jwks_uri`) | `components.schemas.JWK.properties.k`, lines 1899-1902; `JWK.alg` examples, line 1858; `additionalProperties: true`, line 1825; used by `JWKS.keys` (1817-1820) and `/jwks` (573-598) | Remove `k` from the published schema (keep a separate, unpublished `SymmetricJWK` if needed). Drop `HS256` from the examples. Wrap `JWKS.keys` items in a `PublicJWK` that forbids `d`, `p`, `q`, `dp`, `dq`, `qi`, `oth`, `k` and `priv`. Say "public keys only". |
| H12 | `none` and symmetric MAC (message authentication code) algorithms are not excluded from the algorithm metadata. Only line 2308 says `none` MUST NOT be used. [jose](rfc-coverage-findings/jose.md) | RFC 7518 §3.6, §8.5; RFC 8414 §2; RFC 9449 §4.2, §11.6; RFC 9068 §2.1; JARM §5; OIDC Discovery §3 | `*_endpoint_auth_signing_alg_values_supported`, lines 2050-2068; `dpop_signing_alg_values_supported`, lines 2188-2190 and 2326-2328 | Client-authentication, introspection and JARM arrays: `items: {not: {const: none}}`. DPoP arrays: exclude `none` and `HS256`/`HS384`/`HS512`. ID Tokens from the authorization endpoint MUST NOT use `none`. JWT access tokens MUST NOT use `none`, and RS256 MUST be supported (RFC 9068 §2.1). |
| H13 | The YAML does not say how a resource server validates a JWT access token: `typ`, decryption, `iss`, `aud`, signature and `alg`, `exp`, and the `invalid_token` error. [jwt-at-sdjwt](rfc-coverage-findings/jwt-at-sdjwt.md) | RFC 9068 §4, §5 | `securitySchemes.bearerAuth`, lines 2640-2646; `/introspect` description, 323-324; `/userinfo`, 486-490 | Add the six RFC 9068 §4 checks to `bearerAuth` as a numbered list, ending with "on failure: 401 with `WWW-Authenticate: Bearer error="invalid_token"`". At `/userinfo`, require `typ` `at+jwt`, so an ID Token is never accepted as an access token. |

#### F. Dynamic Client Registration is missing (6)

All six are in [dcr](rfc-coverage-findings/dcr.md). `registration_endpoint` is
advertised (lines 1965-1968) but nothing behind it is modeled.

| ID | Finding | Rule | YAML location | Fix |
|---|---|---|---|---|
| H14 | No client registration endpoint (`POST /register`). | RFC 7591 §3, §3.1, §3.2 | `paths` (lines 104-675) | Add a "Client Registration" tag and `paths./register.post`: JSON request body; `201` with `Cache-Control: no-store` and `Pragma: no-cache`; `400` registration error; `401` for a bad initial access token; `security: [{}, {initialAccessToken: []}]`. |
| H15 | No client metadata model. | RFC 7591 §2, §4.1.2 | — | Add `ClientMetadata` (`additionalProperties: true`): `redirect_uris` (no fragment), `token_endpoint_auth_method` (default `client_secret_basic`), `grant_types` (default `[authorization_code]`), `response_types` (default `[code]`), `client_name`, `client_uri`, `logo_uri`, `scope`, `contacts`, `tos_uri`, `policy_uri`, `jwks_uri`, `jwks` (public keys only), `software_id`, `software_version`. Under the OAuth 2.1 profile, reject implicit and password values with `invalid_client_metadata`. |
| H16 | No client information response. | RFC 7591 §3.2.1 | — | Add `ClientInformationResponse`: all registered metadata plus `client_id` (REQUIRED), `client_secret`, `client_id_issued_at` and `client_secret_expires_at` (REQUIRED when a secret is issued; `0` means it never expires). |
| H17 | The four registration error codes are missing: `invalid_redirect_uri`, `invalid_client_metadata`, `invalid_software_statement`, `unapproved_software_statement` (HTTP 400). | RFC 7591 §3.2.2 | `ErrorResponse.error` enum, lines 1477-1517 | Add the four codes (marked "registration endpoint only") and a `ClientRegistrationError` response. |
| H18 | OIDC registration rules are missing: the endpoint is an OAuth protected resource, SHOULD support CORS (Cross-Origin Resource Sharing), SHOULD accept requests without an access token, SHOULD answer `201 Created`, and MUST use `https`. | OIDC Registration §3, §3.1, §3.2; OIDC Core §15.2; OIDC Discovery §3 | `registration_endpoint`, lines 1965-1968 | Use the same `POST /register` and state these rules in its description; add `pattern: '^https://'` to `registration_endpoint`. |
| H19 | No `application_type` (`web` or `native`, default `web`), and no AS-side check that the registered redirect URIs fit the type. | OIDC Registration §2 | — | Add `application_type` to `ClientMetadata`; document the redirect rules per type; violations give `400 invalid_redirect_uri`. |

#### G. OpenID Connect (4)

All four are in [oidc](rfc-coverage-findings/oidc.md).

| ID | Finding | Rule | YAML location | Fix |
|---|---|---|---|---|
| H20 | No `POST /authorize`. OIDC Core requires the authorization endpoint to accept both GET and POST (form body). *(re-checked by hand)* | OIDC Core §3.1.2.1, §13.2 | `paths./authorize`, lines 109-205: only `get` (line 110) | Add `post` with an `application/x-www-form-urlencoded` body that references an `AuthorizationRequest` schema shared by GET and PAR; reuse the 302, 303, 200 and 400 responses. |
| H21 | `nonce` is not REQUIRED for `response_type=id_token` and `code id_token`. | OIDC Core §3.2.2.1, §3.3.2.1, §3.2.2.10, §2 | `components.parameters.Nonce`, lines 797-805 (`required: false`); `ResponseType`, 686-706 | State: REQUIRED when `response_type` contains `id_token`; the value is copied into the ID Token `nonce` claim. Add a conditional to the request schemas; a missing nonce gives `invalid_request`. |
| H22 | The ID Token schema has no `c_hash` or `at_hash`. `c_hash` is REQUIRED when the authorization endpoint returns an ID Token together with a code (`code id_token`), which the YAML allows. | OIDC Core §3.3.2.11, §3.1.3.6, §3.3.3.6 | `components.schemas.IDTokenClaims`, lines 2461-2509 | Add both claims with the left-half-hash rule; note that both MAY be omitted from the ID Token that the token endpoint returns. |
| H23 | `response_mode=query` is allowed with response types that return an ID Token from the authorization endpoint. | OAuth 2.0 Multiple Response Type Encoding Practices §3, §5, §7 | `ResponseMode` enum, line 855; `ResponseType`, 703-706 | If `response_type` contains `id_token`, forbid `query` (and `query.jwt` unless the JWT is encrypted). State this in `ResponseMode` and reject violations. |

#### H. Browser-based applications (2)

Both are in [pkce-apps](rfc-coverage-findings/pkce-apps.md).

| ID | Finding | Rule | YAML location | Fix |
|---|---|---|---|---|
| H24 | No CORS (Cross-Origin Resource Sharing) anywhere: neither the CORS headers that browser-based apps need on the token endpoint and other endpoints, nor the rule that the authorization endpoint must not support CORS. | RFC 10017 §6.3.3.4 (also §4, §7.2.1); OAuth 2.1-16 §3.1, §3.2; RFC 9449 §7.1, §8 | no CORS element in the YAML | Add reusable headers `Access-Control-Allow-Origin`, `Access-Control-Expose-Headers` (for example `DPoP-Nonce, WWW-Authenticate`) and `Vary: Origin` on the 200, 400 and 401 responses of `/token`, `/revoke`, `/userinfo`, `/jwks`, `/par` and both discovery documents. Add `OPTIONS` (204) at least for `/token`, `/userinfo` and `/par`. State "no CORS" at `/authorize`. Describe per-client allowed origins. |
| H25 | No lifetime limit for the refresh tokens of browser-based clients. | RFC 10017 §6.3.2.3 | `RefreshTokenRequest`, lines 1286-1289; `TokenResponse.refresh_token`, 1435-1439 | Add: for browser-based public clients the AS MUST bound refresh-token validity (an absolute maximum lifetime or an idle timeout) and MUST NOT give a rotated refresh token a later expiry than the original one. |

#### I. Sender-constrained tokens (2)

Both are in [pop](rfc-coverage-findings/pop.md). mTLS = mutual Transport
Layer Security.

| ID | Finding | Rule | YAML location | Fix |
|---|---|---|---|---|
| H26 | Certificate-bound access tokens are not supported at `/userinfo`, the protected resource that the AS hosts. | RFC 8705 §3 | `/userinfo` security: GET 516-518, POST 566-568 (`bearerAuth` or `dpop` only) | Add the combined alternative `{bearerAuth: [], mtls: []}`. Describe the check of the client certificate against `cnf.x5t#S256` and the 401 `invalid_token` on mismatch. Mention `mtls_endpoint_aliases.userinfo_endpoint`. |
| H27 | No DPoP downgrade protection: a DPoP-bound access token presented with the `Bearer` scheme (or in the form body) MUST be rejected. | RFC 9449 §7.2 (with §7.1, §6) | `securitySchemes.bearerAuth`, 2640-2646; `ProtectedResourceError`, 1091-1107; `/userinfo` POST form body, 532-545 | Add the rule to `bearerAuth` and `ProtectedResourceError`; respond 401 with `WWW-Authenticate: Bearer error="invalid_token", DPoP algs="..."`. |

#### J. Security BCP: authorization codes and AS-rendered pages (2)

Both are in [security](rfc-coverage-findings/security.md).

| ID | Finding | Rule | YAML location | Fix |
|---|---|---|---|---|
| H28 | Authorization codes are not described as single-use and short-lived, and the handling of reuse is missing. | RFC 9700 §4.2.4 (restating RFC 6749 §4.1.2), §4.5.2; OAuth 2.1-16 §4.1.3, §7.5.3 | `AuthorizationCodeTokenRequest.code`, lines 1249-1251; `/token` description | Add: single use; expires shortly (at most 10 minutes is RECOMMENDED); bound to `client_id` and `redirect_uri`. A second redemption is denied with `invalid_grant`, and the AS SHOULD revoke the tokens issued from that code — but only when the replayed request is otherwise valid, so that an attacker cannot cause a denial of service (OAuth 2.1-16 §7.5.3). |
| H29 | No clickjacking protection on the pages that the AS renders. | RFC 9700 §4.16 (with RFC 6819 §4.4.1.9, §5.2.2.6) | `/authorize` 200 (lines 190-195) and 400 (196-205); `DeviceAuthorizationResponse.verification_uri` (1564-1567) | Add reusable headers `Content-Security-Policy` (for example `frame-ancestors 'none'`) and `X-Frame-Options` (`DENY` or `SAMEORIGIN`) to `/authorize` 200 and 400; state that the device verification page sends them too. |

### 7.2 Medium findings by cluster (187)

| Cluster | Medium | Main topics |
|---|---|---|
| [core-6749](rfc-coverage-findings/core-6749.md) | 11 | client authentication per grant (`client_credentials` only for confidential clients); Basic encoding; which `/authorize` errors are redirected; `redirect_uri` constraints; code lifetime and single use; one client-authentication method per request; refresh rules; POST at the authorization endpoint; clickjacking, Referer leaks and CSRF (cross-site request forgery) on HTML pages; parameter processing; extension grants and their errors |
| [bearer-http](rfc-coverage-findings/bearer-http.md) | 6 | mandatory `WWW-Authenticate` on 401/403 (resource server and AS); access-token syntax and unguessable tokens; `/userinfo` POST security versus the form-body token; Basic encoding; "Basic PREFERRED" contradicts OAuth 2.1 |
| [oauth21](rfc-coverage-findings/oauth21.md) | 8 | `client_credentials` only for confidential clients; `iss` metadata flag must be `true`; redirect URI rules; `code_challenge_methods_supported` published with S256; CORS; clickjacking; code lifecycle; `client_secret_post` versus Basic |
| [revocation-introspection](rfc-coverage-findings/revocation-introspection.md) | 16 | token-ownership check before revoking; `token_type_hint` rules (2); CORS at `/revoke`; introspection validity checks and caller-specific answers; `act`/`may_act`; `token_type` for DPoP; `NumericDate` allows fractions; `active` description; `/introspect` security inconsistent; RFC 9701 client metadata, HTTP 400 for unauthenticated calls, caller must be a resource server, no top-level `sub`/`exp`; JWT pattern |
| [jwt](rfc-coverage-findings/jwt.md) | 11 | nested JWT (`cty`, order); recipient processing rules; JWT pattern; algorithm allowlists and `none`; catalogue of JWT kinds with explicit `typ`; issuer-key binding and audience; entropy of HMAC (hash-based message authentication code) keys; telling JWS, JWE and unsecured JWTs apart; RSA1_5 deprecated; SSRF (server-side request forgery) and `kid` injection; `JWTAccessTokenClaims.sub` |
| [jose](rfc-coverage-findings/jose.md) | 9 | JOSE header documentation; JARM signing metadata and `response` parameter; JWT pattern rejects JWE; `use` on keys; `kid` uniqueness and rotation; required members per key type; private-key members; RSA keys ≥ 2048 bits; HMAC key length |
| [assertions](rfc-coverage-findings/assertions.md) | 9 | `client_assertion` / `client_assertion_type` pairing; one method per request; error mapping (2); `JWTBearerTokenRequest` description; SAML bearer grant not modeled; client-assertion content and validation; `aud` text of the grant assertion; `/introspect` security; audience of JWT authorization grants (rfc7523bis) |
| [dcr](rfc-coverage-findings/dcr.md) | 19 | software statements; initial access token; extension and language-tagged metadata; cross-field rules; redirect validation at registration; client metadata from later RFCs; closed `token_endpoint_auth_methods_supported` enum; RFC 7592 read/update/delete, `registration_client_uri`/`registration_access_token`, 401/403 rules, update constraints, binding check; OIDC `subject_type`/`sector_identifier_uri`, algorithm preferences, authentication defaults, response rules, read rules, logout client metadata, per-client algorithm pinning |
| [pkce-apps](rfc-coverage-findings/pkce-apps.md) | 7 | PKCE errors at `/authorize`; PKCE verification and downgrade check at `/token`; `CodeChallengeMethod` text; the nonce exception versus the always-required `code_verifier`/`code_challenge`; native redirect URI options; refresh-token lifetime tied to the AS session; client authentication of browser apps |
| [metadata](rfc-coverage-findings/metadata.md) | 5 | well-known URL construction for issuers with a path; zero-element arrays must be omitted; omitted `code_challenge_methods_supported` means "no PKCE"; conditional MUSTs for `*_auth_signing_alg_values_supported` and `none`; RFC 9728 metadata URL construction and origin binding |
| [device-crossdevice](rfc-coverage-findings/device-crossdevice.md) | 6 | device-code URN in `grant_types_supported`; the verification page; `user_code` entropy and rate limiting; `device_code` entropy; RFC 10027 reference and risk warning; consent-page requirements |
| [token-exchange](rfc-coverage-findings/token-exchange.md) | 4 | `act` claim and introspection member; `actor_token` and `actor_token_type` together; error-code rules; closed `TokenTypeURI` enum |
| [pop](rfc-coverage-findings/pop.md) | 8 | `tls_client_auth_*` client metadata; `client_id` on mTLS requests and `invalid_client`; `token_type` description; `dpop_bound_access_tokens`; DPoP proof structure and checks; `token_type` in introspection; `dpop_jkt` rules; binding public clients' refresh tokens to the DPoP key |
| [resource-rar-stepup](rfc-coverage-findings/resource-rar-stepup.md) | 7 | audience restriction to the requested resources; `authorization_details` in JWT access tokens and at device authorization; AS duty to validate authorization details; missing mixin in `AuthorizationCodeTokenRequest`; `TokenResponse.authorization_details` text; `unmet_authentication_requirements` error |
| [jwt-at-sdjwt](rfc-coverage-findings/jwt-at-sdjwt.md) | 4 | JOSE header rules for access tokens (`typ` `at+jwt`, no `none`, RS256); `aud` derived from `resource` and `scope`; clients treat access tokens as opaque; `JWTAccessTokenClaims.sub` |
| [jar-par-iss](rfc-coverage-findings/jar-par-iss.md) | 14 | Request Object claim set; JAR client metadata; AS validation rules; `alg` `none` policy; `RequestUri` text; no `request_uri` in the PAR body; `require_pushed_authorization_requests` client metadata; audience of client assertions at `/par`; DPoP binding at PAR; processing a pushed Request Object; `request_uri` lifecycle; `request_uri_parameter_supported` text; `iss` required; `iss` metadata flag |
| [security](rfc-coverage-findings/security.md) | 12 | anti-framing header; code handling; high-entropy credentials; open-redirector precautions; no CORS at `/authorize`; asymmetric client authentication RECOMMENDED; refresh-token rotation semantics; `RedirectUri`, `CodeChallengeMethod`, `JWTAccessTokenClaims.sub` and refresh-token texts; client-assertion audience (security-topics-update) |
| [oidc](rfc-coverage-findings/oidc.md) | 30 | `claims` parameter structure; implicit and hybrid encoding; client-assertion claims; open `UserInfoResponse`; closed `Prompt` enum; `RedirectUri` REQUIRED rule; 302 and `ResponseType` texts; `/userinfo` POST security; CSRF and clickjacking; CORS (Discovery); `k` in the JWK Set; `request_uri_parameter_supported`; Form Post auto-submit page; default response modes; JARM (7 findings across both editions); `session_state`; `sid` claim (2); logout token; logout endpoint; CIBA endpoint, grant and errors |
| [adjacent-families](rfc-coverage-findings/adjacent-families.md) | 1 | the `+jwt` media type at `/introspect` conflicts with the JWT schema pattern |
| [oauth1-origin](rfc-coverage-findings/oauth1-origin.md), [adjacent-ace](rfc-coverage-findings/adjacent-ace.md) | 0 | — |

### 7.3 Recurring medium patterns

Many medium findings describe the same weakness from different documents.
Fixing the pattern once closes several findings.

| Pattern | Medium findings | Clusters | One fix |
|---|---|---|---|
| Client-authentication rules (confidential-only `client_credentials`, one method per request, Basic encoding, `client_secret_post` versus Basic, asymmetric methods, `/introspect` security) | 11 | 6 | One "client authentication" section in `ClientAuthFields` and `/token`, aligned with OAuth 2.1 §2.4 |
| Client metadata with no schema to live in (`tls_client_auth_*`, `dpop_bound_access_tokens`, JAR and PAR client metadata, RFC 9701 client metadata, logout metadata) | 7 | 4 | The `ClientMetadata` schema from H15 |
| Redirect URI handling (constraints, native options, open redirector, REQUIRED rule) | 6 | 5 | Rewrite `RedirectUri` once (with H6-H8) |
| Refresh-token rules (scope, rotation semantics, session binding, DPoP binding) | 5 | 4 | One refresh-token policy text |
| Algorithm policy and `none` | 5 | 4 | A shared "JWT handling" note plus `not: {const: none}` (with H12) |
| Entropy of codes, tokens, device codes and secrets | 5 | 4 | One rule for opaque values (at least 128 bits from a strong random generator), plus rate limiting for `user_code` and at least 256 bits for HS256 client secrets |
| CORS | 4 | 4 | Reusable CORS headers (with H24) |
| Clickjacking and CSRF on AS pages | 4 | 4 | Reusable `Content-Security-Policy` and `X-Frame-Options` headers (with H29) |
| Code and `request_uri` lifecycle | 4 | 4 | Lifecycle text (with H28) |
| Closed enums that reject registered values (`Prompt`, `ResponseMode` ×2, `TokenTypeURI`, `token_endpoint_auth_methods_supported`) | 5 | 3 | Open the enums (string plus `examples`) |
| JWT schema pattern rejects valid JWEs (line 2440) | 3 (+1 out of scope) | 3 | Two alternatives: JWS = 3 non-empty segments; JWE = 5 segments where segments 2, 3 and 5 may be empty |
| `iss` required and the metadata flag | 3 | 2 | With H2 |
| OIDF features advertised without operations: logout and session (5), CIBA (3), JARM (8, across jose and oidc) | 16 | 2 | Model the endpoints (P1 in [§12](#12-recommended-next-steps)) |

---

## 8. IANA registry coverage

### 8.1 Registry by registry

The IANA registries list every registered protocol value. The audit compared
875 values in 28 registries with the YAML text (a whole-word search; snapshot
2026-10-10; the OAuth Parameters registry was last updated 2026-08-24).
**393 values appear in the YAML; 482 do not.** Absence is not always a gap: the
JWT, JOSE, Well-Known URI and HTTP authentication registries serve many
protocols besides OAuth.

| Registry (IANA identifier) | Present / total | Absent | Absent values by defining source |
|---|---|---|---|
| OAuth Access Token Types (`token-types`) | 3 / 4 | 1 | IETF RFC 1 (`PoP`, RFC 9200 — ACE) |
| OAuth Authorization Endpoint Response Types (`endpoint`) | 8 / 10 | 2 | OIDF 2 (`vp_token`, `vp_token id_token` — OID4VP) |
| OAuth Extensions Error (`extensions-error`) | 31 / 50 | 19 | IETF RFC 6 (4 × RFC 7591, 2 × RFC 9200); OIDF 10 (OpenID Federation 7, OID4VP 3); Kantara 3 (UMA) |
| OAuth Parameters (`parameters`) | 57 / 87 | 30 | IETF RFC 10 (`vtr`, RFC 8485; 9 ACE values); OIDF 11 (`session_state`; Federation `trust_chain`; OID4VP 9); Kantara 6; ETSI 1; IETF draft 2 (ACE group communication) |
| OAuth Token Type Hints (`token-type-hint`) | 2 / 3 | 1 | Kantara 1 (`pct`) |
| OAuth URI (`uri`) | 11 / 15 | 4 | IETF RFC 4 (two SAML bearer URNs, RFC 7522; `jwk-thumbprint`, RFC 9278; `ckt`, RFC 9679) |
| OAuth Dynamic Client Registration Metadata (`client-metadata`) | 26 / 94 | 68 | IETF RFC 27 (RFC 7591: 15, RFC 7592: 2, RFC 8705: 5, RFC 9701: 3, RFC 9396: 1, RFC 9449: 1); OIDF 37 (OIDC Registration 17, OpenID Federation 6, logout specs 5, JARM 3, RP Metadata Choices 3, OID4VP 2, FAPI 1); ETSI 3; Kantara 1 |
| OAuth Token Endpoint Authentication Methods (`token-endpoint-auth-method`) | 7 / 7 | 0 | — |
| PKCE Code Challenge Methods (`pkce-code-challenge-method`) | 2 / 2 | 0 | — |
| OAuth Token Introspection Response (`token-introspection-response`) | 16 / 25 | 9 | IETF RFC 8 (`act`, `may_act`, RFC 8693; `vot`, `vtm`, RFC 8485; 4 ACE); Kantara 1 (`permissions`) |
| OAuth Authorization Server Metadata (`authorization-server-metadata`) | 67 / 82 | 15 | OIDF 10 (OpenID Federation); ETSI 3; IETF draft 2 (`status_list_aggregation_endpoint`, `identity_chaining_requested_token_types_supported`) |
| OAuth Protected Resource Metadata (`protected-resource-metadata`) | 17 / 23 | 6 | OIDF 6 (OpenID Federation) |
| OAuth Status Types (`status-types`) | 0 / 7 | 7 | registry created by `draft-ietf-oauth-status-list` |
| JSON Web Token Claims (`claims`) | 49 / 163 | 114 | IETF RFC 67 (mostly SIP/STIR telephony, RATS attestation, CDNI; OAuth-relevant: `act`, `may_act`, `events`, `sub_id`); OIDF 29 (`at_hash`, `c_hash`, `sid`, `sub_jwk`, `_claim_names`, `_claim_sources`, identity assurance, Federation); other 12 (3GPP, CTA); IETF draft 3; W3C 2; ETSI 1 |
| JWT Confirmation Methods (`confirmation-methods`) | 4 / 7 | 3 | IETF RFC 3 (`jwe`, `jku`, RFC 7800; `osc`, RFC 9203) |
| JWT Status Mechanisms (`status-mechanisms`) | 0 / 1 | 1 | `status_list` (status-list draft) |
| JWS and JWE Header Parameters (`web-signature-encryption-header-parameters`) | 24 / 46 | 22 | IETF RFC 17 (`jku`, `cty`, `crit`, `zip`, `epk`, `apu`, `apv`, `iv`, `tag`, `p2s`, `p2c`, `b64` and others); IETF draft 2 (`ek`, `psk_id` — HPKE); OIDF 2; other 1 |
| JWS and JWE Algorithms (`web-signature-encryption-algorithms`) | 12 / 67 | 55 | IETF RFC 31 (RFC 7518: 27, including every JWE key-management and content-encryption algorithm; `ES256K`, RFC 8812; 3 × ML-DSA, RFC 9964); IETF draft 14 (HPKE); W3C 10 (WebCrypto) |
| JWE Compression Algorithms (`web-encryption-compression-algorithms`) | 0 / 1 | 1 | IETF RFC 1 (`DEF`) |
| JSON Web Key Types (`web-key-types`) | 4 / 5 | 1 | IETF RFC 1 (`AKP`, RFC 9964) |
| JWK Elliptic Curves, Key Use, Key Operations, Key Set Parameters | 8/8, 2/2, 8/8, 1/1 | 0 | — |
| JSON Web Key Parameters (`web-key-parameters`) | 24 / 33 | 9 | IETF RFC 8 (RSA private-key members `p`, `q`, `dp`, `dq`, `qi`, `oth`; `pub`, `priv`, RFC 9964); W3C 1 (`ext`) |
| Well-Known URIs (`well-known-uris-1`) | 5 / 106 | 101 | 3 genuine matches (`oauth-authorization-server`, `oauth-protected-resource`, `openid-configuration`; `dots` and `time` are common-word matches). OAuth-relevant absences: `webfinger` (RFC 7033), `openid-federation` and `ssf-configuration` (OIDF), `uma2-configuration` (Kantara) |
| HTTP Authentication Schemes (`authschemes`) | 5 / 14 | 9 | IETF RFC 9 (Digest, Negotiate, SCRAM, HOBA, GNAP and others; none is an OAuth scheme) |
| HTTP Mutual Authentication Algorithms | 0 / 4 | 4 | IETF RFC 4 (RFC 8121) |
| **Total (28 registries)** | **393 / 875** | **482** | |

ETSI = European Telecommunications Standards Institute; W3C = World Wide Web
Consortium; HPKE = Hybrid Public Key Encryption; 3GPP = 3rd Generation
Partnership Project; CTA = Consumer Technology Association; SCRAM = Salted
Challenge Response Authentication Mechanism; HOBA = HTTP Origin-Bound
Authentication.

### 8.2 Absent values by defining source

| Source of the definition | Absent values |
|---|---|
| IETF RFC | 232 |
| OIDF | 109 |
| Other bodies (mostly owners of well-known URIs) | 61 |
| IETF draft (already in the registries, cited as `RFC-ietf-*` or `draft-*`) | 24 |
| W3C | 23 |
| Kantara Initiative (UMA) | 13 |
| ETSI | 11 |
| No per-value reference (status-list registries; one well-known URI) | 9 |
| **Total** | **482** |

In the 13 OAuth Parameters registries alone, 162 values are absent: 56 from
IETF RFCs, 76 from OIDF specs, 12 from Kantara, 7 from ETSI, and 11 from drafts
(2 from an ACE group-communication draft, 1 each from status-list and
identity-chaining, and the 7 status types).
Most OIDF absences belong to specs the YAML does not model by design (OpenID
Federation, OpenID for Verifiable Presentations) or to client metadata that
will come with Dynamic Client Registration (OIDC Registration, logout, JARM,
RP Metadata Choices).

### 8.3 IETF-RFC absences that matter for an OAuth 2.1 AS

| Absent values | Registry | Defined by | Why it matters | When |
|---|---|---|---|---|
| 15 client metadata names (`redirect_uris`, `token_endpoint_auth_method`, `grant_types`, `response_types`, `client_name`, `client_uri`, `logo_uri`, `contacts`, `tos_uri`, `policy_uri`, `software_id`, `software_version`, `client_id_issued_at`, `client_secret_expires_at`, `software_statement`) and 4 error codes | client metadata; errors | RFC 7591 | DCR is advertised but not modeled (H14-H17) | P1 |
| `registration_access_token`, `registration_client_uri` | client metadata | RFC 7592 | managing a registered client | P1 |
| `tls_client_auth_subject_dn`, `tls_client_auth_san_dns`, `tls_client_auth_san_uri`, `tls_client_auth_san_ip`, `tls_client_auth_san_email` | client metadata | RFC 8705 | `tls_client_auth` is advertised, but nothing says which certificate field identifies the client | with DCR |
| `introspection_signed_response_alg`, `introspection_encrypted_response_alg`, `introspection_encrypted_response_enc` | client metadata | RFC 9701 | per-client settings for the JWT introspection responses that the YAML models | with DCR |
| `dpop_bound_access_tokens`; `authorization_details_types` | client metadata | RFC 9449; RFC 9396 | per-client DPoP requirement and RAR types | with DCR |
| `act`, `may_act` | introspection response; JWT claims | RFC 8693 | token exchange is modeled, but its delegation claims are not | P2 |
| `events` | JWT claims | RFC 8417 | the Back-Channel Logout token uses it | with logout (P1) |
| `urn:ietf:params:oauth:grant-type:saml2-bearer`, `urn:ietf:params:oauth:client-assertion-type:saml2-bearer` | OAuth URI | RFC 7522 (rfc7523bis deprecates the client-authentication use) | decide: model the SAML grant, or state that it is excluded | P2 |
| `jku`, `cty`, `crit`, `zip`, `epk`, `apu`, `apv`, `iv`, `tag`, `p2s`, `p2c`, `b64` | JOSE header parameters | RFC 7515, 7516, 7518, 7797 | header processing rules are not documented (including the rfc8725bis `p2c` cap and `jku` SSRF rule) | P2 |
| JWE algorithms (`RSA-OAEP`, `RSA-OAEP-256`, `ECDH-ES` family, `A*KW`, `A*GCM`, `A*CBC-HS*`, `dir`) and `PS384`, `PS512`, `HS384`, `HS512` | JOSE algorithms | RFC 7518 | the encryption metadata arrays have no examples. `RSA1_5` should stay absent (deprecated by rfc8725bis) | P2 |
| `p`, `q`, `dp`, `dq`, `qi`, `oth` | JWK parameters | RFC 7518 | correct to be absent from a public JWK Set, but the schema should forbid them explicitly (H11) | P0 |
| `jwe`, `jku` | JWT confirmation methods | RFC 7800 | the `Confirmation` schema does not list them | low |
| `webfinger` | Well-Known URIs | RFC 7033 | OIDC Discovery §2 issuer discovery (optional) | optional |
| `ES256K` | JOSE algorithms | RFC 8812 | the YAML lists the `secp256k1` curve but not its algorithm | low |
| `ML-DSA-44`, `ML-DSA-65`, `ML-DSA-87`, `AKP`, `pub`, `priv` | JOSE | RFC 9964 | post-quantum readiness | watch |

Not relevant for an HTTP AS: the 16 ACE values in the OAuth registries, the
SIP, STIR, RATS and CDNI JWT claims, and the non-OAuth HTTP authentication
schemes.

---

## 9. Draft pipeline and watch list

### 9.1 Active drafts on 2026-10-10

Priority: **track now** (affects the YAML or the AS soon), **watch** (useful
later), **ignore** (outside the AS surface). "RFC soon" means the draft is in
the RFC Editor queue. AD = Area Director.

| Draft | Rev | State | Priority | RFC soon | What it means for the AS and the YAML |
|---|---|---|---|---|---|
| [`draft-ietf-oauth-v2-1`](https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/) | -16 | WG Document; expires 2027-03-07 | track now | no | See [§5](#5-oauth-21-draft-16). |
| [`draft-ietf-oauth-rfc7523bis`](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc7523bis/) | -11 | RFC Editor queue since 2026-04-30 (in progress) | track now | yes | Client-assertion `aud` = issuer only ([§9.2](#92-rfc7523bis-normative-changes)). |
| [`draft-ietf-oauth-rfc8725bis`](https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc8725bis/) | -10 | RFC Editor queue since 2026-08-25; blocked on `draft-ietf-jose-deprecate-none-rsa15` | track now | yes | Second edition of the JWT BCP ([§9.3](#93-rfc8725bis-normative-changes)). |
| [`draft-ietf-oauth-security-topics-update`](https://datatracker.ietf.org/doc/draft-ietf-oauth-security-topics-update/) | -03 | WG Document; expires 2027-01-07 | track now | no | Four new attacks (audience injection, cross-toolkit account takeover, cross-user session fixation, shared consent in brokered OAuth). Mostly client-side; for the AS: issuer as assertion audience, always send `iss`. |
| [`draft-ietf-oauth-client-id-metadata-document`](https://datatracker.ietf.org/doc/draft-ietf-oauth-client-id-metadata-document/) | -02 | WG Document; expires 2027-01-07 | track now | no | An `https` URL as `client_id`; the AS fetches a JSON metadata document (SSRF-safe fetcher, cache, no shared secrets). Add `client_id_metadata_document_supported`; the `ClientId` text ("issued at registration") no longer covers every case. OAuth 2.1 -16 §7.9 refers to it, and the Model Context Protocol (MCP) authorization spec adopts it. |
| [`draft-ietf-oauth-identity-chaining`](https://datatracker.ietf.org/doc/draft-ietf-oauth-identity-chaining/) | -17 (queue: -15) | RFC Editor queue since 2026-06-22 | track now | yes | Token exchange plus the jwt-bearer grant across trust domains. Adds `identity_chaining_requested_token_types_supported`; the closed `TokenTypeURI` enum must open; fix the `aud` text of `JWTBearerTokenRequest`. |
| [`draft-ietf-oauth-status-list`](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/) | -21 (queue: -20) | RFC Editor queue since 2026-06-04 | watch | yes | Token Status List: compact revocation status for self-contained tokens. Optional for an AS: `status` claim, status list endpoint, `status_list_aggregation_endpoint`. |
| [`draft-ietf-jose-hpke-encrypt`](https://datatracker.ietf.org/doc/draft-ietf-jose-hpke-encrypt/) | -22 | RFC Editor queue since 2026-09-29; blocked on `draft-ietf-hpke-hpke` | watch | yes | HPKE for JWE (updates RFC 7516). The JWT pattern must accept empty segments; add `HPKE-*` examples. |
| [`draft-ietf-oauth-attestation-based-client-auth`](https://datatracker.ietf.org/doc/draft-ietf-oauth-attestation-based-client-auth/) | -11 | In WG Last Call; expires 2027-03-07 | watch | no | Client attestation headers, a challenge endpoint, new authentication methods; the closed `token_endpoint_auth_methods_supported` and `ErrorResponse` enums would reject them. |
| [`draft-ietf-oauth-first-party-apps`](https://datatracker.ietf.org/doc/draft-ietf-oauth-first-party-apps/) | -04 | Consensus, waiting for write-up | watch | no | Authorization Challenge Endpoint for the AS operator's own native apps. PKCE is OPTIONAL there, unlike OAuth 2.1. |
| [`draft-ietf-oauth-transaction-tokens`](https://datatracker.ietf.org/doc/draft-ietf-oauth-transaction-tokens/) | -11 | Consensus, waiting for write-up | watch | no | Short-lived Txn-Tokens issued through token exchange inside one trust domain; new token types. |
| [`draft-ietf-oauth-identity-assertion-authz-grant`](https://datatracker.ietf.org/doc/draft-ietf-oauth-identity-assertion-authz-grant/) | -04 | WG Document; expires 2026-11-22 | watch | no | Identity Assertion JWT Authorization Grant (ID-JAG, "Cross-App Access"); `id-jag` token type; needs `ClientAuthFields` on the jwt-bearer request (H5). |
| [`draft-ietf-oauth-refresh-token-expiration`](https://datatracker.ietf.org/doc/draft-ietf-oauth-refresh-token-expiration/) | -03 | WG Document; expires 2027-01-07 | watch | no | `refresh_token_timeout` and `authorization_expires_in` in token and introspection responses; cheap to add. |
| [`draft-ietf-oauth-rar-metadata-remediation`](https://datatracker.ietf.org/doc/draft-ietf-oauth-rar-metadata-remediation/) | -00 | WG Document (-00 dated 2026-08-23) | watch | no | Metadata endpoint for RAR types; `insufficient_authorization` with `authorization_remediation`. |
| [`draft-ietf-oauth-deferred-token-response`](https://datatracker.ietf.org/doc/draft-ietf-oauth-deferred-token-response/) | -00 | WG Document (newly adopted; -00 dated 2026-09-16) | watch | no | `completion_mode=deferred`, deferral codes and a polling grant for asynchronous approval. |
| [`draft-ietf-oauth-spiffe-client-auth`](https://datatracker.ietf.org/doc/draft-ietf-oauth-spiffe-client-auth/) | -02 | WG Document; expires 2026-12-17 | watch | no | Workload identities (SPIFFE, the Secure Production Identity Framework for Everyone) for client authentication; new assertion type and methods that today's closed enums reject. |
| [`draft-ietf-oauth-sd-jwt-vc`](https://datatracker.ietf.org/doc/draft-ietf-oauth-sd-jwt-vc/) | -19 | IESG: Waiting for AD Go-Ahead; IANA review "Not OK" | ignore (for the AS) | no | A credential format, not AS surface. Vendor it when published (criterion 1). |

The [`../rfc-sources/README.md`](../rfc-sources/README.md) watch list names
the six drafts to vendor when they are published: rfc7523bis, rfc8725bis,
status-list, identity-chaining, jose-hpke-encrypt (once the YAML cites HPKE
algorithms) and sd-jwt-vc.

**Why rfc7523bis exists.** Researchers at the University of Stuttgart (Pedram
Hosseyni, Ralf Küsters and Tim Würtele) found the "audience injection" attack.
Ambiguous `aud` values in client-authentication JWTs let a malicious AS obtain
an assertion that it could replay at an honest AS. The OIDF published a notice
on 24 January 2025. The OAuth WG chose "audience = issuer" on 27 January 2025
(details in [`oauth-rfc-timeline.md`](oauth-rfc-timeline.md)).

### 9.2 rfc7523bis: normative changes

It updates RFC 7521, 7522, 7523 and 9126.

| Change | Replaces | Effect on the YAML |
|---|---|---|
| Client authentication: `aud` MUST be the AS issuer identifier (RFC 8414) as its **sole** value (a string or a one-element array); the AS MUST have an issuer identifier; the token endpoint URL MUST NOT be used; the AS MUST reject every other JWT. Simple string comparison. | RFC 7523 §3 item 3, case (b) | `ClientAuthFields.client_assertion` (1191-1196): add the rule (H3, H4). |
| Client-authentication JWTs SHOULD be typed `client-authentication+jwt`; servers are NOT RECOMMENDED to reject untyped JWTs. | RFC 7523 §3.2 (addition) | Same description. |
| Authorization grants: the client chooses an appropriate `aud`; the issuer identifier or the token endpoint URL. | RFC 7523 §3 item 3, case (a) | `JWTBearerTokenRequest.assertion` (1340-1345): replace "aud (the AS token endpoint URL)". |
| PAR: the issuer identifier MUST be the sole `aud` of `private_key_jwt` and `client_secret_jwt` assertions; the AS MUST reject others; typing SHOULD be used. | RFC 9126 §2, last paragraph | `/par` (427-437) and `PARRequest` (1583-1589). |
| SAML bearer assertions MUST NOT be used for client authentication in new applications. | RFC 7522 §2.2 | Note at `client_assertion_type` (1197-1200) that `saml2-bearer` is deprecated. |
| SAML audience: MUST identify the AS (issuer, token endpoint URL or SAML Entity ID); the AS MUST reject assertions without its identity. | RFC 7522 §3 item 2 | Only if the SAML grant is modeled. |
| Assertion metamodel: the issuer identifier "can be used" as audience; the token-endpoint suggestion is removed. | RFC 7521 §5.1 | Wording only. |
| New examples (§4, §4.1); no out-of-band audience agreement needed (§5). | RFC 7523 §4, §5 | Update examples. |
| Migration: old clients that send the token endpoint as `aud` fail against servers that enforce the update, so update clients first. | §6 (new) | Migration note. |
| IANA: media type `application/client-authentication+jwt`; references added for `private_key_jwt`, `client_secret_jwt` and the jwt-bearer and saml2-bearer URNs. | §8 | Already in the IANA registries. |

### 9.3 rfc8725bis: normative changes

It obsoletes RFC 8725 (BCP 225) and updates RFC 7519. IANA: no actions. The
YAML does not cite RFC 8725 anywhere today; add a short JWT-handling note to
`info.description`.

| Section | Change | Effect on the YAML |
|---|---|---|
| §3.1 | Libraries MUST restrict algorithms, MUST check `alg`/`enc` against the key found by `kid`, and each key MUST be used with exactly one algorithm; use allowlists, not blocklists (the case-insensitive "noNE" bypass). | Document per-issuer algorithm allowlists. |
| §3.2 | `none` MUST NOT be generated or consumed unless the caller explicitly allows it (was SHOULD NOT); `RSA1_5` is deprecated; new deployments SHOULD prefer fully-specified algorithms (Ed25519 over `EdDSA`, RFC 9864). | Add Ed25519 and Ed448 to `JWK.alg` (1855-1858) and the DPoP `algs` example (1023); mark `EdDSA` as legacy. Reject unsigned request objects when `require_signed_request_object` is true (2170-2173). |
| §3.3 | Libraries MUST let the recipient tell unsecured, JWS, JWE and nested JWTs apart (see the published vulnerability CVE-2023-51774; CVE = Common Vulnerabilities and Exposures). | State that verifiers distinguish JWS from JWE. |
| §3.4, §3.5, §3.6 | Validate ECDH-ES inputs (MUST); PBKDF2 (Password-Based Key Derivation Function 2) guidance and no human passwords as HS256 keys; avoid compression when creating a JWE. | Notes on encryption metadata and `client_secret` entropy. |
| §3.8 | Issuer and subject validation; points to RFC 9700 §4.15 (client ID versus user identifier confusion). | Reword `JWTAccessTokenClaims.sub` (2536-2540): for `client_credentials`, `sub` SHOULD identify the client and must not collide with user subjects. |
| §3.9 | `aud` is REQUIRED when JWTs go to more than one relying party "or may do so in the future"; reject if it is missing or matches no value of the recipient. | Add to `aud` in `IDTokenClaims` (2476-2482), `JWTAccessTokenClaims` (2530-2535), `JWTIntrospectionResponse` (1777-1783). |
| §3.10 | Treat claims as attacker input; `kid` injection prevention is now MUST; `jku`/`x5u` fetching SHOULD be protected (for example, by an allowlist), and without an allowlist the AS MUST check where a hostname resolves and avoid fetching from loopback or local addresses. | SSRF notes on `JWK.x5u` (1862-1865), client `jwks_uri`, `request_uri` and `jku`. |
| §3.11 | Explicit typing expanded: a `typ` without `/` means `application/...`; `typ: JWT` is not effective typing; RECOMMENDED for new JWT uses. | Document the `typ` of each JWT: `at+jwt`, `token-introspection+jwt`, `dpop+jwt`, `client-authentication+jwt`, `oauth-authz-req+jwt`. |
| §3.13 (new) | Cap the PBES2 (Password-Based Encryption Scheme 2) iteration count `p2c` (reject values above 1,200,000 is RECOMMENDED). | Note on the encryption metadata. |
| §3.14 (new) | Check the JWT format: only letters, digits, `-`, `_` and `.`. | Relax `components.schemas.JWT` (2434-2441): JWS = 3 non-empty segments; JWE = 5 segments where segments 2, 3 and 5 may be empty. |
| §3.15 (new) | Limit the decompressed size of a JWE (for example 250 KB). | Note. |

### 9.4 Drafts that stopped

Fourteen OAuth WG drafts were abandoned over the years — among them MAC access
tokens (2011-2014), the 2014-2019 proof-of-possession set, mix-up mitigation,
closing redirectors and Token Binding for OAuth. Their ideas mostly live on in
RFC 7800, RFC 8705, RFC 9207, RFC 9449, RFC 9700 and RFC 9728. The companion
timeline explains each one in
[Roads not taken](oauth-rfc-timeline.md#5-roads-not-taken) and follows the
active drafts in [What comes next](oauth-rfc-timeline.md#7-what-comes-next).

---

## 10. OpenID Foundation specs

### 10.1 Vendored now, and why

An OIDF document is vendored in [`../oidf-sources/`](../oidf-sources/README.md)
when the YAML models or advertises its protocol elements, or when it is the
edition that a vendored RFC cites. This audit added the seven marked "new".

| File | Specification | Status, date | Why it is vendored | YAML coverage |
|---|---|---|---|---|
| [oidc-core-1.0.html](../oidf-sources/oidc-core-1.0.html) | OpenID Connect Core 1.0 (errata set 2) | Final, 2023-12-15 | `/authorize` OIDC parameters, ID Token, UserInfo, OIDC errors; cited by RFC 9700 | mostly |
| [oidc-discovery-1.0.html](../oidf-sources/oidc-discovery-1.0.html) | OpenID Connect Discovery 1.0 (errata set 2) | Final, 2023-12-15 | `/.well-known/openid-configuration`, `OpenIDProviderMetadata` | mostly |
| [openid-connect-registration-1_0.html](../oidf-sources/openid-connect-registration-1_0.html) (new) | OpenID Connect Dynamic Client Registration 1.0 (errata set 2) | Final, 2023-12-15 | `registration_endpoint`; the client metadata a future `/register` must carry | referenced-only |
| [openid-connect-session-1_0.html](../oidf-sources/openid-connect-session-1_0.html) (new) | Session Management 1.0 | Final, 2022-09-12 | `check_session_iframe` | referenced-only |
| [openid-connect-rpinitiated-1_0.html](../oidf-sources/openid-connect-rpinitiated-1_0.html) (new) | RP-Initiated Logout 1.0 (RP = relying party) | Final, 2022-09-12 | `end_session_endpoint` | referenced-only |
| [openid-connect-frontchannel-1_0.html](../oidf-sources/openid-connect-frontchannel-1_0.html) (new) | Front-Channel Logout 1.0 | Final, 2022-09-12 | `frontchannel_logout_*` | referenced-only |
| [openid-connect-backchannel-1_0.html](../oidf-sources/openid-connect-backchannel-1_0.html) (new) | Back-Channel Logout 1.0 (errata set 1) | Final, 2023-12-15 | `backchannel_logout_*` | referenced-only |
| [openid-client-initiated-backchannel-authentication-core-1_0.html](../oidf-sources/openid-client-initiated-backchannel-authentication-core-1_0.html) (new) | Client-Initiated Backchannel Authentication (CIBA) Core 1.0 | Final, 2021-09-01 (an errata draft is pending) | `backchannel_authentication_endpoint` and three other `backchannel_*` fields | referenced-only |
| [oauth-v2-multiple-response-types-1_0.html](../oidf-sources/oauth-v2-multiple-response-types-1_0.html) | OAuth 2.0 Multiple Response Type Encoding Practices | Final, 2014-02-25 | `response_mode` `query`/`fragment`; cited by RFC 9700 | partial |
| [oauth-v2-form-post-response-mode-1_0.html](../oidf-sources/oauth-v2-form-post-response-mode-1_0.html) | OAuth 2.0 Form Post Response Mode | Final, 2015-04-27 | `response_mode=form_post`; cited by RFC 9700 | partial |
| [oauth-v2-jarm.html](../oidf-sources/oauth-v2-jarm.html) (new) | JWT Secured Authorization Response Mode (JARM), incorporating errata set 1 | Final 2022-11-09; errata 2025-08-17 | The `jwt` response modes; the current normative text | referenced-only |
| [openid-financial-api-jarm.html](../oidf-sources/openid-financial-api-jarm.html) | JARM, FAPI Draft-02 | Implementer's Draft (superseded), 2018-10-17 | The edition that RFC 9700 and RFC 9207 cite | referenced-only |

**Metadata fields now traceable.** 10 of the 67 `OAuthServerMetadata`
properties came from five OIDF Final specs that were not vendored; now 66 of 67
trace to vendored text. The last one, `http_logout_supported` (lines
2232-2235), comes from the abandoned 2015 draft "OpenID Connect HTTP-Based
Logout 1.0" and is not registered at IANA: mark it `deprecated: true` (pointing
to Front-Channel Logout) or remove it.

**JARM has two files on purpose.** The four response modes (`query.jwt`,
`fragment.jwt`, `form_post.jwt`, `jwt`) are the same in every edition, so the
metadata enum (line 2031) is valid. But `ResponseMode` (846-855) allows only
`query`, `fragment` and `form_post`; with the `*.jwt` modes, `iss` travels
inside the JWT; and `form_post.jwt` needs the auto-submit HTML page.

### 10.2 Recommended next

| Specification | Status, date | Recommendation | Why |
|---|---|---|---|
| [FAPI 2.0 Security Profile](https://openid.net/specs/fapi-security-profile-2_0-final.html) | Final, 2025-02-22 | vendor as the hardening reference | A formally analysed profile for a safe AS: confidential clients only, PAR, PKCE S256, sender-constrained tokens (mTLS or DPoP), client authentication by mTLS or `private_key_jwt` with `aud` = issuer, `iss` (RFC 9207), codes ≤ 60 s, no 307. Most building blocks are already in the YAML. See [§12.4](#124-for-your-oauth-21-server). |
| [Initiating User Registration via OpenID Connect 1.0 (`prompt=create`)](https://openid.net/specs/openid-connect-prompt-create-1_0.html) | Final, 2022-12-02 | vendor and model | The `Prompt` enum (815-819) is closed and rejects `create`; add `prompt_values_supported`. |
| [OpenID Connect Core Error Code `unmet_authentication_requirements`](https://openid.net/specs/openid-connect-unmet-authentication-requirements-1_0-final.html) | Final, 2022-11-17 | vendor and model | RFC 9470 §5 tells an AS to use it when a requested `acr` cannot be met; the `ErrorResponse` enum lacks it. Cite the `-final` URL. |
| [OpenID Connect Ephemeral Subject Identifier 1.0](https://openid.net/specs/openid-connect-ephemeral-subject-identifier-1_0-final.html) | Final, 2026-10-07 | vendor and model | Adds the subject type `ephemeral`; the `subject_types_supported` enum (2116-2121) is closed `[public, pairwise]`. |
| [OpenID Connect Relying Party Metadata Choices 1.0](https://openid.net/specs/openid-connect-rp-metadata-choices-1_0-final.html) | Final, 2026-03-25 | vendor; model with DCR | 19 plural client metadata names; IANA cites it for all 19. Belongs in the `ClientMetadata` schema. |

### 10.3 Other OIDF and related specifications (catalogue only)

| Specification | Body | Status | Date | Relevance |
|---|---|---|---|---|
| [FAPI 2.0 Message Signing](https://openid.net/specs/fapi-message-signing-2_0-final.html) | OIDF FAPI WG | Final | 2025-09-25 | Signed requests (JAR at PAR), JARM responses, JWT introspection; an optional add-on to FAPI 2.0 |
| [FAPI 2.0 Attacker Model](https://openid.net/specs/fapi-attacker-model-2_0-final.html) | OIDF FAPI WG | Final | 2025-02-22 | The threat model behind FAPI 2.0; a companion to RFC 6819 and RFC 9700 |
| [FAPI 1.0 Part 1 and Part 2](https://openid.net/specs/openid-financial-api-part-1-1_0.html) | OIDF FAPI WG | Final | 2021-03-12 | Legacy; the FAPI WG recommends FAPI 2.0 for new ecosystems |
| [FAPI-CIBA profile](https://openid.net/specs/openid-financial-api-ciba.html) | OIDF FAPI WG | Implementer's Draft | 2019-08-15 | Only relevant once CIBA is modeled |
| [Grant Management for OAuth 2.0](https://openid.net/specs/oauth-v2-grant-management.html) | OIDF FAPI WG | Implementer's Draft | 2023-05-09 | `grant_id` and a grant API; a companion to RAR |
| [OpenID Connect Native SSO for Mobile Apps 1.0](https://openid.net/specs/openid-connect-native-sso-1_0.html) | OIDF AB/Connect WG | Implementer's Draft | 2025-01-16 | A token-exchange profile; the closed `TokenTypeURI` enum would reject its token type |
| [OpenID Connect Key Binding 1.0](https://openid.net/specs/openid-connect-key-binding-1_0-ID1.html) | AB/Connect | Implementer's Draft | 2026-09-08 | Key-bound ID Tokens through DPoP |
| [OpenID Federation 1.0](https://openid.net/specs/openid-federation-1_0.html) | AB/Connect | Final | 2026-02-17 | Trust chains. IANA has 12 Federation AS-metadata names and the YAML models none of them; [§8.1](#81-registry-by-registry) counts only 10 as absent, because `jwks` and `description` also occur as ordinary words in the YAML. |
| [OpenID Federation 1.1 (and Federation for OIDC 1.1)](https://openid.net/specs/openid-federation-1_1.html) | AB/Connect | Final | 2026-05-05 | Splits 1.0 into two parts; no new functionality |
| [OpenID for Verifiable Credential Issuance 1.0](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html) | OIDF Digital Credentials Protocols WG | Final | 2025-09-16 | Pre-authorized code grant; `openid_credential` authorization details |
| [OpenID for Verifiable Presentations 1.0](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html) | Digital Credentials Protocols WG | Final | 2025-07-09 | Wallet side; outside an AS |
| [OpenID4VC High Assurance Interoperability Profile (HAIP) 1.0](https://openid.net/specs/openid4vc-high-assurance-interoperability-profile-1_0-final.html) | Digital Credentials Protocols WG | Final | 2025-12-24 | Only if the AS serves a credential issuer |
| [Self-Issued OpenID Provider v2 (SIOPv2)](https://openid.net/specs/openid-connect-self-issued-v2-1_0.html) | AB/Connect | Implementer's Draft | 2023-11-28 (draft 13) | Wallet side |
| [Shared Signals Framework (SSF) 1.0 + CAEP 1.0 + RISC 1.0](https://openid.net/specs/openid-sharedsignals-framework-1_0-final.html) | OIDF Shared Signals WG | Final | 2025-08-29 | Event streams built on SETs (CAEP = Continuous Access Evaluation Profile; RISC = Risk Incident Sharing and Coordination); an AS could be a transmitter |
| [OpenID Connect for Identity Assurance 1.0](https://openid.net/specs/openid-connect-4-identity-assurance-1_0.html) | OIDF eKYC (electronic Know Your Customer) and IDA (Identity Assurance) WG | Final (errata set 1) | 2026-07-01 | `verified_claims`; regulated use |
| [iGov profiles for OAuth 2.0 and OIDC](https://openid.net/specs/openid-igov-oauth2-1_0.html) | OIDF iGov WG | Implementer's Draft | 2026-04-13 | Government profiles; no Final yet |
| [AuthZEN Authorization API 1.0](https://openid.net/specs/authorization-api-1_0.html) | OIDF AuthZEN WG | Final | 2026-01-11 | A policy-decision API; not AS surface |
| [UMA 2.0 Grant + Federated Authorization](https://docs.kantarainitiative.org/uma/wg/rec-oauth-uma-grant-2.0.html) | Kantara Initiative | Kantara Recommendation | 2018-01-07 | 13 IANA values, none in the YAML; never became an RFC |
| [OpenID Connect EAP ACR Values 1.0](https://openid.net/specs/openid-connect-eap-acr-values-1_0.html) | OIDF EAP (Extended Authentication Profile) WG | Final | 2025-06-15 | `acr` values `phr`, `phrh`; `amr` value `pop` |
| [OIDC Token Hash Algorithm Implementer's Guide](https://openid.net/specs/openid-connect-token-hash-algorithms-1_0.html) | AB/Connect | Draft 00 | 2026-09-04 | Hash choice for `at_hash`/`c_hash` with EdDSA and ML-DSA |
| [OpenID Provider Commands 1.0](https://openid.net/specs/openid-provider-commands-1_0.html) | AB/Connect | Draft 02 | 2025-09-25 | Watch only |
| [OpenID Connect HTTP-Based Logout 1.0](https://openid.net/specs/openid-connect-logout-1_0-04.html) | AB/Connect | Abandoned draft 04 (became Front-Channel Logout) | 2015-09-10 | Source of `http_logout_supported` |
| [OpenID 2.0 to OpenID Connect Migration 1.0](https://openid.net/specs/openid-connect-migration-1_0.html) | AB/Connect | Final | 2015-04-16 | History |
| [OpenID Authentication 2.0](https://openid.net/specs/openid-authentication-2_0.html) | OpenID Foundation | Final (obsolete) | 2007-12-05 | History: the identity layer before OIDC |

SSO = single sign-on; `amr` = Authentication Methods References, the OIDC
claim that lists how the user authenticated.

---

## 11. Folder analysis

### 11.1 Structure

```text
oauth-openapi/
├── oauth-openapi.yaml          source of truth: OpenAPI 3.1.0, 2,704 lines
├── oauth-openapi-modular/      derived multi-file view (split-oauth-openapi.py);
│                               bundle.sh writes dist/ (gitignored)
├── references/
│   ├── rfc-sources/            50 RFCs + OAuth 2.1 -16; manifest.txt (this audit)
│   ├── oidf-sources/           12 OIDF specs; manifest.txt (this audit)
│   ├── rfc-validation/         20 reports from 2026-05-10 (17 RFCs, OAuth 2.1 -13, OIDC)
│   ├── audit/                  this report, the timeline, the findings, earlier audits
│   ├── ibm-api-connect-oauth.yaml       read-only historical spec
│   └── ybelenko-oauth2-endpoints.yaml   read-only historical spec
├── tools/                      serve-swagger-ui.sh, fetch-specs.sh (new), README.md runbook
├── CLAUDE.md, .claude/         project conventions, slash commands, permissions
└── .spectral.yaml, openapitools.json, .tool-versions, .gitignore
```

The intended loop: read the RFC or OIDF text → encode it in the YAML → check it
against the audits → lint (0 errors, 0 warnings) → preview → generate server
scaffolds → regenerate the modular view.

### 11.2 Build health

| Check | Result |
|---|---|
| Spectral 6.17.0 lint with the repository rule set | **0 errors, 0 warnings**, 0 infos, 4 hints. The hints are `oas3-unused-component` on the four documentation-only schemas (`JWTIntrospectionResponse`, `UserInfoSignedResponse`, `IDTokenClaims`, `JWTAccessTokenClaims`). Gate passes. Note: Spectral fails only on errors by default; automation needs `-F warn` to enforce "0 warnings". |
| Modular view | In sync: a fresh run of `split-oauth-openapi.py` reproduced the committed tree byte for byte ("VERIFY: PASS"). The script never deletes old files, and it regenerates `bundle.sh` and the modular README from templates. Lint the bundle, not the modular root (11 false-positive errors there). |
| Bundle (`bundle.sh`; Redocly 2.62.1 + Spectral 6.17.0) | 0 / 0 / 0 / 4 hints; the bundle is byte-identical to the local copy and has 0 data differences from the single file. `dist/` is gitignored. |
| openapi-generator `validate` (7.14.0 and 7.26.0) | Passes, with 4 "unused model" notes for the same schemas. |
| The 8 README `generate` commands | Exit 0 on both generator versions. Every target logs "Unknown type `mutualTLS`": the RFC 8705 `mtls` scheme is dropped from every scaffold. |
| Redocly recommended rule set (extra check) | 5 errors and 9 warnings, mostly by design: the 5 intentionally public operations have no `security`, 4 GET operations have no 4xx response, and 5 components are unreferenced. |
| YAML hygiene | UTF-8, LF line endings, no tabs, no trailing spaces, no duplicate keys (all 30 YAML files in the repository). |
| External links | All 16 distinct non-example URLs return HTTP 200. |

**YAML statistics:** 106,967 bytes; 2,704 lines; 11 paths with 12 operations;
35 schemas; 24 parameters; 6 headers; 5 responses; 5 security schemes; 7 tags;
156 `$ref`; 13 `externalDocs`; 285 RFC mentions (228 in YAML data, 57 in
comments) naming 33 distinct RFCs. Most cited: RFC 6749 (40), 9449 (23), 9126
(20), 8414 (15). Of the 35 RFCs vendored before this audit, 8 are never cited
(6755, 6819, 7522, 7592, 8252, 8725, 9278, 9901). The YAML should also start
citing RFC 10017, RFC 10027, RFC 8725 and RFC 9864.

**What the YAML models.** The 12 operations are `GET /authorize`; `POST` on
`/token`, `/revoke`, `/introspect`, `/device_authorization` and `/par`; `GET`
and `POST` on `/userinfo`; `GET /jwks`; and `GET` on the three discovery
documents (`/.well-known/openid-configuration`,
`/.well-known/oauth-authorization-server` and
`/.well-known/oauth-protected-resource`). The token endpoint accepts six
grants: `authorization_code` (with PKCE), `client_credentials`,
`refresh_token`, the device code grant (RFC 8628), the jwt-bearer grant
(RFC 7523) and token exchange (RFC 8693). The five security schemes are
`bearerAuth`, `dpop`, `clientSecretBasic`, `mtls` and `oauth2`. No operation
references `oauth2`; this is by design.

**What the YAML does not model** (see [§7](#7-priority-findings) and
[§12.2](#122-p1--add-the-largest-missing-surface)): client registration
(`/register`, RFC 7591 and RFC 7592), `POST /authorize`, the OIDC logout and
session features (the logout endpoint, the Back-Channel Logout token, `sid`,
`session_state`), the CIBA endpoint and grant, JARM responses, and the SAML
bearer grant (RFC 7522). The metadata already advertises several of them, for
example `registration_endpoint`, `end_session_endpoint` and
`backchannel_authentication_endpoint`.

### 11.3 Documentation consistency

The review covered 48 files and found **48 issues: 2 high, 21 medium, 25
low**. The main cause: the evidence layer and the source indexes were frozen in
May and June 2026, while the spec grew from 1,379 to 2,704 lines and the
standards changed.

**Fixed by this audit (12 issues), and partly addressed (3):**

| Severity | Issue | Status |
|---|---|---|
| high | `../rfc-sources/README.md` (and `CLAUDE.md`) claimed "every OAuth working group RFC" — false since RFC 10017 and RFC 10027 (August 2026). | **Fixed:** both RFCs vendored; a dated five-criteria scope rule; `CLAUDE.md` updated. Still open: cite both RFCs in the YAML. |
| high | The OAuth 2.1 snapshot was -15, which had expired. | **Fixed:** -16 vendored; index row and history updated; refreshes now take the latest revision. Still open: the YAML citations ([§5.4](#54-what-remains-to-change-in-the-yaml)) and the revision label in the YAML info table and the README. |
| medium | The claim "every IETF RFC and Internet-Draft used by this project's audit" was not true: 3986, 7518, 7617, 7638, 8037 and 9110 were cited but not vendored, and RFC 9864 was not tracked. | **Fixed** (criteria 4 and 5). Still open: move the YAML's `EdDSA` examples to `Ed25519`. |
| medium | A `curl` loop that was run by hand, in the RFC README, broke the script-first rule. | **Fixed:** `manifest.txt` + `tools/fetch-specs.sh` + runbook. |
| medium | The OIDF README omitted specs whose fields the YAML advertises. | **Fixed:** six specs vendored and indexed. |
| medium | The OIDF README said "JARM is still a draft". | **Fixed:** the Final JARM is vendored; the README explains the two files. |
| low | RFC licensing text ("IETF Trust LCC", "unrestricted reproduction"). | **Fixed:** BCP 78 and the IETF Trust Legal Provisions. |
| low | OIDF licensing text ("unrestricted reproduction"). | **Fixed:** quotes the purpose-limited OIDF license. |
| low | The OIDF `curl` block. | **Fixed:** manifest + script. |
| low | The RFC index showed no lineage (no obsoletes, updated-by or BCP data; no RFC 5849). | **Fixed:** Published, Status and formal-relationship columns; RFC 5849 vendored. |
| low | No watch list for drafts close to publication. | **Fixed:** a watch list of six drafts. |
| low | "RFC 8705 … refreshed" (it was added, not refreshed). | **Fixed** in the snapshot history. |
| medium | The note that the 17 RFCs added on 2026-06-06 "do not yet have corresponding ../rfc-validation/ audit files" (really 18). | **Partly:** the note is gone, and the README says the May 2026 reports are dated and superseded by the 2026-10 findings. No new reports were written. |
| medium | About 301 YAML line references in 13 of the 20 validation reports point to the pre-audit YAML. | **Partly:** the RFC and audit READMEs now warn about the drift; the reports are unchanged. |
| low | No index of the validation reports. | **Partly:** `README.md` in this folder now dates them; there is still no index. |

**Remaining medium issues (17):**

| # | Where | Issue | Fix |
|---|---|---|---|
| 1 | YAML lines 164-171, 183, 785-792 | OAuth 2.1 statements and citations are stale for -16. | [§5.4](#54-what-remains-to-change-in-the-yaml). |
| 2 | `../rfc-validation/oauth-2.1-draft.md` | Still written against -13; section numbers differ in -13, -15 and -16; §9 discussion predates RFC 10017. | Re-run against -16, or add a banner with a section map and cite RFC 10017. |
| 3 | README "Specifications referenced" vs YAML info table (lines 16-45) | Two tables maintained by hand omit RFCs the YAML cites (7800, 7591, 8176, 7521, 7518, 8037, 7638, 9110, 7617, 3986) and the OIDF specs it models. | Keep one coverage matrix (§6 of this report can serve) and link to it. |
| 4 | The 20 reports in `../rfc-validation/` | 13 reports hold about 301 stale YAML line references; 16 still use the old name `DiscoveryDocument`, and 10 name the removed `clientAssertion` scheme. | Add a standard banner: snapshot revision, renames, and the commits that applied the findings. |
| 5 | Seven validation reports (for example `8414-as-metadata.md`) | Point to cached source files that were never committed. | Link to `../rfc-sources/…` and `../oidf-sources/…` instead. |
| 6 | `rfc-audit-synthesis.md` lines 56-256 | Reads as an open to-do list, but almost all items are applied. | Mark each item applied, deferred or rejected; date the "currently has" snapshots. |
| 7 | `rfc-audit-synthesis.md` line 47 | Cites "OAuth 2.1 §4.8", which does not exist. | Cite RFC 9700 §2.1.1 and §4.8, and OAuth 2.1 -16 §4.1.1 and §7.5.2. |
| 8 | `CLAUDE.md` line 48 | Treats `oas3-unused-component` as a warning and advises deleting unused schemas; `.spectral.yaml` makes it a hint so that four documentation schemas stay. | Name the four schemas as intentional; say "hint". |
| 9 | `CLAUDE.md` line 57 | The modular view is not mentioned, and the workflow has no regenerate-and-bundle step. | Add the convention and the step (expect "VERIFY: PASS" and 0 / 0). |
| 10 | README "View interactively"; `.claude/commands/preview.md` | `npx @redocly/cli preview-docs` fails with Redocly 2.x (the command is unpinned). | Pin `@redocly/cli@1`, or use `build-docs` from a `tools/` script. |
| 11 | `.claude/settings.json` | Allow rules do not match the `npx --yes` commands; some rules are stale or too broad. | Align the rules with the commands; remove `swagger-ui-watcher` and `python3 -c*`. |
| 12 | README "View interactively" | "The script runs all three" viewers — only the `/preview` command does. | Add `tools/preview.sh start\|stop\|status`. |
| 13 | README "Learning goal" and "Why this exists", `CLAUDE.md` lines 15-16, YAML lines 13-14 | Claim every field links to its source through `externalDocs`; only the 12 operations and the root do. | Reword: operations use `externalDocs`; fields cite the clause in their description. |
| 14 | README "Why this exists" and "Grant types modeled"; `CLAUDE.md` line 12 | "every modern extension through 2025" and "All current grants". | Add an "as of" date and list what is not modeled (DCR, RFC 7592, the SAML grant, CIBA, SD-JWT). |
| 15 | README "Roadmap" | Items done or misnamed (JAR, RAR, "token-binding" examples). | Tick and reword; add the -16 refresh, RFC 10017/10027 and DCR. |
| 16 | README "License" | CC-BY-4.0 is declared, but there is no LICENSE file. | Add LICENSE plus a note that the vendored texts keep their own licenses. |
| 17 | `../rfc-sources/README.md` (validation note) | Partly fixed (see above). | Rely on the 2026-10 findings; optionally write reports for RFC 9728, 9101, 9701, 9470, 8705, 9207 and 7800. |

**Remaining low issues (19):**

| Area | Issues |
|---|---|
| Audit documents (7) | The synthesis lists 3 of the 4 documentation-only schemas; the live identity-provider (IdP) comparison projects "38" fields where its own outcome gives 49; two fields it calls Auth0-specific come from IETF drafts (`client_id_metadata_document_supported`, `global_token_revocation_endpoint`); its `curl` and Python snippet should be a script; `community-reference-specs.md` has stale paths, an incomplete table and an old FAPI 2.0 status; some validation reports carry wrong dates; there is no index of the validation reports. |
| README (5) | The eight generator commands should be one script; "20 RFCs" should say "20 documents"; a caveat still calls the `/authorize` responses a placeholder; the layout tree misses files and there is no prerequisites section; hard-coded counts drift. |
| YAML (3) | The PKCE wording in `info.description` conflicts with the `/authorize` text; the Discovery tag also covers the resource server's metadata endpoint; `info.version` stayed 1.0.0 across breaking changes. |
| Other (4) | The modular README template still says "Review this, then decide"; `tools/README.md` says "250-line" (the script has 404 lines) and its quick-start port 8765 collides with Redoc; `.gitignore` does not ignore `.claude/settings.local.json`. |

### 11.4 Tooling findings

| Area | Severity | Finding | Fix |
|---|---|---|---|
| `openapitools.json` | medium | The generator is pinned to 7.14.0 (June 2025); 7.26.0 (2026-10-06) is current and worked in a test without other changes. The `mutualTLS` scheme is dropped on both versions. | Bump to 7.26.0; document that RFC 8705 mTLS must be implemented in your own code. |
| Unpinned tools | medium | No `package.json` or lockfile; `bundle.sh` uses `@latest`; the docs use bare `npx`. The 0 / 0 gate can change without any repository change. | Pin exact versions in the `bundle.sh` template and the docs, or add a `package.json` with a lockfile. |
| CI and hooks | medium | No CI (continuous integration) and no pre-commit hook: lint, modular sync and bundle are manual. | Add a workflow or hook: `spectral lint -F warn`, regenerate and `git diff --exit-code`, `bundle.sh`, optional `validate`. |
| `CLAUDE.md` vs `.spectral.yaml` | medium | Conflicting unused-component policy (see 11.3, issue 8). | Rewrite the section. |
| OAuth 2.1 snapshot | medium | The snapshot was -15. | **Fixed** by this audit; the YAML citations remain (§5.4). |
| `.tool-versions` | low | Node 26.2.0 is pinned; 26.11.1 is the latest 26.x (two security releases since); Node 26 is scheduled to become LTS (long-term support) on 2026-10-28. Python, PyYAML and Java are undeclared. | Bump Node; declare the other runtimes. |
| `.gitignore` | low | Misses `.claude/settings.local.json`, `.venv/`, `__pycache__/`, `.env.*`. | Add them. |
| `.claude/settings.json` | low | Rules do not match real commands; some are too broad (`python3 -c*`, `curl`, `git commit`). | Narrow them. |
| `.claude/settings.local.json` | low | 45 of 50 rules belong to the sibling `oauth-lab` project. | Move them there. |
| Licensing | low | No LICENSE file; CC-BY-4.0 is also declared for software, which Creative Commons does not advise. | Add LICENSE (CC-BY-4.0 for spec and docs) and a software license for `tools/`. |
| Redocly recommended rules | low | 5 errors, 9 warnings (see 11.2). | Add `security: []` to public operations; reword the `oauth2` scheme text for `/userinfo`. |
| Documentation drift | low | Line counts, viewer claims and completeness claims drift. | See 11.3. |
| `tools/serve-swagger-ui.sh` | low | One shellcheck warning (SC2155); floating `swagger-ui-dist@5` without SRI (Subresource Integrity) hashes; the page title is not HTML-escaped. | Split the declaration; optionally pin with SRI; escape the title. |
| `split-oauth-openapi.py` | low | Never deletes files it no longer generates. | Clear `spec/` before writing. |

---

## 12. Recommended next steps

### 12.1 P0 — fix what is wrong today

These items make the YAML correct against OAuth 2.1 -16. They fix 19 of the
29 high findings by changing existing operations and schemas.
[§12.2](#122-p1--add-the-largest-missing-surface) covers the other 10: the
findings that add operations (H14-H20, and the CORS preflight of H24) and two
browser rules that belong with CORS (H25, H29).

1. **OAuth 2.1 -16 alignment:** `code_challenge_method` (H1), `iss` REQUIRED
   and its metadata flag (H2), §7.5.4 citations, the `/authorize` 400 rules,
   value-size notes, `client_secret_post` versus Basic, and the revision label
   ([§5.4](#54-what-remains-to-change-in-the-yaml)).
2. **Client assertions:** issuer-only `aud` and `typ` at every endpoint,
   including `/par` (H3, H4); `ClientAuthFields` in `JWTBearerTokenRequest`
   (H5).
3. **Redirect URIs and codes:** the loopback-port exception (H6, H7); no `http`
   except loopback (H8); the PKCE downgrade check (H9); single-use,
   short-lived codes (H28).
4. **PAR with JAR:** a conditional `PARRequest` schema (H10).
5. **JOSE safety:** a public-only JWK Set (H11); no `none` or MAC algorithms in
   the metadata (H12); JWT access-token validation steps (H13).
6. **`/userinfo`:** mTLS-bound tokens (H26) and DPoP downgrade protection (H27).
7. **OIDC correctness:** `nonce` (H21), `c_hash` and `at_hash` (H22), no `query`
   mode with ID Tokens (H23).
8. **After each change:** regenerate the modular view, bundle, and lint to 0
   errors and 0 warnings.

### 12.2 P1 — add the largest missing surface

1. **Dynamic Client Registration:** `POST /register`, `ClientMetadata`,
   `ClientInformationResponse` and the four errors (H14-H17); the OIDC rules and
   `application_type` (H18, H19); RFC 7592 read, update and delete. This also
   gives a place to the client metadata of [§7.3](#73-recurring-medium-patterns)
   and [§8.3](#83-ietf-rfc-absences-that-matter-for-an-oauth-21-as).
2. **`POST /authorize`** with one `AuthorizationRequest` schema shared by GET,
   POST and PAR (H20).
3. **Browser and page security:** CORS headers and `OPTIONS` where browsers call
   the AS, and no CORS at `/authorize` (H24); clickjacking headers (H29);
   refresh-token lifetime for browser apps (H25). Cite RFC 10017.
4. **Logout and session:** an RP-Initiated Logout endpoint (the
   `end_session_endpoint` is already advertised), a Back-Channel Logout token
   schema, `sid`, `session_state`.
5. **CIBA:** the backchannel authentication endpoint, the CIBA grant and its
   errors. RFC 10027 §6.2.2.5 recommends CIBA over the device grant when the
   consumption device can supply a user identifier.
6. **Device flow:** the verification page, `user_code` and `device_code`
   entropy, and an RFC 10027 reference with its risk warning.
7. **JARM:** the `response` parameter, the AS metadata, and the four `*.jwt`
   values in `ResponseMode`.
8. **Open the closed enums** (`TokenTypeURI`, `Prompt`,
   `token_endpoint_auth_methods_supported`, `ErrorResponse`) and fix the JWT
   pattern so that it accepts valid JWEs.

### 12.3 P2 — watch list, IANA gaps, documentation and tooling

1. **When drafts are published:** vendor rfc7523bis, rfc8725bis, status-list,
   identity-chaining and sd-jwt-vc; vendor jose-hpke-encrypt once the YAML
   cites HPKE algorithms; apply the rfc8725bis changes
   ([§9.3](#93-rfc8725bis-normative-changes)). Refresh OAuth 2.1 at each
   revision and re-check every `OAuth 2.1 §` citation. `fetch-specs.sh --check`
   reports a new OAuth 2.1 revision, but it does not report new RFCs
   ([§1.4](#14-keeping-the-answer-true)).
2. **IANA gaps:** `act` and `may_act`, the JOSE header parameters, encryption
   algorithm examples, a decision on the SAML grant.
3. **OIDF:** vendor the FAPI 2.0 Security Profile; model `prompt=create`,
   `unmet_authentication_requirements` and the `ephemeral` subject type; model
   RP Metadata Choices with DCR; deprecate `http_logout_supported`.
4. **Documentation and tooling:** the open issues in
   [§11.3](#113-documentation-consistency) and [§11.4](#114-tooling-findings).

### 12.4 For your OAuth 2.1 server

The audit reviewed an API description, but its results also form a test list
for an implementation. The rules below come from the ten documents rated
*required (2.1)*, the 29 high findings and the JWT best practices (RFC 8725 and
its successor draft).

| # | What the server must get right | Source |
|---|---|---|
| 1 | Only the authorization code grant with PKCE, client credentials (confidential clients only, always authenticated) and refresh tokens, plus the extension grants you choose. No implicit or password grant. | OAuth 2.1 §4.2, §10 |
| 2 | Require `code_challenge` with `S256`; reject `plain` or a missing method with `invalid_request`. Accept a `code_verifier` only if a `code_challenge` was sent. | OAuth 2.1-16 §4.1.1, §7.5.2; RFC 9700 §4.8.2 |
| 3 | Codes are single-use, short-lived (at most 10 minutes is RECOMMENDED) and bound to the client and redirect URI. A replay gets `invalid_grant`; revoke the tokens from that code only if the replayed request is otherwise valid. | RFC 9700 §4.2.4; OAuth 2.1-16 §7.5.3 |
| 4 | Exact redirect URI matching, except any port for loopback IP URIs; no `http` except loopback; no fragments. | RFC 8252 §7.3; RFC 9700 §2.6; OAuth 2.1-16 §8.4.2 |
| 5 | Validate `client_id` and `redirect_uri` before you redirect any error; otherwise show a 400 page, never a 401. | OAuth 2.1-16 §4.1.2.1 |
| 6 | `iss` in every authorization response; publish `authorization_response_iss_parameter_supported: true`; redirect with 303, never 307. | OAuth 2.1-16 §4.1.2, §7.5.4; RFC 9207 §2.3 |
| 7 | `Content-Security-Policy: frame-ancestors` and `X-Frame-Options` on every page you render (login, consent, errors, device verification). No CORS at `/authorize`; CORS where browser apps call you. | RFC 9700 §4.16; OAuth 2.1-16 §3.1; RFC 10017 §6.3.3.4 |
| 8 | Consent-phishing controls: per-client scope allow-lists, a consent screen with the client name, owner and scopes, grant review and revocation. | OAuth 2.1-16 §7.9 |
| 9 | Support `client_secret_post` (HTTP Basic is only MAY), but prefer asymmetric client authentication (`private_key_jwt` or mTLS). | OAuth 2.1 §2.4.1; RFC 9700 §2.5 |
| 10 | For JWT client assertions, your issuer identifier is the only accepted `aud`, at every endpoint including PAR; detect replay with `jti` and `exp`. | rfc7523bis §4, §5 |
| 11 | Public clients' refresh tokens are sender-constrained (DPoP or mTLS) or rotated; for browser clients, also bound their lifetime and never extend it on rotation. | OAuth 2.1 §4.3.1; RFC 10017 §6.3.2.3 |
| 12 | Prefer sender-constrained access tokens; reject a DPoP-bound token sent as a Bearer token; check certificate-bound tokens against `cnf.x5t#S256`. | RFC 9449 §7.2; RFC 8705 §3 |
| 13 | No tokens in the URI query; `WWW-Authenticate` on every 401; TLS 1.3 supported and preferred, TLS 1.2 still allowed, never TLS 1.0 or 1.1 (see the TLS note below the table). | OAuth 2.1 §1.5, §5.1; RFC 6750; RFC 9110; BCP 195: RFC 8996, RFC 9325 §3.1.1, RFC 9852 §3-§5 |
| 14 | Publish only public keys at `jwks_uri`; per-issuer algorithm allowlists; reject `none`; one algorithm per key; check explicit `typ` values. | RFC 7517 §9.2; RFC 8725; rfc8725bis |
| 15 | Validate JWT access tokens as RFC 9068 §4 requires (`typ` `at+jwt`, `iss`, `aud`, signature, `exp`); answer `invalid_token` on failure. | RFC 9068 §4 |
| 16 | Fetch client-supplied URLs (`jwks_uri`, `request_uri`, metadata documents) through an SSRF-safe fetcher. | rfc8725bis §3.10 |

**On TLS versions.** OAuth 2.1 leaves the choice of TLS version to BCP 195 (§1.5).
[RFC 9325](https://www.rfc-editor.org/rfc/rfc9325.html) §3.1.1 says implementations MUST NOT
negotiate TLS 1.0 or 1.1, MUST support TLS 1.2, SHOULD support TLS 1.3, and MUST prefer
TLS 1.3 when they support it. [RFC 9852](https://www.rfc-editor.org/rfc/rfc9852.html)
(July 2026, now also part of BCP 195) goes further for *new* protocols: TLS 1.3 MUST be
the default and TLS 1.2 is only an optional fallback. It also notes that post-quantum work
targets TLS 1.3 and later, not TLS 1.2. OAuth is not a new protocol, so TLS 1.2 is still
allowed. A new server whose clients are all modern can still choose to accept only TLS 1.3.

**The hardening target: FAPI 2.0.** The
[FAPI 2.0 Security Profile](https://openid.net/specs/fapi-security-profile-2_0-final.html)
(Final, 2025-02-22) is a formally analysed set of defaults for a high-security
AS. Its rules include confidential clients only, PAR, PKCE with S256, the `iss`
response parameter, sender-constrained tokens (mTLS or DPoP), client authentication by
mTLS or `private_key_jwt` with the issuer as the only accepted audience, codes
valid for at most 60 seconds, no 307 redirects, PAR `request_uri` lifetimes
under 600 seconds, and no CORS at the authorization endpoint. The YAML already
models most building blocks (PAR, S256, DPoP and `dpop_jkt`, mTLS and endpoint
aliases, `iss`, 303). Choose a profile and make it the default, not an
option: OAuth 2.1 plus RFC 9700 with FAPI-2.0-style defaults (PAR,
sender-constrained tokens, `private_key_jwt` or mTLS). Then offer a strict
"FAPI 2.0 mode" for deployments that can accept its two differences: no public
clients, and no refresh-token rotation except in extraordinary circumstances.
The
[FAPI 2.0 Attacker Model](https://openid.net/specs/fapi-attacker-model-2_0-final.html)
gives the threat model to test against.

---

## 13. Appendix

### 13.1 Data provenance

- **Committed with this audit (after you commit the working tree):** this
  report, [`oauth-rfc-timeline.md`](oauth-rfc-timeline.md), the findings in
  [`rfc-coverage-findings/`](rfc-coverage-findings/README.md), the vendored
  texts, both manifests, and `tools/fetch-specs.sh`.
- **Not committed:** the working data behind the findings — the parsed RFC
  Editor index, the raw coverage and verification results per cluster, the
  research catalogues, the IANA comparison, and the downloaded drafts. They
  lived in a temporary work area. The findings files contain the verified
  evidence for every finding, so you can check each one against the vendored
  text and the YAML.
- **Reproducing the source checks:** run
  `./tools/fetch-specs.sh --check --dir references/rfc-sources --file references/rfc-sources/manifest.txt`
  and the same for `references/oidf-sources`. Exit code 6 means a file is
  missing, differs from upstream, or a newer draft revision exists.

### 13.2 Glossary

**Tiers (§3)**

| Tier | Meaning |
|---|---|
| T1 | RFC published by the IETF OAuth WG |
| T2 | OAuth's origin (RFC 5849) |
| T3 | RFC from another WG that formally updates an OAuth WG RFC |
| T4 | JOSE foundation |
| T5 | OAuth profile defined by another WG for another protocol |
| T6 | Application protocol that consumes OAuth |
| T7 | Infrastructure (URIs, HTTP, language tags, registries) |
| X | Unrelated (shared term or registry, passing mention, or a JWT or JOSE user outside OAuth) |

**YAML coverage levels (§6)**

| Level | Meaning |
|---|---|
| mostly | Most AS-relevant elements are modeled; the findings list what is missing or wrong. |
| partial | Some AS-relevant elements are modeled; important parts are missing or wrong. |
| referenced-only | The YAML cites the document or advertises a field from it, but does not model its operations or rules. |
| none | None of the document's AS-relevant elements is modeled. |
| not-applicable | The document defines nothing that an AS exposes (for example SD-JWT, a credential format). |
| (was X) | The verifier corrected the first assessment, X. |

**Relevance to an AS (§6)**

| Relevance | Meaning |
|---|---|
| required (2.1) | An OAuth 2.1 AS must follow it (OAuth 2.1 itself, or a document it requires). |
| recommended | A modern AS should implement it. |
| optional | Implement it if the use case needs it. |
| informational | Background only. |
| n/a | Not relevant for an AS. |

**Severity and verification (§2, §7)**

| Term | Meaning |
|---|---|
| high / medium / low | Severity, as defined in [§2.3](#23-workflow). |
| confirmed / partially confirmed / refuted | The verifier's verdict on a claim. Partially confirmed findings are published with the correction; "found by the verifier" marks findings the verifier added. |
| re-checked by hand | A high finding that was also confirmed manually against the YAML. |

### 13.3 Abbreviations

ABNF — Augmented Backus-Naur Form ·
ACE — Authentication and Authorization for Constrained Environments ·
`acr` / `amr` — Authentication Context Class Reference / Authentication
Methods References (OIDC claims) ·
AD — Area Director · AS — authorization server · BCP — Best Current Practice ·
CBOR / COSE — Concise Binary Object Representation / CBOR Object Signing and
Encryption · CIBA — Client-Initiated Backchannel Authentication · CORS —
Cross-Origin Resource Sharing · CSP — Content Security Policy · CSRF —
cross-site request forgery · CTA — Consumer Technology Association · CVE —
Common Vulnerabilities and Exposures · DCR — Dynamic Client Registration ·
DPoP — Demonstrating Proof of Possession · DTLS — Datagram Transport Layer
Security · FAPI — Financial-grade API · GNAP — Grant Negotiation and
Authorization Protocol · HOBA — HTTP Origin-Bound Authentication · HPKE —
Hybrid Public Key Encryption · IANA — Internet Assigned Numbers Authority ·
IDA — Identity Assurance · IESG — Internet Engineering Steering Group ·
IETF — Internet Engineering Task Force · IRTF — Internet Research Task Force ·
JAR — JWT-Secured Authorization Request · JARM — JWT Secured Authorization
Response Mode · JOSE — JSON Object Signing and Encryption · JWA / JWE / JWK /
JWS / JWT — JSON Web Algorithms / Encryption / Key / Signature / Token ·
ML-DSA — Module-Lattice-Based Digital Signature Standard · MQTT — Message
Queuing Telemetry Transport · mTLS — mutual Transport Layer Security · NAT —
network address translation · OIDC — OpenID Connect · OIDF — OpenID
Foundation · OSCORE — Object Security for Constrained RESTful Environments ·
PAR — Pushed Authorization Requests · PBES2 / PBKDF2 — Password-Based
Encryption Scheme 2 / Password-Based Key Derivation Function 2 · PKCE — Proof
Key for Code Exchange · RAR — Rich Authorization Requests · RFC — Request for
Comments · RP — relying party · SASL — Simple Authentication and Security
Layer · SCRAM — Salted Challenge Response Authentication Mechanism ·
SD-JWT — Selective Disclosure for JWTs · SET — Security Event Token · SSO —
single sign-on · SSRF — server-side request forgery · TLS — Transport Layer
Security · UMA — User-Managed Access · URI / URL / URN — Uniform Resource
Identifier / Locator / Name · WG — working group.
