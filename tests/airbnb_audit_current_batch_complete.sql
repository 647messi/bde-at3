{% set batch = airbnb_batch() %}

with expected as (
    select source_table, listing_id, scraped_date, rejection_reason
    from {{ ref('stg_airbnb_date_anomalies') }}
), stored as (
    select source_table, listing_id, scraped_date, rejection_reason
    from {{ ref('audit_airbnb_date_anomalies') }}
    where source_table = '{{ batch["table"] }}'
), missing as (
    select * from expected
    except
    select * from stored
), unexpected as (
    select * from stored
    except
    select * from expected
)
select 'missing_audit_record' as issue, * from missing
union all
select 'unexpected_audit_record' as issue, * from unexpected
