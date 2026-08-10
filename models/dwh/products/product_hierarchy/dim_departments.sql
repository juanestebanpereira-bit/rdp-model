-- =============================================================================
-- dim_departments.sql
-- =============================================================================
-- Dimension table for departments. Reads from int_departments, which already
-- includes customer column passthrough.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: int_departments
-- =============================================================================

SELECT
    *,
    {{ audit_columns() }}

FROM {{ ref('int_departments') }}
