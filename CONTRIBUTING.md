# Contributing to RDP

This document is for developers working on the RDP platform itself.
For customer implementation guidance, see `CONTRACT.md`.

---

## Project Structure

RDP spans four independent git repositories, siblings under `~/projects/`
(not nested inside one another):

```
~/projects/
├── rdp-model/       # RDP product — published as a dbt package (this repo)
├── rdp-client/      # Customer implementation — maps source data to the RDP contract
├── rdp-platform/    # Shared tooling — merge_manifests.py, ERD/lineage generation
└── rdp-docs/        # Ecosystem overview, architecture decisions, glossary, principles
```

See [rdp-docs/README.md](../rdp-docs/README.md) for the full ecosystem picture.

The two-project split between `rdp-model` and `rdp-client` is intentional:
`rtl_rdp` is the product, `rtl_rdp_client` is a reference customer
implementation. Customers install `rtl_rdp` as a dbt package and implement
their own `rtl_rdp_client`. This means `rtl_rdp` must never import or
depend on `rtl_rdp_client`.

### Four separate git repositories

`rdp-model`, `rdp-client`, `rdp-platform`, and `rdp-docs` are **four
independent git repositories**. This is intentional:

- `rdp-model` has its own release cycle and is versioned independently as a
  distributed dbt package — its commits must not be coupled to any customer implementation
- `rdp-client` is a reference implementation that customers fork — it must
  remain independent of the product repo
- `rdp-platform` owns the shared tooling (`merge_manifests.py`, ERD/lineage
  generation via dbterd and colibri) used to build each customer's
  documentation site
- `rdp-docs` owns ecosystem-level documentation

Always be explicit about which repo you are committing to:

```bash
git -C ../rdp-client status
git -C ../rdp-platform status
git status          # this repo (rdp-model)
```

---

## Folder Conventions

### Models are organised by subject area and component

Both projects follow the same nesting inside `models/`:

```
models/
└── {layer}/
    └── {subject_area}/
        └── {component}/
            ├── schema.yml
            └── *.sql
```

For example:
```
rtl_rdp/models/dwh/products/product_hierarchy/
rtl_rdp_client/models/staging/products/product_hierarchy/
```

All new models must follow this structure. Never place model files at the subject area level
or above.

### Doc blocks follow different conventions in each project

dbt doc blocks are defined in `.md` files and referenced from `schema.yml` via
`{{ doc('block_name') }}`. The two projects use different conventions due to a
dbt package constraint:

**`rtl_rdp` (published as a package):**
Doc block files live flat inside `models/` with a `docs__` prefix:
```
rtl_rdp/models/docs__product_hierarchy.md
rtl_rdp/models/docs__rdp_system_columns.md
```
A `docs/` subdirectory cannot be used here because dbt does not deploy subdirectory
doc files when a project is installed as a package. The `docs__` prefix is the
established workaround to make the purpose clear.

**`rtl_rdp_client` (not a package):**
Doc block files are co-located with the component they belong to:
```
rtl_rdp_client/models/staging/products/product_hierarchy/docs.md
```
This is preferred over the `docs__` workaround because `rtl_rdp_client` is never
installed as a package, so the constraint does not apply.

---

## Tool Choices

| Tool | Purpose | Why |
|---|---|---|
| **dbt docs** | Data dictionary — column descriptions, model documentation | Native to dbt; descriptions defined in `schema.yml` and doc blocks flow through automatically |
| **dbterd** | ERD — entity relationship diagrams with PK/FK relationships | Reads dbt constraints (`model_contract` algorithm) rather than tests; produces accurate structural diagrams |
| **colibri** | Lineage — cross-project node-level lineage visualisation | Handles cross-project lineage across `rtl_rdp` and `rtl_rdp_client` which dbt docs cannot do natively |

All three serve distinct purposes and none replaces the others.

The merged manifest (`merge_manifests.py`) is required because dbterd and colibri need a
single combined artifact that spans both projects. Running `dbt docs generate` in each
project separately produces two independent manifests — `merge_manifests.py` combines them
into a single `manifest.json` and `catalog.json` in `build/` before ERD and lineage
generation runs.

---

## Implementation Reference

### Layer → Schema Mapping

Each layer materializes into a BigQuery dataset prefixed with the target environment (`dev`, `tst`, `prd`) via the `generate_schema_name` macro:

| Layer | Schema suffix | Materialization |
|---|---|---|
| staging | `rdp_staging` | view |
| temp | `rdp_temp` | table |
| dwh | `rdp_dwh` | table |
| dwh_views | `rdp_dwh_views` | view |
| mart | `rdp_mart` | table |
| mart_views | `rdp_mart_views` | view |

### Key Macros (`macros/`)

- **`generate_schema_name.sql`** — Prefixes dataset names with the active dbt target (dev/tst/prd)
- **`audit_columns.sql`** — Appends `rdp_created_at` and `rdp_updated_at` to all models
- **`customer_columns.sql`** — Dynamically passes through any `cust_*` columns from staging without code changes

---

## Adding a New Component

1. Create the component folder in both projects following the folder convention above
2. Add staging models to `rtl_rdp_client/models/staging/{subject_area}/{component}/`
3. Add RDP models (temp, dwh, dwh_views, mart, mart_views) to the corresponding layers in `rtl_rdp`
4. Define constraints in `schema.yml` (not just tests) — dbterd reads constraints for the ERD
5. Add doc blocks to `rtl_rdp/models/docs__{component}.md`
6. Enable the component in `rtl_rdp_client/components.yml`
7. Run `merge_manifests.py` and dbterd to regenerate ERD and lineage for the new component
8. Add the new component to the MkDocs nav in `mkdocs.yml`
