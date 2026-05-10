---
description: Run Spectral lint on oauth-openapi.yaml
allowed-tools: Bash
---

Run Spectral lint on `oauth-openapi.yaml` using the project's `.spectral.yaml`
ruleset (which extends `spectral:oas`).

Command:

```bash
npx --yes @stoplight/spectral-cli lint oauth-openapi.yaml
```

Report the result:

- If 0 errors and 0 warnings → confirm "Spec is clean."
- If errors → list them with file:line and one-line explanation each. Suggest
  the most likely fix (consult `CLAUDE.md` § "Spec-change workflow" for
  guidance on `oas3-unused-component` warnings).
- If only warnings → list them but do not fail; note they should be addressed
  before the next commit per `CLAUDE.md`.
