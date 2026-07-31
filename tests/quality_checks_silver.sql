/* Quality Checks:
This script performs quality checks for our silver table. Includes checks for Nulls or duplicates, extra spaces, 
data consistency, invalid date ranges, and data consistency regarding other tables. Check using this script after you have 
loaded the silver layer. */

--Check for nulls or duplicates in primary key
--Expectation: No result
SELECT
cst_id,
COUNT(*) TotalCount
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 OR cst_id IS NULL

--check for unwanted spaces
--expectation: no results
SELECT 
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname!= TRIM(cst_firstname)

SELECT 
cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname!= TRIM(cst_lastname)

-- Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

--check for unwanted spaces
--expectation: no results
SELECT 
prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm!= TRIM(prd_nm)
  
--Quality checks
SELECT
prd_id,
COUNT(*) TotalCount
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) >1 OR prd_id IS NULL

--check for unwanted spaces
SELECT 
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm!= TRIM(prd_nm)

--check for nulls or negatuve
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL

--data standardization and Consistence
SELECT DISTINCT 
prd_line
FROM silver.crm_prd_info

--check for invalud date orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--------------------------------------------------
/* Check for Invalid dates for sales details*/
---------------------------------------------------
SELECT
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt<=0 OR LEN(sls_order_dt) != 8 OR sls_order_dt > 20500101 OR sls_order_dt <19000101

--check for invalid date orders
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt >sls_due_dt

-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity<=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price

SELECT * FROM silver.crm_sales_details

SELECT
cid,
CASE 
	WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4,LEN(cid)) --extract characters starting at 4
	ELSE cid
END cid,
bdate,
gen
FROM bronze.erp_cust_az12
/*WHERE CASE 
	WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4,LEN(cid)) --extract characters starting at 4
	ELSE cid
END NOT IN( SELECT DISTINCT cst_key FROM silver.crm_cust_info ) */ --check for outliers that dont match customer table

--Identify Dates out of range
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate> GETDATE()

--Data Standardization and Consistency
SELECT DISTINCT 
gen,
CASE 
	WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	ELSE 'N/A'
END AS gen
FROM silver.erp_cust_az12

SELECT*
FROM silver.erp_cust_az12

---------------------------------------------------------------
--data standardization and consistency
SELECT DISTINCT
cntry
FROM silver.erp_loc_a101
ORDER BY cntry

SELECT* 
FROM silver.erp_loc_a101
------------------------------------------------


--check for unwanted spaces
SELECT* FROM silver.erp_px_cat_g1v2
WHERE cat!= TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

--Data Standardization
SELECT DISTINCT
cat,
maintenance
FROM silver.erp_px_cat_g1v2

SELECT*
FROM silver.erp_px_cat_g1v2
