-- ============================================
-- ANALYSIS 2: COVID Shock and Industry Recovery
-- Source: Statistics Canada Table 14-10-0023-01
-- Geography: Ontario
-- Period: 2015-2025
--
-- Policy Question:
-- Which Ontario industries were hit hardest by 
-- COVID-19 and which have structurally recovered
-- versus permanently declined by 2025?
--
-- Key Findings:
-- 1. Most impacted: Accommodation and food services
--    at -24.41% shock, still -4.02% below 2019 in 2025
-- 2. 4 industries in structural decline by 2025 --
--    all low-wage in-person service sectors
-- 3. 4 industries grew during COVID -- all high-skill
--    or essential sectors
-- 4. Agriculture at -12.35% longterm signals permanent
--    workforce reduction not temporary shock
-- 5. COVID accelerated labour market polarization --
--    high-skill sectors expanded while low-wage 
--    sectors remain below pre-pandemic levels
-- ============================================
WITH pivoted_industries AS (SELECT
    industry,
    MAX(CASE WHEN year = 2019
        THEN person_count_thousand END)   AS employment_2019,
    MAX(CASE WHEN year = 2020
        THEN person_count_thousand END)   AS employment_2020,
    MAX(CASE WHEN year = 2022
        THEN person_count_thousand END)   AS employment_2022,
    MAX(CASE WHEN year = 2025
        THEN person_count_thousand END)   AS employment_2025
FROM clean_industry_annual
WHERE is_aggregate = FALSE
AND is_suppressed = FALSE
GROUP BY industry),
shock_recovery_CTE AS (SELECT industry,
	   employment_2019,
       employment_2020,
       employment_2022,
       employment_2025,
       ROUND(100.0* (employment_2020-employment_2019)/ 
       NULLIF(employment_2019,0),2) AS shock_pct,
       ROUND(100.0* (employment_2022-employment_2019)/
       NULLIF(employment_2019,0),2) AS recovery_pct,
       ROUND(100.0 * (employment_2025 - employment_2019) /
	   NULLIF(employment_2019, 0), 2) AS longterm_growth_pct
FROM pivoted_industries)
SELECT industry,
	   employment_2019,
       employment_2020,
       employment_2022,
       employment_2025,
       shock_pct,
       recovery_pct,
       longterm_growth_pct,
       RANK() OVER(ORDER BY shock_pct) AS most_impacted_rank,
       RANK() OVER(ORDER BY recovery_pct DESC) AS strongest_recovery_rank,
       CASE
    WHEN shock_pct > 0              THEN 'Grew During COVID'
    WHEN recovery_pct >= 0 
     AND longterm_growth_pct >= 0   THEN 'Full Recovery'
    WHEN recovery_pct < 0 
     AND longterm_growth_pct >= 0   THEN 'Delayed Recovery'
    WHEN recovery_pct >= 0 
     AND longterm_growth_pct < 0    THEN 'Recovered then Declined'
    WHEN recovery_pct < 0 
     AND longterm_growth_pct < 0    THEN 'Structural Decline'
END                                 AS recovery_status
FROM shock_recovery_CTE
ORDER BY shock_pct ASC;