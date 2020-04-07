#!/usr/bin/env

# Global variables
ext4_data_directory=~/data
hdfs_data_directory=/data
option_count=0
option=$1  # first argument passed, if any

# TODO: If file already exists, produce warning at this step
download_data() {
    echo "Getting sales data from AWS..."
    wget https://csci5751-2020sp.s3-us-west-2.amazonaws.com/sales-data/salesdata.tar.gz
    echo "Sales data retrieved, unzipping..."
    tar -xvzf salesdata.tar.gz
    rm -f $ext4_data_directory   # possibly clean up from previous groups
    mv salesdb $ext4_data_directory
    echo "Done unzipping, cleaning up..."
    rm -f salesdata.tar.gz
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
    sudo -u hdfs hdfs dfs -chown -R hive:hive $hdfs_data_directory
}


# Parse input arguments and execute
while [ $option_count -eq 0 ]; do
    option_count=$(( option_count + 1 ))

    case $option in
        -d | --download_data)
            download_data
            ;;
        
        -l | --load_data)
            load_data
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