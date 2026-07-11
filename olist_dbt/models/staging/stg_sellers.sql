{{ config(
    materialized='view',
    schema='silver'
) }}

WITH raw_sellers AS (
    SELECT * FROM {{ source('bronze', 'sellers') }}
)

SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM raw_sellers
WHERE seller_id IS NOT NULL
