{% test greater_than_0(model, column_name) %}

with validation as (

    select
        {{ column_name }} as check_field

    from {{ model }}

),

validation_errors as (

    select
        check_field

    from validation
    -- if this is true, then this field has a value less than 0
    where check_field < 1

)

select *
from validation_errors

{% endtest %}