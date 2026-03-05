WITH lineitem AS (

    SELECT
        order_id,
        part_id,
        supplier_id,
        line_number,
        return_flag_code,
        line_status_code,
        ship_date,
        commit_date,
        receipt_date,
        ship_instructions_name,
        ship_mode_name,
        line_comment,
        loaded_at,
        load_source_name,
        COALESCE(quantity, 0) AS quantity,
        COALESCE(extended_price_value, 0) AS extended_price_value,
        COALESCE(discount_percent, 0) AS discount_percent,
        COALESCE(tax_percent, 0) AS tax_percent
    FROM {{ ref('stg_lineitem') }}

),

discount_calculation AS (

    SELECT
        order_id,
        part_id,
        supplier_id,
        line_number,
        quantity,
        extended_price_value,
        discount_percent,
        tax_percent,
        return_flag_code,
        line_status_code,
        ship_date,
        commit_date,
        receipt_date,
        ship_instructions_name,
        ship_mode_name,
        line_comment,
        loaded_at,
        load_source_name,
        (1 - discount_percent) AS discount_factor
    FROM lineitem

),

net_sales_calculation AS (

    SELECT
        order_id,
        part_id,
        supplier_id,
        line_number,
        quantity,
        extended_price_value,
        discount_percent,
        tax_percent,
        return_flag_code,
        line_status_code,
        ship_date,
        commit_date,
        receipt_date,
        ship_instructions_name,
        ship_mode_name,
        line_comment,
        loaded_at,
        load_source_name,
        discount_factor,
        extended_price_value * discount_factor AS net_item_sales_value
    FROM discount_calculation

)

SELECT
    order_id,
    part_id,
    supplier_id,
    line_number,
    quantity,
    extended_price_value,
    discount_percent,
    tax_percent,
    return_flag_code,
    line_status_code,
    ship_date,
    commit_date,
    receipt_date,
    ship_instructions_name,
    ship_mode_name,
    line_comment,
    loaded_at,
    load_source_name,
    discount_factor,
    net_item_sales_value
FROM net_sales_calculation
