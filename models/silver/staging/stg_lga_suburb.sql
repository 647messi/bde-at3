-- Select only useful source columns; ignore empty CSV trailing columns.
-- Preserve mappings here, including ambiguous suburbs, for downstream checks.
select
    nullif(btrim(lga_name::text), '') as lga_name,
    upper(nullif(btrim(lga_name::text), '')) as lga_name_key,
    nullif(btrim(suburb_name::text), '') as suburb_name,
    upper(nullif(btrim(suburb_name::text), '')) as suburb_name_key
from {{ source('bronze', 'nsw_lga_suburb') }}
