# Audit evidence

Analysis and validation evidence for
[`../../oauth-openapi.yaml`](../../oauth-openapi.yaml). These documents record
*why* the spec models what it does and how it was checked — they are not part of
the spec's machine-readable surface.

| File | What it is |
|---|---|
| [`rfc-audit-synthesis.md`](rfc-audit-synthesis.md) | Per-RFC conformance audit of the spec against 20 RFCs / specs (284 findings), with a 2026-06-07 update log. |
| [`live-idp-comparison.md`](live-idp-comparison.md) | The authorization-server metadata schema (`OAuthServerMetadata`) compared against live Google / Microsoft / Auth0 discovery documents. |
| [`community-reference-specs.md`](community-reference-specs.md) | Survey of the two community OAuth OpenAPI specs ([`../ibm-api-connect-oauth.yaml`](../ibm-api-connect-oauth.yaml), [`../ybelenko-oauth2-endpoints.yaml`](../ybelenko-oauth2-endpoints.yaml)) that predate this project. |

Per-RFC validation detail lives in [`../rfc-validation/`](../rfc-validation/).
