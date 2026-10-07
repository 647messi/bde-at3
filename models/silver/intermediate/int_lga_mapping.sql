-- One row per suburb. Ambiguous mappings stay visible without multiplying joins.
with pairs as (
    select distinct suburb_name_key, lga_name_key
    from {{ ref('stg_lga_suburb') }}
    where suburb_name_key is not null
), candidates as (
    select p.suburb_name_key, p.lga_name_key, c.lga_code, c.lga_name
    from pairs p
    left join {{ ref('stg_lga_code') }} c
        on p.lga_name_key = c.lga_name_key
), grouped as (
    select suburb_name_key,
           count(distinct lga_name_key) as lga_name_count,
           count(distinct lga_code) as lga_code_count,
           bool_or(lga_code is null) as has_unmatched_lga,
           min(lga_code) as candidate_code,
           min(lga_name) as candidate_name
    from candidates
    group by suburb_name_key
)
select suburb_name_key,
       case when lga_name_count = 1 and lga_code_count = 1 and not has_unmatched_lga
            then candidate_code end as lga_code,
       case when lga_name_count = 1 and lga_code_count = 1 and not has_unmatched_lga
            then candidate_name end as lga_name,
       case when lga_name_count > 1 or lga_code_count > 1 then 'ambiguous'
            when has_unmatched_lga or lga_code_count = 0 then 'unmatched'
            else 'matched' end as mapping_status
from grouped
