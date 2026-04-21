-- =============================================================================
-- Gold Layer: LFS Gold Model
-- =============================================================================
-- Source: CANADIAN_LABOUR.SILVER.STG_LFS
-- Output: CANADIAN_LABOUR.GOLD.LFS_GOLD
--
-- Aggregates Silver layer data by all key dimensions for direct consumption
-- by Power BI. One row per unique combination of dimensions per month.
--
-- Key design decisions:
--   - total_weight: sum of survey weights for population-level counts
--   - avg_hourly_wage: simple average within each dimension group
--   - avg_weekly_hours: simple average within each dimension group
--   - year_month: DATE column combining survey_year and survey_month
--     for use as a time axis in Power BI
--   - NULL values retained from Silver layer to preserve survey structure
-- =============================================================================

SELECT
    survey_year,
    survey_month,
    DATEFROMPARTS(survey_year, survey_month, 1) AS year_month,
    province,
    gender,
    age_group,
    education,
    immigrant_status,
    labour_force_status,
    worker_class,
    work_status_main,
    industry_main,
    occupation_main,
    SUM(survey_weight) AS total_weight,
    AVG(hourly_wage) AS avg_hourly_wage,
    AVG(weekly_hours_main) AS avg_weekly_hours
FROM {{ ref('stg_lfs') }}
GROUP BY
    survey_year, survey_month, province, gender, age_group,
    education, immigrant_status, labour_force_status,
    worker_class, work_status_main, industry_main, occupation_main
