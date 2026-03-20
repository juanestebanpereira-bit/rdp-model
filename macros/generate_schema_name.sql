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
        -- No schema override defined — use target dataset as-is.
        -- This should only apply to the default dataset (dev_rdp_client).
        {{ target.schema }}

    {%- else -%}
        -- Prepend environment prefix from target name to custom schema name.
        -- target.name is set in profiles.yml (dev, tst, or prd).
        {{ target.name }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}