
#2.1 — Encounters by Insurance Coverage
#Question: Which insurance types are most common, and how many encounters are associated with each?
SELECT p.name, COUNT(p.name) as p_count
FROM payers p
 GROUP BY p.name
 ORDER BY p_count DESC;



#2.2 — Average Cost per Encounter
#Question: What is the average cost per encounter, by encounter type?
SELECT e.encounterclass, ROUND(AVG(e.Total_CLAIM_COST), 2) as avg_cost
FROM encounters e
GROUP BY e.ENCOUNTERCLASS
ORDER BY avg_cost

;

#2.3 — Cost Distribution by Encounter Type
#Goal: Compare average and total costs across encounter types

SELECT 
    e.encounterclass AS encounter_type,
    ROUND(AVG(e.total_claim_cost), 2) AS avg_cost,
    ROUND(SUM(e.total_claim_cost), 2) AS total_cost,
    COUNT(e.encounter_id) AS encounter_count
FROM encounters e
WHERE e.total_claim_cost IS NOT NULL
GROUP BY e.encounterclass
ORDER BY total_cost DESC;



#2.4 — High-Cost Encounters
#Question: Identify encounters with exceptionally high costs (e.g., top 5% of costs) to flag for review.
WITH ranked_encounters AS (
    SELECT 
        e.encounter_id,
        e.patient_id,
        e.total_claim_cost,
        PERCENT_RANK() OVER (ORDER BY e.total_claim_cost) AS cost_percentile
    FROM encounters e
    WHERE e.total_claim_cost IS NOT NULL
)
SELECT 
    encounter_id,
    patient_id,
    ROUND(total_claim_cost, 2) AS total_cost,
    ROUND(cost_percentile * 100, 2) AS percentile
FROM ranked_encounters
WHERE cost_percentile >= 0.95
ORDER BY total_claim_cost DESC;


#2.5 — Insurance Coverage vs Cost Analysis
#Question: How does average cost vary by insurance type
SELECT p.name, ROUND(AVG(e.TOTAL_CLAIM_COST), 2) as avg_cost
FROM payers p
JOIN encounters e ON p.payer_id = e.payer
GROUP BY p.name
ORDER BY avg_cost
;






ALTER TABLE payers
RENAME COLUMN ï»¿Id TO payer_id;
