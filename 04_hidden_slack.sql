-- ============================================
-- ANALYSIS 4: Hidden Slack
-- Source: Statistics Canada Table 14-10-0287-01
-- Geography: Ontario
-- Period: 2015-2025
--
-- Policy Question:
-- Is Ontario's participation rate still below
-- pre-COVID baseline despite unemployment
-- appearing recovered -- revealing hidden
-- labour force withdrawal?
--
-- Key Findings:
-- 1. Peak hidden slack: 2020 at 173,900 workers
--    missing from labour force vs 2019 baseline
-- 2. 2022-2023: Near genuine recovery achieved
--    unemployment returned to baseline levels
-- 3. 2025: New Labour Market Distress emerging
--    unemployment 7.69% vs 5.54% baseline
--    driven by population growth outpacing
--    job creation not COVID directly
-- 4. Ontario's recovery was real but fragile --
--    structural vulnerability remains in 2025
-- ============================================
WITH yearly_metrics AS (SELECT reference_year,
ROUND(AVG(CASE WHEN labour_characteristic = 'Population' THEN count_thousands END),2) AS avg_population,
ROUND(AVG(CASE WHEN labour_characteristic = 'Employment rate' THEN rate_value END),2) AS avg_employment_rate,
ROUND(AVG(CASE WHEN labour_characteristic = 'Unemployment rate' THEN rate_value END),2) AS avg_unemployment_rate,
ROUND(AVG(CASE WHEN labour_characteristic = 'Participation rate' THEN rate_value END),2) AS avg_participation_rate
FROM clean_labour_monthly
GROUP BY reference_year),
baseline AS (SELECT ROUND(AVG(avg_participation_rate),2) AS baseline_participation,
					ROUND(AVG(avg_unemployment_rate),2) AS baseline_unemployment
			 FROM yearly_metrics 
             WHERE reference_year=2019 )
SELECT ym.reference_year,
       ym.avg_population,
       ym.avg_employment_rate,
       ym.avg_unemployment_rate,
       ym.avg_participation_rate,
       b.baseline_participation,
       b.baseline_unemployment,
       ROUND((ym.avg_participation_rate - b.baseline_participation),2) AS participation_gap,
       ROUND((b.baseline_participation - ym.avg_participation_rate) 
    / 100.0 * ym.avg_population, 1)    AS hidden_slack_thousands,
       CASE
    WHEN ym.reference_year < 2020
        THEN 'Pre-COVID Baseline Period'
    WHEN ym.avg_unemployment_rate <= b.baseline_unemployment
     AND ym.avg_participation_rate >= b.baseline_participation
        THEN 'Genuine Recovery'
    WHEN ym.avg_unemployment_rate <= b.baseline_unemployment
     AND ym.avg_participation_rate < b.baseline_participation
        THEN 'Hidden Slack'
    WHEN ym.avg_unemployment_rate > b.baseline_unemployment
     AND ym.avg_participation_rate < b.baseline_participation
        THEN 'Labour Market Distress'
    ELSE 'Partial Recovery'
END AS recovery_assessment
FROM yearly_metrics ym CROSS JOIN baseline b
ORDER BY  ym.reference_year;