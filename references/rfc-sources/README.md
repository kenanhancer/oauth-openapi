# RFC source snapshots

Local copies of every IETF RFC and Internet-Draft used by this project's audit
(see [`../audit/rfc-audit-synthesis.md`](../audit/rfc-audit-synthesis.md)), including every
OAuth working group RFC. OpenID Foundation specifications (which are **not**
RFCs) live separately in [`../oidf-sources/`](../oidf-sources/). Snapshotted
on **2026-05-10** (RFC 8705 and the OAuth 2.1 draft refreshed **2026-05-30** —
the latter bumped from draft-13 to the then-current draft-15; the 17 OAuth WG
RFCs not previously vendored were added **2026-06-06**) so that the spec is
auditable against the **same source text** used to write it, even if upstream
documents are revised, moved, or temporarily unreachable.

## Index

| File | RFC / spec | Source URL | Bytes |
|---|---|---|---|
| `rfc6749.txt` | OAuth 2.0 Authorization Framework | https://www.rfc-editor.org/rfc/rfc6749.txt | 163K |
| `rfc6750.txt` | Bearer Token Usage | https://www.rfc-editor.org/rfc/rfc6750.txt | 39K |
| `rfc6755.txt` | IETF URN Sub-Namespace for OAuth | https://www.rfc-editor.org/rfc/rfc6755.txt | 8K |
| `rfc6819.txt` | OAuth 2.0 Threat Model and Security Considerations | https://www.rfc-editor.org/rfc/rfc6819.txt | 158K |
| `rfc7009.txt` | Token Revocation | https://www.rfc-editor.org/rfc/rfc7009.txt | 24K |
| `rfc7517.txt` | JSON Web Key (JWK) | https://www.rfc-editor.org/rfc/rfc7517.txt | 94K |
| `rfc7519.txt` | JSON Web Token (JWT) | https://www.rfc-editor.org/rfc/rfc7519.txt | 63K |
| `rfc7521.txt` | Assertion Framework for Client Auth & Authz Grants | https://www.rfc-editor.org/rfc/rfc7521.txt | 44K |
| `rfc7522.txt` | SAML 2.0 Profile for Client Auth & Authz Grants | https://www.rfc-editor.org/rfc/rfc7522.txt | 34K |
| `rfc7523.txt` | JWT Profile for OAuth Client Auth & Authz Grants | https://www.rfc-editor.org/rfc/rfc7523.txt | 26K |
| `rfc7591.txt` | Dynamic Client Registration Protocol | https://www.rfc-editor.org/rfc/rfc7591.txt | 88K |
| `rfc7592.txt` | Dynamic Client Registration Management Protocol | https://www.rfc-editor.org/rfc/rfc7592.txt | 38K |
| `rfc7636.txt` | PKCE | https://www.rfc-editor.org/rfc/rfc7636.txt | 39K |
| `rfc7662.txt` | Token Introspection | https://www.rfc-editor.org/rfc/rfc7662.txt | 37K |
| `rfc7800.txt` | Proof-of-Possession Key Semantics for JWTs | https://www.rfc-editor.org/rfc/rfc7800.txt | 34K |
| `rfc8176.txt` | Authentication Method Reference Values | https://www.rfc-editor.org/rfc/rfc8176.txt | 31K |
| `rfc8252.txt` | OAuth 2.0 for Native Apps (BCP 212) | https://www.rfc-editor.org/rfc/rfc8252.txt | 50K |
| `rfc8414.txt` | OAuth 2.0 Authorization Server Metadata | https://www.rfc-editor.org/rfc/rfc8414.txt | 54K |
| `rfc8628.txt` | Device Authorization Grant | https://www.rfc-editor.org/rfc/rfc8628.txt | 47K |
| `rfc8693.txt` | Token Exchange | https://www.rfc-editor.org/rfc/rfc8693.txt | 63K |
| `rfc8705.txt` | OAuth 2.0 Mutual-TLS Client Auth & Certificate-Bound Access Tokens | https://www.rfc-editor.org/rfc/rfc8705.txt | 59K |
| `rfc8707.txt` | Resource Indicators | https://www.rfc-editor.org/rfc/rfc8707.txt | 26K |
| `rfc8725.txt` | JSON Web Token Best Current Practices (BCP 225) | https://www.rfc-editor.org/rfc/rfc8725.txt | 31K |
| `rfc9068.txt` | JWT Profile for OAuth 2.0 Access Tokens | https://www.rfc-editor.org/rfc/rfc9068.txt | 35K |
| `rfc9101.txt` | JWT-Secured Authorization Request (JAR) | https://www.rfc-editor.org/rfc/rfc9101.txt | 58K |
| `rfc9126.txt` | Pushed Authorization Requests (PAR) | https://www.rfc-editor.org/rfc/rfc9126.txt | 44K |
| `rfc9207.txt` | Authorization Server Issuer Identification | https://www.rfc-editor.org/rfc/rfc9207.txt | 20K |
| `rfc9278.txt` | JWK Thumbprint URI | https://www.rfc-editor.org/rfc/rfc9278.txt | 10K |
| `rfc9396.txt` | Rich Authorization Requests (RAR) | https://www.rfc-editor.org/rfc/rfc9396.txt | 66K |
| `rfc9449.txt` | DPoP — Demonstrating Proof of Possession | https://www.rfc-editor.org/rfc/rfc9449.txt | 92K |
| `rfc9470.txt` | Step Up Authentication Challenge Protocol | https://www.rfc-editor.org/rfc/rfc9470.txt | 34K |
| `rfc9700.txt` | OAuth 2.0 Security Best Current Practice (BCP 240) | https://www.rfc-editor.org/rfc/rfc9700.txt | 125K |
| `rfc9701.txt` | JWT Response for OAuth Token Introspection | https://www.rfc-editor.org/rfc/rfc9701.txt | 28K |
| `rfc9728.txt` | OAuth 2.0 Protected Resource Metadata | https://www.rfc-editor.org/rfc/rfc9728.txt | 60K |
| `rfc9901.txt` | Selective Disclosure for JWTs (SD-JWT) | https://www.rfc-editor.org/rfc/rfc9901.txt | 177K |
| `draft-ietf-oauth-v2-1.txt` | OAuth 2.1 (active draft, snapshot -15) | https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/ | 224K |

**Total: 36 documents, ~2.2 MB.**

> The 17 RFCs added on **2026-06-06** (6755, 6819, 7521, 7522, 7591, 7592, 7800,
> 8176, 8252, 8725, 9101, 9207, 9278, 9470, 9701, 9728, 9901) complete the set of
> OAuth working group RFCs. They are vendored as source text but do **not** yet
> have corresponding [`../rfc-validation/`](../rfc-validation/) audit files.

## Refreshing the snapshots

```bash
cd references/rfc-sources

# Plain RFCs from rfc-editor.org
for n in 6749 6750 6755 6819 7009 7517 7519 7521 7522 7523 7591 7592 7636 \
         7662 7800 8176 8252 8414 8628 8693 8705 8707 8725 9068 9101 9126 \
         9207 9278 9396 9449 9470 9700 9701 9728 9901; do
  curl -sfL "https://www.rfc-editor.org/rfc/rfc${n}.txt" -o "rfc${n}.txt"
done

# OAuth 2.1 active draft — raw text; bump -NN to the current revision (check datatracker)
curl -sfL "https://www.ietf.org/archive/id/draft-ietf-oauth-v2-1-15.txt" -o draft-ietf-oauth-v2-1.txt

# OpenID Foundation specs now live in ../oidf-sources/ (see that folder's README)
```

## Why these are committed

The earlier audit (commit `7816b0c`) ran 20 parallel agents to compare the spec
against each RFC. Most agents had `WebFetch` denied in their sandbox and worked
from training-data knowledge of the (stable) specs. Committing these snapshots:

- Provides a **canonical source text** so anyone re-running the audit measures
  against the same bytes.
- Survives upstream availability problems (datatracker maintenance windows,
  RFC reformatting, OpenID Foundation site reorganization).
- Lets future audits cite specific section numbers with confidence that the
  reader can resolve them locally without an internet round-trip.

## Licensing

- IETF RFCs are published under the [IETF Trust LCC](https://trustee.ietf.org/license-info/);
  unrestricted reproduction is permitted.
- OpenID Foundation specs are published under the
  [OpenID Foundation IPR Policy](https://openid.net/intellectual-property/) — likewise
  unrestricted for reference distribution.
