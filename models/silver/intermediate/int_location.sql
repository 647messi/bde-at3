-- Listing neighbourhoods in the audited CSVs match LGA names directly.
-- Preserve one business key per observed neighbourhood for location snapshots.
with locations as (
    select coalesce(listing_neighbourhood_key, '__UNKNOWN__') as location_key,
           min(listing_neighbourhood) as listing_neighbourhood,
           min(scraped_date) as scraped_date
    from {{ ref('stg_airbnb') }}
    group by coalesce(listing_neighbourhood_key, '__UNKNOWN__')
), codes as (
    select lga_name_key, count(distinct lga_code) as code_count,
           min(lga_code) as lga_code, min(lga_name) as lga_name
    from {{ ref('stg_lga_code') }}
    group by lga_name_key
)
select l.location_key,
       coalesce(l.listing_neighbourhood, 'Unknown') as listing_neighbourhood,
       case when c.code_count = 1 then c.lga_code end as lga_code,
       case when c.code_count = 1 then c.lga_name else 'Unknown' end as lga_name,
       case when l.location_key = '__UNKNOWN__' then 'missing'
            when c.code_count > 1 then 'ambiguous'
            when c.code_count = 1 then 'matched'
            else 'unmatched' end as mapping_status,
       l.scraped_date
from locations l
left join codes c on l.location_key = c.lga_name_key
