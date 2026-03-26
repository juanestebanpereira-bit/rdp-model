-- =============================================================================
-- int_classes.sql
-- =============================================================================
-- Intermediate class model. Reads from stg_classes, joins int_departments to
-- carry down department attributes. Customer columns from both sources pass
-- through automatically via SELECT * EXCEPT.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: rdp_staging.stg_classes
-- Joins:      int_departments (department_id)
-- =============================================================================

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
    COALESCE(departments.department_number, 'NOT_ASSIGNED')  AS department_number,
    COALESCE(departments.department_name,   'NOT ASSIGNED')  AS department_name,

    -- customer columns passthrough from stg_classes
    source.* EXCEPT (
        class_id,
        department_id,
        class_number,
        class_name,
        rdp_source_system
    ),

    -- customer columns passthrough from int_departments
    departments.* EXCEPT (
        department_id,
        department_number,
        department_name,
        rdp_source_system
    ),

    -- system columns
    source.rdp_source_system

FROM source
LEFT JOIN departments
    ON source.department_id = departments.department_id
