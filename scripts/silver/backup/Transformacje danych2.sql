INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- extract category ID
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- extract product key
prd_nm,
ISNULL(prd_cost, 0) AS prd_cost, --handling missing data
CASE UPPER(TRIM(prd_line)) 
	 WHEN 'M' THEN 'Mountain' --Data transformation
	 WHEN 'R' THEN 'Road'
	 WHEN 'S' THEN 'Other Sales'
	 WHEN 'T' THEN 'Touring'
	 ELSE 'NOT AVAILABLE' --handling missing data 
END AS prd_line,
CAST(prd_start_dt AS DATE) AS prd_start_dt, --data type casting
CAST(
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
	AS DATE
	) AS prd_end_dt --calculate end date as one day before next start date
FROM bronze.crm_prd_info;


-- Check for NULLS or duplicates in PK
-- Expectations: no result

SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- Expectations: no result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULL or negative costs
-- Expectations: no result
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standarization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


SELECT * 
FROM silver.crm_prd_info