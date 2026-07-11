{{ config(
    materialized='table',
    schema='gold'
) }}

/*
    dim_customers — Customer Dimension Table
    
    Grain: One row per unique customer.
    Note: Olist dataset has customer_id (per order) and customer_unique_id (per person).
    We deduplicate using customer_unique_id to get one row per real customer,
    keeping the most recent address information.
*/

WITH ranked_customers AS (
    SELECT
        customer_unique_id,
        customer_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY customer_id DESC
        ) AS row_num
    FROM {{ ref('stg_customers') }}
)

SELECT
    customer_unique_id AS customer_key,
    customer_id AS latest_customer_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    -- Regional grouping for analytics
    CASE
        WHEN customer_state IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
        WHEN customer_state IN ('PR', 'SC', 'RS') THEN 'Sul'
        WHEN customer_state IN ('BA', 'PE', 'CE', 'MA', 'PB', 'RN', 'AL', 'SE', 'PI') THEN 'Nordeste'
        WHEN customer_state IN ('DF', 'GO', 'MT', 'MS') THEN 'Centro-Oeste'
        WHEN customer_state IN ('AM', 'PA', 'AC', 'RO', 'RR', 'AP', 'TO') THEN 'Norte'
        ELSE 'Desconhecido'
    END AS customer_region
FROM ranked_customers
WHERE row_num = 1
