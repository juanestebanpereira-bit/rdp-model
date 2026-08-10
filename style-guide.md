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
- **Must declare an explicit `constraints` entry in schema.yml — never rely on tests alone to communicate the PK relationship**
```
product_id
customer_id
order_id
seller_id
```
```yaml
# correct — constraint declared explicitly
models:
  - name: stg_products
    constraints:
      - type: primary_key
        columns: [product_id]
    columns:
      - name: product_id

# incorrect — PK only implied by tests
    columns:
      - name: product_id
        tests:
          - unique
          - not_null
```
#### Composite Primary Keys
When a table receives data from multiple source systems, the primary
key becomes a composite of rdp_source_system and the natural key:

| Single source | Multi source |
|---|---|
| `order_id` | `rdp_source_system + order_id` |
| `product_id` | `rdp_source_system + product_id` |

In dbt, composite keys are tested using:
```yaml
tests:
  - dbt_utils.unique_combination_of_columns:
      combination_of_columns:
        - rdp_source_system
        - order_id
```

#### Surrogate Keys
Surrogate keys (_sk suffix) are not used by default in RDP.
Natural keys (_id suffix) serve as primary keys in all dimension tables.

Surrogate keys could be introduced when:
- Multiple source systems load data into the same dimension table
- Slowly changing dimension (SCD Type 2) support is required
- Source system natural keys are demonstrably unstable

All dimension tables include a source_system column to support
future multi-source scenarios without requiring surrogate keys.

### 3.2 Foreign Keys
- Same name as the primary key they reference
- Makes joins self-documenting
- **Must declare an explicit `constraints` entry in schema.yml — never rely on `relationships` tests alone to communicate the FK relationship**
```sql
-- fct_orders references dim_products
-- both use product_id — no ambiguity
SELECT *
FROM fct_orders o
JOIN dim_products p ON o.product_id = p.product_id
```
```yaml
# correct — FK constraint declared explicitly
models:
  - name: fct_orders
    columns:
      - name: product_id
        constraints:
          - type: foreign_key
            to: ref('dim_products')
            to_columns: [product_id]

# incorrect — FK only implied by a relationships test
      - name: product_id
        tests:
          - relationships:
              to: ref('dim_products')
              field: product_id
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

#### Names vs Descriptions
- Use `_name` for labels, identifiers and short categorical values.
  `department_name`, `class_name`, `item_name`
- Use `_description` only for long free-text fields that genuinely
  describe something in detail rather than label it.
  `product_description`, `promotion_description`
- When in doubt, prefer `_name` — it is more natural and concise.

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
order_created_at    -- TIMESTAMP
order_updated_at    -- TIMESTAMP
```

### 3.6 Monetary Columns

- All monetary amounts in a row are in the same currency.
- Each table containing monetary amounts has exactly one `currency_code`
  column per row following ISO 4217 (e.g. BRL, USD, EUR, GBP).
- Currency conversion is out of scope — amounts are stored in local
  currency only.

**Assumption:** All monetary amounts in a row are in the same currency.
Rows with mixed currencies are not supported by this design.

Monetary columns use the following suffixes reflecting
their valuation type, which is standard terminology in retail:

| Suffix | Meaning | Example |
|---|---|---|
| `_retail` | Value at selling/retail price | `sales_retail`, `inventory_retail` |
| `_cost` | Value at cost price | `sales_cost`, `inventory_cost` |

For monetary columns outside the retail/cost valuation pattern,
use the generic `_amount` suffix:

| Suffix | Meaning | Example |
|---|---|---|
| `_amount` | Generic monetary amount | `freight_amount`, `discount_amount` |
```sql
-- retail valuation columns
sales_retail            -- NUMERIC, sales value at retail price
sales_cost              -- NUMERIC, sales value at cost price
inventory_retail        -- NUMERIC, inventory value at retail price
inventory_cost          -- NUMERIC, inventory value at cost price

-- generic monetary columns
freight_amount          -- NUMERIC, freight charge
discount_amount         -- NUMERIC, discount applied
currency_code           -- STRING, ISO 4217, applies to all amounts in row
```


### 3.7 Customer-Added Columns
- All columns added by the customer beyond the RDP contract must be
  prefixed with `cust_`
- The `cust_` prefix is followed by the same naming conventions above
- This prevents naming conflicts with future RDP canonical columns
```

cust_product_supplier_name
cust_is_featured
```

### 3.8 Missing Values

Missing values are NULL, always. No sentinel strings, no sentinel rows,
no COALESCE to placeholder values. FKs are NULL when the parent doesn't
resolve. Attributes are NULL when the value isn't captured. Reporting
layers handle NULL as they see fit.

**Why:** BigQuery (and Snowflake) treat NULL efficiently, so the
traditional reasons for sentinels no longer apply. Modern BI tools
handle NULL correctly. Removing sentinels simplifies model logic and
transformations.

### 3.9 System Columns

The following columns are reserved by RDP.
Customers must not use these names in custom columns.

| Column | Type | Nullable | Purpose |
|---|---|---|---|
| `rdp_source_system` | STRING | NOT NULL | Identifies the source system that provided the record |
| `rdp_created_at` | TIMESTAMP | NOT NULL | When the record was first loaded into the warehouse |
| `rdp_updated_at` | TIMESTAMP | NOT NULL | When the record was last updated in the warehouse |

These columns appear last in every table, after all business columns
and customer columns (cust_*).

**Note:** `rdp_source_system` is provided by the customer in the staging layer
and flows through `int_` models to `dim_` and `fct_` tables automatically.

`rdp_created_at` and `rdp_updated_at` are generated by the `audit_columns()`
macro in the warehouse layer and reflect the time of the last dbt run.
In full-refresh materializations these values reset on every run; incremental
models are required for true record-level audit timestamps.

---

## 4. Column Ordering

Within any model, columns should be ordered as follows:

1. Primary key columns (all of them, regardless of data type)
2. Foreign keys
3. Strings / categorical attributes
4. Numeric measures
5. Boolean flags
6. Dates (non-PK only)
7. Timestamps (non-PK only)
8. Customer columns (cust_*)
9. System columns (rdp_source_system, rdp_created_at, rdp_updated_at)

**Note:** When a date or timestamp forms part of a composite primary key,
it appears in position 1 alongside the other primary key columns,
not in positions 6 or 7. The rule is: primary key columns always
come first, regardless of their data type.

Example — `fct_sales` with a composite primary key where `sale_date` is part of the PK:
```sql
-- 1. primary key columns (all PK columns first, regardless of data type)
sale_date,       -- DATE, but part of the composite PK → position 1
rdp_source_system,  -- STRING, but part of the composite PK → position 1
order_id,        -- STRING, composite PK → position 1

-- 2. foreign keys
customer_id,
item_id,

-- 3. string / categorical attributes
channel,
store_code,

-- 4. numeric measures
quantity,
unit_price,
total_amount,

-- 6. dates (non-PK only)
ship_date,
return_date,

-- 8. customer columns
cust_region_tag,

-- 9. system columns
rdp_created_at,
rdp_updated_at
```

#### Denormalized Tables
In warehouse tables where parent attributes are carried down through
the hierarchy, the ordering within each grouping follows the hierarchy
from most specific to least specific (bottom up):

1. Primary key of the entity
2. Foreign keys in hierarchy order — immediate parent first,
   then grandparent, then great-grandparent etc.
3. Attributes of the entity itself
4. Attributes of the immediate parent
5. Attributes of the grandparent
6. And so on up the hierarchy
7. Remaining column types follow the standard order
   (booleans, dates, timestamps, cust_*)

Example — dim_items:
```sql
-- 1. primary key
item_id,

-- 2. foreign keys — immediate parent first
style_id,
class_id,
department_id,

-- 3. item attributes
item_number,
item_name,

-- 4. style attributes
style_number,
style_name,

-- 5. class attributes
class_number,
class_name,

-- 6. department attributes
department_number,
department_name
```

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
    length * width * height AS product_volume,

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
- PKs and FKs must have explicit `constraints:` declared in schema.yml — the relationship must never be inferred from tests alone. Tests validate data quality; constraints declare the semantic contract.

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
A full list of reserved column names is maintained in `contract.md`.
