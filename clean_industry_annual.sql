-- ================================================
-- CLEANING LAYER: Industry Annual
-- ================================================

CREATE TABLE clean_industry_annual AS
SELECT
    TRIM(industry)                AS industry,
    year,
    -- Flag suppressed values
    CASE
        WHEN TRIM(person_count_thousand) IN ('x', '..', 'F', '')
        THEN TRUE
        ELSE FALSE
    END                           AS is_suppressed,
    -- Flag aggregate rows
    CASE
        WHEN TRIM(industry) IN (
            'Total, all industries',
            'Goods-producing sector',
            'Services-producing sector',
            'Manufacturing',
            'Wholesale and retail trade',
            'Finance, insurance, real estate, rental and leasing',
            'Forestry, fishing, mining, quarrying, oil and gas'
        ) THEN TRUE
        ELSE FALSE
    END                           AS is_aggregate,
    -- Cast to decimal only when not suppressed
    CASE
        WHEN TRIM(person_count_thousand) NOT IN ('x', '..', 'F', '')
        THEN CAST(
            REPLACE(person_count_thousand, ',', '')
            AS DECIMAL(10,1))
    END                           AS person_count_thousand,
    -- Document NAICS version per footnote 7
    '2022'                        AS naics_version
FROM stg_industry_annual;

SELECT * FROM stg_industry_annual LIMIT 10;
SELECT * FROM clean_industry_annual LIMIT 10;