-- Every observed listing must survive entity decomposition.
select 'listing_row_count_mismatch' as issue
where (select count(*) from {{ ref('int_listing') }})
   <> (select count(*) from {{ ref('stg_airbnb') }})
