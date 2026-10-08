{{ config(materialized='view') }}
{% set batch = airbnb_batch() %}

-- Audit view for the currently selected batch. Historical raw rows remain in Bronze.
select
    raw.*,
    '{{ batch["table"] }}'::text as source_table,
    date '{{ batch["month_date"] }}' as expected_month_date,
    case when raw.scraped_date is null then 'missing_scraped_date'
         else 'scraped_date_outside_file_month' end as rejection_reason
from {{ source('bronze', batch['table']) }} raw
where raw.scraped_date is null
   or date_trunc('month', raw.scraped_date::date)::date
       <> date '{{ batch["month_date"] }}'
