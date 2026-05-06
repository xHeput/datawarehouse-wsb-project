-- dimension
CREATE VIEW gold.dim_products AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pc.ID AS category_ID,
    pc.CAT AS category,
    pc.SUBCAT AS subcategory, 
	pc.MAINTENANCE,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_catg1v2 pc
    ON REPLACE(SUBSTRING(pn.prd_key, 1, 5), '-', '_') = pc.ID -- 
WHERE prd_end_dt IS NULL OR prd_end_dt = '' -- 
