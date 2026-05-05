/*
==================================================================================
AI GENERATED
==================================================================================
    Description:
    This script creates or updates the stored procedure silver.load_silver,
    which performs a full reload of the Silver layer in the DataWarehouseWSB
    database.

    The procedure reads raw data from the Bronze layer, applies cleaning,
    standardization, deduplication, validation, and transformation rules, and
    then inserts the prepared data into the corresponding Silver layer tables.

    Main operations performed by this procedure:
    - truncates Silver layer tables before loading new data
    - removes duplicate customer records using ROW_NUMBER()
    - trims unnecessary spaces from text fields
    - standardizes marital status, gender, country, and product line values
    - handles missing or invalid values using default values or NULL
    - extracts category IDs and product keys from product source keys
    - casts date fields into proper DATE format
    - recalculates incorrect sales and price values where needed
    - calculates product end dates using the next available start date
    - prints progress messages and load duration for each table
    - uses TRY...CATCH error handling to report loading errors

    Tables loaded by this procedure:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.erp_px_cat_g1v2

    Warning:
    This procedure is destructive for the Silver layer. Every time
    silver.load_silver is executed, all existing records in the Silver tables
    are removed using TRUNCATE TABLE before transformed data is inserted again.

    Make sure the Bronze layer tables are already loaded and contain valid
    source data before running this procedure. If the Bronze data is incomplete,
    outdated, or incorrect, the Silver layer will also be affected.

    If an error occurs after a Silver table has been truncated, that table may
    remain empty or only partially loaded until the issue is fixed and the
    procedure is executed again.

    Run this procedure only when a complete Silver layer reload is intended,
    such as during development, testing, or a controlled ETL refresh process.

    Note:
    The statement EXECUTE silver.load_silver is commented out at the beginning
    of the script. Uncomment and run it only after the procedure has been created
    or updated successfully.
*/
--EXECUTE silver.load_silver;

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_load_start_time DATETIME, @batch_load_end_time DATETIME;
	BEGIN TRY
		PRINT '=======================================================';
        PRINT 'Loading Silver Layer';
        PRINT '=======================================================';

        PRINT '#######################################################';
        PRINT 'Loading CRM Tables';
        PRINT '#######################################################';


		SET @batch_load_start_time = GETDATE();
        SET @start_time = GETDATE();
		PRINT 'Truncating into silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT 'Inserting into silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
			)
		SELECT 
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname, --Trimming 
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' --Data transformation
			 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			 ELSE 'NOT AVAILABLE' -- handling missing data 
		END cst_marital_status,
		CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' 
			 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			 ELSE 'NOT AVAILABLE'
		END cst_gndr,
		cst_create_date
		FROM ( -- remove duplicates
			SELECT
			*, 
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		)t WHERE flag_last = 1;
		SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT 'Truncating into silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT 'Inserting into silver.crm_prd_info';
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
		SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT 'Truncating into silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT 'Inserting into silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL --handling invalid data
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) --datatype casting
		END AS sls_order_dt,
		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price) --recalculate sales value in case wrong data
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity, 0) --recalculate price value in case wrong data
			ELSE sls_price
		END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';

		PRINT '#######################################################';
        PRINT 'Loading ERP Tables';
        PRINT '#######################################################';

		SET @start_time = GETDATE();
		PRINT 'Truncating into silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT 'Inserting into silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			CID,
			BDATE,
			GEN
		)
		SELECT
		CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
			ELSE CID
		END CID,
		CASE WHEN BDATE > GETDATE() THEN NULL
			ELSE BDATE
		END BDATE,
		CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
			 WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
			 ELSE 'NOT AVAILABLE'
		END AS GEN
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT 'Truncating into silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT 'Inserting into silver.erp_loc_a101';
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
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT 'Truncating into silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT 'Inserting into silver.erp_px_cat_g1v2';
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
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';

		SET @batch_load_end_time = GETDATE();
        PRINT 'Loading Silver Layer Completed';
        PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';
	END TRY
    BEGIN CATCH
    PRINT '=======================================================';
    PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
    PRINT 'Error Message' + ERROR_MESSAGE();
    PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
    PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
    PRINT '=======================================================';
    END CATCH
END