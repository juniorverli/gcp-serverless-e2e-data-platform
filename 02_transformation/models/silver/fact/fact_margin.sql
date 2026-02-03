WITH aggregated AS (

    SELECT
        customer_id,
        order_date,
        SUM(quantity) AS margin_quantity,
        SUM(margin_value) AS margin_value
    FROM {{ ref('int_sales_metrics') }}
    GROUP BY 1, 2

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} AS margin_uid,
        customer_id,
        order_date,
        margin_quantity,
        margin_value
    FROM aggregated

)

SELECT
    margin_uid,
    customer_id,
    order_date,
    margin_quantity,
    margin_value
FROM final
