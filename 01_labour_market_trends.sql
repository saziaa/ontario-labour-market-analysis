-- ============================================
-- ANALYSIS 1: Ontario Labour Market Trends
-- Source: Statistics Canada Table 14-10-0287-01
-- Geography: Ontario
-- Period: January 2015 - December 2025
-- Data type: Seasonally adjusted
-- 
-- Policy Question:
-- How did Ontario's employment, unemployment and 
-- participation rates trend from 2015 to 2025 
-- including through the COVID-19 shock?
--
-- Key Findings:
-- 1. Peak unemployment: May 2020 at 14.2% (raw)
--    Sustained peak: June 2020 at 12.97% (3mo avg)
-- 2. Largest single month shock: April 2020
--    Unemployment +3.6pts, Employment -5.8pts
-- 3. Recovery began: June 2020
-- 4. Asymmetry finding: Employment fell 9.8pts 
--    but unemployment only rose 8.6pts Mar-May 2020
--    suggesting hidden labour force withdrawal
-- ============================================

WITH monthly_rates AS (
    SELECT
        reference_date,
        reference_year,
        reference_month,
        MAX(CASE WHEN labour_characteristic = 'Employment rate'
            THEN rate_value END)              AS employment_rate,
        MAX(CASE WHEN labour_characteristic = 'Unemployment rate'
            THEN rate_value END)              AS unemployment_rate,
        MAX(CASE WHEN labour_characteristic = 'Participation rate'
            THEN rate_value END)              AS participation_rate
    FROM clean_labour_monthly
    GROUP BY reference_date, reference_year, reference_month
),

monthly_changes AS (
    SELECT
        reference_date,
        reference_year,
        reference_month,
        employment_rate,
        unemployment_rate,
        participation_rate,
        ROUND(unemployment_rate - LAG(unemployment_rate)
            OVER (ORDER BY reference_date), 1) AS unemp_rate_mom_change,
        ROUND(employment_rate - LAG(employment_rate)
            OVER (ORDER BY reference_date), 1) AS emp_rate_mom_change,
        CASE
            WHEN reference_date < '2020-03-01'
                THEN '1-Pre-COVID'
            WHEN reference_date BETWEEN '2020-03-01' AND '2021-12-01'
                THEN '2-COVID Period'
            WHEN reference_date BETWEEN '2022-01-01' AND '2023-06-01'
                THEN '3-Recovery Period'
            ELSE
                '4-Post-Recovery'
        END                                    AS economic_period
    FROM monthly_rates
)

SELECT
    reference_date,
    reference_year,
    reference_month,
    economic_period,
    employment_rate,
    unemployment_rate,
    participation_rate,
    unemp_rate_mom_change,
    emp_rate_mom_change,

    -- 3 month rolling average for unemployment
    ROUND(AVG(unemployment_rate) OVER (
        ORDER BY reference_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                      AS unemp_rate_3mo_avg,

    -- 3 month rolling average for employment
    ROUND(AVG(employment_rate) OVER (
        ORDER BY reference_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                      AS emp_rate_3mo_avg,

    -- 3 month rolling average for participation
    ROUND(AVG(participation_rate) OVER (
        ORDER BY reference_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                      AS part_rate_3mo_avg

FROM monthly_changes
ORDER BY reference_date;