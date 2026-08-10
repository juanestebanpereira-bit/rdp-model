# Contract — Products
## Retail Data Platform — Products Staging Contract

This file defines the staging contract for the Products subject area.
For the full contract index refer to `contract.md`.
For entity definitions refer to `data_model/products.md`.

---

## Component: Product Hierarchy

### Dependencies
None — this is a foundation component with no dependencies.

### Mandatory
Yes — required for all RDP implementations that include any
product-related subject areas (Sales, Inventory etc.)

NULL is an acceptable value for any column marked "NULL allowed."
However, customers should minimize NULLs where the source data
permits — populate values wherever they can be reliably derived.
Excessive NULLs degrade downstream reporting quality even though they
are structurally valid.

### Staging Views Required

#### stg_departments

| Column | Type | Nullable |
|---|---|---|
| `department_id` | STRING | NOT NULL |
| `department_number` | STRING | NOT NULL |
| `department_name` | STRING | NOT NULL |
| `rdp_source_system` | STRING | NOT NULL |
```sql
-- Minimum valid implementation
SELECT
    your_dept_code      AS department_id,
    your_dept_number    AS department_number,
    your_dept_name      AS department_name
FROM {{ source('your_landing', 'your_departments_table') }}
```

---

#### stg_classes

| Column | Type | Nullable |
|---|---|---|
| `class_id` | STRING | NOT NULL |
| `department_id` | STRING | NOT NULL |
| `class_number` | STRING | NOT NULL |
| `class_name` | STRING | NOT NULL |
| `rdp_source_system` | STRING | NOT NULL |
```sql
-- Minimum valid implementation
SELECT
    your_class_code     AS class_id,
    your_dept_code      AS department_id,
    your_class_number   AS class_number,
    your_class_name     AS class_name
FROM {{ source('your_landing', 'your_classes_table') }}
```

---

#### stg_styles

| Column | Type | Nullable |
|---|---|---|
| `style_id` | STRING | NOT NULL |
| `class_id` | STRING | NULL allowed |
| `style_number` | STRING | NOT NULL |
| `style_name` | STRING | NULL allowed |
| `rdp_source_system` | STRING | NOT NULL |
```sql
-- Minimum valid implementation
SELECT
    your_style_code     AS style_id,
    your_class_code     AS class_id,
    your_style_number   AS style_number,
    your_style_name     AS style_name
FROM {{ source('your_landing', 'your_styles_table') }}
```

---

#### stg_items

| Column | Type | Nullable |
|---|---|---|
| `item_id` | STRING | NOT NULL |
| `style_id` | STRING | NOT NULL |
| `item_number` | STRING | NOT NULL |
| `item_name` | STRING | NOT NULL |
| `rdp_source_system` | STRING | NOT NULL |
```sql
-- Minimum valid implementation
SELECT
    your_item_code      AS item_id,
    your_style_code     AS style_id,
    your_item_number    AS item_number,
    your_item_name      AS item_name
FROM {{ source('your_landing', 'your_items_table') }}
```

---

### Enable This Component
```yaml
# rdp-client/components.yml
subject_areas:
  products:
    components:
      product_hierarchy:
        enabled: true
```

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2025-06-01 | Initial — product hierarchy component |