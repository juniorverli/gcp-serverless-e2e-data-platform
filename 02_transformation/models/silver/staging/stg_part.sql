WITH input_data AS (

    SELECT
        message_id AS message_uid,
        publish_time AS loaded_at,
        PARSE_JSON(SAFE_CONVERT_BYTES_TO_STRING(data)) AS parsed_data,
        'tpch' AS load_source_name
    FROM {{ source('bronze', 'part') }}

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
        JSON_VALUE(json_data.p_partkey) AS part_id,
        JSON_VALUE(json_data.p_name) AS part_name,
        JSON_VALUE(json_data.p_mfgr) AS manufacturer_name,
        JSON_VALUE(json_data.p_brand) AS brand_name,
        JSON_VALUE(json_data.p_type) AS part_type_name,
        JSON_VALUE(json_data.p_size) AS part_size,
        JSON_VALUE(json_data.p_container) AS container_name,
        JSON_VALUE(json_data.p_retailprice) AS retail_price_value,
        JSON_VALUE(json_data.p_comment) AS part_comment
    FROM raw_data

),

casted_data AS (

    SELECT
        message_uid,
        loaded_at,
        load_source_name,
        CAST(part_id AS INT64) AS part_id,
        CAST(part_name AS STRING) AS part_name,
        CAST(manufacturer_name AS STRING) AS manufacturer_name,
        CAST(brand_name AS STRING) AS brand_name,
        CAST(part_type_name AS STRING) AS part_type_name,
        CAST(part_size AS INT64) AS part_size,
        CAST(container_name AS STRING) AS container_name,
        CAST(retail_price_value AS FLOAT64) AS retail_price_value,
        CAST(part_comment AS STRING) AS part_comment
    FROM flattened

)

SELECT
    part_id,
    part_name,
    manufacturer_name,
    brand_name,
    part_type_name,
    part_size,
    container_name,
    retail_price_value,
    part_comment,
    loaded_at,
    load_source_name
FROM casted_data
