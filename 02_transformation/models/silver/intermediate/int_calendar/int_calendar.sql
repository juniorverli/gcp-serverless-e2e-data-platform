WITH date_spine AS (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="CAST('1990-01-01' AS DATE)",
        end_date="CAST('2031-01-01' AS DATE)"
    ) }}

),

final AS (

    SELECT
        date_day AS created_date,
        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(QUARTER FROM date_day) AS quarter,
        EXTRACT(MONTH FROM date_day) AS month,
        FORMAT_DATE('%B', date_day) AS month_name,
        EXTRACT(WEEK FROM date_day) AS week_of_year,
        EXTRACT(DAY FROM date_day) AS day_of_month,
        EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,
        FORMAT_DATE('%A', date_day) AS day_name,
        CASE
            WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7) THEN TRUE
            ELSE FALSE
        END AS is_weekend
    FROM date_spine

)

SELECT
    created_date,
    year,
    quarter,
    month,
    month_name,
    week_of_year,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend
FROM final
