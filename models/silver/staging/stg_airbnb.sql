{# Cast through text so both typed and text Bronze columns are supported. #}
{% set columns = [
    'listing_id', 'scrape_id', 'scraped_date',
    'host_id', 'host_name', 'host_since', 'host_is_superhost',
    'host_neighbourhood', 'listing_neighbourhood',
    'property_type', 'room_type', 'accommodates', 'price',
    'has_availability', 'availability_30', 'number_of_reviews',
    'review_scores_rating', 'review_scores_accuracy',
    'review_scores_cleanliness', 'review_scores_checkin',
    'review_scores_communication', 'review_scores_value'
] %}

with cleaned as (
    select
        {% for column in columns %}
        nullif(btrim({{ column }}::text), '') as {{ column }}{% if not loop.last %},{% endif %}
        {% endfor %}
    -- Set once on the dbt Cloud job so all three steps read the same monthly table.
    from {{ source('bronze', env_var('DBT_AIRBNB_SOURCE_TABLE', 'airbnb_05_2020')) }}
),

typed as (
    select
        listing_id::bigint as listing_id,
        scrape_id::bigint as scrape_id,
        scraped_date::date as scraped_date,

        host_id::bigint as host_id,
        host_name,
        case
            when host_since ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
                then to_date(host_since, 'DD/MM/YYYY')
            else host_since::date
        end as host_since,
        host_is_superhost::boolean as host_is_superhost,
        host_neighbourhood,
        upper(host_neighbourhood) as host_neighbourhood_key,
        listing_neighbourhood,
        upper(listing_neighbourhood) as listing_neighbourhood_key,

        property_type,
        room_type,
        accommodates::integer as accommodates,

        -- Only remove currency formatting when it matches a supported format.
        -- Other malformed values fail the cast rather than silently becoming NULL.
        case
            when price ~ '^[$]?[0-9]{1,3}(,[0-9]{3})+([.][0-9]+)?$'
                or price ~ '^[$][0-9]+([.][0-9]+)?$'
                then replace(replace(price, '$', ''), ',', '')::numeric
            else price::numeric
        end as price,
        has_availability::boolean as has_availability,
        availability_30::integer as availability_30,
        number_of_reviews::integer as number_of_reviews,

        review_scores_rating::numeric as review_scores_rating,
        review_scores_accuracy::numeric as review_scores_accuracy,
        review_scores_cleanliness::numeric as review_scores_cleanliness,
        review_scores_checkin::numeric as review_scores_checkin,
        review_scores_communication::numeric as review_scores_communication,
        review_scores_value::numeric as review_scores_value
    from cleaned
)

select
    *,
    date_trunc('month', scraped_date)::date as month_date
from typed
