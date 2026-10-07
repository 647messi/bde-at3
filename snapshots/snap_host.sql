{% snapshot snap_host %}

{{
    config(
        target_schema='silver',
        unique_key='host_id',
        strategy='timestamp',
        updated_at='scraped_date'
    )
}}

select *
from {{ ref('int_host') }}

{% endsnapshot %}
