with orders as (
    select * from {{ ref('stg_postgres__orders')}}
),

order_items as (
    select * from {{ ref('stg_postgres__order_items')}}
),

product_orders_agg as (
    select
        oi.product_id
        ,o.created_at::date as order_date
        ,count(distinct o.order_id) as orders
        ,sum(oi.quantity) as units

    from orders o
    join order_items oi
        on o.order_id = oi.order_id 

    group by 1,2
)

select 
        {{ dbt_utils.generate_surrogate_key([
                'order_date', 
                'product_id'
            ])
        }} as unique_key,
        *
from product_orders_agg 