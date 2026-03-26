-- =============================================================================
-- int_items.sql
-- =============================================================================
-- Intermediate item model. Reads from stg_items, joins int_styles to carry
-- down style, class, and department attributes. Customer columns from both
-- sources pass through automatically via SELECT * EXCEPT.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: rdp_staging.stg_items
-- Joins:      int_styles (style_id)
-- =============================================================================

WITH source AS (
    SELECT * FROM {{ source('rdp_staging', 'stg_items') }}
),

styles AS (
    SELECT * FROM {{ ref('int_styles') }}
)

SELECT
    -- primary key
    source.item_id,

    -- foreign key
    source.style_id,

    -- attributes
    source.item_number,
    source.item_name,

    -- carried down from int_styles
    COALESCE(styles.style_number,      'NOT_ASSIGNED')  AS style_number,
    COALESCE(styles.style_name,        'NOT ASSIGNED')  AS style_name,
    COALESCE(styles.class_id,          'NOT_ASSIGNED')  AS class_id,
    COALESCE(styles.class_number,      'NOT_ASSIGNED')  AS class_number,
    COALESCE(styles.class_name,        'NOT ASSIGNED')  AS class_name,
    COALESCE(styles.department_id,     'NOT_ASSIGNED')  AS department_id,
    COALESCE(styles.department_number, 'NOT_ASSIGNED')  AS department_number,
    COALESCE(styles.department_name,   'NOT ASSIGNED')  AS department_name,

    -- customer columns passthrough from stg_items
    source.* EXCEPT (
        item_id,
        style_id,
        item_number,
        item_name,
        rdp_source_system
    ),

    -- customer columns passthrough from int_styles
    styles.* EXCEPT (
        style_id,
        class_id,
        style_number,
        style_name,
        class_number,
        class_name,
        department_id,
        department_number,
        department_name,
        rdp_source_system
    ),

    -- system columns
    source.rdp_source_system

FROM source
LEFT JOIN styles
    ON source.style_id = styles.style_id
