{{ config(materialized='view') }}

-- Version keys resolve attributes valid at the fact's observation date.
with monthly as (
    select
        n.listing_neighbourhood,
        f.month_date,
        count(*) as total_listings,
        count(*) filter (where f.is_active) as active_listings,
        count(*) filter (where f.is_active = false) as inactive_listings,
        min(f.price) filter (where f.is_active) as min_price,
        max(f.price) filter (where f.is_active) as max_price,
        percentile_cont(0.5) within group (
            order by f.price
        ) filter (where f.is_active) as median_price,
        avg(f.price) filter (where f.is_active) as avg_price,
        count(distinct h.host_id) as distinct_hosts,
        count(distinct h.host_id) filter (
            where h.host_is_superhost
        ) as superhosts,
        avg(f.review_scores_rating) filter (
            where f.is_active
        ) as avg_review_scores_rating,
        sum(f.number_of_stays) filter (
            where f.is_active
        ) as total_stays,
        avg(f.estimated_revenue) filter (
            where f.is_active
        ) as avg_estimated_revenue
    from {{ ref('fact_listing_monthly') }} f
    join {{ ref('dim_location') }} n
        on f.location_version_key = n.location_version_key
    join {{ ref('dim_host') }} h
        on f.host_version_key = h.host_version_key
    group by n.listing_neighbourhood, f.month_date
)

select
    c.listing_neighbourhood,
    c.month_date,
    100.0 * c.active_listings
        / nullif(c.total_listings, 0) as active_listings_rate,
    c.min_price,
    c.max_price,
    c.median_price,
    c.avg_price,
    c.distinct_hosts,
    100.0 * c.superhosts
        / nullif(c.distinct_hosts, 0) as superhost_rate,
    c.avg_review_scores_rating,
    100.0 * (c.active_listings - p.active_listings)
        / nullif(p.active_listings, 0) as active_listings_pct_change,
    100.0 * (c.inactive_listings - p.inactive_listings)
        / nullif(p.inactive_listings, 0) as inactive_listings_pct_change,
    coalesce(c.total_stays, 0) as total_stays,
    c.avg_estimated_revenue
from monthly c
-- Match the previous calendar month, including nullable grouping attributes.
left join monthly p
    on c.listing_neighbourhood is not distinct from p.listing_neighbourhood
    and p.month_date = (c.month_date - interval '1 month')::date
order by c.listing_neighbourhood, c.month_date
