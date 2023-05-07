with product_user_sessions as  (
    select * from {{ ref ('int_product_user_session_events')}}
)

select * from product_user_sessions