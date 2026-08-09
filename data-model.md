# RDP Canonical Data Model
## Retail Data Platform — Entity Definitions and Relationships

This document explains what the RDP canonical data model is: a single set
of entity definitions and relationships that stays identical across every
customer implementation. For the full catalog of subject areas and
components, see `docs/components.md`.

For naming conventions refer to `style-guide.md`.
For customer implementation requirements refer to `contract.md`.
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

## Version History

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2025-06-01 | Initial release — products subject area |