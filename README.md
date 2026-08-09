# rtl_rdp — Retail Data Platform Product

This is the RDP product dbt project. It defines the canonical data model,
transformations, and BI-facing views for the Retail Data Platform.

`rtl_rdp` is distributed to customers as a dbt package. Customers install
it via `dbt deps` in their own `rtl_rdp_client` project and implement
the staging contract it requires.

## This Repository

`rdp-model` is one of four RDP repositories — see
[rdp-docs/README.md](../rdp-docs/README.md) for the full ecosystem picture.

## Key Documents

- `contract.md` — staging contract customers must implement, including how to document custom columns
- `CONTRIBUTING.md` — developer guide: folder conventions, tool choices, adding components
- `style-guide.md` — SQL and dbt coding standards

## Data Flow

```
rtl_rdp_client: staging (stg_*)     customer-owned, maps sources to RDP contract
        ↓
rtl_rdp: temp (int_*)               internal joins, enrichment, sentinel rows
        ↓
rtl_rdp: dwh (dim_*, fct_*)         conformed physical tables
        ↓
rtl_rdp: dwh_views (vw_dim_*, vw_fct_*)   stable public interface
        ↓
rtl_rdp: mart (mart_*)              subject-area aggregations
        ↓
rtl_rdp: mart_views (vw_mart_*)     BI-facing layer (Lightdash)
```

## Common Commands

Run from within this directory (`rtl_rdp/`):

```bash
dbt deps          # Install packages
dbt compile       # Compile SQL without executing
dbt run           # Run all models
dbt test          # Run all data quality tests
dbt docs generate # Generate documentation
```
