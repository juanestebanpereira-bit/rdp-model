-- =============================================================================
-- dim_classes.sql
-- =============================================================================
-- Dimension table for classes. Reads from int_classes, which already includes
-- department attribute carry-down and customer column passthrough.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: int_classes
-- =============================================================================

SELECT
    *,
    {{ audit_columns() }}

FROM {{ ref('int_classes') }}
