with source as (
    select * from {{ source('postgres','order_items') }}
),

final as 
(
    select 
    order_id
    ,product_id
    ,quantity

    from source 
)
select *, order_id || '-' || product_id as unique_id from final