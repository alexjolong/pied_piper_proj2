-- Set global variables
SET VAR:dname=pied_piper_sales_raw;

-- create databases

CREATE DATABASE IF NOT EXISTS ${var:dname}
COMMENT 'raw sales data';

-- Create Employees Table
CREATE EXTERNAL TABLE IF NOT EXISTS ${var:dname}.Employees
(EmployeeID int,
FirstName varchar,
MiddleInitial varchar,
LastName varchar,
Region varchar)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/raw_data/Employees/'
TBLPROPERTIES("skip.header.line.count"="1");

-- Reset metadata for table
invalidate metadata;
compute stats ${var:dname}.Employees;