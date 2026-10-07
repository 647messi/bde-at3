{% for entity, business_key in [
    ('host', 'host_id'), ('listing', 'listing_id'),
    ('property', 'property_id'), ('location', 'location_key')
] %}
select '{{ entity }}' as entity,
       a.{{ entity }}_version_key as version_key
from {{ ref('dim_' ~ entity) }} a
where (a.valid_to is not null and a.valid_to <= a.valid_from)
   or exists (
       select 1
       from {{ ref('dim_' ~ entity) }} b
       where a.{{ business_key }} = b.{{ business_key }}
         and a.{{ entity }}_version_key <> b.{{ entity }}_version_key
         and (b.valid_to is null or a.valid_from < b.valid_to)
         and (a.valid_to is null or b.valid_from < a.valid_to)
   )
{% if not loop.last %}union all{% endif %}
{% endfor %}
