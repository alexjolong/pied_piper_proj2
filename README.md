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
      - Alternatively, you can `git clone https://github.umn.edu/longx552/pied_piper_proj2.git`, and the directory will be named 'pied_piper_proj2'

# Running
- To run deliverable 2, open a terminal from the project directory (the same location as this file) and enter the command `bash ./bash/deploy-proj2.sh --do_deliverable_2`. Alternatively, you can do each step in this process with individual commands:
   1. `bash ./bash/deploy-proj2.sh --download_data`: Downloads data from AWS
   2. `bash ./bash/deploy-proj2.sh --load_data`: Loads the data from Linux's ext4 file system to HDFS
   3. `bash ./bash/deploy-proj2.sh --create_raw_tables`: Creates external table views around the files in HDFS which can be queried from Impala.
- To clean deliverable 2, run the command `bash ./bash/deploy-proj2.sh --clean_deliverable_2`. Alternatively, you can do each step in this process with individual commands:
   1. `bash ./bash/deploy-proj2.sh --do_deliverable_2`

# Data Integrity
- One meta-issue with the defined schema in the assignment is that it requests a column in the Sales table named Date, which is a reserved keyword in Impala. A different name would be better, but we can work around it.
TODO: "Do quality analysis on the data, if you find any issues, document the issues in your ReadME

# Partitioning Performance
TODO: "Document your finding on the performance on the monthly sales view using partitioned and non-partitioned data. Explain the reasoning, which will be more responsive to data visualization?
