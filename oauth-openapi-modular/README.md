# oauth-openapi (modular, standalone)

A **multi-file** decomposition of `../oauth-openapi.yaml`, kept entirely
separate so the original single-file spec stays the source of truth and is
untouched. Review this, then decide whether to adopt the layout.

## How it is produced

Generated mechanically from `../oauth-openapi.yaml` by `split-oauth-openapi.py`,
then **verified data-identical to the source** (every schema, path, parameter,
response, header, security scheme and field compared 1:1 after re-assembly).

```bash
python3 split-oauth-openapi.py   # regenerate this tree from ../oauth-openapi.yaml
```

> The split preserves all *data* (descriptions, `externalDocs`, enums, examples)
> but drops YAML `#` comments (the `# ===` banners and inline `# RFC ...` notes).
> Re-running `split-oauth-openapi.py` OVERWRITES the tree — only do so while the single-file
> spec is the source of truth.

## Layout

```
openapi.yaml                       root: info/servers/tags + $ref wiring
spec/
  paths/                           one file per endpoint (well-known grouped)
  components/
    parameters.yaml headers.yaml responses.yaml security-schemes.yaml
    schemas/                       schemas grouped by domain
```

`$ref`s are relative file references (OpenAPI 3.1). The root `components` block
keeps every component addressable by name, so `security` requirements and
tooling resolve correctly.

## Use it

```bash
./bundle.sh        # bundle -> dist/oauth-openapi.bundled.yaml, then lint
```

Most viewers / generators want a single file: bundle first, then point
Redoc / Swagger UI / openapi-generator at `dist/oauth-openapi.bundled.yaml`.

Lint via `./bundle.sh` (it lints the bundled output, which must match the
single-file spec's result: 0 errors / 0 warnings). Don't lint the multi-file
root directly: Spectral's OAS 3.1 schema check reports false-positive
"unevaluated properties" errors on external path-level `$ref`s and flags
every root re-export stub as an unused component.
