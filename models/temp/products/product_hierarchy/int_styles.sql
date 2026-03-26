-- =============================================================================
-- int_styles.sql
-- =============================================================================
-- Intermediate style model. Reads from stg_styles, joins int_classes to
-- carry down class and department attributes. Customer columns from both
-- sources pass through automatically via SELECT * EXCEPT.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: rdp_staging.stg_styles
-- Joins:      int_classes (class_id)
-- =============================================================================

WITH source AS (
    SELECT * FROM {{ source('rdp_staging', 'stg_styles') }}
),

classes AS (
    SELECT * FROM {{ ref('int_classes') }}
)

SELECT
    -- primary key
    source.style_id,

    -- foreign key
    source.class_id,

    -- attributes
    source.style_number,
    source.style_name,

    -- carried down from int_classes
    COALESCE(classes.class_number,      'NOT_ASSIGNED')  AS class_number,
    COALESCE(classes.class_name,        'NOT ASSIGNED')  AS class_name,
    COALESCE(classes.department_id,     'NOT_ASSIGNED')  AS department_id,
    COALESCE(classes.department_number, 'NOT_ASSIGNED')  AS department_number,
    COALESCE(classes.department_name,   'NOT ASSIGNED')  AS department_name,

    -- customer columns passthrough from stg_styles
    source.* EXCEPT (
        style_id,
        class_id,
        style_number,
        style_name,
        rdp_source_system
    ),

    -- customer columns passthrough from int_classes
    classes.* EXCEPT (
        class_id,
        department_id,
        class_number,
        class_name,
        department_number,
        department_name,
        rdp_source_system
    ),

    -- system columns
    source.rdp_source_system

FROM source
LEFT JOIN classes
    ON source.class_id = classes.class_id
