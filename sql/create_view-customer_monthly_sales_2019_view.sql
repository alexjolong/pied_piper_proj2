-- set global variables
SET VAR:database_name=pied_piper_sales;

--create view customer_monthly_sales_2019_view on pied_piper_sales Data

--View: customer_monthly_sales_2019_view
--Customer id, customer last name, customer first name,
--year, month, aggregate total amount
--of all products purchased by month for 2019.

CREATE VIEW IF NOT EXISTS ${var:database_name}.customer_monthly_sales_2019_view as
Select 
c.customerid as customerid
,c.lastname as lastname
,c.firstname as firstname
,year(a.`date`) as year 
,month(a.`date`) as month 
,sum(a.price * a.quantity) as total_purchase_amount
From ${var:database_name}.customers c 
join
(
    Select 
    s.customerid
    ,s.`date`
    ,p.price
    ,p.quantity
    From ${var:database_name}.sales s
    join ${var:database_name}.products p
    on (s.productid = p.productid)
    where s.`date` between '2019-01-01 00:00:00' AND '2019-12-31 23:59:59' -- bounds are inclusive
) a
on (c.customerid = a.customerid)
group by 
c.customerid
,c.lastname
,c.firstname
,year(a.`date`)
,month(a.`date`);
