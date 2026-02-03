WITH aggregated AS (

    SELECT
        customer_id,
        order_date,
        SUM(quantity) AS tpv_quantity,
        SUM(tpv_value) AS tpv_value
    FROM {{ ref('int_sales_metrics') }}
    GROUP BY 1, 2

),

final AS (

    SELECT
        customer_id,
        order_date,
        tpv_quantity,
        tpv_value,
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} AS tpv_uid
    FROM aggregated

)

SELECT
    tpv_uid,
    customer_id,
    order_date,
    tpv_quantity,
    tpv_value
FROM final
