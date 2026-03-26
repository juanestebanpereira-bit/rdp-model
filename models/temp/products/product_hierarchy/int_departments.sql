-- =============================================================================
-- int_departments.sql
-- =============================================================================
-- Intermediate department model. Reads from stg_departments and adds
-- audit columns. Customer columns from stg_departments pass through
-- automatically via SELECT * EXCEPT.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: rdp_staging.stg_departments
-- =============================================================================

WITH source AS (
    SELECT *, NULL as department_dummy FROM {{ source('rdp_staging', 'stg_departments') }}
)

SELECT
    -- primary key
    department_id,

    -- attributes
    department_number,
    department_name,

    -- customer columns passthrough
    * EXCEPT (
        department_id,
        department_number,
        department_name,
        rdp_source_system
    ),

    -- system columns
    rdp_source_system

FROM source