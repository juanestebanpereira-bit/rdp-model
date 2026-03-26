-- =============================================================================
-- vw_dim_styles.sql
-- =============================================================================
-- Stable public-facing view over dim_styles. Provides a consistent
-- interface to the physical dimension table, absorbing any breaking schema
-- changes before they reach downstream consumers.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: dim_styles
-- =============================================================================

SELECT *

FROM {{ ref('dim_styles') }}
