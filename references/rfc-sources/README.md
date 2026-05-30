# RFC source snapshots

Local copies of every IETF RFC and OpenID specification used by this project's
audit (see [`../RFC_AUDIT_SYNTHESIS.md`](../RFC_AUDIT_SYNTHESIS.md)). Snapshotted
on **2026-05-10** (RFC 8705 and the OAuth 2.1 draft refreshed **2026-05-30** —
the latter bumped from draft-13 to the then-current draft-15) so that the spec is
auditable against the **same source text** used to write it, even if upstream
documents are revised, moved, or temporarily unreachable.

## Index

| File | RFC / spec | Source URL | Bytes |
|---|---|---|---|
| `rfc6749.txt` | OAuth 2.0 Authorization Framework | https://www.rfc-editor.org/rfc/rfc6749.txt | 163K |
| `rfc6750.txt` | Bearer Token Usage | https://www.rfc-editor.org/rfc/rfc6750.txt | 39K |
| `rfc7009.txt` | Token Revocation | https://www.rfc-editor.org/rfc/rfc7009.txt | 24K |
| `rfc7517.txt` | JSON Web Key (JWK) | https://www.rfc-editor.org/rfc/rfc7517.txt | 94K |
| `rfc7519.txt` | JSON Web Token (JWT) | https://www.rfc-editor.org/rfc/rfc7519.txt | 63K |
| `rfc7523.txt` | JWT Profile for OAuth Client Auth & Authz Grants | https://www.rfc-editor.org/rfc/rfc7523.txt | 26K |
| `rfc7636.txt` | PKCE | https://www.rfc-editor.org/rfc/rfc7636.txt | 39K |
| `rfc7662.txt` | Token Introspection | https://www.rfc-editor.org/rfc/rfc7662.txt | 37K |
| `rfc8414.txt` | OAuth 2.0 Authorization Server Metadata | https://www.rfc-editor.org/rfc/rfc8414.txt | 54K |
| `rfc8628.txt` | Device Authorization Grant | https://www.rfc-editor.org/rfc/rfc8628.txt | 47K |
| `rfc8693.txt` | Token Exchange | https://www.rfc-editor.org/rfc/rfc8693.txt | 63K |
| `rfc8705.txt` | OAuth 2.0 Mutual-TLS Client Auth & Certificate-Bound Access Tokens | https://www.rfc-editor.org/rfc/rfc8705.txt | 59K |
| `rfc8707.txt` | Resource Indicators | https://www.rfc-editor.org/rfc/rfc8707.txt | 26K |
| `rfc9068.txt` | JWT Profile for OAuth 2.0 Access Tokens | https://www.rfc-editor.org/rfc/rfc9068.txt | 35K |
| `rfc9126.txt` | Pushed Authorization Requests (PAR) | https://www.rfc-editor.org/rfc/rfc9126.txt | 44K |
| `rfc9396.txt` | Rich Authorization Requests (RAR) | https://www.rfc-editor.org/rfc/rfc9396.txt | 66K |
| `rfc9449.txt` | DPoP — Demonstrating Proof of Possession | https://www.rfc-editor.org/rfc/rfc9449.txt | 92K |
| `rfc9700.txt` | OAuth 2.0 Security Best Current Practice (BCP 240) | https://www.rfc-editor.org/rfc/rfc9700.txt | 125K |
| `draft-ietf-oauth-v2-1.txt` | OAuth 2.1 (active draft, snapshot -15) | https://datatracker.ietf.org/doc/draft-ietf-oauth-v2-1/ | 224K |
| `oidc-core-1.0.html` | OpenID Connect Core 1.0 | https://openid.net/specs/openid-connect-core-1_0.html | 437K |
| `oidc-discovery-1.0.html` | OpenID Connect Discovery 1.0 | https://openid.net/specs/openid-connect-discovery-1_0.html | 109K |

**Total: 21 documents, ~1.9 MB.**

## Refreshing the snapshots

```bash
cd references/rfc-sources

# Plain RFCs from rfc-editor.org
for n in 6749 6750 7009 7517 7519 7523 7636 7662 8414 8628 8693 8705 8707 \
         9068 9126 9396 9449 9700; do
  curl -sfL "https://www.rfc-editor.org/rfc/rfc${n}.txt" -o "rfc${n}.txt"
done

# OAuth 2.1 active draft — raw text; bump -NN to the current revision (check datatracker)
curl -sfL "https://www.ietf.org/archive/id/draft-ietf-oauth-v2-1-15.txt" -o draft-ietf-oauth-v2-1.txt

# OpenID specs
curl -sfL "https://openid.net/specs/openid-connect-core-1_0.html"      -o oidc-core-1.0.html
curl -sfL "https://openid.net/specs/openid-connect-discovery-1_0.html" -o oidc-discovery-1.0.html
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
