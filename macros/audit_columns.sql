-- =============================================================================
-- audit_columns.sql
-- =============================================================================
-- Generates standard RDP audit columns for all dimension and fact tables.
-- Call at the end of every dim_ and fct_ SELECT statement.
--
-- Arguments:
--   source_system: string identifying the source system (e.g. 'olist', 'sap')
--
-- Usage:
--   {{ audit_columns('olist') }}
-- =============================================================================

{% macro audit_columns(source_system) %}
    '{{ source_system }}'           AS rdp_source_system,
    CURRENT_TIMESTAMP()             AS rdp_created_at,
    CURRENT_TIMESTAMP()             AS rdp_updated_at
{% endmacro %}