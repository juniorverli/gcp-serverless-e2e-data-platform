WITH input_data AS (

    SELECT
        message_id AS message_uid,
        publish_time AS loaded_at,
        PARSE_JSON(SAFE_CONVERT_BYTES_TO_STRING(data)) AS parsed_data,
        'tpch' AS load_source_name
    FROM {{ source('bronze', 'orders') }}

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
        JSON_VALUE(json_data.o_orderkey) AS order_id,
        JSON_VALUE(json_data.o_custkey) AS customer_id,
        JSON_VALUE(json_data.o_orderstatus) AS order_status_code,
        JSON_VALUE(json_data.o_totalprice) AS total_price_value,
        JSON_VALUE(json_data.o_orderdate) AS order_date,
        JSON_VALUE(json_data.o_orderpriority) AS order_priority_code,
        JSON_VALUE(json_data.o_clerk) AS clerk_name,
        JSON_VALUE(json_data.o_shippriority) AS ship_priority,
        JSON_VALUE(json_data.o_comment) AS order_comment
    FROM raw_data

),

casted_data AS (

    SELECT
        message_uid,
        loaded_at,
        load_source_name,
        CAST(order_id AS INT64) AS order_id,
        CAST(customer_id AS INT64) AS customer_id,
        CAST(order_status_code AS STRING) AS order_status_code,
        CAST(total_price_value AS FLOAT64) AS total_price_value,
        PARSE_DATE('%Y-%m-%d', order_date) AS order_date,
        CAST(order_priority_code AS STRING) AS order_priority_code,
        CAST(clerk_name AS STRING) AS clerk_name,
        CAST(ship_priority AS INT64) AS ship_priority,
        CAST(order_comment AS STRING) AS order_comment
    FROM flattened

)

SELECT
    order_id,
    customer_id,
    order_status_code,
    total_price_value,
    order_date,
    order_priority_code,
    clerk_name,
    ship_priority,
    order_comment,
    loaded_at,
    load_source_name
FROM casted_data
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY order_id
    ORDER BY loaded_at DESC
) = 1
