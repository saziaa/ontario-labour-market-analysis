-- ================================================
-- CLEANING LAYER: Monthly Labour Characteristics
-- ================================================

CREATE TABLE clean_labour_monthly AS
SELECT
    TRIM(labour_characteristic)   AS labour_characteristic,
    reference_date,
    YEAR(reference_date)          AS reference_year,
    MONTH(reference_date)         AS reference_month,
    -- Classify into counts vs rates
    CASE
        WHEN TRIM(labour_characteristic) IN (
            'Employment rate',
            'Unemployment rate',
            'Participation rate'
        ) THEN 'rate'
        ELSE 'count'
    END                           AS characteristic_type,
    -- Cast counts to decimal
    CASE
        WHEN TRIM(labour_characteristic) NOT IN (
            'Employment rate',
            'Unemployment rate',
            'Participation rate'
        ) THEN CAST(
            REPLACE(person_count, ',', '')
            AS DECIMAL(10,1))
    END                           AS count_thousands,
    -- Cast rates to decimal
    CASE
        WHEN TRIM(labour_characteristic) IN (
            'Employment rate',
            'Unemployment rate',
            'Participation rate'
        ) THEN CAST(
            REPLACE(person_count, ',', '')
            AS DECIMAL(10,2))
    END                           AS rate_value,
    unit,
    -- Flag seasonally adjusted source
    TRUE                          AS is_seasonally_adjusted
FROM stg_labour_monthly
-- TRIM fixes the trailing space duplicate problem
-- All 132 rows per characteristic are preserved

;
SELECT * FROM stg_labour_monthly LIMIT 10;
SELECT * FROM clean_labour_monthly LIMIT 10;