{% set batch = airbnb_batch() %}

-- Every raw row must appear in either accepted staging or the anomaly view.
select 'raw_row_count_not_conserved' as issue
where (select count(*) from {{ source('bronze', batch['table']) }})
   <> (select count(*) from {{ ref('stg_airbnb') }})
      + (select count(*) from {{ ref('stg_airbnb_date_anomalies') }})
