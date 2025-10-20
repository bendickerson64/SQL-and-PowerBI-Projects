USE air_quality;

-- Data Quality Assessment Report
SELECT 
    'Total Records' AS metric,
    COUNT(*) AS value
FROM raw_air_quality

UNION ALL

SELECT 
    'Cleaned Records',
    COUNT(*) 
FROM cleaned_air_quality

UNION ALL

SELECT 
    'Data Quality - VALID',
    COUNT(*)
FROM cleaned_air_quality 
WHERE data_quality_flag = 'VALID'

UNION ALL

SELECT 
    'Data Quality - INVALID_GEO_OR_DATE',
    COUNT(*)
FROM cleaned_air_quality 
WHERE data_quality_flag = 'INVALID_GEO_OR_DATE'

UNION ALL

SELECT 
    'Data Quality - INVALID_MEASUREMENTS',
    COUNT(*)
FROM cleaned_air_quality 
WHERE data_quality_flag = 'INVALID_MEASUREMENTS';

-- Missing values analysis by column
SELECT 
    'state_code' AS column_name,
    COUNT(*) AS missing_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw_air_quality), 2) AS missing_percent
FROM raw_air_quality 
WHERE state_code IS NULL OR TRIM(state_code) = ''

UNION ALL
SELECT 'county_code', COUNT(*), ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw_air_quality), 2)
FROM raw_air_quality WHERE county_code IS NULL OR TRIM(county_code) = ''

UNION ALL
SELECT 'latitude', COUNT(*), ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw_air_quality), 2)
FROM raw_air_quality WHERE latitude IS NULL OR TRIM(latitude) = ''

UNION ALL
SELECT 'arithmetic_mean', COUNT(*), ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw_air_quality), 2)
FROM raw_air_quality WHERE arithmetic_mean IS NULL OR TRIM(arithmetic_mean) = '';

-- Sample of cleaned data for verification
SELECT 
    parameter_name,
    units_of_measure,
    AVG(arithmetic_mean) AS avg_measurement,
    COUNT(*) AS record_count
FROM v_cleaned_air_quality
WHERE data_quality_flag = 'VALID'
GROUP BY parameter_name, units_of_measure
ORDER BY record_count DESC
LIMIT 10;