WITH joined_data AS (

    SELECT
        lineitem.order_id,
        lineitem.line_number,
        orders.customer_id,
        lineitem.part_id,
        lineitem.supplier_id,
        orders.order_date,
        orders.load_source_name,
        lineitem.return_flag_code,
        lineitem.line_status_code,
        lineitem.ship_instructions_name,
        lineitem.ship_mode_name,
        COALESCE(lineitem.quantity, 0) AS quantity,
        COALESCE(lineitem.extended_price_value, 0) AS extended_price_value,
        COALESCE(lineitem.net_item_sales_value, 0) AS net_item_sales_value,
        COALESCE(partsupp.supply_cost_value, 0) AS supply_cost_value
    FROM {{ ref('int_lineitem_enriched') }} AS lineitem
    LEFT JOIN {{ ref('stg_orders') }} AS orders ON lineitem.order_id = orders.order_id
    LEFT JOIN {{ ref('stg_partsupp') }} AS partsupp ON
        lineitem.part_id = partsupp.part_id
        AND lineitem.supplier_id = partsupp.supplier_id

),

cost_calculation AS (

    SELECT
        order_id,
        line_number,
        customer_id,
        part_id,
        supplier_id,
        order_date,
        load_source_name,
        return_flag_code,
        line_status_code,
        ship_instructions_name,
        ship_mode_name,
        quantity,
        extended_price_value AS tpv_value,
        net_item_sales_value AS net_revenue_value,
        supply_cost_value * quantity AS cost_value
    FROM joined_data

),

margin_calculation AS (

    SELECT
        order_id,
        line_number,
        customer_id,
        part_id,
        supplier_id,
        order_date,
        load_source_name,
        return_flag_code,
        line_status_code,
        ship_instructions_name,
        ship_mode_name,
        quantity,
        tpv_value,
        net_revenue_value,
        cost_value,
        net_revenue_value - cost_value AS margin_value
    FROM cost_calculation

)

SELECT
    order_id,
    line_number,
    customer_id,
    part_id,
    supplier_id,
    order_date,
    load_source_name,
    return_flag_code,
    line_status_code,
    ship_instructions_name,
    ship_mode_name,
    quantity,
    tpv_value,
    net_revenue_value,
    cost_value,
    margin_value
FROM margin_calculation
