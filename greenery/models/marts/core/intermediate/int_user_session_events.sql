with events as (
    select * from {{ ref('stg_postgres__events') }}
),

user_session_agg as (
    select
        user_id
        , session_id
        {{ agg_event_types('stg_postgres__events', 'event_type') }}
        , min(created_at) as first_session_event_at_utc
        , max(created_at) as last_session_event_at_utc
    from events
    group by 1, 2
)


select 
        {{ dbt_utils.generate_surrogate_key([
            'user_id',
            'session_id']) }} as unique_key,
        *
from user_session_agg
