{% snapshot snap_property %}

{{
    config(
        target_schema='silver',
        unique_key='property_id',
        strategy='timestamp',
        updated_at='scraped_date'
    )
}}

select *
from {{ ref('int_property') }}

{% endsnapshot %}
