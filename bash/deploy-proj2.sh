#!/usr/bin/env

# Global variables
ext4_data_directory=~/data
hdfs_data_directory=/data
sql_script_directory=./sql
option_count=0
option=$1  # first argument passed, if any



## Displays all function call options when you call "bash ./bash/deploy-proj2.sh -h"  
display_help() {
    echo "Usage: $) [option...] " >&2
    echo
    echo "  -h, --help          display help contents"
    echo "  -d, --download_data     get data from url and unzip it locally"
    echo "  -l, --load_data          load data to hdfs and delete local data"
    echo "  -cr, --create_raw_tables      create impala external table views on raw sales data"
    echo "  -cp, --create_parquet_tables    create sales database containing parquet tables"
    echo "  -cv, --create_views     create views customer_monthly_sales_2019_view & top_ten_customers_amount_view"
    echo "  -cpart, --create_partitions     create partition tables and views for Deliverable 3"
    echo "  -dh, --delete_hdfs_raw      delete raw sales data files from HDFS"
    echo "  -dr, --drop_raw_database      drop raw database and cascading to drop all external table views on raw data"
    echo "  -ds, --drop_sales_database      drop sales DB and cascading to drop parquet tables"
    echo "  -dv, --drop_views       drop views customer_monthly_sales_2019_view  &  top_ten_customers_amount_view"
    echo "  -dp, --drop_partitions      drop the partition tables and views from Deliverable 3"
    echo "  -d2, --do_deliverable_2      To run deliverable 2"
    echo "  -c2, --clean_deliverable_2      To clean deliverable 2 (delete all data)"
    exit 1
}


# TODO: If file already exists, produce warning at this step
download_data() {
    echo "Getting sales data from AWS..."
    sudo wget https://csci5751-2020sp.s3-us-west-2.amazonaws.com/sales-data/salesdata.tar.gz
    echo "Sales data retrieved, unzipping..."
    sudo tar -xvzf salesdata.tar.gz
    sudo rm -r -f $ext4_data_directory   # possibly clean up from previous groups
    sudo mv salesdb $ext4_data_directory
    echo "Done unzipping, cleaning up..."
    sudo rm -f salesdata.tar.gz
}

load_data() {
    echo "Making Hadoop Folders for Impala Load..."
    sudo -u hdfs hdfs dfs -mkdir -p $hdfs_data_directory/Customers/
    sudo -u hdfs hdfs dfs -mkdir -p $hdfs_data_directory/Employees/
    sudo -u hdfs hdfs dfs -mkdir -p $hdfs_data_directory/Products/
    sudo -u hdfs hdfs dfs -mkdir -p $hdfs_data_directory/Sales/

    echo "Putting data into Hadoop Distributed File System..."
    sudo -u hdfs hdfs dfs -put $ext4_data_directory/Customers2.csv $hdfs_data_directory/Customers/
    sudo -u hdfs hdfs dfs -put $ext4_data_directory/Employees2.csv $hdfs_data_directory/Employees/
    sudo -u hdfs hdfs dfs -put $ext4_data_directory/Products.csv $hdfs_data_directory/Products/
    sudo -u hdfs hdfs dfs -put $ext4_data_directory/Sales2.csv $hdfs_data_directory/Sales/

    echo "Make Impala/Hive the owner of our raw data in HDFS"
    sudo -u hdfs hdfs dfs -chown -R hive:impala $hdfs_data_directory

    echo "Making HDFS directory for Impala so that Parquet files can be deleted"
    sudo -u hdfs hdfs dfs -mkdir -p /user/impala
    sudo -u hdfs hdfs dfs -chown -R impala:impala /user/impala

    echo "Cleaning up"
    sudo rm -r -f $ext4_data_directory/
}

delete_hdfs_raw_data() {
    echo "Deleting raw sales data files from HDFS"
    sudo -u hdfs hdfs dfs -rm -r $hdfs_data_directory
}

create_raw_tables() {
    echo "Creating Impala external table views on raw sales data..."
    impala-shell -f "$sql_script_directory"/create_employees_table.sql
    impala-shell -f "$sql_script_directory"/create_customers_table.sql
    impala-shell -f "$sql_script_directory"/create_products_table.sql
    impala-shell -f "$sql_script_directory"/create_sales_table.sql
    echo "Done!"
}

create_parquet_tables() {
    echo "Creating Sales Database containing Parquet tables by selecting from external table views on raw data"
    impala-shell -f "$sql_script_directory"/create_sales_db.sql
    echo "Done!"
}

create_views() {
    echo "Creating customer monthly sales view and top ten customers view"
    impala-shell -f "$sql_script_directory"/create_view-customer_monthly_sales_2019_view.sql
    impala-shell -f "$sql_script_directory"/create_view-top_ten_customers_amount_view.sql
    echo "Done!"
}

create_partitions() {
    echo "Creating partition tables and views for Deliverable 3"
    impala-shell -f "$sql_script_directory"/create_partition-product_sales_partition.sql
    impala-shell -f "$sql_script_directory"/create_view-customer_monthly_sales_2019_partitioned_view.sql
    impala-shell -f "$sql_script_directory"/create_partition-product_region_sales_partition.sql
    echo "Done!"
}

drop_raw_database() {
    echo "Dropping raw database and cascading to drop all external table views on raw data"
    impala-shell -q "DROP DATABASE IF EXISTS pied_piper_sales_raw CASCADE;"
}

drop_sales_database() {
    echo "Dropping Sales DB and cascading to drop parquet tables"
    impala-shell -q "DROP DATABASE IF EXISTS pied_piper_sales CASCADE;"
}

drop_views() {
    echo "Dropping both views (pied_piper_sales) customer_monthly_sales_2019_view  &  top_ten_customers_amount_view"
    impala-shell -q "Drop VIEW IF EXISTS pied_piper_sales.customer_monthly_sales_2019_view;"
    impala-shell -q "Drop VIEW IF EXISTS pied_piper_sales.top_ten_customers_amount_view;"
    echo "Done!"
}

drop_partitions() {
    echo "Dropping the partition tables and views from Deliverable 3"
    impala-shell -q "Drop TABLE IF EXISTS pied_piper_sales.product_sales_partition;"
    impala-shell -q "Drop VIEW IF EXISTS pied_piper_sales.customer_monthly_sales_2019_partitioned_view;"
    impala-shell -q "Drop TABLE IF EXISTS pied_piper_sales.product_region_sales_partition;"
    echo "Done!"
}



do_deliverable_2() {
    download_data
    load_data
    create_raw_tables
    create_parquet_tables
    create_views
}

clean_deliverable_2() {
    drop_sales_database
    drop_raw_database
    delete_hdfs_raw_data
}

# Parse input arguments and execute
while [ $option_count -eq 0 ]; do
    option_count=$(( option_count + 1 ))

    case $option in
        -h | --help)
            display_help
            ;;
        
        -d | --download_data)
            download_data
            ;;
        
        -l | --load_data)
            load_data
            ;;

        -cr | --create_raw_tables)
            create_raw_tables
            ;;

        -cp | --create_parquet_tables)
            create_parquet_tables
            ;;
        -cv | --create_views)
            create_views
            ;;

        -cpart | --create_partitions)
            create_partitions
            ;;

        -dh | --delete_hdfs_raw)
            delete_hdfs_raw_data
            ;;

        -dr | --drop_raw_database)
            drop_raw_database
            ;;

        -ds | --drop_sales_database)
            drop_sales_database
            ;;

        -dv | --drop_views)
            drop_views
            ;;
        
        -dp | --drop_partitions)
            drop_partitions
            ;;

        -d2 | --do_deliverable_2)
            do_deliverable_2
            ;;

        -c2 | --clean_deliverable_2)
            clean_deliverable_2
            ;;

        --) # User indicating no more options
            shift # shift this argument off the array
            break # get out of the case statement
            ;;
        
        -*) # Any argument we don't expect
            echo "Unknown option provided: $1" >&2 # pipe to stderr (&2 file descriptor)
            exit 1
            ;;

        *) # Nothing
            break
            ;;
    
    esac
done
