# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## What this repo is

`rdp-model` (dbt project name `rtl_rdp`) is the RDP product — the canonical
data model, transformations, and BI-facing views. It is published as a dbt
package and installed by customers via `dbt deps`. It must never import or
depend on `rdp-client`.

## Key documents

- `CONTRACT.md` — staging contract customers must implement
- `STYLE_GUIDE.md` — SQL and dbt coding standards
- `DATA_MODEL.md` — canonical data model index
- `docs/glossary/` — subject-area glossaries (e.g. `products.md`), assembled into customer-facing sites at build time
- `CONTRIBUTING.md` — folder conventions, tool choices, adding a component

## Commands

```bash
dbt deps          # Install packages
dbt compile       # Compile SQL without executing
dbt run           # Run all models
dbt test          # Run all data quality tests
dbt docs generate # Generate documentation
```

> Note: this repo's `.claude/settings.local.json` only permits `dbt compile` by default.

## Where other content lives

- **`../rdp-docs/`** — ecosystem overview, architecture decisions, ecosystem-level glossary, design principles
- **`../rdp-client/`** — customer implementation, dbt getting-started
- **`../rdp-platform/`** — shared tooling used to build each customer's documentation site
