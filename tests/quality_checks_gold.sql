/* Purpose of this script is to perfom quality checks on our gold layer.*/

--Check for uniqueness of customer key in gold.dim_customers
--Expectation No result
SELECT
  customer_key
  COUNT(*) AS duplicate
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

--Check for uniqueness of prod key in gold.dim_products
--Expectation No result
SELECT
  product_key
  COUNT(*) AS duplicate
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;



--FOREIGN KEY INTEGRITY (dimensions) for gold.fact_sales
SELECT*
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL
