-- Prevent host deduplication from silently selecting conflicting batch attributes.
-- JSON arrays include NULL, so missing-vs-present conflicts are also detected.
select host_id
from {{ ref('stg_airbnb') }}
group by host_id
having count(distinct jsonb_build_array(
    host_name, host_since, host_is_superhost, host_neighbourhood_key
)) > 1
