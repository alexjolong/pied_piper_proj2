-- set global variables
SET VAR:database_name=pied_piper_sales;

--create view customer_monthly_sales_2019_view on pied_piper_sales Data

--View: customer_monthly_sales_2019_view
--Customer id, customer last name, customer first name,
--year, month, aggregate total amount
--of all products purchased by month for 2019.

CREATE VIEW IF NOT EXISTS ${var:database_name}.customer_monthly_sales_2019_partitioned_view as
SELECT
p.customer_id as customerid
,c.lastname as lastname
,c.firstname as firstname
,year(p.order_date) as year
,month(p.order_date) as month
,count(DISTINCT p.product_id) as total_products
FROM ${var:database_name}.product_sales_partition p
JOIN ${var:database_name}.customers c 
ON (p.customer_id = c.customerid)
WHERE p.order_date between '2019-01-01 00:00:00' AND '2019-12-31 23:59:59'
GROUP BY
p.customer_id
,c.lastname
,c.firstname
,year(p.order_date)
,month(p.order_date);