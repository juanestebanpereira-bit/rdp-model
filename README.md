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

## Folder structure

For the canonical model itself, see [data-model.md](data-model.md).

### Component folder structure

Each component adds files in two places: documentation under 
`docs/components/`, and dbt models under `models/`. Both follow the 
same `{subject-area}/{component}/` folder pattern with 
lowercase-with-hyphens naming.

```text
docs/
└── {subject-area}/
    └── {component}/
        ├── overview.md
        ├── contract.md

models/
├── temp/
│   └── {subject-area}/
│       └── {component}/
│           └── int_*.sql
├── dwh/
│   └── {subject-area}/
│       └── {component}/
│           ├── dim_*.sql
│           └── fct_*.sql
└── dwh_views/
    └── {subject-area}/
        └── {component}/
            ├── vw_dim_*.sql
            └── vw_fct_*.sql
```

### Documentation files

Each component folder under `docs/components/` has the same three files:

| File | Contents | Audience |
|---|---|---|
| `overview.md` | Description and business definitions. Grain, cardinality, hierarchy, denormalization notes. | Implementation consultants, data modelers |
| `contract.md` | Staging contract for this component: required source tables, columns, types, null constraints. | Implementation consultants |

### dbt models

Each component has models across the three warehouse layers, following 
the layer prefixes defined in [style-guide.md](style-guide.md):

- `int_*` in `models/temp/` — intermediate transformations
- `dim_*` and `fct_*` in `models/dwh/` — physical warehouse tables
- `vw_dim_*` and `vw_fct_*` in `models/dwh_views/` — public-facing views

Staging models (`stg_*`) live in `rdp-client`, not here — they are 
customer-owned.

### What's not documented per component

Some content is the same for every component and lives at the platform 
level, not per component:

- dbt layers themselves — documented in [style-guide.md](style -guide.md)
- ERDs and column lineage — generated from dbt artifacts by tooling in `rdp-platform`
- Data dictionary — generated from `schema.yml` files by dbt docs

### Business-user documentation

`overview.md` is written for people who can read 
SQL and understand data modeling concepts. Business-user documentation 
lives in the Cube semantic layer when a customer deploys it.



## Common Commands

Run from within this directory (`rtl_rdp/`):

```bash
dbt deps          # Install packages
dbt compile       # Compile SQL without executing
dbt run           # Run all models
dbt test          # Run all data quality tests
dbt docs generate # Generate documentation
```
