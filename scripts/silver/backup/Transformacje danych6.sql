INSERT INTO silver.erp_px_cat_g1v2(
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
)
SELECT 
ID,
CAT,
SUBCAT,
MAINTENANCE
FROM bronze.erp_px_cat_g1v2

-- Check for unwanted spaces
SELECT * FROM  bronze.erp_px_cat_g1v2
WHERE CAT != TRIM(CAT) OR SUBCAT != TRIM(SUBCAT) OR MAINTENANCE != TRIM(MAINTENANCE)

-- Data Standarization and Consistency
SELECT DISTINCT
MAINTENANCE
FROm bronze.erp_px_cat_g1v2

SELECT * FROM silver.erp_px_cat_g1v2