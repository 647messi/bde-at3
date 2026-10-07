-- Existing historical facts must continue to reference their valid SCD2 versions.
select f.listing_id, f.month_date
from {{ ref('fact_listing_monthly') }} f
left join {{ ref('dim_listing') }} l on f.listing_version_key = l.listing_version_key
left join {{ ref('dim_host') }} h on f.host_version_key = h.host_version_key
left join {{ ref('dim_property') }} p on f.property_version_key = p.property_version_key
left join {{ ref('dim_location') }} n on f.location_version_key = n.location_version_key
where l.listing_version_key is null
   or h.host_version_key is null
   or p.property_version_key is null
   or n.location_version_key is null
   or l.listing_id <> f.listing_id
   or h.host_id <> l.host_id
   or p.property_id <> l.property_id
   or n.location_key <> l.location_key
   or f.scraped_date < l.valid_from
   or (l.valid_to is not null and f.scraped_date >= l.valid_to)
   or f.scraped_date < h.valid_from
   or (h.valid_to is not null and f.scraped_date >= h.valid_to)
   or f.scraped_date < p.valid_from
   or (p.valid_to is not null and f.scraped_date >= p.valid_to)
   or f.scraped_date < n.valid_from
   or (n.valid_to is not null and f.scraped_date >= n.valid_to)
