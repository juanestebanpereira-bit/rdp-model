-- =============================================================================
-- int_styles.sql
-- =============================================================================
-- Intermediate style model. Reads from stg_styles, joins int_classes to
-- carry down class and department attributes. Customer columns from stg_styles
-- pass through dynamically via customer_columns macro.
--
-- Component:  Product Hierarchy
-- Owner:      RDP Product Team
-- Reads from: rdp_staging.stg_styles
-- Joins:      int_classes (class_id)
-- =============================================================================

{% set contract = ['style_id', 'class_id', 'department_id', 'style_number', 'style_name', 'class_number', 'class_name', 'department_number', 'department_name', 'rdp_source_system'] %}

WITH source AS (
    SELECT * FROM {{ source('rdp_staging', 'stg_styles') }}
),

classes AS (
    SELECT * FROM {{ ref('int_classes') }}
)

SELECT
    -- primary key
    source.style_id,

    -- foreign keys
    source.class_id,
    COALESCE(classes.department_id,     'NOT_ASSIGNED')  AS department_id,

    -- attributes
    source.style_number,
    source.style_name,

    -- carried down from int_classes
    COALESCE(classes.class_number,      'NOT_ASSIGNED')  AS class_number,
    COALESCE(classes.class_name,        'NOT ASSIGNED')  AS class_name,
    COALESCE(classes.department_number, 'NOT_ASSIGNED')  AS department_number,
    COALESCE(classes.department_name,   'NOT ASSIGNED')  AS department_name,

    -- customer columns passthrough
    {% if has_customer_columns(source('rdp_staging', 'stg_styles'), contract) %}
        {{ customer_columns(source('rdp_staging', 'stg_styles'), contract) }},
    {% endif %}

    -- system columns
    source.rdp_source_system

FROM source
LEFT JOIN classes
    ON source.class_id = classes.class_id

UNION ALL

SELECT
    'NOT_ASSIGNED'  AS style_id,
    'NOT_ASSIGNED'  AS class_id,
    'NOT_ASSIGNED'  AS department_id,
    'NOT_ASSIGNED'  AS style_number,
    'Not Assigned'  AS style_name,
    'NOT_ASSIGNED'  AS class_number,
    'Not Assigned'  AS class_name,
    'NOT_ASSIGNED'  AS department_number,
    'Not Assigned'  AS department_name,

    {% if has_customer_columns(source('rdp_staging', 'stg_styles'), contract) %}
        {{ sentinel_customer_columns(source('rdp_staging', 'stg_styles'), contract) }},
    {% endif %}

    'NOT_ASSIGNED'  AS rdp_source_system
