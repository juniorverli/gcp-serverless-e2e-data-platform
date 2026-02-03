WITH input_data AS (

    SELECT
        message_id AS message_uid,
        publish_time AS loaded_at,
        PARSE_JSON(SAFE_CONVERT_BYTES_TO_STRING(data)) AS parsed_data,
        'tpch' AS load_source_name
    FROM {{ source('bronze', 'region') }}

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
        JSON_VALUE(json_data.r_regionkey) AS region_id,
        JSON_VALUE(json_data.r_name) AS region_name,
        JSON_VALUE(json_data.r_comment) AS region_comment
    FROM raw_data

),

casted_data AS (

    SELECT
        message_uid,
        loaded_at,
        load_source_name,
        CAST(region_id AS INT64) AS region_id,
        CAST(region_name AS STRING) AS region_name,
        CAST(region_comment AS STRING) AS region_comment
    FROM flattened

)

SELECT
    region_id,
    region_name,
    region_comment,
    loaded_at,
    load_source_name
FROM casted_data
