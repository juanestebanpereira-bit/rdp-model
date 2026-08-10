# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## What this repo is

`rdp-model` (dbt project name `rtl_rdp`) is the RDP product — the canonical
data model, transformations, and BI-facing views. It is published as a dbt
package and installed by customers via `dbt deps`. It must never import or
depend on `rdp-client`.

## Key documents

- `contract.md` — staging contract customers must implement
- `style-guide.md` — SQL and dbt coding standards
- `data-model.md` — what the canonical data model is, conceptually
- `docs/components.md` — catalog of subject areas and components, with implementation status
- `CONTRIBUTING.md` — folder conventions, tool choices, adding a component

## Commands

```bash
dbt deps          # Install packages
dbt compile       # Compile SQL without executing
dbt run           # Run all models
dbt test          # Run all data quality tests
dbt docs generate # Generate manifest.json/catalog.json (NOT the customer site — see below)
```

This alone never updates the customer site — see
[rdp-platform/README.md](../rdp-platform/README.md), "Common commands:
dbt model → customer site", for the full sequence.

> Note: this repo's `.claude/settings.local.json` only permits `dbt compile` by default.

## Where other content lives

- **`../rdp-docs/`** — ecosystem overview, architecture decisions, ecosystem-level glossary, design principles
- **`../rdp-client/`** — customer implementation, dbt getting-started
- **`../rdp-platform/`** — shared tooling used to build each customer's documentation site
