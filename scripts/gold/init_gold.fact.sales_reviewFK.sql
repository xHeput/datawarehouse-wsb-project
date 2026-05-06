-- foreign Key Integrity (dimensions)
select *
FROM gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
where c.customer_key IS NULL