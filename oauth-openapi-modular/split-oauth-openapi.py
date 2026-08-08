#!/usr/bin/env python3
"""Generate this multi-file (modular) OpenAPI layout from the single-file source.

Reads ``../oauth-openapi.yaml`` (the source of truth) and splits it into this
folder's ``openapi.yaml`` + ``spec/`` tree, rewriting every ``$ref`` (and every
``discriminator.mapping`` value) into a relative file reference. It then
re-assembles the split files in memory and asserts the result is data-identical
to the source — so the split is provably lossless.

Usage:
    python3 split-oauth-openapi.py   # run from anywhere; paths derive from __file__

Notes:
  * OVERWRITES openapi.yaml, spec/**, README.md, bundle.sh and .spectral.yaml in
    this folder. Only run while ``../oauth-openapi.yaml`` is the source of truth.
    If you ADOPT this modular layout (i.e. start editing spec/** by hand), STOP
    running this script — it would clobber those edits.
  * The mechanical split preserves all *data* (descriptions, externalDocs, enums,
    examples) but drops YAML ``#`` comments (the ``# ===`` banners and inline
    ``# RFC ...`` notes). Re-curate those if the layout is adopted.
  * Only requires PyYAML. The file/domain grouping lives in SCHEMA_GROUP /
    PATH_FILE below — edit those to reshape the split.
"""
import json
import os
import posixpath
import shutil

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(os.path.dirname(HERE), 'oauth-openapi.yaml')
OUT = HERE
ROOT_FILE = 'openapi.yaml'  # relative to OUT

# ---- which schema goes in which file under spec/components/schemas/ ----
SCHEMA_GROUP = {
    'token-requests': ['TokenRequest', 'ClientAuthFields', 'ResourceIndicators',
                       'AuthorizationDetailsField', 'AuthorizationCodeTokenRequest',
                       'ClientCredentialsTokenRequest', 'RefreshTokenRequest',
                       'DeviceCodeTokenRequest', 'JWTBearerTokenRequest',
                       'TokenExchangeRequest', 'TokenTypeURI'],
    'token-responses': ['TokenResponse', 'ErrorResponse'],
    'introspection': ['IntrospectionRequest', 'IntrospectionResponse',
                      'JWTIntrospectionResponse', 'RevocationRequest'],
    'device': ['DeviceAuthorizationRequest', 'DeviceAuthorizationResponse'],
    'par': ['PARRequest', 'PARResponse'],
    'metadata': ['OpenIDProviderMetadata', 'OAuthServerMetadata', 'ProtectedResourceMetadata'],
    'userinfo': ['UserInfoResponse', 'UserInfoSignedResponse'],
    'jose': ['JWT', 'JWKS', 'JWK', 'StringOrURI', 'NumericDate'],
    'claims': ['IDTokenClaims', 'JWTAccessTokenClaims', 'Confirmation'],
    'rar': ['AuthorizationDetail'],
}
# ---- which path goes in which file (fragment = None means whole-file ref) ----
PATH_FILE = {
    '/authorize': ('spec/paths/authorize.yaml', None),
    '/token': ('spec/paths/token.yaml', None),
    '/revoke': ('spec/paths/revoke.yaml', None),
    '/introspect': ('spec/paths/introspect.yaml', None),
    '/device_authorization': ('spec/paths/device-authorization.yaml', None),
    '/par': ('spec/paths/par.yaml', None),
    '/userinfo': ('spec/paths/userinfo.yaml', None),
    '/jwks': ('spec/paths/jwks.yaml', None),
    '/.well-known/openid-configuration': ('spec/paths/well-known.yaml', 'openidConfiguration'),
    '/.well-known/oauth-authorization-server': ('spec/paths/well-known.yaml', 'oauthAuthorizationServer'),
    '/.well-known/oauth-protected-resource': ('spec/paths/well-known.yaml', 'oauthProtectedResource'),
}
CAT_FILE = {
    'parameters': 'spec/components/parameters.yaml',
    'headers': 'spec/components/headers.yaml',
    'responses': 'spec/components/responses.yaml',
    'securitySchemes': 'spec/components/security-schemes.yaml',
}


# ---- YAML dumping: block style for multi-line strings, preserve key order ----
class Dumper(yaml.SafeDumper):
    pass


def _str_rep(d, data):
    style = '|' if '\n' in data else None
    return d.represent_scalar('tag:yaml.org,2002:str', data, style=style)


Dumper.add_representer(str, _str_rep)


def dump_yaml(obj):
    return yaml.dump(obj, Dumper=Dumper, sort_keys=False, allow_unicode=True,
                     default_flow_style=False, width=1000000)


doc = yaml.safe_load(open(SRC))
comp = doc['components']

schema_file = {}
for grp, names in SCHEMA_GROUP.items():
    for n in names:
        schema_file[n] = 'spec/components/schemas/%s.yaml' % grp

name_cat = {}
for cat, items in comp.items():
    for name in items:
        name_cat[name] = cat

# ---- safety assertions: nothing unmapped, every ref is a component ref ----
unmapped_sch = [n for n in comp.get('schemas', {}) if n not in schema_file]
assert not unmapped_sch, 'Unmapped schemas: %s' % unmapped_sch
unmapped_paths = [p for p in doc['paths'] if p not in PATH_FILE]
assert not unmapped_paths, 'Unmapped paths: %s' % unmapped_paths

allrefs = []
def collect(node):
    if isinstance(node, dict):
        for k, v in node.items():
            if k == '$ref' and isinstance(v, str):
                allrefs.append(v)
            else:
                collect(v)
    elif isinstance(node, list):
        for x in node:
            collect(x)
collect(doc)
bad = sorted({r for r in allrefs if not r.startswith('#/components/')})
assert not bad, 'Non-component refs found: %s' % bad


def file_of(cat, name):
    return schema_file[name] if cat == 'schemas' else CAT_FILE[cat]


def ext_ref(ref, src_rel):
    """Turn '#/components/<cat>/<Name>' into a relative file ref from src_rel."""
    parts = ref[2:].split('/')
    cat, name = parts[1], '/'.join(parts[2:])
    rel = posixpath.relpath(file_of(cat, name), posixpath.dirname(src_rel))
    return '%s#/%s' % (rel, name)


def rewrite(node, src_rel):
    """Recursively rewrite internal refs (and discriminator mappings) to externals."""
    if isinstance(node, dict):
        out = {}
        for k, v in node.items():
            if k == '$ref' and isinstance(v, str) and v.startswith('#/components/'):
                out[k] = ext_ref(v, src_rel)
            elif k == 'discriminator' and isinstance(v, dict):
                d = dict(v)
                m = d.get('mapping')
                if isinstance(m, dict):
                    d['mapping'] = {mk: (ext_ref(mv, src_rel)
                                         if isinstance(mv, str) and mv.startswith('#/components/')
                                         else mv)
                                    for mk, mv in m.items()}
                out[k] = d
            else:
                out[k] = rewrite(v, src_rel)
        return out
    if isinstance(node, list):
        return [rewrite(x, src_rel) for x in node]
    return node


files = {}  # rel path -> object to dump

# component schema files (grouped by domain)
for name, schema in comp.get('schemas', {}).items():
    rel = schema_file[name]
    files.setdefault(rel, {})[name] = rewrite(schema, rel)
# other component categories (one file each)
for cat in ('parameters', 'headers', 'responses', 'securitySchemes'):
    if cat in comp:
        rel = CAT_FILE[cat]
        files[rel] = {name: rewrite(v, rel) for name, v in comp[cat].items()}

# path files (well-known endpoints share one file via fragment keys)
path_ref = {}
wk_rel, wk = None, {}
for path, item in doc['paths'].items():
    rel, frag = PATH_FILE[path]
    ritem = rewrite(item, rel)
    if frag is None:
        files[rel] = ritem
        path_ref[path] = rel
    else:
        wk_rel, wk[frag] = rel, ritem
        path_ref[path] = '%s#/%s' % (rel, frag)
if wk_rel:
    files[wk_rel] = wk

# root file: metadata verbatim + $ref wiring for paths and the full component map
root = {}
for k in ('openapi', 'info', 'externalDocs', 'servers', 'tags'):
    if k in doc:
        root[k] = doc[k]
root['paths'] = {p: {'$ref': './' + r} for p, r in path_ref.items()}
root['components'] = {}
for cat, items in comp.items():
    root['components'][cat] = {name: {'$ref': './%s#/%s' % (file_of(cat, name), name)}
                              for name in items}


def write(rel, text):
    p = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, 'w').write(text)


write(ROOT_FILE, dump_yaml(root))
for rel, obj in files.items():
    write(rel, dump_yaml(obj))

# keep the standalone folder self-contained: copy the lint ruleset alongside
src_ruleset = os.path.join(os.path.dirname(HERE), '.spectral.yaml')
if os.path.exists(src_ruleset):
    shutil.copy(src_ruleset, os.path.join(OUT, '.spectral.yaml'))

# ---- README + bundle.sh (regenerated so the folder is always complete) ----
write('README.md', """# oauth-openapi (modular, standalone)

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
""")

write('bundle.sh', """#!/usr/bin/env bash
# Bundle the multi-file spec into a single distributable file, then lint it.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p dist
npx -y @redocly/cli@latest bundle openapi.yaml -o dist/oauth-openapi.bundled.yaml
npx -y @stoplight/spectral-cli@latest lint dist/oauth-openapi.bundled.yaml
echo "OK -> dist/oauth-openapi.bundled.yaml"
""")
os.chmod(os.path.join(OUT, 'bundle.sh'), 0o755)

# ================= VERIFY: re-assemble from written files, compare to source ===
def load(rel):
    return yaml.safe_load(open(os.path.join(OUT, rel)))


def back_ref(rv):
    nm = rv.split('#/', 1)[1]
    return '#/components/%s/%s' % (name_cat[nm], nm)


def denorm(node):
    if isinstance(node, dict):
        out = {}
        for k, v in node.items():
            if k == '$ref' and isinstance(v, str) and not v.startswith('#/'):
                out[k] = back_ref(v)
            elif k == 'discriminator' and isinstance(v, dict):
                d = dict(v)
                m = d.get('mapping')
                if isinstance(m, dict):
                    d['mapping'] = {mk: (back_ref(mv)
                                         if isinstance(mv, str) and '#/' in mv and not mv.startswith('#/')
                                         else mv)
                                    for mk, mv in m.items()}
                out[k] = d
            else:
                out[k] = denorm(v)
        return out
    if isinstance(node, list):
        return [denorm(x) for x in node]
    return node


recon_comp = {}
for cat, items in comp.items():
    recon_comp[cat] = {name: denorm(load(file_of(cat, name))[name]) for name in items}

rootf = load(ROOT_FILE)
recon_paths = {}
for path, refobj in rootf['paths'].items():
    rel = refobj['$ref'][2:]  # strip leading './'
    if '#/' in rel:
        fp, frag = rel.split('#/', 1)
        item = load(fp)[frag]
    else:
        item = load(rel)
    recon_paths[path] = denorm(item)


def J(o):
    return json.dumps(o, sort_keys=True, ensure_ascii=False)


ok = True
for k in ('openapi', 'info', 'externalDocs', 'servers', 'tags'):
    if J(rootf.get(k)) != J(doc.get(k)):
        ok = False
        print('  MISMATCH top-level:', k)
if J(recon_comp) != J(comp):
    ok = False
    for cat in comp:
        for name in comp[cat]:
            if J(recon_comp[cat][name]) != J(comp[cat][name]):
                print('  MISMATCH component:', cat, name)
if J(recon_paths) != J(doc['paths']):
    ok = False
    for p in doc['paths']:
        if J(recon_paths[p]) != J(doc['paths'][p]):
            print('  MISMATCH path:', p)

print('--- wrote %d spec files + README.md + bundle.sh (+ .spectral.yaml) ---' % (len(files) + 1))
print('VERIFY:', 'PASS - modular spec is data-identical to the source' if ok
      else 'FAIL - see mismatches above')
