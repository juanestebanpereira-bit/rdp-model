-- =============================================================================
-- int_departments.sql
-- =============================================================================
-- Intermediate department model. Reads from stg_departments and adds
-- audit columns. Customer columns from stg_departments pass through
-- dynamically via customer_columns macro.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: rdp_staging.stg_departments
-- =============================================================================

{% set contract = ['department_id', 'department_number', 'department_name', 'rdp_source_system'] %}

WITH source AS (
    SELECT * FROM {{ source('rdp_staging', 'stg_departments') }}
)

SELECT
    -- primary key
    department_id,

    -- attributes
    department_number,
    department_name,

    -- customer columns passthrough
    {% if has_customer_columns(source('rdp_staging', 'stg_departments'), contract) %}
        {{ customer_columns(source('rdp_staging', 'stg_departments'), contract) }},
    {% endif %}

    -- system columns
    rdp_source_system

FROM source
