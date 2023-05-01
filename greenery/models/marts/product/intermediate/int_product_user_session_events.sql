with events as (
    select * from {{ ref('stg_postgres__events') }}
),

products as (
    select * from {{ ref('dim_products')}}
),

user_session_agg as (
    select
        events.user_id
        , events.session_id
        , events.product_id
        , products.product_name
        {{ agg_event_types('stg_postgres__events', 'event_type') }}
        , min(events.created_at) as first_session_event_at_utc
        , max(events.created_at) as last_session_event_at_utc
    from events
    left join products
        on events.product_id = products.product_id
    group by 1, 2, 3, 4
)


select 
        {{ dbt_utils.generate_surrogate_key([
            'user_id',
            'session_id',
            'product_id']) }} as unique_key,
        *
from user_session_agg
