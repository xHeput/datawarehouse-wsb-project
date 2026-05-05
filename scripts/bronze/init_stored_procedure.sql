/*
==================================================================================
AI GENERATED
==================================================================================
    Description:
    This script creates or updates the stored procedure bronze.load_bronze,
    which performs a full reload of the Bronze layer in the DataWarehouseWSB
    database.

    The procedure loads raw data from CRM and ERP CSV source files into the
    corresponding Bronze tables. For each target table, the procedure:
    - records the load start time
    - truncates the existing table data
    - loads new data using BULK INSERT
    - records and prints the load duration
    - prints progress messages for easier monitoring

    Tables loaded by this procedure:
    - bronze.crm_cust_info
    - bronze.crm_prd_info
    - bronze.crm_sales_details
    - bronze.erp_cust_az12
    - bronze.erp_loc_a101
    - bronze.erp_px_cat_g1v2

    The procedure also includes TRY...CATCH error handling to display error
    details if the Bronze layer loading process fails.

    Warning:
    This procedure is destructive. Every time bronze.load_bronze is executed,
    all existing records in the Bronze layer tables are removed using
    TRUNCATE TABLE before new data is inserted.

    Make sure the source CSV files exist at the specified file paths and are
    accessible from the SQL Server machine. If a BULK INSERT fails after a table
    has been truncated, the affected table may remain empty until the issue is
    fixed and the procedure is executed again.

    Run this procedure only when a complete Bronze layer reload is intended,
    such as during development, testing, or a controlled ETL refresh process.

    Note:
    The statement EXECUTE bronze.load_bronze should normally be placed after
    the CREATE OR ALTER PROCEDURE block. Executing it before the procedure is
    created or updated may fail if the procedure does not already exist.
*/

--EXECUTE bronze.load_bronze;

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_load_start_time DATETIME, @batch_load_end_time DATETIME;
    BEGIN TRY
        PRINT '=======================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=======================================================';

        PRINT '#######################################################';
        PRINT 'Loading CRM Tables';
        PRINT '#######################################################';

        SET @batch_load_start_time = GETDATE();
        SET @start_time = GETDATE();
        PRINT 'Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT 'Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\User\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
	        FIRSTROW = 2,
	        FIELDTERMINATOR = ',',
	        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';
        --SELECT * FROM bronze.crm_cust_info;

        SET @start_time = GETDATE();
        PRINT 'Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT 'Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\User\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
	        FIRSTROW = 2,
	        FIELDTERMINATOR = ',',
	        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';
        --SELECT * FROM bronze.crm_prd_info;

        SET @start_time = GETDATE();
        PRINT 'Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT 'Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\User\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
	        FIRSTROW = 2,
	        FIELDTERMINATOR = ',',
	        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';
        --SELECT * FROM bronze.crm_sales_details;

        SET @start_time = GETDATE();
        PRINT '#######################################################';
        PRINT 'Loading ERP Tables';
        PRINT '#######################################################';
        PRINT 'Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT 'Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\User\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
	        FIRSTROW = 2,
	        FIELDTERMINATOR = ',',
	        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';
        --SELECT * FROM bronze.erp_cust_az12;

        SET @start_time = GETDATE();
        PRINT 'Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT 'Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\User\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
	        FIRSTROW = 2,
	        FIELDTERMINATOR = ',',
	        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';
        --SELECT * FROM bronze.erp_loc_a101;

        SET @start_time = GETDATE();
        PRINT 'Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT 'Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\User\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
	        FIRSTROW = 2,
	        FIELDTERMINATOR = ',',
	        TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';
        --SELECT * FROM bronze.erp_px_cat_g1v2;
        SET @batch_load_end_time = GETDATE();
        PRINT 'Loading Bronze Layer Completed';
        PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------';
    END TRY
    BEGIN CATCH
    PRINT '=======================================================';
    PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
    PRINT 'Error Message' + ERROR_MESSAGE();
    PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
    PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
    PRINT '=======================================================';
    END CATCH
END