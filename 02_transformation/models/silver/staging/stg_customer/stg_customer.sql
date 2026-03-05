WITH input_data AS (

    SELECT
        message_id AS message_uid,
        publish_time AS loaded_at,
        PARSE_JSON(SAFE_CONVERT_BYTES_TO_STRING(data)) AS parsed_data,
        'tpch' AS load_source_name
    FROM {{ source('bronze', 'customer') }}

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
        JSON_VALUE(json_data.c_custkey) AS customer_id,
        JSON_VALUE(json_data.c_name) AS customer_name,
        JSON_VALUE(json_data.c_email) AS customer_email_address,
        JSON_VALUE(json_data.c_address) AS customer_address,
        JSON_VALUE(json_data.c_nationkey) AS nation_id,
        JSON_VALUE(json_data.c_phone) AS customer_phone,
        JSON_VALUE(json_data.c_acctbal) AS account_balance_value,
        JSON_VALUE(json_data.c_mktsegment) AS market_segment_name,
        JSON_VALUE(json_data.c_comment) AS customer_comment
    FROM raw_data

),

casted_data AS (

    SELECT
        message_uid,
        loaded_at,
        load_source_name,
        CAST(customer_id AS INT64) AS customer_id,
        CAST(customer_name AS STRING) AS customer_name,
        CAST(customer_email_address AS STRING) AS customer_email_address,
        CAST(customer_address AS STRING) AS customer_address,
        CAST(nation_id AS INT64) AS nation_id,
        CAST(customer_phone AS STRING) AS customer_phone,
        CAST(account_balance_value AS FLOAT64) AS account_balance_value,
        CAST(market_segment_name AS STRING) AS market_segment_name,
        CAST(customer_comment AS STRING) AS customer_comment
    FROM flattened

)

SELECT
    customer_id,
    customer_name,
    customer_email_address,
    customer_address,
    nation_id,
    customer_phone,
    account_balance_value,
    market_segment_name,
    customer_comment,
    loaded_at,
    load_source_name
FROM casted_data
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY loaded_at DESC
) = 1
