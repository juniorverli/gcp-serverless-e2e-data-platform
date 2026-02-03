WITH final AS (

    SELECT
        customer.customer_id,
        customer.customer_name,
        customer.customer_address,
        nation.nation_id,
        nation.nation_name,
        region.region_id,
        region.region_name,
        customer.customer_phone,
        customer.account_balance_value,
        customer.market_segment_name,
        customer.customer_comment,
        customer.loaded_at,
        customer.load_source_name
    FROM {{ ref('stg_customer') }} AS customer
    LEFT JOIN {{ ref('stg_nation') }} AS nation ON
        customer.nation_id = nation.nation_id
    LEFT JOIN {{ ref('stg_region') }} AS region ON
        nation.region_id = region.region_id

)

SELECT
    customer_id,
    customer_name,
    customer_address,
    nation_id,
    nation_name,
    region_id,
    region_name,
    customer_phone,
    account_balance_value,
    market_segment_name,
    customer_comment,
    loaded_at,
    load_source_name
FROM final
