-- Keep every SCD2 version, including closed historical versions.
select
    dbt_scd_id as property_version_key,
    property_id,
    property_type,
    room_type,
    accommodates,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to
from {{ ref('snap_property') }}
