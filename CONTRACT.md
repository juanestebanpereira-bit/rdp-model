# RDP Staging Contract
## Retail Data Platform — Customer Staging Requirements

This document defines what the customer must implement in the
`rtl_rdp_client` dbt project for the RDP pipeline to function.
It is intentionally concise — a checklist for implementation,
not a reference manual.

For full column descriptions, run `dbt docs generate` in `rtl_rdp`
to browse the RDP data dictionary.

For naming conventions and coding standards, refer to `STYLE_GUIDE.md`.

---

## How the Contract Works
```
Customer source data (landing)
        ↓
Customer implements staging views (rtl_rdp_client)
        ↓  must satisfy this contract
RDP product reads staging views (rtl_rdp)
        ↓
RDP warehouse, mart, and BI layers
```

The staging layer is the only place where customer source data meets
RDP product code. Once data passes through staging, RDP takes full
ownership of all downstream processing.

---

## General Rules

1. **Required columns must exist** with the exact names specified below.
   Missing columns will cause the RDP pipeline to fail.

2. **Required columns must satisfy their null constraints.**
   Columns marked NOT NULL must never contain null values.

3. **Additional columns are welcome** but must be prefixed with `cust_`.
   See `STYLE_GUIDE.md` section 3.8 for customer column conventions.

4. **Column names must be lowercase with underscores.**
   No camelCase, no spaces, no special characters.

5. **All monetary amounts in a row must be in the same currency.**
   See `STYLE_GUIDE.md` section 3.6 for monetary column conventions.

6. **Data types must match the contract specification.**
   Type mismatches will cause the RDP pipeline to fail.

---

## Reserved Column Names

Any column name defined in the RDP canonical model is automatically
reserved. Customers must not use reserved names for custom columns
even with the `cust_` prefix.

The canonical model is defined in `rtl_rdp/models/dwh/schema.yml`.
That file is the authoritative source of all reserved names — if a
column appears there, it is reserved.

The `check_custom_column_prefix` dbt test will automatically flag
any violations at pipeline run time.

---

## Component Registry

RDP is modular. Customers implement only the components they need
and expand over time. All components are disabled by default and
must be explicitly enabled.

### How to Enable Components

Edit `components.yml` in your `rtl_rdp_client` project and set
`enabled: true` for each component you have implemented:
```yaml
subject_areas:
  products:
    components:
      product_hierarchy:
        enabled: true    # ← flip to true once implemented
```

### Component Dependencies

Some components depend on others and cannot be enabled independently.
Dependencies are listed in each component's contract section below.
The RDP pipeline will fail at startup if a dependency is not satisfied.

### Available Components

Components are organized by subject area. Each subject area section
below lists its components, their dependencies, and the staging views
they require.

## Staging Contracts by Entity

Each section below defines one required staging view. The customer
must implement all views for the entities they wish to use.

---

### Products

**View name:** `stg_products`
**Grain:** One row per product
**Dataset:** `{env}_rdp_staging`

#### Required Columns

| Column | Type | Nullable |
|---|---|---|
| `product_id` | STRING | NOT NULL |
| `product_category_name` | STRING | NULL |
| `product_description_length` | INTEGER | NULL |

#### Notes
- Additional columns welcome with `cust_` prefix
- Full column descriptions available in RDP data dictionary

#### Minimum Valid Implementation
```sql
SELECT
    your_item_code      AS product_id,
    your_category       AS product_category_name,
    your_desc_length    AS product_description_length
FROM {{ source('your_landing', 'your_products_table') }}
```

#### Example With Customer Columns
```sql
SELECT
    your_item_code      AS product_id,
    your_category       AS product_category_name,
    your_desc_length    AS product_description_length,
    your_cost           AS cust_product_cost,
    your_supplier       AS cust_product_supplier_name
FROM {{ source('your_landing', 'your_products_table') }}
```

---

## Coming Soon

Staging contracts for the following entities will be added as
the RDP canonical model is extended:

- Customers
- Orders
- Order Items
- Sellers
- Payments
- Reviews

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2025-06-01 | Initial contract — products |