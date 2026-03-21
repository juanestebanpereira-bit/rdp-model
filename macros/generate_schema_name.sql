-- =============================================================================
-- generate_schema_name.sql — rtl_rdp (Retail Data Platform)
-- =============================================================================
-- Overrides dbt's default schema naming behavior to prepend the environment
-- prefix (dev/tst/prd) to all dataset names. This ensures models land in
-- the correct BigQuery dataset for each environment without hardcoding
-- environment names in model files.
--
-- Examples:
--   dev  + rdp_dwh        → dev_rdp_dwh
--   tst  + rdp_mart       → tst_rdp_mart
--   prd  + rdp_mart_views → prd_rdp_mart_views
-- =============================================================================

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if custom_schema_name is none -%}
        {{ target.name }}_{{ target.schema }}
    {%- else -%}
        {{ target.name }}_{{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}