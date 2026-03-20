# RDP Style Guide
## Retail Data Platform — Naming Conventions and Coding Standards

This style guide defines naming conventions and coding standards for the
Retail Data Platform (RDP). It applies to all models, columns, tests, and
documentation across both the `rtl_rdp` and `rtl_rdp_client` dbt projects.

This guide is informed by the official dbt Labs style guide:
https://docs.getdbt.com/best-practices/how-we-style/1-how-we-style-our-dbt-models

Where RDP conventions differ from dbt Labs, this document takes precedence.

---

## 1. General Principles

- All names are lowercase with underscores as separators.
  `order_date` not `OrderDate` or `orderDate`
- No abbreviations unless they are universally accepted standards
  (e.g. `id`, ISO currency codes).
  `quantity` not `qty`, `customer` not `cust`, `description` not `desc`
- Names must be self-explanatory without needing additional context.
  The meaning of a column must be derivable from its name alone.
- The same column name must mean the same thing in every table it appears in.
- Consistency is mandatory. Once a naming pattern is established for an
  entity, it applies to all occurrences across all models.

---

## 2. Model Naming Conventions

Models are named with a prefix that reflects their layer in the architecture:

| Layer | Prefix | Example |
|---|---|---|
| Staging | `stg_` | `stg_products` |
| Temp | `int_` | `int_orders_enriched` |
| Dimensions | `dim_` | `dim_products` |
| Facts | `fct_` | `fct_orders` |
| DWH Views | `vw_dim_` / `vw_fct_` | `vw_dim_products` |
| Marts | `mart_` | `mart_sales` |
| Mart Views | `vw_mart_` | `vw_mart_sales` |

All model names are plural:
`stg_products` not `stg_product`
`fct_orders` not `fct_order`

> **Note:** The dbt Labs standard uses `intermediate` for the temp layer.
> RDP uses `temp` instead to reflect its broader purpose — serving as a
> working layer for any downstream layer, not just the warehouse.

---

## 3. Column Naming Conventions

### 3.1 Primary Keys
- Always named `{entity}_id`
- Never just `id` — too ambiguous in joined models
- Must be unique and not null
```
product_id
customer_id
order_id
seller_id
```

### 3.2 Foreign Keys
- Same name as the primary key they reference
- Makes joins self-documenting
```sql
-- fct_orders references dim_products
-- both use product_id — no ambiguity
SELECT *
FROM fct_orders o
JOIN dim_products p ON o.product_id = p.product_id
```

### 3.3 Attribute Columns
- Always qualified with the entity name
- Never use generic names that could be ambiguous across tables
```
-- correct
product_category_name
customer_city
customer_state
order_status
order_cancel_date

-- incorrect
category_name
city
state
status
cancel_date
```

### 3.4 Boolean Columns
- Always prefixed with `is_` or `has_`
- Never use flag suffixes or ambiguous names
```
is_cancelled
is_active
has_discount
has_review

-- incorrect
cancelled
active_flag
discount_yn
```

### 3.5 Date and Timestamp Columns
- Date columns use the suffix `_date`
- Timestamp columns use the suffix `_at`
- Both may exist for the same concept when there is a specific reason.
  For example, `order_date` (DATE) for calendar joins and
  `order_placed_at` (TIMESTAMP) for intraday analysis.
```
order_date          -- DATE, used for calendar joins
order_placed_at     -- TIMESTAMP, used for intraday analysis
ship_date           -- DATE
cancel_date         -- DATE
created_at          -- TIMESTAMP
updated_at          -- TIMESTAMP
```

### 3.6 Monetary Columns
- Monetary amounts use the suffix `_amount`
- All monetary amounts in the same row are in the same currency
- Each table containing monetary amounts has exactly one `currency_code` column
- `currency_code` follows the ISO 4217 standard (e.g. BRL, USD, EUR, GBP)
- Currency conversion is out of scope — amounts are stored in local currency only
```
currency_code           -- STRING, ISO 4217, row-level, applies to all amounts
price_amount            -- NUMERIC, in currency_code
freight_amount          -- NUMERIC, in currency_code
discount_amount         -- NUMERIC, in currency_code
```

**Assumption:** All monetary amounts in a row are in the same currency.
Rows with mixed currencies are not supported by this design.


### 3.7 Customer-Added Columns
- All columns added by the customer beyond the RDP contract must be
  prefixed with `cust_`
- The `cust_` prefix is followed by the same naming conventions above
- This prevents naming conflicts with future RDP canonical columns
```
cust_product_cost_amount
cust_product_supplier_name
cust_is_featured
```

---

## 4. Column Ordering

Within any model, columns should be ordered as follows:

1. Primary key
2. Foreign keys
3. Strings / categorical attributes
4. Numeric measures
5. Boolean flags
6. Dates
7. Timestamps
8. Customer columns (cust_*)

---

## 5. SQL Style

- All SQL keywords uppercase: `SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`
- All column and table names lowercase
- One column per line in SELECT statements
- Trailing commas (comma at end of line, not beginning)
- Explicit JOIN types — never implicit joins
- Always use table aliases in multi-table queries
- CTEs preferred over subqueries for readability
```sql
-- correct
WITH enriched_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        c.customer_city,
    FROM orders o
    LEFT JOIN customers c
        ON o.customer_id = c.customer_id
)

SELECT * FROM enriched_orders

-- incorrect
SELECT o.order_id, o.customer_id, c.city
from orders o, customers c
where o.customer_id = c.customer_id
```

- Always alias columns that are renamed or derived from calculations.
  This makes the output schema explicit and self-documenting,
  particularly important in staging models where source columns
  are mapped to canonical names.
```sql
-- correct — alias makes the output column name explicit
SELECT
    source_item_code        AS product_id,
    source_category         AS product_category_name,
    length * width * height AS product_volume_cm3,

-- incorrect — relies on implicit column naming
SELECT
    source_item_code,
    length * width * height,
```

---

## 6. dbt-Specific Conventions

- All source references use `{{ source() }}` — never hardcoded table names
- All model references use `{{ ref() }}` — never hardcoded model names
- Staging models are the only layer that references `{{ source() }}`
- All other layers reference `{{ ref() }}` only
- Every model must have a `schema.yml` entry with a description
- Every column must have a description using `{{ doc() }}` blocks where available
- Primary keys must have `not_null` and `unique` tests at minimum

---

## 7. Documentation

- Column descriptions use `{{ doc() }}` blocks defined in `rtl_rdp/docs/`
- `doc()` blocks are defined at the canonical column name level
- The same `doc()` block is reused across all tables where the column appears
- Layer-specific context may be appended after the `doc()` reference

---

## 8. Customer Column Enforcement

Customer columns that do not follow the `cust_` prefix convention will
be flagged by the `check_custom_column_prefix` dbt test. In development
environments this raises a warning. In production it raises an error.

Reserved column names — names used by RDP canonical models — must never
be used for customer columns even with the `cust_` prefix.
A full list of reserved column names is maintained in `CONTRACT.md`.