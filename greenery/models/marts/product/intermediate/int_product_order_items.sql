with orders as (
    select * from {{ ref('stg_postgres__orders')}}
),

order_items as (
    select * from {{ ref('stg_postgres__order_items')}}
),

products as (
    select * from {{ ref('dim_products')}}
),

combined as (
    select
        oi.product_id
        ,o.order_id
        ,o.user_id
        ,o.created_at as order_at
        ,p.product_name
        ,oi.quantity
        ,p.price
        ,p.price * oi.quantity as revenue
        ,o.order_status

    from orders o
    join order_items oi
        on o.order_id = oi.order_id 
    join products p
        on oi.product_id = p.product_id
)

select
        {{ dbt_utils.generate_surrogate_key([
                'product_id',
                'order_id', 
                'user_id',
                'order_at'
            ])
        }} as unique_key,
        *
        from combined

