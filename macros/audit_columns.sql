-- =============================================================================
-- audit_columns.sql
-- =============================================================================
-- Generates standard RDP audit columns for all dimension and fact tables.
-- Call at the end of every dim_ and fct_ SELECT statement, after all
-- business columns and before customer columns (cust_*).
--
-- rdp_source_system is NOT generated here — it is provided by the customer
-- in the staging layer and flows through via the int_ models.
--
-- Usage:
--   {{ audit_columns() }}
--
-- Generates:
--   rdp_created_at   TIMESTAMP — time of last dbt run (full refresh)
--   rdp_updated_at   TIMESTAMP — time of last dbt run (full refresh)
--
-- Note: Switch to incremental materialization for true record-level
-- audit timestamps.
-- =============================================================================

{% macro audit_columns() %}
    CURRENT_TIMESTAMP()             AS rdp_created_at,
    CURRENT_TIMESTAMP()             AS rdp_updated_at
{% endmacro %}
