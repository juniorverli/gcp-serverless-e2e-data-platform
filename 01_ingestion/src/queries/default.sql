SELECT JSON_OBJECT(
    'data', TO_JSON(t),
    'generated_at', STRFTIME(NOW() AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%M:%SZ')
) AS payload
FROM {table_name} AS t
