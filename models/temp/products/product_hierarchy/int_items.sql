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
    styles.class_id,
    styles.department_id,

    -- attributes
    source.item_number,
    source.item_name,

    -- carried down from int_styles
    styles.style_number,
    styles.style_name,
    styles.class_number,
    styles.class_name,
    styles.department_number,
    styles.department_name,

    -- customer columns passthrough
    {% if has_customer_columns(source('rdp_staging', 'stg_items'), contract) %}
        {{ customer_columns(source('rdp_staging', 'stg_items'), contract) }},
    {% endif %}

    -- system columns
    source.rdp_source_system

FROM source
LEFT JOIN styles
    ON source.style_id = styles.style_id
