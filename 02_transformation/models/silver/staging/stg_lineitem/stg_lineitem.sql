WITH input_data AS (

    SELECT
        message_id AS message_uid,
        publish_time AS loaded_at,
        PARSE_JSON(SAFE_CONVERT_BYTES_TO_STRING(data)) AS parsed_data,
        'tpch' AS load_source_name
    FROM {{ source('bronze', 'lineitem') }}

),

raw_data AS (

    SELECT
        message_uid,
        loaded_at,
        load_source_name,
        parsed_data.data AS json_data
    FROM input_data

),

flattened AS (

    SELECT
        message_uid,
        loaded_at,
        load_source_name,
        JSON_VALUE(json_data.l_orderkey) AS order_id,
        JSON_VALUE(json_data.l_partkey) AS part_id,
        JSON_VALUE(json_data.l_suppkey) AS supplier_id,
        JSON_VALUE(json_data.l_linenumber) AS line_number,
        JSON_VALUE(json_data.l_quantity) AS quantity,
        JSON_VALUE(json_data.l_extendedprice) AS extended_price_value,
        JSON_VALUE(json_data.l_discount) AS discount_percent,
        JSON_VALUE(json_data.l_tax) AS tax_percent,
        JSON_VALUE(json_data.l_returnflag) AS return_flag_code,
        JSON_VALUE(json_data.l_linestatus) AS line_status_code,
        JSON_VALUE(json_data.l_shipdate) AS ship_date,
        JSON_VALUE(json_data.l_commitdate) AS commit_date,
        JSON_VALUE(json_data.l_receiptdate) AS receipt_date,
        JSON_VALUE(json_data.l_shipinstruct) AS ship_instructions_name,
        JSON_VALUE(json_data.l_shipmode) AS ship_mode_name,
        JSON_VALUE(json_data.l_comment) AS line_comment
    FROM raw_data

),

casted_data AS (

    SELECT
        message_uid,
        loaded_at,
        load_source_name,
        CAST(order_id AS INT64) AS order_id,
        CAST(part_id AS INT64) AS part_id,
        CAST(supplier_id AS INT64) AS supplier_id,
        CAST(line_number AS INT64) AS line_number,
        CAST(quantity AS FLOAT64) AS quantity,
        CAST(extended_price_value AS FLOAT64) AS extended_price_value,
        CAST(discount_percent AS FLOAT64) AS discount_percent,
        CAST(tax_percent AS FLOAT64) AS tax_percent,
        CAST(return_flag_code AS STRING) AS return_flag_code,
        CAST(line_status_code AS STRING) AS line_status_code,
        PARSE_DATE('%Y-%m-%d', ship_date) AS ship_date,
        PARSE_DATE('%Y-%m-%d', commit_date) AS commit_date,
        PARSE_DATE('%Y-%m-%d', receipt_date) AS receipt_date,
        CAST(ship_instructions_name AS STRING) AS ship_instructions_name,
        CAST(ship_mode_name AS STRING) AS ship_mode_name,
        CAST(line_comment AS STRING) AS line_comment
    FROM flattened

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
    load_source_name
FROM casted_data
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY
        order_id,
        part_id,
        supplier_id,
        line_number
    ORDER BY loaded_at DESC
) = 1
