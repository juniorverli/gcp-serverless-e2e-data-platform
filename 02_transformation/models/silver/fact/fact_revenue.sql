WITH aggregated AS (

    SELECT
        customer_id,
        order_date,
        SUM(quantity) AS revenue_quantity,
        SUM(gross_revenue_value) AS gross_revenue_value,
        SUM(net_revenue_value) AS net_revenue_value
    FROM {{ ref('int_sales_metrics') }}
    GROUP BY 1, 2

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} AS revenue_uid,
        customer_id,
        order_date,
        revenue_quantity,
        gross_revenue_value,
        net_revenue_value
    FROM aggregated

)

SELECT
    revenue_uid,
    customer_id,
    order_date,
    revenue_quantity,
    gross_revenue_value,
    net_revenue_value
FROM final
