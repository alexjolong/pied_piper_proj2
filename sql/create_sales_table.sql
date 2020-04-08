-- set global variables
SET VAR:dname=pied_piper_sales_raw;

CREATE DATABASE IF NOT EXISTS ${var:dname}
COMMENT 'raw sales data';

-- create products table
CREATE EXTERNAL TABLE IF NOT EXISTS ${var:dname}.Sales
(OrderID int,
SalesPersonID int,
CustomerID int,
ProductID int,
Quantity int,
`Date` timestamp)
ROW FORMAT DELIMITED   
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/data/Sales/'
TBLPROPERTIES("skip.header.line.count"="1");

-- reset metadata for table
invalidate metadata;
compute stats ${var:dname}.Sales;