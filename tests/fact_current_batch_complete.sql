-- Each source observation must have exactly one fact with four non-null versions.
-- Missing facts and multiplied temporal joins both fail this test.
select a.listing_id, a.month_date
from {{ ref('stg_airbnb') }} a
left join {{ ref('fact_listing_monthly') }} f
    on a.listing_id = f.listing_id
    and a.month_date = f.month_date
    and a.scraped_date = f.scraped_date
group by a.listing_id, a.month_date
having count(f.listing_id) <> 1
    or count(f.listing_version_key) <> 1
    or count(f.host_version_key) <> 1
    or count(f.property_version_key) <> 1
    or count(f.location_version_key) <> 1
