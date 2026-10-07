{% snapshot snap_location %}

{{
    config(
        target_schema='silver',
        unique_key='location_key',
        strategy='timestamp',
        updated_at='scraped_date'
    )
}}

select *
from {{ ref('int_location') }}

{% endsnapshot %}
