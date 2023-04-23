with 

products as (
    select * from {{ ref('stg_postgres__products') }}
)

select
product_id
,product_name
,price   -- Assumption is that price is fixed or based on current
-- ,inventory -- Refer to products_snapshot for inventory

from products
