WITH input_data AS (

    SELECT
        message_id AS message_uid,
        publish_time AS loaded_at,
        PARSE_JSON(SAFE_CONVERT_BYTES_TO_STRING(data)) AS parsed_data,
        'tpch' AS load_source_name
    FROM {{ source('bronze', 'supplier') }}

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
        JSON_VALUE(json_data.s_suppkey) AS supplier_id,
        JSON_VALUE(json_data.s_name) AS supplier_name,
        JSON_VALUE(json_data.s_address) AS supplier_address,
        JSON_VALUE(json_data.s_nationkey) AS nation_id,
        JSON_VALUE(json_data.s_phone) AS supplier_phone,
        JSON_VALUE(json_data.s_acctbal) AS account_balance_value,
        JSON_VALUE(json_data.s_comment) AS supplier_comment
    FROM raw_data

),

casted_data AS (

    SELECT
        message_uid,
        loaded_at,
        load_source_name,
        CAST(supplier_id AS INT64) AS supplier_id,
        CAST(supplier_name AS STRING) AS supplier_name,
        CAST(supplier_address AS STRING) AS supplier_address,
        CAST(nation_id AS INT64) AS nation_id,
        CAST(supplier_phone AS STRING) AS supplier_phone,
        CAST(account_balance_value AS FLOAT64) AS account_balance_value,
        CAST(supplier_comment AS STRING) AS supplier_comment
    FROM flattened

)

SELECT
    supplier_id,
    supplier_name,
    supplier_address,
    nation_id,
    supplier_phone,
    account_balance_value,
    supplier_comment,
    loaded_at,
    load_source_name
FROM casted_data
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY supplier_id
    ORDER BY loaded_at DESC
) = 1
