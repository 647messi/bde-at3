-- Keep every SCD2 version, including closed historical versions.
select
    dbt_scd_id as host_version_key,
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    host_neighbourhood_key,
    host_neighbourhood_lga_code,
    host_neighbourhood_lga,
    mapping_status,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to
from {{ ref('snap_host') }}
