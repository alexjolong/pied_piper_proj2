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

# Deliverable 2:
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
- Load raw data into HDFS (note - make sure that quickstart.cloudera service is running - go to a browser and login to cloudera manager, and restart the cloudera quickstart cluster)
   1. In my VM from the cloudera home directory, I now have an attached folder `share/data` which contains the downloaded data files `share/data/salesdb/Customers2.csv`, `share/data/salesdb/Employees2.csv`, etc.
   2. Run the bash script `/scripts/raw_data_into_hdfs.sh` to create hdfs folders for the raw data, and to move raw files into those folders.
- Create an Impala sales database
   1. From within the shared directory, run this command `bash ./bash/deploy-proj2.sh -d`
      - The `-d` option downloads the dataset from AWS, unzips it, and stores it in the local filesystem.
   2. Then, run `bash ./bash/deploy-proj2.sh -l`
      - The `-l` option loads the raw data from the linux ext4 file system into Hadoop Distributed Filesystem.