# RDP Staging Contract
## Retail Data Platform — Customer Staging Requirements

This document defines the staging contract between the customer's data
and the Retail Data Platform (RDP). It specifies the required views that
customers must implement in the `rtl_rdp_client` dbt project.

The technical enforcement of this contract is implemented via dbt tests
in `rtl_rdp_client/models/staging/schema.yml`. This document is the
human-readable version of those tests.

For column naming conventions and coding standards, refer to `STYLE_GUIDE.md`.

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
RDP product code. Once data passes through staging, the RDP product
takes full ownership of all downstream processing.

---

## General Rules

1. **Required columns must exist** with the exact names specified below.
   Missing columns will cause the RDP pipeline to fail.

2. **Required columns must satisfy their null constraints.**
   Columns marked NOT NULL must never contain null values.

3. **Additional columns are welcome** but must be prefixed with `cust_`.
   See `STYLE_GUIDE.md` section 3.9 for customer column conventions.

4. **Column names must be lowercase with underscores.**
   No camelCase, no spaces, no special characters.

5. **All monetary amounts in a row must be in the same currency.**
   Mixed-currency rows are not supported. See `STYLE_GUIDE.md` section 3.7.

6. **Data types must match the contract specification.**
   Type mismatches will cause the RDP pipeline to fail.

---

## Reserved Column Names

The following column names are reserved by RDP and must not be used
for customer columns, even with the `cust_` prefix:

`product_id`, `product_category_name`, `product_description_length`,
`product_name_length`, `product_photos_quantity`, `product_weight_g`,
`product_length_cm`, `product_height_cm`, `product_width_cm`,
`product_volume_cm3`, `currency_code`

This list will grow as new canonical models are added to RDP.

---

## Staging Contract — Products

**View name:** `stg_products`
**Grain:** One row per product
**Destination:** `{env}_rdp_staging.stg_products`

| Column | Type | Nullable | Description |
|---|---|---|---|
| `product_id` | STRING | NOT NULL | Unique product identifier. Primary key. |
| `product_category_name` | STRING | NULL | Product category in any language. |
| `product_description_length` | INTEGER | NULL | Character length of product description. |

**Optional customer columns:**
Any additional product attributes may be added with the `cust_` prefix.
```sql
-- Minimum valid implementation
SELECT
    your_item_code          AS product_id,
    your_category           AS product_category_name,
    your_desc_length        AS product_description_length
FROM {{ source('your_landing', 'your_products_table') }}

-- With optional customer columns
SELECT
    your_item_code          AS product_id,
    your_category           AS product_category_name,
    your_desc_length        AS product_description_length,
    your_cost               AS cust_product_cost_amount,
    your_supplier           AS cust_product_supplier_name
FROM {{ source('your_landing', 'your_products_table') }}
```

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2025-01-01 | Initial contract — products |

---

## Coming Soon

Staging contracts for the following entities will be added in future versions:
- Customers
- Orders
- Order Items
- Sellers
- Payments
- Reviews