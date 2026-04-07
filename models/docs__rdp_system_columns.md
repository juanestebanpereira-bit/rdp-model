{#
  Doc blocks for RDP platform-level system columns.

  These columns are present on every dim_ and fct_ table and their
  corresponding views, regardless of subject area or component.
  Keeping them in a dedicated file ensures they are available without
  depending on any particular component being implemented first.
#}

{% docs rdp_source_system %}
Identifies the source system that provided the record. Supplied by the
customer in the staging layer and flows through unchanged to all downstream
tables. Used for data lineage and multi-source reconciliation.
{% enddocs %}

{% docs rdp_created_at %}
Timestamp of the dbt run that first materialized this record. Set to
CURRENT_TIMESTAMP() at load time. Reflects full-refresh run time, not
true record creation time, until incremental materialization is adopted.
{% enddocs %}

{% docs rdp_updated_at %}
Timestamp of the dbt run that last materialized this record. Set to
CURRENT_TIMESTAMP() at load time. Reflects full-refresh run time, not
true record update time, until incremental materialization is adopted.
{% enddocs %}
