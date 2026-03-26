-- =============================================================================
-- vw_dim_departments.sql
-- =============================================================================
-- Stable public-facing view over dim_departments. Provides a consistent
-- interface to the physical dimension table, absorbing any breaking schema
-- changes before they reach downstream consumers.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: dim_departments
-- =============================================================================

SELECT *

FROM {{ ref('dim_departments') }}
