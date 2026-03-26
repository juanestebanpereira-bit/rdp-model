-- =============================================================================
-- vw_dim_items.sql
-- =============================================================================
-- Stable public-facing view over dim_items. Provides a consistent
-- interface to the physical dimension table, absorbing any breaking schema
-- changes before they reach downstream consumers.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: dim_items
-- =============================================================================

SELECT *

FROM {{ ref('dim_items') }}
