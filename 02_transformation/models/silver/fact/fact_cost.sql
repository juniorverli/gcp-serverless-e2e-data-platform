WITH aggregated AS (

    SELECT
        customer_id,
        order_date,
        SUM(quantity) AS cost_quantity,
        SUM(cost_value) AS cost_value
    FROM {{ ref('int_sales_metrics') }}
    GROUP BY 1, 2

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} AS cost_uid,
        customer_id,
        order_date,
        cost_quantity,
        cost_value
    FROM aggregated

)

SELECT
    cost_uid,
    customer_id,
    order_date,
    cost_quantity,
    cost_value
FROM final
