{% snapshot snap_listing %}

{{
    config(
        target_schema='silver',
        unique_key='listing_id',
        strategy='timestamp',
        updated_at='scraped_date'
    )
}}

select *
from {{ ref('int_listing') }}

{% endsnapshot %}
