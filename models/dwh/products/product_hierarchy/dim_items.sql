-- =============================================================================
-- dim_items.sql
-- =============================================================================
-- Dimension table for items. Reads from int_items, which already includes
-- style, class, and department attribute carry-down and customer column
-- passthrough.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: int_items
-- =============================================================================

SELECT
    *,
    {{ audit_columns() }}

FROM {{ ref('int_items') }}
