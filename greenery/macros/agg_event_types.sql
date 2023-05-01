{% macro agg_event_types(table_name, column_name) %}
    {% set event_types = dbt_utils.get_column_values( table = ref(table_name), column = column_name)
    %}
    {% for event in event_types %}
    , sum(case when event_type = '{{ event }}' then 1 else 0 end) as {{ event }}_sessions
    {% endfor %}   
{% endmacro %}