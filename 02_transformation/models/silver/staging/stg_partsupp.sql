WITH input_data AS (

    SELECT
        message_id AS message_uid,
        publish_time AS loaded_at,
        PARSE_JSON(SAFE_CONVERT_BYTES_TO_STRING(data)) AS parsed_data,
        'tpch' AS load_source_name
    FROM {{ source('bronze', 'partsupp') }}

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
        JSON_VALUE(json_data.ps_partkey) AS part_id,
        JSON_VALUE(json_data.ps_suppkey) AS supplier_id,
        JSON_VALUE(json_data.ps_availqty) AS available_quantity,
        JSON_VALUE(json_data.ps_supplycost) AS supply_cost_value,
        JSON_VALUE(json_data.ps_comment) AS part_supplier_comment
    FROM raw_data

),

casted_data AS (

    SELECT
        message_uid,
        loaded_at,
        load_source_name,
        CAST(part_id AS INT64) AS part_id,
        CAST(supplier_id AS INT64) AS supplier_id,
        CAST(available_quantity AS INT64) AS available_quantity,
        CAST(supply_cost_value AS FLOAT64) AS supply_cost_value,
        CAST(part_supplier_comment AS STRING) AS part_supplier_comment
    FROM flattened

)

SELECT
    part_id,
    supplier_id,
    available_quantity,
    supply_cost_value,
    part_supplier_comment,
    loaded_at,
    load_source_name
FROM casted_data
