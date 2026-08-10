# rdp_model — Retail Data Platform Product

This is the RDP product dbt project. It defines the canonical data model,
transformations, and BI-facing views for the Retail Data Platform.

`rdp_model` is distributed to customers as a dbt package. Customers install
it via `dbt deps` in their own `rdp_client` project and implement
the staging contract it requires.

## This Repository

`rdp-model` is one of four RDP repositories — see
[rdp-docs/README.md](../rdp-docs/README.md) for the full ecosystem picture.

## Key Documents

- `implementation-guide.md` — staging contract customers must implement, including how to document custom columns
- `CONTRIBUTING.md` — developer guide: folder conventions, tool choices, adding components
- `style-guide.md` — SQL and dbt coding standards

## Data Flow

```
rdp_client: staging (stg_*)         customer-owned, maps sources to RDP contract
        ↓
rdp_model: temp (int_*)              internal joins, enrichment
        ↓
rdp_model: dwh (dim_*, fct_*)        conformed physical tables
        ↓
rdp_model: dwh_views (vw_dim_*, vw_fct_*)   stable public interface
        ↓
rdp_model: mart (mart_*)             subject-area aggregations
        ↓
rdp_model: mart_views (vw_mart_*)    BI-facing layer (Lightdash)
```

## Folder structure

For the canonical model itself, see [data-model.md](data-model.md). For
the `models/`/`docs/` folder conventions, what a new subject area or
component needs, and where each generated artifact (ERD, lineage, data
dictionary) comes from, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Common Commands

Run from within this directory (`rdp-model/`):

```bash
dbt deps          # Install packages
dbt compile       # Compile SQL without executing
dbt run           # Run all models
dbt test          # Run all data quality tests
dbt docs generate # Generate documentation
```
