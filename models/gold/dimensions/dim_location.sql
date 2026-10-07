-- Keep every SCD2 version, including closed historical versions.
select
    dbt_scd_id as location_version_key,
    location_key,
    listing_neighbourhood,
    lga_code,
    lga_name,
    mapping_status,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to
from {{ ref('snap_location') }}
