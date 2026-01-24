SELECT *
FROM {{ source('bronze', 'customer') }}
