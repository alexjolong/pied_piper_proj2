-- Set global variables
SET VAR:dname=pied_piper_sales_raw;

CREATE DATABASE IF NOT EXISTS ${var:dname}
COMMENT 'raw sales data';

-- create customers table
CREATE EXTERNAL TABLE IF NOT EXISTS ${var:dname}.Customers
(CustomerId int,
FirstName VARCHAR,
MiddleInit VARCHAR,
LastName VARCHAR)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/data/Customers/'
TBLPROPERTIES("skip.header.line.count"="1");

-- reset metadata for table
invalidate metadata;
compute stats ${var:dname}.Customers;