-- Earliest observation per host in the current batch: a deterministic snapshot input.
-- A separate test rejects conflicting attributes within the batch.
with ranked as (
    select *,
           row_number() over (
               partition by host_id
               order by scraped_date, listing_id
           ) as host_row_number
    from {{ ref('stg_airbnb') }}
), hosts as (
    select * from ranked where host_row_number = 1
)
select h.host_id, h.host_name, h.host_since, h.host_is_superhost,
       h.host_neighbourhood, h.host_neighbourhood_key,
       m.lga_code as host_neighbourhood_lga_code,
       case when h.host_neighbourhood_key is null then 'Unknown'
            when h.host_neighbourhood_key = 'OVERSEAS' then 'Overseas'
            else coalesce(m.lga_name, 'Unknown') end as host_neighbourhood_lga,
       case when h.host_neighbourhood_key is null then 'missing'
            when h.host_neighbourhood_key = 'OVERSEAS' then 'overseas'
            else coalesce(m.mapping_status, 'unmatched') end as mapping_status,
       h.scraped_date
from hosts h
left join {{ ref('int_lga_mapping') }} m
    on h.host_neighbourhood_key = m.suburb_name_key
