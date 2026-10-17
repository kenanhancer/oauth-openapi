# Audit evidence

Analysis and validation evidence for
[`../../oauth-openapi.yaml`](../../oauth-openapi.yaml). These documents record
*why* the spec models what it does and how it was checked — they are not part of
the spec's machine-readable surface.

| File | What it is |
|---|---|
| [`oauth-rfc-timeline.md`](oauth-rfc-timeline.md) | **Start here to learn.** OAuth from its 2006 origins to October 2026: the eras, why each extension exists, abandoned approaches, every vendored RFC on one timeline, and a staged reading path through `../rfc-sources/`. |
| [`rfc-coverage-audit.md`](rfc-coverage-audit.md) | **2026-10 audit.** Every OAuth-related RFC (catalogued from the RFC Editor index, Datatracker and IANA) compared with this repository: what is vendored and why, how well the spec models each document, OAuth 2.1 draft-16 impact, the draft pipeline, OpenID Foundation specs, folder health, and a prioritized roadmap. |
| [`rfc-coverage-findings/`](rfc-coverage-findings/) | The 724 independently verified findings behind the 2026-10 audit, one file per cluster of related documents. |
| [`rfc-audit-synthesis.md`](rfc-audit-synthesis.md) | The first (May 2026) per-RFC conformance audit of the spec against 20 RFCs / specs (284 findings), with a 2026-06-07 update log. |
| [`live-idp-comparison.md`](live-idp-comparison.md) | The authorization-server metadata schema (`OAuthServerMetadata`) compared against live Google / Microsoft / Auth0 discovery documents. |
| [`community-reference-specs.md`](community-reference-specs.md) | Survey of the two community OAuth OpenAPI specs ([`../ibm-api-connect-oauth.yaml`](../ibm-api-connect-oauth.yaml), [`../ybelenko-oauth2-endpoints.yaml`](../ybelenko-oauth2-endpoints.yaml)) that predate this project. |

Per-RFC validation detail from the May 2026 audit lives in
[`../rfc-validation/`](../rfc-validation/); its YAML line numbers predate later
spec changes — the 2026-10 findings supersede it where they overlap.
