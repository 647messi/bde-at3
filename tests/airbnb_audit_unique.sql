select source_table, listing_id, count(*) as row_count
from {{ ref('audit_airbnb_date_anomalies') }}
group by source_table, listing_id
having count(*) > 1
