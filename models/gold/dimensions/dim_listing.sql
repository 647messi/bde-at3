-- Keep every SCD2 version, including closed historical versions.
select
    dbt_scd_id as listing_version_key,
    listing_id,
    host_id,
    property_id,
    location_key,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to
from {{ ref('snap_listing') }}
