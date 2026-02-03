WITH base_data AS (

    SELECT
        order_id,
        line_number,
        customer_id,
        order_date,
        load_source_name,
        return_flag_code,
        line_status_code,
        ship_instructions_name,
        ship_mode_name,
        quantity,
        gross_revenue_value,
        net_revenue_value,
        cost_value,
        tpv_value,
        margin_value
    FROM {{ ref("int_sales_metrics") }}

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
        customer.customer_address,
        customer.nation_name AS customer_nation_name,
        customer.region_name AS customer_region_name,
        customer.market_segment_name,
        customer.account_balance_value,
        base_data.order_id,
        base_data.line_number,
        base_data.return_flag_code,
        base_data.line_status_code,
        base_data.ship_instructions_name,
        base_data.ship_mode_name,
        base_data.quantity,
        base_data.gross_revenue_value,
        base_data.net_revenue_value,
        base_data.cost_value,
        base_data.tpv_value,
        base_data.margin_value
    FROM base_data
    INNER JOIN {{ ref('dim_calendar') }} AS calendar ON
        base_data.order_date = calendar.created_date
    INNER JOIN {{ ref('dim_customer') }} AS customer ON
        base_data.customer_id = customer.customer_id

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
    customer_address,
    customer_nation_name,
    customer_region_name,
    market_segment_name,
    account_balance_value,
    order_id,
    line_number,
    return_flag_code,
    line_status_code,
    ship_instructions_name,
    ship_mode_name,
    quantity,
    gross_revenue_value,
    net_revenue_value,
    cost_value,
    tpv_value,
    margin_value
FROM final
