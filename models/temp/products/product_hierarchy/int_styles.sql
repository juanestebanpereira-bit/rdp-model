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
    classes.department_id,

    -- attributes
    source.style_number,
    source.style_name,

    -- carried down from int_classes
    classes.class_number,
    classes.class_name,
    classes.department_number,
    classes.department_name,

    -- customer columns passthrough
    {% if has_customer_columns(source('rdp_staging', 'stg_styles'), contract) %}
        {{ customer_columns(source('rdp_staging', 'stg_styles'), contract) }},
    {% endif %}

    -- system columns
    source.rdp_source_system

FROM source
LEFT JOIN classes
    ON source.class_id = classes.class_id
