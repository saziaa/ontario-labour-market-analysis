-- ========================
-- Creating Database
-- ========================

CREATE DATABASE ontario_labour_analysis;
USE ontario_labour_analysis;

-- ========================
-- Creating Tables
-- ========================
CREATE TABLE stg_labour_monthly (
    labour_characteristic   VARCHAR(100),
    reference_date          DATE,
    person_count            VARCHAR(20),
    unit                    VARCHAR(20)
);

CREATE TABLE stg_industry_annual (
    industry                VARCHAR(100),
    year                    INT,
    person_count_thousand   VARCHAR(20)
);

-- Quick row count check
SELECT 'stg_labour_monthly'  AS table_name, 
        COUNT(*)              AS row_count 
FROM stg_labour_monthly

UNION ALL

SELECT 'stg_industry_annual' AS table_name, 
        COUNT(*)              AS row_count 
FROM stg_industry_annual;