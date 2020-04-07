#!/bin/sh
echo "Making Hadoop Folders for Impala Load..."
hdfs dfs -mkdir -p '/user/hive/warehouse/raw_data/Customers/'
hdfs dfs -mkdir -p '/user/hive/warehouse/raw_data/Employees/'
hdfs dfs -mkdir -p '/user/hive/warehouse/raw_data/Products/'
hdfs dfs -mkdir -p '/user/hive/warehouse/raw_data/Sales/'
echo "Putting data into Hadoop Distributed File System..."
sudo -u hdfs hdfs dfs -put ./salesdb/Customers2.csv '/user/hive/warehouse/raw_data/Customers/Customers.csv'
sudo -u hdfs hdfs dfs -put ./salesdb/Employees2.csv '/user/hive/warehouse/raw_data/Employees/Employees.csv'
sudo -u hdfs hdfs dfs -put ./salesdb/Products.csv '/user/hive/warehouse/raw_data/Products/Products.csv'
sudo -u hdfs hdfs dfs -put ./salesdb/Sales2.csv '/user/hive/warehouse/raw_data/Sales/Sales.csv'
echo "Make Impala/Hive the owner of our raw data in HDFS"
sudo -u hdfs hdfs dfs -chown -R hive:hive "/user/hive/warehouse/raw_data"