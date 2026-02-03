WITH dates AS (

    SELECT
        customer_id,
        order_date
    FROM {{ ref('int_sales_metrics')}}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY
            customer_id,
            order_date
        ORDER BY order_date ASC
    ) = 1

),

final AS (

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
        revenue.revenue_quantity,
        revenue.gross_revenue_value,
        revenue.net_revenue_value,
        cost.cost_value,
        tpv.tpv_value,
        margin.margin_value
    FROM dates
    LEFT JOIN {{ ref('fact_revenue') }} AS revenue ON
        revenue.customer_id = dates.customer_id
        AND revenue.order_date = dates.order_date
    LEFT JOIN {{ ref('fact_cost') }} AS cost ON
        cost.customer_id = dates.customer_id
        AND cost.order_date = dates.order_date
    LEFT JOIN {{ ref('fact_margin') }} AS margin ON
        margin.customer_id = dates.customer_id
        AND margin.order_date = dates.order_date
    LEFT JOIN {{ ref('fact_tpv') }} AS tpv ON
        tpv.customer_id = dates.customer_id
        AND tpv.order_date = dates.order_date
    INNER JOIN {{ ref('dim_calendar') }} AS calendar ON
        dates.order_date = calendar.created_date
    INNER JOIN {{ ref('dim_customer') }} AS customer ON
        dates.customer_id = customer.customer_id

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
    gross_revenue_value,
    net_revenue_value,
    cost_value,
    tpv_value,
    margin_value
FROM final
