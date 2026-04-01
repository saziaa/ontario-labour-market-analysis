-- =====================================
-- Validation Check : Industry Annual
-- =====================================

-- VALIDATION 1: Check for suppressed or null values in annual file
SELECT 
    industry,
    year,
    person_count_thousand
FROM stg_industry_annual
WHERE TRIM(person_count_thousand) IN ('..', 'x', 'F', '', 'N/A')
   OR person_count_thousand IS NULL;

-- VALIDATION 2: Total vs detail gap 
SELECT
    year,
    ROUND(MAX(CASE 
        WHEN TRIM(industry) = 'Total, all industries'
        THEN CAST(person_count_thousand AS DECIMAL(10,1)) 
    END), 1)                              AS reported_total,
    ROUND(SUM(CASE 
        WHEN TRIM(industry) NOT IN (
            'Total, all industries',
            'Goods-producing sector',
            'Services-producing sector',
            'Manufacturing',
            'Wholesale and retail trade',
            'Finance, insurance, real estate, rental and leasing',
            'Forestry, fishing, mining, quarrying, oil and gas'
        )
        THEN CAST(person_count_thousand AS DECIMAL(10,1))
    END), 1)                              AS detail_sum,
    ROUND(MAX(CASE 
        WHEN TRIM(industry) = 'Total, all industries'
        THEN CAST(person_count_thousand AS DECIMAL(10,1)) 
    END) - 
    SUM(CASE 
        WHEN TRIM(industry) NOT IN (
            'Total, all industries',
            'Goods-producing sector',
            'Services-producing sector',
            'Manufacturing',
            'Wholesale and retail trade',
            'Finance, insurance, real estate, rental and leasing',
            'Forestry, fishing, mining, quarrying, oil and gas'
        )
        THEN CAST(person_count_thousand AS DECIMAL(10,1))
    END), 1)                              AS unaccounted_gap,
    ROUND(100.0 * (
        MAX(CASE 
            WHEN TRIM(industry) = 'Total, all industries'
            THEN CAST(person_count_thousand AS DECIMAL(10,1)) 
        END) - 
        SUM(CASE 
            WHEN TRIM(industry) NOT IN (
                'Total, all industries',
                'Goods-producing sector',
                'Services-producing sector',
                'Manufacturing',
                'Wholesale and retail trade',
                'Finance, insurance, real estate, rental and leasing',
                'Forestry, fishing, mining, quarrying, oil and gas'
            )
            THEN CAST(person_count_thousand AS DECIMAL(10,1))
        END)
    ) / NULLIF(MAX(CASE 
        WHEN TRIM(industry) = 'Total, all industries'
        THEN CAST(person_count_thousand AS DECIMAL(10,1)) 
    END), 0), 2)                          AS gap_pct
FROM stg_industry_annual
GROUP BY year
ORDER BY year;


-- VALIDATION 3: Suppression flag working correctly
-- Should return only Fishing, hunting and trapping x 11 years
SELECT industry,
       year,
       is_suppressed,
       is_aggregate
FROM clean_industry_annual
WHERE is_suppressed = TRUE
ORDER BY industry, year;

-- VALIDATION 4: Aggregate flag working correctly
-- Should return 7 aggregate industries x 11 years = 77 rows
SELECT industry,
       is_aggregate,
       COUNT(*) AS row_count
FROM clean_industry_annual
WHERE is_aggregate = TRUE
GROUP BY industry, is_aggregate
ORDER BY industry;

-- VALIDATION 5: Detail industries only 
-- Should return (28 - 7 - 1 suppressed) = 20 detail industries x 11 years
SELECT COUNT(*)              AS detail_rows,
       COUNT(DISTINCT industry) AS detail_industries
FROM clean_industry_annual
WHERE is_aggregate = FALSE
AND is_suppressed = FALSE;
