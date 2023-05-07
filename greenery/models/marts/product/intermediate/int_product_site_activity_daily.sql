with events as 
(
    select * from {{ ref('stg_postgres__events')}}
),


product_event_agg as (
    select
        product_id
        ,created_at::date as activity_date
       -- Note: Product ids are only populated on page_view and add_to_cart events
        ,count(case when event_type = 'page_view' then session_id end) as page_view_count
        ,count(case when event_type = 'add_to_cart' then session_id end) as add_to_cart_count

    from events

    where 1=1
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