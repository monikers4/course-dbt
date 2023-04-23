with 

users as (
    select * from {{ ref('stg_postgres__users') }}
)

,addresses as (
    select * from {{ ref('stg_postgres__addresses') }}
)


select
    user_id
    ,first_name
    ,last_name
    ,first_name||' '||last_name as full_name
    ,email
    ,phone_number
    ,created_at
    ,updated_at
    ,address
    ,zipcode
    ,state
    ,country

from users
left join addresses
    on users.address_id = addresses.address_id 