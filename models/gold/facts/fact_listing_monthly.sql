{{
    config(
        materialized='incremental',
        unique_key=['listing_id', 'month_date'],
        incremental_strategy='delete+insert',
        on_schema_change='fail'
    )
}}

-- Current monthly batch only. Incremental reruns replace that batch's keys;
-- previously loaded months remain. Load snapshots before loading this fact.
-- Full refresh requires replaying all monthly batches to recover fact history.
select
    a.listing_id,
    a.scraped_date,
    a.month_date,
    l.listing_version_key,
    h.host_version_key,
    p.property_version_key,
    n.location_version_key,
    a.price,
    a.has_availability as is_active,
    a.availability_30,
    a.number_of_reviews,
    a.review_scores_rating,
    a.review_scores_accuracy,
    a.review_scores_cleanliness,
    a.review_scores_checkin,
    a.review_scores_communication,
    a.review_scores_value,
    case when a.has_availability then 30 - a.availability_30
         when a.has_availability = false then 0 end as number_of_stays,
    case when a.has_availability then (30 - a.availability_30) * a.price
         when a.has_availability = false then 0 end as estimated_revenue
from {{ ref('stg_airbnb') }} a
left join {{ ref('dim_listing') }} l
    on a.listing_id = l.listing_id
    and a.scraped_date >= l.valid_from
    and (a.scraped_date < l.valid_to or l.valid_to is null)
left join {{ ref('dim_host') }} h
    on l.host_id = h.host_id
    and a.scraped_date >= h.valid_from
    and (a.scraped_date < h.valid_to or h.valid_to is null)
left join {{ ref('dim_property') }} p
    on l.property_id = p.property_id
    and a.scraped_date >= p.valid_from
    and (a.scraped_date < p.valid_to or p.valid_to is null)
left join {{ ref('dim_location') }} n
    on l.location_key = n.location_key
    and a.scraped_date >= n.valid_from
    and (a.scraped_date < n.valid_to or n.valid_to is null)
