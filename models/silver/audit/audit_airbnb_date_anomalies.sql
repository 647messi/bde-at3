{% set batch = airbnb_batch() %}
{{
    config(
        schema='silver',
        materialized='incremental',
        unique_key=['source_table', 'listing_id'],
        incremental_strategy='delete+insert',
        on_schema_change='fail',
        pre_hook=(
            "delete from " ~ this ~ " where source_table = '" ~ batch['table'] ~ "'"
        ) if is_incremental() else []
    )
}}

-- Persist all original fields and rejection metadata from the current batch.
-- Replace this batch's audit rows on reruns, even if corrections leave zero errors.
-- Other months remain; PostgreSQL runs the pre-hook and insertion in one transaction.
-- Full refresh only rebuilds the current batch, so historical audits require replay.
select
    *,
    current_timestamp as audited_at
from {{ ref('stg_airbnb_date_anomalies') }}
