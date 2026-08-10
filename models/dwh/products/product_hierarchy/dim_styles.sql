-- =============================================================================
-- dim_styles.sql
-- =============================================================================
-- Dimension table for styles. Reads from int_styles, which already includes
-- class and department attribute carry-down and customer column passthrough.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: int_styles
-- =============================================================================

SELECT
    *,
    {{ audit_columns() }}

FROM {{ ref('int_styles') }}
