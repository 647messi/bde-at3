{% macro airbnb_batch() %}
    {% set table = env_var('DBT_AIRBNB_SOURCE_TABLE', 'airbnb_05_2020') %}
    {% set allowed = [
        'airbnb_05_2020', 'airbnb_06_2020', 'airbnb_07_2020',
        'airbnb_08_2020', 'airbnb_09_2020', 'airbnb_10_2020',
        'airbnb_11_2020', 'airbnb_12_2020', 'airbnb_01_2021',
        'airbnb_02_2021', 'airbnb_03_2021', 'airbnb_04_2021'
    ] %}
    {% if table not in allowed %}
        {{ exceptions.raise_compiler_error('Unsupported DBT_AIRBNB_SOURCE_TABLE: ' ~ table) }}
    {% endif %}
    {% set parts = table.split('_') %}
    {{ return({'table': table, 'month_date': parts[2] ~ '-' ~ parts[1] ~ '-01'}) }}
{% endmacro %}
