-- =============================================================================
-- customer_columns.sql
-- =============================================================================
-- Three macros for handling dynamic customer column passthrough.
-- Used in int_, dim_, and fct_ models to safely include customer-added columns
-- (cust_* prefix) without failing when no customer columns exist.
--
-- has_customer_columns(relation, contract_columns)
--   Returns true if the relation has columns beyond the contract columns.
--   Use to conditionally include customer columns in SELECT.
--
-- customer_columns(relation, contract_columns)
--   Returns a comma-separated list of non-contract columns.
--   Only call this after confirming has_customer_columns is true.
--
-- sentinel_customer_columns(relation, contract_columns, sentinel_value)
--   Returns a comma-separated list of 'sentinel_value' AS col_name expressions
--   for each non-contract column. Use in UNION ALL sentinel rows to assign a
--   fixed value without needing a FROM clause. Defaults to 'UNKNOWN'.
--
-- Usage:
--   {% set contract = ['department_id', 'department_number', 'department_name', 'rdp_source_system'] %}
--   {% if has_customer_columns(source('rdp_staging', 'stg_departments'), contract) %}
--       {{ customer_columns(source('rdp_staging', 'stg_departments'), contract) }},
--   {% endif %}
--
--   -- in a UNION ALL sentinel row:
--   {% if has_customer_columns(source('rdp_staging', 'stg_departments'), contract) %}
--       {{ sentinel_customer_columns(source('rdp_staging', 'stg_departments'), contract) }},
--   {% endif %}
-- =============================================================================

{% macro has_customer_columns(relation, contract_columns) %}
    {%- set cols = adapter.get_columns_in_relation(relation) -%}
    {%- set excluded = contract_columns | map('lower') | list -%}
    {%- set cust_cols = [] -%}
    {%- for col in cols -%}
        {%- if col.name | lower not in excluded -%}
            {%- do cust_cols.append(col.name) -%}
        {%- endif -%}
    {%- endfor -%}
    {{ return(cust_cols | length > 0) }}
{% endmacro %}

{% macro customer_columns(relation, contract_columns) %}
    {%- set cols = adapter.get_columns_in_relation(relation) -%}
    {%- set excluded = contract_columns | map('lower') | list -%}
    {%- set cust_cols = [] -%}
    {%- for col in cols -%}
        {%- if col.name | lower not in excluded -%}
            {%- do cust_cols.append(col.name) -%}
        {%- endif -%}
    {%- endfor -%}
    {%- for col in cust_cols -%}
        {{ col }}{% if not loop.last %},{% endif %}
    {%- endfor -%}
{% endmacro %}

{% macro sentinel_customer_columns(relation, contract_columns, sentinel_value='UNKNOWN') %}
    {%- set cols = adapter.get_columns_in_relation(relation) -%}
    {%- set excluded = contract_columns | map('lower') | list -%}
    {%- set cust_cols = [] -%}
    {%- for col in cols -%}
        {%- if col.name | lower not in excluded -%}
            {%- do cust_cols.append(col.name) -%}
        {%- endif -%}
    {%- endfor -%}
    {%- for col in cust_cols -%}
        '{{ sentinel_value }}' AS {{ col }}{% if not loop.last %},{% endif %}
    {%- endfor -%}
{% endmacro %}