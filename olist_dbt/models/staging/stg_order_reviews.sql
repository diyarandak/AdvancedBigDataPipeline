{{ config(
    materialized='view',
    schema='silver'
) }}

WITH raw_reviews AS (
    SELECT * FROM {{ source('bronze', 'order_reviews') }}
)

SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
    CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp,
    -- Derived: Response time in hours
    TIMESTAMPDIFF(
        HOUR,
        CAST(review_creation_date AS TIMESTAMP),
        CAST(review_answer_timestamp AS TIMESTAMP)
    ) AS response_time_hours
FROM raw_reviews
WHERE review_id IS NOT NULL
  AND review_score BETWEEN 1 AND 5
