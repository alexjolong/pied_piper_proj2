-- set global variables
SET VAR:database_name=pied_piper_sales;

--create view top_ten_customers_amount_view on pied_piper_sales Data

-- View: top_ten_customers_amount_view 
-- Customer id, customer last name, customer first name, total lifetime purchased amount
-- This view should only return the top ten customers sorted 
-- by total dollar amount in sales from highest to lowest. 

CREATE VIEW IF NOT EXISTS ${var:database_name}.top_ten_customers_amount_view as
Select 
c.customerid as customerid
,c.lastname as lastname
,c.firstname as firstname
,a.total_lifetime_purchases
From ${var:database_name}.customers c 
join
(
    Select 
        s.customerid
        ,sum(p.price * s.quantity) as total_lifetime_purchases
    From ${var:database_name}.sales s
    JOIN ${var:database_name}.products p
    ON (s.productid = p.productid)
    GROUP BY s.customerid
) a
on (c.customerid = a.customerid)
order by a.total_lifetime_purchases desc
limit 10;

-- reset metadata for view
invalidate metadata;
compute stats ${var:database_name}.top_ten_customers_amount_view;
