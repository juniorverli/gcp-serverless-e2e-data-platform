WITH input_data AS (

    SELECT
        message_id AS message_uid,
        publish_time AS loaded_at,
        PARSE_JSON(SAFE_CONVERT_BYTES_TO_STRING(data)) AS parsed_data,
        'tpch' AS load_source_name
    FROM {{ source('bronze', 'nation') }}

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
        JSON_VALUE(json_data.n_nationkey) AS nation_id,
        JSON_VALUE(json_data.n_name) AS nation_name,
        JSON_VALUE(json_data.n_regionkey) AS region_id,
        JSON_VALUE(json_data.n_comment) AS nation_comment
    FROM raw_data

),

casted_data AS (

    SELECT
        message_uid,
        loaded_at,
        load_source_name,
        CAST(nation_id AS INT64) AS nation_id,
        CAST(nation_name AS STRING) AS nation_name,
        CAST(region_id AS INT64) AS region_id,
        CAST(nation_comment AS STRING) AS nation_comment
    FROM flattened

)

SELECT
    nation_id,
    nation_name,
    region_id,
    nation_comment,
    loaded_at,
    load_source_name
FROM casted_data
