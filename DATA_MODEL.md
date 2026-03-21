# RDP Canonical Data Model
## Retail Data Platform — Entity Definitions and Relationships

This document is the index for the RDP canonical data model.
Each subject area is documented in its own file under `data_model/`.

For naming conventions refer to `STYLE_GUIDE.md`.
For customer implementation requirements refer to `CONTRACT.md`.
The technical implementation lives in `models/dwh/schema.yml`.

---

## How to Read the Subject Area Files

Each subject area file contains one or more components. Each component
defines:
- The staging entities (normalized, customer-implemented)
- The warehouse entities (denormalized, RDP-implemented)
- The relationships between entities
- The ETL flow

Staging entities are normalized and contain additional columns provided by the customer.

Warehouse entities are denormalized by RDP during ETL. Parent attributes
are carried down through hierarchies so that reporting tools can access
the full lineage from any level without joins.

---

## Subject Areas

| Subject Area | Status | File |
|---|---|---|
| Products | ✅ Available | [data_model/products.md](data_model/products.md) |
| Locations | 🔜 Coming Soon | data_model/locations.md |
| Calendar | 🔜 Coming Soon | data_model/calendar.md |
| Sales | 🔜 Coming Soon | data_model/sales.md |
| Inventory | 🔜 Coming Soon | data_model/inventory.md |
| Digital Orders | 🔜 Coming Soon | data_model/digital_orders.md |
| Purchasing | 🔜 Coming Soon | data_model/purchasing.md |

---

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2025-06-01 | Initial release — products subject area |