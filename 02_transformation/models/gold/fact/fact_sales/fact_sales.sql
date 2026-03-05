WITH aggregated AS (

    SELECT
        customer_id,
        order_date,
        SUM(quantity) AS quantity,
        SUM(tpv_value) AS tpv_value,
        SUM(net_revenue_value) AS net_revenue_value,
        SUM(cost_value) AS cost_value,
        SUM(margin_value) AS margin_value
    FROM {{ ref('int_sales_metrics') }}
    GROUP BY 1, 2

)

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} AS sales_uid,
    customer_id,
    order_date,
    quantity,
    tpv_value,
    net_revenue_value,
    cost_value,
    margin_value
FROM aggregated
