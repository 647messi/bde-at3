select listing_id, month_date, count(*) as row_count
from {{ ref('fact_listing_monthly') }}
group by listing_id, month_date
having count(*) > 1
