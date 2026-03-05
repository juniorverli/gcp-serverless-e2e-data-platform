WITH joined_data AS (

    SELECT
        calendar.created_date AS order_date,
        calendar.year AS order_year,
        calendar.month AS order_month,
        calendar.month_name AS order_month_name,
        calendar.quarter,
        calendar.week_of_year,
        calendar.day_of_month,
        calendar.day_of_week,
        calendar.day_name,
        calendar.is_weekend,
        customer.customer_id,
        customer.customer_name,
        customer.customer_email_address,
        customer.customer_address,
        customer.nation_name AS customer_nation_name,
        customer.region_name AS customer_region_name,
        customer.market_segment_name,
        customer.account_balance_value,
        sales.quantity AS revenue_quantity,
        sales.tpv_value,
        sales.net_revenue_value,
        sales.cost_value,
        sales.margin_value
    FROM {{ ref('fact_sales') }} AS sales
    INNER JOIN {{ ref('dim_calendar') }} AS calendar ON
        sales.order_date = calendar.created_date
    INNER JOIN {{ ref('dim_customer') }} AS customer ON
        sales.customer_id = customer.customer_id

)

SELECT
    order_date,
    order_year,
    order_month,
    order_month_name,
    quarter,
    week_of_year,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend,
    customer_id,
    customer_name,
    customer_email_address,
    customer_address,
    customer_nation_name,
    customer_region_name,
    market_segment_name,
    account_balance_value,
    revenue_quantity,
    tpv_value,
    net_revenue_value,
    cost_value,
    margin_value
FROM joined_data
