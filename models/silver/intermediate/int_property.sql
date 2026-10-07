-- Property configuration belongs to a listing and can change over time.
-- Use listing_id as the snapshot business key; Gold will use a version surrogate key.
select listing_id as property_id,
       property_type, room_type, accommodates, scraped_date
from {{ ref('stg_airbnb') }}
