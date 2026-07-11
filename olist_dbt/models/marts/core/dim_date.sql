{{ config(
    materialized='table',
    schema='gold'
) }}

/*
    dim_date — Date Dimension Table
    
    Grain: One row per calendar date.
    A standard date dimension covering the Olist dataset range (2016-2019).
    Generated using a recursive CTE — no external data needed.
*/

WITH RECURSIVE date_spine AS (
    SELECT CAST('2016-01-01' AS DATE) AS date_day
    UNION ALL
    SELECT DATE_ADD(date_day, INTERVAL 1 DAY)
    FROM date_spine
    WHERE date_day < '2019-12-31'
)

SELECT
    date_day AS date_key,
    YEAR(date_day) AS year,
    QUARTER(date_day) AS quarter,
    MONTH(date_day) AS month,
    DAY(date_day) AS day,
    DAYOFWEEK(date_day) AS day_of_week,
    WEEKOFYEAR(date_day) AS week_of_year,
    CASE
        WHEN DAYOFWEEK(date_day) IN (1, 7) THEN TRUE
        ELSE FALSE
    END AS is_weekend,
    -- Month name in Portuguese (for Superset dashboards)
    CASE MONTH(date_day)
        WHEN 1 THEN 'Janeiro'
        WHEN 2 THEN 'Fevereiro'
        WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Maio'
        WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro'
        WHEN 11 THEN 'Novembro'
        WHEN 12 THEN 'Dezembro'
    END AS month_name_pt,
    CONCAT(YEAR(date_day), '-Q', QUARTER(date_day)) AS year_quarter
FROM date_spine
