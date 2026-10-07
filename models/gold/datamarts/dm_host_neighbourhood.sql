{{ config(materialized='view') }}

-- Use historical host versions; distinguish Overseas from Unknown.
select
    h.host_neighbourhood_lga,
    f.month_date,
    count(distinct h.host_id) as distinct_hosts,
    avg(f.estimated_revenue) filter (
        where f.is_active
    ) as avg_estimated_revenue,
    coalesce(
        sum(f.estimated_revenue) filter (where f.is_active),
        0
    ) / nullif(
        count(distinct h.host_id),
        0
    ) as estimated_revenue_per_host
from {{ ref('fact_listing_monthly') }} f
join {{ ref('dim_host') }} h
    on f.host_version_key = h.host_version_key
group by h.host_neighbourhood_lga, f.month_date
order by h.host_neighbourhood_lga, f.month_date
