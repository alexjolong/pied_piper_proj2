-- set global variables
SET VAR:dname=pied_piper_sales_raw;

CREATE DATABASE IF NOT EXISTS ${var:dname}
COMMENT 'raw sales data';

-- create temp products table
CREATE EXTERNAL TABLE IF NOT EXISTS ${var:dname}.Products1
(ProductId int,
Name varchar,
Price float)
ROW FORMAT DELIMITED   
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/data/Products/'
TBLPROPERTIES("skip.header.line.count"="1");

-- create final products table, casting from float to decimal
CREATE EXTERNAL TABLE IF NOT EXISTS ${var:dname}.Products
AS SELECT ProductId, Name, cast(Price as DECIMAL(9, 2)) AS Price
FROM pied_piper_sales_raw.Products1;

DROP TABLE pied_piper_sales_raw.Products1;

-- reset metadata for table
invalidate metadata;
compute stats ${var:dname}.Products;
