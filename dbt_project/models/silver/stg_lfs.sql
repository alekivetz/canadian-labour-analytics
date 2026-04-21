-- =============================================================================
-- Silver Layer: LFS Staging Model
-- =============================================================================
-- Source: CANADIAN_LABOUR.BRONZE.LFS_RAW
-- Output: CANADIAN_LABOUR.SILVER.STG_LFS
--
-- Transforms raw LFS microdata by:
--   1. Decoding numeric codes into readable labels (province, gender, age, etc.)
--   2. Renaming columns to snake_case for consistency
--   3. Scaling numeric measures to correct units:
--      - hourly_wage: raw value divided by 100 (stored in cents)
--      - weekly_hours_main: raw value divided by 10 (stored in tenths)
--   4. Retaining survey_weight (FINALWT) for population-level aggregations
-- =============================================================================

SELECT
    SURVYEAR AS survey_year,
    SURVMNTH AS survey_month,
    CASE
        WHEN PROV = 10 THEN 'NL'
        WHEN PROV = 11 THEN 'PE'
        WHEN PROV = 12 THEN 'NS'
        WHEN PROV = 13 THEN 'NB'
        WHEN PROV = 24 THEN 'QC'
        WHEN PROV = 35 THEN 'ON'
        WHEN PROV = 46 THEN 'MB'
        WHEN PROV = 47 THEN 'SK'
        WHEN PROV = 48 THEN 'AB'
        WHEN PROV = 59 THEN 'BC'
        ELSE NULL
    END AS province,
    CASE
        WHEN GENDER = 1 THEN 'Male'
        WHEN GENDER = 2 THEN 'Female'
        ELSE NULL
    END AS gender,
    CASE
        WHEN AGE_12 = 1 THEN '15 to 19 years'
        WHEN AGE_12 = 2 THEN '20 to 24 years'
        WHEN AGE_12 = 3 THEN '25 to 29 years'
        WHEN AGE_12 = 4 THEN '30 to 34 years'
        WHEN AGE_12 = 5 THEN '35 to 39 years'
        WHEN AGE_12 = 6 THEN '40 to 44 years'
        WHEN AGE_12 = 7 THEN '45 to 49 years'
        WHEN AGE_12 = 8 THEN '50 to 54 years'
        WHEN AGE_12 = 9 THEN '55 to 59 years'
        WHEN AGE_12 = 10 THEN '60 to 64 years'
        WHEN AGE_12 = 11 THEN '65 to 69 years'
        WHEN AGE_12 = 12 THEN '70 and over'
        ELSE NULL
    END AS age_group,
    CASE
        WHEN MARSTAT = 1 THEN 'Married'
        WHEN MARSTAT = 2 THEN 'Common-law'
        WHEN MARSTAT = 3 THEN 'Widowed'
        WHEN MARSTAT = 4 THEN 'Separated'
        WHEN MARSTAT = 5 THEN 'Divorced'
        WHEN MARSTAT = 6 THEN 'Single, never married'
        ELSE NULL
    END AS marital_status,
    CASE
        WHEN EDUC = 0 THEN '0 to 8 years'
        WHEN EDUC = 1 THEN 'Some high school'
        WHEN EDUC = 2 THEN 'High school graduate'
        WHEN EDUC = 3 THEN 'Some post-secondary'
        WHEN EDUC = 4 THEN 'Post-secondary certificate or diploma'
        WHEN EDUC = 5 THEN 'Bachelor’s degree'
        WHEN EDUC = 6 THEN 'Above bachelor’s degree'
        ELSE NULL
    END AS education,
    CASE
        WHEN IMMIG = 1 THEN 'Immigrant, landed 10 or less years ago'
        WHEN IMMIG = 2 THEN 'Immigrant, landed more than 10 years ago'
        WHEN IMMIG = 3 THEN 'Non-immigrant'
        ELSE NULL
    END AS immigrant_status,
    CASE 
        WHEN LFSSTAT = 1 THEN 'Employed, at work'
        WHEN LFSSTAT = 2 THEN 'Employed, absent from work'
        WHEN LFSSTAT = 3 THEN 'Unemployed'
        WHEN LFSSTAT = 4 THEN 'Not in labour force'
        ELSE NULL
    END AS labour_force_status,
    CASE
        WHEN COWMAIN = 1 THEN 'Public sector employees'
        WHEN COWMAIN = 2 THEN 'Private sector employees'
        WHEN COWMAIN = 3 THEN 'Self-employed incorporated, with paid help'
        WHEN COWMAIN = 4 THEN 'Self-employed incorporated, without paid help'
        WHEN COWMAIN = 5 THEN 'Self-employed unincorporated, with paid help'
        WHEN COWMAIN = 6 THEN 'Self-employed unincorporated, without paid help'
        WHEN COWMAIN = 7 THEN 'Unpaid family worker'
        ELSE NULL
    END AS worker_class,
    CASE
        WHEN FTPTMAIN = 1 THEN 'Full-time'
        WHEN FTPTMAIN = 2 THEN 'Part-time'
        ELSE NULL
    END AS work_status_main,
    CASE
        WHEN NAICS_21 = 1 THEN 'Agriculture'
        WHEN NAICS_21 = 2 THEN 'Forestry and logging'
        WHEN NAICS_21 = 3 THEN 'Fishing, hunting and trapping'
        WHEN NAICS_21 = 4 THEN 'Mining, quarrying, and oil and gas extraction'
        WHEN NAICS_21 = 5 THEN 'Utilities'
        WHEN NAICS_21 = 6 THEN 'Construction'
        WHEN NAICS_21 = 7 THEN 'Manufacturing - durable goods'
        WHEN NAICS_21 = 8 THEN 'Manufacturing - non-durable goods'
        WHEN NAICS_21 = 9 THEN 'Wholesale trade'
        WHEN NAICS_21 = 10 THEN 'Retail trade'
        WHEN NAICS_21 = 11 THEN 'Transportation and warehousing'
        WHEN NAICS_21 = 12 THEN 'Finance and insurance'
        WHEN NAICS_21 = 13 THEN 'Real estate and rental and leasing'
        WHEN NAICS_21 = 14 THEN 'Professional, scientific and technical services'
        WHEN NAICS_21 = 15 THEN 'Business, building and other support services'
        WHEN NAICS_21 = 16 THEN 'Educational services'
        WHEN NAICS_21 = 17 THEN 'Health care and social assistance'
        WHEN NAICS_21 = 18 THEN 'Information, culture and recreation'
        WHEN NAICS_21 = 19 THEN 'Accommodation and food services'
        WHEN NAICS_21 = 20 THEN 'Other services'
        WHEN NAICS_21 = 21 THEN 'Public administration'
        ELSE NULL
    END AS industry_main,
    CASE
        WHEN NOC_10 = 1 THEN 'Management occupations'
        WHEN NOC_10 = 2 THEN 'Business, finance and administration occupations'
        WHEN NOC_10 = 3 THEN 'Natural and applied sciences occupations'
        WHEN NOC_10 = 4 THEN 'Health occupations'
        WHEN NOC_10 = 5 THEN 'Education, law and social services occupations'
        WHEN NOC_10 = 6 THEN 'Art, culture, recreation and sport occupations'
        WHEN NOC_10 = 7 THEN 'Sales and service occupations'
        WHEN NOC_10 = 8 THEN 'Trades and transport occupations'
        WHEN NOC_10 = 9 THEN 'Natural resources and agriculture occupations'
        WHEN NOC_10 = 10 THEN 'Manufacturing and utilities occupations'
        ELSE NULL
    END AS occupation_main,
    HRLYEARN / 100.0 AS hourly_wage,
    TENURE AS tenure_months,
    DURUNEMP AS unemployment_duration_weeks,
    UHRSMAIN / 10.0 AS weekly_hours_main, 
    FINALWT AS survey_weight

FROM {{source('bronze', 'LFS_RAW')}}