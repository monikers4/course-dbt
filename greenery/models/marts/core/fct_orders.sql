with orders as (
    select * from {{ ref('stg_postgres__orders')}}
),

order_items as (
    select * from {{ ref('stg_postgres__order_items')}}
),

promos as (
    select * from {{ ref('stg_postgres__promos')}}
),

order_items_agg as (
    select 
    order_id,
    sum(quantity) order_quantity
    from order_items
    group by 1
)

select
-- ids 
    o.order_id
    ,o.promo_id
    ,o.user_id
    ,o.address_id
    ,tracking_id

-- timestamps
    ,o.created_at
    ,o.estimated_delivery_at
    ,o.delivered_at

-- order related details
    ,o.order_cost
    ,oia.order_quantity
    ,o.shipping_cost
    ,p.discount as order_discount
    ,o.order_total
    ,o.order_status

-- delivery related details
    ,o.shipping_service
    ,datediff(day, o.created_at, o.delivered_at) as order_transit_days
    ,datediff(hour, o.estimated_delivery_at, o.delivered_at) as delivery_estimate_difference_hours

from orders o
join order_items_agg oia
    on o.order_id = oia.order_id 
left join promos p
    on o.promo_id = p.promo_id
