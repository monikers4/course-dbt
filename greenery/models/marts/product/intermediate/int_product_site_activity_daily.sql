with events as 
(
    select * from {{ ref('stg_postgres__events')}}
),


product_event_agg as (
    select
        product_id
        ,created_at::date as activity_date
        ,count(case when event_type = 'page_view' then session_id end) as product_page_view
        ,count(case when event_type = 'add_to_cart' then session_id end) as product_add_to_cart

    from events

    where 
    event_type in ('page_view','add_to_cart')
    and product_id is not null

    group by 1,2
)

select
        {{ dbt_utils.generate_surrogate_key([
                'activity_date', 
                'product_id'
            ])
        }} as unique_key,
        *
        from product_event_agg