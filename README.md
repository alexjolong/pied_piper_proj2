# pied_piper_proj2
Repository for CSCI 5751 (Spring 2020) Project 2 - Hadoop

# Deliverable 1
- **Team name:** Pied Piper
- **Slack channel name:** pied_piper
- **Team Members:**
   - Alex Long [(longx552)](mailto:longx552@umn.edu)
   - Connor Theisen [(theis417)](mailto:theis417@umn.edu)
   - Sam Bloomquist [(bloom246)](mailto:bloom246@umn.edu)
   - Stepan Subbotin [(subbo001)](mailto:subbo001@umn.edu)

# Setup and Running
- This project is meant to be deployed within a Cloudera environment. Here are the steps we followed, which you can replicate.
   1. Install VirtualBox and download cloudera-quickstart-vm-5.13.0.0. Boot virtual disk with the following settings (note my base machine is Windows 10 Education, patch 1909, with intel i7 4-core and 16GB RAM. I turned Hyper-V off for this project.)
      - **OS:** Red Hat Linux (64-bit) v6.7
      - **CPUs:** 3
      - **Base Memory:** 10736 MB
      - **Video Memory:** 16 MB
      - **Network Adapter:** Enabled
   2. Add a TCP port-forwarding rule as per the instructions, from host port 2222 to guest port 22
- Once your virtual machine is set up, you can clone this repo with the command `git clone https://github.com/alexjolong/pied_piper_proj2.git`. The resulting directory will be named 'pied_piper_proj2'.
- **To run deliverable 2**, open a terminal from the project directory (the same location as this file) and enter the command `bash ./bash/deploy-proj2.sh --do_deliverable_2`. Alternatively, you can do each step in this process with individual commands:
   1. `bash ./bash/deploy-proj2.sh --download_data`: Downloads data from AWS
   2. `bash ./bash/deploy-proj2.sh --load_data`: Loads the data from Linux's ext4 file system to HDFS
   3. `bash ./bash/deploy-proj2.sh --create_raw_tables`: Creates external table views around the files in HDFS which can be queried from Impala.
- **To clean deliverable 2**, run the command `bash ./bash/deploy-proj2.sh --clean_deliverable_2`. Alternatively, you can do each step in this process with individual commands:
   1. `bash ./bash/deploy-proj2.sh --drop_sales_database`
   2. `bash ./bash/deploy-proj2.sh --drop_raw_database`
   3. `bash ./bash/deploy-proj2.sh --delete_hdfs_raw_data`
- **To run deliverable 3**, enter the command `bash ./bash/deploy-proj2.sh --create_partitions`, which will create the following partition tables and views in the impala-shell database `pied_piper_sales`:
   1. `product_sales_partition`
   2. `customer_monthly_sales_2019_partitioned_view`
   3. `product_region_sales_partition`
- **To clean deliverable 3**, if you are just wanting to drop all the partition tables/views, run the command `bash ./bash/deploy-proj2.sh --drop_partitions`. 
   1. However, if you are doing a full data deletion and reload into the system, which includes deleting all the tables and views for deliverable 2 and deliverable 3, you can simply run the command `bash ./bash/deploy-proj2.sh --clean_deliverable_2` because `--clean_deliverable_2` drops the sales db which drops all the views and tables contained in the db. 
- **To clean all data**, run the command `bash ./bash/deploy-proj-2.sh --clean_deliverable_2`
- **Need help or need to look for specific function calls without having to look at the code?** Run the command `bash ./bash/deploy-proj2.sh -h` OR `bash ./bash/deploy-proj2.sh --help` to display the contents, function call options, and a short descriptions of each function call's purpose. 
   1. These will be helpful for you to see all function call options if you are desiring individual functon calls for certain operations without having to look within the code script itself
   
# Data Integrity
We analyzed the raw sales data to discover any data cleanliness issues. Here are our findings:
- One meta-issue with the defined schema in the assignment is that it requests a column in the Sales table named Date, which is a reserved keyword in Impala. A different name would be better, but we can work around it.
- **Analysis of Customer file**:
   - Distinct customer IDs: 19,759 , number of rows: 19,760. There are two instances of one of the same record. This turns out to be CustomerID 17,829: Stefanie Smith
   - Customer IDs range from 1 to 19759, as expected.
   - We look for any first or last names that are invalid names (don't start with an alphabetical). There aren't any, but there are 49 names with letters not in the simple alphabet set [a-zA-Z]. For example "Jésus", "Yao-Qiang", and "Ty Loren". These all look like valid names, so we see no problems here.
   - The same process for last names reveals 89 non-simple last names, but no invalid or missing last names.
   - There are 8,334 records with blank middle initials. 11,426 have alphabetical middle initials, and none have any invalid middle initials. No problems here.
- **Analysis of Employees file**:
   - Distinct employee IDs: 23, number of rows: 23. Employee IDs range from 1 to 23, no problems here.
   - There are no invalid first or last names (not starting with alphabetic), although there are three last names which have a non-alphabetic character such as "Blotchet-Halls". There is one employee with an invalid middle initial " ' ". We will set this to an empty string.
   - There are 5 regions - North, South, West, East, and east, with 4 employees in east and 3 in East. We will combine these by setting all values of east to East.
- **Analysis of Products file**: 
   - Distinct product IDs: 504, number of rows: 504. There were no duplicate productIDs or names in the raw data
   - When loading data from the csv file into the raw table, Impala was unable to do a cast from string to decimal for the Price column. This required us to make the Price column a Float type. When creating the managed table, we successfully cast the float values into decimals precise to the hundredths place (emulating cents in a dollar amount).
   - There are 274 product names with at least one occurance of non alphanumeric characters. In all cases, they were "-", ",", "/", or " ' ". These are valid characters to be in a product name so we have left them as is in the managed table.
- **Analysis of Sales file**:
   - 6,715,221 distinct rows
   - 23 sales person ids, ranging from 1 to 23, this corresponds to the 23 employee ids in the employees table. 
   - There are 567 distinct customer ids present, which correspond to customer ids in the customer table. This means that of the 19,759 customers in the customers table, only 567 of them have purchased products. The ids range from 1 to 19,680. 
   - All 504 products from the product table are present in this table as well, under the productid column. 
   - The quantity of items in a sale range from 1-1042. There are no negative numbers or nonnumeric characters. 

In addition, we noticed that some customers were making many very large orders. The customer with the largest total sales purchased over $70 Billion worth of product, so we wanted to investigate further. We found that top customers such as Customer ID 5040 frequently submitted identical orders closely together (within hours or minutes). 
![Most expensive single-item purchases by customer 5040](/documentation/biggest_item_purchases_5040.png)
Since these orders came in at different times and with separate order IDs, we have to assume they are valid. However, this could potentially be a problem with the order entry system allowing multiple entries of the same order (i.e. the user may have pressed "send" multiple times on the same order!). We would encourage our business partners to look into this.

# Partitioning Performance
When we compare the performance on the 2019 monthly sales view using partitioned and non-partitioned data, `customer_monthly_sales_2019_partitioned_view` versus `customer_monthly_sales_2019_view`, we see more efficient performance from the partitioned data than the non-partitioned view. 

We should mention that `customer_monthly_sales_2019_partitioned_view` is partitioned by year and month, which we get from the partitioned sales_year and sales_month from our partitioned table `product_sales_partition`. Our sql script that creates the partitioned monthly sales data view by joinning the partitioned table `product_sales_partition` and the table `customers`. The partitioned columns of sales_year and sales_month from `product_sales_partition` become the year and month variables in the partitioned view `customer_monthly_sales_2019_partitioned_view`. We are aware that having a partitioned year variable seems tedious for this particular view since it only focuses on 2019 data, but we felt necessary to keep it in for the case that this view could be modified in future steps to include more years. 

To test the performance of the the 2019 monthly sales view using partitioned and non-partitioned data views, we ran several different impala-shell commandline queries that filtered based on the month variable (both views only have 2019 data, no point in using year). We would thing run the command `summary;` after each query call to help give us an overview of the timings for the different phases of execution for a query such as average time of aggregation execution, so we're looking at the breakdown of the total execution time of the query. 

**One example** to show you our analysis of the performance of the 2019 monthly sales view using partitioned and non-partitioned data views is the following (under the database `pied_piper_sales`): 
In the impala-commandline, we executed the following queries and commands where we looked for 2019 monthly sales data for only the first 6 months (months BETWEEN 1 AND 6) and limited the output to 10 (limit 10):

**Partitioned: customer_monthly_sales_2019_partitioned_view Query calls and outputs**

`select * from customer_monthly_sales_2019_partitioned_view where month BETWEEN 1 AND 6 limit 10;`
![The query on partitioned data output and results](/documentation/partitioned-query-results-and-output.png)

`summary;`
![Summary of the partitioned data query above](/documentation/summary-of-partitioned-query.png)

**Non-partitioned: customer_monthly_sales_2019_view Query calls and outputs**

`select * from customer_monthly_sales_2019_view where month BETWEEN 1 AND 6 limit 10;`
![The query on non-partitioned data output and results](/documentation/non-partitioned-query-results-and-output.png)

`summary;`
![Summary of the partitioned data query above](/documentation/summary-of-non-partitioned-query.png)

As you see, not only did the partitioned data have quicker overall execution time and response than the non-partitioned data when executing the query, but all the different phases of execution for the query would be quicker and more responsive for partitioned data an overwhelmingly majority of cases. 

**Overall**, the partitioned data view is quicker and more responsive than the non-partitioned view. We should note that the difference in the total time execution between these two queries sometimes varies, such as (Partitioned query vs Non-partitioned query)

   - 1.05s versus 1.47s
   - 2.34s versus 8.68s
   
So it may be slightly dependent on the system or how the system is behaving at times. Regardless, every different run of these queries, the partitioned view query was always faster. 

Our performance analysis bascially proves and shows that the partitions (year and month) are allowing Impala to skip the data in all partitions outside the specified range we used for year and month. Thus, leading to faster execution phases in the queries and getting faster results.  

**THEREFORE**, we can assume that when it comes to data visualization purposes, we would expect the partitioned data view to be more responsive in giving us our desired insights and aggregations our data viz actions than the non-partitioned data view. In any data visualization tools, we are likely filtering the vis to display recent sales, or only care about monthly aggregates that can be computed as partition statistics without having to drill down. These partitioned columns will help reduce the effort in that filtering to make the vizualizations come out more quickly, likely more accurate, and even grab updates in the data quicker when partitions update or new data is added with those partitions compared to when data is not partitioned. 

**SIDE NOTE observation**: When it came to creation of the partitioned and non-partitioned data views for the 2019 monthly sales data, the partitioned view took a little longer. However, as you can see from our observations above, it's still more worth it to have a partitioned date view than a non-partitioned data view, especially for data vizualization. 

**Non-partition: customer_monthly_sales_2019_view**
   - **Runtime creation**: Running the SQL script that creates this view takes about 0.02-7.90s. Creation run-time varies a lot and can be system dependent at times. 
 
**Partition: customer_monthly_sales_2019_partitioned_view**
   - NOTE: This partitioned view uses the partitioned table `product_sales_partition`, so we need to make sure that the partitioned table `product_sales_partition` is created.
   - Creating `product_sales_partition` takes about 49.62s - 50.15s
   - **However, Runtime creation** for just `customer_monthly_sales_2019_partitioned_view` is about 3.08s-9.20s. Creation run-time varies a lot and can be system dependent at times.

Overall, the partitioned views may take a little longer to create, but it's really system dependent and it's still worth it to have a partitioned data view
