-- ============================================
-- ANALYSIS 3: Structural Shift in Ontario
--             Labour Force
-- Source: Statistics Canada Table 14-10-0023-01
-- Geography: Ontario
-- Period: 2015-2025
--
-- Policy Question:
-- Is Ontario's labour force structurally shifting
-- toward services and away from goods-producing
-- industries -- and which sectors are gaining or
-- losing employment share?
--
-- Key Findings:
-- 1. Ontario shifting toward knowledge economy --
--    Professional/technical +2.75ppt,
--    Finance +1.16ppt share gain 2015-2025
-- 2. Care economy growing --
--    Health care +0.82ppt share gain
-- 3. Manufacturing declining --
--    Durables lost -0.87ppt share over 10 years
-- 4. Business support services biggest loser --
--    -1.41ppt share decline, structural decline
--    confirmed across Analysis 2 and 3
-- 5. Polarization accelerating -- high-skill
--    sectors gain share while low-wage sectors
--    lose share permanently
-- ============================================
-- ============================================
-- OUTPUT A: Industry share summary
-- ============================================

WITH annual_totals AS (SELECT year,
       SUM(person_count_thousand) AS total_employment
FROM clean_industry_annual
WHERE is_aggregate = FALSE
AND is_suppressed = FALSE
GROUP BY year),
industry_shares AS (SELECT 
						ci.year, 
                        ci.industry,
                        ci.person_count_thousand,
                        ta.total_employment,
ROUND(100.0* ci.person_count_thousand/NULLIF(ta.total_employment,0),2) AS employment_share_pct,
ci.person_count_thousand- LAG(ci.person_count_thousand) OVER(PARTITION BY ci.industry ORDER BY ci.year) AS yoy_change_thousands
FROM clean_industry_annual ci 
LEFT JOIN annual_totals ta ON ci.year = ta.year
WHERE ci.is_aggregate = FALSE
AND ci.is_suppressed = FALSE
),
shift_summary AS(
SELECT industry,
       MAX(CASE WHEN year = 2015 THEN employment_share_pct END) AS share_2015,
	   MAX(CASE WHEN year = 2025 THEN employment_share_pct END) AS share_2025,
       ROUND((MAX(CASE WHEN year = 2025 THEN employment_share_pct END)
       - MAX(CASE WHEN year = 2015 THEN employment_share_pct END)),2) AS share_shift_ppt
FROM industry_shares
GROUP BY industry)

SELECT industry,
	   share_2015,
	   share_2025,
       share_shift_ppt,
       CASE WHEN share_shift_ppt > +0.5 THEN 'Growing Share'
			WHEN share_shift_ppt < -0.5 THEN 'Declining Share'
            ELSE 'Stable Share' END AS structural_trend,
	   RANK() OVER (ORDER BY share_shift_ppt DESC) AS growth_rank,
       RANK() OVER (ORDER BY share_shift_ppt ASC)  AS decline_rank
FROM shift_summary
ORDER BY share_shift_ppt DESC;

-- ============================================
-- OUTPUT B: Year by year detail for dashboard
-- =============================================
WITH annual_totals AS (
    SELECT year,
           SUM(person_count_thousand) AS total_employment
    FROM clean_industry_annual
    WHERE is_aggregate = FALSE
    AND is_suppressed = FALSE
    GROUP BY year
)
SELECT
    ci.year,
    ci.industry,
    ci.person_count_thousand,
    ROUND(100.0 * ci.person_count_thousand /
        NULLIF(ta.total_employment, 0), 2)    AS employment_share_pct,
    ROUND(ci.person_count_thousand -
        LAG(ci.person_count_thousand)
        OVER (PARTITION BY ci.industry
              ORDER BY ci.year), 1)           AS yoy_change_thousands
FROM clean_industry_annual ci
LEFT JOIN annual_totals ta ON ci.year = ta.year
WHERE ci.is_aggregate = FALSE
AND ci.is_suppressed = FALSE
ORDER BY ci.industry, ci.year;








