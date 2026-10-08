{% snapshot snap_host %}

{{
    config(
        target_schema='silver',
        unique_key='host_id',
        strategy='timestamp',
        updated_at='snapshot_updated_at'
    )
}}

-- Match the snapshot timestamp columns while preserving the observed date.
select
    *,
    scraped_date::timestamp as snapshot_updated_at
from {{ ref('int_host') }}

{% endsnapshot %}
