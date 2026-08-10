# Product hierarchy

The Product Hierarchy is the foundation component of the Products subject area. It models a retailer's merchandise classification structure — department, class, style, and item — and every other product-related component (Sales, Inventory, POs) depends on it. It has no dependencies of its own.

## Hierarchy

The hierarchy runs broadest to most granular:

```
Department → Class → Style → Item
```

- **Department** — a major sector such as Men's Wear, Women's Wear, or Footwear. Typically aligned with specific buying teams, and typically the level use to set buying budgets, inventory targets and sales tracking metrics.
- **Class** — a level below a department, such as Causal Shirts, Business Shirts or Formal Shirts within Men's Shirts. Usually groups styles that share a common use or purpose and therefore are somewhat interchanable from the consumer's perspective.
- **Style** — a core level in a product hierarchy that represents a distinct design, silhouette, or model of an item before it branches into specific color, size, or material variants.
- **Item** — sometimes known as Stock Keepin Unit (SKU) is the lowest, most granular level in the product hierarchy. It represents a unique item variant, defined by specific attributes like style, color, and size.


## Grain and relationships

| Entity | Grain | Primary key | Parent |
|---|---|---|---|
| Department | One row per department | `department_id` | — |
| Class | One row per class | `class_id` | Department |
| Style | One row per style | `style_id` | Class |
| Item | One row per item | `item_id` | Style |

Each level is a one-to-many parent of the level below it: one department has many classes, one class has many styles, one style has many items.

## Warehouse model

Product Hierarchy follows RDP's standard layering:

1. **Staging** (`stg_*`, customer-owned, in `rdp-client`) — raw source data mapped to the RDP contract.
2. **Temp** (`int_*`, this component) — joins each staging entity to its parent and carries down parent attributes.
3. **Dwh** (`dim_*`, this component) — the physical dimension tables. Read directly from the `int_*` models and add audit columns (`rdp_created_at`, `rdp_updated_at`).
4. **Dwh views** (`vw_dim_*`, this component) — a stable public interface over the `dim_*` tables, absorbing any breaking schema changes before they reach downstream consumers.

## Denormalization (attribute carry-down)

RDP carries parent attributes down through the hierarchy at each layer, so reporting tools can query any level without joins. For example, `dim_items` includes not just `item_id` and `item_name`, but also `style_number`, `style_name`, `class_number`, `class_name`, `department_number`, and `department_name` — the full ancestry, denormalized onto every item row.

## Missing values

Missing values are NULL, always — RDP does not use sentinel strings or sentinel rows. NULLs arise from two sources: when a child row's foreign key doesn't resolve to a parent — for example, a class with no matching department — the FK and every carried-down parent attribute are simply NULL; and when the source system doesn't capture a value at all — for example, an item without a recorded class — the attribute is NULL from staging onward, and NULLs propagate naturally through denormalized parent attributes. Reporting layers handle NULL as they see fit.

## Customer columns

Customers may add `cust_*` columns to any staging view; they pass through automatically at the temp layer via the `customer_columns` macro. See [contract.md](contract.md) for the full staging contract, including how to document custom columns.

## Related documentation

- [contract.md](contract.md) — staging contract: required columns, types, null constraints
- `style-guide.md` — naming and layer conventions referenced above
