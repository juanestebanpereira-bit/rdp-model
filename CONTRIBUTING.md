# Contributing to RDP

This document is for developers working on the RDP platform itself.
For customer implementation guidance, see `CONTRACT.md`.

---

## Project Structure

This is a monorepo containing two dbt projects and a shared documentation layer:

```
retail-analytics/
├── rtl_rdp/               # RDP product — published as a dbt package
├── rtl_rdp_client/        # Customer implementation — maps source data to the RDP contract
├── docs/                  # MkDocs site — spans both projects, lives at repo root
├── build/                 # CI artifacts (gitignored) — merged manifests consumed by dbterd and colibri
└── merge_manifests.py     # Merges dbt artifacts from both projects before ERD/lineage generation
```

The two-project split is intentional: `rtl_rdp` is the product, `rtl_rdp_client` is a reference
customer implementation. Customers install `rtl_rdp` as a dbt package and implement their own
`rtl_rdp_client`. This means `rtl_rdp` must never import or depend on `rtl_rdp_client`.

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

## Adding a New Component

1. Create the component folder in both projects following the folder convention above
2. Add staging models to `rtl_rdp_client/models/staging/{subject_area}/{component}/`
3. Add RDP models (temp, dwh, dwh_views, mart, mart_views) to the corresponding layers in `rtl_rdp`
4. Define constraints in `schema.yml` (not just tests) — dbterd reads constraints for the ERD
5. Add doc blocks to `rtl_rdp/models/docs__{component}.md`
6. Enable the component in `rtl_rdp_client/components.yml`
7. Run `merge_manifests.py` and dbterd to regenerate ERD and lineage for the new component
8. Add the new component to the MkDocs nav in `mkdocs.yml`
