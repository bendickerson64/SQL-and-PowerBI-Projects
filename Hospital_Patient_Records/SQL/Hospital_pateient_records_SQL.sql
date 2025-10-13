#Hospital Analytics SQL Project


#1.1. Monthly Encounter Volume
#Count the number of encounters per month to identify trends over time.
#-- 1.1 Monthly Encounter Volume
-- 1.1 Monthly Encounter Volume
SELECT 
    DATE_FORMAT(e.start, '%Y-%m') AS month,
    COUNT(e.encounter_id) AS total_encounters
FROM encounters e
GROUP BY DATE_FORMAT(start, '%Y-%m')
ORDER BY month;


#1.2. Encounter Volume by Type
#Goal: Compare the total number of encounters for each encounter type (e.g., Inpatient, Outpatient, Emergency), to understand how patient volume varies across types.
SELECT 
	encounterclass, COUNT(e.encounter_id) AS total_encounters, ROUND(COUNT(e.encounter_id) * 100.0 / (SELECT COUNT(*) FROM encounters), 2) as pct_of_total
FROM encounters e
GROUP BY encounterclass
ORDER BY total_encounters;

##1.3 — Average Length of Stay (LOS)
#Goal: Calculate the average number of days patients stay in the hospital for inpatient encounters.
SELECT e.encounterclass, 
ROUND(AVG(DATEDIFF(e.stop, e.start)), 2) AS avg_length_of_stay,
ROUND(MIN(DATEDIFF(e.stop, e.start)), 2) AS short_stay,
ROUND(MAX(DATEDIFF(e.stop, e.start)), 2) AS Longest_stay
FROM encounters e
WHERE encounterclass = 'inpatient'
	AND e.start IS NOT NULL
    AND e.stop IS NOT NULL
GROUP BY encounterclass
ORDER BY avg_length_of_stay;

#1.4 — Longest Stays
#Goal: Identify the top 10 longest inpatient stays and the departments (or service units) where they occurred. This helps highlight where extended care durations happen most often.
SELECT 
    e.encounter_id, p.patient_id, e.encounterclass,
DATEDIFF(e.stop, e.start) AS length_of_stay
FROM encounters e
JOIN patients p ON e.patient_id = p.patient_id
WHERE e.encounterclass = 'inpatient'
	AND e.start IS NOT NULL
    AND e.stop IS NOT NULL
ORDER BY length_of_stay DESC
LIMIT 10;



#1.5 — First vs. Repeat Encounters
#Goal: Count how many patients are first-time visitors vs. repeat patients
 
WITH first_encounters AS (
    SELECT e.patient_id, MIN(e.start) AS first_date
    FROM encounters e
    GROUP BY e.patient_id
)
SELECT
    CASE
        WHEN e.start = f.first_date THEN 'First-Time'
        ELSE 'Repeat'
    END AS encounter_type,
    COUNT(DISTINCT e.patient_id) AS patient_count
FROM encounters e
JOIN first_encounters f 
    ON e.patient_id = f.patient_id
GROUP BY
    CASE
        WHEN e.start = f.first_date THEN 'First-Time'
        ELSE 'Repeat'
    END;


#1.6. Peak Encounter Days Find which day of the week and time of day have the highest encounter volumes.
SELECT
DAYNAME(e.start) as day_of_week,
HOUR(e.start) as hour_of_day,
COUNT(*) as enc_count
FROM encounters e
WHERE e.start IS NOT NULL
GROUP BY day_of_week, hour_of_day
ORDER BY enc_count DESC
;


#1.7. Encounter Growth Rate Calculate the year-over-year percentage change in encounter volume.

WITH yearly_counts AS (
SELECT
	YEAR(e.start) as encounter_year,
    COUNT(*) as encounters
    FROM encounters e
	WHERE e.start IS NOT NULL
    GROUP BY YEAR(start)
    )
    SELECT 
    yc.encounter_year,
    yc.encounters,
    LAG(yc.encounters) OVER (ORDER BY yc.encounter_year) AS prev_year_encounters,
    ROUND(
        (yc.encounters - LAG(yc.encounters) OVER (ORDER BY yc.encounter_year)) 
        / LAG(yc.encounters) OVER (ORDER BY yc.encounter_year) * 100, 2
    ) AS yoy_growth_percent
FROM yearly_counts yc
ORDER BY yc.encounter_year;
    

#1.9 — Encounter Duration Distribution
#Goal: Categorize inpatient stays into buckets and count how many fall into each

SELECT
    CASE
        WHEN DATEDIFF(stop, start) BETWEEN 0 AND 2 THEN '0-2 days'
        WHEN DATEDIFF(stop, start) BETWEEN 3 AND 5 THEN '3-5 days'
        WHEN DATEDIFF(stop, start) BETWEEN 6 AND 10 THEN '6-10 days'
        ELSE '10+ days'
    END AS stay_duration,
    COUNT(*) AS encounter_count
FROM encounters
WHERE encounterclass = 'inpatient'
  AND start IS NOT NULL
  AND stop IS NOT NULL
GROUP BY stay_duration
ORDER BY 
    CASE stay_duration
        WHEN '0-2 days' THEN 1
        WHEN '3-5 days' THEN 2
        WHEN '6-10 days' THEN 3
        WHEN '10+ days' THEN 4
    END;















ALTER TABLE encounters
RENAME COLUMN patient TO patient_id;
