WITH enriched AS (

    SELECT * EXCLUDE(c_name), random_name(c_custkey) AS c_name
    FROM customer

)

SELECT JSON_OBJECT(
    'data', JSON_MERGE_PATCH(
        TO_JSON(enriched),
        JSON_OBJECT('c_name', enriched.c_name),
        JSON_OBJECT('c_email', random_email(enriched.c_name))
    ),
    'generated_at', STRFTIME(NOW() AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%M:%SZ')
) AS payload
FROM enriched
