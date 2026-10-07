-- Keep the readable name and a separate key for case-insensitive joins.
select
    nullif(btrim(lga_code::text), '')::integer as lga_code,
    nullif(btrim(lga_name::text), '') as lga_name,
    upper(nullif(btrim(lga_name::text), '')) as lga_name_key
from {{ source('bronze', 'nsw_lga_code') }}
