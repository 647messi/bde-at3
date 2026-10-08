-- Sort versions once per business key instead of repeatedly self-joining tables.
with versions as (
    {% for entity, business_key in [
        ('host', 'host_id'), ('listing', 'listing_id'),
        ('property', 'property_id'), ('location', 'location_key')
    ] %}
    select '{{ entity }}' as entity,
           {{ business_key }}::text as business_key,
           {{ entity }}_version_key as version_key,
           valid_from,
           valid_to
    from {{ ref('dim_' ~ entity) }}
    {% if not loop.last %}union all{% endif %}
    {% endfor %}
), ordered as (
    select *,
           max(valid_to) over (
               partition by entity, business_key
               order by valid_from, version_key
               rows between unbounded preceding and 1 preceding
           ) as prior_max_valid_to,
           count(*) filter (where valid_to is null) over (
               partition by entity, business_key
               order by valid_from, version_key
               rows between unbounded preceding and 1 preceding
           ) as prior_open_versions
    from versions
)
select entity, business_key, version_key
from ordered
where valid_from is null
   or (valid_to is not null and valid_to <= valid_from)
   or valid_from < prior_max_valid_to
   or prior_open_versions > 0
