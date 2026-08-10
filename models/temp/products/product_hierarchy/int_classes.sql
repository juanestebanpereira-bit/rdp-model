-- =============================================================================
-- int_classes.sql
-- =============================================================================
-- Intermediate class model. Reads from stg_classes, joins int_departments to
-- carry down department attributes. Customer columns from stg_classes pass
-- through dynamically via customer_columns macro.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: rdp_staging.stg_classes
-- Joins:      int_departments (department_id)
-- =============================================================================

{% set contract = ['class_id', 'department_id', 'class_number', 'class_name', 'department_number', 'department_name', 'rdp_source_system'] %}

WITH source AS (
    SELECT * FROM {{ source('rdp_staging', 'stg_classes') }}
),

departments AS (
    SELECT * FROM {{ ref('int_departments') }}
)

SELECT
    -- primary key
    source.class_id,

    -- foreign key
    source.department_id,

    -- attributes
    source.class_number,
    source.class_name,

    -- carried down from int_departments
    departments.department_number,
    departments.department_name,

    -- customer columns passthrough
    {% if has_customer_columns(source('rdp_staging', 'stg_classes'), contract) %}
        {{ customer_columns(source('rdp_staging', 'stg_classes'), contract) }},
    {% endif %}

    -- system columns
    source.rdp_source_system

FROM source
LEFT JOIN departments
    ON source.department_id = departments.department_id
