-- ==================================================
-- Validation Check : Monthly Labour Characteristics
-- ==================================================
-- VALIDATION 1: Date range and characteristics in monthly file
SELECT 
    COUNT(*)                              AS total_rows,
    COUNT(DISTINCT labour_characteristic) AS unique_characteristics,
    MIN(reference_date)                   AS earliest_date,
    MAX(reference_date)                   AS latest_date
FROM stg_labour_monthly;

-- Find all 11 characteristics
SELECT DISTINCT labour_characteristic,
       COUNT(*) AS row_count
FROM stg_labour_monthly 
GROUP BY labour_characteristic
ORDER BY labour_characteristic;

-- VALIDATION 2: Check for suppressed or null values in monthly file
SELECT 
    labour_characteristic,
    reference_date,
    person_count
FROM stg_labour_monthly
WHERE TRIM(person_count) IN ('..', 'x', 'F', '', 'N/A')
   OR person_count IS NULL;

-- VALIDATION 3: Trailing space fixed -- should show exactly 9 characteristics
SELECT DISTINCT labour_characteristic,
       characteristic_type,
       COUNT(*) AS row_count
FROM clean_labour_monthly
GROUP BY labour_characteristic, characteristic_type
ORDER BY characteristic_type, labour_characteristic;


-- VALIDATION 4: Checking Labour Force
SELECT
    reference_date,
    MAX(CASE WHEN labour_characteristic = 'Labour force'
        THEN count_thousands END)            AS labour_force,
    MAX(CASE WHEN labour_characteristic = 'Employment'
        THEN count_thousands END)            AS employment,
    MAX(CASE WHEN labour_characteristic = 'Unemployment'
        THEN count_thousands END)            AS unemployment,
    ROUND(
        MAX(CASE WHEN labour_characteristic = 'Labour force'
            THEN count_thousands END) -
        MAX(CASE WHEN labour_characteristic = 'Employment'
            THEN count_thousands END) -
        MAX(CASE WHEN labour_characteristic = 'Unemployment'
            THEN count_thousands END)
    , 1)                                     AS discrepancy
FROM clean_labour_monthly
WHERE characteristic_type = 'count'
GROUP BY reference_date
HAVING ABS(discrepancy) > 0.1
ORDER BY reference_date;

-- VALIDATION 5: Checking Unemployment Rate 
SELECT reference_date,
MAX(CASE WHEN labour_characteristic = 'Unemployment rate' THEN rate_value END)  AS published_rate, 
ROUND(100.0* MAX(CASE WHEN labour_characteristic = 'Unemployment' THEN count_thousands END) /
	   NULLIF(MAX(CASE WHEN labour_characteristic = 'Labour force' THEN count_thousands END),0),1) AS calculated_rate,
    ROUND(ABS(
        MAX(CASE WHEN labour_characteristic = 'Unemployment rate'
            THEN rate_value END) -
        ROUND(100.0 *
            MAX(CASE WHEN labour_characteristic = 'Unemployment'
                THEN count_thousands END) /
            NULLIF(MAX(CASE WHEN labour_characteristic = 'Labour force'
                THEN count_thousands END), 0)
        , 1)
    ), 1)                                    AS difference
FROM clean_labour_monthly
GROUP BY reference_date
ORDER BY reference_date;
SELECT DISTINCT(labour_characteristic)
FROM clean_labour_monthly;

-- VALIDATION 6: Checking Employment Rate 
SELECT reference_date, 
MAX(CASE WHEN labour_characteristic = 'Employment rate' THEN rate_value END) AS published_rate,
ROUND(100.0* MAX(CASE WHEN labour_characteristic = 'Employment' THEN count_thousands END) /
       NULLIF(MAX(CASE WHEN labour_characteristic = 'Population' THEN count_thousands END),0),1) AS calculated_rate, 
ROUND(ABS(MAX(CASE WHEN labour_characteristic = 'Employment rate' THEN rate_value END) -
ROUND(100.0* MAX(CASE WHEN labour_characteristic = 'Employment' THEN count_thousands END) /
       NULLIF(MAX(CASE WHEN labour_characteristic = 'Population' THEN count_thousands END),0),1)),1) AS difference
FROM clean_labour_monthly
GROUP BY reference_date
HAVING difference > 0.5
ORDER BY reference_date;

-- VALIDATION 7: Checking Prticipation Rate 
SELECT reference_date,
MAX(CASE WHEN labour_characteristic = 'Participation rate' THEN rate_value END) AS published_rate,

ROUND(100.0 * MAX(CASE WHEN labour_characteristic = 'Labour force'THEN count_thousands END) / 
NULLIF (MAX(CASE WHEN labour_characteristic = 'Population'THEN count_thousands END),0) ,1) AS calculated_rate,

ROUND(ABS(MAX(CASE WHEN labour_characteristic = 'Participation rate' THEN rate_value END) - 
ROUND(100.0 * MAX(CASE WHEN labour_characteristic = 'Labour force'THEN count_thousands END) / 
NULLIF (MAX(CASE WHEN labour_characteristic = 'Population'THEN count_thousands END),0) ,1)),1) AS difference
FROM clean_labour_monthly
GROUP BY reference_date
ORDER BY reference_date;

-- VALIDATION 8: Logical Sanity Check
SELECT
    reference_date,
    MAX(CASE WHEN labour_characteristic = 'Population'
        THEN count_thousands END)            AS population,
    MAX(CASE WHEN labour_characteristic = 'Labour force'
        THEN count_thousands END)            AS labour_force,
    MAX(CASE WHEN labour_characteristic = 'Employment'
        THEN count_thousands END)            AS employment,
    MAX(CASE WHEN labour_characteristic = 'Unemployment'
        THEN count_thousands END)            AS unemployment,
    -- Flag logical violations
CASE
        WHEN MAX(CASE WHEN labour_characteristic = 'Labour force'
                THEN count_thousands END) >
             MAX(CASE WHEN labour_characteristic = 'Population'
                THEN count_thousands END)
        THEN 'FLAG: Labour force exceeds population'
        WHEN MAX(CASE WHEN labour_characteristic = 'Employment'
                THEN count_thousands END) >
             MAX(CASE WHEN labour_characteristic = 'Labour force'
                THEN count_thousands END)
        THEN 'FLAG: Employment exceeds labour force'
        WHEN MAX(CASE WHEN labour_characteristic = 'Unemployment'
                THEN count_thousands END) < 0
        THEN 'FLAG: Negative unemployment'
        ELSE 'PASS'
    END AS sanity_check
FROM clean_labour_monthly
GROUP BY reference_date
HAVING sanity_check != 'PASS'
ORDER BY reference_date;



