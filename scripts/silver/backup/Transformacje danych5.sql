INSERT INTO silver.erp_loc_a101(
	CID,
	CNTRY
)
SELECT 
REPLACE(CID, '-', '') AS CID,
CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
	 WHEN TRIM(CNTRY) = 'US' THEN 'United States'
	 WHEN TRIM(CNTRY) = 'USA' THEN 'United States'
	 WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'NOT AVAILABLE'
	 ELSE TRIM(CNTRY)
END AS CNTRY
FROM bronze.erp_loc_a101

--Data standarization and consistency
SELECT DISTINCT
CNTRY
FROM silver.erp_loc_a101
ORDER BY CNTRY

SELECT * FROM silver.erp_loc_a101