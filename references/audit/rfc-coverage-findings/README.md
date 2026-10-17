# RFC coverage findings — 2026-10 audit

Per-cluster, independently verified findings behind
[`../rfc-coverage-audit.md`](../rfc-coverage-audit.md).

**How these were produced.** For each cluster of related documents, one agent read the
document text (from `../../rfc-sources/` and `../../oidf-sources/`) and compared every
normative protocol element against `oauth-openapi.yaml` (commit `3e712d7`). A second,
independent agent then tried to refute every claimed gap or error against the YAML and the
document text, re-assessed its severity, and hunted for misses. Of 615 claims, 535 were
confirmed, 80 partially confirmed (shown with the verifier's correction) and 0 refuted;
the verifiers added 109 findings of their own (marked *found by the verifier*).

**Severity.** *High* — a server generated from the YAML would violate a MUST or miss a core
element. *Medium* — SHOULD-level or commonly used optional element. *Low* — documentation
or precision.

**Point in time.** The findings describe the repository at the start of the audit
(2026-10-10). YAML line numbers refer to `oauth-openapi.yaml` at commit `3e712d7`; the audit
did not change the YAML, so they still match. The audit then vendored 15 RFCs and 7 OpenID
Foundation specs and replaced OAuth 2.1 draft -15 with -16
([audit §4](../rfc-coverage-audit.md#4-what-this-audit-changed)). Where a note says a
document is "not vendored" and that has since changed, it carries an *(Update 2026-10-11: …)*
remark. Scripts and downloads that the notes mention were scratch work and are not kept in
the repository.

**The IANA absence list** is the audit's list of IANA-registered values (OAuth Parameters,
JWT, JOSE, Well-Known URIs and HTTP Authentication Schemes registries) that do not appear in
the YAML — see [audit §8](../rfc-coverage-audit.md#8-iana-registry-coverage). It matches
whole words, so a value can count as present when the same word appears in unrelated text.

| Cluster | Documents | High | Medium | Low |
|---|---|---|---|---|
| [OAuth 2.0 core — RFC 6749](core-6749.md) | 1 | 1 | 11 | 28 |
| [Bearer tokens & HTTP authentication — RFC 6750, 8996, 7617, 9110](bearer-http.md) | 4 | 0 | 6 | 23 |
| [OAuth 2.1 — draft-ietf-oauth-v2-1-16](oauth21.md) | 1 | 3 | 8 | 36 |
| [Revocation & introspection — RFC 7009, 7662, 9701](revocation-introspection.md) | 3 | 0 | 16 | 19 |
| [JWT & JWT best practices — RFC 7519, 7797, 8725, rfc8725bis](jwt.md) | 4 | 0 | 11 | 22 |
| [JOSE core — RFC 7515, 7516, 7517, 7518, 7638, 8037, 9864, 9964, 8812, 7520](jose.md) | 10 | 2 | 9 | 33 |
| [Assertion framework & profiles — RFC 7521, 7522, 7523, rfc7523bis](assertions.md) | 4 | 2 | 9 | 19 |
| [Dynamic Client Registration — RFC 7591, 7592, OIDC Registration 1.0](dcr.md) | 3 | 6 | 19 | 19 |
| [PKCE, native apps & browser-based apps — RFC 7636, 8252, 10017](pkce-apps.md) | 3 | 3 | 7 | 20 |
| [Metadata & discovery — RFC 8414, 9728, 6755, 8615, 3986](metadata.md) | 5 | 0 | 5 | 37 |
| [Device grant & cross-device security — RFC 8628, 10027](device-crossdevice.md) | 2 | 0 | 6 | 24 |
| [Token exchange, AMR & Vectors of Trust — RFC 8693, 8176, 8485](token-exchange.md) | 3 | 0 | 4 | 18 |
| [Sender-constrained tokens — RFC 8705, 9449, 7800, 9278, 9440, 9421](pop.md) | 6 | 2 | 8 | 30 |
| [Resource indicators, RAR & step-up — RFC 8707, 9396, 9470](resource-rar-stepup.md) | 3 | 0 | 7 | 22 |
| [JWT access tokens & SD-JWT — RFC 9068, 9901, SD-JWT VC, Token Status List](jwt-at-sdjwt.md) | 4 | 1 | 4 | 22 |
| [JAR, PAR & issuer identification — RFC 9101, 9126, 9207](jar-par-iss.md) | 3 | 1 | 14 | 21 |
| [Security guidance — RFC 6819, RFC 9700, security-topics-update](security.md) | 3 | 4 | 12 | 20 |
| [OAuth 1.0 — RFC 5849](oauth1-origin.md) *(catalogue — informational)* | 1 | 0 | 0 | 0 |
| [OpenID Connect & OIDF response-mode / session / logout / CIBA specs](oidc.md) | 11 | 4 | 30 | 61 |
| [OAuth-adjacent families — SECEVENT, SASL, GNAP, Token Binding and others](adjacent-families.md) *(catalogue — informational)* | 18 | 0 | 1 | 5 |
| [ACE — OAuth 2.0 for constrained (IoT) environments](adjacent-ace.md) *(catalogue — informational)* | 15 | 0 | 0 | 29 |
| **Total** | | **29** | **187** | **508** |

In-scope clusters (excluding the catalogue clusters): **29 high, 186 medium, 474 low.**

