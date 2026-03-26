-- =============================================================================
-- vw_dim_classes.sql
-- =============================================================================
-- Stable public-facing view over dim_classes. Provides a consistent
-- interface to the physical dimension table, absorbing any breaking schema
-- changes before they reach downstream consumers.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: dim_classes
-- =============================================================================

SELECT *

FROM {{ ref('dim_classes') }}
