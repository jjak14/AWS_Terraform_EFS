# AWS_Terraform_EFS
Simple Terraform to practice EFS.

The code:
  - Launches an EFS with mount targets in 2 different AZs
  - Lauches two EC2 instances in separate AZs and run bacics user data to install nfs utilities
  - Output the public IPv4 of each instance and EFS Mount Target

Once deployed connect to each instance and mount you EFS to the desired folder.

sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport {ip_address of the mount target}:/ /{directory where you want to mount EFS}
