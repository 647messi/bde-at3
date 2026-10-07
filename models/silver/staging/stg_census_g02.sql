-- Normalize Census LGA codes to the same integer key as the mapping table.
select
    regexp_replace(upper(nullif(btrim(lga_code_2016::text), '')), '^LGA', '')::integer as lga_code,
    2016::integer as census_year,
    nullif(btrim(median_age_persons::text), '')::integer as median_age_persons,
    nullif(btrim(median_mortgage_repay_monthly::text), '')::integer as median_mortgage_repay_monthly,
    nullif(btrim(median_tot_prsnl_inc_weekly::text), '')::integer as median_tot_prsnl_inc_weekly,
    nullif(btrim(median_rent_weekly::text), '')::integer as median_rent_weekly,
    nullif(btrim(median_tot_fam_inc_weekly::text), '')::integer as median_tot_fam_inc_weekly,
    nullif(btrim(average_num_psns_per_bedroom::text), '')::numeric as average_num_psns_per_bedroom,
    nullif(btrim(median_tot_hhd_inc_weekly::text), '')::integer as median_tot_hhd_inc_weekly,
    nullif(btrim(average_household_size::text), '')::numeric as average_household_size
from {{ source('bronze', 'census_g02_nsw_lga') }}
