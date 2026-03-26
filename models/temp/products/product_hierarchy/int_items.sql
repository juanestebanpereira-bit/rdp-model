-- =============================================================================
-- int_items.sql
-- =============================================================================
-- Intermediate item model. Reads from stg_items, joins int_styles to carry
-- down style, class, and department attributes. Customer columns from stg_items
-- pass through dynamically via customer_columns macro.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: rdp_staging.stg_items
-- Joins:      int_styles (style_id)
-- =============================================================================

{% set contract = ['item_id', 'style_id', 'class_id', 'department_id', 'item_number', 'item_name', 'style_number', 'style_name', 'class_number', 'class_name', 'department_number', 'department_name', 'rdp_source_system'] %}

WITH source AS (
    SELECT * FROM {{ source('rdp_staging', 'stg_items') }}
),

styles AS (
    SELECT * FROM {{ ref('int_styles') }}
)

SELECT
    -- primary key
    source.item_id,

    -- foreign keys
    source.style_id,
    COALESCE(styles.class_id,          'NOT_ASSIGNED')  AS class_id,
    COALESCE(styles.department_id,     'NOT_ASSIGNED')  AS department_id,

    -- attributes
    source.item_number,
    source.item_name,

    -- carried down from int_styles
    COALESCE(styles.style_number,      'NOT_ASSIGNED')  AS style_number,
    COALESCE(styles.style_name,        'NOT ASSIGNED')  AS style_name,
    COALESCE(styles.class_number,      'NOT_ASSIGNED')  AS class_number,
    COALESCE(styles.class_name,        'NOT ASSIGNED')  AS class_name,
    COALESCE(styles.department_number, 'NOT_ASSIGNED')  AS department_number,
    COALESCE(styles.department_name,   'NOT ASSIGNED')  AS department_name,

    -- customer columns passthrough
    {% if has_customer_columns(source('rdp_staging', 'stg_items'), contract) %}
        {{ customer_columns(source('rdp_staging', 'stg_items'), contract) }},
    {% endif %}

    -- system columns
    source.rdp_source_system

FROM source
LEFT JOIN styles
    ON source.style_id = styles.style_id

UNION ALL

SELECT
    'NOT_ASSIGNED'  AS item_id,
    'NOT_ASSIGNED'  AS style_id,
    'NOT_ASSIGNED'  AS class_id,
    'NOT_ASSIGNED'  AS department_id,
    'NOT_ASSIGNED'  AS item_number,
    'Not Assigned'  AS item_name,
    'NOT_ASSIGNED'  AS style_number,
    'Not Assigned'  AS style_name,
    'NOT_ASSIGNED'  AS class_number,
    'Not Assigned'  AS class_name,
    'NOT_ASSIGNED'  AS department_number,
    'Not Assigned'  AS department_name,

    {% if has_customer_columns(source('rdp_staging', 'stg_items'), contract) %}
        {{ sentinel_customer_columns(source('rdp_staging', 'stg_items'), contract) }},
    {% endif %}

    'NOT_ASSIGNED'  AS rdp_source_system
