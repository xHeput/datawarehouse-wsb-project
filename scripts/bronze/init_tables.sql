/*

==================================================================================
AI GENERATED
==================================================================================

    Description:
    This script creates the Bronze layer tables for the DataWarehouseWSB database.
    These tables are designed to store raw source data from CRM and ERP systems
    before any cleaning, transformation, or business logic is applied.

    The script first checks whether each table already exists in the bronze schema.
    If a table exists, it is dropped and then recreated with the defined structure.

    Tables created by this script:
    - bronze.crm_cust_info: raw CRM customer information
    - bronze.crm_prd_info: raw CRM product information
    - bronze.crm_sales_details: raw CRM sales transaction details
    - bronze.erp_cust_az12: raw ERP customer demographic data
    - bronze.erp_loc_a101: raw ERP customer location data
    - bronze.erp_px_cat_g1v2: raw ERP product category data

    Warning:
    This script is destructive. If any of these Bronze layer tables already exist,
    they will be permanently dropped and recreated.

    Dropping the tables will delete all existing data, indexes, constraints,
    permissions, and other table-level objects associated with them.

    Run this script only when you are sure the existing Bronze layer data can be
    removed, such as during initial setup, development, or a full reload process.
*/

IF OBJECT_ID ('bronze.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);

IF OBJECT_ID ('bronze.crm_prd_info' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);

IF OBJECT_ID ('bronze.crm_sales_details' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

IF OBJECT_ID ('bronze.erp_cust_az12' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_loc_a101' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_px_cat_g1v2' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTENANCE NVARCHAR(50)
);