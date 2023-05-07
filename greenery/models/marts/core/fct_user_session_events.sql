with user_sessions as  (
    select * from {{ ref ('int_user_session_events')}}
)

select * from user_sessions