-- Set global variables
SET VAR:dname=pied_piper_sales;
SET VAR:source_dname=pied_piper_sales_raw;

CREATE DATABASE IF NOT EXISTS ${var:dname}
COMMENT 'Parquet Sales Data imported from raw tables';

------------------------
-- create parquet tables
------------------------
-- remove one duplicate customer record from raw table
CREATE TABLE IF NOT EXISTS ${var:dname}.Customers
COMMENT 'Parquet Customers table'
STORED AS Parquet
AS
SELECT DISTINCT customerid, firstname, middleinit, lastname
FROM ${var:source_dname}.Customers;

/* Remove the invalid middle initial and rename instances of region=="east" to region = "East" */
CREATE TABLE IF NOT EXISTS ${var:dname}.Employees
COMMENT 'Parquet Employees table'
STORED AS Parquet
AS
SELECT employeeid, firstname, regexp_replace(middleinitial, "[^a-zA-Z]", "") AS middleinitial, lastname, initcap(region) AS region
FROM ${var:source_dname}.Employees;

/* create final products table, casting from float to decimal */
CREATE TABLE IF NOT EXISTS ${var:dname}.Products
COMMENT 'Parquet Products table'
STORED AS Parquet
AS 
SELECT ProductId, Name, cast(Price as DECIMAL(9, 2)) AS Price
FROM ${var:source_dname}.Products;

CREATE TABLE IF NOT EXISTS ${var:dname}.Sales
COMMENT 'Parquet Sales data'
STORED AS Parquet
AS
SELECT * FROM ${var:source_dname}.Sales;




/* reset metadata for table */
invalidate metadata;
compute stats ${var:dname}.Customers;
compute stats ${var:dname}.Employees;
compute stats ${var:dname}.Products;
compute stats ${var:dname}.Sales;