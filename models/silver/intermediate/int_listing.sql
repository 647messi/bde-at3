-- Descriptive relationships only. Price, availability and reviews belong to facts.
select listing_id, host_id,
       listing_id as property_id,
       coalesce(listing_neighbourhood_key, '__UNKNOWN__') as location_key,
       scraped_date
from {{ ref('stg_airbnb') }}
