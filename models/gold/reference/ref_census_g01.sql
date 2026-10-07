-- Static 2016 Census reference data; retain codes without a mapping match.
select *
from {{ ref('stg_census_g01') }}
