# pied_piper_proj2
Repository for CSCI 5751 (Spring 2020) Project 2 - Hadoop

# Deliverable 1:
- **Team name:** Pied Piper
- **Slack channel name:** pied_piper
- **Team Members:**
   - Alex Long [(longx552)](mailto:longx552@umn.edu)
   - Connor Theisen [(theis417)](mailto:theis417@umn.edu)
   - Sam Bloomquist [(bloom246)](mailto:bloom246@umn.edu)
   - Stepan Subbotin [(subbo001)](mailto:subbo001@umn.edu)

# Setup:
- Steps for setting up Cloudera environment:
   1. Followed along with "Cloudera VM Download and SetUp Notes", installed VirtualBox and downloaded cloudera-quickstart-vm-5.13.0.0. Booted virtual disk with the following settings (note my base machine is Windows 10 Education, patch 1909, with intel i7 4-core and 16GB RAM. I turned Hyper-V off for this project.)
      - **OS:** Red Hat Linux (64-bit) v6.7
      - **CPUs:** 3
      - **Base Memory:** 10736 MB
      - **Video Memory:** 16 MB
      - **Network Adapter:** Enabled
   2. I added a TCP port-forwarding rule as per the instructions, from host port 2222 to guest port 22
   3. In addition, I mounted a shared folder, mounting this repository to a machine folder named "/home/cloudera/share/" with full access for the root user. This should be equivalent to an infrastructure team cloning this repo there. 
      - For me, this command is `sudo mount -t vboxsf pied_piper_proj2 share`, but this will differ depending on your file system.
      - Alternatively, you can `git clone https://github.umn.edu/longx552/pied_piper_proj2.git`, and the directory will be named 'pied_piper_proj2'. Note that the version of git which comes packaged in Cloudera is 1.7.1, which does not support command-line credential passing, as is likely needed for UMN's enterprise github. Update git with `sudo yum update git` before cloning.

# Running
- To run deliverable 2, open a terminal from the project directory (the same location as this file) and enter the command `bash ./bash/deploy-proj2.sh --do_deliverable_2`. Alternatively, you can do each step in this process with individual commands:
   1. `bash ./bash/deploy-proj2.sh --download_data`: Downloads data from AWS
   2. `bash ./bash/deploy-proj2.sh --load_data`: Loads the data from Linux's ext4 file system to HDFS
   3. `bash ./bash/deploy-proj2.sh --create_raw_tables`: Creates external table views around the files in HDFS which can be queried from Impala.
- To clean deliverable 2, run the command `bash ./bash/deploy-proj2.sh --clean_deliverable_2`. Alternatively, you can do each step in this process with individual commands:
   1. `bash ./bash/deploy-proj2.sh --do_deliverable_2`

# Data Integrity
- One meta-issue with the defined schema in the assignment is that it requests a column in the Sales table named Date, which is a reserved keyword in Impala. A different name would be better, but we can work around it.
- Analysis of Customer file:
   - Distinct customer IDs: 19,759 , number of rows: 19,760. There are two instances of one of the same record. This turns out to be CustomerID 17,829: Stefanie Smith
   - Customer IDs range from 1 to 19759, as expected.
   - We look for any first or last names that are invalid names (don't start with an alphabetical). There aren't any, but there are 49 names with letters not in the simple alphabet set [a-zA-Z]. For example "Jésus", "Yao-Qiang", and "Ty Loren". These all look like valid names, so we see no problems here.
   - The same process for last names reveals 89 non-simple last names, but no invalid or missing last names.
   - There are 8,334 records with blank middle initials. 11,426 have alphabetical middle initials, and none have any invalid middle initials. No problems here.
- Analysis of Employees file:
   - Distinct employee IDs: 23, number of rows: 23. Employee IDs range from 1 to 23, no problems here.
   - There are no invalid first or last names (not starting with alphabetic), although there are three last names which have a non-alphabetic character such as "Blotchet-Halls". There is one employee with an invalid middle initial " ' ". We will set this to an empty string.
   - There are 5 regions - North, South, West, East, and east, with 4 employees in east and 3 in East. We will combine these by setting all values of east to East.
- Analysis of Products file: 
   - Distinct product IDs: 504, number of rows: 504. There were no duplicate productIDs or names in the raw data
   - When loading data from the csv file into the raw table, Impala was unable to do a cast from string to decimal for the Price column. This required us to make the Price column a Float type. When creating the managed table, we successfully cast the float values into decimals precise to the hundredths place (emulating cents in a dollar amount).
   - There are 274 product names with at least one occurance of non alphanumeric characters. In all cases, they were "-", ",", "/", or " ' ". These are valid characters to be in a product name so we have left them as is in the managed table.
  
- Analysis of Sales file:
   - 6,715,221 distinct rows
   - 23 sales person ids, ranging from 1 to 23, this corresponds to the 23 employee ids in the employees table. 
   - There are 567 distinct customer ids present, which correspond to customer ids in the customer table. This means that of the 19,759 customers in the customers table, only 567 of them have purchased products. The ids range from 1 to 19,680. 
   - All 504 products from the product table are present in this table as well, under the productid column. 
   - The quantity of items in a sale range from 1-1042. There are no negative numbers or nonnumeric characters. 



# Partitioning Performance
TODO: "Document your finding on the performance on the monthly sales view using partitioned and non-partitioned data. Explain the reasoning, which will be more responsive to data visualization?
